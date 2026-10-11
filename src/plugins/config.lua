local tree = merodi.config.tree
local release = merodi.build.mode() == "release"

return {
	release = release,
	dest = release and tree.release_dest or tree.draft_dest,
	templates = tree.templates,
	roots = { os.getenv("GIT_REPOS") },
	pages = {
		{ "index.html",         "repo.md"    },
		{ "files/index.html",   "files.md"   },
		{ "commits/index.html", "commits.md" },
		{ "refs/index.html",    "refs.md"    },
		{ "license/index.html", "license.md" },
	},
}
