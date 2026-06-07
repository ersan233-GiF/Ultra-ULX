--Commands module (formerly players module) v2 for ULX GUI -- by Stickly Man!
--Handles all user-executable commands, such as kick, slay, ban, etc.

local cmds = xlib.makepanel{ parent=xgui.null }
cmds.selcmd = nil
cmds.mask = xlib.makepanel{ x=160, y=30, w=425, h=330, parent=cmds }
cmds.argslist = xlib.makelistlayout{ w=165, h=330, parent=cmds.mask }
cmds.argslist.secondaryPos = nil

cmds.argslist.scroll:SetVisible( false )

function cmds.argslist:Open( cmd, secondary )
	if secondary then
		if cmds.plist.open then
			cmds.plist:Close()
		elseif self.open then
			self:Close()
		end
	end
	self:openAnim( cmd, secondary )
	self.open = true
end
function cmds.argslist:Close()
	self:closeAnim( self.secondaryPos )
	self.open = false
end
cmds.plist = xlib.makelistview{ w=250, h=330, multiselect=true, parent=cmds.mask }
function cmds.plist:Open( arg )
	if cmds.argslist.secondaryPos == true then cmds.argslist:Close()
	elseif self.open then self:Close() end
	self:openAnim( arg )
	self.open = true
end
function cmds.plist:Close()
	if cmds.argslist.open then cmds.argslist:Close() end
	self:closeAnim()
	self.open = false
end
cmds.plist.DoDoubleClick = function()
	cmds.runCmd( cmds.selcmd )
end
cmds.plist:SetVisible( false )
cmds.plist:AddColumn( ULib.ulx_lang.T("ui_player_name") )
cmds.plist:AddColumn( ULib.ulx_lang.T("ui_user_group") )

