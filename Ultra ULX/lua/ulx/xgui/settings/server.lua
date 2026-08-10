local server = xlib.makepanel{ parent=xgui.null }
local T = ULib.ulx_lang.T
local sidepanel = xlib.makescrollpanel{ x=5, y=5, w=140, h=322, spacing=4, parent=server }
server.sideLabels = {}
local function addSideLabel( textKey )
	local lbl = xlib.makelabel{ dock=TOP, dockmargin={0,0,0,0}, label=T(textKey), parent=sidepanel }
	table.insert( server.sideLabels, { panel=lbl, key=textKey } )
	return lbl
end
local function addSideLabelM( textKey, marginTop )
	local lbl = xlib.makelabel{ dock=TOP, dockmargin={0,marginTop or 5,0,0}, label=T(textKey), parent=sidepanel }
	table.insert( server.sideLabels, { panel=lbl, key=textKey } )
	return lbl
end
local function addSideCheckbox( textKey, convar, repconvar, marginTop )
	local cb = xlib.makecheckbox{ dock=TOP, dockmargin={0,marginTop or 5,0,0}, label=T(textKey), convar=convar, repconvar=repconvar, parent=sidepanel }
	table.insert( server.sideLabels, { panel=cb, key=textKey } )
	return cb
end
addSideLabel("sv_alltalk")
server.alltalkCombo = xlib.makecombobox{ dock=TOP, dockmargin={0,2,0,0}, w=140, repconvar="rep_sv_alltalk", isNumberConvar=true, choices={ T("sv_alltalk_local"), T("sv_alltalk_team"), T("sv_alltalk_near"), T("sv_alltalk_all") }, parent=sidepanel }
addSideLabelM("sv_server_language", 20)
server.langCombo = xlib.makecombobox{ dock=TOP, dockmargin={0,2,0,0}, w=140, repconvar="ulx_language", choices={ "简体中文", "English", "Русский", "文言文" }, parent=sidepanel }
addSideCheckbox("sv_voice", xlib.ifListenHost("sv_voiceenable"), xlib.ifNotListenHost("rep_sv_voiceenable"))
addSideCheckbox("sv_ai_disable", xlib.ifListenHost("ai_disabled"), xlib.ifNotListenHost("rep_ai_disabled"), 20)
addSideCheckbox("sv_ai_ignore", xlib.ifListenHost("ai_ignoreplayers"), xlib.ifNotListenHost("rep_ai_ignoreplayers"))
addSideCheckbox("sv_keep_corpses", xlib.ifListenHost("ai_serverragdolls"), xlib.ifNotListenHost("rep_ai_serverragdolls"))
addSideCheckbox("sv_stick_ground", xlib.ifListenHost("sv_sticktoground"), xlib.ifNotListenHost("rep_sv_sticktoground"), 20)
addSideCheckbox("sv_pickup", xlib.ifListenHost("sv_playerpickupallowed"), xlib.ifNotListenHost("rep_sv_playerpickupallowed"))
addSideCheckbox("sv_fall_damage", xlib.ifListenHost("mp_falldamage"), xlib.ifNotListenHost("rep_mp_falldamage"))
addSideCheckbox("sv_hev_suit", xlib.ifListenHost("gmod_suit"), xlib.ifNotListenHost("rep_gmod_suit"))
addSideLabelM("sv_gravity")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=-1000, max=1000, convar=xlib.ifListenHost("sv_gravity"), repconvar=xlib.ifNotListenHost("rep_sv_gravity"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_friction")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=16, convar=xlib.ifListenHost("sv_friction"), repconvar=xlib.ifNotListenHost("rep_sv_friction"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_phys_timescale")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=4, decimal=2, convar=xlib.ifListenHost("phys_timescale"), repconvar=xlib.ifNotListenHost("rep_phys_timescale"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_deploy_speed")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0.1, max=10, decimal=2, convar=xlib.ifListenHost("sv_defaultdeployspeed"), repconvar=xlib.ifNotListenHost("rep_sv_defaultdeployspeed"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_noclip_speed")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=1, max=10, convar=xlib.ifListenHost("sv_noclipspeed"), repconvar=xlib.ifNotListenHost("rep_sv_noclipspeed"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_max_ammo")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=9999, convar=xlib.ifListenHost("gmod_maxammo"), repconvar=xlib.ifNotListenHost("rep_gmod_maxammo"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_phys_iter")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=0, max=10, convar=xlib.ifListenHost("gmod_physiterations"), repconvar=xlib.ifNotListenHost("rep_gmod_physiterations"), parent=sidepanel, fixclip=true }
addSideLabelM("sv_timeout")
xlib.makeslider{ dock=TOP, dockmargin={0,2,5,0}, label="<--->", w=125, min=60, max=300, convar=xlib.ifListenHost("sv_timeout"), repconvar=xlib.ifNotListenHost("rep_sv_timeout"), parent=sidepanel, fixclip=true }
server.mask = xlib.makepanel{ x=300, y=5, w=285, h=322, parent=server }
server.panel = xlib.makepanel{ x=5, w=285, h=322, parent=server.mask }
server.catList = xlib.makelistview{ x=150, y=5, w=150, h=322, parent=server }
server.catList:AddColumn( T("set_server_settings") )
server.catList.Columns[1].DoClick = function() end
server.catList.OnRowSelected = function( self, LineID, Line )
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
	if nPanel ~= server.curPanel then
		if server.curPanel then
			local temppanel = server.curPanel
			xlib.addToAnimQueue( "pnlSlide", { panel=server.panel, startx=5, starty=0, endx=-285, endy=0, setvisible=false } )
			xlib.addToAnimQueue( function()	temppanel:SetVisible( false ) end )
		end
		server.curPanel = nPanel
		xlib.addToAnimQueue( function() nPanel:SetVisible( true ) end )
		if nPanel.onOpen then xlib.addToAnimQueue( nPanel.onOpen ) end
		xlib.addToAnimQueue( "pnlSlide", { panel=server.panel, startx=-285, starty=0, endx=5, endy=0, setvisible=true } )
	else
		server.curPanel = nil
		self:ClearSelection()
		xlib.addToAnimQueue( "pnlSlide", { panel=server.panel, startx=5, starty=0, endx=-285, endy=0, setvisible=false } )
		xlib.addToAnimQueue( function() nPanel:SetVisible( false ) end )
	end
	xlib.animQueue_start()
end
function xgui.openServerModule( name )
	name = string.lower( name )
	for i = 1, #xgui.modules.submodule do
		local module = xgui.modules.submodule[i]
		if module.mtype == "server" and string.lower(module.name) == name then
			if module.panel ~= server.curPanel then
				server.catList:ClearSelection()
				for i=1, #server.catList.Lines do
					local line = server.catList.Lines[i]
					if string.lower(line:GetColumnText(1)) == name then
						server.catList:SelectItem( line )
						break
					end
				end
			end
			break
		end
	end
end
function server.processModules()
	local TL = ULib.ulx_lang.T
	server.catList.Columns[1].Header:SetText( TL("set_server_settings") )
	server.catList:Clear()
	for i, module in ipairs( xgui.modules.submodule ) do
		if module.mtype == "server" and ( not module.access or LocalPlayer():query( module.access ) ) then
			local w,h = module.panel:GetSize()
			if w == h and h == 0 then module.panel:SetSize( 275, 322 ) end
			if module.panel.scroll then
				module.panel.scroll.panel = module.panel
				module.panel = module.panel.scroll
			end
			module.panel:SetParent( server.panel )
			local line = server.catList:AddLine( module.displayName, i )
			if ( module.panel == server.curPanel ) then
				server.curPanel = nil
				server.catList:SelectItem( line )
			else
				module.panel:SetVisible( false )
			end
		end
	end
	server.catList:SortByColumn( 1, false )
