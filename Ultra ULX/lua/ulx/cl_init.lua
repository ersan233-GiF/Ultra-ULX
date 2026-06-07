-- Ultra ULX - Client initialization
-- 如果 Ultra ULX 已加载则跳过
if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true

-- ULib shared library
include("ulx/shared/defines.lua")
include("ulx/shared/misc.lua")
include("ulx/shared/util.lua")
include("ulx/shared/hook.lua")
include("ulx/shared/tables.lua")
include("ulx/client/cl_commands.lua")
include("ulx/shared/messages.lua")
include("ulx/shared/player.lua")
include("ulx/client/cl_util.lua")
include("ulx/client/draw.lua")
include("ulx/shared/commands.lua")
include("ulx/shared/sh_ucl.lua")
include("ulx/shared/plugin.lua")
include("ulx/shared/cami_global.lua")
include("ulx/shared/cami_ulib.lua")
include("ulx/shared/language.lua")

-- ULX core
include("ulx/shared/ulx_defines.lua")
include("ulx/client/ulx_cl_lib.lua")
include("ulx/shared/ulx_base.lua")

-- 硬编码模块清单，避免 file.Find 跨 addon 加载原版英文模块
local function safeInclude(dir, file)
	local ok, err = pcall(include, "ulx/modules/" .. dir .. "/" .. file)
	if not ok then ErrorNoHalt("[ULX] Client module load failed: " .. file .. " - " .. tostring(err) .. "\n") end
end
local cl_modules = { "motdmenu.lua", "uteam.lua", "xgui_client.lua", "xgui_helpers.lua", "xlib.lua" }
local sh_modules = {
	"chat.lua", "community.lua", "extras.lua", "fun.lua", "menus.lua",
	"rcon.lua", "teleport.lua", "user.lua", "userhelp.lua", "util.lua", "vote.lua"
}
for _, f in ipairs(cl_modules) do safeInclude("cl", f) end
for _, f in ipairs(sh_modules) do safeInclude("sh", f) end

-- Player auth system
local needs_auth = {}
hook.Add("OnEntityCreated", "ULibPlayerAuthCheck", function(ent)
	if ent:IsPlayer() and needs_auth[ent:UserID()] then
		hook.Call(ULib.HOOK_UCLAUTH, _, ent)
		needs_auth[ent:UserID()] = nil
	end
end, HOOK_MONITOR_HIGH)

hook.Add("InitPostEntity", "ULibLocalPlayerReady", function()
	if LocalPlayer():IsValid() then
		hook.Call(ULib.HOOK_LOCALPLAYERREADY, _, LocalPlayer())
		RunConsoleCommand("ulib_cl_ready")
	end
end, HOOK_MONITOR_HIGH)

function authPlayerIfReady(ply, userid)
	if ply and ply:IsValid() then
		hook.Call(ULib.HOOK_UCLAUTH, _, ply)
	else
		needs_auth[userid] = true
	end
end
