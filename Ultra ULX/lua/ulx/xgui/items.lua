-- 道具模块 v3
-- t1=永久无模型无弹药(无生成) t2=消耗品(有生成) t3=有弹药武器(有生成) t4=永久无弹药(有生成) t5=纯实体(有生成)
local item_data = {
	["武器"] = {
		{ c="weapon_fists",      n="拳头",       t=1 },
		{ c="weapon_bugbait",    n="虫饵",       t=1 },
		{ c="weapon_frag",       n="手雷",       t=2 },
		{ c="weapon_slam",       n="SLAM地雷",   t=2 },
		{ c="weapon_crowbar",    n="撬棍",       t=4 },
		{ c="weapon_stunstick",  n="电棍",       t=4 },
		{ c="weapon_shotgun",    n="霰弹枪",     t=3 },
		{ c="weapon_pistol",     n="手枪",       t=3 },
		{ c="weapon_357",        n="左轮",       t=3 },
		{ c="weapon_smg1",       n="SMG",        t=3 },
		{ c="weapon_ar2",        n="AR2步枪",    t=3 },
		{ c="weapon_crossbow",   n="弩",         t=3 },
		{ c="weapon_rpg",        n="RPG",        t=3 },
	},
	["CSS武器"] = {
		{ c="weapon_hegrenade",  n="手雷(CS)",   t=2 },
		{ c="weapon_flashbang",  n="闪光弹",     t=2 },
		{ c="weapon_smokegrenade",n="烟雾弹",    t=2 },
		{ c="weapon_deagle",    n="沙漠之鹰",   t=3 },
		{ c="weapon_elite",     n="双持贝雷塔", t=3 },
		{ c="weapon_fiveseven", n="FN57",        t=3 },
		{ c="weapon_glock",     n="格洛克",      t=3 },
		{ c="weapon_usp",       n="USP消音版",   t=3 },
		{ c="weapon_p228",      n="P228",        t=3 },
		{ c="weapon_m3",        n="M3霰弹枪",    t=3 },
		{ c="weapon_mac10",     n="MAC-10",      t=3 },
		{ c="weapon_mp5navy",   n="MP5海军",     t=3 },
		{ c="weapon_p90",       n="P90",         t=3 },
		{ c="weapon_tmp",       n="TMP",         t=3 },
		{ c="weapon_ump45",     n="UMP45",       t=3 },
		{ c="weapon_ak47",      n="AK-47",       t=3 },
		{ c="weapon_aug",       n="AUG",         t=3 },
		{ c="weapon_famas",     n="FAMAS",       t=3 },
		{ c="weapon_galil",     n="Galil",       t=3 },
		{ c="weapon_m4a1",      n="M4A1消音版",  t=3 },
		{ c="weapon_sg552",     n="SG552",       t=3 },
		{ c="weapon_awp",       n="AWP",         t=3 },
		{ c="weapon_g3sg1",     n="G3SG1",       t=3 },
		{ c="weapon_scout",     n="Scout",       t=3 },
		{ c="weapon_sg550",     n="SG550",       t=3 },
		{ c="weapon_m249",      n="M249",        t=3 },
	},
	["管理员武器"] = {
		{ c="weapon_flechettegun",       n="钢茅枪",       t=4, a="superadmin" },
		{ c="weapon_xm1014",             n="XM1014",       t=3, a="superadmin" },
		{ c="weapon_knife",              n="匕首",         t=4, a="superadmin" },
		{ c="weapon_medkit",             n="医疗包",       t=4, a="superadmin" },
		{ c="manhack_welder",            n="飞锯枪",       t=4, a="superadmin" },
		{ c="weapon_spraypatterncreator",n="喷漆图案器",   t=4, a="superadmin" },
		{ c="weapon_awp_awesome",        n="AWP强化",      t=3, a="superadmin" },
		{ c="weapon_deagleawesome",      n="沙鹰强化",     t=3, a="superadmin" },
		{ c="weapon_g3sg1_awesome",      n="G3SG1强化",    t=3, a="superadmin" },
		{ c="weapon_glockinator",        n="格洛克强化",   t=3, a="superadmin" },
		{ c="weapon_macdadster",         n="MAC10强化",    t=3, a="superadmin" },
		{ c="weapon_xm9000",             n="XM9000",       t=3, a="superadmin" },
	},
	["工具"] = {
		{ c="weapon_physgun",    n="物理枪",     t=4 },
		{ c="weapon_physcannon", n="重力枪",     t=4 },
		{ c="gmod_tool",         n="工具枪",     t=4 },
		{ c="gmod_camera",       n="相机",       t=4 },
	},
	["弹药"] = {
		{ c="item_ammo_pistol",       n="手枪弹药",     t=2 },
		{ c="item_ammo_pistol_large", n="手枪弹药(大)", t=2 },
		{ c="item_ammo_357",          n="左轮弹药",     t=2 },
		{ c="item_ammo_357_large",    n="左轮弹药(大)", t=2 },
		{ c="item_ammo_smg1",         n="SMG弹药",      t=2 },
		{ c="item_ammo_smg1_large",   n="SMG弹药(大)",  t=2 },
		{ c="item_ammo_ar2",          n="AR2弹药",      t=2 },
		{ c="item_ammo_ar2_large",    n="AR2弹药(大)",  t=2 },
		{ c="item_ammo_ar2_altfire",  n="AR2能量球",    t=2 },
		{ c="item_ammo_smg1_grenade", n="SMG榴弹",      t=2 },
		{ c="item_ammo_buckshot",     n="霰弹弹药",     t=2 },
		{ c="item_ammo_crossbow",     n="弩箭",         t=2 },
		{ c="item_rpg_round",         n="RPG火箭弹",    t=2 },
	},
	["道具"] = {
		{ c="item_healthkit",         n="医疗包",       t=2 },
		{ c="item_healthvial",        n="医疗瓶",       t=2 },
		{ c="item_healthcharger",     n="生命恢复仪",   t=2 },
		{ c="item_battery",           n="电池",         t=2 },
		{ c="item_suitcharger",       n="防护服充电仪", t=2 },
		{ c="item_box_buckshot",      n="霰弹弹药箱",   t=2 },
		{ c="item_suit",              n="防护服",       t=4 },
		{ c="combine_mine",           n="联合军跳雷",   t=5 },
		{ c="combine_mine_resistance",n="反抗军跳雷",   t=5 },
		{ c="grenade_helicopter",     n="直升机炸弹",   t=5 },
		{ c="sent_ball",              n="弹力球",       t=5 },
		{ c="prop_ragdoll",           n="布娃娃",       t=5 },
	},
	["座椅"] = {
		{ c="prop_vehicle_prisoner_pod", k="Chair_Office1", n="办公室座椅", t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Chair_Office2", n="真皮办公椅", t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Chair_Plastic", n="铁质凳子",   t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Chair_Wood",   n="木质凳子",   t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Seat_Airboat", n="汽艇座椅",   t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Seat_Jalopy",  n="老爷车座椅", t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Seat_Jeep",    n="吉普车座椅", t=5 },
	},
	["载具"] = {
		{ c="prop_vehicle_airboat",      k="Airboat",          n="汽艇",     t=5 },
		{ c="prop_vehicle_jeep",         k="Jalopy",           n="老爷车",   t=5 },
		{ c="prop_vehicle_jeep_old",     k="Jeep",             n="吉普车",   t=5 },
		{ c="prop_vehicle_prisoner_pod", k="Pod",              n="囚犯舱",   t=5 },
		{ c="prop_vehicle_apc",          k="prop_vehicle_apc", n="装甲战车", t=5 },
	},
}
local cat_order = { "武器", "CSS武器", "管理员武器", "工具", "弹药", "道具", "座椅", "载具" }

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

	-- 布局: 标签+小数量框(同行) / 拖动条满宽(下一行)
	local function makeSlider( label, min, max, def )
		local p = xlib.makepanel{ h=48 }
		p.xguiIgnore = true
		xlib.makelabel{ x=0, y=2, label=label, parent=p }
		local txt = vgui.Create( "DTextEntry", p )
		txt:SetPos( 60, 0 ); txt:SetSize( 40, 18 ); txt:SetValue( tostring( def ) )
		local sl = xlib.makeslider{ x=0, y=22, w=160, h=20, label="", min=min, max=max, value=def, decimal=0, parent=p }
		sl.TextArea:SetWide( 0 )
		local updating = false
		txt.OnChange = function( self )
			if updating then return end
			local num = tonumber( self:GetValue() )
			if num then
				updating = true
				sl:SetValue( math.Clamp( num, min, max ) )
				updating = false
			end
		end
		sl.Slider.OnValueChanged = function( self, frac )
			if updating then return end
			updating = true
			txt:SetValue( tostring( math.floor( sl:GetValue() ) ) )
			updating = false
		end
		items.argslist:Add( p ); p:SetZPos( z ); z = z + 1
		return sl
	end

	local function makeBtn( label )
		local b = xlib.makebutton{ label=label }
		b.xguiIgnore = true
		b:SetSize( 160, 22 )
		items.argslist:Add( b )
		b:SetZPos( z ); z = z + 1
		return b
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
		makeBtn( T("items_give_btn") ).DoClick = function() sendGive( 1 ) end

	elseif itype == 2 or itype == 4 then
		local sl
		makeBtn( T("items_give_btn") ).DoClick = function() sendGive( math.floor( sl:GetValue() ) ) end
		sl = makeSlider( T("items_qty"), 0, 9999, 10 )

		local slSpawn24
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn24:GetValue() ) ) end
		slSpawn24 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )
		items.argslist:InvalidateLayout( true )
		return

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
		items.argslist:InvalidateLayout( true )
		return

	elseif itype == 5 then
		local slSpawn5
		makeBtn( T("items_spawn_btn") ).DoClick = function() sendSpawn( math.floor( slSpawn5:GetValue() ) ) end
		slSpawn5 = makeSlider( T("items_entity_qty"), 1, 10, 1 )
		addLabel( T("items_spawn_warn") )
		items.argslist:InvalidateLayout( true )
		return
	end

	items.argslist:InvalidateLayout( true )
