local function gray(str)
	return "\27[90m" .. str .. "\27[0m"
end

local function cyan(str)
	return "\27[36m" .. str .. "\27[0m"
end

local function print_repo(repo)
	local function dump(value, indent)
		indent = indent or 0
		local prefix = string.rep("  ", indent)

		if type(value) ~= "table" then
			print(prefix .. gray(tostring(value)))
			return
		end

		for key, val in pairs(value) do
			if type(val) == "table" then
				print(prefix .. gray(tostring(key) .. " = {"))
				dump(val, indent + 1)
				print(prefix .. gray("}"))
			else
				print(
					prefix
						.. gray(tostring(key))
						.. " = "
						.. tostring(val)
				)
			end
		end
	end

	dump(repo)
end

return {
	gray = gray,
	cyan = cyan,
	print_repo = print_repo,
}
