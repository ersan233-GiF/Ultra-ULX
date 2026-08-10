if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true
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
include("ulx/shared/ulx_defines.lua")
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
local cl_modules = { "motdmenu.lua", "uteam.lua", "xgui_client.lua", "xgui_helpers.lua", "xlib.lua" }
local sh_modules = {
	"chat.lua", "community.lua", "extras.lua", "fun.lua", "menus.lua",
	"rcon.lua", "teleport.lua", "user.lua", "userhelp.lua", "util.lua", "vote.lua",
	"bhop.lua", "crouchjump.lua", "coord.lua"
}
for _, f in ipairs(cl_modules) do safeInclude("cl", f) end
for _, f in ipairs(sh_modules) do safeInclude("sh", f) end
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
local syncState = { done = false, retryScheduled = false }
net.Receive("ulx_file_sync_manifest", function()
	if syncState.done then return end
	if syncState.retryScheduled then return end
	local serverVer = net.ReadString()
	local fileCount = net.ReadUInt(16)
	local deleteList = {}
	local addonBase = "addons/Ultra ULX"
	for _ = 1, fileCount do
		local relPath = net.ReadString()
		local serverCRC = net.ReadString()
		local localContent = file.Read(relPath, "GAME") or ""
		local localCRC = localContent ~= "" and util.CRC(localContent) or ""
		if localCRC ~= serverCRC then
			deleteList[#deleteList + 1] = relPath
		end
	end
	if #deleteList == 0 then
		syncState.done = true
		Msg("[ULX] 所有核心文件哈希一致，无需同步\n")
		return
	end
	local deletedCount = 0
	for _, relPath in ipairs(deleteList) do
		local fullPath = addonBase .. "/" .. relPath
		pcall(function()
			if file.Exists(fullPath, "MOD") then
				file.Delete(fullPath)
				deletedCount = deletedCount + 1
			end
		end)
	end
	pcall(function()
		local cacheDir = "cache/lua"
		if file.IsDir(cacheDir, "MOD") then
			for _, f in ipairs(file.Find(cacheDir .. "/*", "MOD") or {}) do
				for _, relPath in ipairs(deleteList) do
					local cacheKey = relPath:gsub("/", "_"):gsub("%.lua$", "")
					if f:find(cacheKey) then
						file.Delete(cacheDir .. "/" .. f)
						break
					end
				end
			end
		end
	end)
	syncState.retryScheduled = true
	Msg("[ULX] 删除了 " .. deletedCount .. " 个旧文件，重连下载新版本…\n")
	timer.Simple(0.1, function() RunConsoleCommand("retry") end)
end)
local versionSynced = false
net.Receive("ulx_version_check", function()
	if versionSynced then return end
	versionSynced = true
	local serverVer = net.ReadString()
	local clientVer = (ulx and ulx.VERSION) or "0"
	if serverVer == clientVer then
		Msg("[ULX] 版本一致 (" .. clientVer .. ")，无需同步\n")
		return
	end
	Msg("[ULX] 版本差异: 本地 " .. clientVer .. " / 服务端 " .. serverVer .. "，请求文件清单…\n")
	net.Start("ulx_file_sync_manifest")
	net.SendToServer()
end)