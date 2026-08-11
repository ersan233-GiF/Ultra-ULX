local L = ULib.ulx_lang
local CAT, CAT_T, CAT_C, CAT_M, CAT_A = "cat_fun", "cat_utility", "cat_chat", "cat_movement", "cat_admin"
local string = string
local table = table
local math = math
local net = net
local hook = hook
local Color = Color
local IsValid = IsValid
local Msg = Msg
if SERVER then
	util.AddNetworkString("ulx_community_esp")
	util.AddNetworkString("ulx_coord_display")
	util.AddNetworkString("ulx_coord_data")
	util.AddNetworkString("ulx_community_halo")
	util.AddNetworkString("ulx_community_trail")
	util.AddNetworkString("ulx_community_toggleview")
	util.AddNetworkString("ulx_community_color")
	util.AddNetworkString("ulx_community_stopsound")
	util.AddNetworkString("ulx_community_url")
	util.AddNetworkString("ulx_community_deafen")
	util.AddNetworkString("ulx_community_rocket")
	util.AddNetworkString("ulx_community_explode")
	util.AddNetworkString("ulx_community_cleardecals")
	util.AddNetworkString("ulx_community_profile")
end
if SERVER then
	function ulx.launch(calling_ply, target_plys, power)
		power = power or 500
		for _, ply in ipairs(target_plys) do
			if ply:Alive() and not ply:InVehicle() then
				ply:SetVelocity(Vector(0, 0, power))
			end
		end
		ulx.fancyLogKeyed(calling_ply, "comm_launch_log", target_plys)
	end
end
local launchCmd = ulx.command(CAT, "ulx launch", ulx.launch, "!launch")
launchCmd:addParam{type=ULib.cmds.PlayersArg}
launchCmd:addParam{type=ULib.cmds.NumArg, min=100, max=5000, default=500, hint="power", ULib.cmds.optional, ULib.cmds.round}
launchCmd:defaultAccess(ULib.ACCESS_ADMIN)
launchCmd:help( L.T("comm_launch_help") )
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
		ulx.fancyLogKeyed(calling_ply, "comm_rocket_log", target_plys)
	end
end
local rocketCmd = ulx.command(CAT, "ulx rocket", ulx.rocket, "!rocket")
rocketCmd:addParam{type=ULib.cmds.PlayersArg}
rocketCmd:defaultAccess(ULib.ACCESS_ADMIN)
rocketCmd:help( L.T("comm_rocket_help") )
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
				net.Start("ulx_community_explode")
				net.WriteEntity(ply)
				net.Broadcast()
			end
		end
		ulx.fancyLogKeyed(calling_ply, "comm_explode_log", target_plys)
	end
end
local explodeCmd = ulx.command(CAT, "ulx explode", ulx.explode, "!explode")
explodeCmd:addParam{type=ULib.cmds.PlayersArg}
explodeCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
explodeCmd:help( L.T("comm_explode_help") )
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
		ulx.fancyLogKeyed(calling_ply, "comm_color_log", target_plys, r, g, b)
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
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="red", ULib.cmds.round}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="green", ULib.cmds.round}
colorCmd:addParam{type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="blue", ULib.cmds.round}
colorCmd:defaultAccess(ULib.ACCESS_ADMIN)
colorCmd:help( L.T("comm_color_help") )
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
			ulx.fancyLogKeyed(calling_ply, "comm_halo_remove", target_plys)
		else
			ulx.fancyLogKeyed(calling_ply, "comm_halo_add", target_plys)
		end
	end
end
local haloCmd = ulx.command(CAT, "ulx halo", ulx.halo, "!halo")
haloCmd:addParam{type=ULib.cmds.PlayersArg}
haloCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
haloCmd:defaultAccess(ULib.ACCESS_ADMIN)
haloCmd:help( L.T("comm_halo_help") )
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
			ulx.fancyLogKeyed(calling_ply, "comm_trail_remove", target_plys)
		else
			ulx.fancyLogKeyed(calling_ply, "comm_trail_add", target_plys)
		end
	end
