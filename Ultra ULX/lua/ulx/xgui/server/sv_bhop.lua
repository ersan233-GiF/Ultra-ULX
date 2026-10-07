--[[
	Ultra ULX — BHop 面板服务端桥接

	为什么需要这一层：
	  xgui/bhop.lua 是客户端文件，客户端不能直接调用 ulx.bhop（那是服务端函数）。
	  面板的按钮只能发网络消息，由本文件在服务端做权限校验后调用 ulx.bhop，
	  复用 ulx bhop 命令已有的参数解析与权限体系（与 sv_items.lua 同一套模式）。

	安全模型（三层）：
	  1. 本文件的 net.Receive 先校验 xgui_managebhop 权限；
	  2. 目标玩家经 PlayersArg 解析器校验（可见性/免疫等规则由 ULX 统一处理），
	     与 ulx bhop 命令走同一条路径，不自行实现一套；
	  3. ulx.bhop 自身命令注册了 defaultAccess(ADMIN)。
]]

local L = ULib.ulx_lang

if SERVER then
	if not ulx_bhop_panel_net_init then
		util.AddNetworkString( "ulx_bhop_apply" )
		util.AddNetworkString( "ulx_bhop_query" )
		util.AddNetworkString( "ulx_bhop_panel_state" )
		ulx_bhop_panel_net_init = true
	end
	ULib.ucl.registerAccess( "xgui_managebhop", "admin", "允许在 XGUI 中使用自动连跳管理面板。", "XGUI" )
end

-- 读取并校验目标玩家，返回 ULX 玩家对象列表
local function readValidatedTargets( admin, count )
	local selectors = {}
	local seen = {}
	for _ = 1, count do
		local sid64 = net.ReadString()
		local p = player.GetBySteamID64( sid64 )
		if IsValid( p ) and not seen[p] then
			local id = ULib.getUniqueIDForPlayer( p )
			if id then
				selectors[#selectors + 1] = "$" .. id
				seen[p] = true
			end
		end
	end
	if #selectors == 0 then return {} end

	local parser = ULib.cmds.PlayersArg()
	local targets, err = parser:parseAndValidate( admin, table.concat( selectors, "," ), { cmd = "ulx bhop", type = ULib.cmds.PlayersArg } )
	if not targets then
		ULib.tsayError( admin, err or L.T( "cmd_cannot_target_any" ), true )
		return {}
	end
	return targets
end

net.Receive( "ulx_bhop_apply", function( _, ply )
	if not IsValid( ply ) then return end
	if not ply:query( "xgui_managebhop" ) then
		ULib.tsayError( ply, L.T( "items_no_permission" ), true )
		return
	end

	local count   = net.ReadUInt( 8 )
	local targets = readValidatedTargets( ply, count )
	local enable  = net.ReadBool()
	local limit   = net.ReadUInt( 16 )

	if #targets == 0 then return end
	if not ulx.bhop then
		ULib.tsayError( ply, L.T( "cmd_cannot_target_any" ), true )
		return
	end

	-- 复用命令实现：参数顺序 (calling_ply, target_plys, speedlimit, should_disable)
	ulx.bhop( ply, targets, limit, not enable )
end )

net.Receive( "ulx_bhop_query", function( _, ply )
	if not IsValid( ply ) then return end
	if not ply:query( "xgui_managebhop" ) then return end

	local count = net.ReadUInt( 8 )
	-- 面板当前只展示单选目标的实时状态，取最后一个有效目标
	local last = nil
	for _ = 1, count do
		local sid64 = net.ReadString()
		local p = player.GetBySteamID64( sid64 )
		if IsValid( p ) then last = p end
	end

	-- 回传状态：state 由 bhop 模块维护，这里透传当前值
	local active, limit = false, 0
	if ulx.bhopGetState then
		active, limit = ulx.bhopGetState( last )
	end

	net.Start( "ulx_bhop_panel_state" )
	net.WriteBool( active and true or false )
	net.WriteUInt( math.Clamp( tonumber( limit ) or 0, 0, 65535 ), 16 )
	net.Send( ply )
end )
