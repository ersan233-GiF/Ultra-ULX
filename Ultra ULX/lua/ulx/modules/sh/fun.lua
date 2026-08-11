local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_fun"
function ulx.slap( calling_ply, target_plys, dmg )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, L.T("fun_frozen_error", v:Nick()), true )
		else
			ULib.slap( v, dmg )
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_slap_log", affected_plys, dmg )
end
local slap = ulx.command( CATEGORY_NAME, "ulx slap", ulx.slap, "!slap" )
slap:addParam{ type=ULib.cmds.PlayersArg }
slap:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="damage", ULib.cmds.optional, ULib.cmds.round }
slap:defaultAccess( ULib.ACCESS_ADMIN )
slap:help( L.T("fun_slap_help") )
function ulx.whip( calling_ply, target_plys, times, freq, dmg )
	if times and times == 0 then
		for _, v in ipairs( target_plys ) do
			timer.Remove( "ulxWhip_" .. v:EntIndex() )
		end
		ulx.fancyLogKeyed(calling_ply, "fun_whip_stop_log", target_plys )
		return
	end
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, L.T("fun_frozen_error", v:Nick()), true )
		else
			local interval = freq and freq > 0 and ( 1 / freq ) or 0.5
			local tid = "ulxWhip_" .. v:EntIndex()
			timer.Remove( tid )
			timer.Create( tid, interval, times, function()
				if not v:IsValid() or not v:Alive() then timer.Remove( tid ) return end
				ULib.slap( v, dmg )
			end )
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_whip_log", affected_plys, times, freq or 2, dmg )
end
local whip = ulx.command( CATEGORY_NAME, "ulx whip", ulx.whip, "!whip" )
whip:addParam{ type=ULib.cmds.PlayersArg }
whip:addParam{ type=ULib.cmds.NumArg, min=1, max=9999, default=10, hint="times", ULib.cmds.optional, ULib.cmds.round }
whip:addParam{ type=ULib.cmds.NumArg, min=0.1, max=100, default=2, hint="freq_sec", ULib.cmds.optional }
whip:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="damage", ULib.cmds.optional, ULib.cmds.round }
whip:defaultAccess( ULib.ACCESS_ADMIN )
whip:help( L.T("fun_whip_help") )
whip:setOpposite( "ulx unwhip", {_, _, 0}, "!unwhip" )
local gameModeDefaultHP = nil
local gameModeDefaultArmor = nil
local function getGameModeDefaultHP()
	if gameModeDefaultHP then return gameModeDefaultHP end
	local cv = GetConVar("ulx_default_maxhp")
	if cv then gameModeDefaultHP = math.max(cv:GetInt(), 1); return gameModeDefaultHP end
	if GAMEMODE then
		if GAMEMODE.DefaultPlayerHealth then gameModeDefaultHP = GAMEMODE.DefaultPlayerHealth; return gameModeDefaultHP end
		if GAMEMODE.ConVars and GAMEMODE.ConVars.DefaultPlayerHealth then gameModeDefaultHP = GAMEMODE.ConVars.DefaultPlayerHealth; return gameModeDefaultHP end
	end
	for _, p in ipairs(player.GetAll()) do
		if IsValid(p) and p:Alive() then
			gameModeDefaultHP = (p.GetMaxHealth and p:GetMaxHealth()) or p:Health()
			if gameModeDefaultHP and gameModeDefaultHP > 0 then return gameModeDefaultHP end
		end
	end
	gameModeDefaultHP = 100
	return gameModeDefaultHP
end
local function getGameModeDefaultArmor()
	if gameModeDefaultArmor then return gameModeDefaultArmor end
	local cv = GetConVar("ulx_default_maxarmor")
	if cv then gameModeDefaultArmor = cv:GetInt(); return gameModeDefaultArmor end
	if GAMEMODE then
		if GAMEMODE.DefaultPlayerArmor then gameModeDefaultArmor = GAMEMODE.DefaultPlayerArmor; return gameModeDefaultArmor end
	end
	gameModeDefaultArmor = 0
	return gameModeDefaultArmor
end
local playerMaxHP = {}
local playerMaxArmor = {}
local function getPlayerMaxHP( ply ) return playerMaxHP[ply:SteamID64()] end
local function getPlayerMaxArmor( ply ) return playerMaxArmor[ply:SteamID64()] end
local function clampHP( ply, amount )
	local m = getPlayerMaxHP(ply) or getGameModeDefaultHP()
	return m > 0 and math.min(amount, m) or amount
end
local function clampArmor( ply, amount )
	local m = getPlayerMaxArmor(ply)
	return m and m > 0 and math.min(amount, m) or amount
end
function ulx.regen( calling_ply, target_plys, interval, amount, should_stop )
	if interval and interval <= 0 then should_stop = true end
	interval = math.max(interval or 1, 0.1)
	amount = math.max(amount or 10, 0.1)
	local affected = {}
	for _, v in ipairs(target_plys) do
		local tid = "ulxRegen_" .. v:EntIndex()
		timer.Remove(tid)
		if should_stop then
			table.insert(affected, v)
		else
			timer.Create(tid, interval, 0, function()
				if not v:IsValid() or not v:Alive() then timer.Remove(tid) return end
				local newHp = clampHP(v, v:Health() + amount)
				v:SetHealth(newHp)
			end)
			table.insert(affected, v)
		end
	end
	if should_stop then
		ulx.fancyLogKeyed(calling_ply, "fun_regen_stop", affected)
	else
		ulx.fancyLogKeyed(calling_ply, "fun_regen_start", affected, interval, amount)
	end