end
server.processModules()
xgui.hookEvent( "onProcessModules", nil, server.processModules, "serverSettingsProcessModules" )
xgui.registerRefresh( "server_settings", function()
	xgui.refreshLabels( server.sideLabels )
	if server.langCombo then
		local prevId = server.langCombo:GetSelectedID()
		server.langCombo:Clear()
		local langChoices = { xgui.T("lang_zhcn"), xgui.T("lang_en"), xgui.T("lang_ru"), xgui.T("lang_lzh") }
		for _, v in ipairs( langChoices ) do server.langCombo:AddChoice( v ) end
		if prevId and prevId <= #langChoices then server.langCombo:ChooseOptionID( prevId ) end
	end
	if server.alltalkCombo then
		local prevId = server.alltalkCombo:GetSelectedID()
		server.alltalkCombo:Clear()
		local talkChoices = { xgui.T("sv_alltalk_local"), xgui.T("sv_alltalk_team"), xgui.T("sv_alltalk_near"), xgui.T("sv_alltalk_all") }
		for _, v in ipairs( talkChoices ) do server.alltalkCombo:AddChoice( v ) end
		if prevId and prevId <= #talkChoices then server.alltalkCombo:ChooseOptionID( prevId ) end
	end
	server.catList.Columns[1].Header:SetText( xgui.T("set_server_settings") )
	for _, line in ipairs( server.catList.Lines ) do
		local modIdx = tonumber( line:GetColumnText(2) )
		if modIdx and xgui.modules.submodule[modIdx] then
			line:SetColumnText( 1, xgui.modules.submodule[modIdx].displayName )
		end
	end
end )
xgui.addSettingModule( "server", server, "icon16/server.png", "xgui_svsettings" )
local Tsv = ULib.ulx_lang.T
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_admin_votemap") } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_ratio") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=1, decimal=2, repconvar="ulx_votemap2Successratio" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_min_votes") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=10, repconvar="ulx_votemap2Minvotes" } )
xgui.addSubModule( "adminvotemap", plist, nil, "server" )
xgui.prepareDataType( "adverts" )
local adverts = xlib.makepanel{ parent=xgui.null }
adverts.tree = xlib.maketree{ w=120, h=296, parent=adverts }
adverts.tree.DoClick = function( self, node )
	adverts.removebutton:SetDisabled( false )
	adverts.updatebutton:SetDisabled( not node.data )
	adverts.nodeup:SetDisabled( not node.data or type( node.group ) == "number" )
	adverts.nodedown:SetDisabled( not node.data or not type( node.group ) == "number" or adverts.isBottomNode( node ) )
	adverts.group:SetText( type(node.group) ~= "number" and node.group or Tsv("sv_no_group") )
	if node.data then
		adverts.message:SetText( node.data.message )
		adverts.time:SetValue( node.data.rpt )
		adverts.color:SetColor( node.data.color )
		adverts.csay:SetOpen( node.data.len )
		adverts.csay:InvalidateLayout()
		adverts.display:SetValue( node.data.len or 10 )
	end
