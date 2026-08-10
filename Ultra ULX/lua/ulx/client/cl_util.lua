local function ULibRPC()
	local fn_string = net.ReadString()
	local args = net.ReadTable()
	local success, fn = ULib.findVar( fn_string )
	if not success or type( fn ) ~= "function" then return error( "Received bad RPC, invalid function (" .. tostring( fn_string ) .. ")!" ) end
	local max = 0
	for k, v in pairs( args ) do
		local n = tonumber( k )
		if n and n > max then
			max = n
		end
	end
	fn( unpack( args, 1, max ) )
end
net.Receive( "URPC", ULibRPC )
net.Receive( "ulib_sound", function( ln )
	local str = net.ReadString()
	if not ULib.fileExists( "sound/" .. str ) then
		Msg( "[LC ULib ERROR] Received invalid sound\n" )
		return
	end
	if LocalPlayer():IsValid() then
		LocalPlayer():EmitSound( Sound( str ) )
	end
end )
local cvarinfo = {}
local reversecvar = {}
local function clCvarChanged( cl_cvar, oldvalue, newvalue )
	if not reversecvar[ cl_cvar ] then
		return
	elseif reversecvar[ cl_cvar ].ignore then
		reversecvar[ cl_cvar ].ignore = nil
		return
	end
	local sv_cvar = reversecvar[ cl_cvar ].sv_cvar
	RunConsoleCommand( "ulib_update_cvar", sv_cvar, newvalue )
end
local function repWriteCvar( sv_cvar, cl_cvar, default_value, current_value )
	cvarinfo[ sv_cvar ] = GetConVar( cl_cvar ) or CreateClientConVar( cl_cvar, default_value, false, false )
	reversecvar[ cl_cvar ] = { sv_cvar=sv_cvar }
	ULib.queueFunctionCall( function()
		hook.Call( ULib.HOOK_REPCVARCHANGED, _, sv_cvar, cl_cvar, nil, nil, current_value )
		if cvarinfo[ sv_cvar ]:GetString() ~= current_value then
			reversecvar[ cl_cvar ].ignore = true
			RunConsoleCommand( cl_cvar, current_value )
		end
	end )
	cvars.AddChangeCallback( cl_cvar, clCvarChanged )
end
net.Receive( "ulib_repWriteCvar", function( len )
	local sv_cvar = net.ReadString()
	local cl_cvar = net.ReadString()
	local default_value = net.ReadString()
	local current_value = net.ReadString()
	repWriteCvar( sv_cvar, cl_cvar, default_value, current_value )
end )
local compressedcvars = {}
net.Receive( "ulib_repWriteCvarBatch_Part", function()
	local len = net.ReadUInt( 16 )
	local idx = net.ReadUInt( 16 )
	compressedcvars[ idx ] = net.ReadData( len )
end )
net.Receive( "ulib_repWriteCvarBatch_Complete", function()
	local cvar_count = table.Count( compressedcvars )
	local compressedstring = ""
	for idx = 1, cvar_count do
		compressedstring = compressedstring .. compressedcvars[ idx ]
	end
	local cvars_json = util.Decompress( compressedstring )
	local cvars = util.JSONToTable( cvars_json )
	for sv_cvar, info in pairs( cvars ) do
		repWriteCvar( sv_cvar, info.c, info.d, info.v )
	end
	compressedcvars = {}
end )
net.Receive( "ulib_repChangeCvar", function( len )
	local ply = net.ReadEntity()
	local cl_cvar = net.ReadString()
	local oldvalue = net.ReadString()
	local newvalue = net.ReadString()
	local changed = oldvalue ~= newvalue
	if not reversecvar[ cl_cvar ] then
		return
	end
	local sv_cvar = reversecvar[ cl_cvar ].sv_cvar
	ULib.queueFunctionCall( function()
		if changed then
			hook.Call( ULib.HOOK_REPCVARCHANGED, _, sv_cvar, cl_cvar, ply, oldvalue, newvalue )
		end
		if GetConVarString( cl_cvar ) ~= newvalue then
			reversecvar[ cl_cvar ].ignore = true
			RunConsoleCommand( cl_cvar, newvalue)
		end
	end )
end )