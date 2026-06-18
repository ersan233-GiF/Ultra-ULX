-- XGUI 统一布局引擎 — 所有模块用一致的布局模式，不再各自硬编码坐标
-- 模块开发者只需关心内容，布局由引擎处理

xgui.layout = {}

-- 标准模块容器: 左侧 150px 分类栏 + 右侧 450px 内容区 + 底部 20px 信息栏
-- 返回: { left, right, bottom, container } 方便模块自由扩展
function xgui.layout.moduleStandard( parent )
	local mask = xlib.makepanel{ x=0, y=0, w=600, h=400, parent=parent }

	-- 左侧分类面板 (可折叠)
	local left = xlib.makepanel{ x=5, y=5, w=150, h=390, parent=mask }

	-- 右侧内容区
	local right = xlib.makepanel{ x=160, y=5, w=435, h=390, parent=mask }

	return {
		container = mask,
		left = left,
		right = right,
		-- 快捷方法: 在左侧创建分类列表
		makeCategoryList = function( categories, onSelect )
			local list = xlib.makelistlayout{ x=0, y=0, w=148, h=385, parent=left, padding=1, spacing=1 }
			if categories then
				for _, cat in ipairs( categories ) do
					local btn = xlib.makebutton{ label=cat.name, parent=list }
					btn.DoClick = function()
						if onSelect then onSelect( cat, btn ) end
					end
					if cat.expanded then
						btn:SetTextColor( Color( 100, 255, 100 ) )
					end
				end
			end
			return list
		end,
	}
end

-- 左侧分类 + 中间列表 + 右侧参数 (items/commands 模式)
function xgui.layout.moduleSplit3( parent )
	local mask = xlib.makepanel{ x=0, y=0, w=600, h=400, parent=parent }

	local left = xlib.makepanel{ x=5, y=5, w=150, h=390, parent=mask }
	local mid  = xlib.makepanel{ x=160, y=5, w=270, h=390, parent=mask }
	local right = xlib.makepanel{ x=435, y=5, w=160, h=390, parent=mask }

	return {
		container = mask,
		left = left,
		mid = mid,
		right = right,
		makeCatList = function( cats, onSelect )
			local list = xlib.makelistlayout{ x=0, y=0, w=148, h=385, parent=left, padding=1, spacing=1 }
			for _, cat in ipairs( cats ) do
				local btn = xlib.makebutton{ label=cat.name, parent=list }
				if cat.onClick then btn.DoClick = cat.onClick end
			end
			return list
		end,
	}
end

-- 全宽内容区 + 底部控制 (maps/settings 模式)
function xgui.layout.moduleFullWidth( parent )
	local mask = xlib.makepanel{ x=0, y=0, w=600, h=400, parent=parent }
	local content = xlib.makepanel{ x=5, y=5, w=590, h=360, parent=mask }
	local bottom = xlib.makepanel{ x=5, y=370, w=590, h=25, parent=mask }
	return {
		container = mask,
		content = content,
		bottom = bottom,
	}
end

-- 双栏布局: 左 250px 列表 + 右 350px 详情 (groups 模式)
function xgui.layout.moduleDual( parent )
	local mask = xlib.makepanel{ x=0, y=0, w=600, h=400, parent=parent }
	local left = xlib.makepanel{ x=5, y=5, w=240, h=390, parent=mask }
	local right = xlib.makepanel{ x=250, y=5, w=345, h=390, parent=mask }
	return {
		container = mask,
		left = left,
		right = right,
	}
end

-- 为面板添加统一的关闭按钮 (右上角)
function xgui.layout.addCloseButton( panel )
	if not panel.xbutton then
		panel.xbutton = xlib.makebutton{ x=555, y=-5, w=32, h=24, btype="close", parent=panel }
		panel.xbutton.DoClick = function() xgui.hide() end
	end
end

-- 统一的信息标签 (用于提示/状态)
function xgui.layout.makeInfoLabel( parent, text, x, y, w )
	return xlib.makelabel{ x=x or 5, y=y or 5, w=w or 590, label=text or "", parent=parent, textcolor=Color(160,170,185) }
end

Msg( "[XGUI] 布局引擎已加载\n" )
