xlib = {}
function xlib.makecheckbox( t )
	local pnl = vgui.Create( "DCheckBoxLabel", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetText( t.label or "" )
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[2], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SizeToContents()
	pnl:SetValue( t.value or 0 )
	pnl:SetZPos( t.zpos or 0 )
	if t.convar then pnl:SetConVar( t.convar ) end
	if t.textcolor then
		pnl:SetTextColor( t.textcolor )
	else
		pnl:SetTextColor( SKIN.text_dark )
	end
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetTooltip( t.tooltip )
	end
	function pnl:SetDisabled( val )
		pnl.disabled = val
		pnl:SetMouseInputEnabled( not val )
		pnl:SetAlpha( val and 128 or 255 )
	end
	if t.disabled then pnl:SetDisabled( t.disabled ) end
	local tempfunc = pnl.SetParent
	pnl.SetParent = function( self, parent )
		local ret = tempfunc( self, parent )
		self:SetDisabled( self.disabled )
		return ret
	end
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		pnl:SetValue( GetConVar( t.repconvar ):GetBool() )
		function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
			if cl_cvar == t.repconvar:lower() then
				pnl:SetValue( new_val )
			end
		end
		hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
		function pnl:OnChange( bVal )
			RunConsoleCommand( t.repconvar, tostring( bVal and 1 or 0 ) )
		end
		pnl.Think = function() end
		pnl.ConVarNumberThink = function() end
		pnl.ConVarStringThink = function() end
		pnl.ConVarChanged = function() end
	end
	return pnl
end
function xlib.makelabel( t )
	local pnl = vgui.Create( "DLabel", t.parent )
	pnl:SetPos( t.x, t.y )
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[2], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SetText( t.label or "" )
	pnl:SetZPos( t.zpos or 0 )
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetTooltip( t.tooltip )
		pnl:SetMouseInputEnabled( true )
	end
	if t.font then pnl:SetFont( t.font ) end
	if t.w and t.wordwrap then
		pnl:SetText( xlib.wordWrap( t.label, t.w, t.font or "Default" ) )
		pnl:SetWrap( true )
		pnl:SetAutoStretchVertical( true )
		pnl:SetWidth( t.w )
		pnl:SizeToContents()
	else
		pnl:SizeToContents()
		if t.w then pnl:SetWidth( t.w ) end
	end
	if t.h then pnl:SetHeight( t.h ) end
	if t.textcolor then
		pnl:SetTextColor( t.textcolor )
	else
		pnl:SetTextColor( SKIN.text_dark )
	end
	return pnl
end
function xlib.makelistlayout( t )
	if t.enablescroll == nil then
		t.enablescroll = true
	end
	local pnl = vgui.Create( "DListLayout" )
	if t.enablescroll then
		pnl.scroll = vgui.Create( "DScrollPanel", t.parent )
		pnl.scroll:SetPos( t.x, t.y )
		pnl.scroll:SetSize( t.w, t.h )
		pnl:SetSize( t.w, t.h )
		pnl.scroll:AddItem( pnl )
		pnl:SetZPos( t.zpos or 0 )
		function pnl:PerformLayout()
			self:SizeToChildren( false, true )
			self:SetWide( self.scroll:GetWide() - ( self.scroll.VBar.Enabled and 16 or 0 ) )
		end
	else
		pnl:SetParent( t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		pnl:SetZPos( t.zpos or 0 )
		function pnl:PerformLayout()
			self:SizeToChildren( false, true )
		end
	end
	return pnl
end
function xlib.makebutton( t )
	local pnl = vgui.Create( "DButton", t.parent )
	pnl:SetSize( t.w or 20, t.h or 20 )
	pnl:SetPos( t.x, t.y )
	pnl:SetText( t.label or "" )
	pnl:SetDisabled( t.disabled )
	pnl:SetZPos( t.zpos or 0 )
	if t.icon then pnl:SetIcon( t.icon ) end
	if t.font then pnl:SetFont( t.font ) end
	if t.btype and t.btype == "close" then
		pnl.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "WindowCloseButton", panel, w, h ) end
	end
	if t.centericon then
		function pnl:PerformLayout()
			if ( IsValid( self.m_Image ) ) then
				self.m_Image:SetPos( (self:GetWide() - self.m_Image:GetWide()) * 0.5, (self:GetTall() - self.m_Image:GetTall()) * 0.5 )
				self:SetTextInset( self.m_Image:GetWide() + 16, 0 )
			end
			DLabel.PerformLayout( self )
		end
	end
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetTooltip( t.tooltip )
		pnl:SetMouseInputEnabled( true )
	end
	return pnl
end
function xlib.makeframe( t )
	local pnl = vgui.Create( "DFrame", t.parent )
	pnl:SetSize( t.w, t.h )
	if t.nopopup ~= true then pnl:MakePopup() end
	pnl:SetPos( t.x or ScrW()/2-t.w/2, t.y or ScrH()/2-t.h/2 )
	pnl:SetTitle( t.label or "" )
	if t.draggable ~= nil then pnl:SetDraggable( t.draggable ) end
	if t.showclose ~= nil then pnl:ShowCloseButton( t.showclose ) end
	if t.skin then pnl:SetSkin( t.skin ) end
	if t.visible ~= nil then pnl:SetVisible( t.visible ) end
	return pnl
end
function xlib.makepropertysheet( t )
	local pnl = vgui.Create( "DPropertySheet", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	function pnl:Clear()
		for _, Sheet in ipairs( self.Items ) do
			Sheet.Panel:SetParent( t.offloadparent )
			Sheet.Tab:Remove()
		end
		self.m_pActiveTab = nil
		self:SetActiveTab( nil )
		self.tabScroller.Panels = {}
		self.Items = {}
	end
	return pnl
end
function xlib.maketextbox( t )
	local pnl = vgui.Create( "DTextEntry", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetWide( t.w )
	pnl:SetTall( t.h or 20 )
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[3], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SetEnterAllowed( true )
	pnl:SetZPos( t.zpos or 0 )
	if t.convar then pnl:SetConVar( t.convar ) end
	if t.text then pnl:SetText( t.text ) end
	if t.enableinput then pnl:SetEnabled( t.enableinput ) end
	if t.multiline then pnl:SetMultiline( t.multiline ) end
	pnl.selectAll = t.selectall
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetTooltip( t.tooltip )
	end
	function pnl:SetDisabled( val )
		pnl:SetEnabled( not val )
		pnl:SetMouseInputEnabled( not val )
		pnl:SetAlpha( val and 128 or 255 )
	end
	if t.disabled then pnl:SetDisabled( t.disabled ) end
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		pnl:SetValue( GetConVar( t.repconvar ):GetString() )
		function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
			if cl_cvar == t.repconvar:lower() then
				pnl:SetValue( new_val )
			end
		end
		hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
		function pnl:UpdateConvarValue()
			RunConsoleCommand( t.repconvar, self:GetValue() )
		end
		function pnl:OnEnter()
			RunConsoleCommand( t.repconvar, self:GetValue() )
		end
		pnl.Think = function() end
		pnl.ConVarNumberThink = function() end
		pnl.ConVarStringThink = function() end
		pnl.ConVarChanged = function() end
	end
	return pnl
end
function xlib.makelistview( t )
	local pnl = vgui.Create( "DListView", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	pnl:SetMultiSelect( t.multiselect )
	pnl:SetHeaderHeight( t.headerheight or 20 )
	return pnl
end
function xlib.makecat( t )
	local pnl = vgui.Create( "DCollapsibleCategory", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	pnl:SetLabel( t.label or "" )
	pnl:SetContents( t.contents )
	t.contents:SetParent( pnl )
	t.contents:Dock( TOP )
	if t.expanded ~= nil then pnl:SetExpanded( t.expanded ) end
	if t.checkbox then
		pnl.checkBox = vgui.Create( "DCheckBox", pnl.Header )
		pnl.checkBox:SetValue( t.expanded )
		function pnl.checkBox:DoClick()
			self:Toggle()
			pnl:Toggle()
		end
		function pnl.Header:OnMousePressed( mcode )
			if ( mcode == MOUSE_LEFT ) then
				self:GetParent():Toggle()
				self:GetParent().checkBox:Toggle()
				return
			end
			return self:GetParent():OnMousePressed( mcode )
		end
		local tempfunc = pnl.PerformLayout
		pnl.PerformLayout = function( self )
			tempfunc( self )
			self.checkBox:SetPos( self:GetWide()-18, 2 )
		end
	end
	function pnl:SetOpen( bVal )
		if not self:GetExpanded() and bVal then
			pnl.Header:OnMousePressed( MOUSE_LEFT )
		elseif self:GetExpanded() and not bVal then
			pnl.Header:OnMousePressed( MOUSE_LEFT )
		end
	end
	return pnl
end
function xlib.makepanel( t )
	local pnl = vgui.Create( "DPanel", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[2], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SetZPos( t.zpos or 0 )
	if t.skin then pnl:SetSkin( t.skin ) end
	if t.visible ~= nil then pnl:SetVisible( t.visible ) end
	return pnl
end
function xlib.makescrollpanel( t )
	local pnl = vgui.Create( "DScrollPanel", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[2], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SetZPos( t.zpos or 0 )
	if t.skin then pnl:SetSkin( t.skin ) end
	if t.visible ~= nil then pnl:SetVisible( t.visible ) end
	return pnl
end
function xlib.makeXpanel( t )
	local pnl = vgui.Create( "xlib_Panel", t.parent )
	pnl:MakePopup()
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	if t.visible ~= nil then pnl:SetVisible( t.visible ) end
	return pnl
end
function xlib.makenumberwang( t )
	local pnl = vgui.Create( "DNumberWang", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetDecimals( t.decimal or 0 )
	pnl:SetMinMax( t.min or 0, t.max or 255 )
	pnl:SizeToContents()
	pnl:SetValue( t.value )
	pnl:SetZPos( t.zpos or 0 )
	if t.w then pnl:SetWide( t.w ) end
	if t.h then pnl:SetTall( t.h ) end
	return pnl
end
function xlib.makecombobox( t )
	local pnl = vgui.Create( "DComboBox", t.parent )
	t.w = t.w or 100
	t.h = t.h or 20
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[2], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	pnl:SetZPos( t.zpos or 0 )
	if ( t.enableinput == true ) then
		pnl.TextEntry = vgui.Create( "DTextEntry", pnl )
		pnl.TextEntry.selectAll = t.selectall
		pnl.TextEntry:SetEditable( true )
		pnl.TextEntry.OnGetFocus = function( self )
			hook.Run( "OnTextEntryGetFocus", self )
			if ( pnl.Menu ) then
				pnl.Menu:Remove()
				pnl.Menu = nil
			end
		end
		pnl.GetValue = function( self ) return self.TextEntry:GetValue() end
		pnl.SetText = function( self, val ) self.TextEntry:SetValue( val ) end
		pnl.ChooseOption = function( self, value, index )
			if ( self.Menu ) then
				self.Menu:Remove()
				self.Menu = nil
			end
			self.TextEntry:SetText( value )
			self:OnSelect( index, value, self.Data[index] )
		end
		pnl.PerformLayout = function( self )
			self.DropButton:SetSize( 15, 15 )
			self.DropButton:AlignRight( 4 )
			self.DropButton:CenterVertical()
			self.TextEntry:SetSize( self:GetWide()-20, self:GetTall() )
		end
	end
	pnl:SetText( t.text or "" )
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetTooltip( t.tooltip )
	end
	if t.choices then
		for i, v in ipairs( t.choices ) do
			pnl:AddChoice( v )
		end
	end
	function pnl:SetDisabled( val )
		self:SetMouseInputEnabled( not val )
		self:SetAlpha( val and 128 or 255 )
	end
	if t.disabled then pnl:SetDisabled( t.disabled ) end
	function pnl:OpenMenu()
		if ( #self.Choices == 0 ) then return end
		if ( IsValid( self.Menu ) ) then
			self.Menu:Remove()
			self.Menu = nil
		end
		self.Menu = DermaMenu()
		self.Menu:SetSkin( xgui.settings.skin )
		for k, v in pairs( self.Choices ) do
			if v == "--*" then
				self.Menu:AddSpacer()
			else
				self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
			end
		end
		local x, y = self:LocalToScreen( 0, self:GetTall() )
		self.Menu:SetMinimumWidth( self:GetWide() )
		self.Menu:Open( x, y, false, self )
	end
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		if t.isNumberConvar then
			if t.numOffset == nil then t.numOffset = 1 end
			local cvar = GetConVar( t.repconvar ):GetInt()
			if tonumber( cvar ) and cvar + t.numOffset <= #pnl.Choices and cvar + t.numOffset > 0 then
				pnl:ChooseOptionID( cvar + t.numOffset )
			else
				pnl:SetText( "Invalid Convar Value" )
			end
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					if tonumber( new_val ) and new_val + t.numOffset <= #pnl.Choices and new_val + t.numOffset > 0 then
						pnl:ChooseOptionID( new_val + t.numOffset )
					else
						pnl:SetText( "Invalid Convar Value" )
					end
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:OnSelect( index )
				RunConsoleCommand( t.repconvar, tostring( index - t.numOffset ) )
			end
		else
			pnl:SetText( GetConVar( t.repconvar ):GetString() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					if t.convarblanklabel and new_val == "" then new_val = t.convarblanklabel end
					pnl:SetText( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:OnSelect( index, value )
				if t.convarblanklabel and value == "<not specified>" then value = "" end
				RunConsoleCommand( t.repconvar, value )
			end
		end
	end
	return pnl
end
function xlib.maketree( t )
	local pnl = vgui.Create( "DTree", t.parent )
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )
	function pnl:Clear()
		if self.RootNode.ChildNodes then
			for _, node in ipairs( self.RootNode.ChildNodes:GetChildren() ) do
				node:Remove()
			end
			self.m_pSelectedItem = nil
			self:InvalidateLayout()
		end
	end
	return pnl
end
function xlib.makecolorpicker( t )
	local pnl = vgui.Create( "xlibColorPanel", t.parent )
	pnl:SetPos( t.x, t.y )
	if t.noalphamodetwo then pnl:NoAlphaModeTwo() end
	if t.addalpha then
		pnl:AddAlphaBar()
		if t.alphamodetwo then pnl:AlphaModeTwo() end
	end
	if t.color then pnl:SetColor( t.color ) end
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		local col = GetConVar( t.repconvar ):GetString()
		if col == "0" then col = "0 0 0" end
		col = string.Split( col, " " )
		pnl:SetColor( Color( col[1], col[2], col[3] ) )
		function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
			if cl_cvar == t.repconvar:lower() then
				local col = string.Split( new_val, " " )
				pnl:SetColor( Color( col[1], col[2], col[3] ) )
			end
		end
		hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
		function pnl:OnChange( color )
			RunConsoleCommand( t.repconvar, color.r .. " " .. color.g .. " " .. color.b )
		end
	end
	return pnl
end
function xlib.wordWrap( text, width, font )
	surface.SetFont( font )
	if not surface.GetTextSize( "" ) then
		surface.SetFont( "default" )
	end
	text = text:Trim()
	local output = ""
	local pos_start, pos_end = 1, 1
	while true do
		local begin, stop = text:find( "%s+", pos_end + 1 )
		if (surface.GetTextSize( text:sub( pos_start, begin or -1 ):Trim() ) > width and pos_end - pos_start > 0) then
			output = output .. text:sub( pos_start, pos_end ):Trim() .. "\n"
			pos_start = pos_end + 1
			pos_end = pos_end + 1
		else
			pos_end = stop
		end
		if not stop then
			output = output .. text:sub( pos_start ):Trim()
			break
		end
	end
	return output
end
function xlib.makeprogressbar( t )
	local pnl = vgui.Create( "DProgress", t.parent )
	pnl.Label = xlib.makelabel{ x=5, y=3, w=(t.w or 100), textcolor=SKIN.text_dark, parent=pnl }
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w or 100, t.h or 20 )
	pnl:SetFraction( t.value or 0 )
	if t.skin then pnl:SetSkin( t.skin ) end
	if t.visible ~= nil then pnl:SetVisible( t.visible ) end
	return pnl
end
function xlib.checkRepCvarCreated( cvar )
	if GetConVar( cvar ) == nil then
		CreateClientConVar( cvar:lower(), 0, false, false )
	end
end
function xlib.makeslider( t )
	local pnl = vgui.Create( "DNumSlider", t.parent )
	pnl.PerformLayout = function() end
	pnl:SetPos( t.x, t.y )
	pnl:SetWide( t.w or 100 )
	pnl:SetTall( t.h or 20 )
	pnl:SetText( t.label or "" )
	if t.dock then pnl:Dock( t.dock ) end
	if t.dockmargin then pnl:DockMargin( t.dockmargin[1], t.dockmargin[2], t.dockmargin[3], t.dockmargin[4] ) end
	if t.dockpadding then pnl:DockPadding( t.dockpadding[1], t.dockpadding[2], t.dockpadding[3], t.dockpadding[4] ) end
	pnl:SetMinMax( t.min or 0, t.max or 100 )
	pnl:SetDecimals( t.decimal or 0 )
	pnl.TextArea:SetDrawBackground( true )
	pnl.TextArea.selectAll = t.selectall
	pnl.Label:SizeToContents()
	pnl:SetZPos( t.zpos or 0 )
	if t.textcolor then
		pnl.Label:SetTextColor( t.textcolor )
	else
		pnl.Label:SetTextColor( SKIN.text_dark )
	end
	if t.fixclip then pnl.Slider.Knob:NoClipping( false ) end
	if t.convar then pnl:SetConVar( t.convar ) end
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetTooltip( t.tooltip )
	end
	pnl.SetDisabled = function( self, val )
		pnl:SetAlpha( val and 128 or 255 )
		pnl:SetEnabled( not val )
		pnl.TextArea:SetEnabled( not val )
		pnl.TextArea:SetMouseInputEnabled( not val )
		pnl.Scratch:SetMouseInputEnabled( not val )
		pnl.Slider:SetMouseInputEnabled( not val )
	end
	if t.disabled then pnl:SetDisabled( t.disabled ) end
	pnl:SizeToContents()
	pnl.GetValue = function( self ) return tonumber( self.TextArea:GetValue() ) end
	function pnl.SetValue( self, val )
		if ( val == nil ) then return end
		if t.clampmin then val = math.max( tonumber( val ) or 0, self:GetMin() ) end
		if t.clampmax then val = math.min( tonumber( val ) or 0, self:GetMax() ) end
		self.Scratch:SetValue( val )
		self.ValueUpdated( val )
		self:ValueChanged( val )
	end
	function pnl.ValueChanged( self, val )
		if t.clampmin then val = math.max( tonumber( val ) or 0, self:GetMin() ) end
		if t.clampmax then val = math.min( tonumber( val ) or 0, self:GetMax() ) end
		self.Slider:SetSlideX( self.Scratch:GetFraction( val ) )
		if ( self.TextArea ~= vgui.GetKeyboardFocus() ) then
			self.TextArea:SetValue( self.Scratch:GetTextValue() )
		end
		self:OnValueChanged( val )
	end
	function pnl.ValueUpdated( value )
		pnl.TextArea:SetText( string.format("%." .. ( pnl.Scratch:GetDecimals() ) .. "f", tonumber( value ) or 0) )
	end
	pnl.TextArea.OnTextChanged = function() end
	function pnl.TextArea:OnEnter()
		pnl.TextArea:SetText( string.format("%." .. ( pnl.Scratch:GetDecimals() ) .. "f", tonumber( pnl.TextArea:GetText() ) or 0) )
		if pnl.OnEnter then pnl:OnEnter() end
	end
	function pnl.TextArea:OnLoseFocus()
		pnl:SetValue( pnl.TextArea:GetText() )
		hook.Call( "OnTextEntryLoseFocus", nil, self )
	end
	local pnl_val
	function pnl:TranslateSliderValues( x, y )
		pnl_val = self.Scratch:GetMin() + (x * self.Scratch:GetRange())
		pnl.ValueUpdated( pnl_val )
		self.Scratch:SetFraction( x )
		return self.Scratch:GetFraction(), y
	end
	local tmpfunc = pnl.Slider.Knob.OnMouseReleased
	pnl.Slider.Knob.OnMouseReleased = function( self, mcode )
		tmpfunc( self, mcode )
		pnl.Slider:OnMouseReleased( mcode )
	end
	local tmpfunc = pnl.Slider.SetDragging
	pnl.Slider.SetDragging = function( self, bval )
		tmpfunc( self, bval )
		if ( not bval ) then pnl:SetValue( pnl.TextArea:GetText() ) end
	end
	pnl.Slider.OnMouseReleased = function( self, mcode )
		self:SetDragging( false )
		self:MouseCapture( false )
	end
	function pnl.Scratch:OnCursorMoved( x, y )
		if ( not self:GetActive() ) then return end
		x = x - math.floor( self:GetWide() * 0.5 )
		y = y - math.floor( self:GetTall() * 0.5 )
		local zoom = self:GetZoom()
		local ControlScale = 100 / zoom;
		local maxzoom = 20
		if ( self:GetDecimals() ) then
			maxzoom = 10000
		end
		zoom = math.Clamp( zoom + ((y * -0.6) / ControlScale), 0.01, maxzoom );
		self:SetZoom( zoom )
		local value = self:GetFloatValue()
		value = math.Clamp( value + (x * ControlScale * 0.002), self:GetMin(), self:GetMax() );
		self:SetFloatValue( value )
		pnl_val = value
		pnl.ValueUpdated( pnl_val )
		self:LockCursor()
	end
	pnl.Scratch.OnMouseReleased = function( self, mousecode )
		g_Active = nil
		self:SetActive( false )
		self:MouseCapture( false )
		self:SetCursor( "sizewe" )
		pnl:SetValue( pnl.TextArea:GetText() )
	end
	if t.value then pnl:SetValue( t.value ) end
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		pnl:SetValue( GetConVar( t.repconvar ):GetFloat() )
		function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
			if cl_cvar == t.repconvar:lower() then
				if ( IsValid( pnl ) ) then
					pnl:SetValue( new_val )
				end
			end
		end
		hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
		function pnl:OnValueChanged( val )
			RunConsoleCommand( t.repconvar, tostring( val ) )
		end
		pnl.ConVarNumberThink = function() end
		pnl.ConVarStringThink = function() end
		pnl.ConVarChanged = function() end
	end
	return pnl
end
local PANEL = {}
AccessorFunc( PANEL, "m_bPaintBackground", "PaintBackground" )
Derma_Hook( PANEL, "Paint", "Paint", "Panel" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "Panel" )
function PANEL:Init()
	self:SetPaintBackground( true )
end
derma.DefineControl( "xlib_Panel", "", PANEL, "EditablePanel" )
local PANEL = {}
function PANEL:Init()
	self.showAlpha=false
	self:SetSize( 130, 135 )
	self.RGBBar = vgui.Create( "DRGBPicker", self )
	self.RGBBar.OnChange = function( ctrl, color )
		if ( self.showAlpha ) then
			color.a = self.txtA:GetValue()
		end
		self:SetBaseColor( color )
	end
	self.RGBBar:SetSize( 15, 100 )
	self.RGBBar:SetPos( 5,5 )
	self.RGBBar.OnMouseReleased = function( self, mcode )
		self:MouseCapture( false )
		self:OnCursorMoved( self:CursorPos() )
		self:GetParent():OnChange( self:GetParent():GetColor() )
	end
	function self.RGBBar:SetColor( color )
		local h, s, v = ColorToHSV( color )
		self.LastY = ( 1 - h / 360 ) * self:GetTall()
	end
	self.ColorCube = vgui.Create( "DColorCube", self )
	self.ColorCube.OnUserChanged = function( ctrl ) self:ColorCubeChanged( ctrl ) end
	self.ColorCube:SetSize( 100, 100 )
	self.ColorCube:SetPos( 25,5 )
	self.ColorCube.OnMouseReleased = function( self, mcode )
		self:SetDragging( false )
		self:MouseCapture( false )
		self:GetParent():OnChange( self:GetParent():GetColor() )
	end
	self.ColorCube.Knob.OnMouseReleased = function( self, mcode )
		self:GetParent():GetParent():OnChange( self:GetParent():GetParent():GetColor() )
		return DLabel.OnMouseReleased( self, mcode )
	end
	self.txtR = xlib.makenumberwang{ x=7, y=110, w=35, value=255, parent=self }
	self.txtR.OnValueChanged = function( self, val )
		local p = self:GetParent()
		p:SetColor( Color( val, p.txtG:GetValue(), p.txtB:GetValue(), p.showAlpha and p.txtA:GetValue() ) )
	end
	self.txtR.OnEnter = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		self:OnValueChanged( val )
	end
	self.txtR.OnTextChanged = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		if val ~= math.Clamp( val, 0, 255 ) then self:SetValue( math.Clamp( val, 0, 255 ) ) end
		self:GetParent():UpdateColorText()
	end
	self.txtR.OnLoseFocus = function( self )
		if not tonumber( self:GetValue() ) then self:SetValue( "0" ) end
		local p = self:GetParent()
		p:OnChange( p:GetColor() )
		hook.Call( "OnTextEntryLoseFocus", nil, self )
	end
	self.txtR.Up.DoClick = function( button, mcode )
		self.txtR:SetValue( tonumber( self.txtR:GetValue() ) + 1 )
		self.txtR:GetParent():OnChange( self.txtR:GetParent():GetColor() )
	end
	self.txtR.Down.DoClick = function( button, mcode )
		self.txtR:SetValue( tonumber( self.txtR:GetValue() ) - 1 )
		self.txtR:GetParent():OnChange( self.txtR:GetParent():GetColor() )
	end
	function self.txtR.OnMouseReleased( self, mousecode )
		if ( self.Dragging ) then
			self:GetParent():OnChange( self:GetParent():GetColor() )
			self:EndWang()
		return end
	end
	self.txtG = xlib.makenumberwang{ x=47, y=110, w=35, value=100, parent=self }
	self.txtG.OnValueChanged = function( self, val )
		local p = self:GetParent()
		p:SetColor( Color( p.txtR:GetValue(), val, p.txtB:GetValue(), p.showAlpha and p.txtA:GetValue() ) )
	end
	self.txtG.OnEnter = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		self:OnValueChanged( val )
	end
	self.txtG.OnTextChanged = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		if val ~= math.Clamp( val, 0, 255 ) then self:SetValue( math.Clamp( val, 0, 255 ) ) end
		self:GetParent():UpdateColorText()
	end
	self.txtG.OnLoseFocus = function( self )
		if not tonumber( self:GetValue() ) then self:SetValue( "0" ) end
		local p = self:GetParent()
		p:OnChange( p:GetColor() )
		hook.Call( "OnTextEntryLoseFocus", nil, self )
	end
	self.txtG.Up.DoClick = function( button, mcode )
		self.txtG:SetValue( tonumber( self.txtG:GetValue() ) + 1 )
		self.txtG:GetParent():OnChange( self.txtG:GetParent():GetColor() )
	end
	self.txtG.Down.DoClick = function( button, mcode )
		self.txtG:SetValue( tonumber( self.txtG:GetValue() ) - 1 )
		self.txtG:GetParent():OnChange( self.txtG:GetParent():GetColor() )
	end
	function self.txtG.OnMouseReleased( self, mousecode )
		if ( self.Dragging ) then
			self:GetParent():OnChange( self:GetParent():GetColor() )
			self:EndWang()
		return end
	end
	self.txtB = xlib.makenumberwang{ x=87, y=110, w=35, value=100, parent=self }
	self.txtB.OnValueChanged = function( self, val )
		local p = self:GetParent()
		p:SetColor( Color( p.txtR:GetValue(), p.txtG:GetValue(), val, p.showAlpha and p.txtA:GetValue() ) )
	end
	self.txtB.OnEnter = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		self:OnValueChanged( val )
	end
	self.txtB.OnTextChanged = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		if val ~= math.Clamp( val, 0, 255 ) then self:SetValue( math.Clamp( val, 0, 255 ) ) end
		self:GetParent():UpdateColorText()
	end
	self.txtB.OnLoseFocus = function( self )
		if not tonumber( self:GetValue() ) then self:SetValue( "0" ) end
		local p = self:GetParent()
		p:OnChange( p:GetColor() )
		hook.Call( "OnTextEntryLoseFocus", nil, self )
	end
	self.txtB.Up.DoClick = function( button, mcode )
		self.txtB:SetValue( tonumber( self.txtB:GetValue() ) + 1 )
		self.txtB:GetParent():OnChange( self.txtB:GetParent():GetColor() )
	end
	self.txtB.Down.DoClick = function( button, mcode )
		self.txtB:SetValue( tonumber( self.txtB:GetValue() ) - 1 )
		self.txtB:GetParent():OnChange( self.txtB:GetParent():GetColor() )
	end
	function self.txtB.OnMouseReleased( self, mousecode )
		if ( self.Dragging ) then
			self:GetParent():OnChange( self:GetParent():GetColor() )
			self:EndWang()
		return end
	end
	self:SetColor( Color( 255, 0, 0, 255 ) )
end
function PANEL:AddAlphaBar()
	self.showAlpha = true
	self.txtA = xlib.makenumberwang{ x=150, y=82, w=35, value=255, parent=self }
	self.txtA.OnValueChanged = function( self, val )
		local p = self:GetParent()
		p:SetColor( Color( p.txtR:GetValue(), p.txtG:GetValue(), p.txtB:GetValue(), val ) )
	end
	self.txtA.OnEnter = function( self )
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		self:OnValueChanged( val )
	end
	self.txtA.OnTextChanged = function( self )
		local p = self:GetParent()
		local val = tonumber( self:GetValue() )
		if not val then val = 0 end
		if val ~= math.Clamp( val, 0, 255 ) then self:SetValue( math.Clamp( val, 0, 255 ) ) end
		p.AlphaBar:SetValue( val / 255 )
		p:OnChangeImmediate( p:GetColor() )
	end
	self.txtA.OnLoseFocus = function( self )
		if not tonumber( self:GetValue() ) then self:SetValue( "0" ) end
		local p = self:GetParent()
		p:OnChange( p:GetColor() )
		hook.Call( "OnTextEntryLoseFocus", nil, self )
	end
	self.txtA.Up.DoClick = function( button, mcode )
		self.txtA:SetValue( tonumber( self.txtA:GetValue() ) + 1 )
		self.txtA:GetParent():OnChange( self.txtA:GetParent():GetColor() )
	end
	self.txtA.Down.DoClick = function( button, mcode )
		self.txtA:SetValue( tonumber( self.txtA:GetValue() ) - 1 )
		self.txtA:GetParent():OnChange( self.txtA:GetParent():GetColor() )
	end
	function self.txtA.OnMouseReleased( self, mousecode )
		if ( self.Dragging ) then
			self:GetParent():OnChange( self:GetParent():GetColor() )
			self:EndWang()
		return end
	end
	self.AlphaBar = vgui.Create( "DAlphaBar", self )
	self.AlphaBar.OnChange = function( ctrl, alpha ) self:SetColorAlpha( math.floor( ( alpha * 255 ) ) ) end
	self.AlphaBar:SetPos( 25,5 )
	self.AlphaBar:SetSize( 15, 100 )
	self.AlphaBar:SetValue( 1 )
	self.AlphaBar.OnMouseReleased = function( self, mcode )
		self:MouseCapture( false )
		self:OnCursorMoved( self:CursorPos() )
		self:GetParent():OnChange( self:GetParent():GetColor() )
	end
	self.ColorCube:SetPos( 45,5 )
	self:SetSize( 190, 110 )
	self.txtR:SetPos( 150, 7 )
	self.txtG:SetPos( 150, 32 )
	self.txtB:SetPos( 150, 57 )
end
function PANEL:AlphaModeTwo()
	self:SetSize( 156, 135 )
	self.AlphaBar:SetPos( 28,5 )
	self.ColorCube:SetPos( 51,5 )
	self.txtR:SetPos( 5, 110 )
	self.txtG:SetPos( 42, 110 )
	self.txtB:SetPos( 79, 110 )
	self.txtA:SetPos( 116, 110 )
end
function PANEL:NoAlphaModeTwo()
	self:SetSize( 170, 110 )
	self.txtR:SetPos( 130, 7 )
	self.txtG:SetPos( 130, 32 )
	self.txtB:SetPos( 130, 57 )
end
function PANEL:UpdateColorText()
	self.RGBBar:SetColor( Color( self.txtR:GetValue(), self.txtG:GetValue(), self.txtB:GetValue(), self.showAlpha and self.txtA:GetValue() ) )
	self.ColorCube:SetColor( Color( self.txtR:GetValue(), self.txtG:GetValue(), self.txtB:GetValue(), self.showAlpha and self.txtA:GetValue() ) )
	if ( self.showAlpha ) then self.AlphaBar:SetBarColor( Color( self.txtR:GetValue(), self.txtG:GetValue(), self.txtB:GetValue(), 255 ) ) end
	self:OnChangeImmediate( self:GetColor() )
end
function PANEL:SetColor( color )
	self.RGBBar:SetColor( color )
	self.ColorCube:SetColor( color )
	if tonumber( self.txtR:GetValue() ) ~= color.r then self.txtR:SetText( color.r or 255 ) end
	if tonumber( self.txtG:GetValue() ) ~= color.g then self.txtG:SetText( color.g or 0 ) end
	if tonumber( self.txtB:GetValue() ) ~= color.b then self.txtB:SetText( color.b or 0 ) end
	if ( self.showAlpha ) then
		self.txtA:SetText( color.a or 0 )
		self.AlphaBar:SetBarColor( Color( color.r, color.g, color.b ) )
		self.AlphaBar:SetValue( ( ( color.a or 0 ) / 255) )
	end
	self:OnChangeImmediate( color )
end
function PANEL:SetBaseColor( color )
	self.ColorCube:SetBaseRGB( color )
	self.txtR:SetText(self.ColorCube.m_OutRGB.r)
	self.txtG:SetText(self.ColorCube.m_OutRGB.g)
	self.txtB:SetText(self.ColorCube.m_OutRGB.b)
	if ( self.showAlpha ) then
		self.AlphaBar:SetBarColor( Color( self:GetColor().r, self:GetColor().g, self:GetColor().b ) )
	end
	self:OnChangeImmediate( self:GetColor() )
end
function PANEL:SetColorAlpha( alpha )
	if ( self.showAlpha ) then
		alpha = alpha or 0
		self.txtA:SetValue(alpha)
	end
end
function PANEL:ColorCubeChanged( cube )
	self.txtR:SetText(cube.m_OutRGB.r)
	self.txtG:SetText(cube.m_OutRGB.g)
	self.txtB:SetText(cube.m_OutRGB.b)
	if ( self.showAlpha ) then
		self.AlphaBar:SetBarColor( Color( self:GetColor().r, self:GetColor().g, self:GetColor().b ) )
	end
	self:OnChangeImmediate( self:GetColor() )
end
function PANEL:GetColor()
	local color = Color( self.txtR:GetValue(), self.txtG:GetValue(), self.txtB:GetValue() )
	if ( self.showAlpha ) then
		color.a = self.txtA:GetValue()
	else
		color.a = 255
	end
	return color
end
function PANEL:PerformLayout()
	self:SetColor( Color( self.txtR:GetValue(), self.txtG:GetValue(), self.txtB:GetValue(), self.showAlpha and self.txtA:GetValue() ) )
end
function PANEL:OnChangeImmediate( color )
end
function PANEL:OnChange( color )
end
vgui.Register( "xlibColorPanel", PANEL, "DPanel" )
surface.CreateFont ("DefaultLarge", {
	font = "Tahoma",
	size = 16,
	weight = 0,
})
local xlibAnimation = {}
xlibAnimation.__index = xlibAnimation
function xlib.anim( runFunc, startFunc, endFunc )
	local anim = {}
	anim.runFunc = runFunc
	anim.startFunc = startFunc
	anim.endFunc = endFunc
	setmetatable( anim, xlibAnimation )
	return anim
end
xlib.animTypes = {}
xlib.registerAnimType = function( name, runFunc, startFunc, endFunc )
	xlib.animTypes[name] = xlib.anim( runFunc, startFunc, endFunc )
end
function xlibAnimation:Start( Length, Data )
	self.startFunc( Data )
	if ( Length == 0 ) then
		self.endFunc( Data )
		xlib.animQueue_call()
	else
		self.Length = Length
		self.StartTime = SysTime()
		self.EndTime = SysTime() + Length
		self.Data = Data
		table.insert( xlib.activeAnims, self )
	end
end
function xlibAnimation:Stop()
	self.runFunc( 1, self.Data )
	self.endFunc( self.Data )
	for i, v in ipairs( xlib.activeAnims ) do
		if v == self then table.remove( xlib.activeAnims, i ) break end
	end
	xlib.animQueue_call()
end
function xlibAnimation:Run()
	local CurTime = SysTime()
	local delta = (CurTime - self.StartTime) / self.Length
	if ( CurTime > self.EndTime ) then
		self:Stop()
	else
		self.runFunc( delta, self.Data )
	end
end
xlib.activeAnims = {}
xlib.animRun = function()
	for _, v in ipairs( xlib.activeAnims ) do
		v.Run( v )
	end
end
hook.Add( "XLIBDoAnimation", "xlib_runAnims", xlib.animRun )
xlib.animQueue = {}
xlib.animBackupQueue = {}
xlib.animStep = 0
xlib.animQueue_start = function()
	if xlib.animRunning then
		xlib.animQueue_forceStop()
		return
	end
	xlib.curAnimStep = xlib.animStep
	xlib.animStep = 0
	xlib.animQueue_call()
end
xlib.animQueue_forceStop = function()
	xlib.curAnimStep = -1
	if type( xlib.animRunning ) == "table" then xlib.animRunning:Stop() end
end
xlib.animQueue_call = function()
	if #xlib.animQueue > 0 then
		local func = xlib.animQueue[1]
		table.remove( xlib.animQueue, 1 )
		func()
	else
		xlib.animRunning = nil
		if #xlib.animBackupQueue > 0 then
			xlib.animQueue = table.Copy( xlib.animBackupQueue )
			xlib.animBackupQueue = {}
			xlib.animQueue_start()
		end
	end
end
xlib.addToAnimQueue = function( obj, ... )
	local arg = { ... }
	local outTable = xlib.animRunning and xlib.animBackupQueue or xlib.animQueue
	if type( obj ) == "function" then
		table.insert( outTable, function() xlib.animRunning = true  obj( unpack( arg ) )  xlib.animQueue_call() end )
	elseif type( obj ) == "string" and xlib.animTypes[obj] then
		length = arg[2] or xgui.settings.animTime or 1
		xlib.animStep = xlib.animStep + 1
		table.insert( outTable, function() xlib.animRunning = xlib.animTypes[obj]  xlib.animRunning:Start( ( xlib.curAnimStep ~= -1 and ( length/xlib.curAnimStep ) or 0 ), arg[1] ) end )
	else
		Msg( "Error: XLIB recieved an invalid animation call! TYPE:" .. type( obj ) .. " VALUE:" .. tostring( obj ) .. "\n" )
	end
end
local function slideAnim_run( delta, data )
	data.panel:SetPos( data.startx+((data.endx-data.startx)*delta), data.starty+((data.endy-data.starty)*delta) )
end
local function slideAnim_start( data )
	data.panel:SetPos( data.startx, data.starty )
	if data.setvisible == true then
		ULib.queueFunctionCall( data.panel.SetVisible, data.panel, true )
	end
end
local function slideAnim_end( data )
	data.panel:SetPos( data.endx, data.endy )
	if data.setvisible == false then
		data.panel:SetVisible( false )
	end
end
xlib.registerAnimType( "pnlSlide", slideAnim_run, slideAnim_start, slideAnim_end )
local function fadeAnim_run( delta, data )
	if data.panelOut then data.panelOut:SetAlpha( 255-(delta*255) ) data.panelOut:SetVisible( true ) end
	if data.panelIn then data.panelIn:SetAlpha( 255 * delta ) data.panelIn:SetVisible( true ) end
end
local function fadeAnim_start( data )
	if data.panelOut then data.panelOut:SetAlpha( 255 ) data.panelOut:SetVisible( true ) end
	if data.panelIn then data.panelIn:SetAlpha( 0 ) data.panelIn:SetVisible( true ) end
end
local function fadeAnim_end( data )
	if data.panelOut then data.panelOut:SetVisible( false ) end
	if data.panelIn then data.panelIn:SetAlpha( 255 ) end
end
xlib.registerAnimType( "pnlFade", fadeAnim_run, fadeAnim_start, fadeAnim_end )
xlib.ifListenHost = function(value)
	if LocalPlayer():IsListenServerHost() then return value end
	return nil
end
xlib.ifNotListenHost = function(value)
	if not LocalPlayer():IsListenServerHost() then return value end
	return nil
end
