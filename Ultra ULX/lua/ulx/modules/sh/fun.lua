local CATEGORY_NAME = "娱乐"
function ulx.slap( calling_ply, target_plys, dmg )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		else
			ULib.slap( v, dmg )
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A slapped #T with #i damage", affected_plys, dmg )
end
local slap = ulx.command( CATEGORY_NAME, "ulx slap", ulx.slap, "!slap" )
slap:addParam{ type=ULib.cmds.PlayersArg }
slap:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="伤害值", ULib.cmds.optional, ULib.cmds.round }
slap:defaultAccess( ULib.ACCESS_ADMIN )
slap:help( "扇目标巴掌造成伤害" )
function ulx.whip( calling_ply, target_plys, times, freq, dmg, should_stop )
	if should_stop or times == 0 then
		for _, v in ipairs( target_plys ) do
			timer.Remove( "ulxWhip_" .. v:EntIndex() )
		end
		ulx.fancyLogAdmin( calling_ply, "#A 停止了连续迫害 #T", target_plys )
		return
	end
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
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
	ulx.fancyLogAdmin( calling_ply, "#A 连续扇 #T #i 次 (频率:#ix/秒 伤害:#i)", affected_plys, times, freq or 2, dmg )
end
local whip = ulx.command( CATEGORY_NAME, "ulx whip", ulx.whip, "!whip" )
whip:addParam{ type=ULib.cmds.PlayersArg }
whip:addParam{ type=ULib.cmds.NumArg, min=1, max=9999, default=10, hint="次数", ULib.cmds.optional, ULib.cmds.round }
whip:addParam{ type=ULib.cmds.NumArg, min=0.1, max=100, default=2, hint="频率/秒", ULib.cmds.optional }
whip:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="伤害值", ULib.cmds.optional, ULib.cmds.round }
whip:addParam{ type=ULib.cmds.BoolArg, invisible=true }
whip:defaultAccess( ULib.ACCESS_ADMIN )
whip:help( "连续扇目标指定次数，!unwhip 停止" )
whip:setOpposite( "ulx unwhip", {_, _, _, _, _, true}, "!unwhip" )
function ulx.slay( calling_ply, target_plys )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, v:Nick() .. " 已经死了！", true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " 已被冻结！", true )
		else
			v:Kill()
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A 杀死了 #T", affected_plys )
end
local slay = ulx.command( CATEGORY_NAME, "ulx slay", ulx.slay, "!slay" )
slay:addParam{ type=ULib.cmds.PlayersArg }
slay:defaultAccess( ULib.ACCESS_ADMIN )
slay:help( "直接杀死目标" )
function ulx.sslay( calling_ply, target_plys )
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		elseif not v:Alive() then
			ULib.tsayError( calling_ply, v:Nick() .. " 已经死了！", true )
		elseif v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " 已被冻结！", true )
		else
			if v:InVehicle() then
				v:ExitVehicle()
			end
			v:KillSilent()
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A 静默杀死了 #T", affected_plys )
end
local sslay = ulx.command( CATEGORY_NAME, "ulx sslay", ulx.sslay, "!sslay" )
sslay:addParam{ type=ULib.cmds.PlayersArg }
sslay:defaultAccess( ULib.ACCESS_SUPERADMIN )
sslay:help( "静默杀死目标，不显示死亡消息" )
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
		ulx.fancyLogAdmin( calling_ply, "#A 点燃了 #T #i 秒", affected_plys, seconds )
	else
		ulx.fancyLogAdmin( calling_ply, "#A 熄灭了 #T 的火焰", affected_plys )
	end
end
local ignite = ulx.command( CATEGORY_NAME, "ulx ignite", ulx.ignite, "!ignite" )
ignite:addParam{ type=ULib.cmds.PlayersArg }
ignite:addParam{ type=ULib.cmds.NumArg, min=1, max=300, default=300, hint="秒数", ULib.cmds.optional, ULib.cmds.round }
ignite:addParam{ type=ULib.cmds.BoolArg, invisible=true }
ignite:defaultAccess( ULib.ACCESS_ADMIN )
ignite:help( "点燃目标持续灼烧，!unignite 熄灭" )
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
	ulx.fancyLogAdmin( calling_ply, "#A 熄灭了所有火焰" )
end
local unigniteall = ulx.command( CATEGORY_NAME, "ulx unigniteall", ulx.unigniteall, "!unigniteall" )
unigniteall:defaultAccess( ULib.ACCESS_ADMIN )
unigniteall:help( "熄灭所有玩家和实体的火焰" )
if SERVER then
	util.AddNetworkString( "ulib_sound" )
end
function ulx.playsound( calling_ply, sound )
	if not ULib.fileExists( "sound/" .. sound ) then
		ULib.tsayError( calling_ply, "服务器上不存在该音效！", true )
		return
	end
	net.Start( "ulib_sound" )
		net.WriteString( Sound( sound ) )
	net.Broadcast()
	ulx.fancyLogAdmin( calling_ply, "#A 播放了音效 #s", sound )
