-- Groups management module v3 -- based on Stickly Man!'s original
-- 重构版：使用 xgui_core.lua 统一语言管理

xgui.prepareDataType( "groups" )
xgui.prepareDataType( "users" )
xgui.prepareDataType( "teams" )
xgui.prepareDataType( "accesses" )
xgui.prepareDataType( "playermodels" )

local groups = xlib.makepanel{ parent=xgui.null }
groups.list = xlib.makecombobox{ x=5, y=5, w=175, parent=groups }
function groups.list:GetGroupValue()
	local id = self:GetSelectedID()
	if id then
		local _, data = self:GetOptionData( id )
		return data or self:GetValue()
	end
	return self:GetValue()
end
function groups.list:populate()
	local prevSelId = self:GetSelectedID()
	local _, prevData = prevSelId and self:GetOptionData(prevSelId) or nil, nil
	self:Clear()
	local sortedGroups = groups.getSortedGroupList()
	for _, v in ipairs( sortedGroups ) do
		self:AddChoice( xgui.translateGroup( v ), v )
	end
	self:AddChoice( "--*" )
	self:AddChoice( xgui.T("groups_manage_groups") )
	if groups.lastOpenGroup then
		self:SetText( xgui.translateGroup( groups.lastOpenGroup ) )
	elseif prevData then
		-- 按数据值找到新的翻译后文本
		local found = false
		for id = 1, self:GetOptionsCount() do
			local _, data = self:GetOptionData(id)
			if data == prevData then self:ChooseOptionID(id); found = true; break end
		end
		if not found then self:SetText( xgui.T("groups_select_group") ) end
	elseif prevSelId then
		-- 无数据值的特殊选项：按位置恢复
		self:ChooseOptionID( prevSelId )
	else
		self:SetText( xgui.T("groups_select_group") )
	end
	if groups.lastOpenGroup then
		if not ULib.ucl.groups[groups.lastOpenGroup] then
			groups.pnlG1:Close()
			groups.lastOpenGroup = nil
			self:SetText( xgui.T("groups_select_group") )
		end
	end
end
groups.list.OnSelect = function( self, index, value, data )
	if value ~= xgui.T("groups_manage_groups") then
		local groupName = data or value
		if groupName ~= groups.lastOpenGroup then
			groups.lastOpenGroup = groupName
			groups.pnlG1:Open( groupName )
		end
	else
		groups.lastOpenGroup = nil
		groups.pnlG2:Open()
	end
end
groups.lastOpenGroup = nil

groups.clippanela = xlib.makepanel{ x=5, y=30, w=580, h=335, parent=groups }
groups.clippanela.Paint = function() end
groups.clippanelb = xlib.makepanel{ x=175, y=30, w=410, h=335, visible=false, parent=groups }
groups.clippanelb.Paint = function() end
groups.clippanelc = xlib.makepanel{ x=380, y=30, w=210, h=335, visible=false, parent=groups }
groups.clippanelc.Paint = function() end

-- Panel G1 - 用户/团队
groups.pnlG1 = xlib.makepanel{ w=170, h=335, parent=groups.clippanela }
groups.pnlG1:SetVisible( false )
function groups.pnlG1:Open( group )
	if self:IsVisible() then
		-- 已可见：快速淡出→刷新→淡入，给操作反馈
		xlib.addToAnimQueue( "pnlFade", { panelOut=self } )
		xlib.addToAnimQueue( function()
			groups.refreshPlayers( group )
			groups.updateTeamSelection( groups.lastOpenGroup )
		end )
		xlib.addToAnimQueue( "pnlFade", { panelIn=self } )
		xlib.animQueue_start()
		return
	elseif groups.pnlG2:IsVisible() then groups.pnlG2:Close() end
	if groups.pnlG3:IsVisible() then groups.pnlG3:Close() end
	if groups.pnlG4:IsVisible() then groups.pnlG4:Close() end
	groups.refreshPlayers( group )
	groups.updateTeamSelection( groups.lastOpenGroup )
	self:SetVisible( true )
end
function groups.pnlG1:Close()
	if groups.pnlG3:IsVisible() then groups.pnlG3:Close() end
	if groups.pnlG4:IsVisible() then groups.pnlG4:Close() end
	self:SetVisible( false )
end

