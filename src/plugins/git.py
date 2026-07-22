import os
import subprocess

from models import (
    Repo,
    Commit,
    ChangedFile,
    FileEntry,
    Ref,
    RefEntry,
)
from progress import progress, progress_done


def load_repos(api, directory: str):
    repos = []

    entries = [
        entry
        for entry in os.scandir(directory)
        if entry.is_dir() and os.path.isdir(os.path.join(entry.path, ".git"))
    ]

    total = len(entries)
    for i, entry in enumerate(entries, 1):
        progress("Loading", i, total)
        try:
            repos.append(load_repo(entry.path))
        except Exception as e:
            api.log.warn(f"Failed to load {entry.name}: {e}")

    progress_done("Loading", total)
    return repos


def _git(path: str, *args: str) -> str:
    try:
        result = subprocess.run(
            ["git", "-C", path, *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
        return result.stdout
    except Exception:
        return ""


def _load_repo_info(path: str) -> tuple[str, str, str, str]:
    name = os.path.basename(os.path.abspath(path))

    desc = ""
    desc_file = os.path.join(path, ".git", "description")

    if os.path.isfile(desc_file):
        with open(desc_file, "r", encoding="utf-8", errors="ignore") as f:
            desc = f.read().strip()

        if desc.startswith("Unnamed repository"):
            desc = ""

    author = _git(path, "log", "--reverse", "--format=%an").strip()
    if "\n" in author:
        author = author.splitlines()[0]

    last_commit_date = _git(
        path, "log", "-1", "--format=%ad", "--date=format:%Y-%m-%d %H:%M"
    ).strip()

    return (name, desc, author, last_commit_date)


def _load_file_from_head(path: str, candidates: list[str]) -> str | None:
    for name in candidates:
        text = _git(path, "show", f"HEAD:{name}")
        if text:
            return text
    return None


_LICENSE_NAMES = [
    "LICENSE.txt", "LICENSE.md", "LICENSE",
    "license.txt", "license.md", "license",
    "License.txt", "License.md", "License",
]

_README_NAMES = [
    "README.txt", "README.md", "README",
    "readme.txt", "readme.md", "readme",
    "Readme.txt", "Readme.md", "Readme",
]


def _mode_to_perm(mode: str) -> str:
    return {
        "100644": ".rw-r--r--",
        "100755": ".rwxr-xr-x",
        "120000": "lrwxrwxrwx",
        "040000": "drwxr-xr-x",
        "160000": "m---------",
    }.get(mode, mode)


def _format_size(num_bytes: int) -> str:
    size = float(num_bytes)
    for unit in ("B", "KB", "MB", "GB"):
        if size < 1024:
            return f"{size:.0f}{unit}" if unit == "B" else f"{size:.1f}{unit}"
        size /= 1024
    return f"{size:.1f}TB"


def _load_files(path: str) -> list[FileEntry]:
    output = _git(path, "ls-tree", "-r", "-l", "-z", "HEAD")

    files = []
    for entry in output.split("\0"):
        if not entry:
            continue

        meta, _, filepath = entry.partition("\t")
        parts = meta.split()

        if len(parts) < 4:
            continue

        mode, _type, _sha, size = parts[0], parts[1], parts[2], parts[3]
        size_int = int(size) if size.isdigit() else 0
        display_size = _format_size(size_int)

        files.append(
            FileEntry(
                path=filepath,
                mode=_mode_to_perm(mode),
                size=display_size,
            )
        )

    return files


def _load_single_ref(path: str, refname: str) -> list[RefEntry]:
    output = _git(
        path,
        "for-each-ref",
        "--sort=-committerdate",
        "--format=%(refname:short)\t%(committerdate:format:%Y-%m-%d %H:%M)\t%(authorname)",
        refname,
    )

    refs: list[RefEntry] = []

    for line in output.splitlines():
        if not line:
            continue

        parts = line.split("\t", 2)
        if len(parts) != 3:
            continue

        name, date, author = parts
        refs.append(RefEntry(name=name, date=date, author=author))

    return refs


def _load_refs(path: str) -> list[Ref]:
    return [
        Ref(name="branches", refs=_load_single_ref(path, "refs/heads")),
        Ref(name="tags", refs=_load_single_ref(path, "refs/tags")),
        Ref(name="remotes", refs=_load_single_ref(path, "refs/remotes")),
    ]
def compute_bars(changed_files: list[ChangedFile], max_width: int = 30) -> list[dict]:
    max_changes = max((f.added_lines + f.removed_lines for f in changed_files), default=1) or 1
    bars = []
    for f in changed_files:
        total = f.added_lines + f.removed_lines
        width = round((total / max_changes) * max_width) if total else 0
        add_w = round(width * f.added_lines / total) if total else 0
        bars.append({"file": f, "total": total, "add_width": add_w, "del_width": width - add_w})
    return bars


def _load_commits(path: str) -> list[Commit]:
    output = _git(
        path,
        "log",
        "--date=format:%Y-%m-%d %H:%M",
        "--numstat",
        "--raw",
        "--no-merges",
        "--format=%x1e%H%x1f%an%x1f%ad%x1f%s",
    )

    commits: list[Commit] = []

    for block in output.split("\x1e"):
        block = block.strip()
        if not block:
            continue

        lines = block.splitlines()
        parts = lines[0].split("\x1f")

        if len(parts) != 4:
            continue

        commit_hash, author, date, message = parts
        statuses: dict[str, str] = {}
        numstats: list[tuple[str, str, str]] = []

        for line in lines[1:]:
            if line.startswith(":"):
                raw_parts = line.split("\t")
                meta = raw_parts[0].split()
                if len(meta) >= 5 and len(raw_parts) >= 2:
                    statuses[raw_parts[-1]] = meta[4][0]
            else:
                fields = line.split("\t")
                if len(fields) == 3:
                    numstats.append(tuple(fields))

        changed_files: list[ChangedFile] = [
            ChangedFile(
                name=filename,
                added_lines=int(added) if added.isdigit() else 0,
                removed_lines=int(removed) if removed.isdigit() else 0,
                status=statuses.get(filename, "M"),
            )
            for added, removed, filename in numstats
        ]

        if not changed_files:
            continue

        patch = _git(path, "show", commit_hash, "--patch", "--format=")

        commits.append(
            Commit(
                date=date,
                message=message,
                author=author,
                commit_hash=commit_hash,
                files=changed_files,
                patch=patch,
            )
        )

    return commits


def load_repo(path: str) -> Repo:
    name, desc, author, last_commit_date = _load_repo_info(path)

    return Repo(
        name=name,
        desc=desc,
        author=author,
        readme=_load_file_from_head(path, _README_NAMES),
        license=_load_file_from_head(path, _LICENSE_NAMES),
        commits=_load_commits(path),
        files=_load_files(path),
        refs=_load_refs(path),
        last_commit_date=last_commit_date,
    )
