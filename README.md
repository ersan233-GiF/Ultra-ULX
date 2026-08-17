<p align="center">
  <a href="https://github.com/ersan233-GiF/Ultra-ULX/releases/latest"><img src="https://img.shields.io/github/v/release/ersan233-GiF/Ultra-ULX?label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC&color=blue" alt="最新版本"></a>
  <a href="https://github.com/ersan233-GiF/Ultra-ULX/releases"><img src="https://img.shields.io/github/downloads/ersan233-GiF/Ultra-ULX/total?label=%E6%80%BB%E4%B8%8B%E8%BD%BD&color=success" alt="总下载量"></a>
  <a href="https://github.com/ersan233-GiF/Ultra-ULX"><img src="https://img.shields.io/github/stars/ersan233-GiF/Ultra-ULX?style=social&label=Stars" alt="Stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-CC_BY--NC--SA_3.0-green" alt="许可"></a>
  <a href="https://github.com/TeamUlysses/ulx"><img src="https://img.shields.io/badge/ULX-3.81%20compatible-orange" alt="ULX"></a>
  <a href="https://github.com/TeamUlysses/ulib"><img src="https://img.shields.io/badge/ULib-2.72%20merged-blueviolet" alt="ULib"></a>
  <a href="https://gmod.facepunch.com/"><img src="https://img.shields.io/badge/Garry%27s%20Mod-Addon-ff69b4" alt="Garry's Mod"></a>
  <a href="#%E5%A4%9A%E8%AF%AD%E8%A8%80%E5%88%87%E6%8D%A2"><img src="https://img.shields.io/badge/%E8%AF%AD%E8%A8%80-4%20%E7%A7%8D-4FC08D" alt="语言"></a>
  <a href="#%E5%91%BD%E4%BB%A4%E5%8F%82%E8%80%83"><img src="https://img.shields.io/badge/%E5%91%BD%E4%BB%A4-150%2B-success" alt="命令"></a>
</p>

<h1 align="center">Ultra ULX</h1>

<p align="center">🌐 <strong>简体中文</strong> · <a href="docs/README.en.md">English</a> · <a href="docs/README.ru.md">Русский</a></p>

<p align="center"><em>基于 <a href="https://github.com/TeamUlysses/ulx">Team Ulysses ULX v3.81</a> + <a href="https://github.com/TeamUlysses/ulib">ULib v2.72</a> 的增强分支 · 完全中文化 · 150+ 命令 · 4 种语言 · SQLite 持久化 · 零侵入共存</em></p>

<p align="center">
  <strong><a href="https://github.com/ersan233-GiF/Ultra-ULX/releases/latest/download/Ultra-ULX-latest.zip">⬇️ 下载最新发布包</a></strong> ·
  <a href="https://ersan233-gif.github.io/Ultra-ULX/">🌐 官方网站</a> ·
  <a href="https://github.com/ersan233-GiF/Ultra-ULX/issues">提交 Issue</a> ·
  <a href="docs/CHANGELOG.md">查看变更日志</a> ·
  <a href="https://github.com/ersan233-GiF/ultra-ulx-source">开发源码仓库</a>
</p>

---

<h2 align="center">目录</h2>

<details open>
<summary>🚀 快速开始</summary>