groups.lblPlayersIn = xlib.makelabel{ x=5, y=5, label=xgui.T("groups_players_in"), parent=groups.pnlG1 }

local function _createPlayersList()
	local panel = xlib.makepanel{ x=5, y=20, w=160, h=190, parent=groups.pnlG1 }
	local scroll = xlib.makescrollpanel{ w=160, h=190, spacing=1, parent=panel }

	function panel:getCheckedPlayers()
		local plys = {}
		for _, row in ipairs( scroll:GetChildren() ) do
			local cb = row:GetChildren()[1]
			if cb and cb.GetChecked and cb:GetChecked() and cb.ply and cb.ply:IsValid() then
				table.insert( plys, cb.ply )
			end
		end
		return plys
	end

	function panel:_hasAnyChecked()
		for _, row in ipairs( scroll:GetChildren() ) do
			local cb = row:GetChildren()[1]
			if cb and cb.GetChecked and cb:GetChecked() then return true end
		end
		return false
	end

	return panel, scroll
end
groups.players, groups.playersScroll = _createPlayersList()

groups.aplayer = xlib.makebutton{ x=5, y=210, w=80, label=xgui.T("ui_add") .. "...", parent=groups.pnlG1 }
groups.aplayer.DoClick = function()
	local menu = DermaMenu()
	menu:SetSkin( xgui.settings.skin )
	for k, v in ipairs( player.GetAll() ) do
		if v:GetUserGroup() ~= groups.list:GetGroupValue() then
			menu:AddOption( v:Nick() .. "  |  " .. xgui.translateGroup( v:GetUserGroup() ),
				function() groups.changeUserGroup( v:SteamID(), groups.list:GetGroupValue() ) end )
		end
	end
	menu:AddSpacer()
	for ID, v in pairs( xgui.data.users ) do
		if v.group ~= groups.list:GetGroupValue() and not groups.isOnline( ID ) then
			menu:AddOption( ( v.name or ID ) .. "  |  " .. xgui.translateGroup( v.group or "<无>" ),
				function() groups.changeUserGroup( ID, groups.list:GetGroupValue() ) end )
		end
	end
	menu:AddSpacer()
	menu:AddOption( xgui.T("groups_add_by_id"), function() groups.addBySteamID( groups.list:GetGroupValue() ) end )
	menu:Open()
end

groups.cplayer = xlib.makebutton{ x=85, y=210, w=80, label=xgui.T("groups_change"), disabled=true, parent=groups.pnlG1 }
groups.cplayer.DoClick = function()
	local checked = groups.players:getCheckedPlayers()
	if #checked > 0 then
		local ID = checked[1]:SteamID()
		local menu = DermaMenu()
		menu:SetSkin( xgui.settings.skin )
		local sortedGroups = groups.getSortedGroupList()
		for _, v in ipairs( sortedGroups ) do
			if v ~= "user" and v ~= groups.list:GetGroupValue() then
				menu:AddOption( v, function() groups.changeUserGroup( ID, v ) end )
			end
		end
		menu:AddSpacer()
		menu:AddOption( xgui.T("groups_remove_user"), function() groups.changeUserGroup( ID, "user" ) end )
		menu:Open()
	end
end

groups.lblTeam = xlib.makelabel{ x=5, y=240, label=xgui.T("groups_team"), parent=groups.pnlG1 }
groups.teams = xlib.makecombobox{ x=5, y=255, w=160, disabled=not ulx.uteamEnabled(), parent=groups.pnlG1 }
groups.teams.OnSelect = function( self, index, value, data )
	if value == xgui.T("group_none") then value = "" end
	RunConsoleCommand( "xgui", "changeGroupTeam", groups.list:GetGroupValue(), value )
end

groups.teambutton = xlib.makebutton{ x=5, y=275, w=160, label=xgui.T("groups_manage_teams"), disabled=not ulx.uteamEnabled(), parent=groups.pnlG1 }
groups.teambutton.DoClick = function( self )
	if not groups.pnlG3:IsVisible() then
		self:SetText( xgui.T("groups_manage_teams_close") )
		groups.pnlG3:Open()
	else
		self:SetText( xgui.T("groups_manage_teams") )
		groups.pnlG3:Close()
	end
end

