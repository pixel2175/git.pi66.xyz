import os
from models import Repo
from progress import progress, progress_done


def create_readme_pages(api, repos: list[Repo]):
    total = len(repos)
    for i, repo in enumerate(repos, 1):
        progress("Readme", i, total)
        try:
            content = api.compile_page(repo.readme) if repo.readme else "<p>No README available.</p>"

            html = api.jinja_handler(api.config, '{% extends "Readme.html" %}', plugins={
                "repo_name": repo.name,
                "repo_desc": repo.desc,
                "readme_content": content,
            })

            dest = os.path.join(api.config.tree.dest, f"{repo.name.lower()}/readme.html")
            api.save_html(html, dest)
        except Exception as e:
            api.log.warn(f"Error building readme for {repo.name}: {e}")
    progress_done("Readme", total)