end
function adverts.isBottomNode( node )
	local parentnode = node:GetParentNode()
	local parentchildren = parentnode.ChildNodes:GetChildren()
	if parentnode:GetParentNode().ChildNodes then
		local parentparentchildren = parentnode:GetParentNode().ChildNodes:GetChildren()
		return parentchildren[#parentchildren] == node and parentparentchildren[#parentparentchildren] == parentnode
	else
		return not adverts.hasGroups or parentchildren[#parentchildren] == node
	end
end
function adverts.getNodePos( node )
	if type( node.group ) == "number" then return 1 end
	local parentchildren = node:GetParentNode().ChildNodes:GetChildren()
	local output = 0
	if parentchildren[#parentchildren] == node then output = 1 end
	if parentchildren[1] == node then output = output + 2 end
	return output
end
adverts.tree.DoRightClick = function( self, node )
	self:SetSelectedItem( node )
	local menu = DermaMenu()
	menu:SetSkin(xgui.settings.skin)
	if not node.data then
		menu:AddOption( Tsv("sv_rename_group"), function() adverts.RenameAdvert( node:GetText() ) end )
	end
	menu:AddOption( Tsv("sv_delete"), function() adverts.removeAdvert( node ) end )
	menu:Open()
end
adverts.seloffset = 0
adverts.message = xlib.maketextbox{ x=125, w=150, h=20, text=Tsv("sv_input_msg"), parent=adverts, selectall=true }
xlib.makelabel{ x=125, y=25, label=Tsv("sv_advert_interval"), parent=adverts }
adverts.time = xlib.makeslider{ x=125, y=40, w=150, label="<--->", value=60, min=1, max=1000, tooltip=Tsv("sv_advert_interval_tip"), parent=adverts }
adverts.group = xlib.makecombobox{ x=125, y=65, w=150, enableinput=true, parent=adverts, tooltip=Tsv("sv_advert_group_tip") }
adverts.color = xlib.makecolorpicker{ x=135, y=90, parent=adverts }
local panel = xlib.makelistlayout{ w=150, h=45, spacing=4, parent=xgui.null, enablescroll=false }
panel:Add( xlib.makelabel{ label=Tsv("sv_display_duration") } )
adverts.display = xlib.makeslider{ label="<--->", min=1, max=60, value=10, tooltip=Tsv("sv_display_duration_tip") }
panel:Add( adverts.display )
adverts.csay = xlib.makecat{ x=125, y=230, w=150, label=Tsv("sv_csay_mode"), checkbox=true, contents=panel, parent=adverts, expanded=false }
xlib.makebutton{ x=200, y=302, w=75, label=Tsv("sv_create"), parent=adverts }.DoClick = function()
	local col = adverts.color:GetColor()
	local rpt = tonumber( adverts.time:GetValue() )
	RunConsoleCommand( "xgui", "addAdvert", adverts.message:GetValue(), ( rpt < 0.1 ) and 0.1 or rpt, adverts.group:GetValue(), col.r, col.g, col.b, adverts.csay:GetExpanded() and adverts.display:GetValue() or nil)
end
adverts.removebutton = xlib.makebutton{ y=302, w=75, label=Tsv("sv_remove"), disabled=true, parent=adverts }
adverts.removebutton.DoClick = function( node )
	adverts.removeAdvert( adverts.tree:GetSelectedItem() )
end
adverts.updatebutton = xlib.makebutton{ x=125, y=302, w=75, label=Tsv("sv_update"), parent=adverts, disabled=true }
adverts.updatebutton.DoClick = function( node )
	local node = adverts.tree:GetSelectedItem()
	local col = adverts.color:GetColor()
	if ((( type( node.group ) == "number" ) and Tsv("sv_no_group") or node.group ) == adverts.group:GetValue() ) then
		RunConsoleCommand( "xgui", "updateAdvert", type( node.group ), node.group, node.number, adverts.message:GetValue(), ( adverts.time:GetValue() < 0.1 ) and 0.1 or adverts.time:GetValue(), col.r, col.g, col.b, adverts.csay:GetExpanded() and adverts.display:GetValue() or nil )
	else
		RunConsoleCommand( "xgui", "removeAdvert", node.group, node.number, type( node.group ), "hold" )
		RunConsoleCommand( "xgui", "addAdvert", adverts.message:GetValue(), ( adverts.time:GetValue() < 0.1 ) and 0.1 or adverts.time:GetValue(), adverts.group:GetValue(), col.r, col.g, col.b, adverts.csay:GetExpanded() and adverts.display:GetValue() or nil)
		adverts.selnewgroup = adverts.group:GetValue()
		if xgui.data.adverts[adverts.group:GetValue()] then
			adverts.seloffset = #xgui.data.adverts[adverts.group:GetValue()]+1
		else
			adverts.seloffset = 1
		end
	end
end
adverts.nodeup = xlib.makebutton{ x=80, y=302, w=20, icon="icon16/bullet_arrow_up.png", centericon=true, parent=adverts, disabled=true }
adverts.nodeup.DoClick = function()
	adverts.nodedown:SetDisabled( true )
	adverts.nodeup:SetDisabled( true )
	local node = adverts.tree:GetSelectedItem()
	local state = adverts.getNodePos( node )
	if state <= 1 then
		RunConsoleCommand( "xgui", "moveAdvert", type( node.group ), node.group, node.number, node.number-1 )
		adverts.seloffset = adverts.seloffset - 1
	else
		local parentnode = node:GetParentNode()
		local parentparentchildren = parentnode:GetParentNode().ChildNodes:GetChildren()
		local newgroup = "<无组>"
		for i,v in ipairs( parentparentchildren ) do
			if v == parentnode then
				if parentparentchildren[i-1] and type( parentparentchildren[i-1].group ) ~= "number" then
					newgroup = parentparentchildren[i-1].group
					adverts.selnewgroup = newgroup
					adverts.seloffset = #xgui.data.adverts[newgroup]+1
				end
				break
			end
		end
		RunConsoleCommand( "xgui", "removeAdvert", node.group, node.number, type( node.group ), "hold" )
		RunConsoleCommand( "xgui", "addAdvert", node.data.message, node.data.rpt, newgroup, node.data.color.r, node.data.color.g, node.data.color.b, node.data.len)
		if newgroup == "<无组>" then
			adverts.selnewgroup = #xgui.data.adverts+1
			adverts.seloffset = 1
		end
	end
end
adverts.nodedown = xlib.makebutton{ x=100, y=302, w=20, icon="icon16/bullet_arrow_down.png", centericon=true, parent=adverts, disabled=true }
adverts.nodedown.DoClick = function()
	adverts.nodedown:SetDisabled( true )
	adverts.nodeup:SetDisabled( true )
	local node = adverts.tree:GetSelectedItem()
	local state = adverts.getNodePos( node )
	if state == 1 or state == 3 then
		local parentnode = type( node.group ) == "string" and node:GetParentNode() or node
		local parentchildren = parentnode:GetParentNode().ChildNodes:GetChildren()
		local newgroup = "<无组>"
		for index,v in ipairs( parentchildren ) do
			if v == parentnode then
				local temp = 1
				while( type( parentchildren[index+temp].group ) == "number" ) do
					temp = temp + 1
				end
				if type( parentchildren[index+temp].group ) ~= "number" then
					newgroup = parentchildren[index+temp].group
					adverts.selnewgroup = newgroup
					adverts.seloffset = 1
				end
				break
			end
		end
		RunConsoleCommand( "xgui", "removeAdvert", node.group, node.number, type( node.group ), "hold" )
		RunConsoleCommand( "xgui", "addAdvert", node.data.message, node.data.rpt, newgroup, node.data.color.r, node.data.color.g, node.data.color.b, node.data.len or "", "hold" )
		RunConsoleCommand( "xgui", "moveAdvert", type( newgroup ), newgroup, #xgui.data.adverts[newgroup]+1, 1 )
	else
		RunConsoleCommand( "xgui", "moveAdvert", type( node.group ), node.group, node.number, node.number+1 )
		adverts.seloffset = adverts.seloffset + 1
	end
end
function adverts.removeAdvert( node )
	if node then
		Derma_Query( Tsv("sv_confirm_delete") .. ( node.data and Tsv("sv_advert_single") or Tsv("sv_advert_group") ), Tsv("maps_warning_title"),
		Tsv("sv_delete"), function()
			if node.data then
				RunConsoleCommand( "xgui", "removeAdvert", node.group, node.number, type( node.group ) )
			else
				RunConsoleCommand( "xgui", "removeAdvertGroup", node.group, type( node.group ) )
			end
			adverts.tree:SetSelectedItem( nil )
		end, Tsv("maps_btn_cancel"), function() end )
	end
end
function adverts.RenameAdvert( old )
	local advertRename = xlib.makeframe{ label=Tsv("sv_rename_advert_group") .. " - " .. old, w=400, h=80, showclose=true, skin=xgui.settings.skin }
	advertRename.text = xlib.maketextbox{ x=10, y=30, w=380, h=20, text=old, parent=advertRename }
	advertRename.text.OnEnter = function( self )
		RunConsoleCommand( "xgui", "renameAdvertGroup", old, self:GetValue() )
		advertRename:Remove()
	end
	xlib.makebutton{ x=175, y=55, w=50, label=Tsv("ui_ok"), parent=advertRename }.DoClick = function()
		advertRename.text:OnEnter()
	end
end
function adverts.updateAdverts()
	adverts.updatebutton:SetDisabled( true )
	adverts.nodeup:SetDisabled( true )
	adverts.nodedown:SetDisabled( true )
	adverts.removebutton:SetDisabled( true )
	local lastNode = adverts.tree:GetSelectedItem()
	if adverts.selnewgroup then
		lastNode.group = adverts.selnewgroup
		lastNode.number = adverts.seloffset
		adverts.selnewgroup = nil
		adverts.seloffset = 0
	end
	local groupStates = {}
	if adverts.tree.RootNode.ChildNodes then
		for _, node in ipairs( adverts.tree.RootNode.ChildNodes:GetChildren() ) do
			if node.m_bExpanded then
				groupStates[node:GetText()] = true
			end
		end
	end
	adverts.hasGroups = false
	adverts.tree:Clear()
	adverts.group:Clear()
	adverts.group:AddChoice( Tsv("sv_no_group") )
	adverts.group:ChooseOptionID( 1 )
	local sortGroups = {}
	local sortSingle = {}
	for group, advertgroup in pairs( xgui.data.adverts ) do
		if type( group ) == "string" then
			table.insert( sortGroups, group )
		else
			table.insert( sortSingle, { group=group, message=advertgroup[1].message } )
		end
	end
	table.sort( sortSingle, function(a,b) return string.lower( a.message ) < string.lower( b.message ) end )
	table.sort( sortGroups, function(a,b) return string.lower( a ) < string.lower( b ) end )
	for _, advert in ipairs( sortSingle ) do
		adverts.createNode( adverts.tree, xgui.data.adverts[advert.group][1], advert.group, 1, xgui.data.adverts[advert.group][1].message, lastNode )
	end
	for _, group in ipairs( sortGroups ) do
		local advertgroup = xgui.data.adverts[group]
		adverts.hasGroups = true
		local foldernode = adverts.tree:AddNode( group, "icon16/folder.png" )
		adverts.group:AddChoice( group )
		foldernode.group = group
		if lastNode and not lastNode.data and lastNode:GetValue() == group then
			adverts.tree:SetSelectedItem( foldernode )
			adverts.removebutton:SetDisabled( false )
		end
		for advert, data in ipairs( advertgroup ) do
			adverts.createNode( foldernode, data, group, advert, data.message, lastNode )
		end
		if groupStates[group] then foldernode:SetExpanded( true, true ) end
	end
	adverts.tree:InvalidateLayout()
	local node = adverts.tree:GetSelectedItem()
	if node then
		if adverts.seloffset ~= 0 then
			for i,v in ipairs( node:GetParentNode().ChildNodes:GetChildren() ) do
				if v == node then
					node = node:GetParentNode().ChildNodes:GetChildren()[i+adverts.seloffset]
					adverts.tree:SetSelectedItem( node )
					break
				end
			end
			adverts.seloffset = 0
		end
		if adverts.isBottomNode( node ) then adverts.nodedown:SetDisabled( true ) end
		adverts.nodeup:SetDisabled( type( node.group ) == "number" )
	end
end
function adverts.createNode( parent, data, group, number, message, lastNode )
	local node = parent:AddNode( message, data.len and "icon16/style.png" or "icon16/text_smallcaps.png" )
	node.data = data
	node.group = group
	node.number = number
	node:SetTooltip( xlib.wordWrap( message, 250, "Default" ) )
	if lastNode and lastNode.data then
		if lastNode.group == group and lastNode.number == number then
			adverts.tree:SetSelectedItem( node )
			adverts.group:SetText( type(node.group) ~= "number" and node.group or Tsv("sv_no_group") )
			adverts.updatebutton:SetDisabled( false )
			adverts.nodeup:SetDisabled( false )
			adverts.nodedown:SetDisabled( false )
			adverts.removebutton:SetDisabled( false )
		end
	end
end
function adverts.onOpen()
	ULib.queueFunctionCall( adverts.tree.InvalidateLayout, adverts.tree )
end
adverts.updateAdverts()
xgui.hookEvent( "adverts", "process", adverts.updateAdverts, "serverUpdateAdverts" )
xgui.addSubModule( "adverts", adverts, nil, "server" )
xgui.prepareDataType( "banmessage" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_ban_message_label"), zpos=1 } )
plist.txtBanMessage = xlib.maketextbox{ zpos=2, h=236, multiline=true }
plist:Add( plist.txtBanMessage )
plist:Add( xlib.makelabel{ label=Tsv("sv_insert_var"), zpos=3 } )
plist.variablePicker = xlib.makecombobox{ choices={ Tsv("sv_ban_var_admin"), Tsv("sv_ban_var_time"), Tsv("sv_ban_var_reason"), Tsv("sv_ban_var_left"), Tsv("sv_ban_var_steamid"), Tsv("sv_ban_var_steamid64") }, zpos=4 }
plist:Add( plist.variablePicker )
plist.btnPreview = xlib.makebutton{ label=Tsv("sv_preview_ban_msg"), zpos=4 }
plist.btnPreview.DoClick = function()
	net.Start( "XGUI.PreviewBanMessage" )
		net.WriteString( plist.txtBanMessage:GetText() )
	net.SendToServer()
end
xgui.handleBanPreview = function( message )
	local preview = xlib.makeframe{ w=380, h=200 }
	local message = xlib.makelabel{ x=20, y=35, label=message, textcolor=Color( 191, 191, 191, 255 ), font="DefaultLarge", parent=preview }
	message:SizeToContents()
	local close = xlib.makebutton{ x=288, y=message:GetTall()+42, w=72, h=24, label=Tsv("ui_close"), font="DefaultLarge", parent=preview }
	close.DoClick = function()
		preview:Remove()
	end
	preview:SetTall( message:GetTall() + 85 )
end
plist:Add( plist.btnPreview )
plist.btnSave = xlib.makebutton{ label=Tsv("sv_save_ban_msg"), zpos=5 }
plist.btnSave.DoClick = function()
	net.Start( "XGUI.SaveBanMessage" )
		net.WriteString( plist.txtBanMessage:GetText() )
	net.SendToServer()
end
plist:Add( plist.btnSave )
plist.variablePicker.OnSelect = function( self, index, value, data )
	self:SetValue( "" )
	local newVariable = ""
	if index == 1 then
		newVariable = "{{BANNED_BY}}"
	elseif index == 2 then
		newVariable = "{{BAN_START}}"
	elseif index == 3 then
		newVariable = "{{REASON}}"
	elseif index == 4 then
		newVariable = "{{TIME_LEFT}}"
	elseif index == 5 then
		newVariable = "{{STEAMID}}"
	elseif index == 6 then
		newVariable = "{{STEAMID64}}"
	end
	plist.txtBanMessage:SetText( plist.txtBanMessage:GetText() .. newVariable )
end
plist.updateBanMessage = function()
	plist.txtBanMessage:SetText( xgui.data.banmessage.message or "" )
end
plist.updateBanMessage()
xgui.hookEvent( "banmessage", "process", plist.updateBanMessage, "serverUpdateBanMessage" )
xgui.addSubModule( "banmessage", plist, nil, "server" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null }
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_settings") } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_echo_vote"), repconvar="ulx_voteEcho" } )
plist:Add( xlib.makecombobox{ repconvar="ulx_logEcho", isNumberConvar=true, choices={ Tsv("sv_echo_none"), Tsv("sv_echo_anon"), Tsv("sv_echo_id") } } )
plist:Add( xlib.makecombobox{ repconvar="ulx_logSpawnsEcho", isNumberConvar=true, choices={ Tsv("sv_echo_spawn_none"), Tsv("sv_echo_spawn_admin"), Tsv("sv_echo_spawn_all") } } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_echo_colors"), repconvar="ulx_logEchoColors" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_color_default") } )
plist:Add( xlib.makecolorpicker{ repconvar="ulx_logEchoColorDefault", noalphamodetwo=true } )
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_color_console") } )
plist:Add( xlib.makecolorpicker{ repconvar="ulx_logEchoColorConsole", noalphamodetwo=true } )
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_color_self") } )
plist:Add( xlib.makecolorpicker{ repconvar="ulx_logEchoColorSelf", noalphamodetwo=true } )
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_color_all") } )
plist:Add( xlib.makecolorpicker{ repconvar="ulx_logEchoColorEveryone", noalphamodetwo=true } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_echo_color_team"), repconvar="ulx_logEchoColorPlayerAsGroup" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_color_player") } )
plist:Add( xlib.makecolorpicker{ repconvar="ulx_logEchoColorPlayer", noalphamodetwo=true } )
plist:Add( xlib.makelabel{ label=Tsv("sv_echo_color_misc") } )
plist:Add( xlib.makecolorpicker{ repconvar="ulx_logEchoColorMisc", noalphamodetwo=true } )
xgui.addSubModule( "echo", plist, nil, "server" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_general_ulx") } )
plist:Add( xlib.makeslider{ label=Tsv("sv_chattime"), min=0, max=5, decimal=1, repconvar="ulx_chattime" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_allow_me_chat") } )
plist:Add( xlib.makecombobox{ repconvar="ulx_meChatEnabled", isNumberConvar=true, choices={ Tsv("sv_me_chat_off"), Tsv("sv_me_chat_sandbox"), Tsv("sv_me_chat_on") } } )
plist:Add( xlib.makelabel{ label=Tsv("sv_welcome_message") } )
plist:Add( xlib.maketextbox{ repconvar="ulx_welcomemessage", selectall=true } )
plist:Add( xlib.makelabel{ label=Tsv("sv_available_vars") } )
plist:Add( xlib.makelabel{ label=Tsv("sv_auto_rename_kick") } )
plist:Add( xlib.makelabel{ label=Tsv("sv_rename_kick_count") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=10, decimal=0, repconvar="ulx_kickAfterNameChanges" } )
plist:Add( xlib.makeslider{ label=Tsv("sv_cooldown_seconds"), min=0, max=600, decimal=0, repconvar="ulx_kickAfterNameChangesCooldown" } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_warn_rename"), repconvar="ulx_kickAfterNameChangesWarning" } )
xgui.addSubModule( "ulxsettings", plist, nil, "server" )
xgui.prepareDataType( "gimps" )
local gimps = xlib.makepanel{ parent=xgui.null }
gimps.textbox = xlib.maketextbox{ w=225, h=20, parent=gimps, selectall=true }
gimps.textbox.OnEnter = function( self )
	if self:GetValue() then
		RunConsoleCommand( "xgui", "addGimp", self:GetValue() )
		self:SetText( "" )
	end
end
gimps.textbox.OnGetFocus = function( self )
	gimps.button:SetText( "Add" )
	self:SelectAllText()
	xgui.anchor:SetKeyboardInputEnabled( true )
end
gimps.button = xlib.makebutton{ x=225, w=50, label=Tsv("sv_add"), parent=gimps }
gimps.button.DoClick = function( self )
	if self:GetValue() == Tsv("sv_add") then
		gimps.textbox:OnEnter()
	elseif gimps.list:GetSelectedLine() then
		RunConsoleCommand( "xgui", "removeGimp", gimps.list:GetSelected()[1]:GetColumnText(1) )
	end
end
gimps.list = xlib.makelistview{ y=20, w=275, h=302, multiselect=false, headerheight=0, parent=gimps }
gimps.list:AddColumn( Tsv("sv_gimp_phrases") )
gimps.list.OnRowSelected = function( self, LineID, Line )
	gimps.button:SetText( Tsv("sv_remove") )
end
gimps.updateGimps = function()
	gimps.list:Clear()
	for k, v in pairs( xgui.data.gimps ) do
		gimps.list:AddLine( v )
	end
end
gimps.updateGimps()
xgui.hookEvent( "gimps", "process", gimps.updateGimps, "serverUpdateGimps" )
xgui.addSubModule( "gimps", gimps, nil, "server" )
xgui.prepareDataType( "banreasons", ulx.common_kick_reasons )
local panel = xlib.makepanel{ parent=xgui.null }
panel.textbox = xlib.maketextbox{ w=225, h=20, parent=panel, selectall=true }
panel.textbox.OnEnter = function( self )
	if self:GetValue() then
		RunConsoleCommand( "xgui", "addBanReason", self:GetValue() )
		self:SetText( "" )
	end
end
panel.textbox.OnGetFocus = function( self )
	panel.button:SetText( "Add" )
	self:SelectAllText()
	xgui.anchor:SetKeyboardInputEnabled( true )
end
panel.button = xlib.makebutton{ x=225, w=50, label=Tsv("sv_add"), parent=panel }
panel.button.DoClick = function( self )
	if self:GetValue() == Tsv("sv_add") then
		panel.textbox:OnEnter()
	elseif panel.list:GetSelectedLine() then
		RunConsoleCommand( "xgui", "removeBanReason", panel.list:GetSelected()[1]:GetColumnText(1) )
	end
end
panel.list = xlib.makelistview{ y=20, w=275, h=302, multiselect=false, headerheight=0, parent=panel }
panel.list:AddColumn( Tsv("sv_kickban_reasons") )
panel.list.OnRowSelected = function()
	panel.button:SetText( Tsv("sv_remove") )
end
panel.updateBanReasons = function()
	panel.list:Clear()
	for k, v in pairs( ulx.common_kick_reasons ) do
		panel.list:AddLine( v )
	end
end
panel.updateBanReasons()
xgui.hookEvent( "banreasons", "process", panel.updateBanReasons, "serverUpdateBanReasons" )
xgui.addSubModule( "banreasons", panel, "xgui_managebans", "server" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_log_settings") } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_log_file"), repconvar="ulx_logFile" } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_log_chat"), repconvar="ulx_logChat" } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_log_events"), repconvar="ulx_logEvents" } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_log_spawns"), repconvar="ulx_logSpawns" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_log_dir") } )
local logdirbutton = xlib.makebutton{}
xlib.checkRepCvarCreated( "ulx_logdir" )
logdirbutton:SetText( "data/" .. GetConVar( "ulx_logDir" ):GetString() )
function logdirbutton.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
	if cl_cvar == "ulx_logdir" then
		logdirbutton:SetText( "data/" .. new_val )
	end
