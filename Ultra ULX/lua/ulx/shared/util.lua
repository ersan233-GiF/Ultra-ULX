local dataFolder = "data"
local function stripDataPrefix( f )
	local lower = f:lower()
	local prefixLen = dataFolder:len()
	local separator = lower:sub( prefixLen + 1, prefixLen + 1 )
	if lower:sub( 1, prefixLen ) == dataFolder and ( separator == "/" or separator == "\\" ) then
		return f:sub( prefixLen + 2 )
	end
	return nil
end
function ULib.fileExists( f, noMount )
	if noMount then return file.Exists( f, "MOD" ) end
	local fWoData = stripDataPrefix( f )
	return file.Exists( f, "GAME" ) or (fWoData ~= nil and file.Exists( fWoData, "DATA" ))
end
function ULib.fileRead( f, noMount )
	local existsWoMount = ULib.fileExists( f, true )
	if noMount then
		if not existsWoMount then
			return nil
		end
		return file.Read( f, "MOD" )
	end
	local fWoData = stripDataPrefix( f )
	if fWoData ~= nil then
		if file.Exists( fWoData, "DATA" ) then
			return file.Read( fWoData, "DATA" )
		end
		if file.Exists( f, "GAME" ) then
			return file.Read( f, "GAME" )
		end
		return nil
	end
	if not ULib.fileExists( f ) then return nil end
	return file.Read( f, "GAME" )
end
function ULib.fileWrite( f, content )
	local fWoData = stripDataPrefix( f )
	if fWoData == nil then return nil end
	file.Write( fWoData, content )
end
function ULib.fileAppend( f, content )
	local fWoData = stripDataPrefix( f )
	if fWoData == nil then return nil end
	file.Append( fWoData, content )
end
function ULib.fileCreateDir( f )
	local fWoData = stripDataPrefix( f )
	if fWoData == nil then return nil end
	file.CreateDir( fWoData )
end
function ULib.fileDelete( f )
	local fWoData = stripDataPrefix( f )
	if fWoData == nil then return nil end
	file.Delete( fWoData )
end
function ULib.fileIsDir( f, noMount )
	if not noMount then
		local fWoData = stripDataPrefix( f )
		return file.IsDir( f, "GAME" ) or (fWoData ~= nil and file.IsDir( fWoData, "DATA" ))
	else
		return file.IsDir( f, "MOD" )
	end
end
function ULib.execFile( f, queueName, noMount )
	if not ULib.fileExists( f, noMount ) then
		ULib.error( "Called execFile with invalid file! " .. f )
		return
	end
	ULib.execString( ULib.fileRead( f, noMount ), queueName )
end
function ULib.execString( f, queueName )
	local lines = string.Explode( "\n", f )
	local buffer = ""
	local buffer_lines = 0
	local exec = "exec "
	for _, line in ipairs( lines ) do
		line = string.Trim( line )
		if line:lower():sub( 1, exec:len() ) == exec then
			local dummy, dummy, cfg = line:lower():find( "^exec%s+([%w%.]+)%s*/?/?.*$")
			if not cfg:find( ".cfg", 1, true ) then cfg = cfg .. ".cfg" end
			ULib.execFile( "cfg/" .. cfg, queueName )
		elseif line ~= "" then
			buffer = buffer .. line .. "\n"
			buffer_lines = buffer_lines + 1
			if buffer_lines >= 10 then
				ULib.namedQueueFunctionCall( queueName, ULib.consoleCommand, buffer )
				buffer_lines = 0
				buffer = ""
			end
		end
	end
	if buffer_lines > 0 then
		ULib.namedQueueFunctionCall( queueName, ULib.consoleCommand, buffer )
	end
end
function ULib.execFileULib( f, safeMode, noMount )
	if not ULib.fileExists( f, noMount ) then
		ULib.error( "Called execFileULib with invalid file! " .. f )
		return
	end
	ULib.execStringULib( ULib.fileRead( f, noMount ), safeMode )
end
function ULib.execStringULib( f, safeMode )
	local lines = string.Explode( "\n", f )
	local srvPly = Entity( -1 )
	for _, line in ipairs( lines ) do
		line = string.Trim( line )
		if line ~= "" then
			local argv = ULib.splitArgs( line )
			local commandName = table.remove( argv, 1 )
			local cmdTable, commandName, argv = ULib.cmds.getCommandTableAndArgv( commandName, argv )
			if not cmdTable then
				Msg( "Error executing " .. tostring( commandName ) .. "\n" )
			elseif cmdTable.__unsafe then
				Msg( "Not executing unsafe command " .. commandName .. "\n" )
			else
				ULib.cmds.execute( cmdTable, srvPly, commandName, argv )
			end
		end
	end
