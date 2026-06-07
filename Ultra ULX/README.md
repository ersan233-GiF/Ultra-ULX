# Ultra ULX — 终极 ULX 管理插件

> **ULX 3.81 + ULib 2.72** | 合并优化版 | 三语支持 | 开箱即用 | 2026.06

将 ULX 管理插件与 ULib 开发库合并为单一 addon。内置简体中文/English/Русский 三语实时切换、XGUI 图形化管理面板、30+ 社区扩展命令、SQLite 用户存储。所有权限经安全审计优化，superadmin 可灵活向下委派；标签页语言切换无跳转无遮挡。

---

## 快速开始

> ⚠️ **重要**：Ultra ULX 已内置 ULib，**安装前请先删除** `garrysmod/addons/ulx` 和 `garrysmod/addons/ulib`，否则会导致冲突和认证错误！

1. 删除旧的 ULX/ULib 插件（如已安装）
2. 将 `Ultra ULX` 放入 `garrysmod/addons/`
3. 重启服务器（不能只换图）
4. 服务端控制台：`ulx adduser <你的SteamID> superadmin`
5. 游戏中按 `!menu` 打开管理面板

---

## 模块结构

```
Ultra ULX/lua/
├── autorun/init.lua                # GMod 自动加载入口
└── ulx/
    ├── shared/                     # ULib 共享库
    │   ├── defines/hook/commands   # 核心框架
    │   ├── messages/player/util    # 消息/玩家/工具
    │   ├── language.lua            # 多语言系统
    │   └── sh_ucl.lua              # UCL 访问控制
    ├── server/                     # ULib 服务端
    │   ├── ucl.lua                 # 用户组管理 + SQLite 存储
    │   ├── bans/player/phys        # 封禁/玩家/物理
    │   └── log.lua                 # 日志系统
    ├── client/                     # ULib 客户端
    │   └── cl_util/draw            # cvar 同步/屏幕绘制
    ├── modules/
    │   ├── sh/                     # 共用命令 (chat/fun/teleport/vote/util/rcon/extras/community)
    │   ├── cl/                     # 客户端 (xgui_client/helpers/xlib/motdmenu)
    │   └── sv/                     # 服务端 (slots/uteam/xgui_server)
    ├── xgui/                       # 图形管理界面
    │   ├── commands/groups/bans    # 命令/用户组/封禁面板
    │   ├── maps/items/ai_bot       # 地图/道具/AI Bot 面板
    │   ├── settings/               # 设置 + 子模块
    │   └── server/sv_*.lua         # 服务端逻辑
    └── language/
        ├── zh-cn.lua               # 简体中文 (859 键)
        ├── en.lua                  # English (859 键)
        └── ru.lua                  # Русский (859 键)
```

---

## 命令速查

| 分类 | 常用命令 |
|------|----------|
| **管理** | `!kick` `!ban` `!kickban` `!adduser` `!removeuser` `!groupallow` |
| **娱乐** | `!slap` `!slay` `!ignite` `!freeze` `!god` `!cloak` `!blind` `!jail` `!ragdoll` `!strip` |
| | `!launch` `!rocket` `!explode` `!whip` `!halo` `!trail` `!color` `!esp` |
| **聊天** | `!p` `@` `@@` `!gimp` `!mute` `!gag` `!deafen` `!silence` `§` |
| **传送** | `!goto` `!bring` `!send` `!teleport` `!return` `!tpto` |
| **工具** | `!noclip` `!hp` `!armor` `!cleanup` `!respawn` `!stopsound` `!timescale` |
| **移动** | `!speed` `!runspeed` `!walkspeed` `!jumppower` `!stepsize` `!view` |
| **投票** | `!vote` `!votekick` `!voteban` `!votemap` `!veto` `!stopvote` |
| **远程** | `!rcon` `!luarun` `!cexec` `!ent` `!exec` |
| **用户** | `ulx adduser/removeuser/userallow/groupallow/addgroup/removegroup` |

---

## 关键特性

| 特性 | 说明 |
|------|------|
| **三语实时切换** | zh-cn / en / ru，共 859 键完全同步，切换不跳标签、不重建界面 |
| **XGUI 管理面板** | 命令/用户组/封禁/地图/道具/AI Bot/设置 七大面板 |
| **SQLite 用户存储** | 替代传统 users.txt，启动自动备份 + 命令行恢复 |
| **UCL 权限系统** | 基于继承的组权限，支持 allow/deny 列表和免疫机制 |
| **道具系统** | 85+ 道具中英俄三语，5 种类型，座椅/载具支持变体键独立翻译 |
| **社区扩展** | 30+ 命令：火箭/爆炸/光晕/拖尾/ESP 透视/变速/弹射/伪装/警告 |
| **批量 Cvar 同步** | 压缩分包传输，2560 字节分片，解决网络消息大小限制 |
| **noclip 增强** | 自动上帝模式 + 隐身 + NoTarget + 碰撞关闭，退出自动恢复 |
| **点击外部关闭** | 可配置的窗口外点击关闭，带溢出空间容差 |