end
hook.Add( "ULibReplicatedCvarChanged", "XGUI_ulx_logDir", logdirbutton.ConVarUpdated )
plist:Add( logdirbutton )
xgui.addSubModule( "logs", plist, nil, "server" )
xgui.prepareDataType( "motdsettings" )
local motdpnl = xlib.makepanel{ w=275, h=322, parent=xgui.null }
local plist = xlib.makelistlayout{ w=275, h=298, parent=motdpnl }
local fontWeights = { "normal", "bold", "100", "200", "300", "400", "500", "600", "700", "800", "900", "lighter", "bolder" }
local commonFonts = { "Arial", "Arial Black", "Calibri", "Candara", "Cambria", "Consolas", "Courier New", "Fraklin Gothic Medium", "Futura", "Georgia", "Helvetica", "Impact", "Lucida Console", "Segoe UI", "Tahoma", "Times New Roman", "Trebuchet MS", "Verdana" }
plist:Add( xlib.makelabel{ label=Tsv("sv_motd_mode"), zpos=0 } )
plist:Add( xlib.makecombobox{ repconvar="ulx_showmotd", isNumberConvar=true, choices={ Tsv("sv_motd_off"), Tsv("sv_motd_file"), Tsv("sv_motd_generator"), Tsv("sv_motd_url") }, zpos=1 } )
plist.txtMotdFile = xlib.maketextbox{ repconvar="ulx_motdfile", zpos=2 }
plist:Add( plist.txtMotdFile )
plist.txtMotdURL = xlib.maketextbox{ repconvar="ulx_motdurl", zpos=3 }
plist:Add( plist.txtMotdURL )
plist.lblDescription = xlib.makelabel{ zpos=4 }
plist:Add( plist.lblDescription )
local function unitToNumber(value)
	return tonumber( string.gsub(value, "[^%d]", "" ), _ )
