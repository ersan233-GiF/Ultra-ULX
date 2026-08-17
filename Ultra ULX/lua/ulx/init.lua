if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true
if not ULib.consoleCommand then ULib.consoleCommand = game.ConsoleCommand end
file.CreateDir("ulib")
file.CreateDir("ultra_ulx")
include("ulx/shared/ulx4_ext.lua")
include("ulx/shared/defines.lua")
Msg("// ======================================== //\n// Ultra ULX v" .. ulx.VERSION .. " 启动中... (基于 ULX v" .. (ulx.BASE_ULX or "3.81") .. " + ULib v" .. string.format("%.2f", ULib.VERSION) .. ") (" .. os.date("%H:%M:%S") .. ") //\n// ======================================== //\n")
if SERVER then CreateConVar("ulx_version", ulx.VERSION, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_SPONLY, FCVAR_NOTIFY}, "Ultra ULX 版本号") end
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
local disabledModules = {
}
local function moduleEnabled( dir, file )
	return not disabledModules[ dir .. "/" .. file ]
end
local sv_modules = file.Find("ulx/modules/sv/*.lua", "LUA")
local sh_modules = file.Find("ulx/modules/sh/*.lua", "LUA")
local cl_modules = file.Find("ulx/modules/cl/*.lua", "LUA")
for _, f in ipairs(sv_modules) do if moduleEnabled("sv", f) then safeInclude("sv", f) end end
for _, f in ipairs(sh_modules) do if moduleEnabled("sh", f) then safeInclude("sh", f) end end
include("ulx/server/end.lua")
Msg("// Ultra ULX v" .. ulx.VERSION .. " " .. ULib.ulx_lang.T("init_ready") .. " | ULX v" .. (ulx.BASE_ULX or "3.81") .. " | ULib v" .. string.format("%.2f", ULib.VERSION) .. " | by Team Ulysses & ersan233-GiF (" .. os.date("%H:%M:%S") .. ") //\n")
AddCSLuaFile("ulx/cl_init.lua")
local sharedClientFiles = {
	"ulx/shared/defines.lua", "ulx/shared/misc.lua", "ulx/shared/util.lua",
	"ulx/shared/hook.lua", "ulx/shared/tables.lua", "ulx/shared/player.lua",
	"ulx/shared/messages.lua", "ulx/shared/commands.lua", "ulx/shared/sh_ucl.lua",
	"ulx/shared/plugin.lua", "ulx/shared/cami_global.lua", "ulx/shared/cami_ulib.lua",
	"ulx/shared/ulx_base.lua",
}
for _, f in ipairs(sharedClientFiles) do AddCSLuaFile(f) end
local cl_client = file.Find("ulx/client/*.lua", "LUA")
for _, f in ipairs(cl_client) do AddCSLuaFile("ulx/client/" .. f) end
for _, f in ipairs(cl_modules)  do AddCSLuaFile("ulx/modules/cl/" .. f) end
for _, f in ipairs(sh_modules)  do if moduleEnabled("sh", f) then AddCSLuaFile("ulx/modules/sh/" .. f) end end
AddCSLuaFile( "ulx/items/init.lua" )
for _, f in ipairs( ulx.ITEM_FILES ) do
	AddCSLuaFile( "ulx/items/" .. f )
end
if SERVER then
    ULib.ulx_lang.switch( "zh-cn" )
end