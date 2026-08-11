local slapSounds = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
	"physics/body/body_medium_impact_soft5.wav",
	"physics/body/body_medium_impact_soft6.wav",
	"physics/body/body_medium_impact_soft7.wav",
}
function ULib.slap( ent, damage, power, nosound )
	if ent:GetMoveType() == MOVETYPE_OBSERVER then return end
	damage = damage or 0
	power = power or 500
	if ent:IsPlayer() then
		if not ent:Alive() then
			return
		end
		if ent:InVehicle() then
			ent:ExitVehicle()
		end
		if ent:GetMoveType() == MOVETYPE_NOCLIP then
			ent:SetMoveType( MOVETYPE_WALK )
		end
	end
	if not nosound then
		local sound_num = math.random( #slapSounds )
		ent:EmitSound( slapSounds[ sound_num ] )
	end
	local direction = Vector( math.random( 20 )-10, math.random( 20 )-10, math.random( 20 )-5 )
	ULib.applyAccel( ent, power, direction )
	local angle_punch_pitch = math.Rand( -20, 20 )
	local angle_punch_yaw = math.sqrt( 20*20 - angle_punch_pitch * angle_punch_pitch )
	if math.random( 0, 1 ) == 1 then
		angle_punch_yaw = angle_punch_yaw * -1
	end
	ent:ViewPunch( Angle( angle_punch_pitch, angle_punch_yaw, 0 ) )
	local newHp = ent:Health() - damage
	if newHp <= 0 then
		if ent:IsPlayer() then
			ent:Kill()
		else
			ent:Fire( "break", 1, 0 )
		end
		return
	end
	ent:SetHealth( newHp )
end
function ULib.kick( ply, reason, calling_ply, silent )
	local nick = (IsValid( calling_ply ) and string.format( "%s(%s)", calling_ply:Nick(), calling_ply:SteamID() )) or "Console"
	local steamid = ply:SteamID()
	if reason and nick then
		ply:Kick( string.format( ULib.ulx_lang.T("kick_format_with_reason"), nick, reason ) )
	elseif nick then
		ply:Kick( string.format( ULib.ulx_lang.T("kick_format_no_reason"), nick ) )
	else
		ply:Kick( reason or ULib.ulx_lang.T("kick_default_reason") )
	end
	if not silent then
		hook.Call( ULib.HOOK_USER_KICKED, _, steamid, reason or ULib.ulx_lang.T("kick_default_reason"), calling_ply )
	end
end
local function doInvis()
	local remove = true
	for _, player in player.Iterator() do
		local t = player:GetTable()
		if t.invis then
			remove = false
			if player:Alive() and IsValid( player:GetActiveWeapon() ) then
				if player:GetActiveWeapon() ~= t.invis.wep then
					if t.invis.wep and IsValid( t.invis.wep ) then
						t.invis.wep:SetRenderMode( RENDERMODE_NORMAL )
						t.invis.wep:Fire( "alpha", 255, 0 )
						t.invis.wep:SetMaterial( "" )
					end
					t.invis.wep = player:GetActiveWeapon()
					ULib.invisible( player, true, t.invis.vis )
				end
			end
		end
	end
	if remove then
		hook.Remove( "Think", "InvisThink" )
	end
end
function ULib.invisible( ply, bool, visibility )
	if not ply:IsValid() then return end
	if bool then
		visibility = visibility or 0
		ply:DrawShadow( false )
		ply:SetMaterial( "models/effects/vol_light001" )
		ply:SetRenderMode( RENDERMODE_TRANSALPHA )
		ply:Fire( "alpha", visibility, 0 )
		ply:GetTable().invis = { vis=visibility, wep=ply:GetActiveWeapon() }
		if IsValid( ply:GetActiveWeapon() ) then
			ply:GetActiveWeapon():SetRenderMode( RENDERMODE_TRANSALPHA )
			ply:GetActiveWeapon():Fire( "alpha", visibility, 0 )
			ply:GetActiveWeapon():SetMaterial( "models/effects/vol_light001" )
			if ply:GetActiveWeapon():GetClass() == "gmod_tool" then
				ply:DrawWorldModel( false )
			else
				ply:DrawWorldModel( true )
			end
		end
		hook.Add( "Think", "InvisThink", doInvis )
	else
		ply:DrawShadow( true )
		ply:SetMaterial( "" )
		ply:SetRenderMode( RENDERMODE_NORMAL )
		ply:Fire( "alpha", 255, 0 )
		local activeWeapon = ply:GetActiveWeapon()
		if IsValid( activeWeapon ) then
			activeWeapon:SetRenderMode( RENDERMODE_NORMAL )
			activeWeapon:Fire( "alpha", 255, 0 )
			activeWeapon:SetMaterial( "" )
		end
		ply:GetTable().invis = nil
	end
end
function ULib.getSpawnInfo( ply )
	local t = {}
	ply.ULibSpawnInfo = t
	t.health = ply:Health()
	t.armor = ply:Armor()
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) then
		t.curweapon = wep:GetClass()
	end
	local data = {}
	local weapons = ply:GetWeapons()
	for _, weapon in ipairs( weapons ) do
		local class = weapon:GetClass()
		data[ class ] = {}
		data[ class ].clip1 = weapon:Clip1()
		data[ class ].clip2 = weapon:Clip2()
		data[ class ].ammo1 = ply:GetAmmoCount( weapon:GetPrimaryAmmoType() )
		data[ class ].ammo2 = ply:GetAmmoCount( weapon:GetSecondaryAmmoType() )
	end
	t.data = data
end
local function doWeapons( player, t )
	if not player:IsValid() then return end
	player:StripAmmo()
	player:StripWeapons()
	for class, data in pairs( t.data ) do
		local weapon = player:Give( class )
		if not IsValid( weapon ) then
			weapon = player:GetWeapon( class )
		end
		if IsValid( weapon ) then
			if weapon.SetClip1 then
				weapon:SetClip1( data.clip1 )
			end
			if weapon.SetClip2 then
				weapon:SetClip2( data.clip2 )
			end
			player:SetAmmo( data.ammo1, weapon:GetPrimaryAmmoType() )
			player:SetAmmo( data.ammo2, weapon:GetSecondaryAmmoType() )
		end
	end
	if t.curweapon then
		player:SelectWeapon( t.curweapon )
	end
end
function ULib.spawn( player, bool )
	if not player:IsValid() then return end
	player:UnSpectate()
	local teamId = player:Team()
	if teamId == TEAM_SPECTATOR or teamId == TEAM_UNASSIGNED then
		for tid, _ in pairs( team.GetAllTeams() ) do
			if tid ~= TEAM_SPECTATOR and tid ~= TEAM_UNASSIGNED then
				player:SetTeam( tid )
				break
			end
		end
	end
	if ROLE_INNOCENT and player.SetRole then
		pcall( player.SetRole, player, ROLE_INNOCENT )
	end
	if player.SetSubRole then
		pcall( player.SetSubRole, player, 1 )
	end
	player:Spawn()
	if not player:Alive() then
		player:Spawn()
	end
	if bool and player.ULibSpawnInfo then
		local t = player.ULibSpawnInfo
		player:SetHealth( t.health )
		player:SetArmor( t.armor )
		timer.Simple( 0.1, function() doWeapons( player, t ) end )
		player.ULibSpawnInfo = nil
	end
end