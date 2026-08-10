xgui = xgui or {}
function xgui.T(key, ...) return ULib.ulx_lang.T(key, ...) end
function xgui.translateGroup(name)
	if not name or name == "" then return xgui.T("group_none") end
	return xgui.T("group_" .. name)
end
function xgui.translateCategory(catname)
	if not catname or catname == "" then catname = "_Uncategorized" end
	local key = "cat_" .. catname
	local translated = xgui.T(key)
	if translated == key then return catname end
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
	return nil
end
xgui._refreshCallbacks = xgui._refreshCallbacks or {}
function xgui.registerRefresh(name, callback) xgui._refreshCallbacks[name] = callback end
function xgui.unregisterRefresh(name) xgui._refreshCallbacks[name] = nil end
function xgui.refreshAllPanels()
	for name, cb in pairs(xgui._refreshCallbacks) do
		local ok, err = pcall(cb)
		if not ok then ErrorNoHalt("[XGUI] Panel refresh failed [" .. name .. "]: " .. tostring(err) .. "\n") end
	end
end
function xgui.safeSetText(element, text)
	if element and element:IsValid() then element:SetText(text) end
end
function xgui.safeSetLabel(label, text)
	if label and label:IsValid() then
		label:SetText(text)
		label:SizeToContents()
	end
end
function xgui.refreshLabels(labelsTable)
	for _, item in ipairs(labelsTable) do
		if item.panel and item.panel:IsValid() then
			xgui.safeSetText(item.panel, xgui.T(item.key))
		end
	end
end
hook.Add("ULXLanguageChanged", "XGUI_CoreRefresh", function()
	if not xgui.initialized then return end
	pcall(function()
		if xgui.infoLabel then
			xgui.infoLabel:SetText(string.format("\n" .. xgui.T("xgui_infobar"),
				ulx.VERSION_STR or "v2.69.1", ULib.pluginVersionStr("ULX"), ULib.pluginVersionStr("ULib")))
			xgui.infoLabel:SizeToContents()
		end
	end)
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
	pcall(function()
		for _, m in ipairs(xgui.modules.tab) do
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
		for _, m in ipairs(xgui.modules.setting) do
			if m.tabpanel and m.tabpanel:IsValid() then
				m.tabpanel:SetText(m.displayName)
				m.tabpanel:SizeToContents()
			end
		end
		if xgui.base and xgui.base.tabScroller then
			xgui.base.tabScroller:InvalidateLayout(true)
		end
		if xgui.settings_tabs and xgui.settings_tabs.tabScroller then
			xgui.settings_tabs.tabScroller:InvalidateLayout(true)
		end
	end)
	pcall(xgui.refreshAllPanels)
end)
if SERVER then
end
if CLIENT then
    net.Receive("UltraULX_CheckImport", function()
    end)
end