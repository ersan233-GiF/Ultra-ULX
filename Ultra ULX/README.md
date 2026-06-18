<div align="center">

# <span style="color:#3ca0f0">Ultra</span> <span style="color:#40c850">ULX</span> <span style="color:#e0a030">v3.81</span>

### 完整技术手册

<span style="color:#3ca0f0">**基于 Team Ulysses ULX v3.71**</span> · <span style="color:#40c850">完全中文化</span> · <span style="color:#e0a030">50+ 新命令</span> · <span style="color:#b050e0">BHOP 自动连跳</span> · <span style="color:#f06040">坐标系统</span> · <span style="color:#40c850">ESP 透视</span>

---

</div>

| | | |
|:---:|:---:|:---:|
| <span style="color:#40c850">🟢 **新增**</span> Ultra ULX 独有 | <span style="color:#3ca0f0">🔵 **增强**</span> 功能显著扩展 | <span style="color:#e0a030">🟡 **配置**</span> 配置/模板/语言 |
| <span style="color:#b050e0">🟣 **核心**</span> 服务端关键逻辑 | <span style="color:#f06040">🔴 **模块**</span> 社区扩展模块 | <span style="color:#a0a0a0">⚪ **原版**</span> 小幅调整 |

---

## 总览

| 指标 | 数值 |
|:---:|:---:|
| 总行数 (Lua) | <span style="color:#40c850">**30,602 行**</span> |
| Lua 源码大小 | <span style="color:#3ca0f0">**1.06 MB**</span> (1,108,347 bytes) |
| 文件数 (Lua) | <span style="color:#b050e0">**84 个**</span> |
| 语言包 | <span style="color:#e0a030">4 种</span> (简体中文 / English / Русский / 文言文) |
| 命令总数 | <span style="color:#40c850">**~95 条**</span> (原版 ~45 条) |
| 模块数 | <span style="color:#3ca0f0">22 个</span> (sv 4 + sh 14 + cl 4) |
| 道具分类 | <span style="color:#f06040">8 类</span> |
| ULib 版本 | 2.72 |
| ULX 版本号 | 2026.06.08 |

---

## 性能预估

### 服务端

| 指标 | 原版 ULX | Ultra ULX | 增量 |
|:---:|:---:|:---:|:---:|
| Script CPU (空闲) | ~0.05 ms | ~0.08 ms | <span style="color:#e0a030">+60%</span> |
| Script CPU (峰值) | ~0.3 ms | ~0.5 ms | <span style="color:#e0a030">+67%</span> |
| Lua 内存 | ~8 MB | ~14 MB | <span style="color:#f06040">+6 MB</span> |
| 网络上行 (玩家加入) | ~50 KB | ~120 KB | +70 KB |
| 网络上行 (运行时) | ~0.1 KB/s | ~0.3 KB/s | +0.2 KB/s |
| 数据库磁盘 | ~200 KB | ~2 MB | +1.8 MB |
| 磁盘占用 (addon) | ~500 KB | <span style="color:#40c850">**1.1 MB**</span> | +600 KB |

### 客户端

| 指标 | 原版 ULX | Ultra ULX | 增量 |
|:---:|:---:|:---:|:---:|
| 脚本首次加载 | ~0.3s | ~0.6s | +0.3s |
| 缓存命中加载 | ~0.1s | ~0.2s | +0.1s |
| GPU (HUDPaint) | ~0.01 ms | ~0.05 ms | +0.04ms |
| GPU (3D 钩子) | 0 | ~0.02 ms | Halo/Trail |
| 内存 | ~5 MB | ~10 MB | +5 MB |
| 首次网络下载 | ~80 KB | ~200 KB | +120 KB |

### 模块性能

