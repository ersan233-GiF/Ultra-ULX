# Ultra ULX v2.69.1

> 基于 Team Ulysses ULX v3.71 ⸱ 完全中文化 ⸱ 69+ 新命令

---

## 快速安装

```
1. 将 Ultra ULX 文件夹放入 garrysmod/addons/
2. 重启服务器
3. 控制台显示 // Ultra ULX v2.69.1 Loaded! // 即成功
```

## 命令使用

| 方式 | 示例 | 说明 |
|:----|:-----|:-----|
| 聊天框 `!指令` | `!bring 玩家` | 最常用，游戏中直接输入 |
| 控制台 `ulx_指令` | `ulx bring 玩家` | 管理员使用 |
| `!menu` 或 `!xgui` | 打开图形界面 | 全功能 XGUI 管理面板 |

## 卸载

```
1. 删除 addons/Ultra ULX/ 整个文件夹
2. （可选）删除 data/ultra_ulx/ 配置
3. 重启服务器 — 原版 ULX 自动恢复，零残留
```

> **零侵入设计**：所有数据存储在 `data/ultra_ulx/` 独立目录，不修改原版 ULX。

## 与原版 ULX 共存

| 场景 | 行为 |
|:----|:-----|
| 原版 ULX 已安装 | Ultra ULX 自动覆盖同名命令 |
| 仅安装 Ultra ULX | 自带完整 ULib，无需额外安装 |
| 删除 Ultra ULX | 原版 ULX 完整保留 |

## 多语言切换

客户端控制台执行:

| 代码 | 语言 |
|:----|:-----|
| `ulx_lang zh-cn` | 简体中文 |
| `ulx_lang en` | English |
| `ulx_lang ru` | Русский |
| `ulx_lang lzh` | 文言文 |

或 `!menu` → 设置 → 客户端 → 语言 中切换。

## 常见问题

| 问题 | 解决 |
|:----|:-----|
| `Unknown command: ulx` | 检查目录是否多了一层嵌套：`addons/Ultra ULX/lua/` 必须直接存在 |
| `Groups file was not formatted correctly` | 删除 `data/ulib/groups.txt`，重启自动重建 |
| 命令无反应 | 确认自己有对应权限（SuperAdmin/Admin） |
| 语言切换后乱码 | 输入 `ulx_lang zh-cn` 切回中文 |

---

## 总览

| 指标 | 数值 |
|:---:|:---:|
| 总行数 (Lua) | **~26,100 行** |
| Lua 源码大小 | **~1.07 MB** |
| 文件数 (Lua) | **91 个** |
| 语言包 | **4 种** (简体中文 / English / Русский / 文言文) |
| 命令总数 | **~114 条** (原版 ~45 条 + 69+ 新增) |
| 模块数 | **23 个** (sh 14 + cl 5 + sv 4) |
| 道具分类 | **9 类** |
| ULib 版本 | 2.72 |
| Ultra ULX 版本 | **v2.69.1** |
| ULX 兼容版本 | 3.81 |

---

## 完整文件树

