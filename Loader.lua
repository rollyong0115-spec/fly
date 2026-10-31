-- Simple Loader

local scripts = {
	GodFly = "https://raw.githubusercontent.com/rollyong0115-spec/fly/main/GodFly.lua",
}

local function loadScript(name)
	local url = scripts[name]
	if not url then
		warn("[Loader] Script not found:", name)
		return
	end

	local success, result = pcall(function()
		return game:HttpGet(url)
	end)

	if success and result then
		local ok, err = pcall(loadstring(result))
		if not ok then
			warn("[Loader] Failed to run", name, "→", err)
		else
			print("[Loader] Loaded:", name)
		end
	else
		warn("[Loader] Failed to download", name)
	end
end

-- Load GodFly
loadScript("GodFly")