| 模块 | CPU | GPU | 内存 | 网络 |
|:---:|:---:|:---:|:---:|:---:|
| BHOP (srv) | 0.01ms | — | 2KB/人 | 10B/tick |
| BHOP (cli) | 0.005ms | — | 0.1KB | — |
| 坐标 HUD | — | 0.01ms | 0.2KB | — |
| 头顶坐标 | — | 0.02ms | 0.5KB | 80B/0.25s |
| ESP 透视 | — | 0.03ms | 1KB | 20B |
| Halo 发光 | — | 0.01ms | 0.1KB | 20B |
| Trail 拖尾 | — | 0.02ms | 2KB | 20B |
| 道具生成 | 0.005ms | — | 10KB | 50B |
| MOTD 扫描 | 2ms(一次) | — | 5KB | — |

### 加载分解 (服务端)

```
共享库 ........... ~120ms  (15 文件, commands.lua 49KB)
核心 ............. ~80ms   (12 文件, ucl.lua 48KB)
模块 ............. ~60ms   (22 文件)
道具 ............. ~5ms    (9 文件)
XGUI ............. ~30ms   (7 文件)
配置 ............. ~50ms   (8 处理器, IO)
语言 ............. ~10ms   (4 文件 185KB)
重注册 ........... ~40ms   (14 模块)
───────────────────────────
总计 ............. ~400ms
```

> **10 人↓** 无感知 · **20-32 人** 坐标 0.5s/关Trail · **50+人** 关ESP/Halo · **64 满** 关BHOP全局/限MOTD

---

## 完整文件树

