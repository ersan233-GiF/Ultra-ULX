local settings = xlib.makepanel{ parent=xgui.null }
local autorefreshTab
if xgui.settings_tabs ~= nil then autorefreshTab = xgui.settings_tabs:GetActiveTab() end
xgui.settings_tabs = xlib.makepropertysheet{ x=-5, y=6, w=600, h=368, parent=settings, offloadparent=xgui.null }
function xgui.settings_tabs:SetActiveTab( active, ignoreAnim )
	if ( self.m_pActiveTab == active ) then return end
	if ( self.m_pActiveTab ) then
		if not ignoreAnim then
			xlib.addToAnimQueue( "pnlFade", { panelOut=self.m_pActiveTab:GetPanel(), panelIn=active:GetPanel() } )
		else
			xlib.addToAnimQueue( "pnlFade", { panelOut=nil, panelIn=active:GetPanel() }, 0 )
		end
		xlib.animQueue_start()
	end
	self.m_pActiveTab = active
	self:InvalidateLayout()
end
local func = xgui.settings_tabs.PerformLayout
xgui.settings_tabs.PerformLayout = function( self )
	func( self )
	if self.tabScroller then
		self.tabScroller:SetPos( 10, 0 )
		self.tabScroller:SetWide( 580 )
	end
end
if autorefreshTab ~= nil then
	xgui.settings_tabs:SetActiveTab( autorefreshTab, true )
end
xgui.addModule( "settings", settings, "icon16/wrench.png" )