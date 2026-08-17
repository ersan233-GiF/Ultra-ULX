# Ultra ULX — 开发心得与经验

> 基于 Team Ulysses ULX v3.81 的深度增强分支 · v2.98.51

> **本仓库为发布仓库**（`Ultra ULX/` 为已剥离注释的发布包）。代码开发、文档与构建工具链在 **[ultra-ulx-source](https://github.com/ersan233-GiF/ultra-ulx-source)** 进行。

## 项目定位
在保留原版 ULX 全部功能基础上，完全中文化 + 114+ 新命令 + 4 语言 + SQLite 持久化惩罚 + BHOP/蹲跳 + 坐标 HUD + 智能道具。**与服务器上的原版 ULX 共存、删除即恢复**（零侵入设计）。

## 架构要点（开发必读）
- **6 层加载顺序**：autorun → ULib 共享库 → ULX 服务端 → 模块 → 道具 → XGUI → 语言（见 README"架构"章节）
- **自定义 hook 系统**（`shared/hook.lua`）：5 级优先级（HOOK_MONITOR_HIGH=-2 … HOOK_MONITOR_LOW=2），替换全局 `hook.Call`，但**保留原生回退**处理实体钩子/游戏模式函数。
- **硬编码模块清单**：`init.lua` 里 `sh_modules/sv_modules` 显式列出，避免 `file.Find` 跨 addon 误加载英文模块。
- **独立数据目录**：所有配置存 `data/ultra_ulx/`，不污染原版 ULib 数据。
- **共存机制**：`InitPostEntity` 后重注册命令（`UltraULX_ReloadModules`），覆盖原版同名命令。
- **客户端文件同步**：CRC 校验 + 单独下发，版本不一致时客户端下载最新。

## 开发规范
### 新增一条命令
1. 在对应模块（`modules/sh/*.lua`）定义 `function ulx.xxx(calling_ply, ...)`
2. `local cmd = ulx.command(CATEGORY, "ulx xxx", ulx.xxx, "!xxx")` + `addParam` + `defaultAccess` + `help`
3. 如需反向命令，`cmd:setOpposite("ulx unxxx", {_, _, true}, "!unxxx")` —— **注意 opposite 参数索引从 1 开始含 CallingPlayerArg，且只传 truthy 值**（falsy 如 false/0 不会生效，这是踩过的大坑）
4. **同步 4 种语言**：`ulx/language/{zh-cn,en,ru,lzh}.lua` 都要加对应键，否则其他语言显示原始键名

### 模块命名
- `sh_` = 共享（服务端+客户端） / `cl_` = 客户端 / `sv_` = 服务端
- 模块放 `modules/sh|cl|sv/`，并加入 `init.lua` 的硬编码清单 + `AddCSLuaFile` 列表

## 踩过的大坑（v2.72.0 已修复）
1. **hook 双重执行（P0）**：曾在 `hook.Call` 回退原生后又把历史钩子导入 ULib 表 → 所有早于本插件注册的钩子执行两次 + `PlayerAuthSpawn` 迁移失效。修复：**不再导入历史钩子**，历史钩子由原生系统执行一次。
2. **SQL 转义双重引号（P1）**：`sql.SQLStr(s)` 默认已带引号，再包一层 `'...'` 变成 `''...''` → 限时禁言/警告/举报/封禁**全部静默写入失败**。修复：`"'" .. sql.SQLStr(s, true) .. "'"`。
3. **opposite 参数 falsy 失效**：`setOpposite(..., {false})` / `{_,_,0}` 中 falsy 值不会覆盖参数 → `!endmaintenance` 实际开启维护、`!unwhip` 反而重新开扇。修复：用独立 `BoolArg` + 传 `true`。
4. **限时/常规语义颠倒**：`!tmute`（禁言）与 `!mute`、`!tgag`（禁聊）与 `!gag` 语义相反且共享变量冲突。修复：统一为 `mute=禁文字、gag=禁语音`。
5. **重复定义**：community.lua 与 admin_ext.lua 都定义 `ulx.warn`，按加载顺序覆盖、行为不一。修复：删 community 版，保留数据库持久化版。
6. **PowerShell 中文路径（发布侧）**：`strip_comments.ps1` 含中文路径"发布包"，PowerShell 5.1 按 GBK 误读 → 改用 Python `strip_comments.py`（UTF-8 安全）。

## 发布流程（换机后可复用）
1. 在源码仓库 `ultra-ulx-source` 改 `defines.lua` 版本号（`ulx.VERSION` / `VERSION_STR`）+ README 更新日志
2. 开发版 lua → 发布包（`scripts/strip_comments.py` 去注释）
3. 将发布包（`Ultra ULX/` 文件夹 + addon.json）推送至本仓库
4. 打 tag `v2.98.51` → GitHub Actions 自动打包 zip + 创建 Release

## 下一步规划
- [ ] 继续完善 XGUI 面板（道具/地图投票/设置）
- [ ] 更多社区命令（投稿/签到等）
- [ ] 数据备份工具（UCL SQLite → 导出）
- [ ] 更完善的 i18n 测试脚本（检查 4 语言键完整性）

## 关联仓库
- `ultra-ulx-source` — **开发源码仓库**（带注释 + 文档 + 构建工具链）
- `Ultra-ULX`（本仓库）— 发布仓库（剥离注释的 `Ultra ULX/` 发布包）
