if CLIENT then
local ShowImportForm
local activeContainer
xgui.prepareDataType("importstatus")
local function BuildImportPanel(container)
    activeContainer = container
    container:ClearControls()
    local status = xgui.data.importstatus or {}
    local isComplete = status.complete == true
    local isPending = status.pending == true
    if isComplete then
        container:TextItem("")
        container:TextItem(xgui.T("import_status_done"))
        container:TextItem(xgui.T("import_imported_files"))
        for _, line in ipairs(status.imported or {}) do
            if line ~= "" then
                container:TextItem("  - " .. line)
            end
        end
        container:TextItem("")
        container:Button(xgui.T("import_reimport"), function()
            container:ClearControls()
            ShowImportForm(container)
        end)
        return
    end
    if not isPending then
        container:TextItem("")
        container:TextItem(xgui.T("import_no_data"))
        container:TextItem(xgui.T("import_check_path"))
        return
    end
    ShowImportForm(container)
end
local function ShowImportForm(container)
    container:ClearControls()
    local status = xgui.data.importstatus or {}
    local available = {}
    for _, name in ipairs(status.files or {}) do
        available[name] = true
    end
    container:TextItem("")
    container:TextItem("检测到原版 ULX 配置文件，是否导入？")
    container:TextItem("（导入后旧文件保留，随时可回滚）")
    container:TextItem("")
    local availableFiles = {
        { name = "groups.txt",   label = "用户组权限",    selected = true },
        { name = "users.txt",    label = "用户权限",      selected = true },
        { name = "config.txt",   label = "主配置",        selected = true },
        { name = "adverts.txt",  label = "广播公告",      selected = true },
        { name = "motd.txt",     label = "进入消息",      selected = true },
        { name = "votemaps.txt", label = "投票地图",      selected = true },
        { name = "banreasons.txt", label = "封禁原因",    selected = true },
        { name = "banmessage.txt", label = "封禁提示",    selected = true },
    }
    local checkboxes = {}
    for _, file in ipairs(availableFiles) do
        if available[file.name] then
            local cb = container:Checkbox(file.label .. " (" .. file.name .. ")", file.selected)
            cb.fileName = file.name
            table.insert(checkboxes, cb)
        end
    end
    container:TextItem("")
    local selectAllState = true
    container:Button("全部选择", function()
        selectAllState = true
        for _, cb in ipairs(checkboxes) do
            cb:SetChecked(true)
        end
    end)
    container:Button("全部取消", function()
        selectAllState = false
        for _, cb in ipairs(checkboxes) do
            cb:SetChecked(false)
        end
    end)
    container:TextItem("")
    container:Button("导入选中文件", function()
        local selectedNames = {}
        for _, cb in ipairs(checkboxes) do
            if cb:GetChecked() then
                table.insert(selectedNames, cb.fileName)
            end
        end
        if #selectedNames == 0 then
            container:TextItem("请至少选择一个文件！")
            return
        end
        RunConsoleCommand("_xgui", "importOldData", table.concat(selectedNames, ","))
        container:TextItem("")
        container:TextItemColor("导入请求已发送，请等待服务端响应...", ULib.COLOR_ACCENT)
    end)
    container:TextItem("")
    container:Button("跳过，使用全新配置", function()
        RunConsoleCommand("_xgui", "skipImport")
        container:ClearControls()
        container:TextItem("已跳过导入，将使用全新配置。")
        container:TextItem("如需重新导入，请在设置面板中点击「重新导入」。")
    end)