```
addons/Ultra ULX/                          [1,108,347 bytes / 30,602 行]
│
├── <span style="color:#e0a030">●</span> addon.json ................... 412 B      插件元数据 JSON
├── <span style="color:#e0a030">●</span> addon.txt .................... 243 B      兼容旧版 KeyValues
├── <span style="color:#e0a030">●</span> README.md .................... 48 KB     本文件
├── <span style="color:#a0a0a0">○</span> .gitignore ............................. Git 忽略规则
│
└── 📁 lua/
    ├── 📁 autorun/
    │   ├── <span style="color:#40c850">●</span> init_ulx.lua ..... 132 B  [  6行]  GMod 自动加载入口
    │   └── 📁 rngfix/ ................................. RNG-Fix 独立包
    │       ├── ent_trigger.lua . 1,008 B  [ 45行]  触发器实体
    │       └── sh_rngfix.lua .... 11.4KB  [442行]  斜坡修正逻辑
    │
    └── 📁 ulx/
        ├── <span style="color:#40c850">●</span> init.lua ................. 11.1KB [283行]  ⭐ 服务端主入口
        │   ├─ 加载 53 文件 (10 阶段) + 硬编码模块清单
        │   ├─ 语言 ConVar + P0 共存覆盖 + P1 旧数据检测
        │   └─ 客户端 AddCSLuaFile 批量发送
        │
        ├── <span style="color:#40c850">●</span> cl_init.lua .............. 5.4KB [167行]  ⭐ 客户端主入口
        │   ├─ 版本自动同步 (比对 → 删本地 → retry)
        │   ├─ UCL auth 流程 + 旧数据导入 Derma 弹窗
        │   └─ 硬编码模块安全加载
        │
        ├── 📁 shared/ .............................. 170.7KB [6,099行]
        │   ├── <span style="color:#40c850">●</span> defines.lua ........ 12.8KB [488行]  ⭐ 常量+22钩子+7色主题
        │   ├── <span style="color:#a0a0a0">○</span> misc.lua ........... 25.6KB [1029行] 字符串/解析/继承
        │   ├── <span style="color:#a0a0a0">○</span> util.lua ........... 15.7KB [635行]  文件IO/队列/序列化
        │   ├── <span style="color:#a0a0a0">○</span> hook.lua ........... 2.7KB  [113行]  5级优先级钩子
        │   ├── <span style="color:#a0a0a0">○</span> tables.lua ......... 3.9KB  [163行]  只读表/矩阵
        │   ├── <span style="color:#a0a0a0">○</span> player.lua ......... 10.4KB [383行]  目标匹配/选择器
        │   ├── <span style="color:#a0a0a0">○</span> messages.lua ....... 7.4KB  [294行]  tsay/彩色/分块
        │   ├── <span style="color:#a0a0a0">○</span> commands.lua ....... 49.8KB [1569行] 命令系统核心
        │   ├── <span style="color:#a0a0a0">○</span> sh_ucl.lua ......... 8.7KB  [312行]  共享 UCL 权限
        │   ├── <span style="color:#a0a0a0">○</span> plugin.lua ......... 6.0KB  [189行]  插件注册/更新
        │   ├── <span style="color:#a0a0a0">○</span> cami_global.lua .... 14.1KB [524行]  CAMI 接口
        │   ├── <span style="color:#a0a0a0">○</span> cami_ulib.lua ...... 5.0KB  [121行]  CAMI-ULib 桥接
        │   ├── <span style="color:#40c850">●</span> language.lua ....... 2.3KB  [ 92行]  多语言系统框架
        │   ├── <span style="color:#a0a0a0">○</span> ulx_defines.lua .... 521 B  [ 16行]  ULX 常量
        │   └── <span style="color:#a0a0a0">○</span> ulx_base.lua ....... 5.6KB  [171行]  ULX 命令基类
        │
        ├── 📁 server/ ............................... 136.3KB [4,311行]
        │   ├── <span style="color:#b050e0">●</span> ucl.lua ........... 48.9KB [1595行]  ⭐ UCL+SQLite+备份
        │   ├── <span style="color:#e0a030">●</span> data.lua .......... 17.9KB [503行]  默认配置模板生成
        │   ├── <span style="color:#b050e0">●</span> log.lua ........... 18.7KB [521行]  日志+彩色回显
        │   ├── <span style="color:#a0a0a0">○</span> player.lua ........ 8.7KB  [321行]  玩家管理查询
        │   ├── <span style="color:#b050e0">●</span> bans.lua .......... 8.0KB  [318行]  封禁系统
        │   ├── <span style="color:#a0a0a0">○</span> srv_util.lua ...... 7.5KB  [231行]  复制 Cvar 系统
        │   ├── <span style="color:#a0a0a0">○</span> ulx_lib.lua ....... 2.7KB  [ 88行]  独占/不死/标准化
        │   ├── <span style="color:#a0a0a0">○</span> ulx_command.lua ... 4.6KB  [120行]  Cvar 系统
        │   ├── <span style="color:#a0a0a0">○</span> player_ext.lua .... 2.0KB  [ 72行]  扩展限制
        │   ├── <span style="color:#a0a0a0">○</span> entity_ext.lua .... 5.1KB  [186行]  实体扩展
        │   ├── <span style="color:#a0a0a0">○</span> phys.lua .......... 4.2KB  [114行]  物理工具
        │   ├── <span style="color:#a0a0a0">○</span> concommand.lua .... 3.4KB  [122行]  控制台命令
        │   └── <span style="color:#a0a0a0">○</span> end.lua ........... 4.6KB  [125行]  配置加载引擎
        │
        ├── 📁 client/ ................................ 9.3KB  [332行]
        │   ├── ulx_cl_lib.lua ........ 3.2KB  [128行]  客户端数据填充
        │   ├── cl_util.lua ........... 4.4KB  [133行]  客户端工具
        │   ├── cl_commands.lua ....... 397 B  [ 17行]  客户端命令
        │   └── draw.lua .............. 1.3KB  [ 54行]  绘制
        │
        ├── 📁 modules/
        │   ├── 📁 sh/ ................................ 185.9KB [4,869行]
        │   │   ├── <span style="color:#f06040">●</span> community.lua .. 31.6KB [815行]  ⭐ 30+社区命令
        │   │   ├── <span style="color:#f06040">●</span> fun.lua ........ 33.6KB [1021行] 娱乐 25 命令
        │   │   ├── <span style="color:#f06040">●</span> util.lua ....... 21.9KB [517行]  工具 kick/ban
        │   │   ├── <span style="color:#f06040">●</span> vote.lua ....... 16.5KB [449行]  投票系统
        │   │   ├── <span style="color:#f06040">●</span> user.lua ....... 16.9KB [353行]  用户管理
        │   │   ├── <span style="color:#f06040">●</span> teleport.lua ... 12.5KB [381行]  传送 bring/goto
        │   │   ├── <span style="color:#f06040">●</span> chat.lua ....... 11.3KB [321行]  聊天 psay/gimp
        │   │   ├── <span style="color:#f06040">●</span> extras.lua ..... 8.7KB  [224行]  cleanup/scale
        │   │   ├── <span style="color:#f06040">●</span> coord.lua ...... 6.4KB  [152行]  坐标HUD+头顶
        │   │   ├── <span style="color:#f06040">●</span> crouchjump.lua . 5.9KB  [166行]  蹲跳 3 功能
        │   │   ├── <span style="color:#f06040">●</span> bhop.lua ....... 5.6KB  [109行]  CS:S 自动连跳
        │   │   ├── <span style="color:#40c850">●</span> menus.lua ...... 5.8KB  [156行]  MOTD 菜单
        │   │   ├── <span style="color:#f06040">●</span> rcon.lua ....... 4.4KB  [120行]  远程控制
        │   │   └── <span style="color:#f06040">●</span> userhelp.lua ... 5.1KB  [ 85行]  用户帮助
        │   │
        │   ├── 📁 cl/ ................................ 84.8KB  [2,393行]
        │   │   ├── xlib.lua .............. 43.9KB [1269行]  XGUI 控件库
        │   │   ├── xgui_helpers.lua ...... 18.2KB [440行]   原版 35px 滑块
        │   │   ├── xgui_client.lua ....... 15.0KB [401行]   XGUI 客户端
        │   │   ├── motdmenu.lua .......... 7.4KB  [273行]   MOTD HTML
        │   │   └── uteam.lua ............. 222 B  [ 10行]   UTeam
        │   │
        │   └── 📁 sv/ ................................ 28.4KB  [763行]
        │       ├── xgui_server.lua ....... 12.7KB [344行]   XGUI 通信
        │       ├── votemap.lua ........... 7.5KB  [181行]   投票换图
        │       ├── uteam.lua ............. 4.6KB  [149行]   UTeam
        │       └── slots.lua ............. 3.5KB  [ 89行]   预留槽位
        │
        ├── 📁 items/ .................................. 9.8KB  [184行]
        │   ├── <span style="color:#40c850">●</span> init.lua ............ 2.2KB  [ 72行]  ⭐ 注册表 API
        │   ├── weapons_hl2.lua ........ 979 B  [ 16行]  HL2 武器 14 件
        │   ├── weapons_css.lua ........ 2.1KB  [ 33行]  CSS 武器 12 件
        │   ├── weapons_admin.lua ...... 294 B  [  5行]  管理员武器 2 件
        │   ├── tools.lua .............. 408 B  [  8行]  工具 3 件
        │   ├── ammo.lua ............... 1.1KB  [ 16行]  弹药 7 种
        │   ├── props.lua .............. 1.1KB  [ 16行]  道具 8 件
        │   ├── seats.lua .............. 1.1KB  [ 10行]  座椅 3 件
        │   └── vehicles.lua ........... 512 B  [  8行]  载具 2 件
        │
        ├── 📁 language/ .............................. 185.5KB [4,339行]
        │   ├── <span style="color:#40c850">●</span> zh-cn.lua ........ 43.8KB [1049行]  🇨🇳 简体中文
        │   ├── <span style="color:#3ca0f0">●</span> en.lua ............ 45.6KB [1131行]  🇺🇸 English
        │   ├── <span style="color:#40c850">●</span> ru.lua ............ 57.7KB [1112行]  🇷🇺 Русский
        │   └── <span style="color:#40c850">●</span> lzh.lua ........... 38.4KB [1047行]  🏯 文言文
        │
        └── 📁 xgui/ .................................. 267.9KB [6,368行]
            ├── commands.lua .......... 15.2KB [452行]  命令面板
            ├── groups.lua ............ 24.4KB [609行]  用户组
            ├── bans.lua .............. 19.1KB [383行]  封禁记录
            ├── <span style="color:#40c850">●</span> items.lua ............ 16.7KB [476行]  道具面板
            ├── maps.lua .............. 8.9KB  [212行]  地图投票
            ├── xgui_core.lua ......... 5.8KB  [169行]  XGUI 核心
            ├── settings.lua .......... 1.3KB  [ 37行]  设置入口
            ├── 📁 framework/
            │   ├── init.lua .......... 7.1KB  [190行]  框架初始化
            │   └── <span style="color:#40c850">●</span> layout.lua ........ 3.5KB  [101行]  布局引擎
            ├── 📁 gamemodes/
            │   └── sandbox.lua ....... 5.2KB  [ 72行]  沙盒限制
            ├── 📁 server/
            │   ├── <span style="color:#3ca0f0">●</span> sv_settings.lua ... 60.2KB [1255行] 服务器 MOTD
            │   ├── <span style="color:#3ca0f0">●</span> sv_items.lua ...... 36.1KB [899行]  智能生成
            │   ├── sv_groups.lua ..... 12.9KB [353行]  组服务端
            │   ├── sv_bans.lua ....... 10.2KB [297行]  封禁服务端
            │   ├── <span style="color:#40c850">●</span> sv_import.lua ..... 4.6KB  [128行]  数据导入
            │   ├── sv_sandbox.lua .... 3.7KB  [ 53行]  沙盒服务端
            │   └── sv_maps.lua ....... 660 B  [ 20行]  地图服务端
            └── 📁 settings/
                ├── server.lua ........ 60.2KB [1255行] 服务器设置
                └── <span style="color:#40c850">●</span> client.lua ....... 17.3KB [286行]  客户端设置
```

