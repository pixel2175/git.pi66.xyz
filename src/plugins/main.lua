package.path = "src/plugins/?.lua;" .. package.path

require("watch")
require("hooks")

merodi.enable.GFM()
merodi.enable.HeaderAttr()
merodi.enable.BlockAttr()
merodi.enable.InlineAttr()

local action = merodi.action()

if action == "build" or action == "watch" then
	require("builder").all()
end
