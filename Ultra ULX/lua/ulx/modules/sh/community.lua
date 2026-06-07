-- 社区扩展命令模块 (基于 Timmy/ulx-commands + 社区常见扩展)
-- 分类: 娱乐 / 工具 / 聊天 / 移动 / 管理 / ESP
local CAT, CAT_T, CAT_C, CAT_M, CAT_A = "娱乐", "工具", "聊天", "移动", "管理"

if SERVER then -- Net 消息注册
	util.AddNetworkString("ulx_community_esp")
	util.AddNetworkString("ulx_community_halo")
	util.AddNetworkString("ulx_community_trail")
	util.AddNetworkString("ulx_community_thirdperson")
	util.AddNetworkString("ulx_community_toggleview")
	util.AddNetworkString("ulx_community_color")
	util.AddNetworkString("ulx_community_stopsound")
	util.AddNetworkString("ulx_community_url")
	util.AddNetworkString("ulx_community_deafen")
	util.AddNetworkString("ulx_community_silence")
	util.AddNetworkString("ulx_community_rocket")
	util.AddNetworkString("ulx_community_explode")
end

-- ===== 娱乐类 =====
if SERVER then
	function ulx.launch(calling_ply, target_plys, power)
		power = power or 500
		for _, ply in ipairs(target_plys) do
			if ply:Alive() and not ply:InVehicle() then
				ply:SetVelocity(Vector(0, 0, power))
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A 将 #T 弹射到空中", target_plys)
	end
end
local launchCmd = ulx.command(CAT, "ulx launch", ulx.launch, "!launch")
launchCmd:addParam{type=ULib.cmds.PlayersArg}
launchCmd:addParam{type=ULib.cmds.NumArg, min=100, max=5000, default=500, hint="力度", ULib.cmds.optional, ULib.cmds.round}
launchCmd:defaultAccess(ULib.ACCESS_ADMIN)
launchCmd:help("将目标弹射到空中。")

-- ===== Rocket (火箭发射) =====
if SERVER then
	function ulx.rocket(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			if ply:Alive() then
				net.Start("ulx_community_rocket")
				net.WriteEntity(ply)
				net.Broadcast()
				ply:SetVelocity(Vector(math.random(-200,200), math.random(-200,200), 800+math.random(0,400)))
				timer.Simple(0.1, function() if ply:IsValid() then ply:Ignite(5, 0) end end)
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A 将 #T 发射升空!", target_plys)
	end
end
local rocketCmd = ulx.command(CAT, "ulx rocket", ulx.rocket, "!rocket")
rocketCmd:addParam{type=ULib.cmds.PlayersArg}
rocketCmd:defaultAccess(ULib.ACCESS_ADMIN)
rocketCmd:help("将目标像火箭一样发射升空。")

-- ===== Explode (爆炸) =====
if SERVER then
	function ulx.explode(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			if ply:Alive() then
				local pos = ply:GetPos()
				local boom = ents.Create("env_explosion")
				boom:SetPos(pos)
				boom:SetOwner(calling_ply)
				boom:Spawn()
				boom:SetKeyValue("iMagnitude", "50")
				boom:Fire("Explode", 0, 0)
				ply:Kill()
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A 引爆了 #T", target_plys)
	end
end
local explodeCmd = ulx.command(CAT, "ulx explode", ulx.explode, "!explode")
explodeCmd:addParam{type=ULib.cmds.PlayersArg}
explodeCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
explodeCmd:help("引爆目标玩家。")

-- ===== Color (设置玩家颜色) =====
if SERVER then
	function ulx.color(calling_ply, target_plys, r, g, b)
		for _, ply in ipairs(target_plys) do
			ply:SetPlayerColor(Vector(r/255, g/255, b/255))
			net.Start("ulx_community_color")
			net.WriteEntity(ply)
			net.WriteUInt(r, 8)
			net.WriteUInt(g, 8)
			net.WriteUInt(b, 8)
			net.Broadcast()
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的颜色为 (#i,#i,#i)", target_plys, r, g, b)
	end
end
local colorCmd = ulx.command(CAT, "ulx color", ulx.color, "!color")
colorCmd:addParam{type=ULib.cmds.PlayersArg}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="红", ULib.cmds.round}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="绿", ULib.cmds.round}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="蓝", ULib.cmds.round}
colorCmd:defaultAccess(ULib.ACCESS_ADMIN)
colorCmd:help("设置目标玩家的渲染颜色(RGB)。")

