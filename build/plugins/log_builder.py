import os
from models import Repo
from dataclasses import asdict
from progress import progress, progress_done


def _total_removed_lines(files):
    return sum(f.removed_lines for f in files)


def _total_added_lines(files):
    return sum(f.added_lines for f in files)


def _create_commit_page(api, repo_name, repo_desc, commit):
    dest = os.path.join(
        api.config.tree.dest,
        f"{repo_name.lower()}/commits/{commit.commit_hash}.html"
    )

    if os.path.exists(dest):
        return

    patch_html = api.md_to_html(
        config=api.config,
        md_content=f"```diff\n{commit.patch}```"
    )

    html = api.jinja_handler(api.config, '{% extends "Log-commit.html" %}', plugins={
        "repo_name": repo_name,
        "repo_desc": repo_desc,
        "commit_date": commit.date,
        "commit_hash": commit.commit_hash,
        "commit_message": commit.message,
        "commit_author": commit.author,
        "changed_files": [asdict(f) for f in commit.files],
        "diff_content": patch_html,
    })

    api.save_html(html, dest)


def create_log_pages(api, repos: list[Repo]):
    total = len(repos)
    for i, repo in enumerate(repos, 1):
        progress("Logs", i, total)
        try:
            for commit in repo.commits:
                _create_commit_page(api, repo.name, repo.desc, commit)

            html = api.jinja_handler(api.config, '{% extends "Log.html" %}', plugins={
                "repo_name": repo.name,
                "repo_desc": repo.desc,
                "commits": repo.commits,
                "total_added": _total_added_lines,
                "total_removed": _total_removed_lines,
                "len": len,
            })

            dest = os.path.join(api.config.tree.dest, f"{repo.name.lower()}/log.html")
            api.save_html(html, dest)
        except Exception as e:
            api.log.warn(f"Error building log for {repo.name}: {e}")
    progress_done("Logs", total)
