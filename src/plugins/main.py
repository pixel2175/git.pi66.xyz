import os
from git import load_repos
from log_builder import create_log_pages
from file_builder import create_file_pages
from ref_builder import create_ref_pages
from readme_builder import create_readme_pages
from license_builder import create_license_pages

storage = api.globals

storage.set("git_dirs",{
    "release":"/srv/git/",
    "draft":"/home/pixel/docs/projects/coding/websites/cache/git.pi66.xyz/tmp"}
)
GIT_DIR = storage.get("git_dirs")[api.mode]

def ensure_repos():
    return load_repos(
        api,
        os.path.expanduser(GIT_DIR)
    )

@hook("on_build_start")
def on_start_(_):
    storage.set("repos", ensure_repos())

@hook("on_build_end")
def build_pages(_):
    repos = storage.get("repos")
    ensure_repos()
    create_log_pages(api, repos)
    create_file_pages(api, repos, os.path.expanduser(GIT_DIR))
    create_ref_pages(api, repos)
    create_readme_pages(api, repos)
    create_license_pages(api, repos)
