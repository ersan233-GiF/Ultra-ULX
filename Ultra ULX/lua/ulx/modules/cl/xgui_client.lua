xgui = xgui or {}
xgui.data = xgui.data or {}
xgui.hook = xgui.hook or { onProcessModules={}, onOpen={}, onClose={} }
function xgui.prepareDataType( dtype, location )
	if not xgui.data[dtype] then
		xgui.data[dtype] = location or {}
		xgui.hook[dtype] = { clear={}, process={}, done={}, add={}, update={}, remove={}, data={} }
	end
end
function xgui.hookEvent( dtype, event, func, name )
	if not xgui.hook[dtype] or ( event and not xgui.hook[dtype][event] ) then
		Msg( "XGUI: Attempted to add to invalid type or event to a hook! (" .. dtype .. ", " .. ( event or "nil" ) .. ")\n" )
	else
		if not name then name = "FixMe" .. math.floor(math.random()*10000) end
		if not event then
			xgui.hook[dtype][name] = func
		else
			xgui.hook[dtype][event][name] = func
		end
	end
end
xgui.modules = xgui.modules or {}
xgui.modules.tab = xgui.modules.tab or {}
xgui.modules.setting = xgui.modules.setting or {}
xgui.modules.submodule = xgui.modules.submodule or {}
local function registerModule( moduleList, name, panel, icon, access, tooltip, extra )
	extra = extra or {}
	for i = #moduleList, 1, -1 do
		if moduleList[i].name == name then
			if moduleList[i].panel then moduleList[i].panel:Remove() end
			if moduleList[i].tabpanel then moduleList[i].tabpanel:Remove() end
			if moduleList[i].xbutton then moduleList[i].xbutton:Remove() end
			table.remove(moduleList, i)
		end
	end
	local entry = { name=name, displayName=ULib.ulx_lang.T("tab_"..name), panel=panel, icon=icon, access=access, tooltip=tooltip }
	if extra.mtype then entry.mtype = extra.mtype end
	table.insert(moduleList, entry)
end
function xgui.addModule( name, panel, icon, access, tooltip )
	registerModule( xgui.modules.tab, name, panel, icon, access, tooltip )
end
function xgui.addSettingModule( name, panel, icon, access, tooltip )
	registerModule( xgui.modules.setting, name, panel, icon, access, tooltip )
end
function xgui.addSubModule( name, panel, access, mtype )
	registerModule( xgui.modules.submodule, name, panel, nil, access, nil, { mtype=mtype } )
end
xgui.tabcompletes = xgui.tabcompletes or {}
xgui.ulxmenucompletes = xgui.ulxmenucompletes or {}
include( "ulx/xgui/framework/init.lua" )
function xgui.init( ply )
	xgui.loadSettings()
	xgui.buildBaseWindow()
	xgui.loadAllModules()
	xgui.syncModuleOrder()
	RunConsoleCommand( "_xgui", "getInstalled" )
	xgui.initialized = true
	xgui.buildTabs()
	timer.Simple( 2, function()
		if xgui.initialized then xgui.buildTabs() end
	end )
end
hook.Add( ULib.HOOK_LOCALPLAYERREADY, "InitXGUI", xgui.init, HOOK_MONITOR_LOW )
hook.Add( "UCLChanged", "xgui_processModulesOnAuth", function()
	if xgui.initialized then xgui.processModules() end
end )
function xgui.saveClientSettings()
	if not ULib.fileIsDir( "data/ultra_ulx" ) then
		ULib.fileCreateDir( "data/ultra_ulx" )
	end
	local output = "// This file stores clientside settings for XGUI.\n"
	output = output .. ULib.makeKeyValues( xgui.settings )
	ULib.fileWrite( "data/ultra_ulx/xgui_settings.txt", output )
end
function xgui.checkModuleExists( modulename, moduletable )
	for k, v in ipairs( moduletable ) do
		if v.name == modulename then
			return k
		end
	end
	return false
end
function xgui.processModules()
	xgui.buildTabs()
	xgui.callUpdate( "onProcessModules" )