end
local trailCmd = ulx.command(CAT, "ulx trail", ulx.trail, "!trail")
trailCmd:addParam{type=ULib.cmds.PlayersArg}
trailCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
trailCmd:defaultAccess(ULib.ACCESS_ADMIN)
trailCmd:help( L.T("comm_trail_help") )
trailCmd:setOpposite("ulx removetrail", {_, _, true}, "!removetrail")
if SERVER then
	function ulx.cleardecals(calling_ply, target_plys)
				for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_cleardecals")
			net.Send(ply)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_cleardecals_log", target_plys)
	end
end
local cdCmd = ulx.command(CAT_T, "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cdCmd:addParam{type=ULib.cmds.PlayersArg}
cdCmd:defaultAccess(ULib.ACCESS_ADMIN)
cdCmd:help( L.T("comm_cleardecals_help") )
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
profileCmd:help( L.T("comm_profile_help") )
if SERVER then
	function ulx.redirect(calling_ply, target_plys, hostname)
		for _, ply in ipairs(target_plys) do
			ply:ConCommand("connect " .. hostname)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_redirect_log", target_plys, hostname)
	end
end
local redirectCmd = ulx.command(CAT_T, "ulx redirect", ulx.redirect, "!redirect")
redirectCmd:addParam{type=ULib.cmds.PlayersArg}
redirectCmd:addParam{type=ULib.cmds.StringArg, hint="server_ip", ULib.cmds.takeRestOfLine}
redirectCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
redirectCmd:help( L.T("comm_redirect_help") )
if SERVER then
	function ulx.stopsound(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_stopsound")
			net.Send(ply)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_stopsound_log", target_plys)
	end
end
local ssCmd = ulx.command(CAT_T, "ulx stopsound", ulx.stopsound, "!stopsound")
ssCmd:addParam{type=ULib.cmds.PlayersArg}
ssCmd:defaultAccess(ULib.ACCESS_ADMIN)
ssCmd:help( L.T("comm_stopsound_help") )
if SERVER then
	function ulx.timescale(calling_ply, scale)
		scale = math.Clamp(scale, 0.01, 5)
		game.SetTimeScale(scale)
		ulx.fancyLogKeyed(calling_ply, "comm_timescale_log", scale)
	end
end
local tsCmd = ulx.command(CAT_T, "ulx timescale", ulx.timescale, "!timescale")
tsCmd:addParam{type=ULib.cmds.NumArg, min=0.01, max=5, default=1, hint="timescale"}
tsCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
tsCmd:help( L.T("comm_timescale_help") )
if SERVER then
	local URL_WHITELIST = {
		"^https?://[%w%.%-]*steampowered%.com/",
		"^https?://[%w%.%-]*steamcommunity%.com/",
		"^https?://[%w%.%-]*github%.com/",
		"^https?://[%w%.%-]*google%.com/",
		"^https?://[%w%.%-]*youtube%.com/",
		"^https?://[%w%.%-]*bilibili%.com/",
		"^https?://[%w%.%-]*wikipedia%.org/",
		"^https?://[%w%.%-]*facepunch%.com/",
		"^https?://[%w%.%-]*gmod%.com/",
	}
	local function isUrlAllowed(url)
		local lowerUrl = url:lower()
		for _, pattern in ipairs(URL_WHITELIST) do
			if lowerUrl:match(pattern) then return true end
		end
		return false
	end
	function ulx.url(calling_ply, target_plys, weburl)
		if not isUrlAllowed(weburl) then
			ULib.tsayError(calling_ply, L.T("comm_url_invalid"), true)
			return
		end
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_url")
			net.WriteString(weburl)
			net.Send(ply)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_url_log", target_plys, weburl)
	end
end
local urlCmd = ulx.command(CAT_T, "ulx url", ulx.url, "!url")
urlCmd:addParam{type=ULib.cmds.PlayersArg}
urlCmd:addParam{type=ULib.cmds.StringArg, hint="url", ULib.cmds.takeRestOfLine}
urlCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
urlCmd:help( L.T("comm_url_help") )
if SERVER then
	function ulx.aliases(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			ULib.console(calling_ply, ply:Nick() .. " <" .. ply:SteamID() .. ">")
			ULib.console(calling_ply, "  UniqueID: " .. ply:UniqueID())
			ULib.console(calling_ply, "  IP: " .. ply:IPAddress())
		end
		ulx.fancyLogKeyed(calling_ply, "comm_profile_log", target_plys)
	end
end
local aliasesCmd = ulx.command(CAT_T, "ulx aliases", ulx.aliases, "!aliases")
aliasesCmd:addParam{type=ULib.cmds.PlayersArg}
aliasesCmd:defaultAccess(ULib.ACCESS_ADMIN)
aliasesCmd:help( L.T("comm_aliases_help") )
if SERVER then
	function ulx.removeragdolls(calling_ply)
		local ragdolls = ents.FindByClass("prop_ragdoll")
		for _, rag in ipairs(ragdolls) do
			if rag:IsValid() then rag:Remove() end
		end
		ulx.fancyLogKeyed(calling_ply, "comm_clearragdolls_log")
	end
end
local rrCmd = ulx.command(CAT_T, "ulx removeragdolls", ulx.removeragdolls, "!removeragdolls")
rrCmd:defaultAccess(ULib.ACCESS_ADMIN)
rrCmd:help( L.T("comm_clearragdolls_help") )
if SERVER then
	function ulx.deafen(calling_ply, target_plys, should_undeafen)
		for _, ply in ipairs(target_plys) do
			ply:SetNWBool("ulx_deafened", not should_undeafen)
		end
		if should_undeafen then
			ulx.fancyLogKeyed(calling_ply, "comm_deafen_remove", target_plys)
		else
			ulx.fancyLogKeyed(calling_ply, "comm_deafen_add", target_plys)
		end
	end
end
local deafenCmd = ulx.command(CAT_C, "ulx deafen", ulx.deafen, "!deafen")
deafenCmd:addParam{type=ULib.cmds.PlayersArg}
deafenCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
deafenCmd:defaultAccess(ULib.ACCESS_ADMIN)
deafenCmd:help( L.T("comm_deafen_help") )
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
rsayCmd:addParam{type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine}
rsayCmd:defaultAccess(ULib.ACCESS_ADMIN)
rsayCmd:help( L.T("comm_rsay_help") )
if SERVER then
	function ulx.jumppower(calling_ply, target_plys, power)
		power = math.Clamp(power, 0, 1000)
		for _, ply in ipairs(target_plys) do
			ply:SetJumpPower(power)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_jumppower_log", target_plys, power)
	end
end
local jpCmd = ulx.command(CAT_M, "ulx jumppower", ulx.jumppower, "!jumppower")
jpCmd:addParam{type=ULib.cmds.PlayersArg}
jpCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, default=200, hint="power", ULib.cmds.round}
jpCmd:defaultAccess(ULib.ACCESS_ADMIN)
jpCmd:help( L.T("comm_jumppower_help") )
ulx.DEF_RUNSPEED  = ulx.DEF_RUNSPEED or 400
ulx.DEF_WALKSPEED = ulx.DEF_WALKSPEED or 200
ulx.DEF_JUMPSPEED = ulx.DEF_JUMPSPEED or 200
ulx.DEF_CROUCHSPEED = ulx.DEF_CROUCHSPEED or 100
if SERVER then
	hook.Add("PlayerInitialSpawn", "ULXDetectDefaults", function(ply)
		if not ulx._defaultsDetected and IsValid(ply) and not ply:IsBot() then
			ulx._defaultsDetected = true
			ulx.DEF_RUNSPEED  = ply:GetRunSpeed()
			ulx.DEF_WALKSPEED = ply:GetWalkSpeed()
			ulx.DEF_JUMPSPEED = ply:GetJumpPower()
			ulx.DEF_CROUCHSPEED = ply:GetCrouchedWalkSpeed()
		end
	end)
end
if SERVER then
	function ulx.runspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed or ulx.DEF_RUNSPEED, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetRunSpeed(speed) end
		ulx.fancyLogKeyed(calling_ply, "comm_runspeed_log", target_plys, speed)
	end
end
local rsCmd = ulx.command(CAT_M, "ulx runspeed", ulx.runspeed, "!runspeed")
rsCmd:addParam{type=ULib.cmds.PlayersArg}
rsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="speed", ULib.cmds.optional, ULib.cmds.round}
rsCmd:defaultAccess(ULib.ACCESS_ADMIN)
rsCmd:help( L.T("comm_runspeed_help") )
if SERVER then
	function ulx.walkspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed or ulx.DEF_WALKSPEED, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetWalkSpeed(speed) end
		ulx.fancyLogKeyed(calling_ply, "comm_walkspeed_log", target_plys, speed)
	end
end
local wsCmd = ulx.command(CAT_M, "ulx walkspeed", ulx.walkspeed, "!walkspeed")
wsCmd:addParam{type=ULib.cmds.PlayersArg}
wsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="speed", ULib.cmds.optional, ULib.cmds.round}
wsCmd:defaultAccess(ULib.ACCESS_ADMIN)
wsCmd:help( L.T("comm_walkspeed_help") )
if SERVER then
	function ulx.crouchspeed(calling_ply, target_plys, speed)
		speed = math.Clamp(speed or ulx.DEF_CROUCHSPEED, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetCrouchedWalkSpeed(speed) end
		ulx.fancyLogKeyed(calling_ply, "comm_crouchspeed_log", target_plys, speed)
	end
end
local crsCmd = ulx.command(CAT_M, "ulx crouchspeed", ulx.crouchspeed, "!crouchspeed")
crsCmd:addParam{type=ULib.cmds.PlayersArg}
crsCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="speed", ULib.cmds.optional, ULib.cmds.round}
crsCmd:defaultAccess(ULib.ACCESS_ADMIN)
crsCmd:help( L.T("comm_crouchspeed_help") )
if SERVER then
	function ulx.speed(calling_ply, target_plys, speed)
		local w = speed or ulx.DEF_WALKSPEED
		local r = speed and (speed * 2.0) or ulx.DEF_RUNSPEED
		w = math.Clamp(w, 0, 1000); r = math.Clamp(r, 0, 1000)
		for _, ply in ipairs(target_plys) do ply:SetWalkSpeed(w); ply:SetRunSpeed(r) end
		ulx.fancyLogKeyed(calling_ply, "comm_speed_log", target_plys, w, r)
	end
