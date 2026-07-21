import os
from models import Repo
from progress import progress, progress_done


def create_ref_pages(api, repos: list[Repo]):
    total = len(repos)
    for i, repo in enumerate(repos, 1):
        progress("Refs", i, total)
        try:
            html = api.jinja_handler(api.config, '{% extends "Refs.html" %}', plugins={
                "repo_name": repo.name,
                "repo_desc": repo.desc,
                "page_title": f"Pi66 - {repo.name} - Refs",
                "metadata_content": repo.desc or "A web interface for the pi66.xyz Git server",
                "refs": repo.refs,
            })

            dest = os.path.join(api.config.tree.dest, f"{repo.name.lower()}/refs.html")
            api.save_html(html, dest)
        except Exception as e:
            api.log.warn(f"Error building refs for {repo.name}: {e}")
    progress_done("Refs", total)
