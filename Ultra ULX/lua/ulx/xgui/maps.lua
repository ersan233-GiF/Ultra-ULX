-- Maps management module v3 -- based on Stickly Man!'s original
-- 重构版：使用 xgui_core.lua 统一语言管理

ulx.votemaps = ulx.votemaps or {}
xgui.prepareDataType( "votemaps", ulx.votemaps )
local maps = xlib.makepanel{ parent=xgui.null }

maps.maplabel = xlib.makelabel{ x=10, y=13, label=xgui.T("maps_title"), parent=maps }
maps.gamemodeLabel = xlib.makelabel{ x=10, y=343, label=xgui.T("maps_gamemode"), parent=maps }
maps.curmap = xlib.makelabel{ x=187, y=223, w=192, label=xgui.T("maps_noselect"), parent=maps }

maps.list = xlib.makelistview{ x=5, y=30, w=175, h=310, multiselect=true, parent=maps, headerheight=0 }
maps.list:AddColumn( xgui.T("maps_col_name") )
maps.list.OnRowSelected = function( self, LineID, Line )
	if ULib.fileExists( "maps/thumb/" .. maps.list:GetSelected()[1]:GetColumnText(1) .. ".png" ) then
		maps.disp:SetMaterial( Material( "maps/thumb/" .. maps.list:GetSelected()[1]:GetColumnText(1) .. ".png" ) )
	else
		maps.disp:SetMaterial( Material( "maps/thumb/noicon.png" ) )
	end
	maps.curmap:SetText( Line:GetColumnText(1) )
	maps.updateButtonStates()
end

maps.disp = vgui.Create( "DImage", maps )
maps.disp:SetPos( 185, 30 )
maps.disp:SetMaterial( Material( "maps/thumb/noicon.png" ) )
maps.disp:SetSize( 192, 192 )

maps.gamemode = xlib.makecombobox{ x=70, y=340, w=110, h=20, text=xgui.T("maps_default_gm"), parent=maps }

maps.vote = xlib.makebutton{ x=185, y=245, w=192, h=20, label=xgui.T("maps_vote"), parent=maps }
maps.vote.DoClick = function()
	if maps.curmap:GetValue() ~= xgui.T("maps_noselect") then
		RunConsoleCommand( "ulx", "votemap", maps.curmap:GetValue() )
	end
end

maps.svote = xlib.makebutton{ x=185, y=270, w=192, h=20, label=xgui.T("maps_svote"), parent=maps }
maps.svote.DoClick = function()
	if maps.curmap:GetValue() ~= xgui.T("maps_noselect") then
		local votemaps = {}
		for k, v in ipairs( maps.list:GetSelected() ) do
			table.insert( votemaps, maps.list:GetSelected()[k]:GetColumnText(1) )
		end
		RunConsoleCommand( "ulx", "votemap2", unpack( votemaps ) )
	end
end

maps.changemap = xlib.makebutton{ x=185, y=295, w=192, h=20, disabled=true, label=xgui.T("maps_change"), parent=maps }
maps.changemap.DoClick = function()
	if maps.curmap:GetValue() ~= xgui.T("maps_noselect") then
		Derma_Query( xgui.T("maps_confirm_change") .. "\"" .. maps.curmap:GetValue() .. "\"?",
			xgui.T("maps_warning_title"),
			xgui.T("maps_btn_change"), function()
				RunConsoleCommand( "ulx", "map", maps.curmap:GetValue(),
					( maps.gamemode:GetValue() ~= xgui.T("maps_default_gm") ) and maps.gamemode:GetValue() or nil )
			end,
			xgui.T("maps_btn_cancel"), function() end )
	end
end

maps.vetomap = xlib.makebutton{ x=185, y=320, w=192, label=xgui.T("maps_veto"), parent=maps }
maps.vetomap.DoClick = function() RunConsoleCommand( "ulx", "veto" ) end

maps.nextLevelLabel = xlib.makelabel{ x=382, y=13, label=xgui.T("maps_nextlevel"), parent=maps }
maps.nextlevel = xlib.makecombobox{ x=382, y=30, w=180, h=20, repconvar="rep_nextlevel", convarblanklabel=xgui.T("maps_unspecified"), parent=maps }

function maps.addMaptoList( mapname, lastselected )
	local line = maps.list:AddLine( mapname )
	if table.HasValue( lastselected, mapname ) then maps.list:SelectItem( line ) end
	line.isNotVotemap = nil
	if not table.HasValue( ulx.votemaps, mapname ) then
		line:SetAlpha( 128 )
		line.isNotVotemap = true
	end
end

function maps.updateVoteMaps()
	local lastselected = {}
	for k, Line in pairs( maps.list.Lines ) do
		if Line:IsLineSelected() then table.insert( lastselected, Line:GetColumnText(1) ) end
	end
	maps.list:Clear()
	maps.nextlevel:Clear()
	if LocalPlayer():query( "ulx map" ) then
		maps.maplabel:SetText( xgui.T("maps_title") )
		maps.nextlevel:AddChoice( xgui.T("maps_unspecified") )
		maps.nextlevel.ConVarUpdated( "nextlevel", "rep_nextlevel", nil, nil, GetConVar( "rep_nextlevel" ):GetString() )
		maps.nextLevelLabel:SetAlpha( 255 )
		maps.nextlevel:SetDisabled( false )
		if ulx.maps then for _, v in ipairs( ulx.maps ) do
			maps.addMaptoList( v, lastselected )
			maps.nextlevel:AddChoice( v )
		end end
	else
		maps.maplabel:SetText( xgui.T("maps_title_vote") )
		maps.nextLevelLabel:SetAlpha( 0 )
		maps.nextlevel:SetDisabled( true )
		maps.nextlevel:SetAlpha( 0 )
		if ulx.votemaps then for _, v in ipairs( ulx.votemaps ) do
			maps.addMaptoList( v, lastselected )
		end end
	end
	if not maps.accessVotemap2 then
		local l = maps.list:GetSelected()[1]
		maps.list:ClearSelection()
		maps.list:SelectItem( l )
	end
	maps.updateButtonStates()
	ULib.cmds.translatedCmds["ulx votemap"].args[2].completes = xgui.data.votemaps
