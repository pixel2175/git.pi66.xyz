local fs = require("fs")
local config = require("config")

local M = {}

local sources = {}

local function template(name)
	if not sources[name] then
		sources[name] = fs.read(config.templates .. "/" .. name)
	end
	return sources[name]
end

function M.page(name, out)
	fs.mkdirp(fs.path.dirname(out))
	fs.write(out, merodi.compile.convert(template(name)))
end

return M