end
function xgui.checkNotInstalled( tabname )
	if xgui.notInstalledWarning then return end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	xgui.notInstalledWarning = xlib.makeframe{ label="XGUI Warning!", w=375, h=110, nopopup=true, showclose=false, skin=xgui.settings.skin }
	xlib.makelabel{ x=10, y=30, wordwrap=true, w=365, label="XGUI has not initialized properly with the server. This could be caused by a heavy server load after a mapchange, a major error during XGUI server startup, or XGUI not being installed.", parent=xgui.notInstalledWarning }
	xlib.makebutton{ x=37, y=83, w=80, label="Offline Mode", parent=xgui.notInstalledWarning }.DoClick = function()
		xgui.notInstalledWarning:Remove()
		xgui.notInstalledWarning = nil
		offlineWarning = xlib.makeframe{ label="XGUI Warning!", w=375, h=110, nopopup=true, showclose=false, skin=xgui.settings.skin }
		xlib.makelabel{ x=10, y=30, wordwrap=true, w=365, label="XGUI will run locally in offline mode. Some features will not work, and information will be missing. You can attempt to reconnect to the server using the 'Refresh Server Data' button in the XGUI client menu.", parent=offlineWarning }
		xlib.makebutton{ x=77, y=83, w=80, label="OK", parent=offlineWarning }.DoClick = function()
			offlineWarning:Remove()
			xgui.offlineMode = true
			xgui.show( tabname )
		end
		xlib.makebutton{ x=217, y=83, w=80, label="Cancel", parent=offlineWarning }.DoClick = function()
			offlineWarning:Remove()
			RememberCursorPosition()
			gui.EnableScreenClicker( false )
		end
	end
	xlib.makebutton{ x=257, y=83, w=80, label="Close", parent=xgui.notInstalledWarning }.DoClick = function()
		xgui.notInstalledWarning:Remove()
		xgui.notInstalledWarning = nil
		RememberCursorPosition()
		gui.EnableScreenClicker( false )
	end
	xlib.makebutton{ x=147, y=83, w=80, label="Try Again", parent=xgui.notInstalledWarning }.DoClick = function()
		xgui.notInstalledWarning:Remove()
		xgui.notInstalledWarning = nil
		RememberCursorPosition()
		gui.EnableScreenClicker( false )
		local reattempt = xlib.makeframe{ label="XGUI: Attempting reconnection...", w=200, h=20, nopopup=true, showclose=false, skin=xgui.settings.skin }
		timer.Simple( 1, function()
			RunConsoleCommand( "_xgui", "getInstalled" )
			reattempt:Remove()
			timer.Simple( 0.5, function() xgui.show( tabname ) end )
		end )
	end
end
function xgui.show( tabname )
	if not xgui.anchor then return end
	if not xgui.initialized then return end
	if not xgui.isInstalled and not xgui.offlineMode then
		xgui.checkNotInstalled( tabname )
		return
	end
	if not game.SinglePlayer() and not ULib.ucl.authed[LocalPlayer():UniqueID()] then
		local unauthedWarning = xlib.makeframe{ label="XGUI Error!", w=250, h=90, showclose=true, skin=xgui.settings.skin }
		xlib.makelabel{ label="Your ULX player has not been Authed!", x=10, y=30, parent=unauthedWarning }
		xlib.makelabel{ label="Please wait a couple seconds and try again.", x=10, y=45, parent=unauthedWarning }
		xlib.makebutton{ x=50, y=63, w=60, label="Try Again", parent=unauthedWarning }.DoClick = function()
			unauthedWarning:Remove()
			xgui.show( tabname )
		end
		xlib.makebutton{ x=140, y=63, w=60, label="Close", parent=unauthedWarning }.DoClick = function()
			unauthedWarning:Remove()
		end
		return
	end
	if xgui.base.refreshSkin then
		xgui.base:SetSkin( xgui.settings.skin )
		xgui.base.refreshSkin = nil
	end
	if type( tabname ) == "table" then
		tabname = table.concat( tabname, " " )
	end
	if tabname and tabname ~= "" then
		local found, settingsTab
		for _, v in ipairs( xgui.modules.tab ) do
			if string.lower( v.name ) == "settings" then settingsTab = v.tabpanel end
			if string.lower( v.name ) == string.lower( tabname ) and v.panel:GetParent() ~= xgui.null then
				xgui.base:SetActiveTab( v.tabpanel )
				if xgui.anchor:IsVisible() then return end
				found = true
				break
			end
		end
		if not found then
			for _, v in ipairs( xgui.modules.setting ) do
				if string.lower( v.name ) == string.lower( tabname ) and v.panel:GetParent() ~= xgui.null then
					xgui.base:SetActiveTab( settingsTab )
					xgui.settings_tabs:SetActiveTab( v.tabpanel )
					if xgui.anchor:IsVisible() then return end
					found = true
					break
				end
			end
		end
		if not found then return end
	end
	xgui.base.animOpen()
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	xgui.anchor:SetMouseInputEnabled( true )
	xgui.callUpdate( "onOpen" )
end
function xgui.hide()
	if not xgui.anchor then return end
	if not xgui.anchor:IsVisible() then return end
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
	xgui.anchor:SetMouseInputEnabled( false )
	xgui.base.animClose()
	CloseDermaMenus()
	xgui.callUpdate( "onClose" )
