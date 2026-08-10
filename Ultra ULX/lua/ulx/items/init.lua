ulx.itemRegistry = {}
ulx.itemOrder    = {}
ulx.ITEM_FILES = { "weapons_hl2.lua", "weapons_css.lua", "weapons_admin.lua", "tools.lua", "ammo.lua", "props.lua", "seats.lua", "vehicles.lua" }
function ulx.registerItems( items, category )
	if not items or #items == 0 then return end
	if not ulx.itemRegistry[ category ] then
		ulx.itemRegistry[ category ] = {}
		table.insert( ulx.itemOrder, category )
	end
	for _, it in ipairs( items ) do
		it.category = category
		it.c = it.class
		it.n = it.name
		it.t = it.type
		it.a = it.access
		it.k = it.vkey
		table.insert( ulx.itemRegistry[ category ], it )
	end
end
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
function ulx.getAllItems()
	return ulx.itemRegistry, ulx.itemOrder
end
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