cmds.cmds = xlib.makelistlayout{ x=5, y=30, w=150, h=330, parent=cmds, padding=1, spacing=1 }
cmds.setselected = function( selcat, LineID )
	if selcat.Lines[LineID]:GetColumnText(2) == cmds.selcmd then
		selcat:ClearSelection()
		if cmds.plist.open then cmds.plist:Close() else cmds.argslist:Close() end
		xlib.animQueue_start()
		cmds.selcmd = nil
		return
	end

	for _, cat in pairs( cmds.cmd_contents ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	cmds.selcmd = selcat.Lines[LineID]:GetColumnText(2)

	if cmds.permissionChanged then cmds.refreshPlist() return end

	if xlib.animRunning then xlib.animQueue_forceStop() end

	local cmd = ULib.cmds.translatedCmds[cmds.selcmd]
	if cmd.args[2] and ( cmd.args[2].type == ULib.cmds.PlayersArg or cmd.args[2].type == ULib.cmds.PlayerArg ) then
		-- 道具同款展开：同时拉出玩家列表和参数面板
		cmds.plist:Open( cmd.args[2] )
		xlib.addToAnimQueue( function()
			if cmds.argslist.open then cmds.argslist:Close() end
			cmds.argslist:Open( cmd, false )
		end )
	else
		cmds.argslist:Open( cmd, true )
	end
	xlib.animQueue_start()
end

function cmds.refreshPlist( arg )
	if not arg then arg = ULib.cmds.translatedCmds[cmds.selcmd].args[2] end
	if not arg or ( arg.type ~= ULib.cmds.PlayersArg and arg.type ~= ULib.cmds.PlayerArg ) then return end

	local lastplys = {}
	for k, Line in pairs( cmds.plist.Lines ) do
		if ( Line:IsLineSelected() ) then table.insert( lastplys, Line:GetColumnText(1) ) end
	end

	local targets = cmds.calculateValidPlayers( arg )

	cmds.plist:Clear()
	cmds.plist:SetMultiSelect( arg.type == ULib.cmds.PlayersArg )

	for _, ply in ipairs( targets ) do
		local line = cmds.plist:AddLine( ply:Nick(), xgui.translateGroup( ply:GetUserGroup() ) )
		line.ply = ply
		line.OnSelect = function()
			if cmds.permissionChanged then return end

			if not xlib.animRunning and not cmds.argslist.open then
				cmds.argslist:Open( ULib.cmds.translatedCmds[cmds.selcmd], false )
				xlib.animQueue_start( )
			else
				if not cmds.clickedFlag then --Prevent this from happening multiple times.
					cmds.clickedFlag = true
					xlib.addToAnimQueue( function() if not cmds.argslist.open then
						cmds.argslist:Open( ULib.cmds.translatedCmds[cmds.selcmd], false ) end
						cmds.clickedFlag = nil end )
				end
			end
		end

		--Select previously selected Lines
		if table.HasValue( lastplys, ply:Nick() ) then
			cmds.plist:SelectItem( line )
		end
	end

	cmds.plist:SortByColumn( 1, false )

	--Select only the first item if multiselect is disabled.
	if not cmds.plist:GetMultiSelect() then
		local firstSelected = cmds.plist:GetSelected()[1]
		cmds.plist:ClearSelection()
		cmds.plist:SelectItem( firstSelected )
	end

	if not cmds.plist:GetSelectedLine() then
		if not xlib.animRunning then
			if cmds.argslist.open then
				cmds.argslist:Close()
				xlib.animQueue_start()
			end
		else
			if cmds.permissionChanged then
				xlib.addToAnimQueue( function() if cmds.argslist.open and cmds.plist.open then cmds.argslist:Close() end end )
			end
		end
	end
end

function cmds.calculateValidPlayers( arg )
	if not arg then arg = ULib.cmds.translatedCmds[cmds.selcmd].args[2] end

	local access, tag = LocalPlayer():query( arg.cmd )
	local restrictions = {}
	ULib.cmds.PlayerArg.processRestrictions( restrictions, LocalPlayer(), arg, ulx.getTagArgNum( tag, 1 ) )

	local targets = restrictions.restrictedTargets
	if targets == false then -- No one allowed
		targets = {}
	elseif targets == nil then -- Everyone allowed
		targets = player.GetAll()
	end
	return targets
end

function cmds.buildArgsList( cmd )
	cmds.argslist:Clear()
	cmds.curargs = {}
	local argnum = 0
	local zpos = 0
	local expectingplayers = cmd.args[2] and ( ( cmd.args[2].type == ULib.cmds.PlayersArg ) or ( cmd.args[2].type == ULib.cmds.PlayerArg ) ) or false
	for _, arg in ipairs( cmd.args ) do
		if not arg.type.invisible then
			argnum = argnum + 1
			if not ( argnum == 1 and expectingplayers ) then
				if arg.invisible ~= true then
					local curitem = arg
					if curitem.repeat_min then --This command repeats!
						local panel = xlib.makepanel{ h=20, parent=cmds.argslist }
						local choices = {}
						panel.argnum = argnum
						panel.xguiIgnore = true
						panel.arg = curitem
						panel.addbutton = xlib.makebutton{ label=ULib.ulx_lang.T("ui_add"), w=83, parent=panel }
						panel.addbutton.DoClick = function( self )
							local parent = self:GetParent()
							local ctrl = parent.arg.type.x_getcontrol( parent.arg, parent.argnum, cmds.argslist )
							cmds.argslist:Add( ctrl )
							ctrl:MoveToAfter( choices[#choices] )
							table.insert( choices, ctrl )
							table.insert( cmds.curargs, ctrl )
							panel.removebutton:SetDisabled( false )
							if parent.arg.repeat_max and #choices >= parent.arg.repeat_max then self:SetDisabled( true ) end
						end
						panel.removebutton = xlib.makebutton{ label=ULib.ulx_lang.T("ui_remove"), x=83, w=82, disabled=true, parent=panel }
						panel.removebutton.DoClick = function( self )
							local parent = self:GetParent()
							local ctrl = choices[#choices]
							ctrl:Remove()
							table.remove( choices )
							table.remove( cmds.curargs )
							panel.addbutton:SetDisabled( false )
							if #choices <= parent.arg.repeat_min then self:SetDisabled( true ) end
						end
						cmds.argslist:Add( panel )
						panel:SetZPos( zpos )
						zpos = zpos + 1
						for i=1,curitem.repeat_min do
							local ctrl = arg.type.x_getcontrol( arg, argnum, cmds.argslist )
							cmds.argslist:Add( ctrl )
							ctrl:SetZPos( zpos )
							zpos = zpos + 1
							table.insert( choices, ctrl )
							table.insert( cmds.curargs, ctrl )
						end
					else
						local panel = arg.type.x_getcontrol( arg, argnum, cmds.argslist )
						table.insert( cmds.curargs, panel )
						if curitem.type == ULib.cmds.NumArg then
							panel.TextArea.OnEnter = function( self )
								cmds.runCmd( cmd.cmd )
							end
						elseif curitem.type == ULib.cmds.StringArg then
							panel.OnEnter = function( self )
								cmds.runCmd( cmd.cmd )
							end
						end
						cmds.argslist:Add( panel )
						panel:SetZPos( zpos )
						zpos = zpos + 1
					end
				end
			end
		end
	end
	if LocalPlayer():query( cmd.cmd ) then
		local btnLabel = xgui.translateCommand( cmd.cmd )
		local panel = xlib.makebutton{ label=btnLabel, parent=cmds.argslist }
		panel.xguiIgnore = true
		panel.DoClick = function()
			cmds.runCmd( cmd.cmd )
		end
		cmds.argslist:Add( panel )
		panel:SetZPos( zpos )
		zpos = zpos + 1
	end
	if cmd.opposite and LocalPlayer():query( cmd.opposite ) then
		local oppLabel = xgui.translateCommand( cmd.opposite )
		local panel = xlib.makebutton{ label=oppLabel, parent=cmds.argslist }
		panel.DoClick = function()
			cmds.runCmd( cmd.opposite )
		end
		panel.xguiIgnore = true
		cmds.argslist:Add( panel )
		panel:SetZPos( zpos )
		zpos = zpos + 1
	end
	if cmd.helpStr then -- Command help text (try translation first)
		local helpText = xgui.translateHelp( cmd.cmd ) or cmd.helpStr
		local panel = xlib.makelabel{ w=160, label=helpText, wordwrap=true, parent=cmds.argslist }
		panel.xguiIgnore = true
		cmds.argslist:Add( panel )
		panel:SetZPos( zpos )
		zpos = zpos + 1
	end
end

function cmds.runCmd( cmd )
	local cmd = string.Explode( " ", cmd )
	if cmds.plist:IsVisible() then
		local plys = {}
		for _, line in ipairs( cmds.plist:GetSelected() ) do
			table.insert( plys, "$" .. ULib.getUniqueIDForPlayer( line.ply ) )
			table.insert( plys, "," )
		end
		table.remove( plys ) --Removes the final comma
		table.insert( cmd, table.concat( plys ) )
	end

	for _, arg in ipairs( cmds.curargs ) do
		if not arg.xguiIgnore then
			table.insert( cmd, arg:GetValue() )
		end
	end
	RunConsoleCommand( unpack( cmd ) )
end

function cmds.playerNameChanged( ply, old, new )
	for i, line in ipairs( cmds.plist.Lines ) do
		if line:GetColumnText(1) == old then
			line:SetColumnText( 1, new )
		end
	end
end

cmds.refresh = function( permissionChanged )
	local lastcmd = cmds.selcmd
	cmds.cmds:Clear()
	cmds.cmd_contents = {}
	cmds.expandedcat = nil
	cmds.selcmd = nil
	cmds.permissionChanged = true

	local newcategories = {}
	local sortcategories = {}
	local matchedCmdFound = false
	for cmd, data in pairs( ULib.cmds.translatedCmds ) do
		local opposite = data.opposite
		if opposite ~= cmd and ( LocalPlayer():query( data.cmd ) or (opposite and LocalPlayer():query( opposite ) )) then
			local catname = data.category
			if catname == nil or catname == "" then catname = "_Uncategorized" end
			if not cmds.cmd_contents[catname] then
				--Make a new category
				cmds.cmd_contents[catname] = xlib.makelistview{ headerheight=0, multiselect=false, h=136 }
				cmds.cmd_contents[catname].OnRowSelected = function( self, LineID ) cmds.setselected( self, LineID ) end
				cmds.cmd_contents[catname]:AddColumn( "" )
				local displayCat = xgui.translateCategory( catname )
				local cat = xlib.makecat{ label=displayCat, contents=cmds.cmd_contents[catname], expanded=false, parent=xgui.null }
				function cat.Header:OnMousePressed( mcode )
					if ( mcode == MOUSE_LEFT ) then
						self:GetParent():Toggle()
						if cmds.expandedcat then
							if cmds.expandedcat ~= self:GetParent() then
								cmds.expandedcat:Toggle()
							else
								cmds.expandedcat = nil
								return
							end
						end
						cmds.expandedcat = self:GetParent()
						return
					end
					return self:GetParent():OnMousePressed( mcode )
				end
				newcategories[catname] = cat
				table.insert( sortcategories, catname )
			end
			local displayName = xgui.translateCommand( data.cmd )
			local line = cmds.cmd_contents[catname]:AddLine( displayName, data.cmd )
			if data.cmd == lastcmd then
				cmds.cmd_contents[catname]:SelectItem( line )
				cmds.expandedcat = cmds.cmd_contents[catname]:GetParent()
				cmds.expandedcat:SetExpanded( true )
				matchedCmdFound = true
			end
		end
	end
	if not matchedCmdFound then
		if cmds.plist.open then
			cmds.plist:Close()
			xlib.animQueue_start()
		elseif cmds.argslist.open then
			cmds.argslist:Close()
			xlib.animQueue_start()
		end
	end

	table.sort( sortcategories )
	for _, catname in ipairs( sortcategories ) do
		local cat = newcategories[catname]
		cmds.cmds:Add( cat )
		cat.Contents:SortByColumn( 1 )
		cat.Contents:SetHeight( 17*#cat.Contents:GetLines() )
	end
	cmds.permissionChanged = nil
end

--------------
--ANIMATIONS--
--------------
function cmds.plist:openAnim( arg )
	xlib.addToAnimQueue( cmds.refreshPlist, arg )
	xlib.addToAnimQueue( "pnlSlide", { panel=self, startx=-250, starty=0, endx=0, endy=0, setvisible=true } )
end

function cmds.plist:closeAnim()
	xlib.addToAnimQueue( "pnlSlide", { panel=self, startx=0, starty=0, endx=-250, endy=0, setvisible=false } )
end

function cmds.argslist:openAnim( cmd, secondary )
	xlib.addToAnimQueue( function() cmds.argslist.secondaryPos = secondary end )
	xlib.addToAnimQueue( cmds.buildArgsList, cmd )
	if secondary then
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=-170, starty=0, endx=0, endy=0, setvisible=true } )
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=80, starty=0, endx=255, endy=0, setvisible=true } )
	end
end

function cmds.argslist:closeAnim( secondary )
	if secondary then
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=0, starty=0, endx=-170, endy=0, setvisible=false } )
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=255, starty=0, endx=80, endy=0, setvisible=false } )
	end
	xlib.addToAnimQueue( function() cmds.argslist.secondaryPos = nil end )
