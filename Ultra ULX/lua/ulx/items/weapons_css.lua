-- CSS 武器 — 显式启用后才注册 (lua_run ulx._enableCSS = true)
-- 确保 CSS Dedicated Server 内容已通过 SteamCMD 下载并正确挂载 VPK
if not ulx._enableCSS then return end

ulx.registerItems({
	{ class = "weapon_hegrenade",   name = "手雷(CS)",   type = 2 },
		{ class = "weapon_flashbang",   name = "闪光弹",     type = 2 },
		{ class = "weapon_smokegrenade",name = "烟雾弹",     type = 2 },
		{ class = "weapon_deagle",      name = "沙漠之鹰",   type = 3 },
		{ class = "weapon_elite",       name = "双持贝雷塔", type = 3 },
		{ class = "weapon_fiveseven",   name = "FN57",        type = 3 },
		{ class = "weapon_glock",       name = "格洛克",      type = 3 },
		{ class = "weapon_usp",         name = "USP消音版",   type = 3 },
		{ class = "weapon_p228",        name = "P228",        type = 3 },
		{ class = "weapon_m3",          name = "M3霰弹枪",    type = 3 },
		{ class = "weapon_mac10",       name = "MAC-10",      type = 3 },
		{ class = "weapon_mp5navy",     name = "MP5海军",     type = 3 },
		{ class = "weapon_p90",         name = "P90",         type = 3 },
		{ class = "weapon_tmp",         name = "TMP",         type = 3 },
		{ class = "weapon_ump45",       name = "UMP45",       type = 3 },
		{ class = "weapon_ak47",        name = "AK-47",       type = 3 },
		{ class = "weapon_aug",         name = "AUG",         type = 3 },
		{ class = "weapon_famas",       name = "FAMAS",       type = 3 },
		{ class = "weapon_galil",       name = "Galil",       type = 3 },
		{ class = "weapon_m4a1",        name = "M4A1消音版",  type = 3 },
		{ class = "weapon_sg552",       name = "SG552",       type = 3 },
		{ class = "weapon_awp",         name = "AWP",         type = 3 },
		{ class = "weapon_g3sg1",       name = "G3SG1",       type = 3 },
		{ class = "weapon_scout",       name = "Scout",       type = 3 },
		{ class = "weapon_sg550",       name = "SG550",       type = 3 },
		{ class = "weapon_m249",        name = "M249",        type = 3 },
	}, "CSS武器")

