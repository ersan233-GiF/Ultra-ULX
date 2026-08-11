local devCvar = GetConVar("developer")
local isDev = devCvar and devCvar:GetInt() > 0
if SERVER then
	ulx.DEV = isDev
end
if not isDev then return end
local CAT = "开发"
local L = ULib.ulx_lang
if SERVER then
	ulx.DEV = true
	local reloaded = {}
	function ulx.reloadModule( modulePath )
		local full = "ulx/modules/" .. modulePath
		reloaded[full] = (reloaded[full] or 0) + 1
		if reloaded[full] > 3 then
			ErrorNoHalt("[Dev] Recursive reload detected for " .. full .. ", skipped\n")
			return false
		end
		Msg("[Dev] Reloading: " .. full .. " (#" .. reloaded[full] .. ")\n")
		local ok, err = pcall(include, full)
		if not ok then
			ErrorNoHalt("[Dev] RELOAD FAILED: " .. full .. "\n  " .. tostring(err) .. "\n")
			return false
		end
		Msg("[Dev] OK: " .. full .. "\n")
		return true
	end
	function ulx.reloadLanguage( lang )
		lang = lang or ULib.ulx_lang.current or "zh-cn"
		Msg("[Dev] Reloading language: " .. lang .. "\n")
		ULib.ulx_lang.switch(lang)
		Msg("[Dev] Language reloaded. Keys: " .. table.Count(ULib.ulx_lang.data or {}) .. "\n")
	end
	function ulx.testCommand( ply, cmdStr, ... )
		local args = {...}
		Msg("[Dev] Testing: " .. cmdStr .. " " .. table.concat(args, " ") .. "\n")
		local cmd = ULib.cmds.translatedCmds[cmdStr]
		if not cmd then
			Msg("[Dev] Command not found: " .. cmdStr .. "\n")
			return
		end
		ULib.pcallError(cmd.fn, ply, unpack(args))
	end
end
if CLIENT then
	function ulx.quickRefresh()
		if xgui and xgui.processModules then
			xgui.processModules()
			chat.AddText(Color(100,255,100), "[Dev] XGUI refreshed")
		end
	end
end
if SERVER then
	concommand.Add("ulx_reload", function(ply, _, args)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		local target = args[1]
		if not target or target == "all" then
			local dirs = {"sh", "sv"}
			for _, dir in ipairs(dirs) do
				local files = file.Find("ulx/modules/" .. dir .. "/*.lua", "LUA")
				table.sort(files)
				for _, f in ipairs(files) do
					ulx.reloadModule(dir .. "/" .. f)
				end
			end
			Msg("[Dev] All modules reloaded.\n")
		else
			ulx.reloadModule(target)
		end
		ulx.reloadLanguage()
	end)
	concommand.Add("ulx_lang_reload", function(ply, _, args)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		ulx.reloadLanguage(args[1])
	end)
	concommand.Add("ulx_test", function(ply, _, args)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		if #args < 1 then
			Msg("[Dev] Usage: ulx_test <cmd> [args...]\n")
			Msg("[Dev] Example: ulx_test ulx_slap @bPlayer 20\n")
			return
		end
		local cmd = "ulx " .. args[1]
		local cmdArgs = {}
		for i=2, #args do table.insert(cmdArgs, args[i]) end
		local tester = ply
		if not tester:IsValid() then
			local plys = player.GetAll()
			tester = plys[1]
		end
		if not tester or not tester:IsValid() then
			Msg("[Dev] No valid player to test with.\n")
			return
		end
		ulx.testCommand(tester, cmd, unpack(cmdArgs))
	end)
	concommand.Add("ulx_diag", function(ply)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		local timerCount = 0
		for _, _ in pairs(timer.GetAll and timer.GetAll() or {}) do timerCount = timerCount + 1 end
		local entCount = 0
		for _, _ in pairs(ents.GetAll and ents.GetAll() or {}) do entCount = entCount + 1 end
		Msg("\n===== Ultra ULX Diagnostics =====\n")
		Msg("ULX: v" .. string.format("%.2f", ulx.version) .. "\n")
		Msg("ULib: " .. (ULib.pluginVersionStr and ULib.pluginVersionStr("ULib") or "?") .. "\n")
		Msg("Language: " .. (ULib.ulx_lang.current or "?") .. "\n")
		Msg("Lang keys: " .. table.Count(ULib.ulx_lang.data or {}) .. "\n")
		Msg("Dev mode: " .. tostring(ulx.DEV) .. "\n")
		Msg("Players: " .. #player.GetAll() .. "\n")
		Msg("Entities: " .. entCount .. "\n")
		Msg("Timers: " .. timerCount .. "\n")
		Msg("Uptime: " .. math.floor(CurTime()) .. "s\n")
		Msg("Modules loaded: " .. table.Count(ulx.modulePaths or {}) .. "\n")
		for _, lang in ipairs(ULib.ulx_lang.available) do
			local path = "ulx/language/" .. lang .. ".lua"
			Msg("  " .. lang .. ".lua: " .. (file.Exists(path, "LUA") and "OK" or "MISSING") .. "\n")
		end
		local errorsFile = "ultra_ulx_dev_bridge/errors/errors.jsonl"
		if file.Exists(errorsFile, "DATA") then
			local content = file.Read(errorsFile, "DATA") or ""
			local n = 0
			for _ in content:gmatch("\n") do n = n + 1 end
			Msg("Collected errors: " .. n .. " (Dev Tools bridge)\n")
		end
		Msg("==================================\n")
	end)
	concommand.Add("ulx_errors", function(ply, _, args)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		local limit = tonumber(args and args[1]) or 20
		limit = math.Clamp(limit, 1, 200)
		local errorsFile = "ultra_ulx_dev_bridge/errors/errors.jsonl"
		if not file.Exists(errorsFile, "DATA") then
			Msg("[Dev] 无错误记录 (Dev Tools 桥未启用或从未捕获错误). 启用: ultra_devui_enabled 1\n")
			return
		end
		local content = file.Read(errorsFile, "DATA") or ""
		local recs = {}
		for line in content:gmatch("[^\n]+") do
			local ok, rec = pcall(util.JSONToTable, line)
			if ok and rec then table.insert(recs, rec) end
		end
		local start = math.max(1, #recs - limit + 1)
		Msg("\n===== 最近 " .. (#recs - start + 1) .. " 条错误 (共 " .. #recs .. ") =====\n")
		for i = start, #recs do
			local r = recs[i]
			Msg(string.format("[%s] %s: %s\n",
				os.date("%H:%M:%S", r.time or 0),
				r.realm or "?",
				(r.msg or "?"):sub(1, 120)))
			if r.source then Msg("   at " .. r.source .. "\n") end
		end
		Msg("==================================\n")
	end)
end