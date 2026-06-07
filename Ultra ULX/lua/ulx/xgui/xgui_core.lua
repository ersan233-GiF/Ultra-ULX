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
	return xgui.T("cat_" .. catname)
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
				ULib.pluginVersionStr("ULX"), ULib.pluginVersionStr("ULib")))
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
	-- 更新标签页标题文本 + 重排布局（直接通过 module.tabpanel 引用，最可靠）
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
		-- PropertySheet 布局刷新
		if xgui.base then
			pcall(function()
				if xgui.base.tabScroller then xgui.base.tabScroller:InvalidateLayout(true) end
			end)
			xgui.base:InvalidateLayout(true)
		end
		if xgui.settings_tabs then
			pcall(function()
				if xgui.settings_tabs.tabScroller then xgui.settings_tabs.tabScroller:InvalidateLayout(true) end
			end)
			xgui.settings_tabs:InvalidateLayout(true)
		end
	end)
	pcall(xgui.refreshAllPanels)
end)