---

## 与原版 ULX 对比

### <span style="color:#40c850">新增文件</span>

| 文件 | 行数 | 字节 | 分类 | 功能 |
|:---:|:---:|:---:|:---:|:---|
| `community.lua` | <span style="color:#f06040">815</span> | 31.6KB | <span style="color:#f06040">模块</span> | 30+ 命令 (rocket/color/halo/ESP/banip/bot...) |
| `bhop.lua` | 109 | 5.6KB | <span style="color:#f06040">模块</span> | CS:S 自动连跳 (跑260/跳300/重力0.6) |
| `crouchjump.lua` | 166 | 5.9KB | <span style="color:#f06040">模块</span> | 蹲跳增强 (倍率+解锁+蹲走加速) |
| `coord.lua` | 152 | 6.4KB | <span style="color:#f06040">模块</span> | 坐标 HUD + 头顶坐标 (4 模式) |
| `items/init.lua` +8 | 184 | 9.8KB | <span style="color:#f06040">道具</span> | 8 类道具注册表 API |
| `sv_import.lua` | 128 | 4.6KB | <span style="color:#3ca0f0">XGUI</span> | 旧数据导入面板 |
| `client.lua` | 286 | 17.3KB | <span style="color:#3ca0f0">XGUI</span> | 客户端设置 (语言/皮肤) |
| `layout.lua` | 101 | 3.5KB | <span style="color:#3ca0f0">XGUI</span> | 统一布局引擎 |
| `zh-cn.lua` | 1049 | 43.8KB | <span style="color:#e0a030">语言</span> | 简体中文 100% |
| `lzh.lua` | 1047 | 38.4KB | <span style="color:#e0a030">语言</span> | 文言文 100% |
| `ru.lua` | 1112 | 57.7KB | <span style="color:#e0a030">语言</span> | Русский 100% |
| `language.lua` | 92 | 2.3KB | <span style="color:#3ca0f0">共享</span> | 多语言框架 |
| `rngfix/` | 488 | 12.7KB | <span style="color:#b050e0">RNG</span> | 斜坡修正独立包 |

