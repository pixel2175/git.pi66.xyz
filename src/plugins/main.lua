package.path = "src/plugins/?.lua;" .. package.path

require("watch")
require("hooks")

merodi.enable.GFM()
merodi.enable.HTMLAttr()

local action = merodi.action()

if action == "build" or action == "watch" then
	require("builder").all()
end
