
local dualAmmo = { ["weapon_smg1"] = true, ["weapon_ar2"] = true }
local function translateGroup( name )
	return xgui.translateGroup( name )
end
local items = xlib.makepanel{ parent=xgui.null }
items.selitem = nil
items.mask = xlib.makepanel{ x=160, y=30, w=425, h=370, parent=items }
items.argslist = xlib.makelistlayout{ w=165, h=370, parent=items.mask }
items.argslist.secondaryPos = nil
items.argslist.scroll:SetVisible( true )
function items.argslist:Open( classname, secondary )
	if secondary then
		if items.plist.open then items.plist:Close()
		elseif self.open then self:Close() end
	end
	self:openAnim( classname, secondary )
	self.open = true
end
function items.argslist:Close()
	self:closeAnim( self.secondaryPos )
	self.open = false
end
items.plist = xlib.makelistview{ w=250, h=370, multiselect=true, parent=items.mask }
function items.plist:Open( arg )
	if items.argslist.secondaryPos == true then items.argslist:Close()
	elseif self.open then self:Close() end
	self:openAnim( arg )
	self.open = true
end
function items.plist:Close()
	if items.argslist.open then items.argslist:Close() end
	self:closeAnim()
	self.open = false
end
function items.plist:openAnim( arg )
	xlib.addToAnimQueue( items.refreshPlist )
	xlib.addToAnimQueue( "pnlSlide", { panel=self, startx=-250, starty=0, endx=0, endy=0, setvisible=true } )
end
function items.plist:closeAnim()
	xlib.addToAnimQueue( "pnlSlide", { panel=self, startx=0, starty=0, endx=-250, endy=0, setvisible=false } )
end
items.plist:SetVisible( false )
items.plist:AddColumn( ULib.ulx_lang.T("ui_player_name") )
items.plist:AddColumn( ULib.ulx_lang.T("ui_user_group") )
items.cmds = xlib.makelistlayout{ x=5, y=30, w=150, h=370, parent=items, padding=1, spacing=1 }
items.setselected = function( selcat, LineID )
	local classname = selcat.Lines[LineID]:GetColumnText(2)
	local itemtype = tonumber( selcat.Lines[LineID]:GetColumnText(3) ) or 1
	local itemkey  = selcat.Lines[LineID]:GetColumnText(4)
	if classname == items.selitem then
		selcat:ClearSelection()
		if items.plist.open then items.plist:Close() else items.argslist:Close() end
		xlib.animQueue_start()
		items.selitem = nil
		items.seltype = nil
		items.selkey = nil
		return
	end
	for _, cat in pairs( items.cmd_contents ) do
		if cat ~= selcat then cat:ClearSelection() end
	end
	items.selitem = classname
	items.seltype = itemtype
	items.selkey  = itemkey
	if xlib.animRunning then xlib.animQueue_forceStop() end
	items.plist:Open()
	xlib.addToAnimQueue( function()
		if items.argslist.open then items.argslist:Close() end
		items.argslist:Open( classname, false )
	end )
	xlib.animQueue_start()
