--[[
	Ultra ULX — 客户端版本自动同步

	机制：
	  服务端在玩家 clReady（ulib_cl_ready）时下发 ulx.VERSION；
	  客户端比对自身 ulx.VERSION，若不一致则递归删除本地旧版 Lua 文件，
	  随后自动重连，由服务端 AddCSLuaFile 重新下发最新版。

	为什么需要它：
	  GMod 客户端会缓存 addon 的 Lua 文件，服务端更新后客户端可能仍在跑旧代码，
	  表现为命令缺失、界面功能异常等"服务端明明改了却没生效"的问题。
	  此模块让版本漂移自动收敛，无需玩家手动清缓存。

	设计要点：
	  * 版本号复用 ulx.VERSION（defines.lua 唯一来源），不另设变量，避免两处版本不一致。
	  * 只删本插件目录下的 lua，跳过 lua/bin（第三方二进制模块 DLL 不归我们管）。
	  * 全程 pcall 保护：删文件受沙盒限制时降级为仅清缓存 + 重连，不刷错误。
	  * 每位玩家只处理一次（versionSynced），重连后作为新连接重新校验。

	移植来源：本地 2026-06-08 分支提交 e2e449b / bb9c881 / 0878ac4 / 2546990
]]

local versionSynced = false

local function deleteLuaFiles( dir )
	local items = file.Find( "addons/Ultra ULX/" .. dir .. "/*", "MOD" )
	if not items then return end

	for _, name in ipairs( items ) do
		local full = dir .. "/" .. name
		if name:find( "%.lua$" ) then
			pcall( function() file.Delete( "addons/Ultra ULX/" .. full ) end )
		elseif name ~= "bin" then
			-- 跳过 lua/bin：放置第三方二进制模块，不属于本插件
			deleteLuaFiles( full )
		end
	end
end

local function clearLuaCache()
	pcall( function()
		local cacheDir = "cache/lua"
		if not file.IsDir( cacheDir, "MOD" ) then return end
		for _, f in ipairs( file.Find( cacheDir .. "/*", "MOD" ) or {} ) do
			pcall( function() file.Delete( cacheDir .. "/" .. f ) end )
		end
	end )
end

net.Receive( "ulx_version_check", function()
	if versionSynced then return end
	versionSynced = true

	local serverVer = net.ReadString()
	local clientVer = ulx.VERSION or "0"

	if serverVer == clientVer then return end

	Msg( "[ULX] 客户端版本 " .. clientVer .. " 与服务端 " .. serverVer .. " 不一致，正在同步...\n" )

	pcall( deleteLuaFiles, "lua" )
	clearLuaCache()

	-- 重连后客户端将重新从服务端下载最新 Lua 文件
	timer.Simple( 0.1, function() RunConsoleCommand( "retry" ) end )
end )