### <span style="color:#3ca0f0">显著增强</span>

| 文件 | 原版 | Ultra ULX | 增强内容 |
|:---:|:---:|:---:|:---|
| `sv_settings.lua` | ~600行 | <span style="color:#f06040">**1255行**</span> | MOTD生成+封禁消息+导入+mods扫描 |
| `sv_items.lua` | ~200行 | <span style="color:#f06040">**899行**</span> | 智能生成+碰撞自适应+挂墙+撤回 |
| `init.lua` | ~200行 | <span style="color:#f06040">**283行**</span> | 共存+旧数据+语言ConVar+道具+安全加载 |
| `cl_init.lua` | ~100行 | <span style="color:#f06040">**167行**</span> | 版本同步+导入弹窗+批量CSLuaFile |
| `ucl.lua` | ~1300行 | <span style="color:#f06040">**1595行**</span> | 备份30+恢复+DB管理+二次检测 |
| `data.lua` | ~300行 | <span style="color:#f06040">**503行**</span> | 中文化模板+详细注释+独立数据目录 |
| `defines.lua` | ~400行 | <span style="color:#f06040">**488行**</span> | 7色主题(加深40%)+版号格式 |
| `fun.lua` | ~800行 | <span style="color:#f06040">**1021行**</span> | unigniteall+playsound+sslay |
| `en.lua` | ~900行 | <span style="color:#f06040">**1131行**</span> | +200 翻译键 |
| `menus.lua` | ~100行 | <span style="color:#f06040">**156行**</span> | json+txt+gamemode三路扫描,无缓存 |

