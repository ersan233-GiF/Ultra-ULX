local plySpawned = {}
local L = ULib.ulx_lang
local function startSpawnBatch( ply )
	if not IsValid( ply ) then return end
	plySpawned[ply] = plySpawned[ply] or { batches = {}, all = {} }
	table.insert( plySpawned[ply].batches, { entities = {} } )
end
local function trackSpawn( ply, ent )
	if not IsValid(ply) or not IsValid(ent) then return end
	local data = plySpawned[ply]
	if not data then return end
	local batch = data.batches[#data.batches]
	if batch then table.insert( batch.entities, ent ) end
	table.insert( data.all, ent )
end
local function forceRemoveEntity( ent )
	if not IsValid( ent ) then return 0 end
	if ent.GetDriver and IsValid( ent:GetDriver() ) then
		ent:GetDriver():ExitVehicle()
	end
	if ent.GetPassenger then
		for seat = 0, 8 do
			local p = ent:GetPassenger( seat )
			if IsValid( p ) then p:ExitVehicle() end
		end
	end
	local phys = ent:GetPhysicsObject()
	if IsValid( phys ) then phys:EnableMotion( true ) end
	SafeRemoveEntity( ent )
	if IsValid( ent ) then ent:Remove() end
	return 1
end
if SERVER then
	if not ulx_items_net_init then
		util.AddNetworkString( "ulx_items_give" )
		util.AddNetworkString( "ulx_items_inventory" )
		util.AddNetworkString( "ulx_items_spawn" )
		util.AddNetworkString( "ulx_items_spawn_undo" )
		util.AddNetworkString( "ulx_items_spawn_clear" )
		ulx_items_net_init = true
	end
	ULib.ucl.registerAccess( "xgui_manageitems", "admin", "允许在 XGUI 中使用道具管理面板。", "XGUI" )
end
local function buildPersistentItems()
	local items = {}
	for _, cat in ipairs(ulx.itemOrder) do
		for _, it in ipairs(ulx.itemRegistry[cat] or {}) do
			table.insert(items, {
				class  = it.class,
				name   = it.n or it.name,
				cat    = cat,
				type   = it.t or it.type,
				access = it.a or it.access,
				model  = it.model,
				vkey   = it.k or it.vkey,
			})
		end
	end
	return items
end
local function buildItemAccess()
	local acc = {}
	for _, cat in ipairs(ulx.itemOrder) do
		for _, it in ipairs(ulx.itemRegistry[cat] or {}) do
			local a = it.a or it.access
			if a and a ~= "" and it.class then
				acc[it.class] = a
			end
		end
	end
	return acc
end
local function getPersistentItems()
	return buildPersistentItems()
end
function ulx.getAvailableItems( ply )
	local items = getPersistentItems()
	if ply and ply:IsValid() then
		local access = buildItemAccess()
		local filtered = {}
		for _, it in ipairs(items) do
			local required = access[it.class]
			if not required or required == "" or ply:query(required) then
				table.insert(filtered, it)
			end
		end
		return filtered
	end
	return items
end
local function denyItemAccess( ply )
	if IsValid( ply ) then
		ULib.tsayError( ply, L.T("items_no_permission"), true )
	end
end
local function getRegisteredItem( classname, vkey )
	if not classname or classname == "" then return nil end
	local wantedKey = vkey or ""
	local function matches( it )
		if not it then return false end
		local class = it.class or it.c
		local key = it.k or it.vkey or ""
		if class ~= classname then return false end
		if wantedKey ~= "" and key ~= wantedKey then return false end
		return true
	end
	local direct = ulx.getItemDef and ulx.getItemDef( classname )
	if matches( direct ) then return direct end
	for _, cat in ipairs( ulx.itemOrder or {} ) do
		for _, it in ipairs( ulx.itemRegistry[cat] or {} ) do
			if matches( it ) then return it end
		end
	end
	return nil
end
local function checkItemAccess( ply, classname, vkey )
	local item = getRegisteredItem( classname, vkey )
	if not item then
		denyItemAccess( ply )
		return false
	end
	local required = item.a or item.access
	if required and required ~= "" and not ply:query(required) then
		denyItemAccess( ply )
		return false
	end
	return true, item
end
local function readValidatedTargets( admin, count, accessName )
	local selectors = {}
	local seen = {}
	for i = 1, count do
		local sid64 = net.ReadString()
		local p = player.GetBySteamID64( sid64 )
		if IsValid( p ) and not seen[p] then
			local id = ULib.getUniqueIDForPlayer( p )
			if id then
				selectors[#selectors + 1] = "$" .. id
				seen[p] = true
			end
		end
	end
	if #selectors == 0 then return {} end
	local parser = ULib.cmds.PlayersArg()
	local targets, err = parser:parseAndValidate( admin, table.concat( selectors, "," ), { cmd = accessName, type = ULib.cmds.PlayersArg } )
	if not targets then
		ULib.tsayError( admin, err or L.T("cmd_cannot_target_any"), true )
		return {}
	end
	return targets
end
function ulx.giveItem( calling_ply, target_plys, classname, quantity, secAmmo )
	local ok, item = checkItemAccess( calling_ply, classname )
	if not ok then return {} end
	local itemType = tonumber( item.t or item.type or 1 ) or 1
	if itemType == 5 or itemType == 6 then
		denyItemAccess( calling_ply )
		return {}
	end
	quantity = math.Clamp( quantity or 0, 0, 9999 )
	secAmmo = math.Clamp( secAmmo or 0, 0, 9999 )
	local affected = {}
	local isWeapon = classname:find( "^weapon_" ) or classname:find( "^gmod_" )
	local isAmmo = classname:find( "^item_ammo_" ) or classname:find( "^item_box_" )
	local isConsumable = ( classname == "weapon_frag" or classname == "weapon_slam" or classname == "weapon_hegrenade" or classname == "weapon_flashbang" or classname == "weapon_smokegrenade" )
	local isItem = classname:find( "^item_" ) and not isAmmo
	local dualAmmo = { ["weapon_smg1"]={"SMG1","SMG1_Grenade"}, ["weapon_ar2"]={"AR2","AR2AltFire"} }
	local consumableAmmo = {
		["weapon_frag"] = "Grenade",
		["weapon_slam"] = "Slam",
	}
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
if SERVER then
	net.Receive( "ulx_items_give", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, L.T("items_no_permission"), true); return end
		local count = net.ReadUInt( 8 )
		local targets = readValidatedTargets( ply, count, "xgui_manageitems" )
		if #targets == 0 then return end
		local classname = net.ReadString()
		local quantity = net.ReadUInt( 16 )
		local secAmmo = net.ReadUInt( 16 )
		local result = ulx.giveItem( ply, targets, classname, quantity, secAmmo )
		if #result > 0 then
			ulx.fancyLogKeyed( ply, "items_give_log", nil, #result, classname, quantity )
		end
	end )
	local function smartGroundSpawn( entClass, owner, quantity, centerHit, ang, vdata, mdl )
		local COLLISION_OPT = 1.30
		local COLLISION_MIN = 0.92
		local GROUND_OFFSET  = 300
		local GROUND_DEPTH   = 600
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
		local bboxW = maxs.x - mins.x
		local bboxD = maxs.y - mins.y
		local entityH = maxs.z - mins.z
		local heightOff = math.max( -mins.z, 2 )
		local yaw = math.rad( ang.y )
		local cosY, sinY = math.cos( yaw ), math.sin( yaw )
		local preMaxLayers = math.max( 1, math.ceil( math.sqrt( quantity ) * 3.2 ) )
		local preMaxDist = math.max( bboxW, bboxD ) * preMaxLayers * 0.7
		local HGRID = 8
		local heightMap = {}
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
					heightMap[iy][ix] = nil
				end
			end
		end
		local hAvgZ = (hSamples > 0) and (hSumZ / hSamples) or centerHit.z
		local hRange = (hSamples > 2) and (hMaxZ - hMinZ) or 0
		local avgFlat = (hSamples > 0) and (hSumFlat / hSamples) or 0.7
		local terrainQ = math.Clamp( (avgFlat - 0.55) / 0.45, 0, 1 )
		local undulationPenalty = math.Clamp( hRange / 200, 0, 0.5 )
		terrainQ = math.max( 0.1, terrainQ - undulationPenalty )
		local minAllowedZ = hAvgZ - 150
		local deepPitOffset = math.max( 0, (hAvgZ - hMinZ) - 150 ) * 0.5
		local function estimateGroundZ( wx, wy )
			local lx = (wx - centerHit.x) * cosY + (wy - centerHit.y) * sinY
			local ly = -(wx - centerHit.x) * sinY + (wy - centerHit.y) * cosY
			local ux = (lx / preMaxDist + 1) * 0.5
			local uy = (ly / preMaxDist + 1) * 0.5
			if ux < 0 or ux > 1 or uy < 0 or uy > 1 then return nil end
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
		local spacingMul = 0.30 + terrainQ * 0.20
		local cellX = math.max( bboxW * spacingMul, 14 )
		local cellY = math.max( bboxD * spacingMul, 14 )
		local maxLayers = math.max( 1, math.ceil( math.sqrt( quantity ) * (3.0 + terrainQ * 0.5) ) )
		local maxSearchDist = math.max( cellX, cellY ) * maxLayers * 1.3
		local STAGGERS = { 0.25, 0.50, 0.75 }
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
		local function bestPlacement( factor, needed, firstPos )
			local best = {}
			for _, off in ipairs( STAGGERS ) do
				local result = tryGridPlace( factor, needed, firstPos, off )
				if #result > #best then best = result end
				if #best >= needed then break end
			end
			return best
		end
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
		local positions = bestPlacement( COLLISION_OPT, quantity - 1, firstPos )
		local quality = "optimal"
		if #positions < quantity - 1 then
			positions = bestPlacement( COLLISION_MIN, quantity - 1, firstPos )
			if #positions >= quantity - 1 then
				quality = "tight"
			else
				quality = "partial"
			end
		end
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
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, L.T("items_no_permission"), true); return end
		local count = net.ReadUInt( 8 )
		local targets = readValidatedTargets( ply, count, "xgui_manageitems" )
		if #targets == 0 then return end
		local classname = net.ReadString()
		local quantity = net.ReadUInt( 16 )
		local vkey = net.ReadString()
		quantity = math.Clamp( quantity, 1, 10 )
		local ok, item = checkItemAccess( ply, classname, vkey )
		if not ok then return end
		local itemType = tonumber( item.t or item.type or 1 ) or 1
		if itemType == 1 then
			denyItemAccess( ply )
			return
		end
		local registeredVKey = item.k or item.vkey or ""
		if registeredVKey ~= "" and vkey == "" then
			denyItemAccess( ply )
			return
		end
		local vdata = nil
		if vkey ~= "" then
			vdata = list.Get( "Vehicles" )[vkey]
			if not vdata then
				denyItemAccess( ply )
				return
			end
		end
		startSpawnBatch( ply )
		local spawned = 0
		local wallMounts = {
			["item_healthcharger"] = true,
			["item_suitcharger"] = true,
		}
		for _, target in ipairs( targets ) do
			local trace = target:GetEyeTrace()
			local isWallMount = wallMounts[ classname ]
			local pos, ang, normal
			if isWallMount then
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
				local samples = 16
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
							local dist = tr.HitPos:Distance( hitPos )
							if dist <= radius * 0.4 then
								local dot = tr.HitNormal:Dot( centerNorm )
								if dot > 0.6 then
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
				centerNorm = centerNorm * 2
				local sumW = 2
				local avg = centerNorm * 2
				for i, n in ipairs( primaryNormals ) do
					avg = avg + n; sumW = sumW + (weights[i] or 1)
				end
				if #primaryNormals > 0 then avg = avg / sumW; avg:Normalize() end
				normal = avg
				local totalRays = 0
				for pi = 1, samples do
					totalRays = totalRays + math.floor( samples * math.sin((pi/samples)*math.pi*0.48) * 3 ) + 6
				end
				local occlusionRate = 1 - (#primaryNormals / math.max(totalRays, 1))
				if occlusionRate > 0.40 then
					ULib.tsayError( ply, "严重遮挡 ("..math.floor(occlusionRate*100).."%), 请更换位置。", true )
					return
				end				pos = hitPos + normal * (0.9 * margin)
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
				local mdl = nil
				if vdata then
					mdl = vdata.Model
				elseif classname == "prop_ragdoll" then
					mdl = "models/player/group01/male_01.mdl"
				end
				local entClass = vdata and vdata.Class or classname
				ang = target:EyeAngles()
				ang.p = 0
				local entsPlaced, nPlaced, quality = smartGroundSpawn( entClass, target, quantity, trace.HitPos, ang, vdata, mdl )
				for _, e in ipairs( entsPlaced ) do
					trackSpawn( ply, e )
					spawned = spawned + 1
				end
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
			ulx.fancyLogKeyed( ply, "log_spawn_item", nil, classname, spawned )
		else
			ULib.tsayError( ply, string.format( ULib.ulx_lang.T("items_spawn_fail"), classname ), true )
		end
	end )
	net.Receive( "ulx_items_inventory", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then ULib.tsayError(ply, L.T("items_no_permission"), true); return end
		local targets = readValidatedTargets( ply, 1, "xgui_manageitems" )
		local target = targets[1]
		if not IsValid( target ) then return end
		local sid64 = target:SteamID64()
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
		hook.Run( "ULXItemsInventoryReceived", sid64, nick, weapons )
	end )
end
if SERVER then
	net.Receive( "ulx_items_spawn_undo", function( len, ply )
		if not ply:query( "xgui_manageitems" ) then return end
		local T = ULib.ulx_lang.T
		local data = plySpawned[ply]
		if not data or not data.batches or #data.batches == 0 then
			ULib.tsay( ply, T("items_spawn_undo_none"), true )
			return
		end
		local lastBatch = table.remove( data.batches )
		if not lastBatch or not lastBatch.entities or #lastBatch.entities == 0 then
			ULib.tsay( ply, T("items_spawn_undo_none"), true )
			return
		end
		local count = 0
		for i = #lastBatch.entities, 1, -1 do
			count = count + forceRemoveEntity( lastBatch.entities[i] )
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
		plySpawned[ply] = nil
		if count > 0 then
			ULib.tsay( ply, string.format( T("items_spawn_clear_ok"), count ), true )
		else
			ULib.tsay( ply, T("items_spawn_clear_none"), true )
		end
	end )
end