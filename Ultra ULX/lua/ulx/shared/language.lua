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
function L.T( key, ... )
	if key == nil then return "" end
	local str = L.data[key] or key
	if ... then
		local ok, result = pcall( string.format, str, ... )
		if ok then str = result end
	end
	return str
end
function L.load( lang )
	if not L.names[lang] then
		ErrorNoHalt("[ULX] Attempted to load unknown language: " .. tostring(lang) .. "\n")
		return
	end
	local newData = {}
	local oldData = L.data
	L.data = newData
	if SERVER then
		local ok, err = pcall( include, "ulx/language/" .. lang .. ".lua" )
		if not ok then
			L.data = oldData
			ErrorNoHalt("[ULX] Failed to load language file '" .. lang .. "': " .. tostring(err) .. "\n")
			return
		end
	else
		local ok, err = pcall( include, "ulx/language/" .. lang .. ".lua" )
		if not ok then
			L.data = oldData
			ErrorNoHalt("[ULX] Failed to load language file '" .. lang .. "': " .. tostring(err) .. "\n")
			return
		end
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
			xgui.saveClientSettings()
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
end
if CLIENT then
	L.loadCachedLang()
	concommand.Add( "ulx_lang", function( _, _, args )
		local lang = args[1]
		if lang and L.names[lang] then
			L.switch( lang )
			L.saveClientLang( lang )
		end
	end )
end
