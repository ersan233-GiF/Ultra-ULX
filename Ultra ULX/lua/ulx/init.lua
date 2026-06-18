-- Ultra ULX - Server initialization
-- 如果 Ultra ULX 已加载则跳过；但不阻止原版 ULib 单独存在的场景
if ulx and ulx._ultra then return end
ULib = ULib or {}
ulx = ulx or {}
ulx._ultra = true

if not ULib.consoleCommand then ULib.consoleCommand = game.ConsoleCommand end

file.CreateDir("ulib")
file.CreateDir("ultra_ulx")

Msg("// Ultra ULX v" .. (ulx.VERSION or "3.81") .. " Loading... //\n")

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

-- 道具注册表系统 (shared — 在模块加载前初始化)
include("ulx/items/init.lua")
for _, f in ipairs( ulx.ITEM_FILES ) do
	include( "ulx/items/" .. f )
end

-- ULX modules — 硬编码清单，避免 file.Find 跨 addon 加载原版英文模块
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

-- Config loading engine
include("ulx/server/end.lua")

Msg("// Ultra ULX Loaded! //\n")

-- Send client files
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

-- 道具注册表 (client)
AddCSLuaFile( "ulx/items/init.lua" )
for _, f in ipairs( ulx.ITEM_FILES ) do
	AddCSLuaFile( "ulx/items/" .. f )
end

-- 数据导入面板 (client-side via AddCSLuaFile)
AddCSLuaFile( "ulx/xgui/server/sv_import.lua" )

-- ============================================
-- 服务器语言 ConVar
-- 在 XGUI 设置面板中可切换，控制 fancyLogAdmin 输出语言
-- ============================================
if SERVER then
    -- 创建 ConVar（自动生成 rep_ 复制版本给客户端）
    ulx.convar( "language", "zh-cn", " - Server output language (zh-cn/en/ru/lzh)", ULib.ACCESS_ADMIN )

    -- 初始加载：应用 ConVar 中的语言
    local lang = GetConVarString( "ulx_language" )
    if lang and ULib.ulx_lang.names[lang] then
        ULib.ulx_lang.switch( lang )
    else
        ULib.ulx_lang.switch( "zh-cn" )
    end

    -- 监听管理员通过 XGUI 更改语言
    hook.Add( "ULibReplicatedCvarChanged", "UltraULX_Language", function( sv_cvar, cl_cvar, ply, old_val, new_val )
        if cl_cvar ~= "ulx_language" then return end
        if not IsValid( ply ) or not ply:IsSuperAdmin() then return end
        if new_val and ULib.ulx_lang.names[new_val] then
            ULib.ulx_lang.switch( new_val )
            ULib.tsayColor( ply, true, ULib.COLOR_ACCENT, "[Ultra ULX] 服务器语言已切换为: " .. new_val )
        end
    end )
end