end
local speedCmd = ulx.command(CAT_M, "ulx speed", ulx.speed, "!speed")
speedCmd:addParam{type=ULib.cmds.PlayersArg}
speedCmd:addParam{type=ULib.cmds.NumArg, min=0, max=1000, hint="walkspeed", ULib.cmds.optional, ULib.cmds.round}
speedCmd:defaultAccess(ULib.ACCESS_ADMIN)
speedCmd:help( L.T("comm_speed_help") )
if SERVER then
	function ulx.stepsize(calling_ply, target_plys, stepsize)
		stepsize = math.Clamp(stepsize, 0, 500)
		for _, ply in ipairs(target_plys) do
			ply:SetStepSize(stepsize)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_stepsize_log", target_plys, stepsize)
	end
end
local ssCmd = ulx.command(CAT_M, "ulx stepsize", ulx.stepsize, "!stepsize")
ssCmd:addParam{type=ULib.cmds.PlayersArg}
ssCmd:addParam{type=ULib.cmds.NumArg, min=0, max=500, default=18, hint="height", ULib.cmds.round}
ssCmd:defaultAccess(ULib.ACCESS_ADMIN)
ssCmd:help( L.T("comm_stepsize_help") )
if SERVER then
	function ulx.toggleview(calling_ply, target_plys)
		for _, ply in ipairs(target_plys) do
			net.Start("ulx_community_toggleview")
			net.Send(ply)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_view_log", target_plys)
	end
