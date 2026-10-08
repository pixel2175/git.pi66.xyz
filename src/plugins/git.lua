
local M = {}

local PATCH_LIMIT = 256 * 1024

local function sh(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function run(path, args)
	local pipe = io.popen("git -c core.quotepath=false -C " .. sh(path) .. " " .. args .. " 2>/dev/null")
	local out = pipe:read("*a")
	pipe:close()
	return out
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split(s, sep)
	local fields = {}
	for field in (s .. sep):gmatch("(.-)" .. sep) do
		fields[#fields + 1] = field
	end
	return fields
end

local function esc(s)
	return (s:gsub("[&<>\"|`*_%[%]]", function(c)
		return "&#" .. c:byte() .. ";"
	end))
end

local function urlenc(s)
	return (s:gsub("[^%w%-%._~/]", function(c)
		return string.format("%%%02X", c:byte())
	end))
end

local function human(bytes)
	local units, i = { "B", "KB", "MB", "GB" }, 1
	bytes = tonumber(bytes)
	while bytes >= 1024 and i < #units do
		bytes, i = bytes / 1024, i + 1
	end
	return i == 1 and bytes .. "B" or string.format("%.1f%s", bytes, units[i])
end

local colors = { ["+"] = "text-green-400", ["-"] = "text-red-400", ["@"] = "text-cyan-400" }

local function color(patch)
	return (patch:gsub("[^\n]+", function(line)
		local c = colors[line:sub(1, 1)]
		return c and string.format('<span class="%s">%s</span>', c, line) or line
	end))
end

function M.load(path)
	local log = run(path, "log --all --numstat --abbrev=8 --date='format:%Y-%m-%d %H:%M'"
		.. " --format='%x1e%H%x1f%h%x1f%p%x1f%an%x1f%ad%x1f%s%x1f%b%x1d'")

	local commits = {}

	for record in (log .. "\30"):gmatch("\30(.-)\30") do
		local meta, file_list = record:match("^(.-)\29(.*)$")

		if meta then
			local f = split(meta, "\31")
			local parents = {}
			local files = {}
			local added = 0
			local removed = 0

			for p in f[3]:gmatch("%S+") do
				parents[#parents + 1] = p
			end

			for line in file_list:gmatch("[^\n]+") do
				local add, remove, filename =
					line:match("^(%d+)\t(%d+)\t(.+)$")

				if add and remove then
					add = tonumber(add)
					remove = tonumber(remove)

					local status

					if add > 0 and remove == 0 then
						status = "A"
					elseif add == 0 and remove > 0 then
						status = "D"
					else
						status = "M"
					end

					files[#files + 1] = {
						name = esc(filename),
						added = add,
						removed = remove,
						total = add + remove,
						status = status,
					}

					added = added + add
					removed = removed + remove
				end
			end

			commits[#commits + 1] = {
				hash = f[1]:match("%x+"),
				short = f[2],
				parents = parents,
				author = esc(f[4]),
				date = f[5],
				subject = esc(f[6]),
				body = esc(trim(f[7])),

				stats = {
					files = files,
					added = added,
					removed = removed,
					total = added + removed,
				},
			}
		end
	end

	if #commits == 0 then
		return nil
	end

	local name = path:gsub("/+$", ""):match("([^/]+)$")
	name = name:gsub("%.git$", "")

	local description = ""
	local file = io.open(
		trim(run(path, "rev-parse --absolute-git-dir")) .. "/description"
	)

	if file then
		description = trim(file:read("*a"))
		file:close()
	end

	if description:match("^Unnamed repository") then
		description = ""
	end

	local ref =
		run(path, "rev-parse -q --verify HEAD"):match("%x+")
		and "HEAD"
		or commits[1].hash

	local function read(filename, markdown)
		local content = run(path, "show " .. sh(ref .. ":" .. filename))
		return markdown and content or "<pre>" .. esc(content) .. "</pre>"
	end

	local slug = name:lower()
	local files, readme, license = {}, nil, nil

	for line in run(path, "ls-tree -r -l " .. ref):gmatch("[^\n]+") do
		local size, filename =
			line:match("^%d+ blob %x+%s+(%d+)\t(.+)$")

		if filename then
			files[#files + 1] = {
				path = esc(filename),
				url = "/" .. slug .. "/raw/" .. urlenc(filename),
				size = human(size),
			}

			local lower = filename:lower()

			if lower:match("^readme%.?%a*$") then
				readme = readme or read(filename, lower:match("%.md$"))
			elseif lower:match("^licen[sc]e%.?%a*$") then
				license = license or read(filename, false)
			end
		end
	end

	local refs = {}

	for kind, namespace in pairs({
		branches = "refs/heads",
		tags = "refs/tags",
	}) do
		refs[kind] = {}

		local format =
			"%(HEAD)%09%(refname:short)%09%(objectname:short=8)"
			.. "%09%(*objectname:short=8)%09%(creatordate:short)"
			.. "%09%(contents:subject)"

		local out = run(
			path,
			"for-each-ref --sort=-creatordate --format='"
				.. format
				.. "' "
				.. namespace
		)

		for line in out:gmatch("[^\n]+") do
			local f = split(line, "\t")

			refs[kind][#refs[kind] + 1] = {
				current = f[1] == "*",
				name = esc(f[2]),
				hash = f[4] ~= "" and f[4] or f[3],
				date = f[5],
				subject = esc(f[6]),
			}
		end
	end

	return {
		name = name,
		slug = slug,
		path = path,
		ref = ref,
		description = esc(description),
		commits = commits,
		files = files,
		refs = refs,
		readme = readme,
		license = license,
	}
end

local function split_lines(s, n)
	local pos = 0
	for _ = 1, n do
		pos = s:find("\n", pos + 1, true)
		if not pos then
			return s, ""
		end
	end
	return s:sub(1, pos), s:sub(pos + 1)
end

function M.show(repo, commit)
	local out = run(repo.path, "show -m --first-parent --stat=100 --patch --format= " .. commit.hash)
	local pos = out:find("\ndiff --git", 1, true)
	local stat, patch
	if pos then
		stat, patch = out:sub(1, pos - 1), out:sub(pos + 1)
	else
		stat, patch = out, ""
	end

	if #patch > PATCH_LIMIT then
		patch = patch:sub(1, PATCH_LIMIT) .. "\n... diff truncated"
	end

	local shown = {}
	for key, value in pairs(commit) do
		shown[key] = value
	end
	shown.stat = esc(trim(stat))
	shown.patch = color(esc(patch))
	shown.patch_head, shown.patch_rest = split_lines(shown.patch, 20)

	return shown
end

function M.export(repo, dir)
	os.execute("mkdir -p " .. sh(dir) .. " && git -C " .. sh(repo.path) .. " archive " .. repo.ref
		.. " | tar -x -C " .. sh(dir))
end

return M