### <span style="color:#f06040">删除/合并</span>

| 操作 | 原指令 | 替代方案 |
|:---:|:---|:---|
| <span style="color:#f06040">合并</span> | `!bhopcss` `!bhopcancel` | → `!bhop` + `!unbhop` |
| <span style="color:#f06040">合并</span> | `!kickbots` | → `!bot` setOpposite |
| <span style="color:#f06040">合并</span> | `!undisguise` | → `!disguise` setOpposite |
| <span style="color:#f06040">合并</span> | `!undeafen` | → `!deafen` setOpposite |
| <span style="color:#f06040">合并</span> | `!unsilence` | → `!silence` setOpposite |
| <span style="color:#f06040">删除</span> | RNG-Fix 170行 | 移至独立 `rngfix` 包 |
| <span style="color:#f06040">删除</span> | moveCmds 48px 滑块 | 改用原版 `x_getcontrol` 35px |
| <span style="color:#f06040">删除</span> | makeStyledButton | 改用标准 `xlib.makebutton` |
| <span style="color:#f06040">删除</span> | MOTD 缓存 | `populateMotdData` 每次实时 |

---

## 架构

### <span style="color:#3ca0f0">6 层加载顺序</span>

```
Layer 0: autorun/init_ulx.lua (6行) → SERVER:include(ulx/init.lua) | CLIENT:include(ulx/cl_init.lua)
Layer 1: ULib 共享库 15 文件 → defines→misc→util→hook→tables→player→messages→commands
                              → sh_ucl→plugin→cami_global→cami_ulib→language
Layer 2: ULX 服务端 12 文件 → player→bans→concommand→srv_util→ucl→phys→player_ext
                              → entity_ext→data→ulx_defines→ulx_lib→ulx_command→ulx_base→log→end
Layer 3: 模块 22 文件 → sv:slots|uteam|votemap|xgui_server  sh:14 模块  cl:5 模块
Layer 4: 道具注册 9 文件 → init+8 分类注册表
Layer 5: XGUI 16 文件 → framework→bans→commands→groups→items→maps→settings
Layer 6: 语言 4 文件 → zh-cn|en|ru|lzh
```

### <span style="color:#e0a030">数据流</span>

```
聊天 !cmd → sayCmds → _u → routedCommandCallback → getCommandTableAndArgv 
    → cmds.execute → TranslateCommand 验证 → 回调 → fancyLogAdmin 回显

权限: ULib.ucl.query(ply, access) → allow/deny 用户表 → 组继承链 → CAMI

配置: doCfg() → 全局 → 按模式(叠加) → 按地图(叠加) → ULib.execStringULib(安全模式)

认证: PlayerAuthed → ucl.probe() → 匹配 users → SetUserGroup → UCLAuthed → 同步
```

---

## 模块手册