end
xgui.addSubModule("import", BuildImportPanel, "xgui_importolddata", "settings")
xgui.hookEvent("importstatus", "process", function()
    if IsValid(activeContainer) then
        BuildImportPanel(activeContainer)
    end
end, "importStatusRefresh")
end
if SERVER then
	local import = {}
	local IMPORTABLE = { "groups.txt", "users.txt", "config.txt", "adverts.txt", "motd.txt",
		"votemaps.txt", "banreasons.txt", "banmessage.txt", "downloads.txt", "gimps.txt" }
	local IMPORTABLE_SET = {}
	for _, f in ipairs(IMPORTABLE) do
		IMPORTABLE_SET[f] = true
	end
	local function detectOldULX()
		for _, f in ipairs(IMPORTABLE) do
			if ULib.fileExists("data/ulx/" .. f) then return true end
		end
		return false
	end
	local function getImportStatus()
		local imported = {}
		local complete = ULib.fileExists("data/ultra_ulx/.import_complete")
		if complete then
			local importLog = ULib.fileRead("data/ultra_ulx/.import_complete") or ""
			for _, line in ipairs(string.Explode("\n", importLog)) do
				if line ~= "" then
					table.insert(imported, line)
				end
			end
		end
		local files = {}
		for _, f in ipairs(IMPORTABLE) do
			if ULib.fileExists("data/ulx/" .. f) then
				table.insert(files, f)
			end
		end
		return {
			complete = complete,
			pending = ULib.fileExists("data/ultra_ulx/.import_pending") or (#files > 0 and not complete),
			imported = imported,
			files = files,
		}
	end
	local function doImport(ply, fileList)
		local imported = {}
		ULib.fileCreateDir("data/ultra_ulx")
		for _, f in ipairs(fileList) do
			if IMPORTABLE_SET[f] then
				local src = "data/ulx/" .. f
				local dst = "data/ultra_ulx/" .. f
				if ULib.fileExists(src) then
					local content = ULib.fileRead(src)
					if content then
						ULib.fileWrite(dst, content)
						table.insert(imported, f)
					end
				end
			end
		end
		local log = table.concat(imported, "\n")
		ULib.fileWrite("data/ultra_ulx/.import_complete", log)
		if ULib.fileExists("data/ultra_ulx/.import_pending") then
			ULib.fileDelete("data/ultra_ulx/.import_pending")
		end
		if IsValid(ply) then
			ULib.tsayColor(ply, true, ULib.COLOR_SUCCESS, "[Ultra ULX] 导入完成: " .. #imported .. " 个文件")
		else
			Msg("[Ultra ULX] 导入完成: " .. #imported .. " 个文件\n")
		end
		return imported
	end
	local function canImport(ply)
		if not IsValid(ply) then return true end
		if ULib.ucl.query(ply, "xgui_importolddata") then return true end
		ULib.tsayError(ply, ULib.ulx_lang.T("items_no_permission"), true)
		return false
	end
	function import.init()
		ULib.ucl.registerAccess( "xgui_importolddata", "superadmin", "允许在 XGUI 中导入旧版 ULX 数据。", "XGUI" )
		xgui.addDataType( "importstatus", getImportStatus, "xgui_importolddata", 0, -30 )
		xgui.addCmd("importOldData", function(ply, args)
			if not canImport(ply) then return end
			local fileList = string.Explode(",", args[1] or "")
			if #fileList == 0 then
				ULib.tsayError(ply, ULib.ulx_lang.T("import_select_files"), true)
				return
			end
			doImport(ply, fileList)
			xgui.sendDataTable({}, "importstatus", true)
		end)
		xgui.addCmd("skipImport", function(ply, args)
			if not canImport(ply) then return end
			ULib.fileWrite("data/ultra_ulx/.import_complete", "skipped")
			if ULib.fileExists("data/ultra_ulx/.import_pending") then
				ULib.fileDelete("data/ultra_ulx/.import_pending")
			end
			if IsValid(ply) then
				ULib.tsayColor(ply, true, ULib.COLOR_ACCENT, "[Ultra ULX] 已跳过数据导入")
			else
				Msg("[Ultra ULX] 已跳过数据导入\n")
			end
			xgui.sendDataTable({}, "importstatus", true)
		end)
	end
	xgui.addSVModule( "import", import.init )
	hook.Add("InitPostEntity", "UltraULX_DetectOldData", function()
		if ULib.fileExists("data/ultra_ulx/.import_complete") then return end
		if ULib.fileExists("data/ultra_ulx/.import_pending") then return end
		if detectOldULX() then
			ULib.fileCreateDir("data/ultra_ulx")
			ULib.fileWrite("data/ultra_ulx/.import_pending", os.date("%Y-%m-%d %H:%M:%S"))
			Msg("[Ultra ULX] 检测到原版 ULX 数据 (data/ulx/)，可在 XGUI 设置 → 数据导入 中迁移\n")
		end
	end)
end