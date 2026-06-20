include( "ulx/xgui/framework/layout.lua" )
function xgui.loadSettings()
	xgui.settings = xgui.settings or {}
	if ULib.fileExists( "data/ultra_ulx/xgui_settings.txt" ) then
		local input = ULib.fileRead( "data/ultra_ulx/xgui_settings.txt" )
		input = input:match( "^.-\n(.*)$" )
		xgui.settings = ULib.parseKeyValues( input )
	end
	if not xgui.settings.moduleOrder then xgui.settings.moduleOrder = { "commands", "groups", "maps", "settings", "bans", "items" } end
	if not xgui.settings.settingOrder then xgui.settings.settingOrder = { "sandbox", "server", "client" } end
	if not xgui.settings.animTime then xgui.settings.animTime = 0.22 else xgui.settings.animTime = tonumber( xgui.settings.animTime ) end
	if not xgui.settings.infoColor then
		xgui.settings.infoColor = Color( 40, 200, 220, 160 )
	else
		xgui.settings.infoColor = Color(xgui.settings.infoColor.r, xgui.settings.infoColor.g, xgui.settings.infoColor.b, xgui.settings.infoColor.a)
	end
	if not xgui.settings.showLoadMsgs then xgui.settings.showLoadMsgs = true else xgui.settings.showLoadMsgs = ULib.toBool( xgui.settings.showLoadMsgs ) end
	if not xgui.settings.skin then xgui.settings.skin = "Default" end
	if not xgui.settings.xguipos then xgui.settings.xguipos = { pos=5, xoff=0, yoff=0 } end
	if not xgui.settings.animIntype then xgui.settings.animIntype = 1 end
	if not xgui.settings.animOuttype then xgui.settings.animOuttype = 1 end
	if not xgui.settings.clickOutClose then xgui.settings.clickOutClose = false else xgui.settings.clickOutClose = ULib.toBool( xgui.settings.clickOutClose ) end
end
function xgui.buildBaseWindow()
	xgui.load_helpers()
	xgui.makeXGUIbase{}
	xgui.infobar = xlib.makepanel{ x=10, y=399, w=580, h=20, parent=xgui.anchor }
	xgui.infobar:NoClipping( true )
	xgui.infobar.Paint = function( self, w, h )
		draw.RoundedBoxEx( 4, 0, 1, 580, 20, xgui.settings.infoColor, false, false, true, true )
	end
	local infoLabel = string.format( "\n" .. ULib.ulx_lang.T("xgui_infobar"), ulx.VERSION_STR or "v2.69.1", ULib.pluginVersionStr("ULX"), ULib.pluginVersionStr("ULib") )
	xgui.infoLabel = xlib.makelabel{ x=5, y=-10, label=infoLabel, parent=xgui.infobar }
	xgui.infoLabel:NoClipping( true )
	xgui.thetime = xlib.makelabel{ x=515, y=-10, label="", parent=xgui.infobar }
	xgui.thetime:NoClipping( true )
	xgui.thetime.check = function()
		xgui.thetime:SetText( os.date( "\n%I:%M:%S %p" ) )
		xgui.thetime:SizeToContents()
		timer.Simple( 1, xgui.thetime.check )
	end
	xgui.thetime.check()
	xgui.null = xlib.makepanel{ x=-10, y=-10, w=0, h=0 }
	xgui.null:SetVisible( false )
end
function xgui.loadAllModules()
	local sm = xgui.settings.showLoadMsgs
	if sm then Msg( "// Loading GUI Modules... //\n" ) end
	include( "ulx/xgui/xgui_core.lua" )
	local xgui_main = { "bans.lua", "commands.lua", "groups.lua", "items.lua", "maps.lua", "settings.lua" }
	for _, f in ipairs( xgui_main ) do
		include( "ulx/xgui/" .. f )
		if sm then Msg( "//   " .. f .. " //\n" ) end
	end
	local xgui_settings = { "client.lua", "server.lua" }
	for _, f in ipairs( xgui_settings ) do
		include( "ulx/xgui/settings/" .. f )
	end
	if ULib.isSandbox() and GAMEMODE.FolderName ~= "sandbox" then
		include( "ulx/xgui/gamemodes/sandbox.lua" )
	end
	local gamemodeFile = string.lower( GAMEMODE.FolderName ) .. ".lua"
	for _, f in ipairs({ "sandbox.lua" }) do
		if f == gamemodeFile then
			include( "ulx/xgui/gamemodes/" .. f )
			break
		end
	end
