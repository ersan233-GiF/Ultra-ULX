local autoRegistered = false
function ulx.autoDiscoverItems()
	if autoRegistered then return end
	autoRegistered = true
	local sweps = weapons.GetList()
	local weaponItems = {}
	for _, swep in ipairs(sweps) do
		if (swep.Spawnable == nil or swep.Spawnable == true)
			and swep.ClassName
			and swep.ClassName:find("^weapon_")
			and not swep.ClassName:find("^weapon_base")
			and not swep.ClassName:find("^weapon_tttbase") then
			local class = swep.ClassName
			local name = swep.PrintName or class
			table.insert(weaponItems, {
				class = class,
				name  = name,
				type  = 4,
				access = "",
				model = swep.WorldModel or "",
			})
		end
	end
	if #weaponItems > 0 then
		ulx.registerItems(weaponItems, "[自动] MOD武器", {mounts = {}})
	end
	local sents = scripted_ents.GetList()
	local sentItems = {}
	for class, sent in pairs(sents) do
		local t = sent.t or sent
		if class and t and t.Spawnable then
			table.insert(sentItems, {
				class = class,
				name  = t.PrintName or class,
				type  = 2,
				access = "",
				model = t.Model or "",
			})
		end
	end
	if #sentItems > 0 then
		ulx.registerItems(sentItems, "[自动] MOD实体", {mounts = {}})
	end
	Msg("[ULX] 道具自动发现: " ..
		#weaponItems .. " SWEPs, " ..
		#sentItems .. " SENTs\n")
end
local function runAutoDiscover()
	local ok, err = pcall(ulx.autoDiscoverItems)
	if not ok then
		Msg("[ULX] 道具自动发现跳过: " .. tostring(err) .. "\n")
	end
end
if CLIENT then
	runAutoDiscover()
elseif SERVER then
	runAutoDiscover()
	hook.Add("InitPostEntity", "ULXAutoDiscoverItems", runAutoDiscover)
end