end
local function hexToColor(value)
	value = string.gsub(value, "#","")
	return Color(tonumber("0x"..value:sub(1,2)), tonumber("0x"..value:sub(3,4)), tonumber("0x"..value:sub(5,6)))
end
local function colorToHex(color)
	return string.format("#%02x%02x%02x", color.r, color.g, color.b )
end
local didPressEnter = false
local selectedPanelTag = nil
local function registerMOTDChangeEventsTextbox( textbox, setting, sendTable )
	textbox.hasChanged = false
	textbox.OnEnter = function( self )
		didPressEnter = true
	end
	textbox.OnLoseFocus = function( self )
		selectedPanelTag = nil
		hook.Call( "OnTextEntryLoseFocus", nil, self )
		if didPressEnter then
			didPressEnter = false
			return
		end
		if self:GetValue() and textbox.hasChanged then
			textbox.hasChanged = false
			if sendTable then
				net.Start( "XGUI.SetMotdData" )
					net.WriteString( setting )
					net.WriteTable( ULib.explode( "\n", self:GetValue() ) )
				net.SendToServer()
			else
				net.Start( "XGUI.UpdateMotdData" )
					net.WriteString( setting )
					net.WriteString( self:GetValue() )
				net.SendToServer()
			end
		end
	end
	textbox:SetUpdateOnType( true )
	textbox.OnValueChange = function( self, strValue )
		textbox.hasChanged = true
	end
	textbox.OnGetFocus = function( self )
		hook.Run( "OnTextEntryGetFocus", self )
		selectedPanelTag = setting
	end
	if selectedPanelTag == setting then
		timer.Simple( 0, function() textbox:RequestFocus() end )
	end
end
local function registerMOTDChangeEventsCombobox( combobox, setting )
	registerMOTDChangeEventsTextbox( combobox.TextEntry, setting )
	combobox.OnSelect = function( self )
		net.Start( "XGUI.UpdateMotdData" )
			net.WriteString( setting )
			net.WriteString( self:GetValue() )
		net.SendToServer()
	end
end
local function registerMOTDChangeEventsSlider( slider, setting )
	registerMOTDChangeEventsTextbox( slider.TextArea, setting )
	local tmpfunc = slider.Slider.SetDragging
	slider.Slider.SetDragging = function( self, bval )
		tmpfunc( self, bval )
		if ( !bval ) then
			net.Start( "XGUI.UpdateMotdData" )
				net.WriteString( setting )
				net.WriteString( slider.TextArea:GetValue() )
			net.SendToServer()
		end
	end
	local tmpfunc2 = slider.Scratch.OnMouseReleased
	slider.Scratch.OnMouseReleased = function( self, mousecode )
		tmpfunc2( self, mousecode )
		net.Start( "XGUI.UpdateMotdData" )
			net.WriteString( setting )
			net.WriteString( slider.TextArea:GetValue() )
		net.SendToServer()
	end
end
local function registerMOTDChangeEventsColor( colorpicker, setting )
	colorpicker.OnChange = function( self, color )
		net.Start( "XGUI.UpdateMotdData" )
			net.WriteString( setting )
			net.WriteString( colorToHex( color ) )
		net.SendToServer()
	end
end
local function performMOTDInfoUpdate( data, setting )
	net.Start( "XGUI.SetMotdData" )
		net.WriteString( setting )
		net.WriteTable( data )
	net.SendToServer()