end
-------------

-- 初始化由 UCLChanged 钩子触发，避免在认证前调用 query 导致错误
hook.Add( "UCLChanged", "xgui_RefreshPlayerCmds", cmds.refresh )
hook.Add( "ULibPlayerNameChanged", "xgui_plyUpdateCmds", cmds.playerNameChanged )

-- 语言刷新: 仅更新文本不重建结构
function cmds.refreshTexts()
	if not cmds.cmd_contents then return end
	for catname, listView in pairs( cmds.cmd_contents ) do
		local cat = listView:GetParent()
		if cat and cat.SetLabel then cat:SetLabel( xgui.translateCategory( catname ) ) end
		for _, line in ipairs( listView.Lines ) do
			local fullCmd = line:GetColumnText(2)
			if fullCmd then line:SetColumnText( 1, xgui.translateCommand( fullCmd ) ) end
		end
		listView:SortByColumn( 1 )
	end
	if cmds.argslist.open and cmds.selcmd then
		local cmd = ULib.cmds.translatedCmds[cmds.selcmd]
		if cmd then cmds.buildArgsList( cmd ) end
	end
	if cmds.plist and cmds.plist.Columns then
		local c1 = cmds.plist.Columns[1]; if c1 and c1.Header then c1.Header:SetText( xgui.T("ui_player_name") ) end
		local c2 = cmds.plist.Columns[2]; if c2 and c2.Header then c2.Header:SetText( xgui.T("ui_user_group") ) end
	end
	-- 实时刷新玩家列表行中的用户组翻译
	if cmds.plist and cmds.plist.Lines then
		for _, line in ipairs( cmds.plist.Lines ) do
			if line.ply and line.ply:IsValid() then
				line:SetColumnText( 2, xgui.translateGroup( line.ply:GetUserGroup() ) )
			end
		end
	end
end
xgui.registerRefresh( "commands", cmds.refreshTexts )

xgui.addModule( "commands", cmds, "icon16/user_gray.png" )