groups.accessbutton = xlib.makebutton{ x=5, y=305, w=160, label=xgui.T("groups_manage_perms"), parent=groups.pnlG1 }
groups.accessbutton.DoClick = function( self )
	if not groups.pnlG4:IsVisible() then
		self:SetText( xgui.T("groups_manage_perms_close") )
		groups.pnlG4:Open()
	else
		self:SetText( xgui.T("groups_manage_perms") )
		groups.pnlG4:Close()
	end
end

function groups.addBySteamID( group )
	local frame = xlib.makeframe{ label=xgui.T("groups_add_to") .. " " .. group, w=190, h=60, skin=xgui.settings.skin }
	xlib.maketextbox{ x=5, y=30, w=180, parent=frame, selectall=true, text=xgui.T("groups_enter_steamid") }.OnEnter = function( self )
		if ULib.isValidSteamID( self:GetValue() ) then
			RunConsoleCommand( "ulx", "adduserid", self:GetValue(), group )
			frame:Remove()
		else
			Derma_Message( xgui.T("groups_invalid_steamid"), xgui.T("maps_warning_title") )
		end
	end
end

function groups.changeUserGroup( ID, group )
	if ID == "NULL" then ID = "BOT" end
	if group == "user" then
		RunConsoleCommand( "ulx", "removeuserid", ID )
	else
		RunConsoleCommand( "ulx", "adduserid", ID, group )
	end
end

function groups.isOnline( steamID )
	for _, v in ipairs( player.GetAll() ) do
		if v:SteamID() == steamID then return true end
	end
	return false
end

-- Panel G2 - 用户组管理
-- 获取排序后的用户组名列表（从 ULib.ucl.groups 提取）
function groups.getSortedGroupList()
	local sorted = {}
	for gName, _ in pairs( ULib.ucl.groups ) do table.insert( sorted, gName ) end
	table.sort( sorted, function(a,b)
		local order = { user=0, operator=1, admin=2, superadmin=3 }
		local oa = order[a] or 99; local ob = order[b] or 99
		if oa ~= ob then return oa < ob end
		return a < b
	end )
	return sorted
end

groups.pnlG2 = xlib.makepanel{ w=350, h=200, parent=groups.clippanela }
groups.pnlG2:SetVisible( false )
function groups.pnlG2:Open()
	if groups.pnlG1:IsVisible() then groups.pnlG1:Close() end
	self:SetVisible( true )
end
function groups.pnlG2:Close()
	self:SetVisible( false )
end

groups.glist = xlib.makelistview{ x=5, y=5, h=170, w=130, headerheight=0, parent=groups.pnlG2 }
groups.glist:AddColumn( xgui.T("ui_user_group") )
groups.glist.populate = function( self )
	local previous_group = nil
	local prev_inherit = groups.ginherit:GetValue()
	if groups.glist:GetSelectedLine() then
		local sel = groups.glist:GetSelected()[1]
		previous_group = sel.originalGroup or sel:GetColumnText(1)
	end
	self:Clear()
	groups.ginherit:Clear()
	groups.ginherit:SetText( prev_inherit )
	local sortedGroups = groups.getSortedGroupList()
	for _, v in ipairs( sortedGroups ) do
		local l = self:AddLine( xgui.translateGroup( v ) )
		l.originalGroup = v
		groups.ginherit:AddChoice( v )
		if v == previous_group then
			previous_group = true
			self:SelectItem( l )
		end
	end
	if previous_group and previous_group ~= true then
		groups.gname:SetText( xgui.T("groups_new_group") )
		groups.ginherit:SetText( "user" )
		groups.gcantarget:SetText( "" )
		groups.glist:ClearSelection()
		groups.gdelete:SetDisabled( true )
		groups.gupdate:SetDisabled( true )
		groups.newgroup:SetDisabled( false )
		groups.gname:SetDisabled( false )
		groups.ginherit:SetDisabled( false )
	end
end
groups.glist.OnRowSelected = function( self, LineID, Line )
	local group = Line.originalGroup or Line:GetColumnText(1)
	groups.gname:SetText( group )
	local inheritFrom = ULib.ucl.groups[group].inherit_from or "user"
	groups.ginherit:SetText( xgui.translateGroup( inheritFrom ) )
	groups.gcantarget:SetText( ULib.ucl.groups[group].can_target or "*" )
	groups.gupdate:SetDisabled( false )
	local isGroupUser = ( group == "user" )
	groups.gdelete:SetDisabled( isGroupUser )
	groups.ginherit:SetDisabled( isGroupUser )
	groups.newgroup:SetDisabled( isGroupUser )
	groups.gname:SetDisabled( isGroupUser )