```
addons/Ultra ULX/                          [~1.07 MB / ~26,100 行]
│
├── addon.json ........................... 412 B    插件元数据 JSON
├── README.md                             本文件
│
└── lua/
    ├── autorun/
    │   ├── init_ulx.lua ............. 132 B  [  6行]  GMod 自动加载入口
    │   └── rngfix/ ............................. RNG-Fix 独立包
    │       ├── ent_trigger.lua ....... 493 B  [ 39行]  触发器实体
    │       └── sh_rngfix.lua ......... 585 B  [ 19行]  斜坡修正逻辑
    │
    └── ulx/
        ├── init.lua ................. 6.6 KB [188行]  ⭐ 服务端主入口
        ├── cl_init.lua .............. 4.5 KB [136行]  ⭐ 客户端主入口
        │
        ├── shared/ .............................. 170.2 KB [4,753行]
        │   ├── defines.lua ......... 11.2 KB [377行]  ⭐ 常量+7色主题
        │   ├── misc.lua ............ 19.1 KB [750行]  字符串/解析/继承
        │   ├── util.lua ............ 12.7 KB [454行]  文件IO/队列/序列化
        │   ├── hook.lua ............ 2.2 KB  [ 94行]  5级优先级钩子
        │   ├── tables.lua .......... 3.5 KB  [123行]  只读表/矩阵
        │   ├── player.lua .......... 7.5 KB  [311行]  目标匹配/选择器
        │   ├── messages.lua ........ 5.5 KB  [232行]  tsay/彩色/分块
        │   ├── commands.lua ........ 38.5 KB [1,222行] 命令系统核心
        │   ├── sh_ucl.lua .......... 6.5 KB  [226行]  共享 UCL 权限
        │   ├── plugin.lua .......... 4.6 KB  [148行]  插件注册/更新
        │   ├── cami_global.lua ..... 12.6 KB [447行]  CAMI 接口
        │   ├── cami_ulib.lua ....... 4.1 KB  [ 98行]  CAMI-ULib 桥接
        │   ├── language.lua ........ 2.9 KB  [109行]  多语言系统框架
        │   ├── ulx_defines.lua ..... 521 B   [ 12行]  ULX 常量
        │   └── ulx_base.lua ........ 4.8 KB  [150行]  ULX 命令基类
        │
        ├── server/ ............................... 133.5 KB [3,597行]
        │   ├── ucl.lua ............ 37.1 KB [1,307行]  ⭐ UCL+SQLite+备份
        │   ├── data.lua ........... 14.9 KB [467行]  默认配置模板生成
        │   ├── log.lua ............ 17.2 KB [448行]  日志+彩色回显
        │   ├── player.lua ......... 6.4 KB  [253行]  玩家管理查询
        │   ├── bans.lua ........... 6.5 KB  [249行]  封禁系统
        │   ├── srv_util.lua ....... 5.8 KB  [183行]  复制 Cvar 系统
        │   ├── ulx_lib.lua ........ 2.3 KB  [ 76行]  独占/不死/标准化
        │   ├── ulx_command.lua .... 3.6 KB  [ 94行]  Cvar 系统
        │   ├── player_ext.lua ..... 1.7 KB  [ 62行]  扩展限制
        │   ├── entity_ext.lua ..... 4.7 KB  [167行]  实体扩展
        │   ├── phys.lua ........... 3.1 KB  [ 98行]  物理工具
        │   ├── concommand.lua ..... 2.5 KB  [ 90行]  控制台命令
        │   └── end.lua ............ 3.1 KB  [103行]  配置加载引擎
        │
        ├── client/ ................................ 9.3 KB [268行]
        │   ├── ulx_cl_lib.lua ..... 2.7 KB  [103行]  客户端数据填充
        │   ├── cl_util.lua ........ 3.7 KB  [104行]  客户端工具
        │   ├── cl_commands.lua .... 397 B   [ 13行]  客户端命令
        │   └── draw.lua ........... 1.3 KB  [ 48行]  绘制
        │
        ├── modules/ .............................. 294.9 KB [7,251行]
        │   ├── sh/ (14) .......................... 184.3 KB [4,447行]
        │   │   ├── community.lua .. 28.0 KB [785行]  ⭐ 30+ 社区命令
        │   │   ├── fun.lua ........ 30.9 KB [918行]  娱乐 25 命令
        │   │   ├── util.lua ....... 15.5 KB [445行]  工具 kick/ban
        │   │   ├── vote.lua ....... 13.4 KB [382行]  投票系统
        │   │   ├── teleport.lua ... 9.9 KB  [314行]  传送 bring/goto
        │   │   ├── user.lua ....... 9.4 KB  [307行]  用户管理
        │   │   ├── chat.lua ....... 8.5 KB  [273行]  聊天 psay/gimp
        │   │   ├── bhop.lua ....... 8.2 KB  [216行]  CS:S 自动连跳
        │   │   ├── extras.lua ..... 7.2 KB  [209行]  cleanup/scale
        │   │   ├── coord.lua ...... 6.0 KB  [153行]  坐标 HUD + 头顶
        │   │   ├── crouchjump.lua . 5.8 KB  [145行]  蹲跳增强
        │   │   ├── menus.lua ...... 5.1 KB  [133行]  MOTD 菜单
        │   │   ├── rcon.lua ....... 3.7 KB  [101行]  远程控制
        │   │   └── userhelp.lua ... 2.6 KB  [ 66行]  用户帮助
        │   │
        │   ├── cl/ (5) ............................ 82.8 KB [2,137行]
        │   │   ├── xlib.lua ............. 32.2 KB [1,137行] XGUI 控件库
        │   │   ├── xgui_helpers.lua ..... 14.5 KB [392行]  原版 35px 滑块
        │   │   ├── xgui_client.lua ...... 13.3 KB [360行]  XGUI 客户端
        │   │   ├── motdmenu.lua ......... 9.5 KB  [240行]  MOTD HTML
        │   │   └── uteam.lua ............ 222 B   [  8行]  UTeam
        │   │
        │   └── sv/ (4) ............................. 27.8 KB [667行]
        │       ├── xgui_server.lua ....... 11.0 KB [306行]  XGUI 通信
        │       ├── votemap.lua ........... 6.2 KB  [155行]  投票换图
        │       ├── uteam.lua ............. 5.0 KB  [135行]  UTeam
        │       └── slots.lua ............. 2.9 KB  [ 71行]  预留槽位
        │
        ├── items/ .................................. 9.6 KB [175行]
        │   ├── init.lua .............. 2.1 KB  [ 65行]  ⭐ 注册表 API
        │   ├── weapons_hl2.lua ...... 979 B   [ 16行]  HL2 武器 14 件
        │   ├── weapons_css.lua ...... 2.1 KB  [ 31行]  CSS 武器 12 件
        │   ├── weapons_admin.lua .... 294 B   [  5行]  管理员武器 2 件
        │   ├── tools.lua ............ 408 B   [  8行]  工具 3 件
        │   ├── ammo.lua ............. 1.1 KB  [ 16行]  弹药 7 种
        │   ├── props.lua ............ 1.1 KB  [ 16行]  道具 8 件
        │   ├── seats.lua ............ 1.1 KB  [ 10行]  座椅 3 件
        │   └── vehicles.lua ......... 512 B   [  8行]  载具 2 件
        │
        ├── language/ .............................. 176.5 KB [4,054行]
        │   ├── zh-cn.lua ......... 36.6 KB [951行]  简体中文
        │   ├── en.lua ............. 40.7 KB [1,068行]  English
        │   ├── ru.lua ............. 54.0 KB [1,047行]  Русский
        │   └── lzh.lua ............ 41.3 KB [988行]  文言文
        │
        └── xgui/ .................................. 256.0 KB [5,634行]
            ├── root (7)
            │   ├── commands.lua ..... 13.7 KB [411行]  命令面板
            │   ├── groups.lua ....... 21.5 KB [568行]  用户组
            │   ├── bans.lua ......... 16.0 KB [359行]  封禁记录
            │   ├── items.lua ........ 16.3 KB [431行]  道具面板
            │   ├── maps.lua ......... 7.4 KB  [191行]  地图投票
            │   ├── xgui_core.lua .... 3.8 KB  [112行]  XGUI 核心
            │   └── settings.lua ..... 1.0 KB  [ 32行]  设置入口
            ├── framework/
            │   ├── init.lua ......... 7.0 KB  [190行]  框架初始化
            │   └── layout.lua ....... 3.3 KB  [101行]  布局引擎
            ├── gamemodes/
            │   └── sandbox.lua ...... 5.1 KB  [ 72行]  沙盒限制
            ├── server/ (6)
            │   ├── sv_items.lua ..... 34.4 KB [830行]  智能生成
            │   ├── sv_settings.lua .. 11.7 KB [330行]  服务器设置
            │   ├── sv_groups.lua .... 11.7 KB [321行]  组服务端
            │   ├── sv_bans.lua ...... 9.3 KB  [254行]  封禁服务端
            │   ├── sv_sandbox.lua ... 1.7 KB  [ 47行]  沙盒服务端
            │   └── sv_maps.lua ...... 660 B   [ 18行]  地图服务端
            └── settings/
                ├── server.lua ....... 59.8 KB [1,142行] 服务器设置
                └── client.lua ....... 14.8 KB [265行]  客户端设置
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
| `zh-cn.lua` | 951 | 36.6 KB | 语言 | 简体中文 100% |
| `lzh.lua` | 988 | 41.3 KB | 语言 | 文言文 100% |
| `ru.lua` | 1,047 | 54.0 KB | 语言 | Русский 100% |
| `language.lua` | 109 | 2.9 KB | 共享 | 多语言框架 |
| `rngfix/` (2 文件) | 58 | 1.1 KB | RNG | 斜坡修正独立包 |

### 显著增强

| 文件 | 原版 | Ultra ULX | 增强内容 |
|:---:|:---:|:---:|:---|
| `sv_items.lua` | ~200行 | **830行** | 智能生成+碰撞自适应+挂墙+撤回 |
| `ucl.lua` | ~1,300行 | **1,307行** | 备份30+恢复+DB管理+二次检测 |
| `data.lua` | ~300行 | **467行** | 中文化模板+详细注释+独立数据目录 |
| `fun.lua` | ~800行 | **918行** | unigniteall+playsound+sslay |
| `en.lua` | ~900行 | **1,068行** | +200 翻译键 |
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

> 开 `!bhop` 保存原始物理并覆盖; 关 `!unbhop` 恢复。SetupMove 每帧保活。

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

## 命令参考

### 完整索引

| 分类 | 命令 |
|:---:|:---|
| 娱乐 | `!slap !whip !slay !sslay !ignite !playsound !freeze !god !hp !armor !cloak !blind !jail !jailtp !ragdoll !maul !strip !launch !rocket !explode !color !halo !trail !esp` |
| 工具 | `!cleardecals !profile !redirect !stopsound !timescale !url !aliases !removeragdolls !cleanup !respawn !setmodel !setteam !giveweapon !scale !gravity !coordhud !coord !showtriggers` |
| 聊天 | `!p !psay @ !asay @@ !tsay @@@ !csay !thetime !gimp !mute !gag !rsay !deafen !silence` |
| 移动 | `!jumppower !runspeed !walkspeed !speed !stepsize !bhop !crouchjump` |
| 传送 | `!bring !goto !send !tp !teleport !tpto !return` |
| 投票 | `!vote !stopvote !votemap !votemap2 !votekick !voteban !veto !mapvote !gmvote` |
| 管理 | `!kick !ban !unban !banid !noclip !spectate !map !who !version !resettodefaults !banip !bot !warn !disguise` |
| 远程 | `ulx rcon !rcon ulx luarun ulx exec ulx cexec !cexec ulx ent` |
| 菜单 | `!motd ulx motd` |

> 每个 `!command` 均有对应的 `ulx command` 控制台版本，以及 `!uncommand` 反向命令 (setOpposite)。

---

## 配置系统

```
data/ultra_ulx/                        ← Ultra ULX 独立目录
├── config.txt       ← 主配置
├── groups.txt       ← 用户组
├── users.txt        ← 用户 (备份, 主存储 SQLite)
├── adverts.txt      ← 广播公告
├── motd.txt         ← MOTD 模板
├── votemaps.txt     ← 投票地图
├── banreasons.txt   ← 封禁原因
├── banmessage.txt   ← 封禁消息 ({{变量}})
├── sbox_limits.txt  ← 沙盒限制 (含 Wiremod)
├── xgui_settings.txt← XGUI 界面
├── language.txt     ← 语言缓存
├── gamemodes/<m>/   ← 按模式配置 (叠加)
└── maps/<m>/        ← 按地图配置 (叠加)
```

**优先级**: adverts/downloads/config → 三层叠加 · gimps/votemaps → 取最具体

**备份**: `data/ulib_backups/users_YYYYMMDD_HHMMSS.txt` (保留 30 个)

---

## 颜色主题

```
ULib.COLOR_ACCENT    = Color( 60, 160, 240 )  主色调 (原版 151,211,255→加深40%)
ULib.COLOR_SUCCESS   = Color( 40, 200,  80 )  成功
ULib.COLOR_WARN      = Color(220, 140,   0 )  警告
ULib.COLOR_ERROR     = Color(220,  80,  30 )  错误
ULib.COLOR_INFO      = Color(  0, 170, 220 )  信息
ULib.COLOR_MUTED     = Color(160, 160, 170 )  弱化
ULib.COLOR_HIGHLIGHT = Color(255, 180,   0 )  高亮
```

---

## 关键机制

| 机制 | 实现 |
|:---|:---|
| 共存 | InitPostEntity 重注册覆盖，数据目录独立，删除即恢复 |
| 同步 | CRC 比对 → 删本地 .lua → retry 重连 |
| 零泄露 | BHOP cvar 首个启用设，全关恢复，ShutDown 兜底，非沙盒跳过 |
| 无缓存 | MOTD populateMotdData 每次实时，addon.json+gamemode 双路 |
| 安全加载 | 硬编码模块清单，pcall 包裹，不跨 addon 扫描 |

---

## 道具 API