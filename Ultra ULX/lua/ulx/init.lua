if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true
if not ULib.consoleCommand then ULib.consoleCommand = game.ConsoleCommand end
file.CreateDir("ulib")
file.CreateDir("ultra_ulx")
Msg("// Ultra ULX " .. (ulx.VERSION_STR or "v2.69.1") .. " Loading... //\n")
include("ulx/shared/ulx4_ext.lua")
include("ulx/shared/defines.lua")
include("ulx/shared/misc.lua")
include("ulx/shared/util.lua")
include("ulx/shared/hook.lua")
include("ulx/shared/tables.lua")
include("ulx/shared/player.lua")
include("ulx/server/player.lua")
include("ulx/server/bans.lua")
include("ulx/shared/messages.lua")
include("ulx/shared/commands.lua")
include("ulx/server/concommand.lua")
include("ulx/server/srv_util.lua")
include("ulx/shared/sh_ucl.lua")
include("ulx/server/ucl.lua")
include("ulx/server/phys.lua")
include("ulx/server/player_ext.lua")
include("ulx/server/entity_ext.lua")
include("ulx/shared/plugin.lua")
include("ulx/shared/cami_global.lua")
include("ulx/shared/cami_ulib.lua")
include("ulx/shared/language.lua")
AddCSLuaFile("ulx/shared/language.lua")
for _, lang in ipairs(ULib.ulx_lang.available) do
	AddCSLuaFile("ulx/language/" .. lang .. ".lua")
end
ULib.ulx_lang.switch( "zh-cn" )
include("ulx/server/data.lua")
include("ulx/shared/ulx_defines.lua")
include("ulx/server/ulx_lib.lua")
include("ulx/server/ulx_command.lua")
include("ulx/shared/ulx_base.lua")
include("ulx/server/log.lua")
include("ulx/items/init.lua")
for _, f in ipairs( ulx.ITEM_FILES ) do
	include( "ulx/items/" .. f )
end
local function safeInclude(dir, file)
	local ok, err = pcall(include, "ulx/modules/" .. dir .. "/" .. file)
	if not ok then ErrorNoHalt("[ULX] Module load failed: " .. file .. " - " .. tostring(err) .. "\n") end
end
local sv_modules = { "slots.lua", "uteam.lua", "votemap.lua", "xgui_server.lua" }
local sh_modules = {
	"chat.lua", "community.lua", "extras.lua", "fun.lua", "menus.lua",
	"rcon.lua", "teleport.lua", "user.lua", "userhelp.lua", "util.lua", "vote.lua",
	"bhop.lua", "crouchjump.lua", "coord.lua"
}
for _, f in ipairs(sv_modules) do safeInclude("sv", f) end
for _, f in ipairs(sh_modules) do safeInclude("sh", f) end
include("ulx/server/end.lua")
Msg("// Ultra ULX " .. (ulx.VERSION_STR or "v2.69.1") .. " Loaded! //\n")
AddCSLuaFile("ulx/cl_init.lua")
local sharedClientFiles = {
	"ulx/shared/defines.lua", "ulx/shared/misc.lua", "ulx/shared/util.lua",
	"ulx/shared/hook.lua", "ulx/shared/tables.lua", "ulx/shared/player.lua",
	"ulx/shared/messages.lua", "ulx/shared/commands.lua", "ulx/shared/sh_ucl.lua",
	"ulx/shared/plugin.lua", "ulx/shared/cami_global.lua", "ulx/shared/cami_ulib.lua",
	"ulx/shared/ulx_defines.lua", "ulx/shared/ulx_base.lua",
}
for _, f in ipairs(sharedClientFiles) do AddCSLuaFile(f) end
local cl_client = { "cl_commands.lua", "cl_util.lua", "draw.lua", "ulx_cl_lib.lua" }
local cl_modules = { "motdmenu.lua", "uteam.lua", "xgui_client.lua", "xgui_helpers.lua", "xlib.lua" }
for _, f in ipairs(cl_client)   do AddCSLuaFile("ulx/client/" .. f) end
for _, f in ipairs(cl_modules)  do AddCSLuaFile("ulx/modules/cl/" .. f) end
for _, f in ipairs(sh_modules)  do AddCSLuaFile("ulx/modules/sh/" .. f) end
AddCSLuaFile( "ulx/items/init.lua" )
for _, f in ipairs( ulx.ITEM_FILES ) do
	AddCSLuaFile( "ulx/items/" .. f )