end

groups.newgroup = xlib.makebutton{ x=245, y=175, w=100, label=xgui.T("groups_create"), parent=groups.pnlG2 }
groups.newgroup.DoClick = function()
	if not ULib.ucl.groups[groups.gname:GetValue()] then
		RunConsoleCommand( "ulx", "addgroup", groups.gname:GetValue(), groups.ginherit:GetValue() )
		if groups.gcantarget:GetValue() ~= "" and groups.gcantarget:GetValue() ~= "*" then
			ULib.queueFunctionCall( RunConsoleCommand, "ulx", "setgroupcantarget", groups.gname:GetValue(), groups.gcantarget:GetValue() )
		end
	else
		Derma_Message( xgui.T("groups_exists"), xgui.T("maps_warning_title") )
	end
end

groups.lblG2Name = xlib.makelabel{ x=145, y=8, label=xgui.T("groups_name_label"), parent=groups.pnlG2 }
groups.lblG2Inherit = xlib.makelabel{ x=145, y=33, label=xgui.T("groups_inherit_label"), parent=groups.pnlG2 }
groups.lblG2Target = xlib.makelabel{ x=145, y=58, label=xgui.T("groups_cantarget_label"), parent=groups.pnlG2 }
groups.gname = xlib.maketextbox{ x=180, y=5, w=165, text=xgui.T("groups_new_group"), selectall=true, parent=groups.pnlG2 }
groups.ginherit = xlib.makecombobox{ x=215, y=30, w=130, text="user", parent=groups.pnlG2 }
groups.gcantarget = xlib.maketextbox{ x=205, y=55, w=140, text="", selectall=true, parent=groups.pnlG2 }
groups.gupdate = xlib.makebutton{ x=140, y=175, w=100, disabled=true, label=xgui.T("sv_update"), parent=groups.pnlG2 }
groups.gupdate.DoClick = function( self )
	local groupname = groups.glist:GetSelected()[1]:GetColumnText(1)
	local oldinheritance = ULib.ucl.groups[groupname].inherit_from
	local newinheritance = groups.ginherit:GetValue()
	local cantarget = ULib.ucl.groups[groupname].can_target
	if newinheritance == "user" then newinheritance = nil end
	if not cantarget then cantarget = "*" end
	if groups.gname:GetValue() ~= groupname then
		if groupname == "superadmin" or groupname == "admin" then
			Derma_Query( xgui.T("groups_rename_warn") .. groupname .. xgui.T("groups_rename_warn2"),
				xgui.T("maps_warning_title"),
				xgui.T("groups_rename_confirm") .. groups.gname:GetValue(), function()
					RunConsoleCommand( "ulx", "renamegroup", groupname, groups.gname:GetValue() )
				end,
				xgui.T("maps_btn_cancel"), function() end )
			return
		end
		RunConsoleCommand( "ulx", "renamegroup", groupname, groups.gname:GetValue() )
	end
	if oldinheritance ~= newinheritance then
		RunConsoleCommand( "ulx", "addgroup", groups.gname:GetValue(), newinheritance or "user" )
	end
	if cantarget ~= groups.gcantarget:GetValue() and groups.gcantarget:GetValue() ~= "*" then
		RunConsoleCommand( "ulx", "setgroupcantarget", groups.gname:GetValue(), groups.gcantarget:GetValue() )
	end
end
groups.gdelete = xlib.makebutton{ x=350, y=175, w=45, label=xgui.T("sv_remove"), disabled=true, parent=groups.pnlG2 }
groups.gdelete.DoClick = function()
	local group = groups.glist:GetSelected()[1]:GetColumnText(1)
	Derma_Query( xgui.T("groups_remove_confirm") .. group .. "?",
		xgui.T("maps_warning_title"),
		xgui.T("sv_remove"), function() RunConsoleCommand( "ulx", "removegroup", group ) end,
		xgui.T("maps_btn_cancel"), function() end )
end

-- ===== G3: 团队管理面板 =====
groups.pnlG3 = xlib.makepanel{ w=200, h=335, parent=groups.clippanelc }
groups.pnlG3:SetVisible( false )
function groups.pnlG3:Open()
	self:SetVisible( true )
	groups.refreshTeamPanel()