end
plist.generator = xlib.makelistlayout{ w=255, h=250, zpos=6, enablescroll=false }
plist:Add( plist.generator )
plist.generator:SetVisible( false )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_generator_title"), zpos=-2 } )
local txtServerDescription = xlib.maketextbox{ zpos=-1 }
plist.generator:Add( txtServerDescription )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_generator_info") } )
local pnlInfo = xlib.makelistlayout{ w=271, enablescroll=false }
plist.generator:Add( pnlInfo )
plist.generator:Add( xlib.makelabel{} )
local btnAddSection = xlib.makebutton{ label=Tsv("sv_add_section") }
btnAddSection.DoClick = function()
	local menu = DermaMenu()
	menu:SetSkin(xgui.settings.skin)
	menu:AddOption( Tsv("sv_section_text"), function()
		local info = xgui.data.motdsettings.info
		table.insert( info, {
			type="text",
			title="关于此服务器",
			contents={"在此输入服务器描述！"}
		})
		performMOTDInfoUpdate( info[#info], "info["..#info.."]" )
	end )
	menu:AddOption( Tsv("sv_section_ulist"), function()
		local info = xgui.data.motdsettings.info
		table.insert( info, {
			type="list",
			title="示例列表",
			contents={"每行文字成为一个列表项。", "您可以添加任意数量！"}
		})
		performMOTDInfoUpdate( info[#info], "info["..#info.."]" )
	end )
	menu:AddOption( Tsv("sv_section_olist"), function()
		local info = xgui.data.motdsettings.info
		table.insert( info, {
			type="ordered_list",
			title="示例有序列表",
			contents={"每行文字成为一个编号列表项。", "您可以添加任意数量！"}
		})
		performMOTDInfoUpdate( info[#info], "info["..#info.."]" )
	end )
	menu:AddOption( Tsv("sv_section_mods"), function()
		local info = xgui.data.motdsettings.info
		table.insert( info, {
			type="mods",
			title="已安装的插件"
		})
		performMOTDInfoUpdate( info[#info], "info["..#info.."]" )
	end )
	menu:AddOption( Tsv("sv_section_admins"), function()
		local info = xgui.data.motdsettings.info
		table.insert( info, {
			type="admins",
			title="我们的管理员",
			contents={"superadmin", "admin"}
		})
		performMOTDInfoUpdate( info[#info], "info["..#info.."]" )
	end )
	menu:Open()
end
plist.generator:Add( btnAddSection )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_fonts") } )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_server_name") } )
local pnlFontServerName = xlib.makepanel{h=80, parent=xgui.null }
xlib.makelabel{ x=5, y=8, label=Tsv("sv_font_name"), parent=pnlFontServerName }
pnlFontServerName.name = xlib.makecombobox{ x=65, y=5, w=190, enableinput=true, selectall=true, choices=commonFonts, parent=pnlFontServerName }
pnlFontServerName.size = xlib.makeslider{ x=5, y=30, w=250, label=Tsv("sv_font_size"), value=16, min=4, max=72, parent=pnlFontServerName }
xlib.makelabel{ x=5, y=58, label=Tsv("sv_font_weight"), parent=pnlFontServerName }
pnlFontServerName.weight = xlib.makecombobox{ x=72, y=55, w=183, enableinput=true, selectall=true, choices=fontWeights, parent=pnlFontServerName }
plist.generator:Add( pnlFontServerName )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_subtitle") } )
local pnlFontSubtitle = xlib.makepanel{h=80, parent=xgui.null }
xlib.makelabel{ x=5, y=8, label=Tsv("sv_font_name"), parent=pnlFontSubtitle }
pnlFontSubtitle.name = xlib.makecombobox{ x=65, y=5, w=190, enableinput=true, selectall=true, choices=commonFonts, parent=pnlFontSubtitle }
pnlFontSubtitle.size = xlib.makeslider{ x=5, y=30, w=250, label=Tsv("sv_font_size"), value=16, min=4, max=72, parent=pnlFontSubtitle }
xlib.makelabel{ x=5, y=58, label=Tsv("sv_font_weight"), parent=pnlFontSubtitle }
pnlFontSubtitle.weight = xlib.makecombobox{ x=72, y=55, w=183, enableinput=true, selectall=true, choices=fontWeights, parent=pnlFontSubtitle }
plist.generator:Add( pnlFontSubtitle )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_section_title") } )
local pnlFontSection = xlib.makepanel{h=80, parent=xgui.null }
xlib.makelabel{ x=5, y=8, label=Tsv("sv_font_name"), parent=pnlFontSection }
pnlFontSection.name = xlib.makecombobox{ x=65, y=5, w=190, enableinput=true, selectall=true, choices=commonFonts, parent=pnlFontSection }
pnlFontSection.size = xlib.makeslider{ x=5, y=30, w=250, label=Tsv("sv_font_size"), value=16, min=4, max=72, parent=pnlFontSection }
xlib.makelabel{ x=5, y=58, label=Tsv("sv_font_weight"), parent=pnlFontSection }
pnlFontSection.weight = xlib.makecombobox{ x=72, y=55, w=183, enableinput=true, selectall=true, choices=fontWeights, parent=pnlFontSection }
plist.generator:Add( pnlFontSection )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_regular_text") } )
local pnlFontRegular = xlib.makepanel{h=80, parent=xgui.null }
xlib.makelabel{ x=5, y=8, label=Tsv("sv_font_name"), parent=pnlFontRegular }
pnlFontRegular.name = xlib.makecombobox{ x=65, y=5, w=190, enableinput=true, selectall=true, choices=commonFonts, parent=pnlFontRegular }
pnlFontRegular.size = xlib.makeslider{ x=5, y=30, w=250, label=Tsv("sv_font_size"), value=16, min=4, max=72, parent=pnlFontRegular }
xlib.makelabel{ x=5, y=58, label=Tsv("sv_font_weight"), parent=pnlFontRegular }
pnlFontRegular.weight = xlib.makecombobox{ x=72, y=55, w=183, enableinput=true, selectall=true, choices=fontWeights, parent=pnlFontRegular }
plist.generator:Add( pnlFontRegular )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_colors") } )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_bg_color") } )
local pnlColorBackground = xlib.makecolorpicker{ noalphamodetwo=true }
plist.generator:Add( pnlColorBackground )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_header_color") } )
local pnlColorHeaderBackground = xlib.makecolorpicker{ noalphamodetwo=true }
plist.generator:Add( pnlColorHeaderBackground )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_header_text_color") } )
local pnlColorHeader = xlib.makecolorpicker{ noalphamodetwo=true }
plist.generator:Add( pnlColorHeader )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_section_text_color") } )
local pnlColorSection = xlib.makecolorpicker{ noalphamodetwo=true }
plist.generator:Add( pnlColorSection )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_default_text_color") } )
local pnlColorText = xlib.makecolorpicker{ noalphamodetwo=true }
plist.generator:Add( pnlColorText )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_motd_border") } )
local pnlBorderThickness = xlib.makeslider{ label=Tsv("sv_border_thickness"), w=200, value=1, min=0, max=32 }
plist.generator:Add( pnlBorderThickness )
plist.generator:Add( xlib.makelabel{ label=Tsv("sv_border_color") } )
local pnlBorderColor = xlib.makecolorpicker{ noalphamodetwo=true }
plist.generator:Add( pnlBorderColor )
registerMOTDChangeEventsTextbox( txtServerDescription, "info.description" )
registerMOTDChangeEventsCombobox( pnlFontServerName.name, "style.fonts.server_name.family" )
registerMOTDChangeEventsSlider( pnlFontServerName.size, "style.fonts.server_name.size" )
registerMOTDChangeEventsCombobox( pnlFontServerName.weight, "style.fonts.server_name.weight" )
registerMOTDChangeEventsCombobox( pnlFontSubtitle.name, "style.fonts.subtitle.family" )
registerMOTDChangeEventsSlider( pnlFontSubtitle.size, "style.fonts.subtitle.size" )
registerMOTDChangeEventsCombobox( pnlFontSubtitle.weight, "style.fonts.subtitle.weight" )
registerMOTDChangeEventsCombobox( pnlFontSection.name, "style.fonts.section_title.family" )
registerMOTDChangeEventsSlider( pnlFontSection.size, "style.fonts.section_title.size" )
registerMOTDChangeEventsCombobox( pnlFontSection.weight, "style.fonts.section_title.weight" )
registerMOTDChangeEventsCombobox( pnlFontRegular.name, "style.fonts.regular.family" )
registerMOTDChangeEventsSlider( pnlFontRegular.size, "style.fonts.regular.size" )
registerMOTDChangeEventsCombobox( pnlFontRegular.weight, "style.fonts.regular.weight" )
registerMOTDChangeEventsColor( pnlColorBackground, "style.colors.background_color" )
registerMOTDChangeEventsColor( pnlColorHeaderBackground, "style.colors.header_color" )
registerMOTDChangeEventsColor( pnlColorHeader, "style.colors.header_text_color" )
registerMOTDChangeEventsColor( pnlColorSection, "style.colors.section_text_color" )
registerMOTDChangeEventsColor( pnlColorText, "style.colors.text_color" )
registerMOTDChangeEventsColor( pnlBorderColor, "style.borders.border_color" )
registerMOTDChangeEventsSlider( pnlBorderThickness, "style.borders.border_thickness" )
plist.updateGeneratorSettings = function( data )
	if not data then data = xgui.data.motdsettings end
	if not data or not data.style or not data.info then return end
	if not plist.generator:IsVisible() then return end
	local borders = data.style.borders
	local colors = data.style.colors
	local fonts = data.style.fonts
	txtServerDescription:SetText( data.info.description )
	pnlInfo:Clear()
	for i=1, #data.info do
		local section = data.info[i]
		local sectionPanel = xlib.makelistlayout{ w=270, enablescroll=false }
		if section.type == "text" then
			sectionPanel:Add( xlib.makelabel{ label="\n"..i..": 文本内容", zpos=0 } )
			local sectionTitle = xlib.maketextbox{ zpos=1 }
			registerMOTDChangeEventsTextbox( sectionTitle, "info["..i.."].title" )
			sectionTitle:SetText( section.title )
			sectionPanel:Add( sectionTitle )
			local sectionText = xlib.maketextbox{ h=100, multiline=true, zpos=2 }
			registerMOTDChangeEventsTextbox( sectionText, "info["..i.."].contents", true )
			sectionText:SetText( table.concat( section.contents, "\n" ) )
			sectionPanel:Add( sectionText )
		elseif section.type == "ordered_list" then
			sectionPanel:Add( xlib.makelabel{ label="\n"..i..": 有序列表" } )
			local sectionTitle = xlib.maketextbox{ zpos=1 }
			registerMOTDChangeEventsTextbox( sectionTitle, "info["..i.."].title" )
			sectionTitle:SetText( section.title )
			sectionPanel:Add( sectionTitle )
			local sectionOrderedList = xlib.maketextbox{ h=110, multiline=true, zpos=2 }
			registerMOTDChangeEventsTextbox( sectionOrderedList, "info["..i.."].contents", true )
			sectionOrderedList:SetText( table.concat( section.contents, "\n" ) )
			sectionPanel:Add( sectionOrderedList )
		elseif section.type == "list" then
			sectionPanel:Add( xlib.makelabel{ label="\n"..i..": 无序列表" } )
			local sectionTitle = xlib.maketextbox{ zpos=1 }
			registerMOTDChangeEventsTextbox( sectionTitle, "info["..i.."].title" )
			sectionTitle:SetText( section.title )
			sectionPanel:Add( sectionTitle )
			local sectionList = xlib.maketextbox{ h=100, multiline=true, zpos=2 }
			registerMOTDChangeEventsTextbox( sectionList, "info["..i.."].contents", true )
			sectionList:SetText( table.concat( section.contents, "\n" ) )
			sectionPanel:Add( sectionList )
		elseif section.type == "mods" then
			sectionPanel:Add( xlib.makelabel{ label="\n"..i..": 已安装的插件" } )
			local modsTitle = xlib.maketextbox{ zpos=1 }
			registerMOTDChangeEventsTextbox( modsTitle, "info["..i.."].title" )
			modsTitle:SetText( section.title )
			sectionPanel:Add( modsTitle )
		elseif section.type == "admins" then
			sectionPanel:Add( xlib.makelabel{ label="\n"..i..": 列出用户组中的用户" } )
			local adminsTitle = xlib.maketextbox{ zpos=1 }
			registerMOTDChangeEventsTextbox( adminsTitle, "info["..i.."].title" )
			adminsTitle:SetText( section.title )
			sectionPanel:Add( adminsTitle )
			for j=1, #section.contents do
				local group = section.contents[j]
				local adminPnl = xlib.makepanel{ h=20, w=270, zpos=i+j }
				xlib.makelabel{ h=20, w=200, label=group, parent=adminPnl }
				local adminBtn = xlib.makebutton{ x=204, w=50, label=Tsv("sv_remove"), parent=adminPnl }
				adminBtn.DoClick = function()
					table.remove( section.contents, j )
					performMOTDInfoUpdate( section.contents, "info["..i.."].contents" )
				end
				sectionPanel:Add( adminPnl )
			end
			local adminAddPnl = xlib.makepanel{ h=20, w=270, zpos=99 }
			local adminBtn = xlib.makebutton{ w=100, label=Tsv("sv_add_group"), parent=adminAddPnl }
			adminBtn.DoClick = function()
				local menu = DermaMenu()
				menu:SetSkin(xgui.settings.skin)
				for j=1, #xgui.data.groups do
					local group = xgui.data.groups[j]
					if not table.HasValue( section.contents, group ) then
						menu:AddOption( group, function()
							table.insert( section.contents, group )
							performMOTDInfoUpdate( section.contents, "info["..i.."].contents" )
						end )
					end
				end
				menu:Open()
			end
			sectionPanel:Add( adminAddPnl )
		end
		local actionPnl = xlib.makepanel{ w=270, h=20, zpos=100 }
		local btnRemove = xlib.makebutton{ w=100, label=Tsv("sv_remove_section"), parent=actionPnl }
		btnRemove.DoClick = function()
			Derma_Query( Tsv("sv_confirm_remove_section") .. " \"" .. section.title .. "\"?", Tsv("maps_warning_title"),
				Tsv("sv_remove"), function()
								table.remove( data.info, i )
								performMOTDInfoUpdate( data.info, "info" )
							end,
				Tsv("maps_btn_cancel"), function() end )
		end
		local btnUp = xlib.makebutton{ x=214, w=20, icon="icon16/bullet_arrow_up.png", centericon=true, disabled=(i==1), parent=actionPnl }
		btnUp.DoClick = function()
			local tmp = data.info[i-1]
			data.info[i-1] = data.info[i]
			data.info[i] = tmp
			performMOTDInfoUpdate( data.info, "info" )
		end
		local btnDown = xlib.makebutton{ x=234, w=20, icon="icon16/bullet_arrow_down.png", centericon=true, disabled=(i==#data.info), parent=actionPnl }
		btnDown.DoClick = function()
			local tmp = data.info[i+1]
			data.info[i+1] = data.info[i]
			data.info[i] = tmp
			performMOTDInfoUpdate( data.info, "info" )
		end
		sectionPanel:Add( actionPnl )
		pnlInfo:Add( sectionPanel )
	end
	pnlFontServerName.name:SetText( fonts.server_name.family )
	pnlFontServerName.size:SetValue( unitToNumber( fonts.server_name.size ) )
	pnlFontServerName.weight:SetText( fonts.server_name.weight )
	pnlFontSubtitle.name:SetText( fonts.subtitle.family )
	pnlFontSubtitle.size:SetValue( unitToNumber( fonts.subtitle.size ) )
	pnlFontSubtitle.weight:SetText( fonts.subtitle.weight )
	pnlFontSection.name:SetText( fonts.section_title.family )
	pnlFontSection.size:SetValue( unitToNumber( fonts.section_title.size ) )
	pnlFontSection.weight:SetText( fonts.section_title.weight )
	pnlFontRegular.name:SetText( fonts.regular.family )
	pnlFontRegular.size:SetValue( unitToNumber( fonts.regular.size ) )
	pnlFontRegular.weight:SetText( fonts.regular.weight )
	pnlColorBackground:SetColor( hexToColor( colors.background_color ) )
	pnlColorHeaderBackground:SetColor( hexToColor( colors.header_color ) )
	pnlColorHeader:SetColor( hexToColor( colors.header_text_color ) )
	pnlColorSection:SetColor( hexToColor( colors.section_text_color ) )
	pnlColorText:SetColor( hexToColor( colors.text_color ) )
	pnlBorderThickness:SetValue( unitToNumber( borders.border_thickness ) )
	pnlBorderColor:SetColor( hexToColor( borders.border_color ) )
end
xgui.hookEvent( "motdsettings", "process", plist.updateGeneratorSettings, "serverUpdateGeneratorSettings" )
plist.updateGeneratorSettings()
plist.btnPreview = xlib.makebutton{ label=Tsv("sv_preview_motd"), w=275, y=302, parent=motdpnl }
plist.btnPreview.DoClick = function()
	RunConsoleCommand( "ulx", "motd" )
end
function plist.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
	if string.lower( cl_cvar ) == "ulx_showmotd" then
		local previewDisabled = false
		local showMotdFile = false
		local showGenerator = false
		local showURL = false
		if new_val == "0" then
			previewDisabled = true
			plist.lblDescription:SetText( "MOTD is completely disabled.\n" )
		elseif new_val == "1" then
			showMotdFile = true
			plist.lblDescription:SetText( "MOTD is the contents of the given file.\nFile is located in the server's garrysmod root.\n" )
		elseif new_val == "2" then
			showGenerator = true
			plist.lblDescription:SetText( "MOTD is generated using a basic template and the\nsettings below.\n" )
		elseif new_val == "3" then
			showURL = true
			plist.lblDescription:SetText( "MOTD is the given URL.\nYou can use %curmap% and %steamid%\n(eg, server.com/?map=%curmap%&id=%steamid%)\n" )
		end
		plist.btnPreview:SetDisabled( previewDisabled )
		plist.txtMotdFile:SetVisible( showMotdFile )
		plist.generator:SetVisible( showGenerator )
		plist.txtMotdURL:SetVisible( showURL )
		plist.lblDescription:SizeToContents()
		plist.updateGeneratorSettings()
		plist.scroll:InvalidateChildren()
	end
end
hook.Add( "ULibReplicatedCvarChanged", "XGUI_ulx_showMotd", plist.ConVarUpdated )
xlib.checkRepCvarCreated( "ulx_showMotd" )
plist.ConVarUpdated( nil, "ulx_showMotd", nil, nil, GetConVar( "ulx_showMotd" ):GetString() )
xgui.addSubModule( "motd", motdpnl, "ulx showmotd", "server" )
xgui.prepareDataType( "votemaps", ulx.votemaps )
local panel = xlib.makepanel{ w=285, h=322, parent=xgui.null }
xlib.makelabel{ label=Tsv("sv_allowed_votemaps"), x=5, y=3, parent=panel }
xlib.makelabel{ label=Tsv("sv_excluded_votemaps"), x=150, y=3, parent=panel }
panel.votemaps = xlib.makelistview{ y=20, w=135, h=262, multiselect=true, headerheight=0, parent=panel }
panel.votemaps:AddColumn( "" )
panel.votemaps.OnRowSelected = function( self, LineID, Line )
	panel.add:SetDisabled( true )
	panel.remove:SetDisabled( false )
	panel.remainingmaps:ClearSelection()
end
panel.remainingmaps = xlib.makelistview{ x=140, y=20, w=135, h=262, multiselect=true, headerheight=0, parent=panel }
panel.remainingmaps:AddColumn( "" )
panel.remainingmaps.OnRowSelected = function( self, LineID, Line )
	panel.add:SetDisabled( false )
	panel.remove:SetDisabled( true )
	panel.votemaps:ClearSelection()
end
panel.remove = xlib.makebutton{ y=282, w=135, label=Tsv("sv_remove") .. " -->", disabled=true, parent=panel }
panel.remove.DoClick = function()
	panel.remove:SetDisabled( true )
	local temp = {}
	for _, v in ipairs( panel.votemaps:GetSelected() ) do
		table.insert( temp, v:GetColumnText(1) )
	end
	net.Start( "XGUI.RemoveVotemaps" )
		net.WriteTable( temp )
	net.SendToServer()
end
panel.add = xlib.makebutton{ x=140, y=282, w=135, label="<-- Add", disabled=true, parent=panel }
panel.add.DoClick = function()
	panel.add:SetDisabled( true )
	local temp = {}
	for _, v in ipairs( panel.remainingmaps:GetSelected() ) do
		table.insert( temp, v:GetColumnText(1) )
	end
	net.Start( "XGUI.AddVotemaps" )
		net.WriteTable( temp )
	net.SendToServer()
end
panel.votemapmode = xlib.makecombobox{ y=302, w=275, repconvar="ulx_votemapMapmode", isNumberConvar=true, numOffset=0, choices={ Tsv("sv_votemap_mode_include"), Tsv("sv_votemap_mode_exclude") }, parent=panel }
panel.updateList = function()
	if #ulx.maps ~= 0 then
		panel.votemaps:Clear()
		panel.remainingmaps:Clear()
		panel.add:SetDisabled( true )
		panel.remove:SetDisabled( true )
		for _, v in ipairs( ulx.maps ) do
			if table.HasValue( ulx.votemaps, v ) then
				panel.votemaps:AddLine( v )
			else
				panel.remainingmaps:AddLine( v )
			end
		end
	end
end
panel.updateList()
xgui.hookEvent( "votemaps", "process", panel.updateList, "serverUpdateVotemapList" )
xgui.addSubModule( "votemaplist", panel, nil, "server" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_player_votemap") } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_votemap_enabled"), repconvar="ulx_votemapEnabled" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_min_time") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=300, repconvar="ulx_votemapMintime" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_wait_time") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=60, decimal=1, repconvar="ulx_votemapWaittime" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_ratio") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=1, decimal=2, repconvar="ulx_votemapSuccessratio" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_min_votes_player") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=10, repconvar="ulx_votemapMinvotes" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votemap_veto_window") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=300, repconvar="ulx_votemapVetotime" } )
xgui.addSubModule( "votemapsettings", plist, nil, "server" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_slots_settings") } )
plist:Add( xlib.makecombobox{ repconvar="ulx_rslotsMode", isNumberConvar=true, choices={ Tsv("sv_slots_mode0"), Tsv("sv_slots_mode1"), Tsv("sv_slots_mode2"), Tsv("sv_slots_mode3") } } )
plist:Add( xlib.makeslider{ label=Tsv("sv_slots_count"), min=0, max=game.MaxPlayers(), repconvar="ulx_rslots" } )
plist:Add( xlib.makecheckbox{ label=Tsv("sv_slots_visible"), repconvar="ulx_rslotsVisible" } )
plist:Add( xlib.makelabel{ w=265, wordwrap=true, label=Tsv("sv_slots_desc") } )
xgui.addSubModule( "reservedslots", plist, nil, "server" )
local plist = xlib.makelistlayout{ w=275, h=322, parent=xgui.null, enablescroll=false }
plist:Add( xlib.makelabel{ label=Tsv("sv_votekick_settings") } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votekick_ratio") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=1, decimal=2, repconvar="ulx_votekickSuccessratio" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_votekick_min") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=10, repconvar="ulx_votekickMinvotes" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_voteban_settings") } )
plist:Add( xlib.makelabel{ label=Tsv("sv_voteban_ratio") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=1, decimal=2, repconvar="ulx_votebanSuccessratio" } )
plist:Add( xlib.makelabel{ label=Tsv("sv_voteban_min") } )
plist:Add( xlib.makeslider{ label="<--->", min=0, max=10, repconvar="ulx_votebanMinvotes" } )
xgui.addSubModule( "votekickban", plist, nil, "server" )