### <span style="color:#f06040">共享模块 (14 个)</span>

| 模块 | 行数 | 命令 | 核心功能 |
|:---:|:---:|:---:|:---|
| <span style="color:#f06040">community</span> | 815 | 30+ | rocket/color/halo/trail/ESP/deafen/silence/banip/bot/warn/disguise |
| <span style="color:#f06040">fun</span> | 1021 | 25 | slap/whip/slay/ignite/freeze/god/cloak/blind/jail/ragdoll/maul |
| <span style="color:#f06040">util</span> | 517 | 9 | kick/ban/unban/noclip/spectate/map/who/version |
| <span style="color:#f06040">vote</span> | 449 | 9 | vote/votemap2/votekick/voteban/stopvote/veto |
| <span style="color:#f06040">teleport</span> | 381 | 6 | bring(螺旋网格)/goto(碰撞检测)/send/tpto/teleport/return |
| <span style="color:#f06040">user</span> | 353 | 16 | adduser/removeuser/groupallow/renamegroup |
| <span style="color:#f06040">chat</span> | 321 | 9 | psay/asay/tsay/csay/thetime/gimp/mute/gag+广告 |
| <span style="color:#f06040">extras</span> | 224 | 6 | cleanup/respawn/scale/gravity+防落地抖动 |
| <span style="color:#f06040">coord</span> | 152 | 2 | coordhud 屏幕上方 + coord 头顶(4模式) |
| <span style="color:#f06040">crouchjump</span> | 166 | 1 | 倍率(1~10x)+蹲姿解锁+蹲走加速 |
| <span style="color:#f06040">bhop</span> | 109 | 1 | CS:S自动连跳(跑260/跳300/重力0.6) |
| <span style="color:#3ca0f0">menus</span> | 156 | 1 | MOTD(三路扫描,无缓存) |
| <span style="color:#f06040">rcon</span> | 120 | 5 | rcon/luarun/exec/cexec/ent |
| <span style="color:#f06040">userhelp</span> | 85 | 1 | 用户管理帮助 |

### <span style="color:#40c850">BHOP 参数 (CS:S 标准)</span>

| 参数 | 值 | 说明 |
|:---:|:---:|:---|
| sv_airaccelerate | 1000 | 空中加速度 |
| sv_enablebunnyhopping | 1 | 引擎连跳 |
| sv_staminamax | 0 | 关体力 |
| sv_maxvelocity | 3500 | 速限 |
| sv_accelerate | 10 | 地面加速 |
| sv_friction | 4 | 摩擦 |
| 跑速/走速 | 260/260 | 统一 |
| 跳跃力 | 300 | CS:S 标准 |
| 重力 | 0.6 | 更低=更高跳 |
| 步幅 | 18 | 标准 |

> 开 `!bhop` 保存原始物理并覆盖; 关 `!unbhop` 恢复。SetupMove 每帧保活。全局 cvar 首个启用设/全关恢复/ShutDown 兜底。

### <span style="color:#b050e0">蹲跳参数</span>

| 参数 | 默认 | 范围 |
|:---:|:---:|:---:|
| multiplier | 2.0 | 1.0~10.0 |
| crouchspeed | 1.5 | 1.0~5.0 |
| unlock | true | 蹲姿跳跃解锁 |

### <span style="color:#3ca0f0">坐标系统</span>

**coordhud** — 屏幕正上方 `X  Y  Z`, 半透明深底+青色大字  
**coord** — 目标头顶名字+坐标, 0.25s 刷新, 4 模式:

| 模式 | 可见范围 |
|:---:|:---|
| <span style="color:#40c850">1</span> | 仅目标自己 |
| <span style="color:#3ca0f0">2</span> | 管理员+ |
| <span style="color:#e0a030">3</span> | 全服公开 |
| <span style="color:#b050e0">4</span> | 指定玩家 (额外选择器) |

---

## <span style="color:#f06040">命令参考</span>

### 完整索引

