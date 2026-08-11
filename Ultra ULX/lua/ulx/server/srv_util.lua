function ULib.clientRPC( plys, fn, ... )
	ULib.checkArg( 1, "ULib.clientRPC", {"nil","Player","table"}, plys )
	ULib.checkArg( 2, "ULib.clientRPC", {"string"}, fn )
	net.Start( "URPC" )
	net.WriteString( fn )
	net.WriteTable( {...} )
	if plys then
		net.Send( plys )
	else
		net.Broadcast()
	end
end
function ULib.play3DSound( sound, vector, volume, pitch )
	volume = volume or 100
	pitch = pitch or 100
	local ent = ents.Create( "info_null" )
	if not ent:IsValid() then return end
	ent:SetPos( vector )
	ent:Spawn()
	ent:Activate()
	ent:EmitSound( sound, volume, pitch )
end
function ULib.getAllReadyPlayers()
	local players = player.GetAll()
	for i=#players, 1, -1 do
		if not players[ i ].ulib_ready then
			table.remove( players, i )
		end
	end
	return players
end
ULib.repcvars = ULib.repcvars or {}
local repcvars = ULib.repcvars
local repCvarServerChanged
function ULib.replicatedWritableCvar( sv_cvar, cl_cvar, default_value, save, notify, access )
	sv_cvar = sv_cvar:lower()
	cl_cvar = cl_cvar:lower()
	default_value = tostring(default_value)
	local flags = 0
	if save then
		flags = flags + FCVAR_ARCHIVE
	end
	if notify then
		flags = flags + FCVAR_NOTIFY
	end
	local cvar_obj = GetConVar( sv_cvar ) or CreateConVar( sv_cvar, default_value, flags )
	net.Start("ulib_repWriteCvar")
		net.WriteString( sv_cvar )
		net.WriteString( cl_cvar )
		net.WriteString( default_value )
		net.WriteString( cvar_obj:GetString() )
	net.Broadcast()
	repcvars[ sv_cvar ] = { access=access, default=default_value, cl_cvar=cl_cvar, cvar_obj=cvar_obj }
	cvars.AddChangeCallback( sv_cvar, repCvarServerChanged )
	hook.Call( ULib.HOOK_REPCVARCHANGED, _, sv_cvar, cl_cvar, nil, nil, cvar_obj:GetString() )
	return cvar_obj
end
local function repCvarOnJoin( ply )
	local cvar_data = {}
	for sv_cvar, info in pairs( repcvars ) do
		cvar_data[ sv_cvar ] = { d=info.default, c=info.cl_cvar, v=info.cvar_obj:GetString() }
	end
	local cvars_json = util.TableToJSON( cvar_data )
	local compressedcvars = util.Compress( cvars_json )
	local compressedlen = #compressedcvars
	local blocksize = 2560
	local offset = 1
	local idx = 1
	while ( compressedlen > 0 ) do
		local sendsize = compressedlen
		if sendsize > blocksize then
			sendsize = blocksize
		end
		net.Start( "ulib_repWriteCvarBatch_Part" )
			net.WriteUInt( sendsize, 16 )
			net.WriteUInt( idx, 16 )
			net.WriteData( string.sub( compressedcvars, offset, offset + sendsize - 1 ) )
		net.Send( ply )
		offset = offset + sendsize
		idx = idx + 1
		compressedlen = compressedlen - sendsize
	end
	net.Start( "ulib_repWriteCvarBatch_Complete" )
	net.Send( ply )
end
hook.Add( ULib.HOOK_LOCALPLAYERREADY, "ULibSendCvars", repCvarOnJoin )
local function clientChangeCvar( ply, command, argv )
	local sv_cvar = argv[ 1 ]
	local newvalue = argv[ 2 ]
	if not sv_cvar or not newvalue or not repcvars[ sv_cvar:lower() ] then
		return
	end
	sv_cvar = sv_cvar:lower()
	local cvar_obj = repcvars[ sv_cvar ].cvar_obj
	local oldvalue = cvar_obj:GetString()
	if oldvalue == newvalue then return end
	local access = repcvars[ sv_cvar ].access
	if not ply:query( access ) then
		ULib.tsayError( ply, "You do not have access to this cvar (" .. sv_cvar .. "), " .. ply:Nick() .. "." )
		net.Start( "ulib_repChangeCvar" )
			net.WriteEntity( ply )
			net.WriteString( repcvars[ sv_cvar ].cl_cvar )
			net.WriteString( oldvalue )
			net.WriteString( oldvalue )
		net.Send( ply )
		return
	end
	repcvars[ sv_cvar ].ignore = ply
	RunConsoleCommand( sv_cvar, newvalue )
	hook.Call( ULib.HOOK_REPCVARCHANGED, _, sv_cvar, repcvars[ sv_cvar ].cl_cvar, ply, oldvalue, newvalue )
end
concommand.Add( "ulib_update_cvar", clientChangeCvar, nil, nil, FCVAR_SERVER_CAN_EXECUTE )
repCvarServerChanged = function( sv_cvar, oldvalue, newvalue )
	if not repcvars[ sv_cvar ] then
		return
	end
	net.Start( "ulib_repChangeCvar" )
		net.WriteEntity( repcvars[ sv_cvar ].ignore or Entity( 0 ) )
		net.WriteString( repcvars[ sv_cvar ].cl_cvar )
		net.WriteString( oldvalue )
		net.WriteString( newvalue )
	net.Broadcast()
	if repcvars[ sv_cvar ].ignore then
		repcvars[ sv_cvar ].ignore = nil
	else
		hook.Call( ULib.HOOK_REPCVARCHANGED, _, sv_cvar, repcvars[ sv_cvar ].cl_cvar, Entity( 0 ), oldvalue, newvalue )
	end
end