end
local regen = ulx.command( CATEGORY_NAME, "ulx regen", ulx.regen, "!regen" )
regen:addParam{ type=ULib.cmds.PlayersArg }
regen:addParam{ type=ULib.cmds.NumArg, min=0.1, max=300, default=1, hint="interval_sec", ULib.cmds.optional }
regen:addParam{ type=ULib.cmds.NumArg, min=0.1, max=1000, default=10, hint="regen_amount", ULib.cmds.optional }
regen:defaultAccess( ULib.ACCESS_ADMIN )
regen:help( L.T("fun_regen_help") )
regen:setOpposite( "ulx unregen", {_, _, _, _, true}, "!unregen" )
function ulx.armorregen( calling_ply, target_plys, interval, amount, should_stop )
	if interval and interval <= 0 then should_stop = true end
	interval = math.max(interval or 1, 0.1)
	amount = math.max(amount or 10, 0.1)
	local affected = {}
	for _, v in ipairs(target_plys) do
		local tid = "ulxArmorRegen_" .. v:EntIndex()
		timer.Remove(tid)
		if should_stop then table.insert(affected, v)
		else
			timer.Create(tid, interval, 0, function()
				if not v:IsValid() or not v:Alive() then timer.Remove(tid) return end
				v:SetArmor(clampArmor(v, v:Armor() + amount))
			end)
			table.insert(affected, v)
		end
	end
	local keyArmorRegen = should_stop and "fun_armorregen_stop" or "fun_armorregen_start"
	ulx.fancyLogKeyed(calling_ply, keyArmorRegen, affected, interval, amount)
end
local armorregen = ulx.command( CATEGORY_NAME, "ulx armorregen", ulx.armorregen, "!armorregen" )
armorregen:addParam{ type=ULib.cmds.PlayersArg }
armorregen:addParam{ type=ULib.cmds.NumArg, min=0.1, max=300, default=1, hint="interval_sec", ULib.cmds.optional }
armorregen:addParam{ type=ULib.cmds.NumArg, min=0.1, max=1000, default=10, hint="regen_amount", ULib.cmds.optional }
armorregen:defaultAccess( ULib.ACCESS_ADMIN )
armorregen:help( L.T("fun_armorregen_help") )
armorregen:setOpposite( "ulx unarmorregen", {_, _, _, _, true}, "!unarmorregen" )
function ulx.maxhp( calling_ply, target_plys, amount )
	if amount == 0 then
		for _, ply in ipairs(target_plys) do
			playerMaxHP[ply:SteamID64()] = nil
		end
		ulx.fancyLogKeyed(calling_ply, "fun_maxhp_remove", target_plys, getGameModeDefaultHP())
		return
	end
	amount = math.Clamp(amount, 1, 2147483647)
	for _, ply in ipairs(target_plys) do
		playerMaxHP[ply:SteamID64()] = amount
		if ply:Health() > amount then ply:SetHealth(amount) end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_maxhp_set", target_plys, amount)
end
local maxhp = ulx.command( CATEGORY_NAME, "ulx maxhp", ulx.maxhp, nil, false, false, true )
maxhp:addParam{ type=ULib.cmds.PlayersArg }
maxhp:addParam{ type=ULib.cmds.NumArg, min=0, max=2147483647, default=0, hint="maxhp_cap", ULib.cmds.round }
maxhp:defaultAccess( ULib.ACCESS_ADMIN )
maxhp:help( L.T("fun_maxhp_help") )
function ulx.maxarmor( calling_ply, target_plys, amount )
	if amount == 0 then
		for _, ply in ipairs(target_plys) do
			playerMaxArmor[ply:SteamID64()] = nil
		end
		ulx.fancyLogKeyed(calling_ply, "fun_maxarmor_remove", target_plys)
		return
	end
	amount = math.Clamp(amount, 1, 2147483647)
	for _, ply in ipairs(target_plys) do
		playerMaxArmor[ply:SteamID64()] = amount
		if ply:Armor() > amount then ply:SetArmor(amount) end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_maxarmor_set", target_plys, amount)
