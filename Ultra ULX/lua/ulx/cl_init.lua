if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true
Msg("[ULX] " .. (ULib.ulx_lang and ULib.ulx_lang.T("init_cl_loading") or "客户端模块加载中...") .. " (" .. os.date("%H:%M:%S") .. ")\n")
include("ulx/shared/defines.lua")
include("ulx/shared/misc.lua")
include("ulx/shared/util.lua")
include("ulx/shared/hook.lua")
include("ulx/shared/tables.lua")
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
include("ulx/client/ulx_cl_lib.lua")
include("ulx/shared/ulx_base.lua")
include("ulx/items/init.lua")
for _, f in ipairs( ulx.ITEM_FILES ) do
	include( "ulx/items/" .. f )
end
local function safeInclude(dir, file)
	local ok, err = pcall(include, "ulx/modules/" .. dir .. "/" .. file)
	if not ok then ErrorNoHalt("[ULX] Client module load failed: " .. file .. " - " .. tostring(err) .. "\n") end
end
local disabledModules = {
	["sh/bhop.lua"] = true,
}
local function moduleEnabled( dir, file )
	return not disabledModules[ dir .. "/" .. file ]
end
local cl_modules = file.Find("ulx/modules/cl/*.lua", "LUA")
local sh_modules = file.Find("ulx/modules/sh/*.lua", "LUA")
for _, f in ipairs(cl_modules) do if moduleEnabled("cl", f) then safeInclude("cl", f) end end
for _, f in ipairs(sh_modules) do if moduleEnabled("sh", f) then safeInclude("sh", f) end end
local needs_auth = {}
hook.Add("OnEntityCreated", "ULibPlayerAuthCheck", function(ent)
	if not ent:IsPlayer() then return end
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		local uid = ent:UserID()
		if needs_auth[uid] then
			hook.Call(ULib.HOOK_UCLAUTH, _, ent)
			needs_auth[uid] = nil
		end
	end)
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