local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_utility"
if SERVER then
	function ulx.cleanup( calling_ply )
		game.CleanUpMap( false, { "player", "prop_vehicle*" } )
		ulx.fancyLogKeyed(calling_ply, "ext_cleanup_log" )
	end
end
local cleanupCmd = ulx.command( CATEGORY_NAME, "ulx cleanup", ulx.cleanup, "!cleanup" )
cleanupCmd:defaultAccess( ULib.ACCESS_ADMIN )
cleanupCmd:help( L.T("help_cleanup") )
if SERVER then
	function ulx.respawn( calling_ply, target_plys )
		local affected = {}
		for _, ply in ipairs( target_plys ) do
			if not ply:Alive() then
				ply:UnSpectate()
				local teamId = ply:Team()
				if teamId == TEAM_SPECTATOR or teamId == TEAM_UNASSIGNED then
					for tid, _ in pairs( team.GetAllTeams() ) do
						if tid ~= TEAM_SPECTATOR and tid ~= TEAM_UNASSIGNED then
							ply:SetTeam( tid )
							break
						end
					end
				end
				if ROLE_INNOCENT and ply.SetRole then
					pcall( ply.SetRole, ply, ROLE_INNOCENT )
				end
				if ply.SetSubRole then
					pcall( ply.SetSubRole, ply, 1 )
				end
				ply:Spawn()
				table.insert( affected, ply )
			end
		end
		if #affected > 0 then
			ulx.fancyLogKeyed(calling_ply, "ext_respawn_log", affected )
		else
			ULib.tsayError( calling_ply, L.T("ext_already_alive"), true )
		end
	end
end
local respawnCmd = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn" )
respawnCmd:addParam{ type=ULib.cmds.PlayersArg }
respawnCmd:defaultAccess( ULib.ACCESS_ADMIN )
respawnCmd:help( L.T("help_respawn") )
if SERVER then
	function ulx.setmodel( calling_ply, target_plys, model_path )
		model_path = ulx.standardizeModel( model_path )
		if not util.IsValidModel( model_path ) then
			ULib.tsayError( calling_ply, string.format(L.T("ext_invalid_model"), model_path), true )
			return
		end
		for _, ply in ipairs( target_plys ) do
			ply:SetModel( model_path )
		end
		ulx.fancyLogKeyed(calling_ply, "ext_setmodel_log", target_plys, model_path )
	end
end
local setmodelCmd = ulx.command( CATEGORY_NAME, "ulx setmodel", ulx.setmodel, "!setmodel" )
setmodelCmd:addParam{ type=ULib.cmds.PlayersArg }
setmodelCmd:addParam{ type=ULib.cmds.StringArg, hint="model_path", ULib.cmds.takeRestOfLine }
setmodelCmd:defaultAccess( ULib.ACCESS_ADMIN )
setmodelCmd:help( L.T("help_setmodel") )
if SERVER then
	function ulx.setteam( calling_ply, target_plys, team_id )
		team_id = tonumber( team_id )
		if not team_id then
			ULib.tsayError( calling_ply, L.T("ext_invalid_team"), true )
			return
		end
		local affected = {}
		for _, ply in ipairs( target_plys ) do
			if ply:Team() ~= team_id then
				ply:SetTeam( team_id )
				table.insert( affected, ply )
			end
		end
		if #affected > 0 then
			ulx.fancyLogKeyed(calling_ply, "ext_setteam_log", affected, team_id )
		end
	end
end
local setteamCmd = ulx.command( CATEGORY_NAME, "ulx setteam", ulx.setteam, "!setteam" )
setteamCmd:addParam{ type=ULib.cmds.PlayersArg }
setteamCmd:addParam{ type=ULib.cmds.NumArg, min=1, max=32, hint="team_id", ULib.cmds.round }
setteamCmd:defaultAccess( ULib.ACCESS_ADMIN )
setteamCmd:help( L.T("help_setteam") )
if SERVER then
	function ulx.giveweapon( calling_ply, target_plys, weapon_class )
		weapon_class = weapon_class:lower()
		if not weapon_class:find( "^weapon_" ) and not weapon_class:find( "^gmod_" ) then
			weapon_class = "weapon_" .. weapon_class
		end
		local testWep = weapons.GetStored( weapon_class )
		if not testWep then
			ULib.tsayError( calling_ply, string.format(L.T("ext_invalid_weapon"), weapon_class), true )
			return
		end
		local affected = {}
		for _, ply in ipairs( target_plys ) do
			if ply:Alive() then
				ply:Give( weapon_class )
				table.insert( affected, ply )
			end
		end
		if #affected > 0 then
			ulx.fancyLogKeyed(calling_ply, "ext_giveweapon_log", affected, weapon_class )
		end
	end
