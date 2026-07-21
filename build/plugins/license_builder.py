import os
from models import Repo
from progress import progress, progress_done


def create_license_pages(api, repos: list[Repo]):
    total = len(repos)
    for i, repo in enumerate(repos, 1):
        progress("License", i, total)
        try:
            html = api.jinja_handler(api.config, '{% extends "License.html" %}', plugins={
                "repo_name": repo.name,
                "repo_desc": repo.desc,
                "page_title": f"Pi66 - {repo.name} - License",
                "metadata_content": repo.desc or "A web interface for the pi66.xyz Git server",
                "license_content": repo.license if repo.license else "No license file found.",
            })

            dest = os.path.join(api.config.tree.dest, f"{repo.name.lower()}/license.html")
            api.save_html(html, dest)
        except Exception as e:
            api.log.warn(f"Error building license for {repo.name}: {e}")
    progress_done("License", total)
