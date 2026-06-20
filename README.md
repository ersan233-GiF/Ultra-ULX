# Ultra ULX v2.70.0

[![GitHub release](https://img.shields.io/badge/version-2.70.0-blue)](https://github.com/ersan233-GiF/Ultra-ULX/releases)
[![GitHub stars](https://img.shields.io/github/stars/ersan233-GiF/Ultra-ULX?style=social)](https://github.com/ersan233-GiF/Ultra-ULX)
[![GitHub license](https://img.shields.io/badge/license-MIT-green)](https://github.com/ersan233-GiF/Ultra-ULX/blob/main/LICENSE)
[![ULX](https://img.shields.io/badge/ULX-3.81%20compatible-orange)](https://github.com/TeamUlysses/ulx)
[![GMod](https://img.shields.io/badge/Garry's%20Mod-Addon-ff69b4)](https://gmod.facepunch.com/)

> 基于 [Team Ulysses ULX v3.71](https://github.com/TeamUlysses/ulx) · 完全中文化 · 114+ 新命令 · 4 种语言

**[GitHub 仓库](https://github.com/ersan233-GiF/Ultra-ULX)** · **[下载发布包](https://github.com/ersan233-GiF/Ultra-ULX/releases)** · **[提交 Issue](https://github.com/ersan233-GiF/Ultra-ULX/issues)**

---

## 模块简介

[Ultra ULX ](https://github.com/ersan233-GiF/Ultra-ULX)是 Garry's Mod 服务端管理插件 [ULX](https://github.com/TeamUlysses/ulx) 的增强分支，在保留原版全部功能的基础上，新增 114+ 条管理命令，支持 4 种语言，集成 SQLite 持久化惩罚系统，自动连跳，坐标 HUD 等。

### 核心功能

| 功能 | 说明 |
|:----|:-----|
| **权限管理** | 多级用户组 + 细粒度权限 + SQLite 持久化 + 自动备份 |
| **管理扩展** | 限时禁言/禁聊、分级警告系统（3次→自动禁言，5次→自动封禁）、玩家举报、行动记录、IP封禁持久化、服务器维护模式 |
| **娱乐命令** | 50+ 种娱乐互动，含社区扩展命令 |
| **管理工具** | 封禁/踢出/禁言/传送/换图/清理/重置，覆盖服务器日常运维 |
| **投票系统** | 玩家自主投票换图/踢人/封禁，支持 MapVote/GMVote |
| **XGUI 面板** | 全功能图形管理界面，无需记忆命令即可完成所有操作 |
| **多语言** | 4 种语言，客户端自由切换 |
| **BHOP 连跳** | CS:S 标准自动连跳系统含坡度补偿，SetupMove 保活 |
| **道具生成** | 9 类 70+ 预设物品，智能碰撞检测 |
| **坐标系统** | 屏幕 HUD + 头顶坐标，4 种可见模式 |
| **蹲跳增强** | 可调跳跃倍率 + 蹲行速度 + 自动解锁 |
| **安全共存** | 独立数据目录 + InitPostEntity 覆盖，删除即恢复原版 ULX |

---

## 快速安装

> **优先级：[P0] 安装必读**

```
1. 下载发布包 → 解压 → 将 Ultra ULX 文件夹放入 garrysmod/addons/
2. 重启服务器
3. 控制台显示 // Ultra ULX v2.70.0 Loaded! // 即成功
```

[⬇️ 下载最新发布包](https://github.com/ersan233-GiF/Ultra-ULX/releases)

## 命令使用

> **优先级：[P0] 入门必读**

| 方式 | 示例 | 说明 |
|:----|:-----|:-----|
| 聊天框 `!指令` | `!bring 玩家` | 最常用，游戏中直接输入 |
| 控制台 `ulx_指令` | `ulx bring 玩家` | 管理员使用 |
| `!menu` 或 `!xgui` | 打开图形界面 | 全功能 XGUI 管理面板 |

---

## 首次开服设置

> **优先级：[P0] 开服必读 — 请按顺序操作**

### 第一步：获取你的 SteamID

SteamID 是玩家的唯一标识（如 `STEAM_0:1:12345678`），不会因改名而改变。用 SteamID 设置管理员更可靠。

**获取 SteamID 的方法：**

```
方法一：聊天框输入 !who
       → 输出中可见你自己的 SteamID（如 "STEAM_0:1:55554444"）

方法二：浏览器打开 https://steamid.io/
       输入你的 Steam 个人资料 URL 即可查询

方法三：Steam 客户端 → 好友列表 → 右键自己 → 查看个人资料
       网址末尾的数字就是你的 Steam64 ID（需转换，推荐方法一）
```

> 记下你的 SteamID（格式如 `STEAM_0:1:12345678`），下一步要用到。

### 第二步：将自己设为超级管理员

安装后首次进入服务器时，你是没有权限的。需要通过**服务器控制台**（不是游戏内聊天框）执行：

```
# 服务器控制台 (rcon/后台) 执行:
ulx adduserid <你的SteamID> superadmin

# 例如你的 SteamID 是 STEAM_0:1:55554444:
ulx adduserid STEAM_0:1:55554444 superadmin
```

> **提示**：如果你在本地开服（单人→开始新游戏→沙盒模式），可以直接按 `~` 打开控制台输入上述命令。
> **提示**：如果你是租用服务器，在服务器管理面板的"控制台"或"RCON"中输入。
> **为什么用 SteamID？** 玩家名称可以随意更改，SteamID 是永久绑定的，即使对方改名也不会丢失权限。

设好后，在聊天框输入 `!menu` 即可打开全功能管理面板。

### 第三步：验证权限

```
聊天框输入:
!who               ← 查看自己在列表中的组（同时可看到 SteamID）
!version           ← 查看 Ultra ULX 版本信息
```

若显示 `You do not have access to this command`，说明上一步未生效，请重新执行 `ulx adduserid`，确认 SteamID 格式正确。

### 第四步：常用开服命令

```
# 服务器控制台执行:
ulx map gm_construct           ← 切换到指定地图
ulx ban 玩家名称 60 原因       ← 封禁玩家60分钟
ulx kick 玩家名称              ← 踢出玩家
ulx noclip                     ← 自己飞天
ulx god                        ← 自己无敌
ulx hp 100                     ← 回复血量
ulx cleanup                    ← 清理场景中的所有道具
```

### 用户组管理

> **推荐使用 SteamID 方式**，用户改名后权限不会丢失。

```
# 用 SteamID 设置（推荐，永久绑定）：
ulx adduserid STEAM_0:1:55554444 superadmin    ← 设为超管（最高权限）
ulx adduserid STEAM_0:1:55554444 admin         ← 设为管理员
ulx adduserid STEAM_0:1:55554444 operator      ← 设为协管
ulx removeuserid STEAM_0:1:55554444            ← 移除用户

# 或用玩家名设置（临时用，改名后失效）：
ulx adduser 玩家名 superadmin                  ← 按名称设为超管
ulx removeuser 玩家名                          ← 按名称移除
```

> 提示：`!who` 命令可查看所有在线玩家的名称和 SteamID。

### XGUI 图形管理面板

```
聊天框 !menu （或 !xgui）打开管理面板：
├── 命令       ← 浏览/执行所有 ulx 命令
├── 用户组     ← 可视化管理用户和权限组
├── 封禁记录   ← 查看/解封
├── 道具       ← 生成武器/道具/载具
├── 地图投票   ← 配置投票换图
└── 设置       ← 服务器 MOTD / 语言 / 皮肤
```

---

## 卸载

> **优先级：[P0] 如需卸载**

```
1. 删除 addons/Ultra ULX/ 整个文件夹
2. （可选）删除 data/ultra_ulx/ 配置
3. 重启服务器 — 原版 ULX 自动恢复，零残留
```

> **零侵入设计**：所有数据存储在 `data/ultra_ulx/` 独立目录，不修改原版 ULX。

---

## 与原版 ULX 共存

| 场景 | 行为 |
|:----|:-----|
| 原版 ULX 已安装 | Ultra ULX 自动覆盖同名命令 |
| 仅安装 Ultra ULX | 自带完整 ULib，无需额外安装 |
| 删除 Ultra ULX | 原版 ULX 完整保留 |

---

## 多语言切换

> **优先级：[P1] 可选配置**

客户端控制台执行:

| 代码 | 语言 |
|:----|:-----|
| `ulx_lang zh-cn` | 简体中文 |
| `ulx_lang en` | English |
| `ulx_lang ru` | Русский |
| `ulx_lang lzh` | 文言文 |

或 `!menu` → 设置 → 客户端 → 语言 中切换。

---

## 常见问题 (FAQ)

> **优先级：[P1] 遇到问题时查阅**

| 问题 | 解决 |
|:----|:-----|
| `Unknown command: ulx` | 检查目录是否多了一层嵌套：`addons/Ultra ULX/lua/` 必须直接存在 |
| `Groups file was not formatted correctly` | 删除 `data/ulib/groups.txt`，重启自动重建 |
| 命令无反应 | 确认自己有对应权限（SuperAdmin/Admin） |
| 语言切换后乱码 | 输入 `ulx_lang zh-cn` 切回中文 |
| 怎么给自己权限？ | 服务器控制台执行 `ulx adduserid <你的SteamID> superadmin` |
| 忘记了自己的 SteamID？ | 聊天框输入 `!who` 即可查看自己和在线玩家 |
| BHOP 开了没效果？ | 检查地图是否启用了其他物理插件，部分模式（如 DarkRP）自带移动限制 |
| 道具生成不出来？ | 确认 `data/ultra_ulx/sbox_limits.txt` 中的限制是否过小，或 `!menu`→道具面板中查看已勾选的类别 |

---

## 总览

| 指标 | 数值 |
|:---:|:---:|
| 总行数 (Lua, 含注释) | **~31,400 行** |
| 发布包行数 (去注释) | **~25,650 行** |
| Lua 源码大小 | **~1,120 KB** |
| 发布包大小 | **~1,023 KB** |
| 文件数 (Lua) | **93 个** |
| 语言包 | **4 种** (简体中文 1,180行 / English 1,222行 / Русский 1,246行 / 文言文 1,147行) |
| 命令总数 | **~150 条** (原版 ~45 条 + 105+ 新增) |
| 模块数 | **23 个** (sh 14 + cl 5 + sv 4) |
| 道具分类 | **9 类** |
| ULib 版本 | 2.72 |
| Ultra ULX 版本 | **v2.70.0** |
| ULX 兼容版本 | 3.81 |

---

## 完整文件树

> **优先级：[P2] 开发者/调试用**

```
addons/Ultra ULX/                          [~1.07 MB / ~26,100 行]
│
├── addon.json ........................... 412 B    插件元数据 JSON（GMod 识别入口）
│
└── lua/
    ├── autorun/
    │   ├── init_ulx.lua ............. 132 B  [  6行]  ⭐ 入口：include("ulx/init.lua") + CSLuaFile 批量发送
    │   └── rngfix/                               RNG 修正（独立包，不依赖 ULX）
    │       ├── ent_trigger.lua ....... 493 B  [ 39行]  触发器实体定义
    │       └── sh_rngfix.lua ......... 585 B  [ 19行]  修正实体生成位置 & NAN 伤害
    │
    └── ulx/
        ├── init.lua ................. 6.6 KB  [188行]  ⭐⭐ 服务端主入口（阶段加载91文件+语言ConVar+共存覆盖）
        ├── cl_init.lua .............. 4.5 KB  [136行]  ⭐⭐ 客户端主入口（版本CRC同步+UCL认证+模块安全加载）
        │
        ├── shared/ .............................. 170.2 KB [4,753行]
        │   ├── defines.lua ......... 11.2 KB  [377行]  ⭐⭐⭐ 核心常量+版本号+7色主题+22个net字串
        │   ├── commands.lua ........ 38.5 KB  [1,222行] ⭐⭐⭐ 命令系统（注册/解析/执行/回显全流程）
        │   ├── misc.lua ............ 19.1 KB  [750行]  ⭐⭐  字符串工具/模式继承/命令分类
        │   ├── util.lua ............ 12.7 KB  [454行]  ⭐⭐  文件IO/队列调度/序列化
        │   ├── cami_global.lua ..... 12.6 KB  [447行]  ⭐⭐  CAMI 权限接口全局注册
        │   ├── player.lua .......... 7.5 KB   [311行]  ⭐⭐  玩家选择器/目标匹配
        │   ├── sh_ucl.lua .......... 6.5 KB   [226行]  ⭐⭐  共享 UCL 权限查询
        │   ├── messages.lua ........ 5.5 KB   [232行]  ⭐   彩色消息/tsay分块
        │   ├── ulx_base.lua ........ 4.8 KB   [150行]  ⭐   ULX 命令基类（setOpposite/帮助生成）
        │   ├── plugin.lua .......... 4.6 KB   [148行]  ⭐   插件注册/更新机制
        │   ├── tables.lua .......... 3.5 KB   [123行]  ⭐   只读表/矩阵工具
        │   ├── language.lua ........ 2.9 KB   [109行]  ⭐   多语言系统（load/switch/缓存）
        │   ├── hook.lua ............ 2.2 KB   [ 94行]  自定义5级优先级钩子系统
        │   ├── cami_ulib.lua ....... 4.1 KB   [ 98行]  CAMI-ULib 桥接
        │   └── ulx_defines.lua ..... 521 B    [ 12行]  ULX 兼容常量
        │
        ├── server/ ............................... 133.5 KB [3,597行]
        │   ├── ucl.lua ............ 37.1 KB  [1,307行] ⭐⭐⭐ 权限系统（SQLite+txt双存储+30份自动备份+恢复）
        │   ├── data.lua ........... 14.9 KB  [467行]  ⭐⭐⭐ 默认配置文件生成（中文化模板+独立目录）
        │   ├── log.lua ............ 17.2 KB  [448行]  ⭐⭐  日志系统（彩色回显+文件记录+过滤）
        │   ├── player.lua ......... 6.4 KB   [253行]  ⭐⭐  服务端玩家管理（查找/查询）
        │   ├── bans.lua ........... 6.5 KB   [249行]  ⭐⭐  封禁系统（封/解/查/SQLite持久化）
        │   ├── srv_util.lua ....... 5.8 KB   [183行]  ⭐   复制 Cvar 系统（同步ConVar到客户端）
        │   ├── entity_ext.lua ..... 4.7 KB   [167行]  ⭐   实体扩展方法
        │   ├── concommand.lua ..... 2.5 KB   [ 90行]  控制台命令注册（ulx_前缀）
        │   ├── phys.lua ........... 3.1 KB   [ 98行]  物理工具函数
        │   ├── ulx_command.lua .... 3.6 KB   [ 94行]  Cvar 访问器
        │   ├── ulx_lib.lua ........ 2.3 KB   [ 76行]  独占/不死/无碰撞标记
        │   ├── player_ext.lua ..... 1.7 KB   [ 62行]  玩家扩展限制
        │   └── end.lua ............ 3.1 KB   [103行]  配置加载引擎（doCfg三层叠加）
        │
        ├── client/ ................................ 9.3 KB [268行]
        │   ├── cl_util.lua ........ 3.7 KB   [104行]  客户端工具函数
        │   ├── ulx_cl_lib.lua ..... 2.7 KB   [103行]  客户端数据填充（net接收）
        │   ├── draw.lua ........... 1.3 KB   [ 48行]  HUD绘制（cloak/blind/coord辅助）
        │   └── cl_commands.lua .... 397 B    [ 13行]  客户端命令注册
        │
        ├── modules/ .............................. 294.9 KB [7,251行]
        │   ├── sh/ (14) .......................... 184.3 KB [4,447行]
        │   │   ├── community.lua .. 28.0 KB  [785行]  ⭐⭐⭐ 30+社区扩展命令（火箭/颜色/Halo/拖尾/ESP/banip/机器人/伪装/警告/静默）
        │   │   ├── fun.lua ........ 30.9 KB  [918行]  ⭐⭐⭐ 25种娱乐命令（slap/whip/slay/点燃/冰冻/神/HP/护甲/隐形/致盲/监禁/布娃娃/剥光/maul）
        │   │   ├── util.lua ....... 15.5 KB  [445行]  ⭐⭐⭐ 管理工具（kick/ban/unban/banid/noclip/spectate/map/who/version/重置默认）
        │   │   ├── vote.lua ....... 13.4 KB  [382行]  ⭐⭐  投票系统（发起/停止/votemap2/votekick/voteban/否决/mapvote/gmvote）
        │   │   ├── teleport.lua ... 9.9 KB   [314行]  ⭐⭐  传送命令（bring螺旋网格/goto碰撞检测/send/tp/tpto/return）
        │   │   ├── user.lua ....... 9.4 KB   [307行]  ⭐⭐  用户管理（adduser/removeuser/groupallow/renamegroup等16条）
        │   │   ├── chat.lua ....... 8.5 KB   [273行]  ⭐   聊天命令（psay/asay/tsay/csay/thetime/gimp/mute/gag+广告系统）
        │   │   ├── bhop.lua ....... 8.2 KB   [216行]  ⭐   CS:S自动连跳（跑260/跳300/重力0.6/SetupMove保活）
        │   │   ├── extras.lua ..... 7.2 KB   [209行]  ⭐   辅助命令（cleanup/respawn/setmodel/setteam/giveweapon/scale/gravity）
        │   │   ├── coord.lua ...... 6.0 KB   [153行]  ⭐   坐标系统（coordhud屏幕上方+coord头顶4模式/0.5s刷新）
        │   │   ├── crouchjump.lua . 5.8 KB   [145行]  ⭐   蹲跳增强（倍率1~10x/蹲姿解锁/蹲走加速）
        │   │   ├── menus.lua ...... 5.1 KB   [133行]  ⭐   MOTD菜单（json+txt+gamemode三路扫描/无缓存）
        │   │   ├── rcon.lua ....... 3.7 KB   [101行]  ⭐   远程控制（rcon/luarun/exec/cexec/ent）
        │   │   └── userhelp.lua ... 2.6 KB   [ 66行]  用户帮助面板
        │   │
        │   ├── cl/ (5) ............................ 82.8 KB [2,137行]
        │   │   ├── xlib.lua ............. 32.2 KB [1,137行] ⭐⭐⭐ XGUI 控件库（窗口/按钮/滑块/列表/标签/面板）
        │   │   ├── xgui_helpers.lua ..... 14.5 KB [392行]  ⭐⭐  XGUI 辅助函数（35px原版滑块/动态表单）
        │   │   ├── xgui_client.lua ...... 13.3 KB [360行]  ⭐⭐  XGUI 客户端核心（菜单面板/标签页系统）
        │   │   ├── motdmenu.lua ......... 9.5 KB  [240行]  ⭐   MOTD HTML生成器（模板渲染/变量替换）
        │   │   └── uteam.lua ............ 222 B   [  8行]  UTeam 客户端桩
        │   │
        │   └── sv/ (4) ............................. 27.8 KB [667行]
        │       ├── xgui_server.lua ....... 11.0 KB [306行]  ⭐⭐  XGUI 服务端通信（net消息路由/数据分发）
        │       ├── votemap.lua ........... 6.2 KB  [155行]  ⭐   投票换图系统
        │       ├── uteam.lua ............. 5.0 KB  [135行]  UTeam 队伍管理
        │       └── slots.lua ............. 2.9 KB  [ 71行]  预留槽位（VIP/管理员强制加入）
        │
        ├── items/ .................................. 9.6 KB [175行]
        │   ├── init.lua .............. 2.1 KB   [ 65行]  ⭐⭐ 道具注册表 API（注册/查询/生成）
        │   ├── weapons_css.lua ...... 2.1 KB   [ 31行]  12种 CS:S 武器
        │   ├── weapons_hl2.lua ...... 979 B    [ 16行]  14种 HL2 武器
        │   ├── ammo.lua ............. 1.1 KB   [ 16行]  7种弹药
        │   ├── props.lua ............ 1.1 KB   [ 16行]  8种预设道具
        │   ├── seats.lua ............ 1.1 KB   [ 10行]  3种座椅
        │   ├── vehicles.lua ......... 512 B    [  8行]  2种载具
        │   ├── tools.lua ............ 408 B    [  8行]  3种工具枪
        │   └── weapons_admin.lua .... 294 B    [  5行]  2种管理员武器
        │
        ├── language/ .............................. 196.7 KB [4,795行]
        │   ├── zh-cn.lua ......... 51.4 KB [1,180行]   简体中文（完整翻译 + 文化适配）
        │   ├── en.lua ............. 50.2 KB [1,222行]  English（完整原版 + 新增命令翻译）
        │   ├── ru.lua ............. 65.5 KB [1,246行]  Русский（完整俄语翻译）
        │   └── lzh.lua ............ 43.0 KB [1,147行]   文言文（古典风格翻译）
        │
        └── xgui/ .................................. 256.0 KB [5,634行]
            ├── root (7)
            │   ├── commands.lua ..... 13.7 KB [411行]   命令浏览/执行面板
            │   ├── groups.lua ....... 21.5 KB [568行]   用户组管理面板
            │   ├── bans.lua ......... 16.0 KB [359行]   封禁记录面板
            │   ├── items.lua ........ 16.3 KB [431行]  ⭐  道具生成面板（分类+搜索+快捷）
            │   ├── maps.lua ......... 7.4 KB  [191行]   地图投票配置面板
            │   ├── xgui_core.lua .... 3.8 KB  [112行]  ⭐  XGUI 核心（concommand注册/信息栏）
            │   └── settings.lua ..... 1.0 KB  [ 32行]   设置入口
            ├── framework/
            │   ├── init.lua ......... 7.0 KB  [190行]  ⭐⭐  XGUI 框架初始化（窗口系统/主题/皮肤）
            │   └── layout.lua ....... 3.3 KB  [101行]   统一布局引擎（多标签页管理）
            ├── gamemodes/
            │   └── sandbox.lua ...... 5.1 KB  [ 72行]   沙盒模式限制配置
            ├── server/ (6)
            │   ├── sv_items.lua ..... 34.4 KB [830行]  ⭐⭐⭐ 智能道具生成（碰撞检测/挂墙/撤回/自适应）
            │   ├── sv_settings.lua .. 11.7 KB [330行]  ⭐⭐  服务器设置（MOTD模板/封禁消息/系统配置）
            │   ├── sv_groups.lua .... 11.7 KB [321行]  ⭐⭐  用户组服务端（权限继承/保存/同步）
            │   ├── sv_bans.lua ...... 9.3 KB  [254行]  ⭐   封禁服务端（查询/解封/同步）
            │   ├── sv_sandbox.lua ... 1.7 KB  [ 47行]   沙盒限制服务端
            │   └── sv_maps.lua ...... 660 B   [ 18行]   地图列表服务端
            └── settings/
                ├── server.lua ....... 59.8 KB [1,142行] ⭐⭐⭐ 服务器设置面板（MOTD编辑/游戏模式/地图/沙盒限制）
                └── client.lua ....... 14.8 KB [265行]  ⭐   客户端设置面板（语言/皮肤/界面选项）
```

---

## 与原版 ULX 对比

### 新增文件

| 文件 | 行数 | 大小 | 分类 | 功能 |
|:---:|:---:|:---:|:---:|:---|
| `community.lua` | 785 | 28.0 KB | 模块 | 30+ 命令 (rocket/color/halo/ESP/banip/bot...) |
| `bhop.lua` | 216 | 8.2 KB | 模块 | CS:S 自动连跳 (跑260/跳300/重力0.6) |
| `crouchjump.lua` | 145 | 5.8 KB | 模块 | 蹲跳增强 (倍率+解锁+蹲走加速) |
| `coord.lua` | 153 | 6.0 KB | 模块 | 坐标 HUD + 头顶坐标 (4 模式) |
| `items/*` (9 文件) | 175 | 9.6 KB | 道具 | 道具注册表 API + 8 分类 |
| `client.lua` (settings) | 265 | 14.8 KB | XGUI | 客户端设置 (语言/皮肤) |
| `layout.lua` | 101 | 3.3 KB | XGUI | 统一布局引擎 |
| `zh-cn.lua` | **1,180** | 51.4 KB | 语言 | 简体中文 100% |
| `lzh.lua` | **1,147** | 43.0 KB | 语言 | 文言文 100% |
| `ru.lua` | **1,246** | 65.5 KB | 语言 | Русский 100% |
| `language.lua` | 109 | 2.9 KB | 共享 | 多语言框架 |
| `rngfix/` (2 文件) | 58 | 1.1 KB | RNG | 斜坡修正独立包 |

### 显著增强

| 文件 | 原版 | Ultra ULX | 增强内容 |
|:---:|:---:|:---:|:---|
| `sv_items.lua` | ~200行 | **830行** | 智能生成+碰撞自适应+挂墙+撤回 |
| `ucl.lua` | ~1,300行 | **1,307行** | 备份30+恢复+DB管理+二次检测 |
| `data.lua` | ~300行 | **467行** | 中文化模板+详细注释+独立数据目录 |
| `fun.lua` | ~800行 | **918行** | unigniteall+playsound+sslay |
| `en.lua` | ~900行 | **1,222行** | +322 翻译键 + 文言文新增键同步 |
| `defines.lua` | ~400行 | **377行** | 7色主题(加深40%)+版号格式 |
| `menus.lua` | ~100行 | **133行** | json+txt+gamemode三路扫描,无缓存 |

### 删除/合并

| 操作 | 原指令 | 替代方案 |
|:---:|:---|:---|
| 合并 | `!bhopcss` `!bhopcancel` | → `!bhop` + `!unbhop` |
| 合并 | `!kickbots` | → `!bot` setOpposite |
| 合并 | `!undisguise` | → `!disguise` setOpposite |
| 合并 | `!undeafen` | → `!deafen` setOpposite |
| 合并 | `!unsilence` | → `!silence` setOpposite |
| 删除 | RNG-Fix 大段逻辑 | 精简为独立 `rngfix` 包（58行） |
| 删除 | moveCmds 48px 滑块 | 改用原版 `x_getcontrol` 35px |
| 删除 | makeStyledButton | 改用标准 `xlib.makebutton` |
| 删除 | MOTD 缓存 | `populateMotdData` 每次实时 |

---

## 架构

### 6 层加载顺序

> **优先级：[P2] 开发者/调试用**

```
Layer 0: autorun/init_ulx.lua (6行)
         → SERVER: include("ulx/init.lua")
         → CLIENT: include("ulx/cl_init.lua")
Layer 1: ULib 共享库 (15 文件)
         → defines → misc → util → hook → tables → player → messages
         → commands → sh_ucl → plugin → cami_global → cami_ulib → language
Layer 2: ULX 服务端 (13 文件)
         → player → bans → concommand → srv_util → ucl → phys
         → player_ext → entity_ext → data → ulx_defines → ulx_lib
         → ulx_command → ulx_base → log → end
Layer 3: 模块 (23 文件)
         → sh: 14 模块 | cl: 5 模块 | sv: 4 模块
Layer 4: 道具注册 (9 文件)
         → init + 8 分类注册表
Layer 5: XGUI (18 文件)
         → root 7 + framework 2 + gamemodes 1 + server 6 + settings 2
Layer 6: 语言 (4 文件)
         → zh-cn | en | ru | lzh
```

### 数据流

```
聊天 !cmd → sayCmds → _u → routedCommandCallback → getCommandTableAndArgv
    → cmds.execute → TranslateCommand 验证 → 回调 → fancyLogAdmin 回显

权限: ULib.ucl.query(ply, access) → allow/deny 用户表 → 组继承链 → CAMI

配置: doCfg() → 全局 → 按模式(叠加) → 按地图(叠加) → ULib.execStringULib(安全模式)

认证: PlayerAuthed → ucl.probe() → 匹配 users → SetUserGroup → UCLAuthed → 同步
```

---

## 命令参考

> **优先级：[P1] 日常管理**

### 完整索引（按分类）

| 分类 | 命令 |
|:---:|:---|
| **娱乐** | `!slap !whip !slay !sslay !ignite !playsound !freeze !god !hp !armor !cloak !blind !jail !jailtp !ragdoll !maul !strip !launch !rocket !explode !color !halo !trail !esp` |
| **工具** | `!cleardecals !profile !redirect !stopsound !timescale !url !aliases !removeragdolls !cleanup !respawn !setmodel !setteam !giveweapon !scale !gravity !coordhud !coord` |
| **聊天** | `!p !psay @ !asay @@ !tsay @@@ !csay !thetime !gimp !mute !gag !rsay !deafen !silence` |
| **移动** | `!jumppower !runspeed !walkspeed !speed !stepsize !bhop !crouchjump` |
| **传送** | `!bring !goto !send !tp !teleport !tpto !return` |
| **投票** | `!vote !stopvote !votemap !votemap2 !votekick !voteban !veto !mapvote !gmvote` |
| **管理** | `!kick !ban !unban !banid !noclip !spectate !map !who !version !resettodefaults !banip !bot !warn !disguise` |
| **远程** | `ulx rcon !rcon ulx luarun ulx exec ulx cexec !cexec ulx ent` |
| **菜单** | `!motd ulx motd` |

> 每个 `!command` 均有对应的 `ulx command` 控制台版本，以及 `!uncommand` 反向命令 (setOpposite)。

### 常用命令速查（按使用频率）

| 频率 | 命令 | 说明 |
|:---:|:----|:-----|
| ⭐⭐⭐ | `!bring 玩家` | 把目标传送到自己面前 |
| ⭐⭐⭐ | `!goto 玩家` | 自己传送到目标身边 |
| ⭐⭐⭐ | `!slap 玩家` | 拍打玩家（造成伤害）|
| ⭐⭐⭐ | `!kick 玩家` | 踢出玩家 |
| ⭐⭐⭐ | `!ban 玩家 分钟` | 封禁玩家 |
| ⭐⭐⭐ | `!freeze 玩家` | 冰冻玩家（再输一次解冻）|
| ⭐⭐⭐ | `!god` | 自己无敌模式 |
| ⭐⭐⭐ | `!noclip` | 自己飞天穿墙 |
| ⭐⭐ | `!hp 数值` | 设置血量 |
| ⭐⭐ | `!slay 玩家` | 处决玩家 |
| ⭐⭐ | `!jail 玩家 秒数` | 关禁闭 |
| ⭐⭐ | `!mute 玩家` | 禁言（再输一次解除）|
| ⭐⭐ | `!gag 玩家` | 禁聊（再输一次解除）|
| ⭐⭐ | `!cleanup` | 清理场景道具 |
| ⭐⭐ | `!map 地图名` | 切换地图 |
| ⭐⭐ | `!who` | 查看玩家列表和权限 |
| ⭐⭐ | `!version` | 查看版本信息 |
| ⭐ | `!cloak 玩家` | 隐形 |
| ⭐ | `!blind 玩家` | 致盲 |
| ⭐ | `!ignite 玩家` | 点燃 |
| ⭐ | `!ragdoll 玩家` | 变成布娃娃 |
| ⭐ | `!respawn 玩家` | 复活玩家 |
| ⭐ | `!scale 玩家 倍数` | 改变大小 |
| ⭐ | `!gravity 倍数` | 改变重力 |
| ⭐ | `!warn 玩家 原因` | 警告玩家 |

---

## 模块手册

### 共享模块 (14 个)

| 模块 | 行数 | 命令 | 核心功能 |
|:---:|:---:|:---:|:---|
| community | 785 | 30+ | rocket/color/halo/trail/ESP/deafen/silence/banip/bot/warn/disguise |
| fun | 918 | 25 | slap/whip/slay/ignite/freeze/god/cloak/blind/jail/ragdoll/maul |
| util | 445 | 9 | kick/ban/unban/noclip/spectate/map/who/version |
| vote | 382 | 9 | vote/votemap2/votekick/voteban/stopvote/veto |
| teleport | 314 | 6 | bring(螺旋网格)/goto(碰撞检测)/send/tpto/teleport/return |
| user | 307 | 16 | adduser/removeuser/groupallow/renamegroup |
| chat | 273 | 9 | psay/asay/tsay/csay/thetime/gimp/mute/gag+广告 |
| extras | 209 | 6 | cleanup/respawn/scale/gravity+防落地抖动 |
| bhop | 216 | 1 | CS:S自动连跳(跑260/跳300/重力0.6) |
| coord | 153 | 2 | coordhud 屏幕上方 + coord 头顶(4模式) |
| crouchjump | 145 | 1 | 倍率(1~10x)+蹲姿解锁+蹲走加速 |
| menus | 133 | 1 | MOTD(三路扫描,无缓存) |
| rcon | 101 | 5 | rcon/luarun/exec/cexec/ent |
| userhelp | 66 | 1 | 用户管理帮助 |

### BHOP 参数 (CS:S 标准)

| 参数 | 值 | 说明 |
|:---:|:---:|:---|
| sv_airaccelerate | 1000 | 空中加速度 |
| sv_enablebunnyhopping | 1 | 引擎连跳 |
| sv_staminamax | 0 | 关体力 |
| sv_maxvelocity | 3,500 | 速限 |
| sv_accelerate | 10 | 地面加速 |
| sv_friction | 4 | 摩擦 |
| sv_stopspeed | 75 | 停止速度 |
| 跑速/走速 | 260/260 | 统一 |
| 跳跃力 | 300 | CS:S 标准 |
| 重力 | 0.6 | 更低=更高跳 |
| 步幅 | 18 | 标准 |

> 开 `!bhop` 保存原始物理并覆盖；关 `!unbhop` 恢复。SetupMove 每帧保活。

### 蹲跳参数

| 参数 | 默认 | 范围 |
|:---:|:---:|:---:|
| multiplier | 2.0 | 1.0~10.0 |
| crouchspeed | 1.5 | 1.0~5.0 |
| unlock | true | 蹲姿跳跃解锁 |

### 坐标系统

**coordhud** — 屏幕正上方 X Y Z，半透明深底+青色大字
**coord** — 目标头顶名字+坐标，0.5s 刷新，4 模式:

| 模式 | 可见范围 |
|:---:|:---|
| 1 | 仅目标自己 |
| 2 | 管理员+ |
| 3 | 全服公开 |
| 4 | 指定玩家 (额外选择器) |

---

## 配置系统

> **优先级：[P1] 服务器配置**

```
data/ultra_ulx/                        ← Ultra ULX 独立目录（不干扰原版）
├── config.txt       ← 主配置（通用设置）
├── groups.txt       ← 用户组（权限继承链）
├── users.txt        ← 用户列表（备份，主存储 SQLite）
├── adverts.txt      ← 广播公告（定时循环显示）
├── motd.txt         ← MOTD 模板（{{变量}}系统）
├── votemaps.txt     ← 投票地图列表
├── banreasons.txt   ← 封禁预设原因
├── banmessage.txt   ← 封禁消息模板（含变量）
├── sbox_limits.txt  ← 沙盒限制（含 Wiremod 额外限制）
├── xgui_settings.txt← XGUI 界面设置
├── language.txt     ← 语言缓存
├── gamemodes/<m>/   ← 按游戏模式配置（叠加）
└── maps/<m>/        ← 按地图配置（叠加）
```

**配置优先级**：`全局 → 按模式 → 按地图`（三层叠加）

**备份机制**：`data/ulib_backups/users_YYYYMMDD_HHMMSS.txt`（保留最近 30 个备份）

---

## 颜色主题

```
ULib.COLOR_ACCENT    = Color( 60, 160, 240 )  主色调（原版 151,211,255→加深40%）
ULib.COLOR_SUCCESS   = Color( 40, 200,  80 )  成功（绿色）
ULib.COLOR_WARN      = Color(220, 140,   0 )  警告（橙色）
ULib.COLOR_ERROR     = Color(220,  80,  30 )  错误（红色）
ULib.COLOR_INFO      = Color(  0, 170, 220 )  信息（青色）
ULib.COLOR_MUTED     = Color(160, 160, 170 )  弱化（灰色）
ULib.COLOR_HIGHLIGHT = Color(255, 180,   0 )  高亮（金色）
```

---

## 关键机制

> **优先级：[P2] 开发者/调试用**

| 机制 | 实现 | 重要性 |
|:---|:---|:---:|
| **共存** | InitPostEntity 重注册覆盖，数据目录独立，删除即恢复 | ⭐⭐⭐ |
| **同步** | CRC 比对 → 删本地 .lua → retry 重连 | ⭐⭐⭐ |
| **零泄露** | BHOP cvar 首个启用设，全关恢复，ShutDown 兜底，非沙盒跳过 | ⭐⭐ |
| **无缓存** | MOTD populateMotdData 每次实时，addon.json+gamemode 双路 | ⭐⭐ |
| **安全加载** | 硬编码模块清单，pcall 包裹，不跨 addon 扫描 | ⭐⭐⭐ |
| **多语言** | L.load 临时表加载 + 失败保留旧数据，客户端按需下载 | ⭐⭐ |
| **备份** | UCL 自动备份30轮 + 数据恢复 fallback | ⭐⭐ |

---

## 道具 API

> **优先级：[P2] 开发者/扩展用**

可通过 `items/init.lua` 中的注册表 API 扩展新的道具分类：

```lua
-- 注册一个新道具分类
ulx.item.Register("my_category", {
    name = "我的分类",
    items = {
        { class = "prop_physics", name = "示例道具" },
    }
})
```

已有分类：weapons_hl2（14件）、weapons_css（12件）、weapons_admin（2件）、tools（3件）、ammo（7种）、props（8件）、seats（3件）、vehicles（2件）。

---

**[⬆ 返回顶部](#ultra-ulx-v2691)**

---

## 更新日志

### v2.70.0 (2026-06-20)

- **性能优化**: coord.lua HUDPaint 钩子改为动态添加/移除，关闭后零开销
- **硬编码迁移**: teleport.lua 全部错误提示和日志改用 `L.T()` 多语言系统
- **新增语言键**: `tele_tp_help`、`tele_send_help`、`tele_tpto_help` 同步至 4 种语言
- **移除冗余 net 消息**: community.lua 中的 `ulx_community_deafen/silence` net 消息已移除（NWBool 已自动同步）
- **修复定时器负延迟**: sv_bans.lua 中已过期封禁立即执行解封，不再创建空定时器
- **GLuaLS 兼容**: 添加 `---@diagnostic disable` 标记，消除 VS Code 中大量误报错误
- **修复运算符优先级**: sv_bans.lua `\255` 拼接括号修正
- **修复 `mousecode` 拼写错误**: xlib.lua 中 `mousecode` → `mcode`

*Ultra ULX — 基于 [ULX](https://github.com/TeamUlysses/ulx) by Team Ulysses · [GitHub 仓库](https://github.com/ersan233-GiF/Ultra-ULX) · [提交 Issue](https://github.com/ersan233-GiF/Ultra-ULX/issues)*