| 分类 | 命令 |
|:---:|:---|
| <span style="color:#f06040">娱乐</span> | `!slap !whip !slay !sslay !ignite !playsound !freeze !god !hp !armor !cloak !blind !jail !jailtp !ragdoll !maul !strip !launch !rocket !explode !color !halo !trail !esp` |
| <span style="color:#3ca0f0">工具</span> | `!cleardecals !profile !redirect !stopsound !timescale !url !aliases !removeragdolls !cleanup !respawn !setmodel !setteam !giveweapon !scale !gravity !coordhud !coord !showtriggers` |
| <span style="color:#40c850">聊天</span> | `!p !psay @ !asay @@ !tsay @@@ !csay !thetime !gimp !mute !gag !rsay !deafen !silence` |
| <span style="color:#e0a030">移动</span> | `!jumppower !runspeed !walkspeed !speed !stepsize !bhop !crouchjump` |
| <span style="color:#b050e0">传送</span> | `!bring !goto !send !tp !teleport !tpto !return` |
| <span style="color:#f06040">投票</span> | `!vote !stopvote !votemap !votemap2 !votekick !voteban !veto !mapvote !gmvote` |
| <span style="color:#b050e0">管理</span> | `!kick !ban !unban !banid !noclip !spectate !map !who !version !resettodefaults !banip !bot !warn !disguise` |
| <span style="color:#a0a0a0">远程</span> | `ulx rcon !rcon ulx luarun ulx exec ulx cexec !cexec ulx ent` |
| <span style="color:#e0a030">菜单</span> | `!motd ulx motd` |

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
├── .import_*        ← 导入标记
├── gamemodes/<m>/   ← 按模式配置 (叠加)
└── maps/<m>/        ← 按地图配置 (叠加)
```

**优先级**: adverts/downloads/config → 三层叠加 · gimps/votemaps → 取最具体

**备份**: `data/ulib_backups/users_YYYYMMDD_HHMMSS.txt` (保留 30 个)

---

## 颜色主题

```lua
ULib.COLOR_ACCENT    = Color( 60, 160, 240 )  -- 主色调 (原版 151,211,255→加深40%)
ULib.COLOR_SUCCESS   = Color( 40, 200,  80 )  -- 成功
ULib.COLOR_WARN      = Color(220, 140,   0 )  -- 警告
ULib.COLOR_ERROR     = Color(220,  80,  30 )  -- 错误
ULib.COLOR_INFO      = Color(  0, 170, 220 )  -- 信息
ULib.COLOR_MUTED     = Color(160, 160, 170 )  -- 弱化
ULib.COLOR_HIGHLIGHT = Color(255, 180,   0 )  -- 高亮
```

---

## 关键机制

| 机制 | 实现 |
|:---|:---|
| <span style="color:#40c850">共存</span> | InitPostEntity 重注册覆盖, 数据目录独立, 删除即恢复 |
| <span style="color:#3ca0f0">同步</span> | 版本号比对 → 删本地 .lua → retry 重连 |
| <span style="color:#e0a030">零泄露</span> | BHOP cvar 首个启用设, 全关恢复, ShutDown 兜底, 非沙盒跳过 |
| <span style="color:#b050e0">无缓存</span> | MOTD populateMotdData 每次实时, addon.json+txt+gamemode 三路 |
| <span style="color:#f06040">安全加载</span> | 硬编码模块清单, pcall 包裹, 不跨 addon 扫描 |
| <span style="color:#40c850">导入</span> | 检测→标记→PlayerAuthed推送→Derma弹窗→XGUI面板 |

---

## 道具 API

```lua
ulx.registerItems(items, category)    -- 注册 ([{class,name,type,access}])
ulx.getItemsByCategory(filterPly)     -- 权限过滤获取
ulx.getAllItems()                     -- 全量
ulx.getItemAccess(classname)          -- 权限查询
```
类型: 1=永久无弹药 · 2=消耗品 · 3=武器+弹药 · 4=永久(有生成) · 5=纯实体 · 6=挂墙

---

<div align="center">

**Ultra ULX** v3.81 · [Team Ulysses](https://ulyssesmod.net) · 构建 2026.06.15

</div>
