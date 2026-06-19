-- XGUI Core Framework - centralized language/refresh management
xgui = xgui or {}

-- Language helpers
function xgui.T(key, ...) return ULib.ulx_lang.T(key, ...) end
function xgui.translateGroup(name)
	if not name or name == "" then return xgui.T("group_none") end
	return xgui.T("group_" .. name)
end
function xgui.translateCategory(catname)
	if not catname or catname == "" then catname = "_Uncategorized" end
	local key = "cat_" .. catname
	local translated = xgui.T(key)
	if translated == key then return catname end  -- 翻译不存在时回退到原始分类名
	return translated
end
function xgui.translateCommand(fullCmd)
	local cmdName = string.gsub(fullCmd, "^ulx ", "")
	cmdName = string.gsub(cmdName, "^xgui ", "")
	return xgui.T("cmd_" .. cmdName)
end
function xgui.translateHelp(fullCmd)
	local cmdName = string.gsub(fullCmd, "^ulx ", "")
	cmdName = string.gsub(cmdName, "^xgui ", "")
	local translated = xgui.T("help_" .. cmdName)
	if translated ~= "help_" .. cmdName then return translated end
	return nil -- 未找到翻译时返回 nil，调用方回退到 helpStr
end

-- Panel refresh management
xgui._refreshCallbacks = xgui._refreshCallbacks or {}
function xgui.registerRefresh(name, callback) xgui._refreshCallbacks[name] = callback end
function xgui.unregisterRefresh(name) xgui._refreshCallbacks[name] = nil end
function xgui.refreshAllPanels()
	for name, cb in pairs(xgui._refreshCallbacks) do
		local ok, err = pcall(cb)
		if not ok then ErrorNoHalt("[XGUI] Panel refresh failed [" .. name .. "]: " .. tostring(err) .. "\n") end
	end
end

-- Safe UI helpers
function xgui.safeSetText(element, text)
	if element and element:IsValid() then element:SetText(text) end
end
function xgui.safeSetLabel(label, text)
	if label and label:IsValid() then
		label:SetText(text)
		label:SizeToContents()
	end
end

-- Batch label refresh
function xgui.refreshLabels(labelsTable)
	for _, item in ipairs(labelsTable) do
		if item.panel and item.panel:IsValid() then
			xgui.safeSetText(item.panel, xgui.T(item.key))
		end
	end
end

-- Language change hook (lightweight - no tab rebuild)
hook.Add("ULXLanguageChanged", "XGUI_CoreRefresh", function()
	if not xgui.initialized then return end
	pcall(function()
		if xgui.infoLabel then
			xgui.infoLabel:SetText(string.format("\n" .. xgui.T("xgui_infobar"),
				ulx.VERSION_STR or "v2.69.1", ULib.pluginVersionStr("ULX"), ULib.pluginVersionStr("ULib")))
			xgui.infoLabel:SizeToContents()
		end
	end)
	-- 更新模块显示名（不重建标签结构）
	pcall(function()
		for _, m in ipairs(xgui.modules.tab) do
			m.displayName = xgui.T("tab_" .. m.name)
		end
		for _, m in ipairs(xgui.modules.setting) do
			m.displayName = xgui.T("tab_" .. m.name)
		end
		for _, m in ipairs(xgui.modules.submodule) do
			m.displayName = xgui.T("tab_" .. m.name)
		end
	end)
	-- 更新标签页标题文本 + 轻量重排（仅 tab 栏，不重建内容）
	pcall(function()
		-- 主模块标签页
		for _, m in ipairs(xgui.modules.tab) do
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
		-- 设置标签页
		for _, m in ipairs(xgui.modules.setting) do
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
		-- 仅刷新 tab 滚动条布局（不刷新整个 PropertySheet，避免界面闪烁）
		if xgui.base and xgui.base.tabScroller then
			xgui.base.tabScroller:InvalidateLayout(true)
		end
		if xgui.settings_tabs and xgui.settings_tabs.tabScroller then
			xgui.settings_tabs.tabScroller:InvalidateLayout(true)
		end
	end)
	-- 调用所有模块的文本级刷新回调
	pcall(xgui.refreshAllPanels)
end)


-- ============================================
-- Ultra ULX - 数据导入 ConCommand
-- 处理 XGUI 导入对话框的请求和跳过操作
-- ============================================
if SERVER then
end

if CLIENT then
    -- 查询导入状态（连接时检查是否需要弹窗）
    net.Receive("UltraULX_CheckImport", function()
        -- 由服务端在处理 PlayerAuthed 时调用
    end)
end
