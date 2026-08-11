xgui = xgui or {}
local function stripCmdPrefix(fullCmd)
	return (fullCmd:gsub("^ulx ", ""):gsub("^xgui ", ""))
end
function xgui.T(key, ...) return ULib.ulx_lang.T(key, ...) end
function xgui.translateGroup(name)
	if not name or name == "" then return xgui.T("group_none") end
	return xgui.T("group_" .. name)
end
function xgui.translateCategory(catname)
	if not catname or catname == "" then catname = "_Uncategorized" end
	local key = "cat_" .. catname
	local t = xgui.T(key)
	if t ~= key then return t end
	local lower = catname:lower()
	if lower ~= catname then
		t = xgui.T("cat_" .. lower)
		if t ~= "cat_" .. lower then return t end
	end
	local nospaces = catname:gsub("%s+", ""):lower()
	if nospaces ~= lower then
		t = xgui.T("cat_" .. nospaces)
		if t ~= "cat_" .. nospaces then return t end
	end
	return catname
end
function xgui.translateCommand(fullCmd)
	return xgui.T("cmd_" .. stripCmdPrefix(fullCmd))
end
function xgui.translateHelp(fullCmd)
	local t = xgui.T("help_" .. stripCmdPrefix(fullCmd))
	return t ~= "help_" .. stripCmdPrefix(fullCmd) and t or nil
end
function xgui.safeSetText(element, text)
	if element and element:IsValid() then element:SetText(text) end
end
function xgui.safeSetLabel(label, text)
	if label and label:IsValid() then
		label:SetText(text); label:SizeToContents()
	end
end
function xgui.refreshLabels(labelsTable)
	for _, item in ipairs(labelsTable) do
		xgui.safeSetText(item.panel, xgui.T(item.key))
	end
end
xgui._refreshCallbacks = xgui._refreshCallbacks or {}
function xgui.registerRefresh(name, callback) xgui._refreshCallbacks[name] = callback end
function xgui.unregisterRefresh(name) xgui._refreshCallbacks[name] = nil end
function xgui.refreshAllPanels()
	for name, cb in pairs(xgui._refreshCallbacks) do
		local ok, err = pcall(cb)
		if not ok then ErrorNoHalt("[XGUI] 面板刷新失败 [" .. name .. "]: " .. tostring(err) .. "\n") end
	end
end
hook.Add("ULXLanguageChanged", "XGUI_CoreRefresh", function()
	if not xgui.initialized then return end
	pcall(function()
		if xgui.infoLabel then
			xgui.infoLabel:SetText(string.format("\n" .. xgui.T("xgui_infobar"),
				ulx.VERSION_STR or "v2.98.51", ULib.pluginVersionStr("ULX"), ULib.pluginVersionStr("ULib")))
			xgui.infoLabel:SizeToContents()
		end
	end)
	pcall(function()
		for _, m in ipairs(xgui.modules.tab) do
			m.displayName = xgui.T("tab_" .. m.name)
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
		for _, m in ipairs(xgui.modules.setting) do
			m.displayName = xgui.T("tab_" .. m.name)
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
		for _, m in ipairs(xgui.modules.submodule) do
			m.displayName = xgui.T("tab_" .. m.name)
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
	end)
	pcall(function()
		if xgui.base and xgui.base.tabScroller then
			xgui.base.tabScroller:InvalidateLayout(true)
		end
		if xgui.settings_tabs and xgui.settings_tabs.tabScroller then
			xgui.settings_tabs.tabScroller:InvalidateLayout(true)
		end
	end)
	pcall(xgui.refreshAllPanels)
end)