end
local playsound = ulx.command( CATEGORY_NAME, "ulx playsound", ulx.playsound, "!playsound" )
playsound:addParam{ type=ULib.cmds.StringArg, hint="音效路径", autocomplete_fn=ulx.soundComplete }
playsound:defaultAccess( ULib.ACCESS_ADMIN )
playsound:help( "服务器广播播放音效文件" )
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
		ulx.fancyLogAdmin( calling_ply, "#A 冻结了 #T", affected_plys )
	else
		ulx.fancyLogAdmin( calling_ply, "#A 解冻了 #T", affected_plys )
	end
end
local freeze = ulx.command( CATEGORY_NAME, "ulx freeze", ulx.freeze, "!freeze" )
freeze:addParam{ type=ULib.cmds.PlayersArg }
freeze:addParam{ type=ULib.cmds.BoolArg, invisible=true }
freeze:defaultAccess( ULib.ACCESS_ADMIN )
freeze:help( "冻结目标无法移动，!unfreeze 解除" )
freeze:setOpposite( "ulx unfreeze", {_, _, true}, "!unfreeze" )
function ulx.god( calling_ply, target_plys, should_revoke )
	if not target_plys[ 1 ]:IsValid() then
		if not should_revoke then
			Msg( "You are the console, you are already god.\n" )
		else
			Msg( "Your position of god is irrevocable; if you don't like it, leave the matrix.\n" )
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
		ulx.fancyLogAdmin( calling_ply, "#A 给予 #T 无敌模式", affected_plys )
	else
		ulx.fancyLogAdmin( calling_ply, "#A 取消 #T 无敌模式", affected_plys )
	end
end
local god = ulx.command( CATEGORY_NAME, "ulx god", ulx.god, "!god" )
god:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional }
god:addParam{ type=ULib.cmds.BoolArg, invisible=true }
god:defaultAccess( ULib.ACCESS_ADMIN )
god:help( "给予目标无敌模式，!ungod 解除" )
god:setOpposite( "ulx ungod", {_, _, true}, "!ungod" )
function ulx.hp( calling_ply, target_plys, amount )
	for i=1, #target_plys do
		target_plys[ i ]:SetHealth( amount )
	end
	ulx.fancyLogAdmin( calling_ply, "#A 设置 #T 生命值为 #i", target_plys, amount )
end
local hp = ulx.command( CATEGORY_NAME, "ulx hp", ulx.hp, "!hp" )
hp:addParam{ type=ULib.cmds.PlayersArg }
hp:addParam{ type=ULib.cmds.NumArg, min=1, max=2^32/2-1, hint="生命值", ULib.cmds.round }
hp:defaultAccess( ULib.ACCESS_ADMIN )
hp:help( "设置目标的生命值" )
function ulx.armor( calling_ply, target_plys, amount )
	for i=1, #target_plys do
		target_plys[ i ]:SetArmor( amount )
	end
	ulx.fancyLogAdmin( calling_ply, "#A 设置 #T 护甲值为 #i", target_plys, amount )
end
local armor = ulx.command( CATEGORY_NAME, "ulx armor", ulx.armor, "!armor" )
armor:addParam{ type=ULib.cmds.PlayersArg }
armor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, hint="护甲值", ULib.cmds.round }
armor:defaultAccess( ULib.ACCESS_ADMIN )
armor:help( "设置目标的护甲值" )
function ulx.cloak( calling_ply, target_plys, amount, should_uncloak )
	if not target_plys[ 1 ]:IsValid() then
		Msg( "You are always invisible.\n" )
		return
	end
	amount = 255 - amount
	for i=1, #target_plys do
		ULib.invisible( target_plys[ i ], not should_uncloak, amount )
	end
	if not should_uncloak then
		ulx.fancyLogAdmin( calling_ply, "#A 隐身 #T 透明度 #i", target_plys, amount )
	else
		ulx.fancyLogAdmin( calling_ply, "#A 取消 #T 隐身", target_plys )
	end
end
local cloak = ulx.command( CATEGORY_NAME, "ulx cloak", ulx.cloak, "!cloak" )
cloak:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional }
cloak:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="透明度", ULib.cmds.round, ULib.cmds.optional }
cloak:addParam{ type=ULib.cmds.BoolArg, invisible=true }
cloak:defaultAccess( ULib.ACCESS_ADMIN )
cloak:help( "使目标隐身，!uncloak 恢复可见" )
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
		local durStr = duration and duration > 0 and (" (" .. duration .. "秒)") or ""
		ulx.fancyLogAdmin( calling_ply, "#A blinded #T by amount #i" .. durStr, target_plys, amount )
	else
		ulx.fancyLogAdmin( calling_ply, "#A unblinded #T", target_plys )
	end
