local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_teleport"
local function spiralGrid(rings)
	local grid = {}
	local col, row
	for ring=1, rings do
		row = ring
		for col=1-ring, ring do
			table.insert( grid, {col, row} )
		end
		col = ring
		for row=ring-1, -ring, -1 do
			table.insert( grid, {col, row} )
		end
		row = -ring
		for col=ring-1, -ring, -1 do
			table.insert( grid, {col, row} )
		end
		col = -ring
		for row=1-ring, ring do
			table.insert( grid, {col, row} )
		end
	end
	return grid
end
local tpGrid = spiralGrid( 24 )
local function playerSend( from, to, force )
	if not to:IsInWorld() and not force then return false end
	local yawForward = to:EyeAngles().yaw
	local directions = {
		math.NormalizeAngle( yawForward - 180 ),
		math.NormalizeAngle( yawForward + 90 ),
		math.NormalizeAngle( yawForward - 90 ),
		yawForward,
	}
	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 32 )
	t.filter = { to, from }
	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47
	local tr = util.TraceEntity( t, from )
	while tr.Hit do
		i = i + 1
		if i > #directions then
			if force then
				from.ulx_prevpos = from:GetPos()
				from.ulx_prevang = from:EyeAngles()
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end
		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47
		tr = util.TraceEntity( t, from )
	end
	from.ulx_prevpos = from:GetPos()
	from.ulx_prevang = from:EyeAngles()
	return tr.HitPos
end
function ulx.bring( calling_ply, target_plys )
	local cell_size = 50
  if not calling_ply:IsValid() then
    Msg( "如果你把某人带到控制台, 他们会被控制台的威严瞬间毁灭.\n" )
    return
  end
  if ulx.getExclusive( calling_ply, calling_ply ) then
    ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
    return
  end
  if not calling_ply:Alive() then
    ULib.tsayError( calling_ply, L.T("tele_you_dead"), true )
    return
  end
  if calling_ply:InVehicle() then
    ULib.tsayError( calling_ply, L.T("tele_leave_vehicle"), true )
    return
  end
	local t = {
		start = calling_ply:GetPos(),
		filter = { calling_ply },
		endpos = calling_ply:GetPos(),
	}
	local tr = util.TraceEntity( t, calling_ply )
  if tr.Hit then
    ULib.tsayError( calling_ply, L.T("tele_inside_world"), true )
    return
  end
  local teleportable_plys = {}
  for i=1, #target_plys do
    local v = target_plys[ i ]
    if ulx.getExclusive( v, calling_ply ) then
      ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
    elseif not v:Alive() then
      ULib.tsayError( calling_ply, v:Nick() .. L.T("tele_retrn_dead"), true )
    else
      table.insert( teleportable_plys, v )
    end
  end
	local players_involved = table.Copy( teleportable_plys )
	table.insert( players_involved, calling_ply )
  local affected_plys = {}
  for i=1, #tpGrid do
		local c = tpGrid[i][1]
		local r = tpGrid[i][2]
    local target = table.remove( teleportable_plys )
		if not target then break end
		local yawForward = calling_ply:EyeAngles().yaw
		local offset = Vector( r * cell_size, c * cell_size, 0 )
		offset:Rotate( Angle( 0, yawForward, 0 ) )
		local t = {}
		t.start = calling_ply:GetPos() + Vector( 0, 0, 32 )
		t.filter = players_involved
		t.endpos = t.start + offset
		local tr = util.TraceEntity( t, target )
    if tr.Hit then
      table.insert( teleportable_plys, target )
    else
      if target:InVehicle() then target:ExitVehicle() end
			target.ulx_prevpos = target:GetPos()
			target.ulx_prevang = target:EyeAngles()
      target:SetPos( t.endpos )
      target:SetEyeAngles( (calling_ply:GetPos() - t.endpos):Angle() )
      target:SetLocalVelocity( Vector( 0, 0, 0 ) )
      table.insert( affected_plys, target )
    end
  end
  if #teleportable_plys > 0 then
    ULib.tsayError( calling_ply, L.T("tele_bring_nospace"), true )
  end
	if #affected_plys > 0 then
  	ulx.fancyLogKeyed(calling_ply, "tele_bring_log", affected_plys )
	end
