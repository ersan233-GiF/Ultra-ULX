local CAT, CAT_T, CAT_C, CAT_M, CAT_A = "娱乐", "工具", "聊天", "移动", "管理"
if SERVER then
	util.AddNetworkString("ulx_community_esp")
	util.AddNetworkString("ulx_coord_display")
	util.AddNetworkString("ulx_coord_data")
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
	util.AddNetworkString("ulx_community_cleardecals")
end
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
launchCmd:help( "将目标弹射到空中" )
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
rocketCmd:help( "将目标像火箭一样发射升空" )
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
explodeCmd:help( "引爆目标玩家" )
if SERVER then
	local playerColors = {}
	local function applyColor( ply, vec )
		ply:SetPlayerColor( vec )
		net.Start("ulx_community_color")
		net.WriteEntity(ply); net.WriteUInt(vec.x*255,8); net.WriteUInt(vec.y*255,8); net.WriteUInt(vec.z*255,8)
		net.Broadcast()
	end
	function ulx.color(calling_ply, target_plys, r, g, b)
		for _, ply in ipairs(target_plys) do
			local vec = Vector(r/255, g/255, b/255)
			if r == 255 and g == 255 and b == 255 then
				playerColors[ply] = nil
			else
				playerColors[ply] = vec
			end
			applyColor(ply, vec)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的颜色为 (#i,#i,#i)", target_plys, r, g, b)
	end
	hook.Add("PlayerSpawn", "ULX_ColorRestore", function(ply)
		if playerColors[ply] then
			timer.Simple(0.15, function() if IsValid(ply) then applyColor(ply, playerColors[ply]) end end)
		end
	end)
	hook.Add("PlayerHurt", "ULX_ColorRestore", function(ply)
		if playerColors[ply] then
			timer.Simple(0.05, function() if IsValid(ply) then applyColor(ply, playerColors[ply]) end end)
		end
	end)
	hook.Add("PlayerDisconnected", "ULX_ColorCleanup", function(ply)
		playerColors[ply] = nil
	end)
end
local colorCmd = ulx.command(CAT, "ulx color", ulx.color, "!color")
colorCmd:addParam{type=ULib.cmds.PlayersArg}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="红", ULib.cmds.round}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="绿", ULib.cmds.round}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="蓝", ULib.cmds.round}
colorCmd:defaultAccess(ULib.ACCESS_ADMIN)
colorCmd:help( "设置目标玩家的渲染颜色 RGB" )
if SERVER then
	function ulx.halo(calling_ply, target_plys, should_remove)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_halo")
			net.WriteEntity(ply)
			net.WriteBool(not should_remove)
			net.Broadcast()
			ply:SetNWBool("ulx_has_halo", not should_remove)
		end
		if should_remove then
			ulx.fancyLogAdmin(calling_ply, "#A 移除了 #T 的发光轮廓", target_plys)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 为目标 #T 添加了发光轮廓", target_plys)
		end
	end
end
local haloCmd = ulx.command(CAT, "ulx halo", ulx.halo, "!halo")
haloCmd:addParam{type=ULib.cmds.PlayersArg}
haloCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
haloCmd:defaultAccess(ULib.ACCESS_ADMIN)
haloCmd:help( "切换目标发光轮廓，!removehalo 关闭" )
haloCmd:setOpposite("ulx removehalo", {_, _, true}, "!removehalo")
if SERVER then
	function ulx.trail(calling_ply, target_plys, should_remove)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_trail")
			net.WriteEntity(ply)
			net.WriteBool(not should_remove)
			net.Broadcast()
			ply:SetNWBool("ulx_has_trail", not should_remove)
		end
		if should_remove then
			ulx.fancyLogAdmin(calling_ply, "#A 移除了 #T 的拖尾特效", target_plys)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 为目标 #T 添加了拖尾特效", target_plys)
		end
	end
end
local trailCmd = ulx.command(CAT, "ulx trail", ulx.trail, "!trail")
trailCmd:addParam{type=ULib.cmds.PlayersArg}
trailCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
trailCmd:defaultAccess(ULib.ACCESS_ADMIN)
trailCmd:help( "切换目标拖尾特效，!removetrail 关闭" )
trailCmd:setOpposite("ulx removetrail", {_, _, true}, "!removetrail")
if SERVER then
	function ulx.cleardecals(calling_ply, target_plys)
				for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_cleardecals")
			net.Send(ply)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 清除了 #T 的弹孔贴花", target_plys)
	end
