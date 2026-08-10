local client = xlib.makepanel{ parent=xgui.null }
client.panel = xlib.makepanel{ x=160, y=5, w=425, h=322, parent=client }
client.catList = xlib.makelistview{ x=5, y=5, w=150, h=302, parent=client }
client.catList:AddColumn( xgui.T("set_client_settings") )
client.catList.Columns[1].DoClick = function() end
client.catList.OnRowSelected = function( self, LineID, Line )
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
	if nPanel ~= client.curPanel then
		nPanel:SetZPos( 0 )
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=-435, starty=0, endx=0, endy=0, setvisible=true } )
		if client.curPanel then
			client.curPanel:SetZPos( -1 )
			xlib.addToAnimQueue( client.curPanel.SetVisible, client.curPanel, false )
		end
		xlib.animQueue_start()
		client.curPanel = nPanel
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=0, starty=0, endx=-435, endy=0, setvisible=false } )
		self:ClearSelection()
		client.curPanel = nil
		xlib.animQueue_start()
	end
	if nPanel.onOpen then nPanel.onOpen() end
end
local btnSaveClient = xlib.makebutton{ x=5, y=307, w=150, label=xgui.T("set_save_client"), parent=client }
btnSaveClient.DoClick = function() xgui.saveClientSettings() end
function xgui.openClientModule( name )
	name = string.lower( name )
	for i = 1, #xgui.modules.submodule do
		local module = xgui.modules.submodule[i]
		if module.mtype == "client" and string.lower(module.name) == name then
			if module.panel ~= client.curPanel then
				client.catList:ClearSelection()
				for j = 1, #client.catList.Lines do
					local line = client.catList.Lines[j]
					if string.lower(line:GetColumnText(1)) == name then
						client.catList:SelectItem( line ); break
					end
				end
			end
			break
		end
	end
end
function client.processModules()
	client.catList.Columns[1].Header:SetText( xgui.T("set_client_settings") )
	btnSaveClient:SetText( xgui.T("set_save_client") )
	client.catList:Clear()
	for i, module in ipairs( xgui.modules.submodule ) do
		if module.mtype == "client" and ( not module.access or LocalPlayer():query( module.access ) ) then
			local x, y = module.panel:GetSize()
			if x == y and y == 0 then module.panel:SetSize( 425, 327 ) end
			module.panel:SetParent( client.panel )
			local line = client.catList:AddLine( module.displayName, i )
			if module.panel == client.curPanel then
				client.curPanel = nil; client.catList:SelectItem( line )
			else module.panel:SetVisible( false ) end
		end
	end
	client.catList:SortByColumn( 1, false )
end
client.processModules()
xgui.hookEvent( "onProcessModules", nil, client.processModules, "xguiProcessModules" )
xgui.registerRefresh( "client_settings", function()
	client.catList.Columns[1].Header:SetText( xgui.T("set_client_settings") )
	btnSaveClient:SetText( xgui.T("set_save_client") )
	for _, line in ipairs( client.catList.Lines ) do
		local modIdx = tonumber( line:GetColumnText(2) )
		if modIdx and xgui.modules.submodule[modIdx] then
			line:SetColumnText( 1, xgui.modules.submodule[modIdx].displayName )
		end
	end
end )
xgui.addSettingModule( "client", client, "icon16/layout_content.png" )
local genpnl = xlib.makepanel{ parent=xgui.null }
genpnl.pickupplayers = xlib.makecheckbox{ x=10, y=10, w=150, label=xgui.T("ui_physgun_pickup"), convar="cl_pickupplayers", parent=genpnl }
local ckClickOut = xlib.makecheckbox{ x=10, y=30, w=150, label=xgui.T("ui_click_out_close"), value=xgui.settings.clickOutClose, parent=genpnl }
ckClickOut.OnChange = function( self, bVal ) xgui.settings.clickOutClose = bVal end
local L = ULib.ulx_lang
local lblLang = xlib.makelabel{ x=10, y=55, label=L.T("set_language_desc") .. ":", parent=genpnl }
local langCombo = xlib.makecombobox{ x=10, y=70, w=150, parent=genpnl, choices={} }
for _, lang in ipairs( L.available ) do langCombo:AddChoice( L.names[lang], lang ) end
langCombo:SetValue( L.names[L.current] or L.names["zh-cn"] )
langCombo.OnSelect = function( self, index, value, data )
	ULib.ulx_lang.switch( data ); ULib.ulx_lang.saveClientLang( data )
	chat.AddText( Color( 100, 255, 100 ), "[Ultra ULX] Language: " .. L.names[data] )