end
local maxarmor = ulx.command( CATEGORY_NAME, "ulx maxarmor", ulx.maxarmor, nil, false, false, true )
maxarmor:addParam{ type=ULib.cmds.PlayersArg }
maxarmor:addParam{ type=ULib.cmds.NumArg, min=0, max=2147483647, default=0, hint="maxarmor_cap", ULib.cmds.round }
maxarmor:defaultAccess( ULib.ACCESS_ADMIN )
maxarmor:help( L.T("fun_maxarmor_help") )
hook.Add( "PlayerDisconnected", "ULXMaxHPArmorCleanup", function(ply)
	playerMaxHP[ply:SteamID64()] = nil
	playerMaxArmor[ply:SteamID64()] = nil
end, HOOK_MONITOR_HIGH )
function ulx.slay( calling_ply, target_plys )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, L.T("fun_already_dead_error", v:Nick()), true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, L.T("fun_frozen_error", v:Nick()), true )
		else
			v:Kill()
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_slay_log", affected_plys )
end
local slay = ulx.command( CATEGORY_NAME, "ulx slay", ulx.slay, "!slay" )
slay:addParam{ type=ULib.cmds.PlayersArg }
slay:defaultAccess( ULib.ACCESS_ADMIN )
slay:help( L.T("fun_slay_help") )
function ulx.sslay( calling_ply, target_plys )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, L.T("fun_already_dead_error", v:Nick()), true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, L.T("fun_frozen_error", v:Nick()), true )
		else
			if v:InVehicle() then
				v:ExitVehicle()
			end
			v:KillSilent()
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_sslay_log", affected_plys )
end
local sslay = ulx.command( CATEGORY_NAME, "ulx sslay", ulx.sslay, "!sslay" )
sslay:addParam{ type=ULib.cmds.PlayersArg }
sslay:defaultAccess( ULib.ACCESS_SUPERADMIN )
sslay:help( L.T("fun_sslay_help") )
function ulx.ignite( calling_ply, target_plys, seconds, should_extinguish )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if not should_extinguish then
			v:Ignite( seconds )
			v.ulx_ignited_until = CurTime() + seconds
			table.insert( affected_plys, v )
		elseif v:IsOnFire() then
			v:Extinguish()
			v.ulx_ignited_until = nil
			table.insert( affected_plys, v )
		end
	end
	if not should_extinguish then
		ulx.fancyLogKeyed(calling_ply, "fun_ignite_log", affected_plys, seconds )
	else
		ulx.fancyLogKeyed(calling_ply, "fun_unignite_log", affected_plys )
	end
end
local ignite = ulx.command( CATEGORY_NAME, "ulx ignite", ulx.ignite, "!ignite" )
ignite:addParam{ type=ULib.cmds.PlayersArg }
ignite:addParam{ type=ULib.cmds.NumArg, min=1, max=300, default=300, hint="seconds", ULib.cmds.optional, ULib.cmds.round }
ignite:addParam{ type=ULib.cmds.BoolArg, invisible=true }
ignite:defaultAccess( ULib.ACCESS_ADMIN )
ignite:help( L.T("fun_ignite_help") )
ignite:setOpposite( "ulx unignite", {_, _, _, true}, "!unignite" )
local function checkFireDeath( ply )
	if ply.ulx_ignited_until and ply.ulx_ignited_until >= CurTime() and ply:IsOnFire() then
		ply:Extinguish()
		ply.ulx_ignited_until = nil
	end
end
hook.Add( "PlayerDeath", "ULXCheckFireDeath", checkFireDeath, HOOK_MONITOR_HIGH )
function ulx.unigniteall( calling_ply )
	local flame_ents = ents.FindByClass( 'entityflame' )
	for _,v in ipairs( flame_ents ) do
		if v:IsValid() then
			v:Remove()
		end
	end
	local plys = player.GetAll()
	for _, v in ipairs( plys ) do
		if v:IsOnFire() then
			v:Extinguish()
			v.ulx_ignited_until = nil
		end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_unigniteall_log", {calling_ply})
end
local unigniteall = ulx.command( CATEGORY_NAME, "ulx unigniteall", ulx.unigniteall, "!unigniteall" )
unigniteall:defaultAccess( ULib.ACCESS_ADMIN )
unigniteall:help( L.T("fun_unigniteall_help") )
if SERVER then
	util.AddNetworkString( "ulib_sound" )
end
function ulx.playsound( calling_ply, sound )
	if not ULib.fileExists( "sound/" .. sound ) then
		ULib.tsayError( calling_ply, L.T("fun_sound_missing"), true )
		return
	end
	net.Start( "ulib_sound" )
		net.WriteString( Sound( sound ) )
	net.Broadcast()
	ulx.fancyLogKeyed(calling_ply, "fun_playsound_log", sound )
end
local playsound = ulx.command( CATEGORY_NAME, "ulx playsound", ulx.playsound, "!playsound" )
playsound:addParam{ type=ULib.cmds.StringArg, hint="sound_path", autocomplete_fn=ulx.soundComplete }
playsound:defaultAccess( ULib.ACCESS_ADMIN )
playsound:help( L.T("fun_playsound_help") )
function ulx.freeze( calling_ply, target_plys, should_unfreeze )
	local affected_plys = {}
	for i=1, #target_plys do
		if not should_unfreeze and ulx.getExclusive( target_plys[ i ], calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( target_plys[ i ], calling_ply ), true )
		else
			local v = target_plys[ i ]
			if v:InVehicle() then
				v:ExitVehicle()
			end
			if not should_unfreeze then
				v:Lock()
				v.frozen = true
				ulx.setExclusive( v, "frozen" )
			else
				v:UnLock()
				v.frozen = nil
				ulx.clearExclusive( v )
			end
			v:DisallowSpawning( not should_unfreeze )
			ulx.setNoDie( v, not should_unfreeze )
			table.insert( affected_plys, v )
			if v.whipped then
				v.whipcount = v.whipamt
			end
		end
	end
	if not should_unfreeze then
		ulx.fancyLogKeyed(calling_ply, "fun_freeze_log", affected_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "fun_unfreeze_log", affected_plys )
	end
