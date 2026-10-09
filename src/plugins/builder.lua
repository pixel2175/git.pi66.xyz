local fs = require("fs")
local git = require("git")
local ui = require("ui")
local config = require("config")
local render = require("render")
local repos_mod = require("repos")

local M = {}

local function export_raw(repo, out)
	ui.info("Moving: " .. ui.gray("raw files") .. "\r")
	git.export(repo, out .. "/raw")
end

local function write_pages(out)
	for _, page in ipairs(config.pages) do
		ui.status("writing " .. ui.gray(page[2]:sub(1, -4)))
		render.page(page[2], out .. "/" .. page[1])
	end
end

local function write_commits(repo, out)
	ui.status("writing " .. ui.gray("commit pages"))
	local total = #repo.commits
	for i, commit in ipairs(repo.commits) do
		ui.progress(i, total, commit.short)
		merodi.jinja.set("commit", git.show(repo, commit))
		render.page("commit.md", out .. "/commit/" .. commit.short .. "/index.html")
	end
end

function M.repo(repo)
	local out = config.dest .. "/" .. repo.slug

	ui.info("Processing " .. ui.cyan(repo.name))
	fs.remove_all(out)
	merodi.jinja.set("repo", repo)

	export_raw(repo, out)
	write_pages(out)
	write_commits(repo, out)
end

function M.all()
	local repos = repos_mod.load_all()
	merodi.jinja.set("repos", repos)

	print()
	for _, repo in ipairs(repos) do
		M.repo(repo)
	end
end

function M.one(name)
	local repo = repos_mod.load_one(name)

	if not repo then
		ui.info("repo not found: " .. ui.cyan(name))
		return false
	end

	merodi.jinja.set("repos", { repo })
	print()
	M.repo(repo)
	return true
end
return M