end
function items.buildArgsList( classname )
	items.argslist:Clear()
	local T = ULib.ulx_lang.T
	local itype = items.seltype or 1
	local z = 0
	local function makeSlider( label, min, max, def )
		local p = xlib.makepanel{ h=35, parent=items.argslist }; p.xguiIgnore = true
		local sl = xlib.makeslider{ y=0, w=165, min=min, max=max, value=def, decimal=0, label="<--->", parent=p }
		xlib.makelabel{ y=20, label=label, parent=p }
		p:SetZPos( z ); z = z + 1
		return sl
	end
	local function makeBtn( label )
		local b = xlib.makebutton{ label=label, parent=items.argslist }; b.xguiIgnore = true
		b:SetZPos( z ); z = z + 1; return b
	end
	local function addLabel( txt )
		local l = vgui.Create( "DLabel", items.argslist )
		l:SetText( txt )
		l:SetWrap( true )
		l:SetAutoStretchVertical( true )
		l:SetWide( 160 )
		l:SetTextColor( Color( 0, 0, 0 ) )
		l.xguiIgnore = true
		items.argslist:Add( l ); l:SetZPos( z ); z = z + 1
	end
	local function getTargets()
		local T = ULib.ulx_lang.T
		local plys = {}
		for _, line in ipairs( items.plist:GetSelected() ) do
			if line.ply and line.ply:IsValid() then table.insert( plys, line.ply ) end
		end
		if #plys == 0 then Derma_Message( T("items_select_player"), T("ui_ok"), T("ui_ok") ) return nil end
		local t = {}
		for _, ply in ipairs( plys ) do table.insert( t, ply:SteamID64() ) end
		return t
	end
	local function sendGive( qty, extra )
		local tg = getTargets() if not tg then return end
		local xqty = math.floor( qty or 0 )
		local xextra = math.floor( extra or 0 )
		local itemName = T("itm_" .. classname)
		if itemName == "itm_" .. classname then itemName = classname end
		net.Start( "ulx_items_give" )
		net.WriteUInt( #tg, 8 )
		for _, s in ipairs( tg ) do net.WriteString( s ) end
		net.WriteString( classname ); net.WriteUInt( xqty, 16 )
		net.WriteUInt( xextra, 16 )
		net.SendToServer()
		chat.AddText( Color( 100, 255, 100 ), string.format( T("items_given"), itemName, xqty ) )
	end
	local function sendSpawn( qty )
		local tg = getTargets() if not tg then return end
		local itemName = T("itm_" .. classname)
		if itemName == "itm_" .. classname then itemName = classname end
		net.Start( "ulx_items_spawn" )
		net.WriteUInt( #tg, 8 )
		for _, s in ipairs( tg ) do net.WriteString( s ) end
		net.WriteString( classname ); net.WriteUInt( qty, 16 )
		net.WriteString( items.selkey or "" )
		net.SendToServer()
		chat.AddText( Color( 100, 255, 100 ), string.format( T("items_spawned"), itemName, qty ) )
	end
	if itype == 1 then
		makeBtn( T("items_give_btn") ).DoClick = function() sendGive( 1 ) end
	elseif itype == 2 then
		local sl
		makeBtn( T("items_give_btn") ).DoClick = function() sendGive( math.floor( sl:GetValue() ) ) end
		sl = makeSlider( T("items_qty"), 0, 9999, 10 )
		local slSpawn2
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn2:GetValue() ) ) end
		slSpawn2 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )
	elseif itype == 4 then
		makeBtn( T("items_give_weapon_btn") ).DoClick = function() sendGive( 1, 0 ) end
		local slSpawn4
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn4:GetValue() ) ) end
		slSpawn4 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )
	elseif itype == 3 then
		local isDual = dualAmmo[classname]
		local slPri, slSec, slSingle, slSpawn3
		makeBtn( T("items_give_weapon_btn") ).DoClick = function() sendGive( 1, 0 ) end
		if isDual then
			makeBtn( T("items_give_ammo_btn") ).DoClick = function()
				sendGive( math.floor( slPri:GetValue() ), math.floor( slSec:GetValue() ) )
			end
			slPri = makeSlider( T("items_primary_ammo"), 0, 9999, 200 )
			slSec = makeSlider( T("items_secondary_ammo"), 0, 9999, 50 )
		else
			makeBtn( T("items_give_ammo_btn") ).DoClick = function() sendGive( math.floor( slSingle:GetValue() ), 0 ) end
			slSingle = makeSlider( T("items_ammo_qty"), 0, 9999, 200 )
		end
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn3:GetValue() ) ) end
		slSpawn3 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )
	elseif itype == 5 then
		local slSpawn5
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn5:GetValue() ) ) end
		slSpawn5 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )
	elseif itype == 6 then
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( 1 ) end
	end
	if itype >= 2 then
		local undoBtn = xlib.makebutton{ label = xgui.T("items_spawn_undo") or "撤回上一次", parent=items.argslist }
		undoBtn.xguiIgnore = true
		undoBtn.DoClick = function()
			net.Start( "ulx_items_spawn_undo" )
			net.SendToServer()
		end
		items.argslist:Add( undoBtn ); undoBtn:SetZPos( z ); z = z + 1
		local clearBtn = xlib.makebutton{ label = xgui.T("items_spawn_clear") or "清除所有", parent=items.argslist }
		clearBtn.xguiIgnore = true
		clearBtn.DoClick = function()
			net.Start( "ulx_items_spawn_clear" )
			net.SendToServer()
		end
		items.argslist:Add( clearBtn ); clearBtn:SetZPos( z ); z = z + 1
	end
	items.argslist:InvalidateLayout( true )