end
function groups.pnlG3:Close()
	self:SetVisible( false )
end

xlib.makelabel{ x=5, y=0, label=xgui.T("groups_manage_teams"), parent=groups.pnlG3 }
groups.teamList = xlib.makelistview{ x=5, y=20, w=190, h=180, headerheight=0, parent=groups.pnlG3 }
groups.teamList:AddColumn( xgui.T("groups_team") )
groups.teamList.OnRowSelected = function( self, LineID, Line )
	groups.teamDeleteBtn:SetDisabled( false )
	-- 显示颜色预览
	if Line.teamData and Line.teamData.color then
		local c = Line.teamData.color
		groups.teamColorPicker:SetColor( type(c)=="table" and Color(c.r,c.g,c.b) or c )
	end
end

groups.teamColorPicker = xlib.makecolorpicker{ x=10, y=205, parent=groups.pnlG3 }
groups.teamColorPicker.OnChangeImmediate = function( self, color )
	local line = groups.teamList:GetSelectedLine()
	if line and groups.teamList:GetSelected()[1] then
		local team = groups.teamList:GetSelected()[1].teamData
		if team and team.name then
			RunConsoleCommand( "xgui", "updateTeamValue", team.name, "color", color.r, color.g, color.b, "true" )
		end
	end
end

groups.teamCreateBtn = xlib.makebutton{ x=5, y=310, w=90, label=xgui.T("groups_create") .. " " .. xgui.T("groups_team"), parent=groups.pnlG3 }
groups.teamCreateBtn.DoClick = function()
	local frame = xlib.makeframe{ label=xgui.T("groups_create") .. " " .. xgui.T("groups_team"), w=220, h=80, skin=xgui.settings.skin }
	xlib.makelabel{ x=5, y=30, label=xgui.T("groups_name_label") .. ":", parent=frame }
	local txtName = xlib.maketextbox{ x=50, y=28, w=165, text="", parent=frame, selectall=true }
	txtName.OnEnter = function( self )
		local name = self:GetValue()
		if name ~= "" then
			RunConsoleCommand( "xgui", "createTeam", name, "100", "200", "255" )
			frame:Remove()
		end
	end
end

groups.teamDeleteBtn = xlib.makebutton{ x=100, y=310, w=95, label=xgui.T("sv_remove") .. " " .. xgui.T("groups_team"), disabled=true, parent=groups.pnlG3 }
groups.teamDeleteBtn.DoClick = function()
	local line = groups.teamList:GetSelectedLine()
	if line and groups.teamList:GetSelected()[1] then
		local team = groups.teamList:GetSelected()[1].teamData
		if team and team.name then
			Derma_Query( xgui.T("groups_remove_confirm") .. team.name .. "?",
				xgui.T("maps_warning_title"),
				xgui.T("sv_remove"), function() RunConsoleCommand( "xgui", "removeTeam", team.name ) end,
				xgui.T("maps_btn_cancel"), function() end )
		end
	end
end

function groups.refreshTeamPanel()
	if not groups.pnlG3:IsVisible() then return end
	groups.teamList:Clear()
	groups.teamDeleteBtn:SetDisabled( true )
	if not xgui.data.teams then return end
	for _, team in ipairs( xgui.data.teams ) do
		local l = groups.teamList:AddLine( team.name )
		l.teamData = team
	end
end

-- ===== G4: 权限管理面板 =====
groups.pnlG4 = xlib.makepanel{ w=200, h=335, parent=groups.clippanelc }
groups.pnlG4:SetVisible( false )
function groups.pnlG4:Open()
	self:SetVisible( true )
	groups.refreshAccessPanel()
end
function groups.pnlG4:Close()
	self:SetVisible( false )
end

xlib.makelabel{ x=5, y=0, label=xgui.T("groups_manage_perms"), parent=groups.pnlG4 }

groups.accessTree = xlib.maketree{ x=5, y=20, w=190, h=260, parent=groups.pnlG4 }
groups.accessTree.DoClick = function( self, node )
	if node.accessName then
		groups.accessAddBtn:SetDisabled( false )
		groups.accessRemoveBtn:SetDisabled( false )
	end
end

