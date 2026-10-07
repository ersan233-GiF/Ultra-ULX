--[[
	Ultra ULX — BHop 自动连跳管理面板（XGUI）

	与 ulx/modules/sh/bhop.lua 的服务端实现配套。
	服务端 bhop 已重构为：状态 + 限速 两个值，通过 ulx bhop 命令下发；
	调参走 ConVar（ulx_bhop_*），不再有逐玩家参数面板。

	因此本面板的定位是「管理入口」，而不是参数编辑器：
	  * 左侧：玩家列表（多选，样式照抄 items.lua）
	  * 右侧：当前玩家 BHop 状态与限速 + 启用/关闭按钮
	  * 状态来源：服务端 ulx_bhop / ulx_bhop_state 消息（只读显示）

	权限：xgui_managebhop（见 xgui/server/sv_bhop.lua），默认 admin；
	      服务端 ulx bhop 命令自身还有一层 defaultAccess(ADMIN) 校验。

	语言键：全部复用 4 语言文件中已有的 bhop_* 键，未新增任何字符串。
]]

local bhop = xlib.makepanel{ parent = xgui.null }
bhop.curState = { active = false, limit = 0 }

bhop.mask = xlib.makepanel{ x = 160, y = 30, w = 425, h = 370, parent = bhop }

bhop.argslist = xlib.makelistlayout{ w = 165, h = 370, parent = bhop.mask }
bhop.argslist.scroll:SetVisible( true )

bhop.plist = xlib.makelistview{ w = 250, h = 370, multiselect = true, parent = bhop.mask }
bhop.plist:AddColumn( ULib.ulx_lang.T( "ui_player_name" ) )
bhop.plist:AddColumn( ULib.ulx_lang.T( "ui_user_group" ) )

local function sid64Of( ply )
	if not IsValid( ply ) then return nil end
	if ply.SteamID64 then
		local ok, sid = pcall( ply.SteamID64, ply )
		if ok and sid then return sid end
	end
	return ply:SteamID() and ( "SID:" .. ply:SteamID() ) or nil
end

function bhop.refreshPlist()
	local lastSelected = {}
	for _, line in ipairs( bhop.plist:GetSelected() ) do
		local sid = sid64Of( line.ply )
		if sid then table.insert( lastSelected, sid ) end
	end

	bhop.plist:Clear()
	local localLine = nil
	for _, ply in ipairs( player.GetAll() ) do
		local sid = sid64Of( ply )
		if sid then
			local line = bhop.plist:AddLine( ply:Nick(), xgui.translateGroup( ply:GetUserGroup() ) )
			line.ply = ply
			line.sid = sid
			if table.HasValue( lastSelected, sid ) then bhop.plist:SelectItem( line ) end
			if ply == LocalPlayer() then localLine = line end
		end
	end

	bhop.plist:SortByColumn( 1, false )
	if #bhop.plist:GetSelected() == 0 and localLine then bhop.plist:SelectItem( localLine ) end
end

local function selectedSids()
	local out = {}
	for _, line in ipairs( bhop.plist:GetSelected() ) do
		if line.sid then table.insert( out, line.sid ) end
	end
	return out
end

-- 向后端查询选中玩家的 BHop 状态
function bhop.requestState()
	local sids = selectedSids()
	if #sids == 0 then return end
	net.Start( "ulx_bhop_query" )
	net.WriteUInt( #sids, 8 )
	for _, sid in ipairs( sids ) do net.WriteString( sid ) end
	net.SendToServer()
end

function bhop.updateStateLabel()
	if not IsValid( bhop.stateLabel ) then return end
	local text
	if bhop.curState.active then
		local limit = bhop.curState.limit
		if limit and limit > 0 then
			text = xgui.T( "bhop_speedlimit" ) .. ": " .. tostring( limit )
		else
			text = xgui.T( "bhop_unlimited" )
		end
	else
		text = xgui.T( "bhop_disabled_val" )
	end
	bhop.stateLabel:SetText( text )
	bhop.stateLabel:SizeToContents()
end

function bhop.buildPanel()
	bhop.argslist:Clear()
	local z = 0
	local function place( p )
		bhop.argslist:Add( p )
		p:SetZPos( z )
		z = z + 1
		return p
	end

	local info = place( xlib.makelabel{ x = 0, y = 2, label = xgui.T( "bhop_xgui_info" ) } )
	info:SetWrap( true )
	info:SetAutoStretchVertical( true )
	info:SetWide( 160 )

	place( xlib.makelabel{ label = xgui.T( "bhop_params_title" ) } )
	bhop.stateLabel = place( xlib.makelabel{ label = "" } )
	bhop.updateStateLabel()

	local enableBtn = place( xlib.makebutton{ label = xgui.T( "bhop_enable" ) } )
	enableBtn:SetSize( 160, 22 )
	enableBtn.DoClick = function()
		local sids = selectedSids()
		if #sids == 0 then
			Derma_Message( xgui.T( "items_select_player" ), xgui.T( "ui_ok" ), xgui.T( "ui_ok" ) )
			return
		end
		net.Start( "ulx_bhop_apply" )
		net.WriteUInt( #sids, 8 )
		for _, sid in ipairs( sids ) do net.WriteString( sid ) end
		net.WriteBool( true )
		net.WriteUInt( 0, 16 ) -- 0 = 不限速；限速值由 ulx_bhop_speedlimit 等 ConVar 统一控制
		net.SendToServer()
	end

	local disableBtn = place( xlib.makebutton{ label = xgui.T( "bhop_disable" ) } )
	disableBtn:SetSize( 160, 22 )
	disableBtn.DoClick = function()
		local sids = selectedSids()
		if #sids == 0 then
			Derma_Message( xgui.T( "items_select_player" ), xgui.T( "ui_ok" ), xgui.T( "ui_ok" ) )
			return
		end
		net.Start( "ulx_bhop_apply" )
		net.WriteUInt( #sids, 8 )
		for _, sid in ipairs( sids ) do net.WriteString( sid ) end
		net.WriteBool( false )
		net.WriteUInt( 0, 16 )
		net.SendToServer()
	end

	local refreshBtn = place( xlib.makebutton{ label = xgui.T( "ui_refresh_data" ) } )
	refreshBtn:SetSize( 160, 22 )
	refreshBtn.DoClick = function()
		bhop.refreshPlist()
		bhop.requestState()
	end

	bhop.argslist:InvalidateLayout( true )
end

-- 服务端回传：某玩家的 BHop 状态
net.Receive( "ulx_bhop_panel_state", function()
	bhop.curState.active = net.ReadBool()
	bhop.curState.limit  = net.ReadUInt( 16 )
	bhop.updateStateLabel()
end )

-- 服务端广播的状态变化（ulx bhop 命令执行后）
net.Receive( "ulx_bhop", function()
	bhop.curState.active = net.ReadBool()
	bhop.curState.limit  = net.ReadUInt( 16 )
	bhop.updateStateLabel()
end )

net.Receive( "ulx_bhop_state", function()
	bhop.curState.active = net.ReadBool()
	bhop.curState.limit  = net.ReadUInt( 16 )
	bhop.updateStateLabel()
end )

bhop.buildPanel()
bhop.refreshPlist()
bhop.requestState()

hook.Add( "UCLChanged", "xgui_bhop_refresh", bhop.refreshPlist )
xgui.registerRefresh( "bhop", function()
	bhop.refreshPlist()
	bhop.requestState()
end )
xgui.addModule( "bhop", bhop, "icon16/arrow_up.png", "xgui_managebhop" )
Msg( "[ULX] BHop 面板已注册\n" )