end
local freeze = ulx.command( CATEGORY_NAME, "ulx freeze", ulx.freeze, "!freeze" )
freeze:addParam{ type=ULib.cmds.PlayersArg }
freeze:addParam{ type=ULib.cmds.BoolArg, invisible=true }
freeze:defaultAccess( ULib.ACCESS_ADMIN )
freeze:help( L.T("fun_freeze_help") )
freeze:setOpposite( "ulx unfreeze", {_, _, true}, "!unfreeze" )
function ulx.god( calling_ply, target_plys, should_revoke )
	if not target_plys[ 1 ]:IsValid() then
		if not should_revoke then
			Msg( L.T("fun_console_god") .. "\n" )
		else
			Msg( L.T("fun_console_god2") .. "\n" )
		end
		return
	end
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		else
			if not should_revoke then
				v:GodEnable()
				v.ULXHasGod = true
			else
				v:GodDisable()
				v.ULXHasGod = nil
			end
			table.insert( affected_plys, v )
		end
	end
	if not should_revoke then
		ulx.fancyLogKeyed(calling_ply, "fun_god_log", affected_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "fun_ungod_log", affected_plys )
	end
end
local god = ulx.command( CATEGORY_NAME, "ulx god", ulx.god, "!god" )
god:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional }
god:addParam{ type=ULib.cmds.BoolArg, invisible=true }
god:defaultAccess( ULib.ACCESS_ADMIN )
god:help( L.T("fun_god_help") )
god:setOpposite( "ulx ungod", {_, _, true}, "!ungod" )
function ulx.hp( calling_ply, target_plys, amount )
	amount = math.max(amount, 1)
	local clamped = false
	for i=1, #target_plys do
		local newHp = clampHP(target_plys[i], amount)
		if newHp ~= amount then clamped = true end
		target_plys[i]:SetHealth(newHp)
	end
	ulx.fancyLogKeyed( calling_ply, clamped and "fun_hp_capped" or "fun_hp_set", target_plys, amount )
end
local hp = ulx.command( CATEGORY_NAME, "ulx hp", ulx.hp, "!hp" )
hp:addParam{ type=ULib.cmds.PlayersArg }
hp:addParam{ type=ULib.cmds.NumArg, min=1, max=2147483647, hint="hp_value", ULib.cmds.round }
hp:defaultAccess( ULib.ACCESS_ADMIN )
hp:help( L.T("fun_hp_help") )
function ulx.armor( calling_ply, target_plys, amount )
	local clamped = false
	for i=1, #target_plys do
		local newArmor = clampArmor(target_plys[i], amount)
		if newArmor ~= amount then clamped = true end
		target_plys[i]:SetArmor(newArmor)
	end
	ulx.fancyLogKeyed( calling_ply, clamped and "fun_armor_capped" or "fun_armor_set", target_plys, amount )
end
local armor = ulx.command( CATEGORY_NAME, "ulx armor", ulx.armor, "!armor" )
armor:addParam{ type=ULib.cmds.PlayersArg }
armor:addParam{ type=ULib.cmds.NumArg, min=0, max=2147483647, hint="armor_value", ULib.cmds.round }
armor:defaultAccess( ULib.ACCESS_ADMIN )
armor:help( L.T("fun_armor_help") )
function ulx.cloak( calling_ply, target_plys, amount, should_uncloak )
	if not target_plys[ 1 ]:IsValid() then
		Msg( L.T("fun_console_cloak") .. "\n" )
		return
	end
	amount = 255 - amount
	for i=1, #target_plys do
		ULib.invisible( target_plys[ i ], not should_uncloak, amount )
	end
	if not should_uncloak then
		ulx.fancyLogKeyed(calling_ply, "fun_cloak_log", target_plys, amount )
	else
		ulx.fancyLogKeyed(calling_ply, "fun_uncloak_log", target_plys )
	end
end
local cloak = ulx.command( CATEGORY_NAME, "ulx cloak", ulx.cloak, "!cloak" )
cloak:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional }
cloak:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="alpha", ULib.cmds.round, ULib.cmds.optional }
cloak:addParam{ type=ULib.cmds.BoolArg, invisible=true }
cloak:defaultAccess( ULib.ACCESS_ADMIN )
cloak:help( L.T("fun_cloak_help") )
cloak:setOpposite( "ulx uncloak", {_, _, _, true}, "!uncloak" )
if SERVER then
	util.AddNetworkString( "ulx_blind" )
end
function ulx.blind( calling_ply, target_plys, amount, duration, should_unblind )
	for i=1, #target_plys do
		local v = target_plys[ i ]
		net.Start( "ulx_blind" )
			net.WriteBool( not should_unblind )
			net.WriteInt( amount, 16 )
		net.Send( v )
		if should_unblind then
			timer.Remove( "ulxBlind_" .. v:EntIndex() )
			if v.HadCamera then
				v:Give( "gmod_camera" )
			end
			v.HadCamera = nil
		else
			timer.Remove( "ulxBlind_" .. v:EntIndex() )
			if v.HadCamera == nil then
				v.HadCamera = v:HasWeapon( "gmod_camera" )
			end
			v:StripWeapon( "gmod_camera" )
			if duration and duration > 0 then
				timer.Create( "ulxBlind_" .. v:EntIndex(), duration, 1, function()
					if not v:IsValid() then return end
					net.Start( "ulx_blind" )
						net.WriteBool( false )
						net.WriteInt( 0, 16 )
					net.Send( v )
					if v.HadCamera then v:Give( "gmod_camera" ) end
					v.HadCamera = nil
				end )
			end
		end
	end
	if not should_unblind then
		if duration and duration > 0 then
			ulx.fancyLogKeyed(calling_ply, "fun_blind_duration", target_plys, amount, duration )
		else
			ulx.fancyLogKeyed(calling_ply, "fun_blind_log", target_plys, amount )
		end
	else
		ulx.fancyLogKeyed(calling_ply, "fun_unblind_log", target_plys )
	end
