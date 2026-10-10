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

local function missing_commits(repo, out)
	local done = {}
	for _, name in ipairs(fs.listdir(out .. "/commit") or {}) do
		done[name] = true
	end

	local missing = {}
	for _, commit in ipairs(repo.commits) do
		if not done[commit.short] then
			missing[#missing + 1] = commit
		end
	end
	return missing
end

local function write_commits(repo, out, commits)
	if #commits == 0 then
		return
	end

	ui.status("writing " .. ui.gray("commit pages"))
	local total = #commits
	for i, commit in ipairs(commits) do
		ui.progress(i, total, commit.short)
		merodi.jinja.set("commit", git.show(repo, commit))
		render.page("commit.md", out .. "/commit/" .. commit.short .. "/index.html")
	end
end

function M.repo(repo, incremental)
	local out = config.dest .. "/" .. repo.slug
	local commits = repo.commits

	ui.info("Processing " .. ui.cyan(repo.name))

	if incremental then
		fs.remove_all(out .. "/raw")
		commits = missing_commits(repo, out)
	else
		fs.remove_all(out)
	end

	merodi.jinja.set("repo", repo)

	export_raw(repo, out)
	write_pages(out)
	write_commits(repo, out, commits)
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
	M.repo(repo, true)
	return true
end
return M