end
function xgui.syncModuleOrder()
	local function checkModulesOrder( moduleTable, sortTable )
		for _, m in ipairs( moduleTable ) do
			local notlisted = true
			for _, existing in ipairs( sortTable ) do
				if m.name == existing then notlisted = false; break end
			end
			if notlisted then table.insert( sortTable, m.name ) end
		end
	end
	checkModulesOrder( xgui.modules.tab, xgui.settings.moduleOrder )
	checkModulesOrder( xgui.modules.setting, xgui.settings.settingOrder )
end
function xgui.buildTabs()
	if not game.SinglePlayer() and not ULib.ucl.authed[LocalPlayer():UniqueID()] then return end
	local activetab = nil
	if xgui.base:GetActiveTab() then activetab = xgui.base:GetActiveTab():GetValue() end
	local activesettingstab = nil
	if xgui.settings_tabs:GetActiveTab() then activesettingstab = xgui.settings_tabs:GetActiveTab():GetValue() end
	for _, list in ipairs({ xgui.modules.tab, xgui.modules.setting, xgui.modules.submodule }) do
		for _, m in ipairs( list ) do
			m.displayName = ULib.ulx_lang.T( "tab_" .. m.name )
		end
	end
	xgui.base:Clear()
	for _, modname in ipairs( xgui.settings.moduleOrder ) do
		for _, m in ipairs( xgui.modules.tab ) do
			if m.name == modname then
				xgui.layout.addCloseButton( m.panel )
				if LocalPlayer():query( m.access ) then
					xgui.base:AddSheet( m.displayName, m.panel, m.icon, false, false, m.tooltip )
					m.tabpanel = xgui.base.Items[#xgui.base.Items].Tab
				else
					m.tabpanel = nil
					m.panel:SetParent( xgui.null )
				end
			end
		end
	end
	xgui.settings_tabs:Clear()
	for _, modname in ipairs( xgui.settings.settingOrder ) do
		for _, m in ipairs( xgui.modules.setting ) do
			if m.name == modname then
				if LocalPlayer():query( m.access ) then
					xgui.settings_tabs:AddSheet( m.displayName, m.panel, m.icon, false, false, m.tooltip )
					m.tabpanel = xgui.settings_tabs.Items[#xgui.settings_tabs.Items].Tab
				else
					m.tabpanel = nil
					m.panel:SetParent( xgui.null )
				end
			end
		end
	end
	xgui.tabcompletes = {}
	xgui.ulxmenucompletes = {}
	for _, list in ipairs({ xgui.modules.tab, xgui.modules.setting }) do
		for _, m in ipairs( list ) do
			table.insert( xgui.tabcompletes, "xgui show " .. m.name )
			table.insert( xgui.ulxmenucompletes, "ulx menu " .. m.name )
		end
	end
	table.sort( xgui.tabcompletes )
	table.sort( xgui.ulxmenucompletes )
	local function restoreActiveTab( sheet, prevTab, items )
		if prevTab and items then
			for _, v in pairs( items ) do
				if v.Tab:GetValue() == prevTab then
					sheet:SetActiveTab( v.Tab, true )
					return
				end
			end
			sheet.m_pActiveTab = "none"
			if items[1] then sheet:SetActiveTab( items[1].Tab, true ) end
		end
	end
	restoreActiveTab( xgui.base, activetab, xgui.base.Items )
	restoreActiveTab( xgui.settings_tabs, activesettingstab, xgui.settings_tabs.Items )
end
Msg( "[XGUI] 框架初始化完成\n" )
