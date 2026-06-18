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

-- 道具注册表系统 (shared)
include("ulx/items/init.lua")
for _, f in ipairs( ulx.ITEM_FILES ) do
	include( "ulx/items/" .. f )
end

-- 硬编码模块清单，避免 file.Find 跨 addon 加载原版英文模块
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

-- ===== 客户端版本自动同步：静默删除旧版，自动重连从服务端下载 =====
local versionSynced = false
net.Receive("ulx_version_check", function()
	if versionSynced then return end
	local serverVer = net.ReadString()
	local clientVer = (ulx and ulx.VERSION) or "0"
	if serverVer == clientVer then versionSynced = true; return end

	versionSynced = true
	Msg("[ULX] " .. clientVer .. " -> " .. serverVer .. "\n")

	-- 递归删除本地 Lua 文件
	local addonBase = "addons/Ultra ULX"
	local function deleteLua(dir)
		local items = file.Find(addonBase .. "/" .. dir .. "/*", "MOD") or {}
		for _, name in ipairs(items) do
			local full = dir .. "/" .. name
			if name:find("%.lua$") then
				pcall(function() file.Delete(addonBase .. "/" .. full) end)
			else
				deleteLua(full)
			end
		end
	end
	pcall(deleteLua, "lua")

	-- 清除客户端缓存
	pcall(function()
		local c = "cache/lua"
		if file.IsDir(c, "MOD") then
			for _, f in ipairs(file.Find(c .. "/*", "MOD") or {}) do
				pcall(function() file.Delete(c .. "/" .. f) end)
			end
		end
	end)

	-- 自动重连，服务端下发最新文件（全程加载界面，无提示）
	timer.Simple(0.1, function() RunConsoleCommand("retry") end)
end)


-- ============================================
-- Ultra ULX - 旧数据导入客户端通知
-- 接收服务端的导入提示，自动弹框
-- ============================================
net.Receive("UltraULX_PromptImport", function()
    -- 延迟一小段时间确保 XGUI 已初始化
    timer.Simple(1, function()
        if not xgui then return end

        -- 创建弹窗
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 250)
        frame:Center()
        frame:SetTitle("Ultra ULX - 数据导入")
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:SetDeleteOnClose(true)

        local label = vgui.Create("DLabel", frame)
        label:SetPos(20, 40)
        label:SetSize(360, 80)
        label:SetText("检测到原版 ULX 的配置文件。\n是否要导入到 Ultra ULX？\n\n导入后原文件保留，随时可回滚。")
        label:SetFont("DermaDefaultBold")

        local importBtn = vgui.Create("DButton", frame)
        importBtn:SetPos(50, 140)
        importBtn:SetSize(140, 30)
        importBtn:SetText("打开导入面板")
        importBtn.DoClick = function()
            frame:Close()
            -- 打开 XGUI 并切换到设置 -> 数据导入
            if xgui and xgui.showSettings then
                xgui.showSettings("数据导入")
            end
        end

        local skipBtn = vgui.Create("DButton", frame)
        skipBtn:SetPos(210, 140)
        skipBtn:SetSize(140, 30)
        skipBtn:SetText("跳过")
        skipBtn.DoClick = function()
            frame:Close()
            RunConsoleCommand("_xgui_skipImport")
        end

        -- 关闭按钮也有跳过效果
        frame.btnClose.DoClick = function()
            frame:Close()
            RunConsoleCommand("_xgui_skipImport")
        end
    end)
end)
