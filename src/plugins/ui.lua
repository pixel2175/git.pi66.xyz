local helper = require("helpers")

local M = {}

function M.info(msg)
	merodi.log.info("Git: " .. msg)
end

function M.status(msg)
	io.write("\27[1A\27[2K\r")
	merodi.log.info("Git: " .. msg .. "\r")
end

function M.progress(i, total, label)
	io.write("[" .. i .. "/" .. total .. "]- " .. helper.gray(label) .. "\r")
end

M.cyan = helper.cyan
M.gray = helper.gray

return M