end
local blind = ulx.command( CATEGORY_NAME, "ulx blind", ulx.blind, "!blind" )
blind:addParam{ type=ULib.cmds.PlayersArg }
blind:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="blindness", ULib.cmds.round, ULib.cmds.optional }
blind:addParam{ type=ULib.cmds.NumArg, min=0, max=3600, default=0, hint="duration_perm", ULib.cmds.round, ULib.cmds.optional }
blind:addParam{ type=ULib.cmds.BoolArg, invisible=true }
blind:defaultAccess( ULib.ACCESS_ADMIN )
blind:help( L.T("fun_blind_help") )
blind:setOpposite( "ulx unblind", {_, _, _, _, true}, "!unblind" )
local doJail
local jailableArea
function ulx.jail( calling_ply, target_plys, seconds, should_unjail )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if not should_unjail then
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif not jailableArea( v:GetPos() ) then
				ULib.tsayError( calling_ply, v:Nick() .. " " .. L.T("fun_no_jail_pos"), true )
			else
				doJail( v, seconds )
				table.insert( affected_plys, v )
			end
		elseif v.jail then
			v.jail.unjail()
			v.jail = nil
			table.insert( affected_plys, v )
		end
	end
	if not should_unjail then
		if seconds > 0 then
			ulx.fancyLogKeyed(calling_ply, "fun_jail_time_log", affected_plys, seconds )
		else
			ulx.fancyLogKeyed(calling_ply, "fun_jail_log", affected_plys )
		end
	else
		ulx.fancyLogKeyed(calling_ply, "fun_unjail_log", affected_plys )
	end
end
local jail = ulx.command( CATEGORY_NAME, "ulx jail", ulx.jail, "!jail" )
jail:addParam{ type=ULib.cmds.PlayersArg }
jail:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="jail_seconds", ULib.cmds.round, ULib.cmds.optional }
jail:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jail:defaultAccess( ULib.ACCESS_ADMIN )
jail:help( L.T("fun_jail_help") )
jail:setOpposite( "ulx unjail", {_, _, _, true}, "!unjail" )
function ulx.jailtp( calling_ply, target_ply, seconds, should_unjail )
	if should_unjail then
		if target_ply.jail then
			target_ply.jail.unjail()
			target_ply.jail = nil
			ulx.fancyLogKeyed(calling_ply, "fun_unjail_log", target_ply )
		else
			ULib.tsayError( calling_ply, L.T("fun_unjailtp_not_jailed", target_ply:Nick()), true )
		end
		return
	end
	local shootPos = calling_ply:GetShootPos()
	local aimVec = calling_ply:GetAimVector()
	local tr = util.TraceLine( {
		start = shootPos,
		endpos = shootPos + aimVec * 16384,
		filter = { calling_ply, target_ply }
	} )
	local pos = tr.HitPos
	if not tr.Hit or pos:Distance(shootPos) > 8000 then
		pos = shootPos + aimVec * 256
		local ground = util.TraceLine( {
			start = pos + Vector(0, 0, 64),
			endpos = pos - Vector(0, 0, 512),
			filter = { calling_ply, target_ply }
		} )
		if ground.Hit then
			pos = ground.HitPos
		end
	end
	pos = pos + Vector(0, 0, 4)
	if ulx.getExclusive( target_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		return
	elseif not target_ply:Alive() then
		ULib.tsayError( calling_ply, L.T("fun_maul_dead", target_ply:Nick()), true )
		return
	elseif not jailableArea( pos ) then
		ULib.tsayError( calling_ply, L.T("fun_jail_cant_place"), true )
		return
	else
		target_ply.ulx_prevpos = target_ply:GetPos()
		target_ply.ulx_prevang = target_ply:EyeAngles()
		if target_ply:InVehicle() then
			target_ply:ExitVehicle()
		end
		target_ply:SetPos( pos )
		target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
		doJail( target_ply, seconds )
	end
	if seconds > 0 then
		ulx.fancyLogKeyed(calling_ply, "fun_jailtp_time_log", target_ply, seconds )
	else
		ulx.fancyLogKeyed(calling_ply, "fun_jailtp_log", target_ply )
	end
end
local jailtp = ulx.command( CATEGORY_NAME, "ulx jailtp", ulx.jailtp, "!jailtp" )
jailtp:addParam{ type=ULib.cmds.PlayerArg }
jailtp:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="jail_seconds", ULib.cmds.round, ULib.cmds.optional }
jailtp:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jailtp:defaultAccess( ULib.ACCESS_ADMIN )
jailtp:help( L.T("fun_jailtp_help") )
jailtp:setOpposite( "ulx unjailtp", {_, _, _, true}, "!unjailtp" )
local function jailCheck()
	local remove_timer = true
	local players = player.GetAll()
	for i=1, #players do
		local ply = players[ i ]
		if ply.jail then
			remove_timer = false
		end
		if ply.jail and (ply.jail.pos-ply:GetPos()):LengthSqr() >= 6500 then
			ply:SetPos( ply.jail.pos )
			if ply.jail.jail_until then
				doJail( ply, ply.jail.jail_until - CurTime() )
			else
				doJail( ply, 0 )
			end
		end
	end
	if remove_timer then
		timer.Remove( "ULXJail" )
	end