end
function ULib.serialize( v )
	local t = type( v )
	local str
	if t == "string" then
		str = string.format( "%q", v )
	elseif t == "boolean" or t == "number" then
		str = tostring( v )
	elseif t == "table" then
		str = table.ToString( v )
	elseif t == "Vector" then
		str = "Vector(" .. v.x .. "," .. v.y .. "," .. v.z .. ")"
	elseif t == "Angle" then
		str = "Angle(" .. v.pitch .. "," .. v.yaw .. "," .. v.roll .. ")"
	elseif t == "Player" then
		str = tostring( v )
	elseif t == "Entity" then
		str = tostring( v )
	elseif t == "nil" then
		str = "nil"
	else
		ULib.error( "Passed an invalid parameter to serialize! (type: " .. t .. ")" )
		return
	end
	return str
end
function ULib.isSandbox()
	return GAMEMODE.IsSandboxDerived
end
local function insertResult( files, result, relDir )
	if not relDir then
		table.insert( files, result )
	else
		table.insert( files, relDir .. "/" .. result )
	end
end
function ULib.filesInDir( dir, recurse, noMount, root )
	if not ULib.fileIsDir( dir ) then
		return nil
	end
	local files = {}
	local relDir
	if root then
		relDir = dir:gsub( root .. "[\\/]", "" )
	end
	root = root or dir
	local resultFiles, resultFolders = file.Find( dir .. "/*", not noMount and "GAME" or "MOD" )
	for i=1, #resultFiles do
		insertResult( files, resultFiles[ i ], relDir )
	end
	for i=1, #resultFolders do
		if recurse then
			files = table.Add( files, ULib.filesInDir( dir .. "/" .. resultFolders[ i ], recurse, noMount, root ) )
		else
			insertResult( files, resultFolders[ i ], relDir )
		end
	end
	return files
end
local stacks = {}
local function onThink()
	local remove = true
	for queueName, stack in pairs( stacks ) do
		local num = #stack
		if num > 0 then
			remove = false
			local b, e = pcall( stack[ 1 ].fn, unpack( stack[ 1 ], 1, stack[ 1 ].n ) )
			if not b then
				ErrorNoHalt( "ULib queue error: " .. tostring( e ) .. "\n" )
			end
			table.remove( stack, 1 )
		end
	end
	if remove then
		hook.Remove( "Think", "ULibQueueThink" )
	end
end
function ULib.queueFunctionCall( fn, ... )
	if type( fn ) ~= "function" then
		error( "queueFunctionCall received a bad function", 2 )
		return
	end
	ULib.namedQueueFunctionCall( "defaultQueueName", fn, ... )
end
function ULib.namedQueueFunctionCall( queueName, fn, ... )
	queueName = queueName or "defaultQueueName"
	if type( fn ) ~= "function" then
		error( "queueFunctionCall received a bad function", 2 )
		return
	end
	stacks[ queueName ] = stacks[ queueName ] or {}
	table.insert( stacks[ queueName ], { fn=fn, n=select( "#", ... ), ... } )
	hook.Add( "Think", "ULibQueueThink", onThink, HOOK_MONITOR_HIGH )
end
function ULib.backupFile( f )
	local contents = ULib.fileRead( f )
	local filename = f:GetFileFromFilename():sub( 1, -5 )
	local folder = f:GetPathFromFilename()
	local num = 1
	local targetPath = folder .. filename .. "_backup.txt"
	while ULib.fileExists( targetPath ) do
		num = num + 1
		targetPath = folder .. filename .. "_backup" .. num .. ".txt"
	end
	ULib.fileWrite( targetPath, contents )
	return targetPath
end
function ULib.nameCheck( data )
	hook.Call( ULib.HOOK_PLAYER_NAME_CHANGED, nil, Player(data.userid), data.oldname, data.newname )
end
gameevent.Listen( "player_changename" )
hook.Add( "player_changename", "ULibNameCheck", ULib.nameCheck )
function ULib.getPlyByUID( uid )
	local players = player.GetAll()
	for _, ply in ipairs( players ) do
		if ply:UniqueID() == uid then
			return ply
		end
	end
	return nil
end
function ULib.pcallError( ... )
	local returns = { pcall( ... ) }
	if not returns[ 1 ] then
		ErrorNoHalt( returns[ 2 ] )
	end
	return unpack( returns )
end