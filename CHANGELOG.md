# Ultra ULX 变更日志

> 基于 Git 提交记录自动生成，每轮修复一个独立章节。

---

## v2.98.52 (2026-08-17)

> 发布里程碑：参考服 BHOP 手感移植完成，发布包已剥离注释并通过游戏内功能验证（128 命令 / 11 分类 / 4 语言 1,614 键 / 启动 0 错误）。

### 本版修复与优化
- **BHOP 参考服手感移植**：全局 7 项 convar 配方（sv_airaccelerate=2000 / sv_maxspeed=10000 / sv_accelerate=5 / sv_friction=4 / sv_stopspeed=75 / sv_gravity=800 / sv_stepsize=18，引用计数管理，任一设为 0 即不接管）；每玩家物理 JumpPower 290 / 走跑 250 / 重力 1 / 阶梯 18 / MaxSpeed 10000（启用应用、关闭/断开恢复）
- **BHOP 坡度补偿重写**：废弃 1.3x 任意倍率，改为落地 TraceHull 探坡 + ClipVelocity 能量守恒投影（垂直分量自然转沿坡水平分量，高速不再突跳）
- **BHOP 反卡**：贴地 >15 tick 未离地自动松一拍重建跳跃边沿（上坡滑动防卡）
- **BHOP 状态同步**：客户端进图立即 + 3s 轮询请求状态（防 net 丢失）
- 修复 `!endmaintenance` oppositeArgs 传参错误（原 `{false}` 为 falsy 导致反向开启维护）
- 修复服务端日志模板字符类漏 `#T/#P` 导致占位符原样输出
- 修复 `ulx return` 别名缺失参数/权限/帮助定义
- 修复桥错误文件路径 `errors.jsonl` → `errors.json`（与 Dev Tools 实际写入一致）
- 清理语言孤儿键（immune/whois/fban 模块已移除），4 语言包对齐至 1,614 键
- 仓库文档与插件彻底分离：所有 `.md` 与 `site/` 仅存仓库在线查阅，不进入发布包

---

## v2.98.51 (2026-08-11)

> 发布里程碑：自 v2.72.0 以来的完整演进，全新发布包已同步至公开仓库 `Ultra-ULX`。

### 本版修复与优化
- 修复 XGUI 设置面板语法错误（`not` 替代 C 风格 `!` 运算符），消除级联报错
- 移除 4 个无发送端的死网络接收器（`ulx_items_ammo` / `ulx_coord_req` / `ulx_bhop_xgui` / `ulx_community_thirdperson`）
- XGUI 界面恢复 v2.72.0 经典布局，还原底部信息栏
- 全模块热路径性能缓存（local 引用优化）
- 4 语言包对齐至 1626 键（zh-cn / en / ru / lzh）

### v2.72.0 → v2.98.50 主要演进
- 统一版本口径（ULX 3.81 / ULib 2.72）
- 修复 hook 双重执行、SQL 转义双重引号、限时禁言/禁聊语义等核心健壮性问题
- 多语言系统重构（`L.T()` 回退链 + 4 语言全量对齐）
- 客户端文件同步（CRC 比对 + 按需下载）
- 热检测道具引擎（`isGameMounted` 双重检测）
- RNG 修正独立包（rngfix）

---

## Round 5 — 文件合并精简 (2026-06-29)

**目标**: 消除碎片化小文件，减少文件数

### 已修改文件 (7)
| 文件 | 变更 |
|------|------|
| `lua/ulx/shared/defines.lua` | +11行: 合并 ulx_defines.lua 全部常量; 修复旧版本号 2.71.0→3.81 |
| `lua/ulx/init.lua` | 移除 `ulx_defines.lua` 和 `cl_commands.lua` 的 include |
| `lua/ulx/cl_init.lua` | 移除 `ulx_defines.lua` 和 `cl_commands.lua` 的 include |
| `lua/ulx/client/ulx_cl_lib.lua` | +6行: 合并 cl_commands.lua 的 `ULib.redirect` 函数 |
| `lua/ulx/items/weapons_hl2.lua` | +4行: 合并 weapons_admin.lua 的2个管理员武器 |
| `lua/ulx/items/init.lua` | ITEM_FILES 列表移除 `weapons_admin.lua` |

### 已删除文件 (3)
| 文件 | 原因 |
|------|------|
| `lua/ulx/shared/ulx_defines.lua` | 合并到 defines.lua |
| `lua/ulx/client/cl_commands.lua` | 合并到 ulx_cl_lib.lua |
| `lua/ulx/items/weapons_admin.lua` | 合并到 weapons_hl2.lua |

---

## Round 4 — XGUI 框架深度精简 (2026-06-29)

**目标**: 移除死代码，DRY 重复逻辑

### 已修改文件 (4)
| 文件 | 行变化 | 变更 |
|------|:--:|------|
| `lua/ulx/xgui/xgui_core.lua` | -40 | 移除空 `if SERVER then end` 死代码; 空 `net.Receive` 死代码; `stripCmdPrefix()` 消除 translateCommand/translateHelp 重复; 语言hook 3×pcall→1×循环; 修复硬编码 v2.69.1 |
| `lua/ulx/xgui/framework/init.lua` | -28 | `buildTabs()` 双 30行循环→`buildSheet()` 单函数 |
| `lua/ulx/xgui/framework/layout.lua` | -15 | `makeCategoryList`/`makeCatList`→统一函数 |
| `lua/ulx/modules/cl/xgui_client.lua` | -30 | `addModule`/`addSettingModule`/`addSubModule`→`registerModule()` |