end
local bring = ulx.command( CATEGORY_NAME, "ulx bring", ulx.bring, "!bring" )
bring:addParam{ type=ULib.cmds.PlayersArg, target="!^" }
bring:defaultAccess( ULib.ACCESS_ADMIN )
bring:help( L.T("tele_bring_help") )
function ulx.gotoTp( calling_ply, target_ply )
	if not calling_ply:IsValid() then
		Msg( "你无法从控制台降临到凡人的世界.\n" )
		return
	end
	if ulx.getExclusive( calling_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
		return
	end
	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. L.T("tele_retrn_dead"), true )
		return
	end
	if not calling_ply:Alive() then
		ULib.tsayError( calling_ply, L.T("tele_you_dead"), true )
		return
	end
	if target_ply:InVehicle() and calling_ply:GetMoveType() ~= MOVETYPE_NOCLIP then
		ULib.tsayError( calling_ply, L.T("tele_vehicle_block"), true )
		return
	end
	local newpos = playerSend( calling_ply, target_ply, calling_ply:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		ULib.tsayError( calling_ply, L.T("tele_no_place"), true )
		return
	end
	if calling_ply:InVehicle() then
		calling_ply:ExitVehicle()
	end
	local newang = (target_ply:GetPos() - newpos):Angle()
	calling_ply:SetPos( newpos )
	calling_ply:SetEyeAngles( newang )
	calling_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	ulx.fancyLogKeyed(calling_ply, "tele_goto_log", target_ply )
end
local gotoCmd = ulx.command( CATEGORY_NAME, "ulx goto", ulx.gotoTp, "!goto" )
gotoCmd:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
gotoCmd:defaultAccess( ULib.ACCESS_ADMIN )
gotoCmd:help( L.T("tele_goto_help") )
function ulx.send( calling_ply, target_from, target_to )
	if target_from == target_to then
		ULib.tsayError( calling_ply, L.T("tele_same_target"), true )
		return
	end
	if ulx.getExclusive( target_from, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_from, calling_ply ), true )
		return
	end
	if ulx.getExclusive( target_to, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_to, calling_ply ), true )
		return
	end
	local nick = target_from:Nick()
	if not target_from:Alive() or not target_to:Alive() then
		if not target_to:Alive() then
			nick = target_to:Nick()
		end
		ULib.tsayError( calling_ply, nick .. L.T("tele_retrn_dead"), true )
		return
	end
	if target_to:InVehicle() and target_from:GetMoveType() ~= MOVETYPE_NOCLIP then
		ULib.tsayError( calling_ply, L.T("tele_vehicle_block"), true )
		return
	end
	local newpos = playerSend( target_from, target_to, target_from:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		ULib.tsayError( calling_ply, L.T("tele_no_place"), true )
		return
	end
	if target_from:InVehicle() then
		target_from:ExitVehicle()
	end
	local newang = (target_from:GetPos() - newpos):Angle()
	target_from:SetPos( newpos )
	target_from:SetEyeAngles( newang )
	target_from:SetLocalVelocity( Vector( 0, 0, 0 ) )
	ulx.fancyLogKeyed(calling_ply, "tele_send_log", target_from, target_to )
end
local send = ulx.command( CATEGORY_NAME, "ulx send", ulx.send, "!send" )
send:addParam{ type=ULib.cmds.PlayerArg, target="!^" }
send:addParam{ type=ULib.cmds.PlayerArg, target="!^" }
send:defaultAccess( ULib.ACCESS_ADMIN )
send:help( L.T("tele_send_help") )
function ulx.teleport( calling_ply, target_ply )
	if not calling_ply:IsValid() then
		Msg( "You are the console, you can't teleport or teleport others since you can't see the world!\n" )
		return
	end
	if ulx.getExclusive( target_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		return
	end
	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. L.T("tele_retrn_dead"), true )
		return
	end
	local tr = util.TraceLine( {
		start  = calling_ply:GetShootPos(),
		endpos = calling_ply:GetShootPos() + calling_ply:GetAimVector() * 32768,
		filter = { calling_ply, target_ply },
	} )
	local pos = tr.HitPos + tr.HitNormal * 16
	if target_ply == calling_ply and pos:Distance( target_ply:GetPos() ) < 64 then
		return
	end
	target_ply.ulx_prevpos = target_ply:GetPos()
	target_ply.ulx_prevang = target_ply:EyeAngles()
	if target_ply:InVehicle() then
		target_ply:ExitVehicle()
	end
	target_ply:SetPos( pos )
	target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	if target_ply ~= calling_ply then
		ulx.fancyLogKeyed(calling_ply, "tele_tp_log", target_ply )
	end
end
local teleport = ulx.command( CATEGORY_NAME, "ulx teleport", ulx.teleport, {"!tp", "!teleport"} )
teleport:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
teleport:defaultAccess( ULib.ACCESS_ADMIN )
teleport:help( L.T("tele_tp_help") )
function ulx.tpto( calling_ply, target_plys, x, y, z )
	if not calling_ply:IsValid() then
		Msg( "控制台无法在凡人世界游荡.\n" )
		return
	end
	local nx, ny, nz = tonumber( x ), tonumber( y ), tonumber( z )
	if not nx or not ny or not nz then
		ULib.tsayError( calling_ply, L.T("tele_tpto_badcoord"), true )
		return
	end
	local pos = Vector( nx, ny, nz )
	for _, ply in ipairs( target_plys ) do
		if ulx.getExclusive( ply, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( ply, calling_ply ), true )
		elseif not ply:Alive() then
			ULib.tsayError( calling_ply, ply:Nick() .. " " .. L.T("tele_you_dead"), true )
		else
			ply.ulx_prevpos = ply:GetPos()
			ply.ulx_prevang = ply:EyeAngles()
			if ply:InVehicle() then ply:ExitVehicle() end
			ply:SetPos( pos )
			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end
	end
	ulx.fancyLogKeyed(calling_ply, "tele_tpto_log", target_plys )
end
local tpto = ulx.command( CATEGORY_NAME, "ulx tpto", ulx.tpto, "!tpto" )
tpto:addParam{ type=ULib.cmds.PlayersArg }
tpto:addParam{ type=ULib.cmds.StringArg, hint="x" }
tpto:addParam{ type=ULib.cmds.StringArg, hint="y" }
tpto:addParam{ type=ULib.cmds.StringArg, hint="z" }
tpto:defaultAccess( ULib.ACCESS_ADMIN )
tpto:help( L.T("tele_tpto_help") )
function ulx.retrn( calling_ply, target_ply )
	if not target_ply:IsValid() then
		Msg( "返回哪里? 控制台永远无法返回凡人世界.\n" )
		return
	end
	if not target_ply.ulx_prevpos then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " " .. (L.T and L.T("tele_retrn_no_prev") or "has no previous location"), true )
		return
	end
	if ulx.getExclusive( target_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( target_ply, calling_ply ), true )
		return
	end
	if not target_ply:Alive() then
		ULib.tsayError( calling_ply, target_ply:Nick() .. " " .. (L.T and L.T("tele_retrn_dead") or "已死亡!"), true )
		return
	end
	if target_ply:InVehicle() then
		target_ply:ExitVehicle()
	end
	target_ply:SetPos( target_ply.ulx_prevpos )
	target_ply:SetEyeAngles( target_ply.ulx_prevang )
	target_ply.ulx_prevpos = nil
	target_ply.ulx_prevang = nil
	target_ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	ulx.fancyLogKeyed( calling_ply, "tele_retrn_log", target_ply )
end
local retrn = ulx.command( CATEGORY_NAME, "ulx retrn", ulx.retrn, "!return" )
retrn.opposite = nil
local returnAlias = ulx.command( CATEGORY_NAME, "ulx return", ulx.retrn, nil )
retrn:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
retrn:defaultAccess( ULib.ACCESS_ADMIN )
retrn:help( L.T("tele_retrn_help") )