end
local viewCmd = ulx.command(CAT_T, "ulx view", ulx.toggleview, "!view")
viewCmd:addParam{type=ULib.cmds.PlayersArg}
viewCmd:defaultAccess(ULib.ACCESS_OPERATOR)
viewCmd:help( L.T("comm_view_help") )
if SERVER then
	function ulx.banip(calling_ply, ip, minutes, reason)
		minutes = minutes or 0
		local name = "<" .. L.T("punish_type_banip") .. ">"
		ULib.addBan(ip, minutes, reason, name, calling_ply)
		if ulx.recordBanIP then
			ulx.recordBanIP(calling_ply, ip, minutes, reason)
		end
		ulx.fancyLogKeyed(calling_ply, "comm_banip_log", ip)
	end
end
local banipCmd = ulx.command(CAT_A, "ulx banip", ulx.banip, "!banip")
banipCmd:addParam{type=ULib.cmds.StringArg, hint="ip"}
banipCmd:addParam{type=ULib.cmds.NumArg, min=0, default=0, hint="ban_minutes", ULib.cmds.optional, ULib.cmds.allowTimeString}
banipCmd:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
banipCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
banipCmd:help( L.T("comm_banip_help") )
if SERVER then
	function ulx.bot(calling_ply, amount, should_kick)
		if should_kick then
			local count = 0
			for _, ply in ipairs(player.GetAll()) do
				if ply:IsBot() then ply:Kick(L.T("community_bot_removed")); count = count + 1 end
			end
			ulx.fancyLogKeyed(calling_ply, "comm_kickbots_log", count)
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
			ULib.tsayError(calling_ply, L.T("comm_bot_nosupport"), true); return
		end
		local success = 0
		for i = 1, amount do
			if pcall(RunConsoleCommand, "bot") then success = success + 1 end
			if i < amount then timer.Simple(0.05 * i, function() end) end
		end
		if success > 0 then ulx.fancyLogKeyed(calling_ply, "comm_bot_spawn_log", success)
		else ULib.tsayError(calling_ply, L.T("comm_bot_fail"), true) end
	end