end
local giveweaponCmd = ulx.command( CATEGORY_NAME, "ulx giveweapon", ulx.giveweapon, "!giveweapon" )
giveweaponCmd:addParam{ type=ULib.cmds.PlayersArg }
giveweaponCmd:addParam{ type=ULib.cmds.StringArg, hint="weapon_class", ULib.cmds.takeRestOfLine }
giveweaponCmd:defaultAccess( ULib.ACCESS_ADMIN )
giveweaponCmd:help( L.T("help_giveweapon") )
if SERVER then
	util.AddNetworkString( "ulx_scale_sync" )
	ulx_playerscales = ulx_playerscales or {}; hook.Add("PlayerDisconnected", "ULXScaleCleanup", function(p) ulx_playerscales[p:SteamID64()] = nil end)
	local function applyScale( ply, scale_val )
		scale_val = math.Clamp( scale_val, 0.1, 10 )
		ply:SetModelScale( scale_val, 0 )
		ply:SetViewOffset( Vector( 0, 0, 64 * scale_val ) )
		ply:SetViewOffsetDucked( Vector( 0, 0, 28 * scale_val ) )
		if scale_val > 1 then
			ply:SetJumpPower( 200 * scale_val )
			ply:SetGravity( 2.0 - scale_val / 10 )
			ply:SetWalkSpeed( 200 * scale_val )
			ply:SetRunSpeed( 400 * scale_val )
		else
			ply:SetJumpPower( 200 )
			ply:SetGravity( 1 )
			ply:SetWalkSpeed( 200 )
			ply:SetRunSpeed( 400 )
		end
		net.Start( "ulx_scale_sync" )
		net.WriteFloat( scale_val )
		net.Send( ply )
	end
	function ulx.scale( calling_ply, target_plys, scale_val )
		scale_val = math.Clamp( scale_val, 0.1, 10 )
		for _, ply in ipairs( target_plys ) do
			ulx_playerscales[ ply:SteamID64() ] = scale_val
			applyScale( ply, scale_val )
		end
		ulx.fancyLogKeyed(calling_ply, "ext_scale_log", target_plys, scale_val )
	end
	hook.Add( "PlayerSpawn", "ULXScaleRespawn", function( ply )
		local scale = ulx_playerscales[ ply:SteamID64() ]
		if scale and scale ~= 1 then
			timer.Simple( 0.1, function()
				if ply:IsValid() then applyScale( ply, scale ) end
			end )
		end
	end )
	hook.Add( "GetFallDamage", "ULXScaleFall", function( ply, speed )
		local scale = ulx_playerscales[ ply:SteamID64() ]
		if scale and scale > 1 then
			local s = speed / scale
			local safeSpeed = 350
			if s < safeSpeed then return 0 end
			return ( s - safeSpeed ) * ( 100 / 350 )
		end
	end )
	hook.Add( "OnPlayerHitGround", "ULXScaleHitGround", function( ply, inWater, onFloater, speed )
		local scale = ulx_playerscales[ ply:SteamID64() ]
		if scale and scale > 1 and speed / scale < 350 then
			return true
		end
	end )
end
local scaleCmd = ulx.command( CATEGORY_NAME, "ulx scale", ulx.scale, "!scale" )
scaleCmd:addParam{ type=ULib.cmds.PlayersArg }
scaleCmd:addParam{ type=ULib.cmds.NumArg, min=0.1, max=10, default=1, hint="scale" }
scaleCmd:defaultAccess( ULib.ACCESS_ADMIN )
scaleCmd:help( L.T("help_scale") )
if SERVER then
	function ulx.setgravity( calling_ply, target_plys, grav )
		grav = math.Clamp( grav, 0, 6 )
		for _, ply in ipairs( target_plys ) do
			ply:SetGravity( grav )
		end
		ulx.fancyLogKeyed(calling_ply, "ext_gravity_log", target_plys, grav )
	end
end
local gravityCmd = ulx.command( CATEGORY_NAME, "ulx gravity", ulx.setgravity, "!gravity" )
gravityCmd:addParam{ type=ULib.cmds.PlayersArg }
gravityCmd:addParam{ type=ULib.cmds.NumArg, min=0, max=6, default=1, hint="gravity" }
gravityCmd:defaultAccess( ULib.ACCESS_ADMIN )
gravityCmd:help( L.T("help_gravity") )
if not ulx._silentReReg then Msg( L.T("ext_loaded") .. "\n" ) end
if CLIENT then
	ulx_playerscale = ulx_playerscale or 1
	net.Receive( "ulx_scale_sync", function()
		ulx_playerscale = net.ReadFloat()
	end )
end