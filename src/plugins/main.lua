package.path = "src/plugins/?.lua;" .. package.path

require("watch")
local fs = require("fs")
local git = require("git")
local helper = require("helpers")

merodi.enable.GFM()
merodi.enable.HeaderAttr()
merodi.enable.BlockAttr()
merodi.enable.InlineAttr()

local release = merodi.build.mode() == "release"
local root = os.getenv("REPOS") or (release and "/srv/git" or "/home/pixel/repos")
local dest = release and merodi.config.tree.release_dest or merodi.config.tree.draft_dest
local templates = merodi.config.tree.templates

local function render(template, out)
	local html = merodi.compile.convert(fs.read(templates .. "/" .. template))
	fs.mkdirp(fs.path.dirname(out))
	fs.write(out, html)
end

local repos = {}

for _, name in ipairs(fs.listdir(root)) do
	local repo = git.load(root .. "/" .. name)

	if repo then
		merodi.log.info("Git: loading " .. helper.cyan(repo.name))
		repos[#repos + 1] = repo
	end
end

merodi.jinja.set("repos", repos)

local pages = {
	["index.html"]         = "repo.md",
	["files/index.html"]   = "files.md",
	["commits/index.html"] = "commits.md",
	["refs/index.html"]    = "refs.md",
	["license/index.html"] = "license.md",
}

print()
for _, repo in ipairs(repos) do
	local out = dest .. "/" .. repo.slug

	fs.remove_all(out)

	merodi.log.info("Git: Processing " .. helper.cyan( repo.name ))
	merodi.log.info("Git: Moving: " .. helper.gray("raw files")  .. "\r" )
	git.export(repo, out .. "/raw")

	merodi.jinja.set("repo", repo)

	io.write("\27[1A\27[2K\r")
	merodi.log.info("Git: writing " .. helper.gray("pages")  .. "\r" )

	for page, template in pairs(pages) do
		io.write("\27[1A\27[2K\r")
		merodi.log.info("Git: writing " .. helper.gray(string.sub(template, 1, -4)) .. "\r" )
		render(template, out .. "/" .. page)
	end

	io.write("\27[1A\27[2K\r")
	merodi.log.info("Git: writing ".. helper.gray("commit pages"))

	for idx, commit in ipairs(repo.commits) do
		io.write("[" .. idx .. "/" .. #repo.commits .. "]- " .. helper.gray(commit.short).."\r")
		merodi.jinja.set("commit", git.show(repo, commit))
		render("commit.md", out .. "/commit/" .. commit.short .. "/index.html")
	end
end
