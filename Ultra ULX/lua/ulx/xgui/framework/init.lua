include( "ulx/xgui/framework/theme.lua" )
include( "ulx/xgui/framework/layout.lua" )
include( "ulx/xgui/framework/modern_layout.lua" )
function xgui.loadSettings()
	xgui.settings = xgui.settings or {}
	if ULib.fileExists( "data/ultra_ulx/xgui_settings.txt" ) then
		local input = ULib.fileRead( "data/ultra_ulx/xgui_settings.txt" )
		if input then
			input = input:match( "^.-\n(.*)$" ) or input
			local parsed = ULib.parseKeyValues( input )
			if parsed then xgui.settings = parsed end
		end
	end
	if not xgui.settings.moduleOrder then xgui.settings.moduleOrder = { "commands", "groups", "maps", "settings", "bans", "items" } end
	if not xgui.settings.settingOrder then xgui.settings.settingOrder = { "sandbox", "server", "client" } end
	if not xgui.settings.animTime then
		xgui.settings.animTime = 0.22
	else
		local t = tonumber( xgui.settings.animTime )
		if t then xgui.settings.animTime = t else xgui.settings.animTime = 0.22 end
	end
	if not xgui.settings.infoColor then
		xgui.settings.infoColor = Color( 40, 200, 220, 160 )
	else
		local ic = xgui.settings.infoColor
		local r, g, b, a = tonumber(ic.r) or 40, tonumber(ic.g) or 200, tonumber(ic.b) or 220, tonumber(ic.a) or 160
		xgui.settings.infoColor = Color( r, g, b, a )
	end
	if not xgui.settings.showLoadMsgs then
		xgui.settings.showLoadMsgs = true
	else
		xgui.settings.showLoadMsgs = ULib.toBool( xgui.settings.showLoadMsgs ) or true
	end
	if not xgui.settings.skin then xgui.settings.skin = "Default" end
	if not xgui.settings.xguipos then xgui.settings.xguipos = { pos=5, xoff=0, yoff=0 } end
	if not xgui.settings.animIntype then xgui.settings.animIntype = 1 end
	if not xgui.settings.animOuttype then xgui.settings.animOuttype = 1 end
	if not xgui.settings.clickOutClose then
		xgui.settings.clickOutClose = false
	else
		xgui.settings.clickOutClose = ULib.toBool( xgui.settings.clickOutClose ) or false
	end
end
function xgui.buildBaseWindow()
	xgui.load_helpers()
	xgui.makeXGUIbase{}
	xgui.infobar = xlib.makepanel{ x=10, y=399, w=580, h=20, parent=xgui.anchor }
	xgui.infobar:NoClipping( true )
	xgui.infobar.Paint = function( self, w, h )
		draw.RoundedBoxEx( 4, 0, 1, 580, 20, xgui.settings.infoColor, false, false, true, true )
	end
   local infoLabel = string.format( "\n" .. ULib.ulx_lang.T("xgui_infobar"), ulx.VERSION_STR or "v2.98.51", ULib.pluginVersionStr("ULX"), ULib.pluginVersionStr("ULib") )
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
	local folderName = GAMEMODE and GAMEMODE.FolderName and string.lower(GAMEMODE.FolderName) or "sandbox"
	if ULib.isSandbox() and folderName ~= "sandbox" then
		include( "ulx/xgui/gamemodes/sandbox.lua" )
	end
	local gamemodeFile = folderName .. ".lua"
	for _, f in ipairs({ "sandbox.lua", "darkrp.lua", "troubleinterroristtown.lua" }) do
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
	if not game.SinglePlayer() then
		local lp = LocalPlayer()
		if not IsValid(lp) then return end
		if not (ULib.ucl and ULib.ucl.authed and ULib.ucl.authed[lp:UniqueID()]) then return end
	end
	local activetab = xgui.base:GetActiveTab() and xgui.base:GetActiveTab():GetValue()
	local activesettingstab = xgui.settings_tabs:GetActiveTab() and xgui.settings_tabs:GetActiveTab():GetValue()
	for _, list in ipairs({ xgui.modules.tab, xgui.modules.setting, xgui.modules.submodule }) do
		for _, m in ipairs( list ) do
			m.displayName = ULib.ulx_lang and ULib.ulx_lang.T( "tab_" .. m.name ) or m.name
		end
	end
	local function buildSheet( sheet, moduleList, orderList, addCloseBtn )
		sheet:Clear()
		for _, modname in ipairs( orderList ) do
			for _, m in ipairs( moduleList ) do
				if m.name == modname then
					if addCloseBtn then xgui.layout.addCloseButton( m.panel ) end
					if LocalPlayer():query( m.access ) then
						sheet:AddSheet( m.displayName, m.panel, m.icon, false, false, m.tooltip )
						if sheet.Items and #sheet.Items > 0 then
							m.tabpanel = sheet.Items[#sheet.Items].Tab
						end
					else
						m.tabpanel = nil
						m.panel:SetParent( xgui.null )
					end
				end
			end
		end
	end
	buildSheet( xgui.base, xgui.modules.tab, xgui.settings.moduleOrder, true )
	buildSheet( xgui.settings_tabs, xgui.modules.setting, xgui.settings.settingOrder, false )
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