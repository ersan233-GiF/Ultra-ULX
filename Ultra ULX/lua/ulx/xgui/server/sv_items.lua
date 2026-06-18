-- 道具管理模块 - 服务端 -- Ultra ULX

-- 玩家生成实体追踪 (批次记录, 用于撤回, 顶层作用域供所有 SERVER 块访问)
local plySpawned = {}  -- [ply] = { batches = {{entities,...}, ...}, all = {ent,...} }

-- 开始一个新的生成批次 (在每次 net.Receive 入口调用)
local function startSpawnBatch( ply )
	if not IsValid( ply ) then return end
	plySpawned[ply] = plySpawned[ply] or { batches = {}, all = {} }
	table.insert( plySpawned[ply].batches, { entities = {} } )
end

-- 记录单个实体到当前批次
local function trackSpawn( ply, ent )
	if not IsValid(ply) or not IsValid(ent) then return end
	local data = plySpawned[ply]
	if not data then return end
	local batch = data.batches[#data.batches]
	if batch then table.insert( batch.entities, ent ) end
	table.insert( data.all, ent )
end

-- 强制移除实体 (处理交互后无法正常删除的情况)
local function forceRemoveEntity( ent )
	if not IsValid( ent ) then return 0 end
	-- 尝试驱逐内部玩家 (载具/座椅)
	if ent.GetDriver and IsValid( ent:GetDriver() ) then
		ent:GetDriver():ExitVehicle()
	end
	-- 遍历所有座位驱逐乘客 (GetPassenger 需要座位号参数)
	if ent.GetPassenger then
		for seat = 0, 8 do
			local p = ent:GetPassenger( seat )
			if IsValid( p ) then p:ExitVehicle() end
		end
	end
	-- 解除物理约束
	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then phys:EnableMotion( true ) end
	-- 移除
	SafeRemoveEntity( ent )
	if IsValid( ent ) then ent:Remove() end  -- 兜底
	return 1
end

if SERVER then
	if not ulx_items_net_init then
		util.AddNetworkString( "ulx_items_give" )
		util.AddNetworkString( "ulx_items_ammo" )
		util.AddNetworkString( "ulx_items_inventory" )
		util.AddNetworkString( "ulx_items_spawn" )
		util.AddNetworkString( "ulx_items_spawn_undo" )
		util.AddNetworkString( "ulx_items_spawn_clear" )
		ulx_items_net_init = true
	end

	-- 注册道具管理权限
	ULib.ucl.registerAccess( "xgui_manageitems", "admin", "允许在 XGUI 中使用道具管理面板。", "XGUI" )
end

-- ===== 常驻道具列表(即使地图没有也会列出) =====
local persistent_items = {
	-- 武器
	{ class = "weapon_crowbar",     name = "撬棍",       cat = "武器" },
	{ class = "weapon_pistol",      name = "手枪",       cat = "武器" },
	{ class = "weapon_357",         name = "左轮",       cat = "武器" },
	{ class = "weapon_smg1",        name = "SMG",        cat = "武器" },
	{ class = "weapon_ar2",         name = "AR2步枪",    cat = "武器" },
	{ class = "weapon_shotgun",     name = "霰弹枪",     cat = "武器" },
	{ class = "weapon_crossbow",    name = "弩",         cat = "武器" },
	{ class = "weapon_rpg",         name = "RPG",        cat = "武器" },
	{ class = "weapon_frag",        name = "手雷",       cat = "武器" },
	{ class = "weapon_slam",        name = "SLAM地雷",   cat = "武器" },
	{ class = "weapon_stunstick",   name = "电棍",       cat = "武器" },
	{ class = "weapon_bugbait",     name = "虫饵",       cat = "武器" },
	{ class = "weapon_physcannon",  name = "重力枪",     cat = "武器" },
	{ class = "weapon_physgun",     name = "物理枪",     cat = "武器" },
	{ class = "weapon_alyxgun",     name = "Alyx手枪",   cat = "武器" },
	{ class = "weapon_annabelle",   name = "Annabelle",  cat = "武器" },
	{ class = "weapon_striderbuster", name = "三角机甲克星", cat = "武器" },

	-- CSS武器
	{ class = "weapon_cs_desert_eagle", name = "沙漠之鹰",   cat = "CSS武器" },
	{ class = "weapon_cs_elite",        name = "双持贝雷塔", cat = "CSS武器" },
	{ class = "weapon_cs_fiveseven",    name = "FN57",        cat = "CSS武器" },
	{ class = "weapon_cs_glock",        name = "格洛克",      cat = "CSS武器" },
	{ class = "weapon_cs_usp",          name = "USP消音版",   cat = "CSS武器" },
	{ class = "weapon_cs_p228",         name = "P228",        cat = "CSS武器" },
	{ class = "weapon_cs_m3",           name = "M3霰弹枪",    cat = "CSS武器" },
	{ class = "weapon_cs_mac10",        name = "MAC-10",      cat = "CSS武器" },
	{ class = "weapon_cs_mp5navy",      name = "MP5海军",     cat = "CSS武器" },
	{ class = "weapon_cs_p90",          name = "P90",         cat = "CSS武器" },
	{ class = "weapon_cs_tmp",          name = "TMP",         cat = "CSS武器" },
	{ class = "weapon_cs_ump45",        name = "UMP45",       cat = "CSS武器" },
	{ class = "weapon_cs_ak47",         name = "AK-47",       cat = "CSS武器" },
	{ class = "weapon_cs_aug",          name = "AUG",         cat = "CSS武器" },
	{ class = "weapon_cs_famas",        name = "FAMAS",       cat = "CSS武器" },
	{ class = "weapon_cs_galil",        name = "Galil",       cat = "CSS武器" },
	{ class = "weapon_cs_m4a1",         name = "M4A1消音版",  cat = "CSS武器" },
	{ class = "weapon_cs_sg552",        name = "SG552",       cat = "CSS武器" },
	{ class = "weapon_cs_awp",          name = "AWP",         cat = "CSS武器" },
	{ class = "weapon_cs_g3sg1",        name = "G3SG1",       cat = "CSS武器" },
	{ class = "weapon_cs_scout",        name = "Scout",       cat = "CSS武器" },
	{ class = "weapon_cs_sg550",        name = "SG550",       cat = "CSS武器" },
	{ class = "weapon_cs_m249",         name = "M249",        cat = "CSS武器" },

	-- 工具
	{ class = "gmod_tool",          name = "工具枪",     cat = "工具" },
	{ class = "gmod_camera",        name = "相机",       cat = "工具" },

	-- 道具
	{ class = "prop_physics",       name = "物理道具",     cat = "道具" },
	{ class = "prop_dynamic",       name = "动态道具",     cat = "道具" },
	{ class = "prop_ragdoll",       name = "布娃娃",       cat = "道具" },
	{ class = "item_suit",          name = "防护服",       cat = "道具" },
	{ class = "item_healthkit",     name = "医疗包",       cat = "道具" },
	{ class = "item_healthvial",    name = "医疗瓶",       cat = "道具" },
	{ class = "item_healthcharger", name = "生命恢复仪",   cat = "道具" },
	{ class = "item_battery",       name = "电池",         cat = "道具" },
	{ class = "item_suitcharger",   name = "防护服充电仪", cat = "道具" },
	{ class = "combine_mine",            name = "联合军跳雷",   cat = "道具" },
	{ class = "combine_mine_resistance", name = "反抗军跳雷",   cat = "道具" },
	{ class = "grenade_helicopter",      name = "直升机炸弹",   cat = "道具" },
	{ class = "sent_ball",               name = "弹力球",       cat = "道具" },
	{ class = "item_box_buckshot",        name = "霰弹弹药箱",   cat = "道具" },

	-- 座椅
	{ class = "prop_physics",  name = "办公室座椅",   cat = "座椅", model = "models/props_c17/FurnitureChair001a.mdl" },
	{ class = "prop_physics",  name = "真皮办公椅",   cat = "座椅", model = "models/props_c17/FurnitureChair002a.mdl" },
	{ class = "prop_physics",  name = "铁质凳子",     cat = "座椅", model = "models/props_c17/FurnitureChair003a.mdl" },
	{ class = "prop_physics",  name = "木质凳子",     cat = "座椅", model = "models/props_c17/FurnitureChair004a.mdl" },
	{ class = "prop_physics",  name = "汽艇座椅",     cat = "座椅", model = "models/nova/airboat_seat.mdl" },
	{ class = "prop_physics",  name = "老爷车座椅",   cat = "座椅", model = "models/nova/jalopy_seat.mdl" },
	{ class = "prop_physics",  name = "吉普车座椅",   cat = "座椅", model = "models/nova/jeep_seat.mdl" },

	-- 载具
	{ class = "prop_vehicle_jeep",         name = "吉普车",     cat = "载具" },
	{ class = "prop_vehicle_airboat",      name = "汽艇",       cat = "载具" },
	{ class = "prop_vehicle_prisoner_pod", name = "囚犯舱",     cat = "载具" },
	{ class = "prop_vehicle_apc",          name = "装甲战车",   cat = "载具" },

	-- 弹药
	{ class = "item_ammo_pistol",           name = "手枪弹药",     cat = "弹药" },
	{ class = "item_ammo_pistol_large",     name = "手枪弹药(大)", cat = "弹药" },
	{ class = "item_ammo_357",              name = "左轮弹药",     cat = "弹药" },
	{ class = "item_ammo_357_large",        name = "左轮弹药(大)", cat = "弹药" },
	{ class = "item_ammo_smg1",             name = "SMG弹药",      cat = "弹药" },
	{ class = "item_ammo_smg1_large",       name = "SMG弹药(大)",  cat = "弹药" },
	{ class = "item_ammo_ar2",              name = "AR2弹药",      cat = "弹药" },
	{ class = "item_ammo_ar2_large",        name = "AR2弹药(大)",  cat = "弹药" },
	{ class = "item_ammo_ar2_altfire",      name = "AR2能量球",    cat = "弹药" },
	{ class = "item_ammo_smg1_grenade",     name = "SMG榴弹",      cat = "弹药" },
	{ class = "item_ammo_buckshot",         name = "霰弹弹药",     cat = "弹药" },
	{ class = "item_ammo_crossbow",         name = "弩箭",         cat = "弹药" },
	{ class = "item_rpg_round",             name = "RPG火箭弹",    cat = "弹药" },

	-- 管理员武器 (并入武器分类，需要 superadmin 权限)
	{ class = "weapon_flechettegun",        name = "钢茅枪",       cat = "武器", access = "superadmin" },
	{ class = "weapon_medkit",              name = "医疗包",       cat = "道具", access = "superadmin" },
	{ class = "manhack_welder",             name = "飞锯枪",       cat = "武器", access = "superadmin" },
	{ class = "weapon_spraypatterncreator", name = "喷漆图案器",   cat = "工具", access = "superadmin" },
}

-- ===== classname → access 快速查找表 =====
local itemAccess = {}
for _, it in ipairs( persistent_items ) do
	if it.access then
		itemAccess[ it.class ] = it.access
	end
end

-- ===== 获取可用道具列表 (按权限过滤) =====
function ulx.getAvailableItems( ply )
	if ply and ply:IsValid() then
		local filtered = {}
		for _, it in ipairs( persistent_items ) do
			if not it.access or ply:query( it.access ) then
				table.insert( filtered, it )
			end
		end
		return filtered
	end
	return persistent_items
end

-- ===== 检查管理员道具权限 (无权限时返回 false + 提示) =====
local function checkItemAccess( ply, classname )
	local required = itemAccess[ classname ]
	if required and not ply:query( required ) then
		ULib.tsayError( ply, "你没有使用该管理道具的权限。", true )
		return false
	end
	return true
end

-- ===== 智能给予道具 (根据类型自动处理) =====
function ulx.giveItem( calling_ply, target_plys, classname, quantity, secAmmo )
	if not checkItemAccess( calling_ply, classname ) then return {} end
	quantity = math.Clamp( quantity or 0, 0, 9999 )
	secAmmo = math.Clamp( secAmmo or 0, 0, 9999 )
	local affected = {}
	local isWeapon = classname:find( "^weapon_" ) or classname:find( "^gmod_" )
	local isAmmo = classname:find( "^item_ammo_" ) or classname:find( "^item_box_" )
	local isConsumable = ( classname == "weapon_frag" or classname == "weapon_slam" or classname == "weapon_hegrenade" or classname == "weapon_flashbang" or classname == "weapon_smokegrenade" )
	local isItem = classname:find( "^item_" ) and not isAmmo
	local dualAmmo = { ["weapon_smg1"]={"SMG1","SMG1_Grenade"}, ["weapon_ar2"]={"AR2","AR2AltFire"} }

	-- 消耗品弹药类型映射
	local consumableAmmo = {
		["weapon_frag"] = "Grenade",
		["weapon_slam"] = "Slam",
	}
	-- 弹药物品→弹药类型 (避免循环9999次Give创建大量实体)
	local ammoToType = {
		["item_ammo_pistol"] = "pistol",       ["item_ammo_pistol_large"] = "pistol",
		["item_ammo_357"] = "357",             ["item_ammo_357_large"] = "357",
		["item_ammo_smg1"] = "smg1",           ["item_ammo_smg1_large"] = "smg1",
		["item_ammo_ar2"] = "ar2",             ["item_ammo_ar2_large"] = "ar2",
		["item_ammo_ar2_altfire"] = "AR2AltFire", ["item_ammo_smg1_grenade"] = "SMG1_Grenade",
		["item_ammo_buckshot"] = "buckshot",
		["item_ammo_crossbow"] = "xbowbolt",
		["item_rpg_round"] = "rpg_round",
	}

	for _, ply in ipairs( target_plys ) do
		if ply:Alive() then

			if isConsumable then
				ply:Give( classname )
				local aType = consumableAmmo[classname]
				if aType and quantity > 1 then ply:GiveAmmo( quantity - 1, aType, true ) end

			elseif isAmmo then
				local aType = ammoToType[classname]
				if aType then
					ply:GiveAmmo( quantity, aType, true )
				else
					for i = 1, math.min( quantity, 200 ) do ply:Give( classname ) end
				end

			elseif isItem then
				for i = 1, math.min( quantity, 500 ) do ply:Give( classname ) end
			elseif isWeapon then
				ply:Give( classname )
				local d = dualAmmo[classname]
				if d then
					if quantity > 0 then ply:GiveAmmo( quantity, d[1], true ) end
					if secAmmo > 0 then ply:GiveAmmo( secAmmo, d[2], true ) end
				else
					if quantity > 0 then
						ply:GiveAmmo( quantity, "pistol", true )
						ply:GiveAmmo( quantity, "357", true )
						ply:GiveAmmo( quantity, "smg1", true )
						ply:GiveAmmo( quantity, "ar2", true )
						ply:GiveAmmo( quantity, "buckshot", true )
						ply:GiveAmmo( quantity, "xbowbolt", true )
						ply:GiveAmmo( quantity, "rpg_round", true )
					end
				end
			else
				for i = 1, math.min( quantity, 50 ) do ply:Give( classname ) end
			end

			table.insert( affected, ply )
		end
	end
	return affected
end

-- ===== 补充弹药 =====
function ulx.giveAmmo( calling_ply, target_plys, ammo_type, amount )
	local affected = {}
	for _, ply in ipairs( target_plys ) do
		if ply:Alive() then
			if ammo_type and ammo_type ~= "" then
				ply:GiveAmmo( amount or 999, ammo_type, true )
			else
				ply:GiveAmmo( amount or 999, "pistol", true )
				ply:GiveAmmo( amount or 999, "357", true )
				ply:GiveAmmo( amount or 999, "smg1", true )
				ply:GiveAmmo( amount or 999, "ar2", true )
				ply:GiveAmmo( amount or 999, "buckshot", true )
				ply:GiveAmmo( amount or 999, "xbowbolt", true )
				ply:GiveAmmo( amount or 999, "rpg_round", true )
			end
			table.insert( affected, ply )
		end
	end
	return affected
end

-- ===== 获取玩家背包 =====
function ulx.getPlayerInventory( ply )
	if not ply:IsValid() then return {} end
	local weapons = {}
	for _, wep in ipairs( ply:GetWeapons() ) do
		if wep:IsValid() then
			table.insert( weapons, {
				class = wep:GetClass(),
				printname = wep:GetPrintName() or wep:GetClass(),
				clip1 = wep:Clip1(),
				clip2 = wep:Clip2(),
			} )
		end
	end
	return weapons
end

-- ===== 网络消息处理 =====
if SERVER then
	-- 接收给予道具请求
	net.Receive( "ulx_items_give", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, "你没有使用道具管理的权限。", true); return end
		local count = net.ReadUInt( 8 )
		local targets = {}
		for i = 1, count do
			local sid64 = net.ReadString()
			local p = player.GetBySteamID64( sid64 )
			if IsValid( p ) then table.insert( targets, p ) end
		end
		local classname = net.ReadString()
		local quantity = net.ReadUInt( 16 )
		local secAmmo = net.ReadUInt( 16 )
		local result = ulx.giveItem( ply, targets, classname, quantity, secAmmo )
		if #result > 0 then
			ulx.fancyLogAdmin( ply, "#A 给予 " .. #result .. " 名玩家 " .. classname .. " x" .. quantity )
		end
	end )

	-- 接收补充弹药请求
	net.Receive( "ulx_items_ammo", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, "你没有使用道具管理的权限。", true); return end
		local count = net.ReadUInt( 8 )
		local targets = {}
		for i = 1, count do
			local sid64 = net.ReadString()
			local p = player.GetBySteamID64( sid64 )
			if IsValid( p ) then table.insert( targets, p ) end
		end
		local ammoType = net.ReadString()
		local amount = net.ReadUInt( 16 )
		local result = ulx.giveAmmo( ply, targets, ammoType, amount )
		if ammoType == "" then
			ulx.fancyLogAdmin( ply, "#A 补充了 #i 名玩家的全部弹药", #result )
		else
			ulx.fancyLogAdmin( ply, "#A 给予 #i 名玩家 " .. ammoType .. " 弹药 x" .. amount, #result )
		end
	end )

	-- 在玩家面前生成实体 (使用 list.Get("Vehicles") 官方数据)

	-- 智能地面生成: 网格排列 + 双级碰撞策略 (载具/座椅/大型道具)
	-- 独立 X/Y 间距, 最大化空间利用率
	-- 碰撞级: 最优=-30%(130%包围盒) → 最小=+8%(92%包围盒)
	-- 返回: entities, count, quality ("optimal"/"tight"/"partial")
	local function smartGroundSpawn( entClass, owner, quantity, centerHit, ang, vdata, mdl )
		local COLLISION_OPT = 1.30
		local COLLISION_MIN = 0.92
		local GROUND_OFFSET  = 300
		local GROUND_DEPTH   = 600

		-- 步骤1: 探头测量精确包围盒
		local probe = ents.Create( entClass )
		if not IsValid( probe ) then return {}, 0, "fail" end
		if mdl then probe:SetModel( mdl ) end
		if vdata and vdata.KeyValues then
			for k, v in pairs( vdata.KeyValues ) do probe:SetKeyValue( k, v ) end
		end
		probe:SetPos( centerHit + Vector( 0, 0, 100 ) )
		probe:SetAngles( ang )
		probe:Spawn()
		if not IsValid( probe ) then return {}, 0, "fail" end
		probe:Activate()
		local physProbe = probe:GetPhysicsObject()
		if IsValid( physProbe ) then physProbe:EnableMotion( false ) end
		local mins, maxs = probe:GetCollisionBounds()
		probe:Remove()

		-- 独立 X/Y 包围盒基础值
		local bboxW = maxs.x - mins.x
		local bboxD = maxs.y - mins.y
		local entityH = maxs.z - mins.z
		local heightOff = math.max( -mins.z, 2 )
		local yaw = math.rad( ang.y )
		local cosY, sinY = math.cos( yaw ), math.sin( yaw )

		-- 先预估搜索范围, 用于确定高度图采样区域
		local preMaxLayers = math.max( 1, math.ceil( math.sqrt( quantity ) * 3.2 ) )
		local preMaxDist = math.max( bboxW, bboxD ) * preMaxLayers * 0.7

		-- 步骤1.5: 密集高度图采样 (网格 N×N, 覆盖预估搜索区)
		local HGRID = 8  -- 8×8 = 64 采样点
		local heightMap = {}     -- [iy][ix] = { z, flat }
		local hSamples, hSumZ, hMinZ, hMaxZ, hSumFlat = 0, 0, 99999, -99999, 0
		for iy = 0, HGRID do
			heightMap[iy] = {}
			for ix = 0, HGRID do
				local lx = (ix / HGRID - 0.5) * 2 * preMaxDist
				local ly = (iy / HGRID - 0.5) * 2 * preMaxDist
				local wx = centerHit.x + (lx * cosY - ly * sinY)
				local wy = centerHit.y + (lx * sinY + ly * cosY)
				local tr = util.TraceLine({
					start  = Vector( wx, wy, centerHit.z + 500 ),
					endpos = Vector( wx, wy, centerHit.z - 800 ),
					filter = owner
				})
				if tr.Hit and tr.HitNormal.z >= 0.50 then
					heightMap[iy][ix] = { z = tr.HitPos.z, flat = tr.HitNormal.z }
					hSamples = hSamples + 1
					hSumZ = hSumZ + tr.HitPos.z
					hSumFlat = hSumFlat + tr.HitNormal.z
					if tr.HitPos.z < hMinZ then hMinZ = tr.HitPos.z end
					if tr.HitPos.z > hMaxZ then hMaxZ = tr.HitPos.z end
				else
					heightMap[iy][ix] = nil  -- 无效区域
				end
			end
		end

		-- 地形统计
		local hAvgZ = (hSamples > 0) and (hSumZ / hSamples) or centerHit.z
		local hRange = (hSamples > 2) and (hMaxZ - hMinZ) or 0
		local avgFlat = (hSamples > 0) and (hSumFlat / hSamples) or 0.7
		local terrainQ = math.Clamp( (avgFlat - 0.55) / 0.45, 0, 1 )
		-- 起伏惩罚: 高度差 > 100 则降低质量分
		local undulationPenalty = math.Clamp( hRange / 200, 0, 0.5 )
		terrainQ = math.max( 0.1, terrainQ - undulationPenalty )
		-- 最低高度限制: 低于平均高度 150+ 单位视为深坑, 提升实体高度偏移
		local minAllowedZ = hAvgZ - 150
		local deepPitOffset = math.max( 0, (hAvgZ - hMinZ) - 150 ) * 0.5

		-- 高度图查询函数: 已知世界坐标, 估算地面高度
		local function estimateGroundZ( wx, wy )
			-- 将世界坐标映射到高度图网格
			local lx = (wx - centerHit.x) * cosY + (wy - centerHit.y) * sinY  -- 逆旋转
			local ly = -(wx - centerHit.x) * sinY + (wy - centerHit.y) * cosY
			local ux = (lx / preMaxDist + 1) * 0.5  -- 映射到 0~1
			local uy = (ly / preMaxDist + 1) * 0.5
			-- 钳制到有效范围
			if ux < 0 or ux > 1 or uy < 0 or uy > 1 then return nil end
			-- 双线性插值
			local fx = ux * HGRID
			local fy = uy * HGRID
			local ix0, iy0 = math.floor( fx ), math.floor( fy )
			local ix1, iy1 = math.min( ix0 + 1, HGRID ), math.min( iy0 + 1, HGRID )
			local tx, ty = fx - ix0, fy - iy0
			local v00 = heightMap[iy0] and heightMap[iy0][ix0]
			local v10 = heightMap[iy0] and heightMap[iy0][ix1]
			local v01 = heightMap[iy1] and heightMap[iy1][ix0]
			local v11 = heightMap[iy1] and heightMap[iy1][ix1]
			if not v00 or not v10 or not v01 or not v11 then return nil end
			local z0 = v00.z * (1-tx) + v10.z * tx
			local z1 = v01.z * (1-tx) + v11.z * tx
			return z0 * (1-ty) + z1 * ty
		end

		-- 动态间距: 平坦→50%, 起伏→30%, 含深坑补偿
		local spacingMul = 0.30 + terrainQ * 0.20
		local cellX = math.max( bboxW * spacingMul, 14 )
		local cellY = math.max( bboxD * spacingMul, 14 )

		-- 自适应搜索范围
		local maxLayers = math.max( 1, math.ceil( math.sqrt( quantity ) * (3.0 + terrainQ * 0.5) ) )
		local maxSearchDist = math.max( cellX, cellY ) * maxLayers * 1.3

		-- 步骤2: 多策略网格排列 — 3种六角密排偏移, 择优
		local STAGGERS = { 0.25, 0.50, 0.75 }  -- 三种六角密排偏移量

		local function tryGridPlace( factor, needed, firstPos, staggerOffset )
			local sx = cellX * factor
			local sy = cellY * factor
			local cMins = mins * factor
			local cMaxs = maxs * factor
			local minDistSq = math.min( sx, sy ) ^ 2

			local positions = {}
			for layer = 1, maxLayers do
				if #positions >= needed then break end
				local cells = {}
				for dx = -layer, layer do
					for dy = -layer, layer do
						table.insert( cells, { dx, dy } )
					end
				end
				table.sort( cells, function( a, b )
					return (a[1]*a[1] + a[2]*a[2]) < (b[1]*b[1] + b[2]*b[2])
				end )

				for _, cell in ipairs( cells ) do
					if #positions >= needed then break end
					local stagger = (cell[2] % 2 == 0) and (sx * staggerOffset) or 0
					local lx = cell[1] * sx + stagger
					local ly = cell[2] * sy
					local wx = centerHit.x + (lx * cosY - ly * sinY)
					local wy = centerHit.y + (lx * sinY + ly * cosY)
					local testPos = Vector( wx, wy, centerHit.z )

					if testPos:Distance( centerHit ) > maxSearchDist then break end

					-- 高度图预估地面: 缩小追踪范围, 提升精度
					local estZ = estimateGroundZ( wx, wy )
					local tStart, tEnd
					if estZ then
						tStart = Vector( wx, wy, estZ + 200 )
						tEnd   = Vector( wx, wy, estZ - 200 )
					else
						tStart = testPos + Vector( 0, 0, GROUND_OFFSET )
						tEnd   = testPos + Vector( 0, 0, -GROUND_DEPTH )
					end

					local tr = util.TraceLine({ start = tStart, endpos = tEnd, filter = owner })
					if tr.Hit and tr.HitNormal.z >= 0.50 then
						-- 最低高度过滤: 深坑/低洼区域拒绝生成
						if tr.HitPos.z < minAllowedZ then break end

						local baseH = heightOff + deepPitOffset
						local spawnPos = tr.HitPos + Vector( 0, 0, baseH )
						local ok = true

						if firstPos and spawnPos:DistToSqr( firstPos ) < minDistSq then ok = false end
						if ok then
							for _, p in ipairs( positions ) do
								if spawnPos:DistToSqr( p ) < minDistSq then ok = false; break end
							end
						end
						if ok then
							local connDist = (spawnPos - centerHit):Length()
							if connDist > cellX * 0.8 then
								local connTr = util.TraceLine({
									start  = spawnPos + Vector( 0, 0, 10 ),
									endpos = centerHit + Vector( 0, 0, 10 ),
									filter = owner
								})
								if connTr.Hit and connTr.HitPos:Distance( spawnPos ) < connDist * 0.6 then
									ok = false
								end
							end
						end
						if ok then
							local hTr = util.TraceHull({
								start = spawnPos, endpos = spawnPos,
								mins = cMins, maxs = cMaxs, filter = owner
							})
							if not hTr.Hit then
								table.insert( positions, spawnPos )
							end
						end
					end
				end
			end
			return positions
		end

		-- 多策略择优: 对每种碰撞级别, 尝试3种偏移取最优
		local function bestPlacement( factor, needed, firstPos )
			local best = {}
			for _, off in ipairs( STAGGERS ) do
				local result = tryGridPlace( factor, needed, firstPos, off )
				if #result > #best then best = result end
				if #best >= needed then break end  -- 已满, 无需再试
			end
			return best
		end

		-- 先生成首个实体 (准星中心点)
		local first = ents.Create( entClass )
		if not IsValid( first ) then return {}, 0, "fail" end
		if mdl then first:SetModel( mdl ) end
		if vdata and vdata.KeyValues then
			for k, v in pairs( vdata.KeyValues ) do first:SetKeyValue( k, v ) end
		end
		local firstPos = centerHit + Vector( 0, 0, heightOff )
		first:SetPos( firstPos )
		first:SetAngles( ang )
		first:Spawn()
		if not IsValid( first ) then return {}, 0, "fail" end
		first:Activate()
		local placed = { first }

		-- 阶段A: 最优碰撞 → 多策略择优
		local positions = bestPlacement( COLLISION_OPT, quantity - 1, firstPos )
		local quality = "optimal"

		if #positions < quantity - 1 then
			-- 阶段B: 最小碰撞 → 多策略择优
			positions = bestPlacement( COLLISION_MIN, quantity - 1, firstPos )
			if #positions >= quantity - 1 then
				quality = "tight"
			else
				quality = "partial"
			end
		end

		-- 在网格位置生成剩余实体
		for _, pos in ipairs( positions ) do
			if #placed >= quantity then break end
			local ent = ents.Create( entClass )
			if IsValid( ent ) then
				if mdl then ent:SetModel( mdl ) end
				if vdata and vdata.KeyValues then
					for k, v in pairs( vdata.KeyValues ) do ent:SetKeyValue( k, v ) end
				end
				ent:SetPos( pos )
				ent:SetAngles( ang )
				ent:Spawn()
				if IsValid( ent ) then
					ent:Activate()
					table.insert( placed, ent )
				end
			end
		end

		return placed, #placed, quality
	end

	net.Receive( "ulx_items_spawn", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, "你没有使用道具管理的权限。", true); return end
		startSpawnBatch( ply )  -- 开始新批次记录

		local count = net.ReadUInt( 8 )
		local targets = {}
		for i = 1, count do
			local sid64 = net.ReadString()
			local p = player.GetBySteamID64( sid64 )
			if IsValid( p ) then table.insert( targets, p ) end
		end

		local classname = net.ReadString()
		local quantity = net.ReadUInt( 16 )
		local vkey = net.ReadString()
		quantity = math.Clamp( quantity, 1, 10 )

		-- 逐项权限校验
		if not checkItemAccess( ply, classname ) then return end

		local vdata = nil
		if vkey ~= "" then
			vdata = list.Get( "Vehicles" )[vkey]
		end

		local spawned = 0
		-- 挂墙实体列表 (充电仪等)
		local wallMounts = {
			["item_healthcharger"] = true,
			["item_suitcharger"] = true,
		}
		for _, target in ipairs( targets ) do
			local trace = target:GetEyeTrace()
			local isWallMount = wallMounts[ classname ]
			local pos, ang, normal

			if isWallMount then
				-- 高精度体积球采样 + 墙角规避 (包围盒级别)
				local hitPos = trace.HitPos
				local centerNorm = trace.HitNormal
				local radius = 32
				local margin = 1.09
				local right = centerNorm:Cross( Vector(0,0,1) ):GetNormalized()
				if right:Length() < 0.1 then right = centerNorm:Cross( Vector(1,0,0) ):GetNormalized() end
				local up = centerNorm:Cross( right ):GetNormalized()
				local primaryNormals = {}
				local weights = {}
				local cornerHits = {}
				local samples = 16  -- 提升精度
				for pi = 1, samples do
					local phi = (pi / samples) * math.pi * 0.48
					local ringSamples = math.floor( samples * math.sin(phi) * 3 ) + 6
					for ti = 1, ringSamples do
						local theta = (ti / ringSamples) * math.pi * 2
						local dir = right * math.cos(theta) * math.sin(phi)
						          + up    * math.sin(theta) * math.sin(phi)
						          + centerNorm * math.cos(phi)
						local tr = util.TraceLine({
							start = hitPos + dir * radius,
							endpos = hitPos - dir * 4,
							filter = target
						})
						if tr.Hit and tr.HitPos:Distance( hitPos ) <= radius then
							-- 就近策略：排除远距离背景面 (杆/栅栏穿透)
							local dist = tr.HitPos:Distance( hitPos )
							if dist <= radius * 0.4 then
								local dot = tr.HitNormal:Dot( centerNorm )
								if dot > 0.6 then
									-- 加权: 越靠近中心权重越高
									local w = dot * (1 - dist / radius)
									table.insert( primaryNormals, tr.HitNormal * w )
									table.insert( weights, w )
								else
									table.insert( cornerHits, { pos = tr.HitPos, normal = tr.HitNormal } )
								end
							end
						end
					end
				end
				-- 加权平均法线
				centerNorm = centerNorm * 2  -- 中心点权重×2
				local sumW = 2
				local avg = centerNorm * 2
				for i, n in ipairs( primaryNormals ) do
					avg = avg + n; sumW = sumW + (weights[i] or 1)
				end
				if #primaryNormals > 0 then avg = avg / sumW; avg:Normalize() end
				normal = avg				-- 遮挡率检测 (>35% 则拒绝)
				local totalRays = 0
				for pi = 1, samples do
					totalRays = totalRays + math.floor( samples * math.sin((pi/samples)*math.pi*0.48) * 3 ) + 6
				end
				local occlusionRate = 1 - (#primaryNormals / math.max(totalRays, 1))
				if occlusionRate > 0.40 then
					ULib.tsayError( ply, "严重遮挡 ("..math.floor(occlusionRate*100).."%), 请更换位置。", true )
					return
				end				pos = hitPos + normal * (0.9 * margin)
				-- 墙角补偿: 去重后逐一推出
				local pushed = {}
				for _, cn in ipairs( cornerHits ) do
					local key = math.floor(cn.normal.x*10)..","..math.floor(cn.normal.y*10)..","..math.floor(cn.normal.z*10)
					if not pushed[key] then
						pushed[key] = true
						local toWall = (cn.pos - pos):Dot( cn.normal )
						if toWall < 14 then
							pos = pos + cn.normal * (14 - toWall) * margin
						end
					end
				end
				ang = normal:Angle()
				pos.z = pos.z - 6
				quantity = 1

				-- 挂墙实体生成 (始终1个, 使用原有逻辑)
				local ent = ents.Create( classname )
				if IsValid( ent ) then
					ent:SetPos( pos )
					ent:SetAngles( ang )
					ent:Spawn()
					if IsValid( ent ) then
						ent:Activate()
						local phys = ent:GetPhysicsObject()
						if IsValid( phys ) then
							local lMins, lMaxs = ent:GetCollisionBounds()
							local maxPen = 0
							for x = 0, 1 do for y = 0, 1 do for z = 0, 1 do
								local corner = Vector(
									x == 0 and lMins.x or lMaxs.x,
									y == 0 and lMins.y or lMaxs.y,
									z == 0 and lMins.z or lMaxs.z
								)
								corner = ent:LocalToWorld( corner )
								local pen = (trace.HitPos - corner):Dot( normal )
								if pen > maxPen then maxPen = pen end
							end end end
							if maxPen > 0 then
								ent:SetPos( ent:GetPos() + normal * maxPen )
							end
							phys:EnableMotion( false )
						end
						trackSpawn( ply, ent )
						spawned = spawned + 1
					else
						ent:Remove()
					end
				end
			else
				-- 地面实体：球形辐射扩散 + 双级碰撞策略生成
				local mdl = nil
				if vdata then
					mdl = vdata.Model
				elseif classname == "prop_ragdoll" then
					mdl = "models/player/group01/male_01.mdl"
				end
				local entClass = vdata and vdata.Class or classname
				ang = target:EyeAngles()
				ang.p = 0  -- 保持水平

				local entsPlaced, nPlaced, quality = smartGroundSpawn( entClass, target, quantity, trace.HitPos, ang, vdata, mdl )
				for _, e in ipairs( entsPlaced ) do
					trackSpawn( ply, e )
					spawned = spawned + 1
				end

				-- 空间/碰撞质量反馈 (立即通知)
				if nPlaced == 0 then
					ULib.tsayError( ply, string.format( ULib.ulx_lang.T("items_spawn_nospace"), classname ), true )
				elseif nPlaced < quantity then
					ULib.tsay( ply, string.format( ULib.ulx_lang.T("items_spawn_partial"), nPlaced, quantity, classname ), true )
				elseif quality == "optimal" then
					ULib.tsay( ply, string.format( ULib.ulx_lang.T("items_spawn_optimal"), nPlaced, quantity, classname ), true )
				elseif quality == "tight" then
					ULib.tsay( ply, string.format( ULib.ulx_lang.T("items_spawn_tight"), nPlaced, quantity, classname ), true )
				end
			end
		end

		if spawned > 0 then
			ulx.fancyLogAdmin( ply, string.format( ULib.ulx_lang.T("log_spawn"), classname, spawned, #targets ) )
		else
			ULib.tsayError( ply, string.format( ULib.ulx_lang.T("items_spawn_fail"), classname ), true )
		end
	end )

	-- 接收查询背包请求
	net.Receive( "ulx_items_inventory", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, "你没有使用道具管理的权限。", true); return end
		local sid64 = net.ReadString()
		local target = player.GetBySteamID64( sid64 )
		if not IsValid( target ) then return end

		local inventory = ulx.getPlayerInventory( target )

		net.Start( "ulx_items_inventory" )
		net.WriteString( sid64 )
		net.WriteString( target:Nick() )
		net.WriteUInt( #inventory, 8 )
		for _, wep in ipairs( inventory ) do
			net.WriteString( wep.class )
			net.WriteString( wep.printname )
			net.WriteInt( wep.clip1, 16 )
			net.WriteInt( wep.clip2, 16 )
		end
		net.Send( ply )
	end )
end

-- ===== 客户端接收背包数据 =====
if CLIENT then
	net.Receive( "ulx_items_inventory", function()
		local sid64 = net.ReadString()
		local nick = net.ReadString()
		local count = net.ReadUInt( 8 )
		local weapons = {}
		for i = 1, count do
			table.insert( weapons, {
				class = net.ReadString(),
				printname = net.ReadString(),
				clip1 = net.ReadInt( 16 ),
				clip2 = net.ReadInt( 16 ),
			} )
		end
		-- 触发事件, 由 UI 模块处理
		hook.Run( "ULXItemsInventoryReceived", sid64, nick, weapons )
	end )
end

-- ===== 服务器接收撤回/清除请求 =====
if SERVER then
	-- 接收撤回请求: 撤回上一次生成的整批实体
	net.Receive( "ulx_items_spawn_undo", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then return end
		local T = ULib.ulx_lang.T
		local data = plySpawned[ply]
		if not data or not data.batches or #data.batches == 0 then
			ULib.tsay( ply, T("items_spawn_undo_none"), true )
			return
		end
		-- 取出最后一个批次
		local lastBatch = table.remove( data.batches )
		if not lastBatch or not lastBatch.entities or #lastBatch.entities == 0 then
			ULib.tsay( ply, T("items_spawn_undo_none"), true )
			return
		end
		-- 逆序移除 (后生成的先删, 避免依赖问题)
		local count = 0
		for i = #lastBatch.entities, 1, -1 do
			count = count + forceRemoveEntity( lastBatch.entities[i] )
			-- 同步清理 all 列表
			for j, e in ipairs( data.all ) do
				if e == lastBatch.entities[i] then
					table.remove( data.all, j )
					break
				end
			end
		end
		if count > 0 then
			ULib.tsay( ply, string.format( T("items_spawn_undo_ok"), count ), true )
		else
			ULib.tsay( ply, T("items_spawn_undo_gone"), true )
		end
	end )

	-- 接收清除请求: 清除该管理员全部已生成实体
	net.Receive( "ulx_items_spawn_clear", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then return end
		local T = ULib.ulx_lang.T
		local data = plySpawned[ply]
		if not data or not data.all or #data.all == 0 then
			ULib.tsay( ply, T("items_spawn_clear_none"), true )
			return
		end
		local count = 0
		for _, ent in ipairs( data.all ) do
			count = count + forceRemoveEntity( ent )
		end
		plySpawned[ply] = nil  -- 完全清除记录
		if count > 0 then
			ULib.tsay( ply, string.format( T("items_spawn_clear_ok"), count ), true )
		else
			ULib.tsay( ply, T("items_spawn_clear_none"), true )
		end
	end )
end