end
local botCmd = ulx.command(CAT_A, "ulx bot", ulx.bot, "!bot")
botCmd:addParam{type=ULib.cmds.NumArg, min=1, max=32, default=1, hint="count", ULib.cmds.round, ULib.cmds.optional}
botCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
botCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
botCmd:help( L.T("comm_bot_help") )
botCmd:setOpposite("ulx kickbots", {_, _, true}, "!kickbots")
if SERVER and not ulx.warn and not ulx.unwarn then
	ulx.warns = ulx.warns or {}
	hook.Add("PlayerDisconnected", "ULXWarnCleanup", function(ply) ulx.warns[ply:SteamID()] = nil end)
	function ulx.warn(calling_ply, target_ply, reason)
		local sid = target_ply:SteamID()
		ulx.warns[sid] = (ulx.warns[sid] or 0) + 1
		local count = ulx.warns[sid]
		ULib.tsayError(target_ply, string.format(L.T("comm_warn_msg"), count, reason or L.T("comm_warn_unspec")), true)
		ulx.fancyLogKeyed(calling_ply, "comm_warn_log", target_ply, count, reason or "未指定")
		if count >= 3 then
			ULib.kickban(target_ply, 60, L.T("community_auto_ban_3warn"), calling_ply)
			ulx.warns[sid] = 0
			ulx.fancyLogKeyed(calling_ply, "comm_warn_autoban", target_ply)
		end
	end
	function ulx.unwarn(calling_ply, target_ply)
		local sid = target_ply:SteamID()
		ulx.warns[sid] = math.max(0, (ulx.warns[sid] or 0) - 1)
		ulx.fancyLogKeyed(calling_ply, "comm_unwarn_log", target_ply, ulx.warns[sid])
	end