end
function items.refreshPlist()
	local lastSelected = {}
	for _, line in ipairs( items.plist:GetSelected() ) do
		if line.ply and line.ply:IsValid() then
			table.insert( lastSelected, line.ply:SteamID64() )
		end
	end
	items.plist:Clear()
	local localLine = nil
	for _, ply in ipairs( player.GetAll() ) do
		local line = items.plist:AddLine( ply:Nick(), translateGroup( ply:GetUserGroup() ) )
		line.ply = ply
		if table.HasValue( lastSelected, ply:SteamID64() ) then
			items.plist:SelectItem( line )
		end
		if ply == LocalPlayer() then localLine = line end
	end
	items.plist:SortByColumn( 1, false )
	if #items.plist:GetSelected() == 0 and localLine then
		items.plist:SelectItem( localLine )
	end
	if #items.plist:GetSelected() == 0 then
		if not xlib.animRunning then
			if items.argslist.open then items.argslist:Close(); xlib.animQueue_start() end
		end
	end
end
function items.refresh()
	local T = ULib.ulx_lang.T
	items.cmds:Clear()
	items.cmd_contents = {}
	items.expandedcat = nil
	items.selitem = nil
	local lp = LocalPlayer()
	for _, catname in ipairs( ulx.itemOrder ) do
		local data = ulx.itemRegistry[catname]
		if data then
			local visibleItems = {}
			local hasAny = false
			for _, it in ipairs( data ) do
				local allowed = true
				if it.a and it.a ~= "" then
					if it.a == "superadmin" then
						allowed = LocalPlayer():IsSuperAdmin()
					elseif it.a == "admin" then
						allowed = LocalPlayer():IsAdmin()
					else
						allowed = lp:query( it.a )
					end
				end
				if allowed then
					table.insert( visibleItems, it )
					hasAny = true
				end
			end
			if hasAny then
				items.cmd_contents[catname] = xlib.makelistview{ headerheight=0, multiselect=false, h=136 }
				items.cmd_contents[catname].OnRowSelected = function( self, LineID )
					items.setselected( self, LineID )
				end
				items.cmd_contents[catname]:AddColumn( "" )
				local cat_tkeys = {
					["武器"] = "items_weapons",
					["CSS武器"] = "items_css_weapons",
					["工具"] = "items_tools",
					["弹药"] = "items_ammo",
					["道具"] = "items_props",
					["座椅"] = "items_seats",
					["载具"] = "items_vehicles",
				}
				local T = ULib.ulx_lang.T
				local tkey = cat_tkeys[catname]
				local displayName = tkey and T(tkey) or catname
				local cat = xlib.makecat{ label=displayName, contents=items.cmd_contents[catname], expanded=false, parent=xgui.null }
				function cat.Header:OnMousePressed( mcode )
					if mcode == MOUSE_LEFT then
						self:GetParent():Toggle()
						if items.expandedcat then
							if items.expandedcat ~= self:GetParent() then
								items.expandedcat:Toggle()
							else
								items.expandedcat = nil
								return
							end
						end
						items.expandedcat = self:GetParent()
						return
					end
					return self:GetParent():OnMousePressed( mcode )
				end
				for _, it in ipairs( visibleItems ) do
					local langKey = "itm_" .. it.c
					if it.k and it.k ~= "" then langKey = langKey .. "_" .. it.k end
					local itemName = T(langKey)
					if itemName == langKey then itemName = it.n end
					if it.a and it.a ~= "" then
						itemName = itemName .. " (管理员)"
					end
					items.cmd_contents[catname]:AddLine( itemName, it.c, tostring( it.t or 1 ), it.k or "" )
				end
				items.cmd_contents[catname]:SortByColumn( 1 )
				items.cmd_contents[catname]:SetHeight( 17 * #items.cmd_contents[catname]:GetLines() )
				items.cmds:Add( cat )
			end
		end
	end
end
function items.argslist:openAnim( classname, secondary )
	xlib.addToAnimQueue( function() items.argslist.secondaryPos = secondary end )
	xlib.addToAnimQueue( items.buildArgsList, classname )
	if secondary then
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=-170, starty=0, endx=0, endy=0, setvisible=true } )
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=80, starty=0, endx=255, endy=0, setvisible=true } )
	end