-- ============================================
-- P0: 原版 ULX 共存机制
-- InitPostEntity 后重新注册命令，确保 Ultra ULX 覆盖原版
-- 删除本插件后原版 ULX 无缝恢复，零侵入
-- ============================================
local UltraULX_ReloadModules
if SERVER then
    UltraULX_ReloadModules = function()
        -- 设置静默标志，防止模块重复打印 "已加载" 消息
        UltraULX_SilentReRegister = true

        -- 只重载含 ulx.command() 的模块（命令注册模块）
        -- 跳过纯钩子模块（crouchjump等），它们不注册命令
        local cmd_modules = {
            "modules/sh/community.lua",  -- fancyLogAdmin 等工具
            "modules/sh/bhop.lua",
            "modules/sh/chat.lua",
            "modules/sh/extras.lua",     -- cleanup/respawn/setmodel
            "modules/sh/fun.lua",        -- 娱乐命令
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
        -- XGUI 服务端模块（含命令注册，不含 xgui_server.lua 横幅）
        local xgui_server = { "sv_bans.lua", "sv_groups.lua", "sv_items.lua", "sv_maps.lua", "sv_sandbox.lua", "sv_settings.lua" }
        for _, file in ipairs(xgui_server) do
            include("ulx/xgui/server/" .. file)
        end
        -- 客户端模块重新通告
        AddCSLuaFile("ulx/modules/cl/xgui_client.lua")
        AddCSLuaFile("ulx/modules/cl/xgui_helpers.lua")
        AddCSLuaFile("ulx/modules/cl/xlib.lua")
        AddCSLuaFile("ulx/modules/cl/motdmenu.lua")
        AddCSLuaFile("ulx/modules/cl/uteam.lua")

        -- 清除静默标志
        UltraULX_SilentReRegister = nil

        MsgC(ULib.COLOR_ACCENT, "[Ultra ULX] 命令重注册完成，已覆盖原版 ULX\n")
    end

    hook.Add("InitPostEntity", "UltraULX_Finalize", function()
        timer.Simple(0.1, function()
            UltraULX_ReloadModules()
        end)
    end)
end

-- ============================================
-- P1: 旧数据导入检测
-- 在 Initialize 阶段检测原版 data/ulx/ 中的旧配置
-- ============================================
if SERVER then
    hook.Add("Initialize", "UltraULX_ImportCheck", function()
        local hasOldData = ULib.fileExists("data/ulx/groups.txt")
        local hasNewData = ULib.fileExists("data/ultra_ulx/groups.txt")

        if hasOldData and not hasNewData then
            ULib.fileWrite("data/ultra_ulx/.import_pending", "1")
            Msg("[Ultra ULX] 检测到原版 ULX 数据，等待管理员导入\n")
        end
    end)

    -- PlayerAuthed 时向管理员推送导入通知
    hook.Add("PlayerAuthed", "UltraULX_NotifyAdmin", function(ply)
        if not IsValid(ply) then return end
        timer.Simple(2, function()
            if not IsValid(ply) then return end
            local isPending = ULib.fileExists("data/ultra_ulx/.import_pending")
            local isSkipped = ULib.fileExists("data/ultra_ulx/.import_skipped")
            local isComplete = ULib.fileExists("data/ultra_ulx/.import_complete")

            -- 如果 .import_pending 标记不存在，但旧数据存在且新数据不存在，再次检测（第二道防线）
            if not isPending and not isSkipped and not isComplete then
                local hasOldData = ULib.fileExists("data/ulx/groups.txt")
                local hasNewData = ULib.fileExists("data/ultra_ulx/groups.txt")
                if hasOldData and not hasNewData then
                    ULib.fileWrite("data/ultra_ulx/.import_pending", "1")
                    isPending = true
                    Msg("[Ultra ULX] 检测到原版 ULX 数据（PlayerAuthed 二次检测）\n")
                end
            end

            if isPending and (ply:IsSuperAdmin() or ply:IsAdmin()) then
                ULib.tsayColor(ply, true, Color(255, 200, 0), "[Ultra ULX] 检测到原版 ULX 数据！")
                ULib.tsayColor(ply, true, Color(255, 200, 0), "请在 XGUI -> 设置 -> 数据导入 中导入配置")
                -- 客户端弹窗
                net.Start("UltraULX_PromptImport")
                net.Send(ply)
            end
        end)
    end)
end

-- ============================================
-- P1: 旧数据导入函数
-- 供 XGUI 导入对话框调用
-- ============================================
function ulx.importOldData(ply, selectedFiles)
    -- ply: 执行导入的管理员 Player 对象
    -- selectedFiles: 用户勾选的文件名列表，如 {"groups.txt", "users.txt"}
    if not selectedFiles or #selectedFiles == 0 then
        selectedFiles = {
            "config.txt", "groups.txt", "users.txt",
            "adverts.txt", "motd.txt", "votemaps.txt",
            "banreasons.txt", "banmessage.txt",
        }
    end

    local targetDir = "data/ultra_ulx/"
    local oldDir = "data/ulx/"

    if not ULib.fileIsDir(targetDir) then
        ULib.fileCreateDir(targetDir)
    end

    local imported = {}
    for _, file in ipairs(selectedFiles) do
        local oldPath = oldDir .. file
        if ULib.fileExists(oldPath) then
            local content = ULib.fileRead(oldPath)
            if content and content ~= "" then
                ULib.fileWrite(targetDir .. file, content)
                table.insert(imported, file)
            end
        end
    end

    if #imported > 0 then
        ULib.fileWrite(targetDir .. ".import_complete", table.concat(imported, "\n"))
        ULib.fileDelete("data/ultra_ulx/.import_pending")
        if IsValid(ply) then
            ULib.tsayColor(ply, true, ULib.COLOR_ACCENT, "[Ultra ULX] 已导入 " .. #imported .. " 个配置文件")
        end
        Msg("[Ultra ULX] 数据导入完成: " .. table.concat(imported, ", ") .. "\n")
    end

    return imported
end
