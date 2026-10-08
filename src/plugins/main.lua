package.path = "src/plugins/?.lua;" .. package.path

require("watch")
local fs = require("fs")
local git = require("git")
local helper = require("helpers")

merodi.enable.GFM()
merodi.enable.HeaderAttr()
merodi.enable.BlockAttr()
merodi.enable.InlineAttr()

local tree = merodi.config.tree
local release = merodi.build.mode() == "release"
local dest = release and tree.release_dest or tree.draft_dest
local templates = tree.templates
local roots = os.getenv("REPOS") and { os.getenv("REPOS") }
	or { release and "/srv/git" or "/home/pixel/repos" }

local pages = {
	{ "index.html",         "repo.md"    },
	{ "files/index.html",   "files.md"   },
	{ "commits/index.html", "commits.md" },
	{ "refs/index.html",    "refs.md"    },
	{ "license/index.html", "license.md" },
}

local function render(template, out)
	local html = merodi.compile.convert(fs.read(templates .. "/" .. template))
	fs.mkdirp(fs.path.dirname(out))
	fs.write(out, html)
end

local function status(msg)
	io.write("\27[1A\27[2K\r")
	merodi.log.info("Git: " .. msg .. "\r")
end

local repos = {}

for _, root in ipairs(roots) do
	local found = 0

	for _, name in ipairs(fs.listdir(root) or {}) do
		local repo = git.load(root .. "/" .. name)

		if repo then
			merodi.log.info("Git: loading " .. helper.cyan(repo.name))
			repos[#repos + 1] = repo
			found = found + 1
		end
	end

	if found == 0 then
		merodi.log.info("Git: no repos loaded from " .. helper.cyan(root))
	end
end

merodi.jinja.set("repos", repos)

print()
for _, repo in ipairs(repos) do
	local out = dest .. "/" .. repo.slug
	local total = #repo.commits

	fs.remove_all(out)
	merodi.jinja.set("repo", repo)

	merodi.log.info("Git: Processing " .. helper.cyan(repo.name))
	merodi.log.info("Git: Moving: " .. helper.gray("raw files") .. "\r")
	git.export(repo, out .. "/raw")

	status("writing " .. helper.gray("pages"))
	for _, p in ipairs(pages) do
		status("writing " .. helper.gray(p[2]:sub(1, -4)))
		render(p[2], out .. "/" .. p[1])
	end

	status("writing " .. helper.gray("commit pages"))
	for idx, commit in ipairs(repo.commits) do
		io.write("[" .. idx .. "/" .. total .. "]- " .. helper.gray(commit.short) .. "\r")
		merodi.jinja.set("commit", git.show(repo, commit))
		render("commit.md", out .. "/commit/" .. commit.short .. "/index.html")
	end
end
