-- AI Bot module for ULX GUI
-- AI Bot 管理面板：使用属性表（标签页）布局，类似设置模块
-- Tab 1: BOT 管理 — 生成/移除/行为控制
-- Tab 2: AI 聊天 — 占位，稍后添加 AI 聊天功能

local ai_bot = xlib.makepanel{ parent=xgui.null }

------------------------------
-- 属性表（标签页容器）
------------------------------
ai_bot.tabs = xlib.makepropertysheet{ x=-5, y=6, w=600, h=368, parent=ai_bot, offloadparent=xgui.null }

function ai_bot.tabs:SetActiveTab( active, ignoreAnim )
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

-- 调整标签滚动条位置（与设置模块一致）
local func = ai_bot.tabs.PerformLayout
ai_bot.tabs.PerformLayout = function( self )
	func( self )
	if self.tabScroller then
		self.tabScroller:SetPos( 10, 0 )
		self.tabScroller:SetWide( 580 )
	end
end

-- ==================== Tab 1: BOT 管理 ====================
local bot_mgmt = xlib.makepanel{ parent=xgui.null }

------------------------------
-- 左侧：BOT 列表（原版 ListView 多选）
------------------------------
local botList = xlib.makelistview{ x=5, y=5, w=175, h=330, multiselect=true, parent=bot_mgmt }
botList:AddColumn( ULib.ulx_lang.T("ui_player_name") )

-- 获取选中的 BOT
function bot_mgmt.getSelectedBots()
	local bots = {}
	for _, line in ipairs( botList:GetSelected() ) do
		if line.ply and line.ply:IsValid() and line.ply:IsBot() then
			table.insert( bots, line.ply )
		end
	end
	return bots
end

function bot_mgmt.refreshBotList()
	local lastSelected = {}
	for _, line in ipairs( botList:GetSelected() ) do
		if line.ply and line.ply:IsValid() then table.insert( lastSelected, line.ply:UserID() ) end
	end
	botList:Clear()
	for _, ply in ipairs( player.GetAll() ) do
		if ply:IsBot() then
			local line = botList:AddLine( ply:Nick() )
			line.ply = ply
			if table.HasValue( lastSelected, ply:UserID() ) then
				botList:SelectItem( line )
			end
		end
	end
	botList:SortByColumn( 1, false )
end

------------------------------
-- 右侧：控制面板
------------------------------
local ctrlPanel = xlib.makepanel{ x=185, y=5, w=400, h=355, parent=bot_mgmt }

-- 生成 BOT
local lblSpawn = xlib.makelabel{ x=5, y=2, label=xgui.T("bots_spawn"), parent=ctrlPanel }
local spawnSlider = xlib.makeslider{ x=5, y=18, w=150, min=1, max=32, value=1, decimal=0, label="<--->", parent=ctrlPanel }
local spawnBtn = xlib.makebutton{ x=160, y=16, w=80, label=xgui.T("bots_spawn_btn"), parent=ctrlPanel }
spawnBtn.DoClick = function()
	RunConsoleCommand( "ulx", "bot", math.floor( spawnSlider:GetValue() ) )
	timer.Simple( 1, function() if bot_mgmt and bot_mgmt.refreshBotList then bot_mgmt.refreshBotList() end end )
end

-- 移除 BOT
local lblRemove = xlib.makelabel{ x=5, y=48, label=xgui.T("bots_remove"), parent=ctrlPanel }
local kickSelBtn = xlib.makebutton{ x=5, y=64, w=120, label=xgui.T("bots_kick_sel"), parent=ctrlPanel }
kickSelBtn.DoClick = function()
	for _, ply in ipairs( bot_mgmt.getSelectedBots() ) do
		RunConsoleCommand( "_xgui_bot_kick", ply:UserID() )
	end
	bot_mgmt.refreshBotList()
end
local kickAllBtn = xlib.makebutton{ x=130, y=64, w=110, label=xgui.T("bots_kick_all"), parent=ctrlPanel }
kickAllBtn.DoClick = function()
	RunConsoleCommand( "ulx", "kickbots" )
	timer.Simple( 1, function() if bot_mgmt and bot_mgmt.refreshBotList then bot_mgmt.refreshBotList() end end )
end

-- BOT 行为控制
local lblBehavior = xlib.makelabel{ x=5, y=95, label=xgui.T("bots_behavior"), parent=ctrlPanel }

-- 冻结/解冻 (ulx freeze / ulx unfreeze)
local freezeBtn = xlib.makebutton{ x=5, y=112, w=120, label=xgui.T("bots_freeze"), parent=ctrlPanel }
freezeBtn.DoClick = function()
	for _, ply in ipairs( bot_mgmt.getSelectedBots() ) do
		RunConsoleCommand( "_xgui_bot_freeze", ply:UserID() )
	end