end
local cdCmd = ulx.command(CAT_T, "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cdCmd:addParam{type=ULib.cmds.PlayersArg}
cdCmd:defaultAccess(ULib.ACCESS_ADMIN)
cdCmd:help( "清除目标客户端的弹孔和贴花" )
function ulx.profile(calling_ply, target_ply)
	local sid64 = target_ply:SteamID64()
	if SERVER then
		net.Start("ulx_community_profile")
		net.WriteString(sid64)
		net.Send(calling_ply)
	end
end
local profileCmd = ulx.command(CAT_T, "ulx profile", ulx.profile, "!profile")
profileCmd:addParam{type=ULib.cmds.PlayerArg}
profileCmd:defaultAccess(ULib.ACCESS_ALL)
profileCmd:help( "在浏览器中打开目标的 Steam 资料页" )
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
redirectCmd:help( "将目标重定向到另一台服务器" )
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
ssCmd:help( "停止目标客户端的所有音效" )
if SERVER then
	function ulx.timescale(calling_ply, scale)
		scale = math.Clamp(scale, 0.01, 5)
		game.SetTimeScale(scale)
		ulx.fancyLogAdmin(calling_ply, "#A 将游戏时间倍速设为 #i", scale)
	end
end
local tsCmd = ulx.command(CAT_T, "ulx timescale", ulx.timescale, "!timescale")
tsCmd:addParam{type=ULib.cmds.NumArg, min=0.01, max=5, default=1, hint="倍速"}
tsCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
tsCmd:help( "设置游戏全局时间倍速 0.01~5" )
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
urlCmd:help( "在目标客户端打开指定网页" )
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
aliasesCmd:help( "查看目标的 SteamID 和 IP 信息" )
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
rrCmd:help( "清除地图上所有布娃娃" )
if SERVER then
	function ulx.deafen(calling_ply, target_plys, should_undeafen)
		for _, ply in ipairs(target_plys) do
			ply.ulx_deafened = not should_undeafen
			ply:SetNWBool("ulx_deafened", not should_undeafen)
		end
		if should_undeafen then
			ulx.fancyLogAdmin(calling_ply, "#A 解除了 #T 的聊天语音屏蔽", target_plys)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 屏蔽了 #T 的聊天和语音", target_plys)
		end
	end
	hook.Add("PlayerSay", "ULXDeafenSay", function(ply)
		if ply.ulx_deafened then return "" end
	end)
	hook.Add("PlayerCanHearPlayersVoice", "ULXDeafenVoice", function(_, talker)
		if talker.ulx_deafened then return false end
	end)
end
local deafenCmd = ulx.command(CAT_C, "ulx deafen", ulx.deafen, "!deafen")
deafenCmd:addParam{type=ULib.cmds.PlayersArg}
deafenCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
deafenCmd:defaultAccess(ULib.ACCESS_ADMIN)
deafenCmd:help( "屏蔽目标的聊天和语音，!undeafen 解除" )
deafenCmd:setOpposite("ulx undeafen", {_, _, true}, "!undeafen")
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
local rsayCmd = ulx.command(CAT_C, "ulx rsay", ulx.rsay, {"§", "!rsay"}, true, true)
rsayCmd:addParam{type=ULib.cmds.StringArg, hint="消息", ULib.cmds.takeRestOfLine}
rsayCmd:defaultAccess(ULib.ACCESS_ADMIN)
rsayCmd:help( "向所有人发送彩色广播消息" )
if SERVER then
	function ulx.silence(calling_ply, target_plys, should_unsilence)
		for _, ply in ipairs(target_plys) do
			ply:SetNWBool("ulx_silenced", not should_unsilence)
		end
		if should_unsilence then
			ulx.fancyLogAdmin(calling_ply, "#A 解除了 #T 的禁言状态", target_plys)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 禁言了 #T (聊天+语音)", target_plys)
		end
	end
end
local silenceCmd = ulx.command(CAT_C, "ulx silence", ulx.silence, "!silence")
silenceCmd:addParam{type=ULib.cmds.PlayersArg}
silenceCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
silenceCmd:defaultAccess(ULib.ACCESS_ADMIN)
silenceCmd:help( "完全禁言目标和语音，!unsilence 解除" )
silenceCmd:setOpposite("ulx unsilence", {_, _, true}, "!unsilence")
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
jpCmd:help( "设置目标的跳跃力度" )
if SERVER then
	ulx.DEF_RUNSPEED  = 400
	ulx.DEF_WALKSPEED = 200
	ulx.DEF_JUMPSPEED = 200
	hook.Add("PlayerInitialSpawn", "ULXDetectDefaults", function(ply)
		if not ulx._defaultsDetected and IsValid(ply) and not ply:IsBot() then
			ulx._defaultsDetected = true
			ulx.DEF_RUNSPEED  = ply:GetRunSpeed()
			ulx.DEF_WALKSPEED = ply:GetWalkSpeed()
			ulx.DEF_JUMPSPEED = ply:GetJumpPower()
		end
	end)
end
if SERVER then
	function ulx.runspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed or ulx.DEF_RUNSPEED, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetRunSpeed(speed) end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的奔跑速度为 #i", target_plys, speed)
	end
end
local rsCmd = ulx.command(CAT_M, "ulx runspeed", ulx.runspeed, "!runspeed")
rsCmd:addParam{type=ULib.cmds.PlayersArg}
rsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="速度", ULib.cmds.optional, ULib.cmds.round}
rsCmd:defaultAccess(ULib.ACCESS_ADMIN)
rsCmd:help( "设置目标的奔跑速度，不加参数恢复默认" )
if SERVER then
	function ulx.walkspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed or ulx.DEF_WALKSPEED, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetWalkSpeed(speed) end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的行走速度为 #i", target_plys, speed)
	end
