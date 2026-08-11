ulx.itemRegistry = {}
ulx.itemOrder    = {}
ulx._itemIndex   = {}
local mountCache = {}
local function isGameMounted( gameName )
	if mountCache[gameName] ~= nil then return mountCache[gameName] end
	local ok, games = pcall(engine.GetGames)
	if ok and games and type(games) == "table" then
		for _, g in ipairs(games) do
			local name = type(g) == "table" and (g.name or g.title or g.folder or "") or tostring(g)
			if name:lower() == gameName:lower() then
				mountCache[gameName] = true; return true
			end
		end
	end
	local checks = {
		cstrike="materials/models/weapons/v_models/snip_awp/v_awp.vmt",
		hl2="materials/models/weapons/v_models/smg1/v_smg1.vmt",
		episodic="materials/models/weapons/v_models/annabelle/v_annabelle.vmt",
		ep2="materials/models/weapons/v_models/ar2/v_ar2.vmt",
		hl1="materials/models/weapons/v_models/glock/v_glock.vmt",
		dod="materials/models/weapons/v_models/garand/v_garand.vmt",
		tf="materials/models/weapons/v_models/flamethrower/v_flamethrower.vmt",
		left4dead="materials/models/weapons/v_models/dual_pistols/v_dual_pistols.vmt",
		left4dead2="materials/models/weapons/v_models/magnum/v_magnum_pistol.vmt",
		portal="materials/models/weapons/v_models/portalgun/v_portalgun.vmt",
	}
	local p = checks[gameName:lower()]
	if p and file.Exists(p, "GAME") then mountCache[gameName] = true; return true end
	return false
end
local function isItemAvailable( it )
	if it.mounts then
		for _, m in ipairs(it.mounts) do
			if not isGameMounted(m) then return false end
		end
	end
	if it.model and not file.Exists(it.model, "GAME") then return false end
	return true
end
function ulx.registerItems( items, category, opts )
	if not items or #items == 0 then return end
	opts = opts or {}
	local reg, skip = 0, 0
	local pass = {}
	for _, it in ipairs(items) do
		if opts.mounts and not it.mounts then it.mounts = opts.mounts end
		if not isItemAvailable(it) then skip = skip + 1
		else
			it.category = category; it.c = it.class; it.n = it.name
			it.t = it.type; it.a = it.access; it.k = it.vkey
			pass[#pass + 1] = it
			reg = reg + 1
		end
	end
	if reg > 0 then
		if not ulx.itemRegistry[category] then
			ulx.itemRegistry[category] = {}
			table.insert(ulx.itemOrder, category)
		end
		for _, it in ipairs(pass) do
			table.insert(ulx.itemRegistry[category], it)
			if it.class then ulx._itemIndex[it.class] = it end
		end
		local extra = skip > 0 and (" | 热检测跳过 " .. skip .. " 项(需挂载对应游戏)") or ""
		Msg("[ULX] 道具 [" .. category .. "] 已注册 " .. reg .. " 项" .. extra .. "\n")
	elseif skip > 0 then
		Msg("[ULX] 道具 [" .. category .. "] 无可用项 (" .. skip .. " 项需挂载对应游戏)\n")
	end
end
function ulx.getItemsByCategory( filterPly )
	local result, order = {}, {}
	for _, cat in ipairs(ulx.itemOrder) do
		local items = ulx.itemRegistry[cat]
		if items then
			local v = {}
			for _, it in ipairs(items) do
				if not it.access or it.access == "" or (IsValid(filterPly) and filterPly:query(it.access)) then
					table.insert(v, it)
				end
			end
			if #v > 0 then result[cat] = v; table.insert(order, cat) end
		end
	end
	return result, order
end
function ulx.getAllItems() return ulx.itemRegistry, ulx.itemOrder end
function ulx.getItemAccess( cn ) local it = ulx._itemIndex[cn]; return it and it.access or nil end
function ulx.getItemDef( cn ) return ulx._itemIndex[cn] end
function ulx.getAllAvailableItems( ply )
	local all = {}
	for _, cat in ipairs(ulx.itemOrder) do
		for _, it in ipairs(ulx.itemRegistry[cat] or {}) do
			if not it.access or it.access == "" or (ply and ply:IsValid() and ply:query(it.access)) then
				table.insert(all, it)
			end
		end
	end
	return all
end
function ulx.isGameMounted( gn ) return isGameMounted(gn) end
function ulx.getMountedGames()
	local r = {}
	for _, g in ipairs({"cstrike","hl2","episodic","ep2","hl1","dod","tf","left4dead","left4dead2","portal"}) do
		if isGameMounted(g) then table.insert(r, g) end
	end
	return r
end
ulx.ITEM_FILES = { "weapons_hl2.lua", "weapons_css.lua", "tools.lua", "ammo.lua", "props.lua", "seats.lua", "vehicles.lua", "auto_discover.lua" }
Msg( "[ULX] 道具热检测注册引擎已初始化 (已挂载: " .. table.concat(ulx.getMountedGames(), ", ") .. ")\n" )