end
jailableArea = function( pos )
	local entList = ents.FindInBox( pos - Vector( 35, 35, 5 ), pos + Vector( 35, 35, 110 ) )
	for i=1, #entList do
		if entList[ i ]:GetClass() == "trigger_remove" then
			return false
		end
	end
	return true
end
local mdl1 = Model( "models/props_building_details/Storefront_Template001a_Bars.mdl" )
local jail = {
	{ pos = Vector( 0, 0, -5 ), ang = Angle( 90, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 0, 0, 97 ), ang = Angle( 90, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 21, 31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( 21, -31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -21, 31, 46 ), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -21, -31, 46), ang = Angle( 0, 90, 0 ), mdl=mdl1 },
	{ pos = Vector( -52, 0, 46 ), ang = Angle( 0, 0, 0 ), mdl=mdl1 },
	{ pos = Vector( 52, 0, 46 ), ang = Angle( 0, 0, 0 ), mdl=mdl1 },
}
doJail = function( v, seconds )
	if v.jail then
		v.jail.unjail()
	end
	if v:InVehicle() then
		local vehicle = v:GetParent()
		v:ExitVehicle()
		vehicle:Remove()
	end
	if v.physgunned_by then
		for ply, v in pairs( v.physgunned_by ) do
			local wep = ply:GetActiveWeapon()
			if IsValid( wep ) and wep:GetClass() == "weapon_physgun" then
				ply:ConCommand( "-attack" )
			end
		end
	end
	if v:GetMoveType() == MOVETYPE_NOCLIP then
		v:SetMoveType( MOVETYPE_WALK )
	end
	local pos = v:GetPos()
	local walls = {}
	for _, info in ipairs( jail ) do
		local ent = ents.Create( "prop_physics" )
		ent:SetModel( info.mdl )
		ent:SetPos( pos + info.pos )
		ent:SetAngles( info.ang )
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then phys:EnableMotion( false ) end
		ent:SetMoveType( MOVETYPE_NONE )
		ent.jailWall = true
		table.insert( walls, ent )
	end
	local key = {}
	local function unjail()
		if not v:IsValid() or not v.jail or v.jail.key ~= key then
			return
		end
		for _, ent in ipairs( walls ) do
			if ent:IsValid() then
				ent:DisallowDeleting( false )
				ent:Remove()
			end
		end
		if not v:IsValid() then return end
		v:DisallowNoclip( false )
		v:DisallowMoving( false )
		v:DisallowSpawning( false )
		v:DisallowVehicles( false )
		ulx.clearExclusive( v )
		ulx.setNoDie( v, false )
		v.jail = nil
	end
	if seconds > 0 then
		timer.Simple( seconds, unjail )
	end
	local function newWall( old, new )
		table.insert( walls, new )
	end
	for _, ent in ipairs( walls ) do
		ent:DisallowDeleting( true, newWall )
		ent:DisallowMoving( true )
	end
	v:DisallowNoclip( true )
	v:DisallowMoving( true )
	v:DisallowSpawning( true )
	v:DisallowVehicles( true )
	v.jail = { pos=pos, unjail=unjail, key=key }
	if seconds > 0 then
		v.jail.jail_until = CurTime() + seconds
	end
	ulx.setExclusive( v, "in jail" )
	ulx.setNoDie( v, true )
	timer.Create( "ULXJail", 1, 0, jailCheck )
end
local function jailDisconnectedCheck( ply )
	if ply.jail then
		ply.jail.unjail()
	end
end
hook.Add( "PlayerDisconnected", "ULXJailDisconnectedCheck", jailDisconnectedCheck, HOOK_MONITOR_HIGH )
local function playerPickup( ply, ent )
	if CLIENT then return end
	if ent:IsPlayer() then
		ent.physgunned_by = ent.physgunned_by or {}
		ent.physgunned_by[ ply ] = true
	end
end
hook.Add( "PhysgunPickup", "ulxPlayerPickupJailCheck", playerPickup, HOOK_MONITOR_HIGH )
local function playerDrop( ply, ent )
	if CLIENT then return end
	if ent:IsPlayer() and ent.physgunned_by then
		ent.physgunned_by[ ply ] = nil
	end
end
hook.Add( "PhysgunDrop", "ulxPlayerDropJailCheck", playerDrop )
function ulx.ragdollPlayer( v )
	if v:InVehicle() then
		v:ExitVehicle()
	end
	ULib.getSpawnInfo( v )
	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll.ragdolledPly = v
	ragdoll:SetPos( v:GetPos() )
	local velocity = v:GetVelocity()
	ragdoll:SetAngles( v:GetAngles() )
	ragdoll:SetModel( v:GetModel() )
	ragdoll:Spawn()
	ragdoll:Activate()
	v:SetParent( ragdoll )
	for j = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local phys_obj = ragdoll:GetPhysicsObjectNum( j )
		if IsValid( phys_obj ) then
			phys_obj:SetVelocity( velocity )
		end
	end
	v:Spectate( OBS_MODE_CHASE )
	v:SpectateEntity( ragdoll )
	v:StripWeapons()
	ragdoll:DisallowDeleting( true, function( _, new )
		if v:IsValid() then v.ragdoll = new end
	end )
	v:DisallowSpawning( true )
	v.ragdoll = ragdoll
	ulx.setExclusive( v, "ragdolled" )
