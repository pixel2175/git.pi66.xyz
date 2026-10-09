local fs = require("fs")
local git = require("git")
local ui = require("ui")
local config = require("config")

local M = {}

local function load_root(root)
	local repos = {}
	for _, dir in ipairs(fs.listdir(root) or {}) do
		local repo = git.load(root .. "/" .. dir)
		if repo then
			ui.info("loading " .. ui.cyan(repo.name))
			repos[#repos + 1] = repo
		end
	end
	if #repos == 0 then
		ui.info("no repos loaded from " .. ui.cyan(root))
	end
	return repos
end

function M.load_one(name)
	for _, root in ipairs(config.roots) do
		for _, dir in ipairs({ name, name .. ".git" }) do
			local path = root .. "/" .. dir
			if fs.isdir(path) then
				local repo = git.load(path)
				if repo then
					ui.info("loading " .. ui.cyan(repo.name))
					return repo
				end
			end
		end
	end
end

function M.load_all()
	local all = {}
	for _, root in ipairs(config.roots) do
		for _, repo in ipairs(load_root(root)) do
			all[#all + 1] = repo
		end
	end
	return all
end

function M.find(repos, name)
	for _, repo in ipairs(repos) do
		if repo.name == name or repo.slug == name then
			return repo
		end
	end
end

return M