end
function genpnl.processModules()
	genpnl.pickupplayers:SetDisabled( not LocalPlayer():query( "ulx physgunplayer" ) )
	genpnl.pickupplayers:SetText( xgui.T("ui_physgun_pickup") )
	ckClickOut:SetText( xgui.T("ui_click_out_close") )
	lblLang:SetText( xgui.T("set_language_desc") .. ":" )
end
xgui.hookEvent( "onProcessModules", nil, genpnl.processModules, "clientGeneralProcessModules" )
xgui.registerRefresh( "client_general", function()
	genpnl.pickupplayers:SetText( xgui.T("ui_physgun_pickup") )
	ckClickOut:SetText( xgui.T("ui_click_out_close") )
	lblLang:SetText( xgui.T("set_language_desc") .. ":" )
	if langCombo then langCombo:SetText( L.names[L.current] or L.names["zh-cn"] ) end
end )
xgui.addSubModule( "general", genpnl, nil, "client" )
local xguipnl = xlib.makepanel{ parent=xgui.null }
local btnRefreshXGUI = xlib.makebutton{ x=10, y=10, w=150, label=xgui.T("ui_refresh_xgui"), parent=xguipnl }
btnRefreshXGUI.DoClick = function() xgui.processModules() end
local btnRefreshData = xlib.makebutton{ x=10, y=30, w=150, label=xgui.T("ui_refresh_data"), parent=xguipnl }
btnRefreshData.DoClick = function( self )
	if xgui.offlineMode then
		self:SetDisabled( true ); RunConsoleCommand( "_xgui", "getInstalled" )
		timer.Simple( 10, function() self:SetDisabled( false ) end )
	elseif xgui.isInstalled then
		self:SetDisabled( true ); RunConsoleCommand( "xgui", "refreshdata" )
		timer.Simple( 10, function() self:SetDisabled( false ) end )
	end
end
local lblAnimTime = xlib.makelabel{ x=10, y=55, label=xgui.T("ui_anim_time"), parent=xguipnl }
xlib.makeslider{ x=10, y=70, w=150, label="<--->", max=2, value=xgui.settings.animTime, decimal=2, parent=xguipnl }.OnValueChanged = function( self, val )
	xgui.settings.animTime = math.Clamp( tonumber( val ) or 0, 0, 2 )
end
local ckShowLoadMsgs = xlib.makecheckbox{ x=10, y=97, w=150, label=xgui.T("ui_show_load_msgs"), value=xgui.settings.showLoadMsgs, parent=xguipnl }
ckShowLoadMsgs.OnChange = function( self, bVal ) xgui.settings.showLoadMsgs = bVal end
local lblInfoColor = xlib.makelabel{ x=10, y=120, label=xgui.T("ui_info_color"), parent=xguipnl }
xlib.makecolorpicker{ x=10, y=135, color=xgui.settings.infoColor, addalpha=true, alphamodetwo=true, parent=xguipnl }.OnChangeImmediate = function( self, color )
	xgui.settings.infoColor = color