end
function ulx.unragdollPlayer( v )
	v:DisallowSpawning( false )
	v:SetParent()
	v:UnSpectate()
	local ragdoll = v.ragdoll
	v.ragdoll = nil
	if not ragdoll:IsValid() then
		ULib.spawn( v, true )
	else
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10
		ULib.spawn( v, true )
		v:SetPos( pos )
		v:SetVelocity( ragdoll:GetVelocity() )
		local yaw = ragdoll:GetAngles().yaw
		v:SetAngles( Angle( 0, yaw, 0 ) )
		ragdoll:DisallowDeleting( false )
		ragdoll:Remove()
	end
	ulx.clearExclusive( v )
end
function ulx.ragdoll( calling_ply, target_plys, should_unragdoll )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if not should_unragdoll then
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif not v:Alive() then
				ULib.tsayError( calling_ply, L.T("fun_ragdoll_dead", v:Nick()), true )
			else
				ulx.ragdollPlayer( v )
				table.insert( affected_plys, v )
			end
		elseif v.ragdoll then
			ulx.unragdollPlayer( v )
			table.insert( affected_plys, v )
		end
	end
	if not should_unragdoll then
		ulx.fancyLogKeyed(calling_ply, "fun_ragdoll_log", affected_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "fun_unragdoll_log", affected_plys )
	end
end
local ragdoll = ulx.command( CATEGORY_NAME, "ulx ragdoll", ulx.ragdoll, "!ragdoll" )
ragdoll:addParam{ type=ULib.cmds.PlayersArg }
ragdoll:addParam{ type=ULib.cmds.BoolArg, invisible=true }
ragdoll:defaultAccess( ULib.ACCESS_ADMIN )
ragdoll:help( L.T("fun_ragdoll_help") )
ragdoll:setOpposite( "ulx unragdoll", {_, _, true}, "!unragdoll" )
local function ragdollSpawnCheck( ply )
	if ply.ragdoll then
		timer.Simple( 0.01, function()
			if not ply:IsValid() then return end
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity( ply.ragdoll )
			ply:StripWeapons()
		end )
	end
end
hook.Add( "PlayerSpawn", "ULXRagdollSpawnCheck", ragdollSpawnCheck )
local function ragdollDisconnectedCheck( ply )
	if ply.ragdoll then
		ply.ragdoll:DisallowDeleting( false )
		ply.ragdoll:Remove()
	end
end
hook.Add( "PlayerDisconnected", "ULXRagdollDisconnectedCheck", ragdollDisconnectedCheck, HOOK_MONITOR_HIGH )
local function removeRagdollOnCleanup()
	local players = player.GetAll()
	for i=1, #players do
		local ply = players[i]
		if ply.ragdoll then
			ply.ragdollAfterCleanup = true
			ulx.unragdollPlayer( ply )
		end
	end
end
hook.Add("PreCleanupMap","ULXRagdollBeforeCleanup", removeRagdollOnCleanup )
local function createRagdollAfterCleanup()
	local players = player.GetAll()
	for i=1, #players do
		local ply = players[i]
		if ply.ragdollAfterCleanup then
			ply.ragdollAfterCleanup = nil
			timer.Simple( 0.1, function()
				ulx.ragdollPlayer( ply )
			end)
		end
	end
end
hook.Add("PostCleanupMap","ULXRagdollAfterCleanup", createRagdollAfterCleanup )
local zombieDeath
local checkMaulDeath
local function newZombie( pos, ang, ply, b )
		local ent = ents.Create( "npc_fastzombie" )
		ent:SetPos( pos )
		ent:SetAngles( ang )
		ent:Spawn()
		ent:Activate()
		ent:AddRelationship("player D_NU 98")
		ent:AddEntityRelationship( ply, D_HT, 99 )
		ent:DisallowDeleting( true, _, true )
		ent:DisallowMoving( true )
		if not b then
			ent:CallOnRemove( "NoDie", zombieDeath, ply )
		end
		return ent
end
zombieDeath = function( ent, ply )
	if ply.maul_npcs then
		local pos = ent:GetPos()
		local ang = ent:GetAngles()
		ULib.queueFunctionCall( function()
			if not ply:IsValid() then return end
			local ent2 = newZombie( pos, ang, ply )
			table.insert( ply.maul_npcs, ent2 )
			local crabs = ents.FindByClass( "npc_headcrab_fast" )
			for _, ent in ipairs( crabs ) do
				local dist = ent:GetPos():Distance( pos )
				if dist < 128 then
					ent:Remove()
				end
			end
		end )
	end
end
local function maulMoreDamage()
	local players = player.GetAll()
	for _, ply in ipairs( players ) do
		if ply.maul_npcs and ply:Alive() then
			if CurTime() > ply.maulStart + 10 then
				local damage = math.ceil( ply.maulStartHP / 10 )
				damage = damage * FrameTime()
				damage = math.ceil( damage )
				local newhp = ply:Health() - damage
				if newhp < 1 then newhp = 1 end
				ply:SetHealth( newhp )
				if CurTime() > ply.maulStart + 20 then
					ply:Kill()
					checkMaulDeath( ply )
				end
			end
			ply.maul_lasthp = ply:Health()
		end
	end