---

## 多语言

| 语言 | 代码 | 翻译键 | 切换方式 |
|------|------|--------|----------|
| 简体中文 | `zh-cn` | 859 | 默认语言 |
| English | `en` | 859 | 设置 → 通用 → 语言下拉 |
| Русский | `ru` | 859 | 控制台 `ulx_lang ru` |

三语文件键名完全一致，零缺失。切换时标签页保持不动，所有文本即时刷新。

---

## 用户管理

```lua
-- 添加超管
ulx adduser STEAM_0:1:12345678 superadmin

-- 移除用户
ulx removeuser STEAM_0:1:12345678

-- 允许操作员使用 ban 命令
ulx groupallow operator "ulx ban"

-- 备份/恢复用户数据（SQLite）
ucl_backup_users              -- 手动备份
ucl_restore_users latest      -- 恢复最新备份
ucl_drop_users_db CONFIRM     -- 删除数据库（回退到 users.txt）
```

---

## 开发者 API

```lua
-- 注册新命令
local myCmd = ulx.command("工具", "ulx mycmd", function(ply, targets)
    ulx.fancyLogAdmin(ply, "#A 对 #T 执行了操作", targets)
end, "!mycmd")
myCmd:addParam{type=ULib.cmds.PlayersArg}
myCmd:defaultAccess(ULib.ACCESS_ADMIN)
myCmd:help("命令说明。")
```

```lua
-- 多语言翻译
ULib.ulx_lang.T("key_name")                  -- 简单翻译
ULib.ulx_lang.T("key_format", arg1, arg2)    -- 格式化翻译

-- 权限查询
ULib.ucl.query(ply, "ulx ban")

-- 注册新访问权限
ULib.ucl.registerAccess("my_access", ULib.ACCESS_ADMIN, "描述", "Other")
```

---

## 权限级别

| 级别 | 常量 | 命令数 | 说明 |
|------|------|--------|------|
| `user` | `ULib.ACCESS_ALL` | 9 | 信息查询 + 聊天 + 投票 |
| `operator` | `ULib.ACCESS_OPERATOR` | 10 | user 权限 + 查看管理员消息回显 |
| `admin` | `ULib.ACCESS_ADMIN` | ~60 | 标准管理：踢人/封禁/禁言/娱乐/传送 |
| `superadmin` | `ULib.ACCESS_SUPERADMIN` | ~90 | 全部命令：用户管理/Rcon/Lua/换图/远程控制 |

权限继承链：`superadmin → admin → operator → user`。deny 优先于 allow，低级别默认不能管理高级别（can_target 免疫）。

> **委派示例**：superadmin 可随时用 `ulx groupallow admin "ulx map"` 将换图权下放给 admin，或用 `ulx groupdeny` 收回。

---

## 部署后生成的文件

首次启动服务器后，以下目录和文件会自动创建（已通过 `.gitignore` 排除，不会提交到仓库）：

```
garrysmod/
├── sv.db                           # SQLite 用户数据库（ulib_users 表）
└── data/
    ├── ulx/
    │   ├── config.txt              # 全局 cvar 配置
    │   ├── language.txt            # 客户端语言选择缓存
    │   ├── xgui_settings.txt       # XGUI 客户端设置
    │   ├── adverts.txt             # 广告轮播配置
    │   ├── banmessage.txt          # 封禁消息模板
    │   ├── banreasons.txt          # 封禁原因列表
    │   ├── downloads.txt           # 强制下载文件列表
    │   ├── gimps.txt               # 限制聊天语句
    │   ├── motd.txt                # MOTD 消息内容
    │   ├── votemaps.txt            # 投票地图列表
    │   ├── gamemodes/<mode>/       # 游戏模式级配置覆盖
    │   └── maps/<map>/             # 地图级配置覆盖
    ├── ulib/
    │   ├── groups.txt              # 用户组定义（KeyValues）
    │   └── misc_registered.txt     # 已注册的访问权限
    ├── ulx_logs/                   # 日志目录（按日期命名）
    └── ulib_backups/               # 用户数据备份（SQLite，保留 30 份）
```

### 配置文件层级

```
config.txt (全局)
  ↓ 覆盖
gamemodes/<gamemode>/config.txt (游戏模式)
  ↓ 覆盖
maps/<mapname>/config.txt (单张地图)
```

---

## 致谢

- [ULX](https://github.com/TeamUlysses/ulx) / [ULib](https://github.com/TeamUlysses/ulib) — Team Ulysses 原创项目
- [ulx_simplified_chinese](https://github.com/sbzlzh/ulx_simplified_chinese) — 中文优化参考
- **Stickly Man!** — XGUI 原创作者
- 社区扩展参考 Timmy/ulx-commands 及 GMod 社区

> **官网**: [ulyssesmod.net](https://ulyssesmod.net) &nbsp;|&nbsp; **原始仓库**: [github.com/TeamUlysses](https://github.com/TeamUlysses)