end
if SERVER then
	local disguisedNames = {}
	hook.Add("GetPlayerName", "ULXDisguiseName", function(ply)
		local name = disguisedNames[ply:SteamID()]
		if name then return name end
	end)
	function ulx.disguise(calling_ply, target_ply, disguise_target, should_restore)
		local sid = target_ply:SteamID()
		if should_restore then
			if disguisedNames[sid] then
				disguisedNames[sid] = nil
				ulx.fancyLogKeyed(calling_ply, "comm_disguise_restore", target_ply)
			else
				ULib.tsayError(calling_ply, target_ply:Nick() .. L.T("comm_disguise_none"), true)
			end
			return
		end
		if not disguise_target:IsValid() then
			ULib.tsayError(calling_ply, L.T("community_invalid_disguise"), true)
			return
		end
		disguisedNames[sid] = disguise_target:Nick()
		ulx.fancyLogKeyed(calling_ply, "comm_disguise_log", target_ply)
	end
	hook.Add("PlayerDisconnected", "ULXDisguiseRestore", function(ply)
		disguisedNames[ply:SteamID()] = nil
	end)
end
local disguiseCmd = ulx.command(CAT_A, "ulx disguise", ulx.disguise, "!disguise")
disguiseCmd:addParam{type=ULib.cmds.PlayerArg}
disguiseCmd:addParam{type=ULib.cmds.PlayerArg, hint="disguise_target", ULib.cmds.optional}
disguiseCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
disguiseCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
disguiseCmd:help( L.T("comm_disguise_help") )
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
			ulx.fancyLogKeyed(calling_ply, "comm_esp_disable", target_plys)
		else
			ulx.fancyLogKeyed(calling_ply, "comm_esp_enable", target_plys)
		end
	end
end
local espCmd = ulx.command(CAT, "ulx esp", ulx.esp, "!esp")
espCmd:addParam{type=ULib.cmds.PlayersArg}
espCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
espCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
espCmd:help( L.T("comm_esp_help") )
espCmd:setOpposite("ulx unesp", {_, _, true}, "!unesp")
if CLIENT then
	local espTargets = {}
	local espHookActive = false
	local espDraw
	local function espUpdateHook()
		if next(espTargets) and not espHookActive then
			hook.Add("HUDPaint", "ULXCommunityESP", espDraw)
			espHookActive = true
		elseif not next(espTargets) and espHookActive then
			hook.Remove("HUDPaint", "ULXCommunityESP")
			espHookActive = false
		end
	end
	function espDraw()
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
		Derma_Query(L.T("community_url_prompt") .. "\n" .. url .. "\n\n" .. L.T("community_url_confirm"),
			"ULX - " .. L.T("community_url_title"),
			L.T("ui_yes"), function() gui.OpenURL(url) end,
			L.T("ui_no"))
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
	local trailDraw
	local function trailUpdateHook()
		if next(trailTargets) and not trailHookActive then
			hook.Add("PostDrawOpaqueRenderables", "ULXCommunityTrail", trailDraw)
			trailHookActive = true
		elseif not next(trailTargets) and trailHookActive then
			hook.Remove("PostDrawOpaqueRenderables", "ULXCommunityTrail")
			trailHookActive = false
		end
	end
	function trailDraw()
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
	local LocalPlayer = LocalPlayer
	local chat = chat
	net.Receive("ulx_community_color", function()
		local ent = net.ReadEntity()
		if ent:IsValid() then ent:SetColor(Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))) end
	end)
	hook.Add("PlayerChat", "ULXDeafenCheck", function(ply) if LocalPlayer():GetNWBool("ulx_deafened") then return true end end)
	hook.Add("PlayerSay", "ULXSilenceCheck", function(ply)
		if ply == LocalPlayer() and ply:GetNWBool("ulx_silenced") then
			chat.AddText(Color(255,100,100), L.T("community_muted_notice"))
			return ""
		end
	end)
	hook.Add("PlayerCanHearPlayersVoice", "ULXSilenceVoiceCheck", function(listener, talker)
		if talker:GetNWBool("ulx_silenced") then return false end
	end)
end
if not ulx._silentReReg then Msg("[ULX] Community extension loaded (30+ commands)\n") end