end
xguipnl.mainorder = xlib.makelistview{ x=175, y=10, w=115, h=110, parent=xguipnl }
xguipnl.mainorder:AddColumn( xgui.T("ui_main_modules") )
xguipnl.mainorder.OnRowSelected = function( self, LineID, Line )
	xguipnl.upbtnM:SetDisabled( LineID <= 1 ); xguipnl.downbtnM:SetDisabled( LineID >= #xgui.settings.moduleOrder )
end
xguipnl.updateMainOrder = function()
	local sel = xguipnl.mainorder:GetSelectedLine() and xguipnl.mainorder:GetSelected()[1]
	local selKey = sel and sel.key
	xguipnl.mainorder:Clear()
	local i = 1
	while i <= #xgui.settings.moduleOrder do
		local v = xgui.settings.moduleOrder[i]; local found = false
		for _, tab in pairs( xgui.modules.tab ) do if tab.name == v then found = true; break end end
		if found then
			local l = xguipnl.mainorder:AddLine( xgui.T( "tab_" .. v ) ); l.key = v
			if selKey and selKey == v then xguipnl.mainorder:SelectItem( l ) end
			i = i + 1
		else table.remove( xgui.settings.moduleOrder, i ) end
	end
end
xgui.hookEvent( "onProcessModules", nil, xguipnl.updateMainOrder, "clientXGUIUpdateTabOrder" )
xguipnl.upbtnM = xlib.makebutton{ x=250, y=120, w=20, icon="icon16/bullet_arrow_up.png", centericon=true, disabled=true, parent=xguipnl }
xguipnl.upbtnM.DoClick = function( self )
	self:SetDisabled( true ); local i = xguipnl.mainorder:GetSelectedLine()
	if not i then return end
	table.insert( xgui.settings.moduleOrder, i - 1, xgui.settings.moduleOrder[i] )
	table.remove( xgui.settings.moduleOrder, i + 1 ); xgui.processModules()
end
xguipnl.downbtnM = xlib.makebutton{ x=270, y=120, w=20, icon="icon16/bullet_arrow_down.png", centericon=true, disabled=true, parent=xguipnl }
xguipnl.downbtnM.DoClick = function( self )
	self:SetDisabled( true ); local i = xguipnl.mainorder:GetSelectedLine()
	if not i then return end
	table.insert( xgui.settings.moduleOrder, i + 2, xgui.settings.moduleOrder[i] )
	table.remove( xgui.settings.moduleOrder, i ); xgui.processModules()
end
xguipnl.settingorder = xlib.makelistview{ x=300, y=10, w=115, h=110, parent=xguipnl }
xguipnl.settingorder:AddColumn( xgui.T("ui_settings_modules") )
xguipnl.settingorder.OnRowSelected = function( self, LineID, Line )
	xguipnl.upbtnS:SetDisabled( LineID <= 1 ); xguipnl.downbtnS:SetDisabled( LineID >= #xgui.settings.settingOrder )
end
xguipnl.updateSettingOrder = function()
	local sel = xguipnl.settingorder:GetSelectedLine() and xguipnl.settingorder:GetSelected()[1]
	local selKey = sel and sel.key
	xguipnl.settingorder:Clear()
	local i = 1
	while i <= #xgui.settings.settingOrder do
		local v = xgui.settings.settingOrder[i]; local found = false
		for _, tab in pairs( xgui.modules.setting ) do if tab.name == v then found = true; break end end
		if found then
			local l = xguipnl.settingorder:AddLine( xgui.T( "tab_" .. v ) ); l.key = v
			if selKey and selKey == v then xguipnl.settingorder:SelectItem( l ) end
			i = i + 1
		else table.remove( xgui.settings.settingOrder, i ) end
	end
end
xgui.hookEvent( "onProcessModules", nil, xguipnl.updateSettingOrder, "clientXGUIUpdateSettingOrder" )
xguipnl.upbtnS = xlib.makebutton{ x=395, y=120, w=20, icon="icon16/bullet_arrow_up.png", centericon=true, disabled=true, parent=xguipnl }
xguipnl.upbtnS.DoClick = function( self )
	self:SetDisabled( true ); local i = xguipnl.settingorder:GetSelectedLine()
	if not i then return end
	table.insert( xgui.settings.settingOrder, i - 1, xgui.settings.settingOrder[i] )
	table.remove( xgui.settings.settingOrder, i + 1 ); xgui.processModules()
end
xguipnl.downbtnS = xlib.makebutton{ x=375, y=120, w=20, icon="icon16/bullet_arrow_down.png", centericon=true, disabled=true, parent=xguipnl }
xguipnl.downbtnS.DoClick = function( self )
	self:SetDisabled( true ); local i = xguipnl.settingorder:GetSelectedLine()
	if not i then return end
	table.insert( xgui.settings.settingOrder, i + 2, xgui.settings.settingOrder[i] )
	table.remove( xgui.settings.settingOrder, i ); xgui.processModules()
end
xlib.makelabel{ x=175, y=145, label=xgui.T("ui_xgui_position"), parent=xguipnl }
local pos = tonumber( xgui.settings.xguipos.pos )
xguipnl.b7 = xlib.makebutton{ x=175, y=160, w=20, disabled=pos==7, parent=xguipnl }; xguipnl.b7.DoClick = function() xguipnl.updatePos( 7 ) end
xguipnl.b8 = xlib.makebutton{ x=195, y=160, w=20, icon="icon16/arrow_up.png", centericon=true, disabled=pos==8, parent=xguipnl }; xguipnl.b8.DoClick = function() xguipnl.updatePos( 8 ) end
xguipnl.b9 = xlib.makebutton{ x=215, y=160, w=20, disabled=pos==9, parent=xguipnl }; xguipnl.b9.DoClick = function() xguipnl.updatePos( 9 ) end
xguipnl.b4 = xlib.makebutton{ x=175, y=180, w=20, icon="icon16/arrow_left.png", centericon=true, disabled=pos==4, parent=xguipnl }; xguipnl.b4.DoClick = function() xguipnl.updatePos( 4 ) end
xguipnl.b5 = xlib.makebutton{ x=195, y=180, w=20, icon="icon16/bullet_green.png", centericon=true, disabled=pos==5, parent=xguipnl }; xguipnl.b5.DoClick = function() xguipnl.updatePos( 5 ) end
xguipnl.b6 = xlib.makebutton{ x=215, y=180, w=20, icon="icon16/arrow_right.png", centericon=true, disabled=pos==6, parent=xguipnl }; xguipnl.b6.DoClick = function() xguipnl.updatePos( 6 ) end
xguipnl.b1 = xlib.makebutton{ x=175, y=200, w=20, disabled=pos==1, parent=xguipnl }; xguipnl.b1.DoClick = function() xguipnl.updatePos( 1 ) end
xguipnl.b2 = xlib.makebutton{ x=195, y=200, w=20, icon="icon16/arrow_down.png", centericon=true, disabled=pos==2, parent=xguipnl }; xguipnl.b2.DoClick = function() xguipnl.updatePos( 2 ) end
xguipnl.b3 = xlib.makebutton{ x=215, y=200, w=20, disabled=pos==3, parent=xguipnl }; xguipnl.b3.DoClick = function() xguipnl.updatePos( 3 ) end
xguipnl.updatePos = function( newpos, xoffset, yoffset, ignoreanim )
	newpos = newpos or 5; xoffset = xoffset or tonumber( xgui.settings.xguipos.xoff ); yoffset = yoffset or tonumber( xgui.settings.xguipos.yoff )
	xgui.settings.xguipos = { pos=newpos, xoff=xoffset, yoff=yoffset }
	xgui.SetPos( newpos, xoffset, yoffset, ignoreanim )
	xguipnl.b1:SetDisabled( newpos==1 ); xguipnl.b2:SetDisabled( newpos==2 ); xguipnl.b3:SetDisabled( newpos==3 )
	xguipnl.b4:SetDisabled( newpos==4 ); xguipnl.b5:SetDisabled( newpos==5 ); xguipnl.b6:SetDisabled( newpos==6 )
	xguipnl.b7:SetDisabled( newpos==7 ); xguipnl.b8:SetDisabled( newpos==8 ); xguipnl.b9:SetDisabled( newpos==9 )
end
xguipnl.xwang = xlib.makenumberwang{ x=245, y=167, w=50, min=-1000, max=1000, value=xgui.settings.xguipos.xoff, decimal=0, parent=xguipnl }
xguipnl.xwang.OnValueChanged = function( self, val ) xguipnl.updatePos( xgui.settings.xguipos.pos, tonumber( val ), xgui.settings.xguipos.yoff, true ) end
xguipnl.xwang.OnEnter = function( self )
	local val = tonumber( self:GetValue() ); if not val then val = 0 end
	xguipnl.updatePos( xgui.settings.xguipos.pos, val, xgui.settings.xguipos.yoff )
end
xguipnl.xwang.OnLoseFocus = function( self ) hook.Call( "OnTextEntryLoseFocus", nil, self ); self:OnEnter() end
xlib.makelabel{ x=300, y=169, label=xgui.T("ui_x_offset"), parent=xguipnl }
xguipnl.ywang = xlib.makenumberwang{ x=245, y=193, w=50, min=-1000, max=1000, value=xgui.settings.xguipos.yoff, decimal=0, parent=xguipnl }
xguipnl.ywang.OnValueChanged = function( self, val ) xguipnl.updatePos( xgui.settings.xguipos.pos, xgui.settings.xguipos.xoff, tonumber( val ), true ) end
xguipnl.ywang.OnEnter = function( self )
	local val = tonumber( self:GetValue() ); if not val then val = 0 end
	xguipnl.updatePos( xgui.settings.xguipos.pos, xgui.settings.xguipos.xoff, val )
end
xguipnl.ywang.OnLoseFocus = function( self ) hook.Call( "OnTextEntryLoseFocus", nil, self ); self:OnEnter() end
xlib.makelabel{ x=300, y=195, label=xgui.T("ui_y_offset"), parent=xguipnl }
xlib.makelabel{ x=175, y=229, label=xgui.T("ui_xgui_anim"), parent=xguipnl }
xlib.makelabel{ x=175, y=247, label=xgui.T("ui_anim_open"), parent=xguipnl }
xguipnl.cmbIn = xlib.makecombobox{ x=225, y=245, w=150, choices={ xgui.T("ui_anim_fade_in"), xgui.T("ui_anim_slide_top"), xgui.T("ui_anim_slide_left"), xgui.T("ui_anim_slide_bottom"), xgui.T("ui_anim_slide_right") }, enableinput=false, parent=xguipnl }
xguipnl.cmbIn:ChooseOptionID( tonumber( xgui.settings.animIntype ) or 1 )
function xguipnl.cmbIn:OnSelect( i, v, d ) xgui.settings.animIntype = i end
xlib.makelabel{ x=175, y=272, label=xgui.T("ui_anim_close"), parent=xguipnl }
xguipnl.cmbOut = xlib.makecombobox{ x=225, y=270, w=150, choices={ xgui.T("ui_anim_fade_out"), xgui.T("ui_anim_slide_top_out"), xgui.T("ui_anim_slide_left_out"), xgui.T("ui_anim_slide_bottom_out"), xgui.T("ui_anim_slide_right_out") }, enableinput=false, parent=xguipnl }
xguipnl.cmbOut:ChooseOptionID( tonumber( xgui.settings.animOuttype ) or 1 )
function xguipnl.cmbOut:OnSelect( i, v, d ) xgui.settings.animOuttype = i end
xgui.registerRefresh( "client_xgui", function()
	xguipnl.mainorder.Columns[1].Header:SetText( xgui.T("ui_main_modules") )
	xguipnl.settingorder.Columns[1].Header:SetText( xgui.T("ui_settings_modules") )
	for _, line in ipairs( xguipnl.mainorder.Lines ) do
		if line.key then line:SetColumnText( 1, xgui.T("tab_" .. line.key) ) end
	end
	for _, line in ipairs( xguipnl.settingorder.Lines ) do
		if line.key then line:SetColumnText( 1, xgui.T("tab_" .. line.key) ) end
	end
	btnRefreshXGUI:SetText( xgui.T("ui_refresh_xgui") ); btnRefreshData:SetText( xgui.T("ui_refresh_data") )
	lblAnimTime:SetText( xgui.T("ui_anim_time") ); ckShowLoadMsgs:SetText( xgui.T("ui_show_load_msgs") )
	lblInfoColor:SetText( xgui.T("ui_info_color") )
	local inChoices = { xgui.T("ui_anim_fade_in"), xgui.T("ui_anim_slide_top"), xgui.T("ui_anim_slide_left"), xgui.T("ui_anim_slide_bottom"), xgui.T("ui_anim_slide_right") }
	xguipnl.cmbIn:Clear(); for _, v in ipairs(inChoices) do xguipnl.cmbIn:AddChoice(v) end
	xguipnl.cmbIn:ChooseOptionID( tonumber( xgui.settings.animIntype ) or 1 )
	local outChoices = { xgui.T("ui_anim_fade_out"), xgui.T("ui_anim_slide_top_out"), xgui.T("ui_anim_slide_left_out"), xgui.T("ui_anim_slide_bottom_out"), xgui.T("ui_anim_slide_right_out") }
	xguipnl.cmbOut:Clear(); for _, v in ipairs(outChoices) do xguipnl.cmbOut:AddChoice(v) end
	xguipnl.cmbOut:ChooseOptionID( tonumber( xgui.settings.animOuttype ) or 1 )
end )
xgui.addSubModule( "xgui_settings", xguipnl, nil, "client" )