end
function ulx.maul( calling_ply, target_plys )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, v:Nick() .. " " .. L.T("fun_already_dead") .. "!", true )
		else
			local pos = {}
			local testent = newZombie( Vector( 0, 0, 0 ), Angle( 0, 0, 0 ), v, true )
			local yawForward = v:EyeAngles().yaw
			local directions = {
				math.NormalizeAngle( yawForward - 180 ),
				math.NormalizeAngle( yawForward + 90 ),
				math.NormalizeAngle( yawForward - 90 ),
				yawForward,
			}
			local t = {}
			t.start = v:GetPos() + Vector( 0, 0, 32 )
			t.filter = { v, testent }
			for i=1, #directions do
				t.endpos = v:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47
				local tr = util.TraceEntity( t, testent )
				if not tr.Hit then
					table.insert( pos, v:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47 )
				end
			end
			testent:DisallowDeleting( false )
			testent:Remove()
			if #pos > 0 then
				v.maul_npcs = {}
				for _, newpos in ipairs( pos ) do
					local newang = (v:GetPos() - newpos):Angle()
					local ent = newZombie( newpos, newang, v )
					table.insert( v.maul_npcs, ent )
				end
				v:SetMoveType( MOVETYPE_WALK )
				v:DisallowNoclip( true )
				v:DisallowSpawning( true )
				v:DisallowVehicles( true )
				v:GodDisable()
				v:SetArmor( 0 )
				v.maulOrigWalk = v:GetWalkSpeed()
				v.maulOrigSprint = v:GetRunSpeed()
				v:SetWalkSpeed(1)
				v:SetRunSpeed(1)
				v.maulStart = CurTime()
				v.maulStartHP = v:Health()
				hook.Add( "Think", "MaulMoreDamageThink", maulMoreDamage )
				ulx.setExclusive( v, "being mauled" )
				table.insert( affected_plys, v )
			else
				ULib.tsayError( calling_ply, L.T("fun_maul_no_pos", v:Nick()), true )
			end
		end
	end
	ulx.fancyLogKeyed(calling_ply, "fun_maul_log", affected_plys )
end
local maul = ulx.command( CATEGORY_NAME, "ulx maul", ulx.maul, "!maul" )
maul:addParam{ type=ULib.cmds.PlayersArg }
maul:defaultAccess( ULib.ACCESS_SUPERADMIN )
maul:help( L.T("fun_maul_help") )
checkMaulDeath = function( ply, weapon, killer )
	if ply.maul_npcs then
		if killer == ply and CurTime() < ply.maulStart + 20 then
			ply:AddFrags( 1 )
			local pos = ply:GetPos()
			local ang = ply:EyeAngles()
			ULib.queueFunctionCall( function()
				if not ply:IsValid() then return end
				ply:Spawn()
				ply:SetPos( pos )
				ply:SetEyeAngles( ang )
				ply:SetArmor( 0 )
				ply:SetHealth( ply.maul_lasthp )
				timer.Simple( 0.1, function()
					if not ply:IsValid() then return end
					ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
					ply:SetWalkSpeed(1)
					ply:SetRunSpeed(1)
				end )
			end )
			return true
		end
		local npcs = ply.maul_npcs
		ply.maul_npcs = nil
		for _, ent in ipairs( npcs ) do
			if ent:IsValid() then
				ent:DisallowDeleting( false )
				ent:Remove()
			end
		end
		ulx.clearExclusive( ply )
		ply.maulStart = nil
		ply.maul_lasthp = nil
		ply:DisallowNoclip( false )
		ply:DisallowSpawning( false )
		ply:DisallowVehicles( false )
		ply:SetWalkSpeed(ply.maulOrigWalk)
		ply:SetRunSpeed(ply.maulOrigSprint)
		ply.maulOrigWalk = nil
		ply.maulOrigSprint = nil
		ulx.clearExclusive( ply )
		local players = player.GetAll()
		for _, ply in ipairs( players ) do
			if ply.maul_npcs then
				return
			end
		end
		hook.Remove( "Think", "MaulMoreDamageThink" )
	end
end
hook.Add( "PlayerDeath", "ULXCheckMaulDeath", checkMaulDeath, HOOK_HIGH )
local function maulDisconnectedCheck( ply )
	checkMaulDeath( ply )
end
hook.Add( "PlayerDisconnected", "ULXMaulDisconnectedCheck", maulDisconnectedCheck, HOOK_MONITOR_HIGH )
hook.Add( "PlayerDisconnected", "ULXFunCleanupTimers", function(ply)
	local eid = ply:EntIndex()
	for _, prefix in ipairs({"ulxRegen_","ulxArmorRegen_","ulxWhip_","ulxBlind_","ulxJail_"}) do
		timer.Remove(prefix .. eid)
	end
end, HOOK_MONITOR_HIGH)
function ulx.stripweapons( calling_ply, target_plys )
	for i=1, #target_plys do
		target_plys[ i ]:StripWeapons()
	end
	ulx.fancyLogKeyed(calling_ply, "fun_strip_log", target_plys )
end
local strip = ulx.command( CATEGORY_NAME, "ulx strip", ulx.stripweapons, "!strip" )
strip:addParam{ type=ULib.cmds.PlayersArg }
strip:defaultAccess( ULib.ACCESS_ADMIN )
strip:help( L.T("fun_strip_help") )