---

## Round 3 — 命令模块中文化优化 (2026-06-29)

**目标**: 统一英文化日志为中文化，修复全局变量泄漏

### 已修改文件 (6)
| 文件 | 变更 |
|------|------|
| `lua/ulx/modules/sh/fun.lua` | `"slapped #T with #i damage"` → `"扇了 #T #i 点伤害"` |
| `lua/ulx/modules/sh/rcon.lua` | 4处: rcon/luarun/exec 英文日志中文化; `tmp_var` 全局→`local` 防泄漏 |
| `lua/ulx/modules/sh/chat.lua` | 3处: psay/asay/tsay 英文日志中文化; `(ADMINS)`→`(管理员)` |
| `lua/ulx/modules/sh/user.lua` | 4处: adduser/removeuser/adduserid/removeuserid 英文日志中文化 |
| `lua/ulx/modules/sh/util.lua` | 3处: who 英文提示、version 硬编码修复、map 英文日志 |
| `lua/ulx/modules/sh/teleport.lua` | return 回退英文日志中文化 |

---

## Round 2 — 道具模块深度重构 (2026-06-29)

**目标**: 热检测引擎 + 统一注册表，消除硬编码和重复数据

### 已修改文件 (3)
| 文件 | 行变化 | 变更 |
|------|:--:|------|
| `lua/ulx/items/init.lua` | +80/-60 | 全新热检测注册引擎 v2.0: `isGameMounted()` 双重检测(engine.GetGames+资源文件), `registerItems()` 新增 opts.mounts 自动过滤, `ulx._itemIndex` 快速索引, `ulx.getAllAvailableItems()` 统一接口 |
| `lua/ulx/items/weapons_css.lua` | ±2 | 移除 `ulx._enableCSS` 手动开关→`{ mounts={"cstrike"} }` 热检测 |
| `lua/ulx/xgui/server/sv_items.lua` | +30/-80 | 移除 70+行硬编码 `persistent_items`→`buildPersistentItems()` 从注册表自动生成 |

---

## Round 1 — 语法错误 + 安全修复 (2026-06-29)

**目标**: 修复 GLua 语法错误和安全隐患

### 严重修复 (7)
| 文件 | 问题 | 修复 |
|------|------|------|
| `init.lua` | 版本号硬编码 `v2.69.1` | 动态读取 `ulx.version` |
| `autorun/` | `ulx_merged_init.lua` 重复入口 | 已删除 |
| `server/log.lua` | 日期字符串比较跨年 Bug | `dateToNum()` 数字比较 |
| `server/log.lua` | `logEcho=1(匿名)` 与 `=2(完整)` 相同 | 匿名模式隐藏昵称 |
| `shared/ulx4_ext.lua` | UTF-8 中文时间解析失败 | `gmatch` 模式匹配重写 |
| `cl_init.lua` | 文件同步自动删除+强制重连 | 改为仅警告模式 |
| `server/bans.lua` | `ULib.ban` 不传 admin 参数 | `admin or ply` |

### 安全修复 (4)
| 文件 | 修复 |
|------|------|
| `modules/sh/community.lua` | `ulx url` 添加域名白名单 |
| `client/cl_util.lua` | RPC 命名空间白名单(`ulx.*`,`ULib.*`等) |
| `server/ulx_command.lua` | CVar 写入 2 秒去抖 |
| `modules/sh/fun.lua` 等 | `"is frozen!"`→`"已被冻结！"` |

### 语法错误修复 (第二轮)
| 文件 | 问题 | 修复 |
|------|------|------|
| `shared/cami_global.lua` | 6处 `--[[` 吞掉代码(表闭合/函数参数) | 修复所有块注释错误 |
| `server/ucl.lua` | 残留 `]]` 无匹配 `[[` | 删除调试代码 |
| `xgui/framework/init.lua` | 13个问题(硬编码版本/nil守卫等) | 全部修复 |
| `shared/ulx_base.lua` | `help:defaultAccess()` nil 崩溃 | 守卫 |
| `server/end.lua` | `populateMotdData()` nil 崩溃 | 守卫 |
| `modules/sv/uteam.lua` | `uteamEnabled()` nil 崩溃 | 守卫 |

---

## 配置变更

| 文件 | 内容 |
|------|------|
| `.vscode/settings.json` | Lua Language Server 配置: LuaJIT 运行时, 80+ GMod 全局白名单 |
| `.luarc.json` | Lua LS 项目配置: Tab缩进, 忽略 .history/docs |
| `addon.txt` | `up_date` 更新为 2026-06-29 |

---

## 文件统计

| 轮次 | 修改 | 新增 | 删除 | 净变化 |
|:--:|:--:|:--:|:--:|:--:|
| R1 | 15 | 1 | 1 | 0 |
| R2 | 3 | 0 | 0 | 0 |
| R3 | 6 | 0 | 0 | 0 |
| R4 | 4 | 0 | 0 | 0 |
| R5 | 7 | 0 | 3 | -3 |
| **总计** | **35** | **1** | **4** | **-3** |