- [模块简介](#模块简介)
- [快速安装](#快速安装)
- [命令使用](#命令使用)
- [首次开服设置](#首次开服设置)
- [卸载](#卸载)

</details>
<details>
<summary>🧰 日常使用与管理</summary>

- [多语言切换](#多语言切换)
- [与原版 ULX 共存](#与原版-ulx-共存)
- [常见问题 (FAQ)](#常见问题-faq)
- [命令参考](#命令参考)
- [模块手册](#模块手册)
- [配置系统](#配置系统)

</details>
<details>
<summary>📚 项目资料</summary>

- [项目总览](#项目总览)
- [完整文件树](#完整文件树)
- [与原版 ULX 对比](#与原版-ulx-对比)
- [仓库文档索引](#仓库文档索引)

</details>
<details>
<summary>📦 发布与参与</summary>

- [发布说明](#发布说明)
- [开发与贡献](#开发与贡献)
- [安全](#安全)
- [许可证](#许可证)
- [致谢](#致谢)
- [更新日志](#更新日志)

</details>

---

## 模块简介

[Ultra ULX](https://github.com/ersan233-GiF/Ultra-ULX) 是 Garry's Mod 服务端管理插件 [ULX](https://github.com/TeamUlysses/ulx) 的增强分支，在保留原版全部功能的基础上，新增 **150+ 条管理命令**，支持 **4 种语言**，集成 SQLite 持久化惩罚系统、自动连跳、坐标 HUD 等。

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
| **BHOP 连跳** | 参考服手感自动连跳：JumpPower 290 + sv_airaccelerate 2000 配方 + 能量守恒坡度补偿 + groundTicks 反卡 |
| **道具生成** | 9 类 70+ 预设物品，智能碰撞检测 |
| **坐标系统** | 屏幕 HUD + 头顶坐标，4 种可见模式 |
| **蹲跳增强** | 可调跳跃倍率 + 蹲行速度 + 自动解锁 |
| **内置 ULib** | ULib 2.72 已整体并入，`ulib/` 目录保留为兼容垫片，无需单独安装 |
| **安全共存** | 独立数据目录 + InitPostEntity 覆盖，删除即恢复原版 ULX |

---

## 快速安装


```
1. 下载发布包 → 解压 → 将 Ultra ULX 文件夹放入 garrysmod/addons/
2. 重启服务器
3. 控制台显示 Ultra ULX v2.98.52 启动完成信息即成功
```

[⬇️ 下载最新发布包](https://github.com/ersan233-GiF/Ultra-ULX/releases/latest/download/Ultra-ULX-latest.zip)

> **下载包即完整插件**：放入 `addons/` 重启即用，无需额外安装任何组件。

## 命令使用


| 方式 | 示例 | 说明 |
|:----|:-----|:-----|
| 聊天框 `!指令` | `!bring 玩家` | 最常用，游戏中直接输入 |
| 控制台 `ulx_指令` | `ulx bring 玩家` | 管理员使用 |
| `!menu` 或 `!xgui` | 打开图形界面 | 全功能 XGUI 管理面板 |

---

## 首次开服设置


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
| 仅安装 Ultra ULX | 内置完整 ULib 2.72（已并入），无需额外安装 |
| 删除 Ultra ULX | 原版 ULX 完整保留 |

---

## 多语言切换


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

> 以下数据取自 **v2.98.52 发布包实况**：

| 指标 | 数值 |
|:---:|:---:|
| 发布包 Lua 文件数 | **123 个** |
| 发布包 Lua 总行数 | **~27,000 行** |
| 发布包大小 (lua) | **~1,067 KB** |
| 语言包 | **4 种**（各 1,616 行） |
| 运行时命令数 | **128 条**（11 分类，含别名/反向 ~150 条） |
| 模块数 | **25 个**（sh 16 + cl 5 + sv 4） |
| 道具分类 | **9 类** |
| ULib 版本 | 2.72（已并入 Ultra ULX） |
| Ultra ULX 版本 | **v2.98.52** |
| ULX 兼容版本 | 3.81 |

---

## 完整文件树

> 以下为 v2.98.52 发布包实际行数

```
addons/Ultra ULX/                          [~1,067 KB / 123 文件]
│
├── addon.json ........................... 插件元数据 JSON（GMod 识别入口）
│
└── lua/
    ├── autorun/
    │   ├── init_ulx.lua .............  5行  ⭐ Ultra 主入口
    │   ├── ulib_init.lua ............  6行  ULib 路径兼容入口
    │   └── sh_rngfix.lua ............ 18行  RNG 修正（独立包，不依赖 ULX）
    │
    ├── ulib/ ................................ ULib 兼容垫片（真实实现已并入 ulx/）
    │   └── (24 个 1~6 行重定向垫片 + modules/what_is_this.txt 说明)
    │
    └── ulx/
        ├── init.lua ................. 81行  ⭐⭐ 服务端主入口（阶段加载+语言ConVar+共存覆盖）
        ├── cl_init.lua .............. 64行  ⭐⭐ 客户端主入口（版本CRC同步+UCL认证+模块安全加载）
        │
        ├── shared/ .............................. 2,900行
        │   ├── commands.lua ........ 804行  ⭐⭐⭐ 命令系统（注册/解析/执行/回显全流程）
        │   ├── misc.lua ............ 404行  ⭐⭐  字符串工具/模式继承/命令分类
        │   ├── util.lua ............ 249行  ⭐⭐  文件IO/队列调度/序列化
        │   ├── player.lua .......... 232行  ⭐⭐  玩家选择器/目标匹配
        │   ├── language.lua ........ 158行  ⭐   多语言系统（load/switch/缓存）
        │   ├── messages.lua ........ 154行  ⭐   彩色消息/tsay分块
        │   ├── ulx_base.lua ........ 142行  ⭐   ULX 命令基类（setOpposite/帮助生成）
        │   ├── cami_global.lua ..... 126行  ⭐⭐  CAMI 权限接口全局注册
        │   ├── ulx4_ext.lua ........ 117行       ULX4 兼容扩展
        │   ├── sh_ucl.lua .......... 111行  ⭐⭐  共享 UCL 权限查询
        │   ├── plugin.lua ..........  96行  ⭐   插件注册/更新机制
        │   ├── hook.lua ............  85行       自定义5级优先级钩子系统
        │   ├── tables.lua ..........  79行  ⭐   只读表/矩阵工具
        │   ├── defines.lua .........  72行  ⭐⭐⭐ 核心常量+版本号+7色主题+22个net字串
        │   └── cami_ulib.lua .......  71行       CAMI-ULib 桥接
        │
        ├── server/ ............................... 3,187行
        │   ├── ucl.lua ............ 1029行  ⭐⭐⭐ 权限系统（SQLite+txt双存储+30份自动备份+恢复）
        │   ├── log.lua ............  556行  ⭐⭐  日志系统（彩色回显+文件记录+过滤）
        │   ├── data.lua ...........  507行  ⭐⭐⭐ 默认配置文件生成（中文化模板+独立目录）
        │   ├── player.lua .........  194行  ⭐⭐  服务端玩家管理（查找/查询）
        │   ├── bans.lua ...........  189行  ⭐⭐  封禁系统（封/解/查/SQLite持久化）
        │   ├── entity_ext.lua .....  150行  ⭐   实体扩展方法
        │   ├── srv_util.lua .......  128行  ⭐   复制 Cvar 系统（同步ConVar到客户端）
        │   ├── end.lua ............  106行       配置加载引擎（doCfg三层叠加）
        │   ├── ulx_command.lua ....   87行       Cvar 访问器
        │   ├── ulx_lib.lua ........   73行       独占/不死/无碰撞标记
        │   ├── player_ext.lua .....   61行       玩家扩展限制
        │   ├── phys.lua ...........   56行       物理工具函数
        │   └── concommand.lua .....   51行       控制台命令注册（ulx_前缀）
        │
        ├── client/ ................................ 257行
        │   ├── cl_util.lua ........  117行       客户端工具函数
        │   ├── ulx_cl_lib.lua .....  107行       客户端数据填充（net接收）
        │   └── draw.lua ...........   33行       HUD绘制（cloak/blind/coord辅助）
        │
        ├── modules/ .............................. 7,904行
        │   ├── sh/ (16) .......................... 4,630行
        │   │   ├── fun.lua ........ 1044行  ⭐⭐⭐ 25种娱乐命令（slap/whip/slay/点燃/冰冻/神/HP/护甲/隐形/致盲/监禁/布娃娃/剥光/maul）
        │   │   ├── community.lua ..  758行  ⭐⭐⭐ 30+社区扩展命令（火箭/颜色/Halo/拖尾/ESP/banip/机器人/伪装/警告/静默）
        │   │   ├── util.lua .......  446行  ⭐⭐⭐ 管理工具（kick/ban/unban/banid/noclip/spectate/map/who/version/重置默认）
        │   │   ├── vote.lua .......  397行  ⭐⭐  投票系统（发起/停止/votemap2/votekick/voteban/否决/mapvote/gmvote）
        │   │   ├── bhop.lua .......  344行  ⭐⭐  参考服手感连跳（JumpPower290/aa2000/能量守恒坡补/groundTicks反卡）
        │   │   ├── teleport.lua ...  327行  ⭐⭐  传送命令（bring螺旋网格/goto碰撞检测/send/tp/tpto/return）
        │   │   ├── user.lua .......  313行  ⭐⭐  用户管理（adduser/removeuser/groupallow/renamegroup等16条）
        │   │   ├── chat.lua .......  293行  ⭐   聊天命令（psay/asay/tsay/csay/thetime/gimp/mute/gag+广告系统）
        │   │   ├── admin_ext.lua ..  234行  ⭐   管理扩展（限时禁言/警告分级/维护模式/endmaintenance）
        │   │   ├── extras.lua .....  198行  ⭐   辅助命令（cleanup/respawn/setmodel/setteam/giveweapon/scale/gravity）
        │   │   ├── coord.lua ......  168行  ⭐   坐标系统（coordhud屏幕上方+coord头顶4模式/0.5s刷新）
        │   │   ├── crouchjump.lua .  157行  ⭐   蹲跳增强（倍率1~10x/蹲姿解锁/蹲走加速）
        │   │   ├── dev_debug.lua ..  154行       系统诊断（版本/语言检查/错误列表）
        │   │   ├── menus.lua ......  135行  ⭐   MOTD菜单（json+txt+gamemode三路扫描/无缓存）
        │   │   ├── rcon.lua .......  104行  ⭐   远程控制（rcon/luarun/exec/cexec/ent）
        │   │   └── userhelp.lua ...   65行       用户帮助面板
        │   │
        │   ├── cl/ (5) ............................ 2,138行
        │   │   ├── xlib.lua ............. 1181行  ⭐⭐⭐ XGUI 控件库（窗口/按钮/滑块/列表/标签/面板）
        │   │   ├── xgui_helpers.lua .....  381行  ⭐⭐  XGUI 辅助函数（35px原版滑块/动态表单）
        │   │   ├── xgui_client.lua ......  325行  ⭐⭐  XGUI 客户端核心（菜单面板/标签页系统）
        │   │   ├── motdmenu.lua .........  243行  ⭐   MOTD HTML生成器（模板渲染/变量替换）
        │   │   └── uteam.lua ............    8行  UTeam 客户端桩
        │   │
        │   └── sv/ (4) ............................. 629行
        │       ├── xgui_server.lua .......  276行  ⭐⭐  XGUI 服务端通信（net消息路由/数据分发）
        │       ├── votemap.lua ...........  149行  ⭐   投票换图系统
        │       ├── uteam.lua .............  133行  UTeam 队伍管理
        │       └── slots.lua .............   71行  预留槽位（VIP/管理员强制加入）
        │
        ├── items/ .................................. 267行
        │   ├── init.lua ..............  110行  ⭐⭐ 道具注册表 API（注册/查询/生成）
        │   ├── auto_discover.lua .....   59行  分类自动发现
        │   ├── weapons_css.lua ......   28行  12种 CS:S 武器
        │   ├── weapons_hl2.lua ......   17行  14种 HL2 武器
        │   ├── ammo.lua .............   15行  7种弹药
        │   ├── props.lua ............   15行  8种预设道具
        │   ├── seats.lua ............    9行  3种座椅
        │   ├── tools.lua ............    7行  3种工具枪
        │   └── vehicles.lua .........    7行  2种载具
        │
        ├── language/ .............................. 6,464行
        │   ├── ru.lua ............. 1,616行  Русский（完整俄语翻译）
        │   ├── zh-cn.lua .......... 1,616行  简体中文（完整翻译 + 文化适配）
        │   ├── en.lua ............. 1,616行  English（完整原版 + 新增命令翻译）
        │   └── lzh.lua ............ 1,616行  文言文（古典风格翻译）
        │
        └── xgui/ .................................. 5,756行
            ├── root (8)
            │   ├── commands.lua .....  397行   命令浏览/执行面板
            │   ├── groups.lua .......  545行   用户组管理面板
            │   ├── bans.lua .........  351行   封禁记录面板
            │   ├── items.lua ........  389行  ⭐ 道具生成面板（分类+搜索+快捷）
            │   ├── maps.lua .........  186行   地图投票配置面板
            │   ├── ai_bot.lua .......  145行   机器人管理面板
            │   ├── xgui_core.lua ....   97行  ⭐ XGUI 核心（concommand注册/信息栏）
            │   └── settings.lua .....   29行   设置入口
            ├── framework/
            │   ├── init.lua .........  163行  ⭐⭐ XGUI 框架初始化（窗口系统/主题/皮肤）
            │   ├── layout.lua .......   65行   统一布局引擎（多标签页管理）
            │   ├── theme.lua ........   35行   主题
            │   └── modern_layout.lua    17行   现代化布局扩展
            ├── gamemodes/
            │   └── sandbox.lua ......   62行   沙盒模式限制配置
            ├── server/ (8)
            │   ├── sv_items.lua .....  746行  ⭐⭐⭐ 智能道具生成（碰撞检测/挂墙/撤回/自适应）
            │   ├── sv_settings.lua ..  323行  ⭐⭐  服务器设置（MOTD模板/封禁消息/系统配置）
            │   ├── sv_groups.lua ....  288行  ⭐⭐  用户组服务端（权限继承/保存/同步）
            │   ├── sv_bans.lua ......  230行  ⭐   封禁服务端（查询/解封/同步）
            │   ├── sv_import.lua ....  218行       导入服务端
            │   ├── sv_ai_bot.lua ....   65行       机器人服务端
            │   ├── sv_sandbox.lua ...   42行       沙盒限制服务端
            │   └── sv_maps.lua ......   16行       地图列表服务端
            └── settings/
                ├── server.lua ....... 1089行  ⭐⭐⭐ 服务器设置面板（MOTD编辑/游戏模式/地图/沙盒限制）
                └── client.lua .......  258行  ⭐   客户端设置面板（语言/皮肤/界面选项）
```

---

## 与原版 ULX 对比

### 新增文件

| 文件 | 行数 | 大小 | 分类 | 功能 |
|:---:|:---:|:---:|:---:|:---|
| `community.lua` | 758 | 29.0 KB | 模块 | 30+ 命令 (rocket/color/halo/ESP/banip/bot...) |
| `bhop.lua` | 344 | 11.9 KB | 模块 | 参考服手感自动连跳 (JumpPower290/aa2000) |
| `admin_ext.lua` | 234 | 11.5 KB | 模块 | 限时禁言/警告分级/维护模式 |
| `crouchjump.lua` | 157 | 5.4 KB | 模块 | 蹲跳增强 (倍率+解锁+蹲走加速) |
| `coord.lua` | 168 | 6.4 KB | 模块 | 坐标 HUD + 头顶坐标 (4 模式) |
| `dev_debug.lua` | 154 | 5.5 KB | 模块 | 开发诊断 |
| `items/*` (9 文件) | 267 | 10.9 KB | 道具 | 道具注册表 API + 8 分类 |
| `settings/client.lua` | 258 | 16.5 KB | XGUI | 客户端设置 (语言/皮肤) |
| `settings/server.lua` | 1089 | 55.8 KB | XGUI | 服务器设置面板 |
| `layout.lua` | 65 | 2.5 KB | XGUI | 统一布局引擎 |
| `zh-cn.lua` | **1,616** | 79.9 KB | 语言 | 简体中文 100% |
| `lzh.lua` | **1,616** | 69.0 KB | 语言 | 文言文 100% |
| `ru.lua` | **1,616** | 89.7 KB | 语言 | Русский 100% |
| `language.lua` | 158 | 4.3 KB | 共享 | 多语言框架 |
| `sh_rngfix.lua` | 18 | 0.5 KB | RNG | 斜坡修正独立包 |

### 显著增强

| 文件 | 原版 | Ultra ULX | 增强内容 |
|:---:|:---:|:---:|:---|
| `sv_items.lua` | ~200行 | **746行** | 智能生成+碰撞自适应+挂墙+撤回 |
| `ucl.lua` | ~1,300行 | **1029行** | 备份30+恢复+DB管理+二次检测 |
| `data.lua` | ~300行 | **507行** | 中文化模板+详细注释+独立数据目录 |
| `fun.lua` | ~800行 | **1044行** | unigniteall+playsound+sslay |
| `en.lua` | ~900行 | **1,616行** | +700 翻译键 + 新增键同步 |
| `menus.lua` | ~100行 | **135行** | json+txt+gamemode三路扫描,无缓存 |

### 删除/合并

| 操作 | 原指令 | 替代方案 |
|:---:|:---|:---|
| 合并 | `!bhopcss` `!bhopcancel` | → `!bhop` + `!unbhop` |
| 合并 | `!kickbots` | → `!bot` setOpposite |
| 合并 | `!undisguise` | → `!disguise` setOpposite |
| 合并 | `!undeafen` | → `!deafen` setOpposite |
| 合并 | `!unsilence` | → `!silence` setOpposite |
| 删除 | RNG-Fix 大段逻辑 | 精简为独立 `rngfix` 包（18行） |
| 删除 | moveCmds 48px 滑块 | 改用原版 `x_getcontrol` 35px |
| 删除 | makeStyledButton | 改用标准 `xlib.makebutton` |
| 删除 | MOTD 缓存 | `populateMotdData` 每次实时 |

---

## 架构

### 6 层加载顺序


```
Layer 0: autorun/init_ulx.lua (5行)
         → SERVER: include("ulx/init.lua")
         → CLIENT: include("ulx/cl_init.lua")
Layer 1: ULib 兼容层 (ulib/* 垫片)
         → 所有 ulib 路径请求重定向到 ulx/init.lua 合并实现
Layer 2: ULX 共享库 (15 文件)
         → defines → misc → util → hook → tables → player → messages
         → commands → sh_ucl → plugin → cami_global → cami_ulib → language
Layer 3: ULX 服务端 (13 文件)
         → player → bans → concommand → srv_util → ucl → phys
         → player_ext → entity_ext → data → ulx_lib
         → ulx_command → ulx_base → log → end
Layer 4: 模块 (25 文件)
         → sh: 16 模块 | cl: 5 模块 | sv: 4 模块
Layer 5: 道具注册 (9 文件)
         → init + auto_discover + 7 分类注册表
Layer 6: XGUI (23 文件) + 语言 (4 文件)
         → root 8 + framework 4 + gamemodes 1 + server 8 + settings 2
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

### 共享模块 (16 个)

| 模块 | 行数 | 命令 | 核心功能 |
|:---:|:---:|:---:|:---|
| fun | 1044 | 25 | slap/whip/slay/ignite/freeze/god/cloak/blind/jail/ragdoll/maul |
| community | 758 | 30+ | rocket/color/halo/trail/ESP/deafen/silence/banip/bot/warn/disguise |
| util | 446 | 9 | kick/ban/unban/noclip/spectate/map/who/version |
| vote | 397 | 9 | vote/votemap2/votekick/voteban/stopvote/veto |
| bhop | 344 | 1 | 参考服手感连跳(能量守恒坡补+groundTicks反卡) |
| teleport | 327 | 6 | bring(螺旋网格)/goto(碰撞检测)/send/tpto/teleport/return |
| user | 313 | 16 | adduser/removeuser/groupallow/renamegroup |
| chat | 293 | 9 | psay/asay/tsay/csay/thetime/gimp/mute/gag+广告 |
| admin_ext | 234 | 6 | 限时禁言/警告分级/维护模式/endmaintenance |
| extras | 198 | 6 | cleanup/respawn/scale/gravity+防落地抖动 |
| coord | 168 | 2 | coordhud 屏幕上方 + coord 头顶(4模式) |
| crouchjump | 157 | 1 | 倍率(1~10x)+蹲姿解锁+蹲走加速 |
| dev_debug | 154 | 1 | 系统诊断 |
| menus | 135 | 1 | MOTD(三路扫描,无缓存) |
| rcon | 104 | 5 | rcon/luarun/exec/cexec/ent |
| userhelp | 65 | 1 | 用户管理帮助 |

### BHOP 参数（参考服手感，v2.98.52 实测配方）

> 配方来源：热门 bhop 服 "BunnyHop 兔子跳 - 1服 [128Tick]" A2S 实测

| 参数 | 值 | 说明 |
|:---:|:---:|:---|
| JumpPower (玩家跳力) | **290** | 参考服一致 |
| 走/跑速 | **250 / 250** | 统一 |
| 重力倍率 (玩家) | **1** | 不接管全局 |
| 步幅 | **18** | 参考服一致 |
| sv_airaccelerate | **2000** | 空气加速（专业 bhop 服级） |
| sv_maxspeed | **10000** | 空中期望速度上限（不影响走速） |
| sv_accelerate | **5** | 地面加速 |
| sv_friction | **4** | 摩擦 |
| sv_stopspeed | **75** | 停止速度 |
| sv_gravity | **800** | 全局重力（可设 0 不接管） |

- 开 `!bhop` 保存原始物理并应用；关 `!unbhop` 恢复；断开连接自动恢复，零残留
- 7 个全局 cvar 引用计数管理：任一玩家开启即生效，全部关闭恢复原值
- **坡度补偿**：落地瞬间 TraceHull 探坡 + ClipVelocity 能量守恒投影（无任意倍率，高速不突跳）
- **反卡机制**：贴地 >15 tick 未离地（上坡滑动）自动松一拍重建跳跃边沿
- 客户端进图立即 + 3s 轮询状态同步，防 net 丢失
- 管理员可调：`ulx_bhop_airaccelerate` / `ulx_bhop_maxspeed` / `ulx_bhop_gravity` 等 7 个 convar，设 0 = 不接管该项

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

已有分类：weapons_hl2（14件）、weapons_css（12件）、tools（3件）、ammo（7种）、props（8件）、seats（3件）、vehicles（2件）。

---

## 仓库文档索引

> 下载包仅包含插件本体；以下文档供在线查阅，不随下载包分发。

| 文档 | 说明 |
|:----|:-----|
| [README.md](README.md) | 中文主文档（本页） |
| [README.en.md](docs/README.en.md) | English documentation |
| [README.ru.md](docs/README.ru.md) | Русская документация |
| [CHANGELOG.md](docs/CHANGELOG.md) | 完整更新日志 |
| [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md) | 贡献指南 |
| [.github/SECURITY.md](.github/SECURITY.md) | 安全策略 |
| [🌐 官方网站](https://ersan233-gif.github.io/Ultra-ULX/) | 三语言官网（GitHub Pages） |

---

## 发布说明


本仓库是 **Ultra ULX 发布仓库**：根目录的 `Ultra ULX/` 文件夹即为可直接放入 `garrysmod/addons/` 的完整插件（开箱即用）。

- **发布包内容**：`addon.json` + `lua/`（123 个 Lua 文件，~27,000 行）
- **文档与插件分离**：README/CHANGELOG/官网等所有 `.md` 与 `site/` 只存于仓库，不进入 Release 打包
- **项目源码仓库**：[ultra-ulx-source](https://github.com/ersan233-GiF/ultra-ulx-source)
- **更新方式**：新版本发布后自动生成 Release 下载包
- **当前版本**：v2.98.52（build 20260817）

---

## 开发与贡献


欢迎提交 PR 与 Issue！请先阅读 [贡献指南](.github/CONTRIBUTING.md)。

> 源码与开发活动在 **[ultra-ulx-source](https://github.com/ersan233-GiF/ultra-ulx-source)** 仓库进行，欢迎提交 PR / Issue。

---

## 安全


- 所有写入路径均经过消毒与转义（`sql.SQLStr`），防止 SQL 注入
- `ulx url` 命令内置域名白名单，防止开放重定向
- 客户端 RPC 使用命名空间白名单（`ulx.*` / `ULib.*`），防止恶意调用
- 发现安全漏洞请参阅 [SECURITY.md](.github/SECURITY.md)，请勿公开披露

---

## 许可证

本项目基于 [CC BY-NC-SA 3.0](LICENSE) 许可发布（非商业使用）。

- 原版 ULX / ULib 版权归 [Team Ulysses](https://github.com/TeamUlysses) 所有
- Ultra ULX 在保留原版权声明的基础上进行增强与中文化

---

## 致谢

- [Team Ulysses](https://github.com/TeamUlysses) — 原版 ULX / ULib 的开发者
- Garry's Mod 社区 — 命令灵感与大量反馈
- 所有为 Ultra ULX 提交过 Issue / PR / 建议的朋友

---

**[⬆ 返回顶部](#)**

---

## 更新日志

### v2.98.52 (2026-08-17)

- **发布**：全新发布包，迭代自 v2.98.51，完成游戏内全功能验证
- **BHOP**：参考服手感移植——全局 7 项 convar 配方（sv_airaccelerate=2000 等，引用计数+可关）、JumpPower 290、ClipVelocity 能量守恒坡度补偿（废弃任意倍率）、groundTicks 上坡反卡、客户端 3s 状态同步
- **修复**：`!endmaintenance` oppositeArgs 传参错误（原 `{false}` 为 falsy 导致反向开启维护）
- **修复**：服务端日志模板漏 `#T/#P` 占位符导致原样输出
- **修复**：`ulx return` 别名缺失参数/权限/帮助定义
- **修复**：错误记录文件路径更正（`errors.jsonl` → `errors.json`）
- **语言**：清理孤儿键，4 语言包对齐至 1,614 键（文件各 1,616 行）
- **仓库**：文档与插件彻底分离——所有 `.md` 仅存仓库可在线查阅，不进入发布包

### v2.98.51 (2026-08-11)

- **发布**：全新发布包，迭代自 v2.98.50，可直接放入 `addons/` 使用
- **修复**：XGUI 设置面板语法错误（`not` 替代 C 风格 `!`），消除级联报错
- **清理**：移除 4 个无发送端的死网络接收器，减少无用 net 监听
- **界面**：恢复 v2.72.0 经典 XGUI 布局与底部信息栏
- **性能**：全模块热路径 local 缓存优化
- **语言**：4 语言包对齐

### v2.70.0 (2026-06-20)

- **性能优化**: coord.lua HUDPaint 钩子改为动态添加/移除，关闭后零开销
- **硬编码迁移**: teleport.lua 全部错误提示和日志改用 `L.T()` 多语言系统
- **新增语言键**: `tele_tp_help`、`tele_send_help`、`tele_tpto_help` 同步至 4 种语言
- **移除冗余 net 消息**: community.lua 中的 `ulx_community_deafen/silence` net 消息已移除（NWBool 已自动同步）
- **修复定时器负延迟**: sv_bans.lua 中已过期封禁立即执行解封，不再创建空定时器
- **编辑器兼容**: 添加诊断屏蔽标记，消除大量误报错误
- **修复运算符优先级**: sv_bans.lua `\255` 拼接括号修正
- **修复 `mousecode` 拼写错误**: xlib.lua 中 `mousecode` → `mcode`

*Ultra ULX — 基于 [ULX](https://github.com/TeamUlysses/ulx) by Team Ulysses · [发布仓库](https://github.com/ersan233-GiF/Ultra-ULX) · [开发源码](https://github.com/ersan233-GiF/ultra-ulx-source)*
