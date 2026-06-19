-- 道具注册表系统 — Ultra ULX
-- 所有模组/插件通过 ulx.registerItems() 注册道具，无需修改核心代码
-- 由 Stickly Man! 原版 XGUI 扩展而来

-- 每次脚本重载时重建注册表 (换图不残留旧数据)
ulx.itemRegistry = {}
ulx.itemOrder    = {}

-- 道具内容文件清单 (共享，避免 server/client 重复定义)
ulx.ITEM_FILES = { "weapons_hl2.lua", "weapons_css.lua", "weapons_admin.lua", "tools.lua", "ammo.lua", "props.lua", "seats.lua", "vehicles.lua" }

-- 注册一批道具到指定分类
-- items: 数组，每项 { class, name, type, [access], [model], [vkey] }
-- type: 1=永久无弹药(无生成) 2=消耗品 3=武器含弹药 4=永久无弹药(有生成) 5=纯实体 6=挂墙实体(仅生成1个)
function ulx.registerItems( items, category )
	if not items or #items == 0 then return end
	if not ulx.itemRegistry[ category ] then
		ulx.itemRegistry[ category ] = {}
		table.insert( ulx.itemOrder, category )
	end
	for _, it in ipairs( items ) do
		it.category = category
		-- 短字段别名 (兼容 XGUI 旧代码)
		it.c = it.class
		it.n = it.name
		it.t = it.type
		it.a = it.access
		it.k = it.vkey
		table.insert( ulx.itemRegistry[ category ], it )
	end
end

-- 按分类获取道具（可选权限过滤）
function ulx.getItemsByCategory( filterPly )
	local result = {}
	local order = {}
	for _, cat in ipairs( ulx.itemOrder ) do
		local items = ulx.itemRegistry[ cat ]
		if items then
			local visible = {}
			for _, it in ipairs( items ) do
				if not it.access or it.access == "" or ( filterPly and filterPly:query( it.access ) ) then
					table.insert( visible, it )
				end
			end
			if #visible > 0 then
				result[ cat ] = visible
				table.insert( order, cat )
			end
		end
	end
	return result, order
end

-- 获取全量注册表（无过滤）
function ulx.getAllItems()
	return ulx.itemRegistry, ulx.itemOrder
end

-- 检查某个道具是否需要特殊权限
function ulx.getItemAccess( classname )
	for _, items in pairs( ulx.itemRegistry ) do
		for _, it in ipairs( items ) do
			if it.class == classname then
				return it.access
			end
		end
	end
	return nil
end

Msg( "[ULX] 道具注册表系统已初始化\n" )
