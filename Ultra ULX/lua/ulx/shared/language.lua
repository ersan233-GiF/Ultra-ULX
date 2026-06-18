-- Ultra ULX 多语言系统
ULib.ulx_lang = ULib.ulx_lang or {}
local L = ULib.ulx_lang

L.available = { "zh-cn", "en", "ru", "lzh" }
L.names = {
	["zh-cn"] = "简体中文",
	["en"]    = "English",
	["lzh"]   = "文言文",
	["ru"]    = "Русский",
}
L.data = L.data or {}  -- 当前语言数据表

-- 默认语言
L.current = L.current or "zh-cn"

-- 获取翻译
function L.T( key, ... )
	local str = L.data[key] or key
	if ... then str = string.format( str, ... ) end
	return str
end

-- 加载语言文件到数据表
function L.load( lang )
	L.data = {}
	if SERVER then
		-- 服务端也加载，用于 fancyLog
		pcall( include, "ulx/language/" .. lang .. ".lua" )
	else
		include( "ulx/language/" .. lang .. ".lua" )
	end
	L.current = lang
end

-- 切换语言
function L.switch( lang )
	local prev = L.current
	L.load( lang )
	if prev ~= lang then
		hook.Call( "ULXLanguageChanged", nil, lang )
	end
end

-- 客户端缓存
if CLIENT then
	-- 保存语言设置（双写保障：独立文件 + XGUI设置）
	function L.saveClientLang( lang )
		-- 直接写入 data/ultra_ulx/language.txt（绕过 ULib 文件函数，更可靠）
		file.CreateDir( "ultra_ulx" )
		file.Write( "ultra_ulx/language.txt", lang )
		-- 同时保存到 XGUI 设置中作为备份
		if xgui and xgui.settings then
			xgui.settings.language = lang
			xgui.saveClientSettings()
		end
	end

	-- 加载缓存
	function L.loadCachedLang()
		-- 优先从独立文件读取
		if file.Exists( "ultra_ulx/language.txt", "DATA" ) then
			local lang = file.Read( "ultra_ulx/language.txt", "DATA" ):Trim()
			if L.names[lang] then
				L.switch( lang )
				return
			end
		end
		-- 回退：从 XGUI 设置读取（可能尚未加载，安全忽略）
		if xgui and xgui.settings and xgui.settings.language then
			local lang = xgui.settings.language
			if L.names[lang] then
				L.switch( lang )
				return
			end
		end
		-- 默认简体中文
		L.switch( "zh-cn" )
	end
end

-- 初始化(客户端)
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