end
if SERVER then
    ulx.convar( "language", "zh-cn", " - Server output language (zh-cn/en/ru/lzh)", ULib.ACCESS_ADMIN )
    local lang = GetConVarString( "ulx_language" )
    if lang and ULib.ulx_lang.names[lang] then
        ULib.ulx_lang.switch( lang )
    else
        ULib.ulx_lang.switch( "zh-cn" )
    end
    hook.Add( "ULibReplicatedCvarChanged", "UltraULX_Language", function( sv_cvar, cl_cvar, ply, old_val, new_val )
        if cl_cvar ~= "ulx_language" then return end
        if not IsValid( ply ) or not ply:IsSuperAdmin() then return end
        if new_val and ULib.ulx_lang.names[new_val] then
            ULib.ulx_lang.switch( new_val )
            ULib.tsayColor( ply, true, ULib.COLOR_ACCENT, "[Ultra ULX] 服务器语言已切换为: " .. new_val )
        end
    end )
end
local UltraULX_ReloadModules
if SERVER then
    UltraULX_ReloadModules = function()
        UltraULX_SilentReRegister = true
        local cmd_modules = {
            "modules/sh/admin_ext.lua",
            "modules/sh/community.lua",
            "modules/sh/bhop.lua",
            "modules/sh/chat.lua",
            "modules/sh/extras.lua",
            "modules/sh/fun.lua",
            "modules/sh/menus.lua",
            "modules/sh/rcon.lua",
            "modules/sh/teleport.lua",
            "modules/sh/user.lua",
            "modules/sh/userhelp.lua",
            "modules/sh/util.lua",
            "modules/sh/vote.lua", "modules/sh/coord.lua",
            "modules/sv/slots.lua",
            "modules/sv/uteam.lua",
            "modules/sv/votemap.lua",
        }
        for _, mod in ipairs(cmd_modules) do
            include("ulx/" .. mod)
        end
        local xgui_server = { "sv_bans.lua", "sv_groups.lua", "sv_items.lua", "sv_maps.lua", "sv_sandbox.lua", "sv_settings.lua" }
        for _, file in ipairs(xgui_server) do
            include("ulx/xgui/server/" .. file)
        end
        AddCSLuaFile("ulx/modules/cl/xgui_client.lua")
        AddCSLuaFile("ulx/modules/cl/xgui_helpers.lua")
        AddCSLuaFile("ulx/modules/cl/xlib.lua")
        AddCSLuaFile("ulx/modules/cl/motdmenu.lua")
        AddCSLuaFile("ulx/modules/cl/uteam.lua")
        UltraULX_SilentReRegister = nil
        MsgC(ULib.COLOR_ACCENT, "[Ultra ULX] 命令重注册完成，已覆盖原版 ULX\n")
    end
    hook.Add("InitPostEntity", "UltraULX_Finalize", function()
        timer.Simple(0.1, function()
            UltraULX_ReloadModules()
        end)
    end)
end
local function rebuildSyncCache()
	if not ulx.SYNC_FILES then return end
	for _, relPath in ipairs(ulx.SYNC_FILES) do
		local content = file.Read(relPath, "GAME") or ""
		local crc = content ~= "" and util.CRC(content) or ""
		ulx._sync_cache[relPath] = crc
	end
	ulx._sync_ready = true
end
hook.Add("InitPostEntity", "ULX_BuildSyncCache", function()
	rebuildSyncCache()
	Msg("[ULX] 文件同步清单已生成 (" .. #(ulx.SYNC_FILES or {}) .. " 个核心文件)\n")
end)
net.Receive("ulx_file_sync_manifest", function(len, ply)
	if not IsValid(ply) then return end
	if not ulx._sync_ready then rebuildSyncCache() end
	local count = #(ulx.SYNC_FILES or {})
	net.Start("ulx_file_sync_manifest")
	net.WriteString(ulx.VERSION)
	net.WriteUInt(count, 16)
	for _, relPath in ipairs(ulx.SYNC_FILES) do
		net.WriteString(relPath)
		net.WriteString(ulx._sync_cache[relPath] or "")
	end
	net.Send(ply)
end)