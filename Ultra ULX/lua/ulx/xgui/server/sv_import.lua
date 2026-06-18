-- ============================================
-- Ultra ULX - 旧数据导入面板
-- 在 XGUI 设置中添加导入子模块
-- 检测到原版 ULX 数据时自动弹窗提示
-- ============================================

local function BuildImportPanel(container)
    -- 清空容器
    container:ClearControls()

    -- 检查是否已导入
    local isComplete = ULib.fileExists("data/ultra_ulx/.import_complete")
    local isPending = ULib.fileExists("data/ultra_ulx/.import_pending")

    -- 已导入 → 显示完成状态
    if isComplete then
        local importLog = ULib.fileRead("data/ultra_ulx/.import_complete") or ""
        container:TextItem("")
        container:TextItem("数据导入状态：已完成")
        container:TextItem("已导入文件：")
        for _, line in ipairs(importLog:Split("\n")) do
            if line ~= "" then
                container:TextItem("  - " .. line)
            end
        end
        container:TextItem("")
        container:Button("重新导入", function()
            container:ClearControls()
            ShowImportForm(container)
        end)
        return
    end

    -- 未检测到旧数据 → 显示无数据提示
    if not isPending then
        container:TextItem("")
        container:TextItem("未检测到原版 ULX 数据。")
        container:TextItem("如果您已在使用原版 ULX，请确保配置文件位于 data/ulx/ 下。")
        return
    end

    -- 有旧数据待导入 → 显示导入表单
    ShowImportForm(container)
end

local function ShowImportForm(container)
    container:ClearControls()

    container:TextItem("")
    container:TextItem("检测到原版 ULX 配置文件，是否导入？")
    container:TextItem("（导入后旧文件保留，随时可回滚）")
    container:TextItem("")

    -- 可导入的文件列表，默认全选
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
        -- 检查旧文件是否存在
        local exists = ULib.fileExists("data/ulx/" .. file.name)
        if exists then
            local cb = container:Checkbox(file.label .. " (" .. file.name .. ")", file.selected)
            cb.fileName = file.name
            table.insert(checkboxes, cb)
        end
    end

    container:TextItem("")

    -- 全选/取消按钮
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

    -- 导入按钮
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

        -- 调用服务端导入函数
        RunConsoleCommand("_xgui", "importOldData", table.concat(selectedNames, ","))

        container:TextItem("")
        container:TextItemColor("导入请求已发送，请等待服务端响应...", ULib.COLOR_ACCENT)
    end)

    container:TextItem("")
    container:Button("跳过，使用全新配置", function()
        -- 标记为已跳过，不再弹窗
        RunConsoleCommand("_xgui", "skipImport")
        container:ClearControls()
        container:TextItem("已跳过导入，将使用全新配置。")
        container:TextItem("如需重新导入，请在设置面板中点击「重新导入」。")
    end)
end

-- 注册为设置面板子模块
xgui.addSubModule("数据导入", BuildImportPanel, "superadmin", "settings")