end
function items.argslist:closeAnim( secondary )
	if secondary then
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=0, starty=0, endx=-170, endy=0, setvisible=false } )
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=self.scroll, startx=255, starty=0, endx=80, endy=0, setvisible=false } )
	end
	xlib.addToAnimQueue( function() items.argslist.secondaryPos = nil end )
end
local cat_tkeys = {
	["武器"] = "items_weapons",
	["CSS武器"] = "items_css_weapons",
	["工具"] = "items_tools",
	["弹药"] = "items_ammo",
	["道具"] = "items_props",
	["座椅"] = "items_seats",
	["载具"] = "items_vehicles",
}
function items.refreshTexts()
	if not items.cmd_contents then return end
	local T = xgui.T
	for catname, listView in pairs( items.cmd_contents ) do
		local cat = listView:GetParent()
		if cat and cat.SetLabel then
			local tkey = cat_tkeys[catname]
			cat:SetLabel( tkey and T(tkey) or catname )
		end
		for _, line in ipairs( listView.Lines ) do
			local classname = line:GetColumnText(2)
			if classname then
				local langKey = "itm_" .. classname
				local itemKey = line:GetColumnText(4)
				if itemKey and itemKey ~= "" then langKey = langKey .. "_" .. itemKey end
				local itemName = T(langKey)
				local foundIt = nil
				for _, data in pairs( ulx.itemRegistry ) do
					for _, it in ipairs( data ) do
						if it.c == classname and (itemKey == "" or it.k == itemKey) then
							foundIt = it
							break
						end
					end
					if foundIt then break end
				end
				if itemName == langKey and foundIt then
					itemName = foundIt.n
				end
				if foundIt and foundIt.a and foundIt.a ~= "" then
					itemName = itemName .. " (管理员)"
				end
				line:SetColumnText( 1, itemName )
			end
		end
		listView:SortByColumn( 1 )
	end
	if items.plist and items.plist.Columns then
		local c1 = items.plist.Columns[1]; if c1 and c1.Header then c1.Header:SetText( T("ui_player_name") ) end
		local c2 = items.plist.Columns[2]; if c2 and c2.Header then c2.Header:SetText( T("ui_user_group") ) end
	end
	if items.plist and items.plist.Lines then
		for _, line in ipairs( items.plist.Lines ) do
			if line.ply and line.ply:IsValid() then
				line:SetColumnText( 2, translateGroup( line.ply:GetUserGroup() ) )
			end
		end
	end
	if items.argslist.open and items.selitem then
		items.buildArgsList( items.selitem )
	end
end
items.refresh()
hook.Add( "UCLChanged", "xgui_items_refresh_items", function()
	items.refresh()
end )
hook.Add( "UCLChanged", "xgui_items_refresh", items.refreshPlist )
xgui.registerRefresh( "items", function()
	items.refreshTexts()
end )
xgui.addModule( "items", items, "icon16/gun.png" )
Msg( "[ULX] 道具模块已注册\n" )