groups.accessAddBtn = xlib.makebutton{ x=5, y=285, w=90, label=xgui.T("ui_add") .. " " .. xgui.T("groups_manage_perms"), disabled=true, parent=groups.pnlG4 }
groups.accessAddBtn.DoClick = function()
	local node = groups.accessTree:GetSelectedItem()
	if not node or not node.accessName then return end
	if groups.lastOpenGroup then
		RunConsoleCommand( "ulx", "userallowid", groups.lastOpenGroup, node.accessName )
		-- 暂不支持按 ID 操作，使用 groupallow
		RunConsoleCommand( "ulx", "groupallow", groups.lastOpenGroup, node.accessName )
	end
end

groups.accessRemoveBtn = xlib.makebutton{ x=100, y=285, w=95, label=xgui.T("sv_remove") .. " " .. xgui.T("groups_manage_perms"), disabled=true, parent=groups.pnlG4 }
groups.accessRemoveBtn.DoClick = function()
	local node = groups.accessTree:GetSelectedItem()
	if not node or not node.accessName then return end
	if groups.lastOpenGroup then
		RunConsoleCommand( "ulx", "groupdeny", groups.lastOpenGroup, node.accessName )
	end
end

groups.accessRefreshBtn = xlib.makebutton{ x=5, y=308, w=190, label=xgui.T("ui_refresh_data"), parent=groups.pnlG4 }
groups.accessRefreshBtn.DoClick = function() groups.refreshAccessPanel() end

function groups.refreshAccessPanel()
	if not groups.pnlG4:IsVisible() then return end
	groups.accessTree:Clear()
	groups.accessAddBtn:SetDisabled( true )
	groups.accessRemoveBtn:SetDisabled( true )
	if not xgui.data.accesses then return end
	-- 按分类组织权限
	local categories = {}
	for accessName, accessData in pairs( xgui.data.accesses ) do
		local cat = accessData.category or "Other"
		if not categories[cat] then categories[cat] = {} end
		table.insert( categories[cat], accessName )
	end
	local sortedCats = {}
	for cat, _ in pairs( categories ) do table.insert( sortedCats, cat ) end
	table.sort( sortedCats )
	for _, cat in ipairs( sortedCats ) do
		local folder = groups.accessTree:AddNode( cat, "icon16/folder.png" )
		table.sort( categories[cat] )
		for _, accessName in ipairs( categories[cat] ) do
			local node = folder:AddNode( accessName, "icon16/key.png" )
			node.accessName = accessName
			-- 检查当前用户组是否已有此权限
			if groups.lastOpenGroup and ULib.ucl.groups[groups.lastOpenGroup] then
				local gInfo = ULib.ucl.groups[groups.lastOpenGroup]
				if table.HasValue( gInfo.allow, accessName ) then
					node:SetIcon( "icon16/accept.png" )
				end
			end
		end
	end
end

-- ===== 数据刷新函数 =====
function groups.refreshPlayers( groupName )
	if not groupName then return end
	groups.playersScroll:Clear()
	for _, ply in ipairs( player.GetAll() ) do
		if ply:GetUserGroup() == groupName then
			local row = xlib.makepanel{ dock=TOP, dockmargin={2,0,2,0}, h=18, parent=groups.playersScroll }
			local cb = xlib.makecheckbox{ x=2, y=1, w=16, h=16, label="", parent=row }
			cb.ply = ply
			cb.OnChange = function( self, bVal )
				groups.cplayer:SetDisabled( not groups.players:_hasAnyChecked() )
			end
			local lbl = xlib.makelabel{ x=22, y=0, label=ply:Nick() .. "  |  " .. xgui.translateGroup(ply:GetUserGroup()), parent=row }
		end
	end
	for steamID, userData in pairs( xgui.data.users ) do
		if userData.group == groupName and not groups.isOnline( steamID ) then
			local row = xlib.makepanel{ dock=TOP, dockmargin={2,0,2,0}, h=18, parent=groups.playersScroll }
			local cb = xlib.makecheckbox{ x=2, y=1, w=16, h=16, label="", parent=row }
			local lbl = xlib.makelabel{ x=22, y=0, label=( userData.name or steamID ), parent=row }
		end
	end
	groups.cplayer:SetDisabled( true )
end

