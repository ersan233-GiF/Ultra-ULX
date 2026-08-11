ULib.ulx_lang = ULib.ulx_lang or {}
local L = ULib.ulx_lang
L.available = { "zh-cn", "en", "ru", "lzh" }
L.names = {
	["zh-cn"] = "简体中文",
	["en"]    = "English",
	["lzh"]   = "文言文",
	["ru"]    = "Русский",
}
L.data = L.data or {}
L.current = L.current or "zh-cn"
L.fallbackData = L.fallbackData or {}
L.fallbackLang = "zh-cn"
function L.T( key, ... )
	if key == nil then return "" end
	local str = L.data[key]
	if str == nil and L.fallbackData then
		str = L.fallbackData[key]
	end
	if str == nil then str = key end
	if ... then
		local lua_str = str
			:gsub( "#([%.%d]*)f", "%%%1f" )
			:gsub( "#[%.%d]*i", "%%g" )
			:gsub( "#[%.%d]*d", "%%g" )
			:gsub( "#s", "%%s" )
			:gsub( "#[%.%d]*g", "%%g" )
			:gsub( "#A", "%%s" )
			:gsub( "#T", "%%s" )
			:gsub( "#P", "%%s" )
		local n = select( "#", ... )
		local clean_args = { ... }
		for i = 1, n do
			if clean_args[i] == nil then
				clean_args[i] = ""
			end
		end
		local ok, result = pcall( string.format, lua_str, unpack( clean_args, 1, n ) )
		if ok then str = result end
	end
	return str
end
if CLIENT and L.current ~= "zh-cn" then
	L.fallbackData = L.fallbackData or {}
	local origData = L.data
	L.data = {}
	pcall(include, "ulx/language/zh-cn.lua")
	L.fallbackData = L.data
	L.data = origData
end
function L.load( lang )
	if not L.names[lang] then
		ErrorNoHalt("[ULX] Attempted to load unknown language: " .. tostring(lang) .. "\n")
		return
	end
	local newData = {}
	local oldData = L.data
	L.data = newData
	local ok, err = pcall( include, "ulx/language/" .. lang .. ".lua" )
	if not ok then
		L.data = oldData
		ErrorNoHalt("[ULX] Failed to load language file '" .. lang .. "': " .. tostring(err) .. "\n")
		return
	end
	L.current = lang
end
function L.switch( lang )
	local prev = L.current
	L.load( lang )
	if prev ~= lang then
		hook.Call( "ULXLanguageChanged", nil, lang )
	end
end
if CLIENT then
	function L.saveClientLang( lang )
		file.CreateDir( "ultra_ulx" )
		file.Write( "ultra_ulx/language.txt", lang )
		if xgui and xgui.settings then
			xgui.settings.language = lang
			if xgui.saveClientSettings then xgui.saveClientSettings() end
		end
	end
	function L.loadCachedLang()
		local loaded = false
		local ok, err = pcall( function()
			if file.Exists( "ultra_ulx/language.txt", "DATA" ) then
				local lang = file.Read( "ultra_ulx/language.txt", "DATA" ):Trim()
				if L.names[lang] then
					L.switch( lang )
					loaded = true
					return
				end
			end
			if xgui and xgui.settings and xgui.settings.language then
				local lang = xgui.settings.language
				if L.names[lang] then
					L.switch( lang )
					loaded = true
					return
				end
			end
		end )
		if not ok then
			ErrorNoHalt("[ULX] Language cache load failed: " .. tostring(err) .. "\n")
		end
		if not loaded then
			L.switch( "zh-cn" )
		end
	end
	L.loadCachedLang()
	concommand.Add( "ulx_lang", function( _, _, args )
		local lang = args[1]
		if lang and L.names[lang] then
			L.switch( lang )
			L.saveClientLang( lang )
		end
	end )
	net.Receive("ulx_localized_msg", function()
		local key = net.ReadString()
		local params = net.ReadTable() or {}
		local text = L.T(key, unpack(params))
		chat.AddText(ULib.COLOR_ACCENT, text)
	end)
end
if SERVER then
	util.AddNetworkString("ulx_localized_msg")
	concommand.Add("ulx_reload_lang", function(ply, _, args)
		if not IsValid(ply) or ply:IsSuperAdmin() then
			local lang = args[1] or L.current
			L.load(lang)
			ULib.tsayColor(ply, true, ULib.COLOR_SUCCESS, "[ULX] Language '" .. lang .. "' reloaded (" .. (L.data and table.Count(L.data) or 0) .. " keys)")
			Msg("[ULX] Language '" .. lang .. "' reloaded (" .. (L.data and table.Count(L.data) or 0) .. " keys)\n")
		end
	end)
	function L.keyedBroadcast(key, ...)
		local params = {...}
		net.Start("ulx_localized_msg")
		net.WriteString(key)
		net.WriteTable(params)
		net.Broadcast()
	end
	function L.keyedBroadcastFiltered(key, recipients, ...)
		local params = {...}
		net.Start("ulx_localized_msg")
		net.WriteString(key)
		net.WriteTable(params)
		if recipients and #recipients > 0 then
			net.Send(recipients)
		end
	end
	function L.keyedTsay(ply, key, ...)
		local params = {...}
		net.Start("ulx_localized_msg")
		net.WriteString(key)
		net.WriteTable(params)
		if IsValid(ply) then net.Send(ply) else net.Broadcast() end
	end
end