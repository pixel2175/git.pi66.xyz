local fs = {}
local path = {}

function path.join(...)
	local parts = { ... }
	local result = ""

	for _, part in ipairs(parts) do
		if part ~= "" then
			if result == "" then
				result = part
			else
				result = result:gsub("/+$", "") .. "/" .. part:gsub("^/+", "")
			end
		end
	end

	return result
end

function path.normalize(p)
	local absolute = p:sub(1, 1) == "/"
	local parts = {}

	for part in p:gmatch("[^/]+") do
		if part == ".." then
			if #parts > 0 and parts[#parts] ~= ".." then
				table.remove(parts)
			elseif not absolute then
				table.insert(parts, part)
			end
		elseif part ~= "." then
			table.insert(parts, part)
		end
	end

	local result = table.concat(parts, "/")

	if absolute then
		result = "/" .. result
	end

	if result == "" then
		return absolute and "/" or "."
	end

	return result
end

function path.dirname(p)
	p = p:gsub("/+$", "")

	local dir = p:match("^(.*)/[^/]+$")

	if not dir or dir == "" then
		return "."
	end

	return dir
end

function path.basename(p)
	p = p:gsub("/+$", "")
	return p:match("([^/]+)$") or p
end

function path.extname(p)
	local name = path.basename(p)
	local ext = name:match("(%.[^%.]+)$")

	return ext or ""
end

function path.stem(p)
	local name = path.basename(p)
	return name:gsub("%.[^%.]+$", "")
end

function path.is_absolute(p)
	return p:sub(1, 1) == "/"
end

function path.relative(from, to)
	from = path.normalize(from)
	to = path.normalize(to)

	local a = {}
	local b = {}

	for part in from:gmatch("[^/]+") do
		table.insert(a, part)
	end

	for part in to:gmatch("[^/]+") do
		table.insert(b, part)
	end

	local common = 0

	while common < #a and common < #b and a[common + 1] == b[common + 1] do
		common = common + 1
	end

	local result = {}

	for i = common + 1, #a do
		table.insert(result, "..")
	end

	for i = common + 1, #b do
		table.insert(result, b[i])
	end

	return table.concat(result, "/")
end

fs.path = path

function fs.exists(p)
	local file = io.open(p, "r")

	if file then
		file:close()
		return true
	end

	local command = string.format(
		'test -e %q',
		p
	)

	return os.execute(command) == true or os.execute(command) == 0
end

function fs.isfile(p)
	local command = string.format(
		'test -f %q',
		p
	)

	return os.execute(command) == true or os.execute(command) == 0
end

function fs.isdir(p)
	local command = string.format(
		'test -d %q',
		p
	)

	return os.execute(command) == true or os.execute(command) == 0
end

function fs.islink(p)
	local command = string.format(
		'test -L %q',
		p
	)

	return os.execute(command) == true or os.execute(command) == 0
end

function fs.listdir(dir)
	local pipe = io.popen("ls -1A " .. dir, "r")
	local entries = {}

	for entry in pipe:lines() do
		table.insert(entries, entry)
	end

	pipe:close()

	return entries
end

function fs.mkdir(p)
	local command = string.format("mkdir %q", p)
	return os.execute(command) == true or os.execute(command) == 0
end

function fs.mkdirp(p)
	local command = string.format("mkdir -p %q", p)
	return os.execute(command) == true or os.execute(command) == 0
end

function fs.rmdir(p)
	local command = string.format("rmdir %q", p)
	return os.execute(command) == true or os.execute(command) == 0
end

function fs.remove(p)
	local command = string.format("rm -f %q", p)
	return os.execute(command) == true or os.execute(command) == 0
end

function fs.remove_all(p)
	local command = string.format("rm -rf %q", p)
	return os.execute(command) == true or os.execute(command) == 0
end

function fs.read(p)
	local file, err = io.open(p, "r")

	if not file then
		return nil, err
	end

	local data = file:read("*a")
	file:close()

	return data
end

function fs.write(p, data)
	local file, err = io.open(p, "w")

	if not file then
		return nil, err
	end

	file:write(data)
	file:close()

	return true
end

function fs.append(p, data)
	local file, err = io.open(p, "a")

	if not file then
		return nil, err
	end

	file:write(data)
	file:close()

	return true
end

function fs.copy(src, dst)
	local data, err = fs.read(src)

	if not data then
		return nil, err
	end

	return fs.write(dst, data)
end

function fs.move(src, dst)
	local command = string.format(
		"mv %q %q",
		src,
		dst
	)

	return os.execute(command) == true or os.execute(command) == 0
end

function fs.rename(src, dst)
	return fs.move(src, dst)
end

function fs.cwd()
	local pipe = io.popen("pwd", "r")

	if not pipe then
		return nil
	end

	local cwd = pipe:read("*l")
	pipe:close()

	return cwd
end

function fs.chdir(dir)
	local command = string.format("cd %q", dir)
	return os.execute(command) == true or os.execute(command) == 0
end


function fs.walk(dir, callback)
	local entries, err = fs.listdir_full(dir)

	if not entries then
		return nil, err
	end

	for _, entry in ipairs(entries) do
		callback(entry)

		if fs.isdir(entry) then
			local ok, walk_err = fs.walk(entry, callback)

			if not ok and walk_err then
				return nil, walk_err
			end
		end
	end

	return true
end

return fs
