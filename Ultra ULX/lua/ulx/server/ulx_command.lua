ulx.cvars = ulx.cvars or {}
function ulx.convar( command, value, help, access )
	help = help or ""
	access = access or ULib.ACCESS_ALL
	ULib.ucl.registerAccess( "ulx " .. command, access, help, "Cvar" )
	local nospaceCommand = command:gsub( " ", "_" )
	local cvarName = "ulx_" .. nospaceCommand
	local obj = ULib.replicatedWritableCvar( cvarName, cvarName, value, false, false, "ulx " .. command )
	ulx.cvars[ command:lower() ] = { help=help, cvar=nospaceCommand, original=command, obj=obj }
	return obj
end
function ulx.addToHelpManually( category, cmd, string, access_tag )
	ulx.cmdsByCategory[ category ] = ulx.cmdsByCategory[ category ] or {}
	for i=#ulx.cmdsByCategory[ category ],1,-1 do
		local existingCmd = ulx.cmdsByCategory[ category ][i]
		if existingCmd.cmd == cmd and existingCmd.manual == true then
			table.remove( ulx.cmdsByCategory[ category ], i)
			break
		end
	end
	table.insert( ulx.cmdsByCategory[ category ], { access_tag=access_tag, cmd=cmd, helpStr=string, manual=true } )
end
do
	ulx.maps = {}
	local maps = file.Find( "maps/*.bsp", "GAME" )
	for _, map in ipairs( maps ) do
		table.insert( ulx.maps, map:sub( 1, -5 ):lower() )
	end
	table.sort( ulx.maps )
	ulx.gamemodes = {}
	local fromEngine = engine.GetGamemodes()
	for i=1, #fromEngine do
		table.insert( ulx.gamemodes, fromEngine[ i ].name:lower() )
	end
	table.sort( ulx.gamemodes )
end
ulx.common_kick_reasons = ulx.common_kick_reasons or {}
function ulx.addKickReason( reason )
	table.insert( ulx.common_kick_reasons, reason )
	table.sort( ulx.common_kick_reasons )
end
local function sendAutocompletes( ply )
	if ply:query( "ulx map" ) or ply:query( "ulx votemap2" ) then
		ULib.clientRPC( ply, "ulx.populateClMaps", ulx.maps )
		ULib.clientRPC( ply, "ulx.populateClGamemodes", ulx.gamemodes )
	end
	ULib.clientRPC( ply, "ulx.populateClVotemaps", ulx.votemaps )
	ULib.clientRPC( ply, "ulx.populateKickReasons", ulx.common_kick_reasons )
end
hook.Add( ULib.HOOK_UCLAUTH, "sendAutoCompletes", sendAutocompletes )
hook.Add( "PlayerInitialSpawn", "sendAutoCompletes", sendAutocompletes )
function cvarChanged( sv_cvar, cl_cvar, ply, old_value, new_value )
	if not sv_cvar:find( "^ulx_" ) then return end
	local command = sv_cvar:gsub( "^ulx_", "" ):lower()
	if not ulx.cvars[ command ] then return end
	sv_cvar = ulx.cvars[ command ].original
	local path = "data/ultra_ulx/config.txt"
	if not ULib.fileExists( path ) then
		Msg( "[ULX ERROR] Config doesn't exist at " .. path .. "\n" )
		return
	end
	sv_cvar = sv_cvar:gsub( "_", " " )
	if new_value:find( "[%s:']" ) then new_value = string.format( "%q", new_value ) end
	local replacement = string.format( "%s %s ", sv_cvar, new_value:gsub( "%%", "%%%%" ) )
	local config = ULib.fileRead( path )
	local found
	config, found = config:gsub( ULib.makePatternSafe( sv_cvar ):gsub( "%a", function( c ) return "[" .. c:lower() .. c:upper() .. "]" end ) .. "%s+[^;\r\n]*", replacement )
	if found == 0 then
		local newline = config:match("\r?\n") or "\n"
		if not config:find("\r?\n$") then config = config .. newline end
		config = config .. "ulx " .. replacement .. "; " .. ulx.cvars[ command ].help .. newline
	end
	ULib.fileWrite( path, config )
end
hook.Add( ulx.HOOK_ULXDONELOADING, "AddCvarHook", function() hook.Add( ULib.HOOK_REPCVARCHANGED, "ULXCheckCvar", cvarChanged ) end )