end
local wsCmd = ulx.command(CAT_M, "ulx walkspeed", ulx.walkspeed, "!walkspeed")
wsCmd:addParam{type=ULib.cmds.PlayersArg}
wsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="速度", ULib.cmds.optional, ULib.cmds.round}
wsCmd:defaultAccess(ULib.ACCESS_ADMIN)
wsCmd:help( "设置目标的行走速度，不加参数恢复默认" )
if SERVER then
	function ulx.speed(calling_ply, target_plys, speed)
		local w = speed or ulx.DEF_WALKSPEED
		local r = speed and (speed * 2.0) or ulx.DEF_RUNSPEED
		w = math.Clamp(w, 0, 1000); r = math.Clamp(r, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetWalkSpeed(w); ply:SetRunSpeed(r) end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的移动速度 (走#i 跑#i)", target_plys, w, r)
	end
end
local speedCmd = ulx.command(CAT_M, "ulx speed", ulx.speed, "!speed")
speedCmd:addParam{type=ULib.cmds.PlayersArg}
speedCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="走速", ULib.cmds.optional, ULib.cmds.round}
speedCmd:defaultAccess(ULib.ACCESS_ADMIN)
speedCmd:help( "统一设置行走和奔跑速度，不加参数恢复默认" )
if SERVER then
	function ulx.stepsize(calling_ply, target_plys, stepsize)
		stepsize = math.Clamp(stepsize, 0, 500)
		for _, ply in ipairs(target_plys) do
			ply:SetStepSize(stepsize)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 设置了 #T 的跨步高度为 #i", target_plys, stepsize)
	end
end
local ssCmd = ulx.command(CAT_M, "ulx stepsize", ulx.stepsize, "!stepsize")
ssCmd:addParam{type=ULib.cmds.PlayersArg}
ssCmd:addParam{type=ULib.cmds.NumArg, min=0, max=500, default=18, hint="高度", ULib.cmds.round}
ssCmd:defaultAccess(ULib.ACCESS_ADMIN)
ssCmd:help( "设置目标的最大跨步高度" )
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
viewCmd:help( "切换目标的第一/第三人称视角" )
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
banipCmd:help( "通过 IP 地址封禁玩家" )
if SERVER then
	function ulx.bot(calling_ply, amount, should_kick)
		if should_kick then
			local count = 0
			for _, ply in ipairs(player.GetAll()) do
				if ply:IsBot() then ply:Kick("BOT已被管理员移除"); count = count + 1 end
			end
			ulx.fancyLogAdmin(calling_ply, "#A 移除了 #i 个BOT", count)
			return
		end
		amount = math.Clamp(amount, 1, 32)
		local gmName = (GAMEMODE and GAMEMODE.FolderName) or ""
		local gmDerived = false
		if GAMEMODE then
			local sd = GAMEMODE.IsSandboxDerived
			if type(sd) == "function" then
				gmDerived = GAMEMODE:IsSandboxDerived()
			elseif type(sd) == "boolean" then
				gmDerived = sd
			end
		end
		local allowed = (gmName == "sandbox" or gmName == "terrortown" or gmName == "murder" or gmDerived)
		if not allowed then
			ULib.tsayError(calling_ply, "当前游戏模式不支持生成BOT。", true); return
		end
		for i = 1, amount do
			timer.Simple(0.05 * (i - 1), function() RunConsoleCommand("bot") end)
		end
		ulx.fancyLogAdmin(calling_ply, "#A 已请求生成 #i 个BOT", amount)
	end
end
local botCmd = ulx.command(CAT_A, "ulx bot", ulx.bot, "!bot")
botCmd:addParam{type=ULib.cmds.NumArg, min=1, max=32, default=1, hint="数量", ULib.cmds.round, ULib.cmds.optional}
botCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
botCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
botCmd:help( "生成 BOT 玩家，!kickbots 全部移除" )
botCmd:setOpposite("ulx kickbots", {_, _, true}, "!kickbots")
if SERVER then
	local disguisedPlayers = {}
	function ulx.disguise(calling_ply, target_ply, disguise_target, should_restore)
		if should_restore then
			local sid = target_ply:SteamID()
			if disguisedPlayers[sid] then
				target_ply:SetName(disguisedPlayers[sid])
				disguisedPlayers[sid] = nil
				ulx.fancyLogAdmin(calling_ply, "#A 恢复了 #T 的原始名称", target_ply)
			else
				ULib.tsayError(calling_ply, target_ply:Nick() .. " 没有被伪装。", true)
			end
			return
		end
		if not disguise_target:IsValid() then
			ULib.tsayError(calling_ply, "伪装目标无效。", true)
			return
		end
		local sid = target_ply:SteamID()
		if not disguisedPlayers[sid] then disguisedPlayers[sid] = target_ply:Nick() end
		target_ply:SetName(disguise_target:Nick())
		ulx.fancyLogAdmin(calling_ply, "#A 将 #T 伪装成了目标玩家", target_ply)
	end
	hook.Add("PlayerDisconnected", "ULXDisguiseRestore", function(ply)
		local sid = ply:SteamID()
		if disguisedPlayers[sid] then ply:SetName(disguisedPlayers[sid]); disguisedPlayers[sid] = nil end
	end)
end
local disguiseCmd = ulx.command(CAT_A, "ulx disguise", ulx.disguise, "!disguise")
disguiseCmd:addParam{type=ULib.cmds.PlayerArg}
disguiseCmd:addParam{type=ULib.cmds.PlayerArg, hint="伪装目标", ULib.cmds.optional}
disguiseCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
disguiseCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
disguiseCmd:help( "将目标伪装成另一个玩家的名字，!undisguise 恢复" )
disguiseCmd:setOpposite("ulx undisguise", {_, _, _, true}, "!undisguise")
if SERVER then
	function ulx.esp(calling_ply, target_plys, should_disable)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_esp")
			net.WriteEntity(ply)
			net.WriteBool(not should_disable)
			net.Send(calling_ply)
		end
		if should_disable then
			ulx.fancyLogAdmin(calling_ply, "#A 关闭了 #T 的透视", target_plys)
		else
			ulx.fancyLogAdmin(calling_ply, "#A 开启了 #T 的透视", target_plys)
		end
	end
end
local espCmd = ulx.command(CAT, "ulx esp", ulx.esp, "!esp")
espCmd:addParam{type=ULib.cmds.PlayersArg}
espCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
espCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
espCmd:help( "透视目标显示名称/血量/距离，!unesp 关闭" )
espCmd:setOpposite("ulx unesp", {_, _, true}, "!unesp")
if CLIENT then
	local espTargets = {}
	local espHookActive = false
	local function espUpdateHook()
		if next(espTargets) and not espHookActive then
			hook.Add("HUDPaint", "ULXCommunityESP", espDraw)
			espHookActive = true
		elseif not next(espTargets) and espHookActive then
			hook.Remove("HUDPaint", "ULXCommunityESP")
			espHookActive = false
		end
	end
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
	net.Receive("ulx_community_esp", function()
		local ent = net.ReadEntity()
		if net.ReadBool() then espTargets[ent] = true else espTargets[ent] = nil end
		espUpdateHook()
	end)
	local function thirdPersonCam(ply, pos, angles, fov)
		local playerScale = GetConVar("ulx_playerscale")
		local dist = 100 * math.max((playerScale and playerScale:GetFloat()) or 1, 1)
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
	net.Receive("ulx_community_url", function()
		local url = net.ReadString()
		Derma_Query("管理员想在你浏览器中打开以下网址:\n" .. url .. "\n\n是否允许？",
			"ULX - 网址确认",
			"是", function() gui.OpenURL(url) end,
			"否")
	end)
	net.Receive("ulx_community_rocket", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then
			local pos = ent:GetPos() + Vector(0, 0, 50)
			local effect = EffectData()
			effect:SetOrigin(pos)
			util.Effect("Explosion", effect)
		end
	end)
	net.Receive("ulx_community_explode", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then
			local pos = ent:GetPos()
			local effect = EffectData()
			effect:SetOrigin(pos)
			util.Effect("Explosion", effect)
		end
	end)
	net.Receive("ulx_community_profile", function()
		local sid64 = net.ReadString()
		gui.OpenURL("https://steamcommunity.com/profiles/" .. sid64)
	end)
	net.Receive("ulx_community_cleardecals", function()
		RunConsoleCommand("r_cleardecals")
	end)
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
	local haloEntities = {}
	hook.Add("PreDrawHalos", "ULXCommunityHalo", function()
		for ent, clr in pairs(haloEntities) do
			if ent:IsValid() then
				halo.Add({ent}, clr, 2, 2, 1, true, false)
			else
				haloEntities[ent] = nil
			end
		end
	end)
	net.Receive("ulx_community_halo", function()
		local ent, enable = net.ReadEntity(), net.ReadBool()
		if enable and ent:IsValid() then
			haloEntities[ent] = Color(255, 215, 0)
		else
			haloEntities[ent] = nil
		end
	end)
		local trailTargets = {}
	local trailHistory = {}
	local TRAIL_LIFE = 40
	local trailHookActive = false
	local function trailUpdateHook()
		if next(trailTargets) and not trailHookActive then
			hook.Add("PostDrawOpaqueRenderables", "ULXCommunityTrail", trailDraw)
			trailHookActive = true
		elseif not next(trailTargets) and trailHookActive then
			hook.Remove("PostDrawOpaqueRenderables", "ULXCommunityTrail")
			trailHookActive = false
		end
	end
	local function trailDraw()
		for ent, _ in pairs(trailTargets) do
			if not ent:IsValid() then
				trailTargets[ent] = nil
				trailHistory[ent] = nil
			else
				local h = trailHistory[ent]
				if not h then
					h = { head = 0, count = 0, pts = {} }
					trailHistory[ent] = h
				end
				local pts = h.pts
				h.head = h.head + 1
				pts[h.head] = ent:GetPos() + Vector(0, 0, 10)
				if h.count < TRAIL_LIFE then h.count = h.count + 1 end
				if h.count > 1 then
					render.SetMaterial(Material("trails/laser"))
					local startIdx = h.head - h.count + 1
					for i = 0, h.count - 2 do
						local idx1 = startIdx + i
						local idx2 = idx1 + 1
						local alpha = ((i + 1) / h.count) * 255
						render.DrawBeam(pts[idx1], pts[idx2], 6 * ((i + 1) / h.count), 0, 1, ColorAlpha(Color(255, 200, 0), alpha))
					end
				end
			end
		end
	end
	net.Receive("ulx_community_trail", function()
		local ent, enable = net.ReadEntity(), net.ReadBool()
		if enable then
			trailTargets[ent] = true
		else
			trailTargets[ent] = nil
			trailHistory[ent] = nil
		end
		trailUpdateHook()
	end)
	hook.Add("EntityRemoved", "ULXCommunityTrailCleanup", function(ent)
		trailTargets[ent] = nil
		trailHistory[ent] = nil
		haloEntities[ent] = nil
	end)
	net.Receive("ulx_community_color", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then ent:SetColor(Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))) end
	end)
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
if not UltraULX_SilentReRegister then Msg("[ULX] 社区扩展模块已加载 (30+ 命令)\n") end