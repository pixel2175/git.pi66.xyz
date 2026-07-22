import os
import re
import subprocess
from git import load_repos
from log_builder import create_log_pages
from file_builder import create_file_pages
from ref_builder import create_ref_pages
from readme_builder import create_readme_pages
from license_builder import create_license_pages

GIT_DIR = "/srv/git/"

if api.mode == "draft":
    GIT_DIR = "/home/pixel/docs/projects/coding/websites/cache/git.pi66.xyz/tmp"


repos = []

def ensure_repos():
    global repos
    if not repos:
        repos.extend(load_repos(
            api,
            os.path.expanduser(GIT_DIR)
        ))

@hook("on_build_start")
def load_repos_hook(_):
    ensure_repos()

@hook("on_page_read")
def inject_repos(md_file, md_content):
    if "index.md" not in md_file:
        return
    ensure_repos()
    rows = []
    for repo in repos:
        rows.append(
            f'<tr>\n'
            f'    <td> <a href="/{repo.name.lower()}/log.html"><strong>{repo.name}</strong></a> </td>\n'
            f'    <td class="!text-gray-400"> {repo.desc}</td>\n'
            f'    <td class="!text-gray-400"> {repo.author}</td>\n'
            f'    <td class="!text-gray-400"> {repo.last_commit_date}</td>\n'
            f'</tr>'
        )
    table = "\n\n".join(rows)
    return re.sub(
        r"\{%\s*for repo in repos\s*%\}.*?\{%\s*endfor\s*%\}",
        table,
        md_content,
        flags=re.DOTALL,
    )

@hook("on_file_changed")
def on_file_changed_hook(changed_path, config):
    if changed_path.startswith(config.tree.static) and api.mode == "release":
        subprocess.run(["rsync", "-a", api.config.tree.static, os.path.join(os.path.dirname(api.config.tree.release_dest),"static") ])

@hook("on_end")
def sync_static():
    if api.mode == "release":
        subprocess.run(["rsync", "-a", api.config.tree.static, os.path.join(os.path.dirname(api.config.tree.release_dest),"static") ])

@hook("on_build_end")
def build_pages(_):
    global repos
    ensure_repos()
    create_log_pages(api, repos)
    create_file_pages(api, repos, os.path.expanduser(GIT_DIR))
    create_ref_pages(api, repos)
    create_readme_pages(api, repos)
    create_license_pages(api, repos)
