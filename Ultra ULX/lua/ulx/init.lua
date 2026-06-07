-- Ultra ULX - Server initialization
-- 如果 Ultra ULX 已加载则跳过；但不阻止原版 ULib 单独存在的场景
if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true

if not ULib.consoleCommand then ULib.consoleCommand = game.ConsoleCommand end

file.CreateDir("ulib")
file.CreateDir("ulx")

Msg("// Ultra ULX v" .. (ulx.version or "3.81") .. " Loading... //\n")

-- ULib shared library (load-order dependent)
include("ulx/shared/defines.lua")
include("ulx/shared/misc.lua")
include("ulx/shared/util.lua")
include("ulx/shared/hook.lua")
include("ulx/shared/tables.lua")
include("ulx/shared/player.lua")

-- ULib server library
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

-- Language system
include("ulx/shared/language.lua")
AddCSLuaFile("ulx/shared/language.lua")
for _, lang in ipairs(ULib.ulx_lang.available) do
	AddCSLuaFile("ulx/language/" .. lang .. ".lua")
end

-- ULX core
include("ulx/server/data.lua")
include("ulx/shared/ulx_defines.lua")
include("ulx/server/ulx_lib.lua")
include("ulx/server/ulx_command.lua")
include("ulx/shared/ulx_base.lua")
include("ulx/server/log.lua")

-- ULX modules — 硬编码清单，避免 file.Find 跨 addon 加载原版英文模块
local function safeInclude(dir, file)
	local ok, err = pcall(include, "ulx/modules/" .. dir .. "/" .. file)
	if not ok then ErrorNoHalt("[ULX] Module load failed: " .. file .. " - " .. tostring(err) .. "\n") end
end

local sv_modules = { "slots.lua", "uteam.lua", "votemap.lua", "xgui_server.lua" }
local sh_modules = {
	"chat.lua", "community.lua", "extras.lua", "fun.lua", "menus.lua",
	"rcon.lua", "teleport.lua", "user.lua", "userhelp.lua", "util.lua", "vote.lua"
}
for _, f in ipairs(sv_modules) do safeInclude("sv", f) end
for _, f in ipairs(sh_modules) do safeInclude("sh", f) end

-- Config loading engine
include("ulx/server/end.lua")

Msg("// Ultra ULX Loaded! //\n")

-- Send client files
AddCSLuaFile("ulx/cl_init.lua")
AddCSLuaFile("autorun/ulx_merged_init.lua")

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