end

-- 玩家列表刷新
function items.refreshPlist()
	items.plist:Clear()
	for _, ply in ipairs( player.GetAll() ) do
		local line = items.plist:AddLine( ply:Nick(), translateGroup( ply:GetUserGroup() ) )
		line.ply = ply
	end
	items.plist:SortByColumn( 1, false )
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

	for _, catname in ipairs( cat_order ) do
		local data = item_data[catname]
		if data then
			local T = ULib.ulx_lang.T
			-- 武器分类仅管理员可见 (使用 data key 判断，非翻译文本)
			local isWeaponCat = ( catname == "武器" or catname == "CSS武器" or catname == "管理员武器" )
			if isWeaponCat and not LocalPlayer():IsAdmin() then
				-- 非管理员不显示武器分类
			elseif catname == "管理员武器" and not LocalPlayer():IsSuperAdmin() then
				-- 非超级管理员不显示管理员武器
			else
			items.cmd_contents[catname] = xlib.makelistview{ headerheight=0, multiselect=false, h=136 }
			items.cmd_contents[catname].OnRowSelected = function( self, LineID )
				items.setselected( self, LineID )
			end
			items.cmd_contents[catname]:AddColumn( "" )

			-- 翻译分类显示名
			local cat_tkeys = {
				["武器"] = "items_weapons",
				["CSS武器"] = "items_css_weapons",
				["管理员武器"] = "items_admin_weapons",
				["工具"] = "items_tools",
				["弹药"] = "items_ammo",
				["道具"] = "items_props",
				["座椅"] = "items_seats",
				["载具"] = "items_vehicles",
			}
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

			for _, it in ipairs( data ) do
				-- 跳过需要超级管理员权限的物品
				if not it.a or it.a == "" or LocalPlayer():IsSuperAdmin() then
					-- 使用语言键查找翻译名；有 k 参数用 itm_<c>_<k>，回退 itm_<c>，最后用 n 字段
					local langKey = "itm_" .. it.c
					if it.k and it.k ~= "" then langKey = langKey .. "_" .. it.k end
					local itemName = T(langKey)
					if itemName == langKey then itemName = it.n end
					items.cmd_contents[catname]:AddLine( itemName, it.c, tostring( it.t or 1 ), it.k or "" )
				end
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
	["管理员武器"] = "items_admin_weapons",
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
				-- 无翻译时从 item_data 回退
				if itemName == langKey then
					for _, data in pairs( item_data ) do
						for _, it in ipairs( data ) do
							if it.c == classname and (itemKey == "" or it.k == itemKey) then
								itemName = it.n
								break
							end
						end
						if itemName ~= langKey then break end
					end
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
items.refresh()
hook.Add( "UCLChanged", "xgui_items_refresh", items.refreshPlist )
-- 语言刷新：仅更新文本（不重建道具列表结构）
xgui.registerRefresh( "items", function()
	items.refreshTexts()
end )

xgui.addModule( "items", items, "icon16/gun.png" )
Msg( "[ULX] 道具模块已注册\n" )