-- ===== Halo (发光轮廓) =====
if SERVER then
	function ulx.halo(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_halo")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.Broadcast()
			ply:SetNWBool("ulx_has_halo", true)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 为目标 #T 添加了发光轮廓", target_plys)
	end
	function ulx.removehalo(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_halo")
			net.WriteEntity(ply)
			net.WriteBool(false)
			net.Broadcast()
			ply:SetNWBool("ulx_has_halo", false)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 移除了 #T 的发光轮廓", target_plys)
	end
end
local haloCmd = ulx.command(CAT, "ulx halo", ulx.halo, "!halo")
haloCmd:addParam{type=ULib.cmds.PlayersArg}
haloCmd:defaultAccess(ULib.ACCESS_ADMIN)
haloCmd:help("给目标玩家添加发光轮廓特效。")
local rhCmd = ulx.command(CAT, "ulx removehalo", ulx.removehalo, "!removehalo")
rhCmd:addParam{type=ULib.cmds.PlayersArg}
rhCmd:defaultAccess(ULib.ACCESS_ADMIN)
rhCmd:help("移除目标玩家的发光轮廓特效。")

-- ===== Trail (拖尾特效) =====
if SERVER then
	function ulx.trail(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_trail")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.Broadcast()
			ply:SetNWBool("ulx_has_trail", true)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 为目标 #T 添加了拖尾特效", target_plys)
	end
	function ulx.removetrail(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_trail")
			net.WriteEntity(ply)
			net.WriteBool(false)
			net.Broadcast()
			ply:SetNWBool("ulx_has_trail", false)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 移除了 #T 的拖尾特效", target_plys)
	end
end
local trailCmd = ulx.command(CAT, "ulx trail", ulx.trail, "!trail")
trailCmd:addParam{type=ULib.cmds.PlayersArg}
trailCmd:defaultAccess(ULib.ACCESS_ADMIN)
trailCmd:help("给目标玩家添加拖尾特效。")
local rtCmd = ulx.command(CAT, "ulx removetrail", ulx.removetrail, "!removetrail")
rtCmd:addParam{type=ULib.cmds.PlayersArg}
rtCmd:defaultAccess(ULib.ACCESS_ADMIN)
rtCmd:help("移除目标玩家的拖尾特效。")

-- ===== 工具类 =====

-- ===== ClearDecals (清除弹孔贴花) =====
if SERVER then
	function ulx.cleardecals(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			umsg.Start("ulx_cleardecals", ply)
			umsg.End()
		end
		ulx.fancyLogAdmin(calling_ply, "#A 清除了 #T 的弹孔贴花", target_plys)
	end
end
local cdCmd = ulx.command(CAT_T, "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cdCmd:addParam{type=ULib.cmds.PlayersArg}
cdCmd:defaultAccess(ULib.ACCESS_ADMIN)
cdCmd:help("清除目标客户端的所有子弹痕迹和贴花。")

-- ===== Profile (打开Steam资料) =====
function ulx.profile(calling_ply, target_ply)
	local sid64 = target_ply:SteamID64()
	if CLIENT then
		gui.OpenURL("https://steamcommunity.com/profiles/" .. sid64)
	end
end
local profileCmd = ulx.command(CAT_T, "ulx profile", ulx.profile, "!profile")
profileCmd:addParam{type=ULib.cmds.PlayerArg}
profileCmd:defaultAccess(ULib.ACCESS_ALL)
profileCmd:help("在Steam浏览器中打开目标的个人资料页。")

-- ===== Redirect (重定向到另一服务器) =====
if SERVER then
	function ulx.redirect(calling_ply, target_plys, hostname)
		for _, ply in ipairs(target_plys) do
			ply:ConCommand("connect " .. hostname)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 将 #T 重定向到服务器 #s", target_plys, hostname)
	end
end
local redirectCmd = ulx.command(CAT_T, "ulx redirect", ulx.redirect, "!redirect")
redirectCmd:addParam{type=ULib.cmds.PlayersArg}
redirectCmd:addParam{type=ULib.cmds.StringArg, hint="服务器IP:端口", ULib.cmds.takeRestOfLine}
redirectCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
redirectCmd:help("将目标重定向到另一个服务器。")

-- ===== StopSound (停止音效) =====
if SERVER then
	function ulx.stopsound(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_stopsound")
			net.Send(ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 停止了 #T 的所有音效", target_plys)
	end
end
local ssCmd = ulx.command(CAT_T, "ulx stopsound", ulx.stopsound, "!stopsound")
ssCmd:addParam{type=ULib.cmds.PlayersArg}
ssCmd:defaultAccess(ULib.ACCESS_ADMIN)
ssCmd:help("停止目标客户端的所有音效播放。")

-- ===== TimeScale (时间倍速) =====
if SERVER then
	function ulx.timescale(calling_ply, scale)
		scale = math.Clamp(scale, 0.01, 5)
		game.SetTimeScale(scale)
		ulx.fancyLogAdmin(calling_ply, "#A 将游戏时间倍速设为 #ix", _, scale)
	end
end
local tsCmd = ulx.command(CAT_T, "ulx timescale", ulx.timescale, "!timescale")
tsCmd:addParam{type=ULib.cmds.NumArg, min=0.01, max=5, default=1, hint="倍速"}
tsCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
tsCmd:help("设置游戏全局时间倍速(0.01~5, 慢动作~快进)。")

-- ===== URL (打开网页) =====
if SERVER then
	function ulx.url(calling_ply, target_plys, weburl)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_url")
			net.WriteString(weburl)
			net.Send(ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 对 #T 打开了网页", target_plys)
	end
end
local urlCmd = ulx.command(CAT_T, "ulx url", ulx.url, "!url")
urlCmd:addParam{type=ULib.cmds.PlayersArg}
urlCmd:addParam{type=ULib.cmds.StringArg, hint="网址", ULib.cmds.takeRestOfLine}
urlCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
urlCmd:help("在目标客户端打开指定网页。")

-- ===== Aliases (查看别名) =====
if SERVER then
	function ulx.aliases(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			ULib.console(calling_ply, ply:Nick() .. " <" .. ply:SteamID() .. ">")
			ULib.console(calling_ply, "  UniqueID: " .. ply:UniqueID())
			ULib.console(calling_ply, "  IP: " .. ply:IPAddress())
		end
		ulx.fancyLogAdmin(calling_ply, "#A 查看了 #T 的身份信息", target_plys)
	end
end
local aliasesCmd = ulx.command(CAT_T, "ulx aliases", ulx.aliases, "!aliases")
aliasesCmd:addParam{type=ULib.cmds.PlayersArg}
aliasesCmd:defaultAccess(ULib.ACCESS_ADMIN)
aliasesCmd:help("查看目标玩家的身份标识信息。")

-- ===== RemoveRagdolls (移除布娃娃) =====
if SERVER then
	function ulx.removeragdolls(calling_ply)
		local ragdolls = ents.FindByClass("prop_ragdoll")
		for _, rag in ipairs(ragdolls) do
			if rag:IsValid() then rag:Remove() end
		end
		ulx.fancyLogAdmin(calling_ply, "#A 清除了所有可见的布娃娃")
	end
end
local rrCmd = ulx.command(CAT_T, "ulx removeragdolls", ulx.removeragdolls, "!removeragdolls")
rrCmd:defaultAccess(ULib.ACCESS_ADMIN)
rrCmd:help("清除所有客户端布娃娃实体。")

-- ===== 聊天类 =====

-- ===== Deafen (完全屏蔽) =====
if SERVER then
	function ulx.deafen(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_deafen")
			net.WriteBool(true)
			net.Send(ply)
			ply:SetNWBool("ulx_deafened", true)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 屏蔽了 #T 的聊天和语音", target_plys)
	end
	function ulx.undeafen(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_deafen")
			net.WriteBool(false)
			net.Send(ply)
			ply:SetNWBool("ulx_deafened", false)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 解除了 #T 的聊天语音屏蔽", target_plys)
	end
end
local deafenCmd = ulx.command(CAT_C, "ulx deafen", ulx.deafen, "!deafen")
deafenCmd:addParam{type=ULib.cmds.PlayersArg}
deafenCmd:defaultAccess(ULib.ACCESS_ADMIN)
deafenCmd:help("使目标完全看不到也听不到聊天。")
local udeafenCmd = ulx.command(CAT_C, "ulx undeafen", ulx.undeafen, "!undeafen")
udeafenCmd:addParam{type=ULib.cmds.PlayersArg}
udeafenCmd:defaultAccess(ULib.ACCESS_ADMIN)
udeafenCmd:help("解除目标的聊天语音屏蔽状态。")

-- ===== RSay (彩色广播) - 共享域(CLIENT+SERVER皆可用) =====
function ulx.rsay(calling_ply, message)
	local colors = {
		Color(255,100,100), Color(100,255,100), Color(100,100,255),
		Color(255,255,100), Color(255,100,255), Color(100,255,255),
	}
	if SERVER then
		for _, ply in ipairs(player.GetAll()) do
			ULib.tsayColor(ply, true, colors[math.random(#colors)], message)
		end
	else
		chat.AddText(colors[math.random(#colors)], message)
	end
end
local rsayCmd = ulx.command(CAT_C, "ulx rsay", ulx.rsay, "§", true, true)
rsayCmd:addParam{type=ULib.cmds.StringArg, hint="消息", ULib.cmds.takeRestOfLine}
rsayCmd:defaultAccess(ULib.ACCESS_ADMIN)
rsayCmd:help("向所有人发送彩色广播消息。")

-- ===== Silence (完全禁言禁语音) =====
if SERVER then
	function ulx.silence(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			ply:SetNWBool("ulx_silenced", true)
			net.Start("ulx_community_silence")
			net.WriteBool(true)
			net.Send(ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 禁言了 #T (聊天+语音)", target_plys)
	end
	function ulx.unsilence(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			ply:SetNWBool("ulx_silenced", false)
			net.Start("ulx_community_silence")
			net.WriteBool(false)
			net.Send(ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 解除了 #T 的禁言状态", target_plys)
	end
end
local silenceCmd = ulx.command(CAT_C, "ulx silence", ulx.silence, "!silence")
silenceCmd:addParam{type=ULib.cmds.PlayersArg}
silenceCmd:defaultAccess(ULib.ACCESS_ADMIN)
silenceCmd:help("完全禁止目标说话和聊天。")
local unsilenceCmd = ulx.command(CAT_C, "ulx unsilence", ulx.unsilence, "!unsilence")
unsilenceCmd:addParam{type=ULib.cmds.PlayersArg}
unsilenceCmd:defaultAccess(ULib.ACCESS_ADMIN)
unsilenceCmd:help("解除目标的完全禁言状态。")

-- ===== 移动类 =====

-- ===== JumpPower (跳跃力) =====
if SERVER then
	function ulx.jumppower(calling_ply, target_plys, power)
		power = math.Clamp(power, 0, 1000)
		for _, ply in ipairs(target_plys) do
			ply:SetJumpPower(power)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的跳跃力为 #i", target_plys, power)
	end
end
local jpCmd = ulx.command(CAT_M, "ulx jumppower", ulx.jumppower, "!jumppower")
jpCmd:addParam{type=ULib.cmds.PlayersArg}
jpCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, default=200, hint="力度", ULib.cmds.round}
jpCmd:defaultAccess(ULib.ACCESS_ADMIN)
jpCmd:help("设置目标玩家的跳跃力。")

-- ===== RunSpeed (奔跑速度) =====
if SERVER then
	function ulx.runspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed, 0, 1000)
		for _, ply in ipairs(target_plys) do
			ply:SetRunSpeed(speed)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的奔跑速度为 #i", target_plys, speed)
	end
end
local rsCmd = ulx.command(CAT_M, "ulx runspeed", ulx.runspeed, "!runspeed")
rsCmd:addParam{type=ULib.cmds.PlayersArg}
rsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, default=400, hint="速度", ULib.cmds.round}
rsCmd:defaultAccess(ULib.ACCESS_ADMIN)
rsCmd:help("设置目标玩家的奔跑速度。")

-- ===== WalkSpeed (行走速度) =====
if SERVER then
	function ulx.walkspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed, 0, 1000)
		for _, ply in ipairs(target_plys) do
			ply:SetWalkSpeed(speed)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的行走速度为 #i", target_plys, speed)
	end
end
local wsCmd = ulx.command(CAT_M, "ulx walkspeed", ulx.walkspeed, "!walkspeed")
wsCmd:addParam{type=ULib.cmds.PlayersArg}
wsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, default=200, hint="速度", ULib.cmds.round}
wsCmd:defaultAccess(ULib.ACCESS_ADMIN)
wsCmd:help("设置目标玩家的行走速度。")

-- ===== Speed (统一设置行走+奔跑速度) =====
if SERVER then
	function ulx.speed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed, 0, 1000)
		for _, ply in ipairs(target_plys) do
			ply:SetWalkSpeed(speed)
			ply:SetRunSpeed(speed * 1.25)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的移动速度为 #i", target_plys, speed)
	end
end
local speedCmd = ulx.command(CAT_M, "ulx speed", ulx.speed, "!speed")
speedCmd:addParam{type=ULib.cmds.PlayersArg}
speedCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, default=250, hint="速度", ULib.cmds.round}
speedCmd:defaultAccess(ULib.ACCESS_ADMIN)
speedCmd:help("统一设置目标玩家的行走和奔跑速度。")

-- ===== StepSize (跨步高度) =====
if SERVER then
	function ulx.stepsize(calling_ply, target_plys, stepsize)
		stepsize = math.Clamp(stepsize, 0, 100)
		for _, ply in ipairs(target_plys) do
			ply:SetStepSize(stepsize)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的跨步高度为 #i", target_plys, stepsize)
	end
end
local ssCmd = ulx.command(CAT_M, "ulx stepsize", ulx.stepsize, "!stepsize")
ssCmd:addParam{type=ULib.cmds.PlayersArg}
ssCmd:addParam{type=ULib.cmds.NumArg, min=0, max=100, default=18, hint="高度", ULib.cmds.round}
ssCmd:defaultAccess(ULib.ACCESS_ADMIN)
ssCmd:help("设置目标玩家的最大跨步高度。")

-- ===== 视角类 =====

-- ===== ViewToggle (第一/三人称切换) =====
if SERVER then
	function ulx.toggleview(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_toggleview")
			net.Send(ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 切换了 #T 的视角", target_plys)
	end
end
local viewCmd = ulx.command(CAT_T, "ulx view", ulx.toggleview, "!view")
viewCmd:addParam{type=ULib.cmds.PlayersArg}
viewCmd:defaultAccess(ULib.ACCESS_ADMIN)
viewCmd:help("切换目标的第一/第三人称视角。")

-- ===== 管理类 =====

-- ===== BanIP (封禁IP) =====
if SERVER then
	function ulx.banip(calling_ply, ip, minutes, reason)
		minutes = minutes or 0
		local name = "<IP封禁>"
		ULib.addBan(ip, minutes, reason, name, calling_ply)
		ulx.fancyLogAdmin(calling_ply, "#A 封禁了 IP #s", ip)
	end
end
local banipCmd = ulx.command(CAT_A, "ulx banip", ulx.banip, "!banip")
banipCmd:addParam{type=ULib.cmds.StringArg, hint="IP地址"}
banipCmd:addParam{type=ULib.cmds.NumArg, min=0, default=0, hint="分钟,0=永久", ULib.cmds.optional, ULib.cmds.allowTimeString}
banipCmd:addParam{type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
banipCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
banipCmd:help("通过IP地址封禁玩家。")

-- ===== Bot (生成BOT) + KickBots =====
if SERVER then
	function ulx.bot(calling_ply, amount)
		amount = math.Clamp(amount, 1, 32)
		local success = 0
		for i = 1, amount do
			game.ConsoleCommand("bot\n")
			success = success + 1
		end
		if success > 0 then
			ulx.fancyLogAdmin(calling_ply, "#A 生成了 #i 个BOT", success)
		else
			ULib.tsayError(calling_ply, "无法生成BOT，当前游戏模式可能不支持。", true)
		end
	end
	function ulx.kickbots(calling_ply)
		local count = 0
		for _, ply in ipairs(player.GetAll()) do
			if ply:IsBot() then
				ply:Kick("BOT已被管理员移除")
				count = count + 1
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A 移除了 #i 个BOT", count)
	end
end
local botCmd = ulx.command(CAT_A, "ulx bot", ulx.bot, "!bot")
botCmd:addParam{type=ULib.cmds.NumArg, min=1, max=32, default=1, hint="数量", ULib.cmds.round, ULib.cmds.optional}
botCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
botCmd:help("生成指定数量的BOT玩家。")
local kbCmd = ulx.command(CAT_A, "ulx kickbots", ulx.kickbots, "!kickbots")
kbCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
kbCmd:help("移除所有BOT玩家。")

-- ===== Warn (警告系统) =====
if SERVER then
	ulx.warns = ulx.warns or {}
	function ulx.warn(calling_ply, target_ply, reason)
		local sid = target_ply:SteamID()
		ulx.warns[sid] = (ulx.warns[sid] or 0) + 1
		local count = ulx.warns[sid]
		ULib.tsayError(target_ply, "你已被管理员警告! (" .. count .. "/3) 原因: " .. (reason or "未指定"), true)
		ulx.fancyLogAdmin(calling_ply, "#A 警告了 #T (#i/3) 原因: #s", target_ply, count, reason or "未指定")
		if count >= 3 then
			ULib.kickban(target_ply, 60, "累计3次警告自动封禁1小时", calling_ply)
			ulx.warns[sid] = 0
			ulx.fancyLogAdmin(calling_ply, "#A 的警告触发自动封禁: #T (3次警告)", target_ply)
		end
	end
	function ulx.unwarn(calling_ply, target_ply)
		local sid = target_ply:SteamID()
		ulx.warns[sid] = math.max(0, (ulx.warns[sid] or 0) - 1)
		ulx.fancyLogAdmin(calling_ply, "#A 撤销了 #T 的一次警告 (剩余 #i 次)", target_ply, ulx.warns[sid])
	end
end
local warnCmd = ulx.command(CAT_A, "ulx warn", ulx.warn, "!warn")
warnCmd:addParam{type=ULib.cmds.PlayerArg}
warnCmd:addParam{type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
warnCmd:defaultAccess(ULib.ACCESS_ADMIN)
warnCmd:help("警告目标玩家。累计3次自动封禁1小时。")
local uwCmd = ulx.command(CAT_A, "ulx unwarn", ulx.unwarn, "!unwarn")
uwCmd:addParam{type=ULib.cmds.PlayerArg}
uwCmd:defaultAccess(ULib.ACCESS_ADMIN)
uwCmd:help("撤销目标玩家的一次警告记录。")

-- ===== Disguise (伪装) =====
if SERVER then
	function ulx.disguise(calling_ply, target_ply, disguise_target)
		if not disguise_target:IsValid() then
			ULib.tsayError(calling_ply, "伪装目标无效。", true)
			return
		end
		local oldName = target_ply:Nick()
		target_ply:SetName(disguise_target:Nick())
		ulx.fancyLogAdmin(calling_ply, "#A 将 #T 伪装成了目标玩家", target_ply)
	end
end
local disguiseCmd = ulx.command(CAT_A, "ulx disguise", ulx.disguise, "!disguise")
disguiseCmd:addParam{type=ULib.cmds.PlayerArg}
disguiseCmd:addParam{type=ULib.cmds.PlayerArg, hint="伪装目标"}
disguiseCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
disguiseCmd:help("将目标伪装成另一个玩家的名字(娱乐用途)。")

-- ===== ESP 透视 =====
if SERVER then
	function ulx.esp(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_esp")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.Send(calling_ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 开启了 #T 的透视", target_plys)
	end
	function ulx.unesp(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_esp")
			net.WriteEntity(ply)
			net.WriteBool(false)
			net.Send(calling_ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 关闭了 #T 的透视", target_plys)
	end
end
local espCmd = ulx.command(CAT, "ulx esp", ulx.esp, "!esp")
espCmd:addParam{type=ULib.cmds.PlayersArg}
espCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
espCmd:help("开启目标玩家的透视效果(显示名称/血量/距离/用户组)。")
local unespCmd = ulx.command(CAT, "ulx unesp", ulx.unesp, "!unesp")
unespCmd:addParam{type=ULib.cmds.PlayersArg}
unespCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
unespCmd:help("关闭目标玩家的透视效果。")

if CLIENT then
	local espTargets = {}

	local function espDraw()
		local lp = LocalPlayer()
		if not lp:IsValid() then return end
		for ent, _ in pairs(espTargets) do
			if not ent:IsValid() or not ent:Alive() then
				espTargets[ent] = nil
			else
				local pos = ent:GetPos() + Vector(0, 0, 72)
				local sp = pos:ToScreen()
				if sp.visible then
					local dist = math.floor(lp:GetPos():Distance(pos) / 50)
					local alpha = math.Clamp(255 - dist * 2, 40, 255)
					local hp, arm, grp = ent:Health(), ent:Armor(), ent:GetUserGroup()
					local color = grp == "superadmin" and Color(255, 50, 50, alpha) or grp == "admin" and Color(50, 150, 255, alpha) or Color(255, 200, 0, alpha)
					surface.SetFont("Default")
					local text = ent:Nick() .. " [" .. hp .. "HP" .. (arm > 0 and " " .. arm .. "AP" or "") .. "] " .. dist .. "m"
					local tw, th = surface.GetTextSize(text)
					local x, y = sp.x - tw / 2, sp.y - th - 4
					draw.RoundedBox(4, x - 4, y - 6, tw + 8, th + 12, Color(0, 0, 0, alpha * 0.6))
					surface.SetTextPos(x, y)
					surface.SetTextColor(color)
					surface.DrawText(text)
					draw.RoundedBox(0, x, sp.y + 2, tw, 3, Color(50, 50, 50, alpha))
					draw.RoundedBox(0, x, sp.y + 2, tw * (hp / 100), 3, Color(0, 200, 0, alpha))
				end
			end
		end
	end
	hook.Add("HUDPaint", "ULXCommunityESP", espDraw)

	net.Receive("ulx_community_esp", function()
		local ent = net.ReadEntity()
		if net.ReadBool() then espTargets[ent] = true else espTargets[ent] = nil end
	end)

	-- 第三人称相机
	local function thirdPersonCam(ply, pos, angles, fov)
		local dist = 100 * math.max(ulx_playerscale or 1, 1)
		local trace = util.TraceHull({start=pos, endpos=pos - angles:Forward() * dist, filter=ply, mins=Vector(-4,-4,-4), maxs=Vector(4,4,4)})
		local view = {angles=angles, fov=fov, origin=trace.Hit and trace.HitPos + trace.HitNormal * 4 or pos - angles:Forward() * dist}
		return view
	end

	local function toggleThirdPerson()
		if hook.GetTable().ShouldDrawLocalPlayer and hook.GetTable().ShouldDrawLocalPlayer.ULXThirdPerson then
			hook.Remove("ShouldDrawLocalPlayer", "ULXThirdPerson")
			hook.Remove("CalcView", "ULXThirdPersonCam")
		else
			hook.Add("ShouldDrawLocalPlayer", "ULXThirdPerson", function() return true end)
			hook.Add("CalcView", "ULXThirdPersonCam", thirdPersonCam)
		end
	end

	net.Receive("ulx_community_stopsound", function() RunConsoleCommand("stopsound") end)
	net.Receive("ulx_community_url", function() gui.OpenURL(net.ReadString()) end)
	net.Receive("ulx_community_thirdperson", function()
		if net.ReadBool() then
			hook.Add("ShouldDrawLocalPlayer", "ULXThirdPerson", function() return true end)
			hook.Add("CalcView", "ULXThirdPersonCam", thirdPersonCam)
		else
			hook.Remove("ShouldDrawLocalPlayer", "ULXThirdPerson")
			hook.Remove("CalcView", "ULXThirdPersonCam")
		end
	end)
	net.Receive("ulx_community_toggleview", toggleThirdPerson)
	net.Receive("ulx_community_halo", function()
		local ent, enable = net.ReadEntity(), net.ReadBool()
		if enable and ent:IsValid() then halo.Add({ent}, Color(255, 215, 0), 2, 2, 1, true, false) end
	end)
	net.Receive("ulx_community_color", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then ent:SetColor(Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))) end
	end)
	hook.Add("OnPlayerChat", "ULXDeafenCheck", function(ply) if LocalPlayer():GetNWBool("ulx_deafened") then return true end end)
	hook.Add("PlayerSay", "ULXSilenceCheck", function(ply)
		if ply == LocalPlayer() and ply:GetNWBool("ulx_silenced") then
			chat.AddText(Color(255,100,100), "[ULX] 你已被禁言,无法发送消息。")
			return ""
		end
	end)
	hook.Add("PlayerCanHearPlayersVoice", "ULXSilenceVoiceCheck", function(listener, talker)
		if talker:GetNWBool("ulx_silenced") then return false end
	end)
end

Msg("[ULX] 社区扩展模块已加载 (30+ 命令)\n")