end

function maps.updateGamemodes()
	local lastselected = maps.gamemode:GetValue()
	maps.gamemode:Clear()
	maps.gamemode:SetText( lastselected )
	maps.gamemode:AddChoice( xgui.T("maps_default_gm") )
	local access, tag = LocalPlayer():query( "ulx map" )
	local restrictions = {}
	ULib.cmds.StringArg.processRestrictions( restrictions, ULib.cmds.translatedCmds['ulx map'].args[3], ulx.getTagArgNum( tag, 2 ) )
	for _, v in ipairs( restrictions.restrictedCompletes ) do
		local name = xgui.T( "gm_" .. v )
		if name == "gm_" .. v then name = v end
		maps.gamemode:AddChoice( name, v )
	end
end

function maps.updatePermissions()
	maps.vetomap:SetDisabled( true )
	RunConsoleCommand( "xgui", "getVetoState" )
	maps.accessVotemap = ( GetConVarNumber( "ulx_votemapEnabled" ) == 1 )
	maps.accessVotemap2 = LocalPlayer():query( "ulx votemap2" )
	maps.accessMap = LocalPlayer():query( "ulx map" )
	maps.updateGamemodes()
	maps.updateVoteMaps()
	maps.updateButtonStates()
end

function xgui.updateVetoButton( value )
	maps.vetomap:SetDisabled( not value )
end

function maps.updateButtonStates()
	maps.gamemode:SetDisabled( not maps.accessMap )
	maps.list:SetMultiSelect( maps.accessVotemap2 )
	if maps.list:GetSelectedLine() then
		maps.vote:SetDisabled( maps.list:GetSelected()[1].isNotVotemap or not maps.accessVotemap )
		maps.svote:SetDisabled( not maps.accessVotemap2 )
		maps.changemap:SetDisabled( not maps.accessMap )
	else
		maps.vote:SetDisabled( true )
		maps.svote:SetDisabled( true )
		maps.changemap:SetDisabled( true )
		maps.curmap:SetText( xgui.T("maps_noselect") )
		maps.disp:SetMaterial( Material( "maps/thumb/noicon.png" ) )
	end
end

maps.updateVoteMaps()

function maps.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
	if cl_cvar == "ulx_votemapenabled" then
		maps.accessVotemap = ( tonumber( new_val ) == 1 )
		maps.updateButtonStates()
	end
end
hook.Add( "ULibReplicatedCvarChanged", "XGUI_mapsUpdateVotemapEnabled", maps.ConVarUpdated )

xgui.hookEvent( "onProcessModules", nil, maps.updatePermissions, "mapsUpdatePermissions" )
xgui.hookEvent( "votemaps", "process", maps.updateVoteMaps, "mapsUpdateVotemaps" )

-- 语言刷新：更新静态标签 + 游戏模式选择框
xgui.registerRefresh( "maps", function()
	maps.maplabel:SetText( xgui.T("maps_title") )
	local col = maps.list.Columns[1]; if col and col.Header then col.Header:SetText( xgui.T("maps_col_name") ) end
	maps.vote:SetText( xgui.T("maps_vote") )
	maps.svote:SetText( xgui.T("maps_svote") )
	maps.changemap:SetText( xgui.T("maps_change") )
	maps.vetomap:SetText( xgui.T("maps_veto") )
	maps.nextLevelLabel:SetText( xgui.T("maps_nextlevel") )
	maps.gamemodeLabel:SetText( xgui.T("maps_gamemode") )
	local noselectStr = xgui.T("maps_noselect")
	if maps.curmap:GetValue() == noselectStr or maps.curmap:GetValue() == "未选择地图" or maps.curmap:GetValue() == "No Map Selected" then
		maps.curmap:SetText( noselectStr )
	end
	-- 重建游戏模式选择框选项（按数据值保留选中）
	if maps.gamemode then
		local prevId = maps.gamemode:GetSelectedID()
		local prevData = prevId and select(2, maps.gamemode:GetOptionData(prevId))
		maps.gamemode:Clear()
		maps.gamemode:AddChoice( xgui.T("maps_default_gm") )
		local access, tag = LocalPlayer():query( "ulx map" )
		local restrictions = {}
		ULib.cmds.StringArg.processRestrictions( restrictions, ULib.cmds.translatedCmds['ulx map'].args[3], ulx.getTagArgNum( tag, 2 ) )
		for _, v in ipairs( restrictions.restrictedCompletes ) do
			local name = xgui.T( "gm_" .. v )
			if name == "gm_" .. v then name = v end
			maps.gamemode:AddChoice( name, v )
		end
		-- 按数据值恢复选中
		if prevData then
			for id = 1, maps.gamemode:GetOptionsCount() do
				local _, data = maps.gamemode:GetOptionData(id)
				if data == prevData then maps.gamemode:ChooseOptionID(id); break end
			end
		else
			maps.gamemode:SetText( xgui.T("maps_default_gm") )
		end
	end
end )

xgui.addModule( "maps", maps, "icon16/map.png" )
