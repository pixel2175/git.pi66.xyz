merodi.hook("build_repo", function(repo_name)
	merodi.log.info("Building: " .. repo_name)
	require("builder").one(repo_name)
end)
