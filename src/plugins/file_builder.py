import os
from models import Repo
from progress import progress, progress_done


def _get_file_extension(filename: str) -> str:
    return os.path.splitext(filename)[1].lstrip(".")


def _create_file_preview_page(api, repo_name, repo_desc, git_path, file):
    file_path = os.path.join(git_path, repo_name, file.path)
    file_ext = _get_file_extension(file.path)

    try:
        with open(file_path, "rb") as f:
            content = f.read()
    except FileNotFoundError:
        return

    if b"\x00" in content:
        content = "[BIN FILE]"
    else:
        try:
            decoded = content.decode()
        except UnicodeDecodeError:
            decoded = content.decode(errors="replace")

        content = api.md_to_html(
            config=api.config,
            md_content=f"```{file_ext}\n{decoded}```"
        )

    html = api.jinja_handler(api.config, '{% extends "File-preview.html" %}', plugins={
        "repo_name": repo_name,
        "repo_desc": repo_desc,
        "page_title": f"Pi66 - {repo_name} - {file.path}",
        "metadata_content": repo_desc or "A web interface for the pi66.xyz Git server",
        "file_name": file.path,
        "file_content": content,
    })

    dest = os.path.join(api.config.tree.draft_dest if api.mode == "draft" else api.config.tree.release_dest, f"{repo_name.lower()}/files/{file.path}.html")
    api.save_html(html, dest)


def create_file_pages(api, repos: list[Repo], git_dir):
    total = len(repos)
    for i, repo in enumerate(repos, 1):
        progress("Files", i, total)
        try:
            for file in repo.files:
                _create_file_preview_page(api, repo.name, repo.desc, git_dir, file)

            html = api.jinja_handler(api.config, '{% extends "Files.html" %}', plugins={
                "repo_name": repo.name,
                "repo_desc": repo.desc,
                "page_title": f"Pi66 - {repo.name} - Files",
                "metadata_content": repo.desc or "A web interface for the pi66.xyz Git server",
                "files": repo.files,
            })

            dest = os.path.join(api.config.tree.draft_dest if api.mode == "draft" else api.config.tree.release_dest, f"{repo.name.lower()}/files.html")
            api.save_html(html, dest)
        except Exception as e:
            api.log.warn(f"Error building files for {repo.name}: {e}")
    progress_done("Files", total)