end
local blind = ulx.command( CATEGORY_NAME, "ulx blind", ulx.blind, "!blind" )
blind:addParam{ type=ULib.cmds.PlayersArg }
blind:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="黑屏程度", ULib.cmds.round, ULib.cmds.optional }
blind:addParam{ type=ULib.cmds.NumArg, min=0, max=3600, default=0, hint="持续时间/秒 (0=永久)", ULib.cmds.round, ULib.cmds.optional }
blind:addParam{ type=ULib.cmds.BoolArg, invisible=true }
blind:defaultAccess( ULib.ACCESS_ADMIN )
blind:help( "使目标屏幕变黑，!unblind 解除。可指定持续时间" )
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
				ULib.tsayError( calling_ply, v:Nick() .. " is not in an area where a jail can be placed!", true )
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
		local str = "#A jailed #T"
		if seconds > 0 then
			str = str .. " for #i seconds"
		end
		ulx.fancyLogAdmin( calling_ply, str, affected_plys, seconds )
	else
		ulx.fancyLogAdmin( calling_ply, "#A unjailed #T", affected_plys )
	end
end
local jail = ulx.command( CATEGORY_NAME, "ulx jail", ulx.jail, "!jail" )
jail:addParam{ type=ULib.cmds.PlayersArg }
jail:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="秒, 0为永久", ULib.cmds.round, ULib.cmds.optional }
jail:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jail:defaultAccess( ULib.ACCESS_ADMIN )
jail:help( "将目标关入监狱，!unjail 释放" )
jail:setOpposite( "ulx unjail", {_, _, _, true}, "!unjail" )
function ulx.jailtp( calling_ply, target_ply, seconds, should_unjail )
	if should_unjail then
		if target_ply.jail then
			target_ply.jail.unjail()
			target_ply.jail = nil
			ulx.fancyLogAdmin( calling_ply, "#A teleported and unjailed #T", target_ply )
		else
			ULib.tsayError( calling_ply, target_ply:Nick() .. " 没有被囚禁！", true )
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
		ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!", true )
		return
	elseif not jailableArea( pos ) then
		ULib.tsayError( calling_ply, "该位置无法放置监狱！", true )
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
	local str = "#A teleported and jailed #T"
	if seconds > 0 then
		str = str .. " for #i seconds"
	end
	ulx.fancyLogAdmin( calling_ply, str, target_ply, seconds )
end
local jailtp = ulx.command( CATEGORY_NAME, "ulx jailtp", ulx.jailtp, "!jailtp" )
jailtp:addParam{ type=ULib.cmds.PlayerArg }
jailtp:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="秒, 0为永久", ULib.cmds.round, ULib.cmds.optional }
jailtp:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jailtp:defaultAccess( ULib.ACCESS_ADMIN )
jailtp:help( "将目标传送到准星位置并关入监狱，!unjailtp 释放" )
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
	local j = 1
	while true do
		local phys_obj = ragdoll:GetPhysicsObjectNum( j )
		if phys_obj then
			phys_obj:SetVelocity( velocity )
			j = j + 1
		else
			break
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
				ULib.tsayError( calling_ply, v:Nick() .. " is dead and cannot be ragdolled!", true )
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
		ulx.fancyLogAdmin( calling_ply, "#A ragdolled #T", affected_plys )
	else
		ulx.fancyLogAdmin( calling_ply, "#A unragdolled #T", affected_plys )
	end
end
local ragdoll = ulx.command( CATEGORY_NAME, "ulx ragdoll", ulx.ragdoll, "!ragdoll" )
ragdoll:addParam{ type=ULib.cmds.PlayersArg }
ragdoll:addParam{ type=ULib.cmds.BoolArg, invisible=true }
ragdoll:defaultAccess( ULib.ACCESS_ADMIN )
ragdoll:help( "使目标变成布娃娃无法行动，!unragdoll 恢复" )
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
			local ents = ents.FindByClass( "npc_headcrab_fast" )
			for _, ent in ipairs( ents ) do
				dist = ent:GetPos():Distance( pos )
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
			ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
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
				ULib.tsayError( calling_ply, "找不到放置 NPC 的位置给 " .. v:Nick(), true )
			end
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A mauled #T", affected_plys )
end
local maul = ulx.command( CATEGORY_NAME, "ulx maul", ulx.maul, "!maul" )
maul:addParam{ type=ULib.cmds.PlayersArg }
maul:defaultAccess( ULib.ACCESS_SUPERADMIN )
maul:help( "召唤僵尸群围攻目标" )
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
function ulx.stripweapons( calling_ply, target_plys )
	for i=1, #target_plys do
		target_plys[ i ]:StripWeapons()
	end
	ulx.fancyLogAdmin( calling_ply, "#A stripped weapons from #T", target_plys )
end
local strip = ulx.command( CATEGORY_NAME, "ulx strip", ulx.stripweapons, "!strip" )
strip:addParam{ type=ULib.cmds.PlayersArg }
strip:defaultAccess( ULib.ACCESS_ADMIN )
strip:help( "卸下目标的所有武器" )