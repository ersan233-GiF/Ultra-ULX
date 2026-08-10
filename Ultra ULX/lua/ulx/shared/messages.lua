function ULib.tsay( ply, msg, wait, wasValid )
	ULib.checkArg( 1, "ULib.tsay", {"nil","Player","Entity"}, ply )
	ULib.checkArg( 2, "ULib.tsay", "string", msg )
	ULib.checkArg( 3, "ULib.tsay", {"nil","boolean"}, wait )
	if wait then ULib.namedQueueFunctionCall( "ULibChats", ULib.tsay, ply, msg, false, ply and ply:IsValid() ) return end
	if SERVER and ply and not ply:IsValid() then
		if wasValid then
			return
		end
		Msg( msg .. "\n" )
		return
	end
	if CLIENT then
		LocalPlayer():ChatPrint( msg )
		return
	end
	if ply then
		ply:ChatPrint( msg )
	else
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			player:ChatPrint( msg )
		end
	end
end
local serverConsole = {}
local function tsayColorCallback( ply, ... )
	if CLIENT then
		chat.AddText( ... )
		return
	end
	if ply and ply ~= serverConsole and not ply:IsValid() then return end
	local args = { ... }
	if ply == serverConsole then
		for i=2, #args, 2 do
			Msg( args[ i ] )
		end
		Msg( "\n" );
		return
	end
	local current_chunk = { size = 0 }
	local chunks = { current_chunk }
	local max_chunk_size = 240
	for idx = 1, #args do
		local arg = args[ idx ]
		local typ = type( arg )
		local arg_size = typ == "table" and 4 or #arg + 2
		if typ == "string" and current_chunk.size + arg_size > max_chunk_size then
			local substr = arg:sub( 1, math.max( 1, max_chunk_size - current_chunk.size - 2 ) )
			if #substr > 0 then
				table.insert( current_chunk, substr )
			end
			local remaining = arg:sub( #substr + 1 )
			if #remaining > 0 then
				args[ idx ] = remaining
				idx = idx - 1
			end
			current_chunk = { size = 0 }
			table.insert( chunks, current_chunk )
		else
			if current_chunk.size + arg_size > max_chunk_size then
				current_chunk = { size = 0 }
				table.insert( chunks, current_chunk )
			end
			current_chunk.size = current_chunk.size + arg_size
			table.insert( current_chunk, arg )
		end
	end
	for chunk_num=1, #chunks do
		local chunk = chunks[ chunk_num ]
		net.Start("tsayc")
			net.WriteBool(chunk_num == #chunks)
			net.WriteInt( #chunk, 8 )
			for i=1, #chunk do
				local arg = chunk[ i ]
				if type( arg ) == "string" then
					net.WriteBool( true )
					net.WriteString( arg )
				else
					net.WriteBool( false )
					net.WriteColor( arg )
				end
			end
		if IsValid(ply) then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end
end
if CLIENT then
	local accumulator = {}
	net.Receive( "tsayc", function( len )
		local last = net.ReadBool()
		local argn = net.ReadInt(8)
		for i=1, argn do
			if net.ReadBool() then
				table.insert( accumulator, net.ReadString() )
			else
				table.insert( accumulator, net.ReadColor() )
			end
		end
		if last then
			chat.AddText( unpack( accumulator ) )
			accumulator = {}
		end
	end )
end
function ULib.tsayColor( ply, wait, ... )
	if SERVER and ply and not ply:IsValid() then ply = serverConsole end
	if wait then ULib.namedQueueFunctionCall( "ULibChats", tsayColorCallback, ply, ... ) return end
	tsayColorCallback( ply, ... )
end
function ULib.tsayError( ply, msg, wait )
	return ULib.tsayColor( ply, wait, ULib.COLOR_ERROR, msg )
end
function ULib.csay( ply, msg, color, duration, fade )
	if CLIENT then
		ULib.csayDraw( msg, color, duration, fade )
		Msg( msg .. "\n" )
		return
	end
	ULib.clientRPC( ply, "ULib.csayDraw", msg, color, duration, fade )
	ULib.console( ply, msg )
end
function ULib.console( ply, msg )
	if CLIENT or (ply and not ply:IsValid()) then
		Msg( msg .. "\n" )
		return
	end
	if ply then
		ply:PrintMessage( HUD_PRINTCONSOLE, msg .. "\n" )
	else
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			player:PrintMessage( HUD_PRINTCONSOLE, msg .. "\n" )
		end
	end
end
function ULib.error( s )
	if CLIENT then
		Msg( "[LC ULIB ERROR] " .. s .. "\n" )
	else
		Msg( "[LS ULIB ERROR] " .. s .. "\n" )
	end
end
function ULib.debugFunctionCall( name, ... )
	local args = { ... }
	print( "Function '" .. name .. "' called. Parameters:" )
	for i=1, #args do
		local value = ULib.serialize( args[ i ] )
		print( "[PARAMETER " .. i .. "]: Type=" .. type( args[ i ] ) .. "\tValue=(" .. value .. ")" )
	end
end