end
function xgui.toggle( tabname )
	if xgui.anchor and ( not xgui.anchor:IsVisible() or ( tabname and #tabname ~= 0 ) ) then
		xgui.show( tabname )
	else
		xgui.hide()
	end
end
function xgui.expectChunks( numofchunks )
	if xgui.isInstalled then
		xgui.expectingdata = true
		xgui.chunkbox.max = numofchunks
		xgui.chunkbox.value = 0
		xgui.chunkbox:SetFraction( 0 )
		xgui.chunkbox.Label:SetText( "Getting data: Waiting for server..." )
		xgui.chunkbox:SetVisible( true )
		xgui.chunkbox:SetSkin( xgui.settings.skin )
		xgui.flushQueue( "chunkbox" )
	end
end
function xgui.getChunk( flag, datatype, data )
	if xgui.expectingdata then
		if flag == -1 then
		elseif flag == 0 then
			if xgui.data[datatype] then
				table.Empty( xgui.data[datatype] )
			end
			xgui.flushQueue( datatype )
			xgui.callUpdate( datatype, "clear" )
		elseif flag == 1 then
			if not xgui.mergeData then
				if not data then data = {} end
				xgui.flushQueue( datatype )
				if not xgui.data[datatype] then xgui.data[datatype] = {} end
				table.Empty( xgui.data[datatype] )
				table.Merge( xgui.data[datatype], data )
				xgui.callUpdate( datatype, "clear" )
				xgui.callUpdate( datatype, "process", data )
				xgui.callUpdate( datatype, "done" )
			else
				if not xgui.data[datatype] then xgui.data[datatype] = {} end
				table.Merge( xgui.data[datatype], data )
				xgui.callUpdate( datatype, "process", data )
			end
		elseif flag == 2 or flag == 3 then
			if not xgui.data[datatype] then xgui.data[datatype] = {} end
			table.Merge( xgui.data[datatype], data )
			xgui.callUpdate( datatype, flag == 2 and "add" or "update", data )
		elseif flag == 4 then
			if not xgui.data[datatype] then xgui.data[datatype] = {} end
			xgui.removeDataEntry( xgui.data[datatype], data )
			xgui.callUpdate( datatype, "remove", data )
		elseif flag == 5 then
			if not xgui.data[datatype] then xgui.data[datatype] = {} end
			table.Empty( xgui.data[datatype] )
			xgui.mergeData = true
			xgui.flushQueue( datatype )
			xgui.callUpdate( datatype, "clear" )
		elseif flag == 6 then
			xgui.mergeData = nil
			xgui.callUpdate( datatype, "done" )
		elseif flag == 7 then
			xgui.callUpdate( datatype, "data", data )
		end
		xgui.chunkbox:Progress( datatype )
	end
end
function xgui.removeDataEntry( data, entry )
	for k, v in pairs( entry ) do
		if type( v ) == "table" then
			xgui.removeDataEntry( data[k], v )
		else
			if type(v) == "number" then
				table.remove( data, v )
			else
				data[v] = nil
			end
		end
	end
end
function xgui.callUpdate( dtype, event, data )
	if not xgui.hook[dtype] or ( event and not xgui.hook[dtype][event] ) then
		Msg( "XGUI: Attempted to call non-existent type or event to a hook! (" .. dtype .. ", " .. ( event or "nil" ) .. ")\n" )
	else
		if not event then
			for name, func in pairs( xgui.hook[dtype] ) do func( data ) end
		else
			for name, func in pairs( xgui.hook[dtype][event] ) do func( data ) end
		end
	end
end
function xgui.PermissionsChanged( ply )
	if ply == LocalPlayer() and xgui.isInstalled and xgui.dataInitialized then
		xgui.processModules()
		local types = {}
		for dtype, data in pairs( xgui.data ) do
			if table.Count( data ) > 0 then table.insert( types, dtype ) end
		end
		RunConsoleCommand( "xgui", "refreshdata", unpack( types ) )
	end
end
hook.Add( "UCLAuthed", "XGUI_PermissionsChanged", xgui.PermissionsChanged )
function xgui.getInstalled()
	if not xgui.isInstalled then
		if xgui.notInstalledWarning then
			xgui.notInstalledWarning:Remove()
			xgui.notInstalledWarning = nil
		end
		xgui.isInstalled = true
		xgui.offlineMode = false
		RunConsoleCommand( "xgui", "getdata" )
	end
end
function xgui.cmd_base( ply, func, args )
	if not args[ 1 ] then
		xgui.toggle()
	elseif xgui.isInstalled then
		RunConsoleCommand( "_xgui", unpack( args ) )
	end
end
function xgui.tab_completes()
	return xgui.tabcompletes
end
function xgui.ulxmenu_tab_completes()
	return xgui.ulxmenucompletes
end
ULib.cmds.addCommandClient( "xgui", xgui.cmd_base )
ULib.cmds.addCommandClient( "xgui show", function( ply, cmd, args ) xgui.show( args ) end, xgui.tab_completes )
ULib.cmds.addCommandClient( "xgui hide", xgui.hide )
ULib.cmds.addCommandClient( "xgui toggle", function() xgui.toggle() end )
ULib.cmds.addCommandClient( "ulx menu", function( ply, cmd, args ) xgui.toggle( args ) end, xgui.ulxmenu_tab_completes )