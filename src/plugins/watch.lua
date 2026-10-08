merodi.watch.add("src/static")
merodi.watch.add("md")
merodi.watch.add("src/templates")

merodi.hook("on_start_watching", function()
	merodi.log.info("Start watching")
end)

merodi.hook("on_file_changed", function(mode, filepath)
	if mode == "WRITE" then
		merodi.log.info("FILEPATH: " .. filepath)
		os.execute("pkill -f '^merodi build$'")
		os.execute("merodi build")
	end
end)
