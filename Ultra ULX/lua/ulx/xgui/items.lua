-- 道具模块 v3 — 从 ulx.itemRegistry 动态读取
-- 数据源: lua/ulx/items/*.lua (模组/插件各自注册，无需修改本文件)
-- t1=永久无模型无弹药(无生成) t2=消耗品(有生成) t3=有弹药武器(有生成) t4=永久无弹药(有生成) t5=纯实体(有生成)

-- 双弹药武器: SMG(榴弹), AR2(能量球)
local dualAmmo = { ["weapon_smg1"] = true, ["weapon_ar2"] = true }

-- 用户组名称翻译
local function translateGroup( name )
	return xgui.translateGroup( name )
end

-- === 主面板 ===
local items = xlib.makepanel{ parent=xgui.null }
items.selitem = nil
items.mask = xlib.makepanel{ x=160, y=30, w=425, h=370, parent=items }

-- 道具参数面板 (用于显示数量和给予按钮)
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

-- 玩家列表 (原版 ListView 多选)
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

-- 左侧分类列表
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

-- 构建道具参数面板 (根据物品类型显示不同控件)
function items.buildArgsList( classname )
	items.argslist:Clear()
	local T = ULib.ulx_lang.T
	local itype = items.seltype or 1
	local z = 0

	-- 原版 ULX 滑块布局 (与 xgui_helpers.lua NumArg.x_getcontrol 一致)
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

	-- ===== 布局 =====

	if itype == 1 then
		-- 永久无模型无弹药 (拳头/虫饵): 仅给予，无数量无生成
		makeBtn( T("items_give_btn") ).DoClick = function() sendGive( 1 ) end

	elseif itype == 2 then
		-- 消耗品 (手雷/医疗包/弹药): 数量滑块 + 给予 + 生成
		local sl
		makeBtn( T("items_give_btn") ).DoClick = function() sendGive( math.floor( sl:GetValue() ) ) end
		sl = makeSlider( T("items_qty"), 0, 9999, 10 )

		local slSpawn2
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn2:GetValue() ) ) end
		slSpawn2 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )

	elseif itype == 4 then
		-- 永久无弹药有实体 (撬棍/电棍/物理枪/工具枪/医疗包等): 仅给予 1 件 + 生成实体
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
		-- 挂墙实体: 仅生成1个
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( 1 ) end
	end

	-- 撤回按钮 (所有可生成类型通用: 2,3,4,5,6)
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

-- 玩家列表刷新
function items.refreshPlist()
	-- 记住当前选中的玩家 SteamID64
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
		-- 恢复上次选中的玩家
		if table.HasValue( lastSelected, ply:SteamID64() ) then
			items.plist:SelectItem( line )
		end
		-- 标记本地玩家行
		if ply == LocalPlayer() then localLine = line end
	end
	items.plist:SortByColumn( 1, false )

	-- 无选中时自动选中自己
	if #items.plist:GetSelected() == 0 and localLine then
		items.plist:SelectItem( localLine )
	end

	if #items.plist:GetSelected() == 0 then
		if not xlib.animRunning then
			if items.argslist.open then items.argslist:Close(); xlib.animQueue_start() end
		end
	end
end

-- 道具分类刷新
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
			-- 收集当前分类中该玩家有权限看到的道具 (ULX 聊天指令式权限过滤)
			local visibleItems = {}
			local hasAny = false
			for _, it in ipairs( data ) do
				-- ULX 聊天指令式权限过滤：有 a 字段则检查对应权限
				local allowed = true
				if it.a and it.a ~= "" then
					if it.a == "superadmin" then
						allowed = LocalPlayer():IsSuperAdmin()  -- 听服立即可用
					elseif it.a == "admin" then
						allowed = LocalPlayer():IsAdmin()
					else
						allowed = lp:query( it.a )  -- 自定义权限走 UCL 查询
					end
				end
				if allowed then
					table.insert( visibleItems, it )
					hasAny = true
				end
			end
			-- 分类下无可显示道具则跳过整个分类（但仍需关闭 if data then）
			if hasAny then
				items.cmd_contents[catname] = xlib.makelistview{ headerheight=0, multiselect=false, h=136 }
				items.cmd_contents[catname].OnRowSelected = function( self, LineID )
					items.setselected( self, LineID )
				end
				items.cmd_contents[catname]:AddColumn( "" )

				-- 翻译分类显示名
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
					-- 受限物品在名称后加标记
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

-- === 动画 (argslist, plist动画已在createItemsPlist内联) ===
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

-- === 轻量刷新 (语言切换时仅更新文本) ===
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
				-- 查找注册表中的条目以获取 a 字段和回退名称
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
				-- 无翻译时回退到 n 字段
				if itemName == langKey and foundIt then
					itemName = foundIt.n
				end
				-- 权限受限物品加标记
				if foundIt and foundIt.a and foundIt.a ~= "" then
					itemName = itemName .. " (管理员)"
				end
				line:SetColumnText( 1, itemName )
			end
		end
		listView:SortByColumn( 1 )
	end
	-- 玩家列表列标题 (GMod DListView 列头是 .Header DButton)
	if items.plist and items.plist.Columns then
		local c1 = items.plist.Columns[1]; if c1 and c1.Header then c1.Header:SetText( T("ui_player_name") ) end
		local c2 = items.plist.Columns[2]; if c2 and c2.Header then c2.Header:SetText( T("ui_user_group") ) end
	end
	-- 实时刷新玩家列表行中的用户组翻译
	if items.plist and items.plist.Lines then
		for _, line in ipairs( items.plist.Lines ) do
			if line.ply and line.ply:IsValid() then
				line:SetColumnText( 2, translateGroup( line.ply:GetUserGroup() ) )
			end
		end
	end
	-- 如果有展开的参数面板, 重建
	if items.argslist.open and items.selitem then
		items.buildArgsList( items.selitem )
	end
end

-- === 初始化 ===
-- 立即刷新道具列表（与 GitHub 原版一致，不等 UCLChanged 首次触发）
items.refresh()
-- UCL 认证完成后重新刷新 (管理员武器等权限物品在认证后才可见)
hook.Add( "UCLChanged", "xgui_items_refresh_items", function()
	items.refresh()
end )
hook.Add( "UCLChanged", "xgui_items_refresh", items.refreshPlist )
-- 语言刷新：仅更新文本（不重建道具列表结构）
xgui.registerRefresh( "items", function()
	items.refreshTexts()
end )

xgui.addModule( "items", items, "icon16/gun.png" )
Msg( "[ULX] 道具模块已注册\n" )