end
local unfreezeBtn = xlib.makebutton{ x=130, y=112, w=110, label=xgui.T("bots_unfreeze"), parent=ctrlPanel }
unfreezeBtn.DoClick = function()
	for _, ply in ipairs( bot_mgmt.getSelectedBots() ) do
		RunConsoleCommand( "_xgui_bot_unfreeze", ply:UserID() )
	end
end

-- 缴械（生成时已自动去除武器，此处用于后续缴械）
local stripWeaponBtn = xlib.makebutton{ x=5, y=140, w=155, label=xgui.T("bots_strip"), parent=ctrlPanel }
stripWeaponBtn.DoClick = function()
	for _, ply in ipairs( bot_mgmt.getSelectedBots() ) do
		RunConsoleCommand( "_xgui_bot_strip", ply:UserID() )
	end
end

-- 设置血量
local lblHp = xlib.makelabel{ x=5, y=168, label=xgui.T("bots_hp"), parent=ctrlPanel }
local hpSlider = xlib.makeslider{ x=5, y=185, w=150, min=1, max=10000, value=100, decimal=0, label="<--->", parent=ctrlPanel }
local hpBtn = xlib.makebutton{ x=160, y=183, w=70, label=xgui.T("sv_update"), parent=ctrlPanel }
hpBtn.DoClick = function()
	local hp = math.floor( hpSlider:GetValue() )
	for _, ply in ipairs( bot_mgmt.getSelectedBots() ) do
		RunConsoleCommand( "_xgui_bot_hp", ply:UserID(), hp )
	end
end

-- 刷新按钮
local refreshBtn = xlib.makebutton{ x=5, y=330, w=175, label=xgui.T("ui_refresh_data"), parent=bot_mgmt }
refreshBtn.DoClick = function() bot_mgmt.refreshBotList() end

-- 定时刷新列表
timer.Create( "ULXAIBotListRefresh", 2, 0, function()
	if ai_bot:IsVisible() then bot_mgmt.refreshBotList() end
end )

-- ==================== Tab 2: AI 聊天（占位） ====================
local ai_chat = xlib.makepanel{ parent=xgui.null }

xlib.makelabel{ x=180, y=160, label=xgui.T("ai_chat_placeholder"), parent=ai_chat }

-- ==================== 注册标签页 ====================
-- 在 onProcessModules 中重建内部标签页（与设置模块一致的模式），
-- 确保语言切换时标签标题能正确刷新。
local function rebuildTabs()
	ai_bot.tabs:Clear()
	ai_bot.tabs:AddSheet( xgui.T("tab_ai_bot_mgmt"), bot_mgmt, "icon16/application_view_list.png" )
	ai_bot.tabs:AddSheet( xgui.T("tab_ai_chat"), ai_chat, "icon16/comment.png" )
end
xgui.hookEvent( "onProcessModules", nil, rebuildTabs, "aiBotRebuildTabs" )

-- ==================== 注册模块 ====================
xgui.hookEvent( "onProcessModules", nil, bot_mgmt.refreshBotList, "aiBotRefreshList" )

xgui.registerRefresh( "ai_bot", function()
	-- 刷新标签页标题 (按位置: Tab1=BOT管理, Tab2=AI聊天)
	if ai_bot.tabs and ai_bot.tabs.Items then
		local tabKeys = { "tab_ai_bot_mgmt", "tab_ai_chat" }
		for i, item in ipairs(ai_bot.tabs.Items) do
			if item.Tab and item.Tab:IsValid() and tabKeys[i] then
				item.Tab:SetText(xgui.T(tabKeys[i]))
				item.Tab:SizeToContents()
			end
		end
		ai_bot.tabs:InvalidateLayout(true)
	end
	-- 刷新列标题
	if botList and botList.Columns then
		local c = botList.Columns[1]; if c and c.Header then c.Header:SetText( xgui.T("ui_player_name") ) end
	end
	-- 刷新标签文本
	if lblSpawn then lblSpawn:SetText( xgui.T("bots_spawn") ) end
	if lblRemove then lblRemove:SetText( xgui.T("bots_remove") ) end
	if lblBehavior then lblBehavior:SetText( xgui.T("bots_behavior") ) end
	if lblHp then lblHp:SetText( xgui.T("bots_hp") ) end
	-- 刷新按钮文本
	spawnBtn:SetText( xgui.T("bots_spawn_btn") )
	kickSelBtn:SetText( xgui.T("bots_kick_sel") )
	kickAllBtn:SetText( xgui.T("bots_kick_all") )
	freezeBtn:SetText( xgui.T("bots_freeze") )
	unfreezeBtn:SetText( xgui.T("bots_unfreeze") )
	stripWeaponBtn:SetText( xgui.T("bots_strip") )
	hpBtn:SetText( xgui.T("sv_update") )
	refreshBtn:SetText( xgui.T("ui_refresh_data") )
end )

xgui.addModule( "ai_bot", ai_bot, "icon16/computer.png", "xgui_managebots" )
rebuildTabs()
bot_mgmt.refreshBotList()