function groups.refreshTeamsCombo()
	if not ulx.uteamEnabled() then
		groups.teams:SetDisabled( true )
		return
	end
	groups.teams:SetDisabled( false )
	local prev_val = groups.teams:GetValue()
	local noTeam = xgui.T("group_none")
	groups.teams:Clear()
	groups.teams:AddChoice( noTeam )
	if xgui.data.teams then
		for _, team in ipairs( xgui.data.teams ) do
			groups.teams:AddChoice( team.name )
		end
	end
	groups.teams:SetText( prev_val ~= "" and prev_val or noTeam )
end

function groups.updateTeamSelection( groupName )
	if not groupName then
		groups.teams:SetText( xgui.T("group_none") )
		return
	end
	if xgui.data.teams then
		for _, team in ipairs( xgui.data.teams ) do
			if team.groups then
				for _, g in ipairs( team.groups ) do
					if g == groupName then
						groups.teams:SetText( team.name )
						return
					end
				end
			end
		end
	end
	groups.teams:SetText( xgui.T("group_none") )
end

-- 数据事件钩子：使用 onProcessModules (ULib.ucl.groups 已通过 UCL 同步)
xgui.hookEvent( "onProcessModules", nil, function()
	groups.list:populate()
	groups.refreshTeamsCombo()
	if groups.pnlG2:IsVisible() then
		groups.glist:populate()
	end
	if groups.pnlG4:IsVisible() then
		groups.refreshAccessPanel()
	end
end, "groupsRefreshUI" )
xgui.hookEvent( "users", "process", function()
	if groups.lastOpenGroup and groups.pnlG1:IsVisible() then
		groups.refreshPlayers( groups.lastOpenGroup )
	end
end, "usersRefreshUI" )
xgui.hookEvent( "teams", "process", function()
	groups.refreshTeamsCombo()
	groups.refreshTeamPanel()
end, "teamsRefreshUI" )

-- 语言刷新：仅更新静态标签文本（不重建下拉框/列表数据）
xgui.registerRefresh( "groups", function()
	-- G1 标签
	groups.lblPlayersIn:SetText( xgui.T("groups_players_in") )
	groups.lblTeam:SetText( xgui.T("groups_team") )
	if groups.players and groups.players.Columns then
		local c = groups.players.Columns[1]; if c and c.Header then c.Header:SetText( xgui.T("ui_player_name") ) end
	end
	groups.aplayer:SetText( xgui.T("ui_add") .. "..." )
	groups.cplayer:SetText( xgui.T("groups_change") )
	if groups.teambutton then groups.teambutton:SetText( xgui.T("groups_manage_teams") ) end
	if groups.accessbutton then groups.accessbutton:SetText( xgui.T("groups_manage_perms") ) end
	-- 重建用户组选择框选项（保留选中值）
	if groups.list then groups.list:populate() end
	-- G2 标签
	groups.lblG2Name:SetText( xgui.T("groups_name_label") )
	groups.lblG2Inherit:SetText( xgui.T("groups_inherit_label") )
	groups.lblG2Target:SetText( xgui.T("groups_cantarget_label") )
	groups.newgroup:SetText( xgui.T("groups_create") )
	groups.gupdate:SetText( xgui.T("sv_update") )
	groups.gdelete:SetText( xgui.T("sv_remove") )
	-- G3 标签 (团队管理)
	if groups.teamCreateBtn then groups.teamCreateBtn:SetText( xgui.T("groups_create") .. " " .. xgui.T("groups_team") ) end
	if groups.teamDeleteBtn then groups.teamDeleteBtn:SetText( xgui.T("sv_remove") .. " " .. xgui.T("groups_team") ) end
	-- G4 标签 (权限管理)
	if groups.accessAddBtn then groups.accessAddBtn:SetText( xgui.T("ui_add") .. " " .. xgui.T("groups_manage_perms") ) end
	if groups.accessRemoveBtn then groups.accessRemoveBtn:SetText( xgui.T("sv_remove") .. " " .. xgui.T("groups_manage_perms") ) end
	if groups.accessRefreshBtn then groups.accessRefreshBtn:SetText( xgui.T("ui_refresh_data") ) end
	-- 语言切换时实时刷新玩家列表中的用户组名称
	if groups.lastOpenGroup and groups.pnlG1:IsVisible() then
		groups.refreshPlayers( groups.lastOpenGroup )
	end
end )

xgui.addModule( "groups", groups, "icon16/group.png", "xgui_managegroups" )
