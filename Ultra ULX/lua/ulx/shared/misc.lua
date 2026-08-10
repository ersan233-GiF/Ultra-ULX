function ULib.explode( separator, str, limit )
	local t = {}
	local curpos = 1
	while true do
		local newpos, endpos = str:find( separator, curpos )
		if newpos ~= nil then
			table.insert( t, str:sub( curpos, newpos - 1 ) )
			curpos = endpos + 1
		else
			if limit and #t > limit then
				return t
			end
			table.insert( t, str:sub( curpos ) )
			break
		end
	end
	return t
end
function ULib.stripComments( str, comment, blockcommentbeg, blockcommentend )
	if blockcommentbeg and string.sub( blockcommentbeg, 1, string.len( comment ) ) == comment then
		string.gsub( str, ULib.makePatternSafe( comment ) .. "[%S \t]*", function ( match )
			if string.sub( match, 1, string.len( blockcommentbeg ) ) == blockcommentbeg then
				return ""
			end
			str = string.gsub( str, ULib.makePatternSafe( match ), "", 1 )
			return ""
		end )
		str = string.gsub( str, ULib.makePatternSafe( blockcommentbeg ) .. ".-" .. ULib.makePatternSafe( blockcommentend ), "" )
	else
		str = string.gsub( str, ULib.makePatternSafe( comment ) .. "[%S \t]*", "" )
		if blockcommentbeg and blockcommentend then
			str = string.gsub( str, ULib.makePatternSafe( blockcommentbeg ) .. ".-" .. ULib.makePatternSafe( blockcommentend ), "" )
		end
	end
	return str
end
function ULib.makePatternSafe( str )
	return str:gsub( "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1" )
end
function ULib.stripQuotes( s )
	return s:gsub( "^%s*[\"]*(.-)[\"]*%s*$", "%1" )
end
function ULib.unescapeBackslash( s )
	return s:gsub( "\\\\", "\\" )
end
function ULib.splitPort( ipAndPort )
	return unpack( ULib.explode( ":", ipAndPort ) )
end
function ULib.splitArgs( args, start_token, end_token )
	args = args:Trim()
	local argv = {}
	local curpos = 1
	local in_quote = false
	start_token = start_token or "\""
	end_token = end_token or "\""
	local args_len = args:len()
	while in_quote or curpos <= args_len do
		local quotepos = args:find( in_quote and end_token or start_token, curpos, true )
		local prefix = args:sub( curpos, (quotepos or 0) - 1 )
		if not in_quote then
			local trimmed = prefix:Trim()
			if trimmed ~= "" then
				local t = ULib.explode( "%s+", trimmed )
				table.Add( argv, t )
			end
		else
			table.insert( argv, prefix )
		end
		if quotepos ~= nil then
			curpos = quotepos + 1
			in_quote = not in_quote
		else
			break
		end
	end
	return argv, in_quote
end
function ULib.parseKeyValues( str, convert )
	local lines = ULib.explode( "\n", str:gsub( "\r\n", "\n" ):gsub( "\r", "\n" ) )
	local parent_tables = {}
	local current_table = {}
	local is_insert_last_op = false
	for i, line in ipairs( lines ) do
		local tmp_string = string.char( 01, 02, 03 )
		local tokens = ULib.splitArgs( (line:gsub( "\\\"", tmp_string )) )
		for i, token in ipairs( tokens ) do
			tokens[ i ] = ULib.unescapeBackslash( token ):gsub( tmp_string, "\"" )
		end
		local num_tokens = #tokens
		if num_tokens == 1 then
			local token = tokens[ 1 ]
			if token == "{" then
				local new_table = {}
				if is_insert_last_op then
					current_table[ table.remove( current_table ) ] = new_table
				else
					table.insert( current_table, new_table )
				end
				is_insert_last_op = false
				table.insert( parent_tables, current_table )
				current_table = new_table
			elseif token == "}" then
				is_insert_last_op = false
				current_table = table.remove( parent_tables )
				if current_table == nil then
					return nil, "Mismatched recursive tables on line " .. i
				end
			else
				is_insert_last_op = true
				table.insert( current_table, tokens[ 1 ] )
			end
		elseif num_tokens == 2 then
			is_insert_last_op = false
			if convert and tonumber( tokens[ 1 ] ) then
				tokens[ 1 ] = tonumber( tokens[ 1 ] )
			end
			current_table[ tokens[ 1 ] ] = tokens[ 2 ]
		elseif num_tokens > 2 then
			return nil, "Bad input on line " .. i
		end
	end
	if #parent_tables ~= 0 then
		return nil, "Mismatched recursive tables"
	end
	if convert and table.Count( current_table ) == 1 and
		type( current_table.Out ) == "table" then
		current_table = current_table.Out
	end
	return current_table
end
function ULib.makeKeyValues( t, tab, completed )
	ULib.checkArg( 1, "ULib.makeKeyValues", "table", t )
	tab = tab or ""
	completed = completed or {}
	if completed[ t ] then return "" end
	completed[ t ] = true
	local str = ""
	for k, v in pairs( t ) do
		str = str .. tab
		if type( k ) ~= "number" then
			str = string.format( "%s%q\t", str, tostring( k ) )
		end
		if type( v ) == "table" then
			str = string.format( "%s\n%s{\n%s%s}\n", str, tab, ULib.makeKeyValues( v, tab .. "\t", completed ), tab )
		elseif type( v ) == "string" then
			str = string.format( "%s%q\n", str, v )
		else
			str = str .. tostring( v ) .. "\n"
		end
	end
	return str
end
function ULib.toBool( x )
	if type( x ) == "boolean" then return x end
	if x == nil then return false end
	if tonumber( x ) ~= nil then
		x = math.Round( tonumber( x ) )
		if x == 0 then
			return false
		else
			return true
		end
	end
	x = x:lower()
	if x == "t" or x == "true" or x == "yes" or x == "y" then
		return true
	else
		return false
	end
end
local function navigateUpTo(currentPointer, tableCrumbs)
	for i=1, #tableCrumbs-1 do
		local nextTableName = tableCrumbs[i]
		currentPointer = currentPointer[ nextTableName ]
		if type(currentPointer) ~= "table" then return false end
	end
	return true, currentPointer
end
local function getCrumbsTable( varLocation )
	local tableCrumbs = ULib.explode( "[%.%[]", varLocation )
	for i=1, #tableCrumbs do
		local newCrumb, replaced = string.gsub( tableCrumbs[i], "]$", "" )
		if replaced > 0 then tableCrumbs[i] = tonumber( newCrumb ) end
	end
	return tableCrumbs
end
function ULib.findVar( varLocation, rootTable )
	ULib.checkArg( 1, "ULib.findVar", "string", varLocation )
	ULib.checkArg( 2, "ULib.findVar", {"table", "nil"}, rootTable )
	rootTable = rootTable or _G
	local tableCrumbs = getCrumbsTable( varLocation )
	local success, lastTable = navigateUpTo(rootTable, tableCrumbs)
	if not success then return false end
	local lastCrumb = tableCrumbs[#tableCrumbs]
	return true, lastTable[lastCrumb]
end
function ULib.setVar( varLocation, varValue, rootTable )
	ULib.checkArg( 1, "ULib.setVar", "string", varLocation )
	ULib.checkArg( 3, "ULib.setVar", {"table", "nil"}, rootTable )
	rootTable = rootTable or _G
	local tableCrumbs = getCrumbsTable( varLocation )
	local success, lastTable = navigateUpTo(rootTable, tableCrumbs)
	if not success then return false end
	local lastCrumb = tableCrumbs[#tableCrumbs]
	local prevVal = lastTable[lastCrumb]
	lastTable[lastCrumb] = varValue
	return true, prevVal
end
function ULib.throwBadArg( argnum, fnName, expected, data, throwLevel )
	throwLevel = throwLevel or 3
	local str = "bad argument"
	if argnum then
		str = str .. " #" .. tostring( argnum )
	end
	if fnName then
		str = str .. " to " .. fnName
	end
	if expected or data then
		str = str .. " ("
		if expected then
			str = str .. expected .. " expected"
		end
		if expected and data then
			str = str .. ", "
		end
		if data then
			str = str .. "got " .. type( data )
		end
		str = str .. ")"
	end
	error( str, throwLevel )
end
function ULib.checkArg( argnum, fnName, expected, data, throwLevel )
	throwLevel = throwLevel or 4
	if type( expected ) == "string" then
		if type( data ) == expected then
			return
		else
			return ULib.throwBadArg( argnum, fnName, expected, data, throwLevel )
		end
	else
		if table.HasValue( expected, type( data ) ) then
			return
		else
			return ULib.throwBadArg( argnum, fnName, table.concat( expected, "," ), data, throwLevel )
		end
	end
end
function ULib.isValidSteamID( steamid )
	return steamid:match( "^STEAM_%d:%d:%d+$" ) ~= nil
end
function ULib.isValidIP( ip )
	if ip:find( "^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$" ) then
		return true
	else
		return false
	end
end
function ULib.removeCommentHeader( data, comment_char )
	comment_char = comment_char or ";"
	local lines = ULib.explode( "\r?\n", data )
	local end_comment_line = 0
	for _, line in ipairs( lines ) do
		local trimmed = line:Trim()
		if trimmed == "" or trimmed:sub( 1, 1 ) == comment_char then
			end_comment_line = end_comment_line + 1
		else
			break
		end
	end
	local not_comment = table.concat( lines, "\n", end_comment_line + 1 )
	return not_comment:Trim()
end
function ULib.stringTimeToMinutes( str )
	if str == nil or type( str ) == "number" then
		return str
	end
	str = str:gsub( " ", "" )
	local minutes = 0
	local keycode_location = str:find( "%a" )
	while keycode_location do
		local keycode = str:sub( keycode_location, keycode_location )
		local num = tonumber( str:sub( 1, keycode_location - 1 ) )
		if not num then
			return nil
		end
		local multiplier
		if keycode == "h" then
			multiplier = 60
		elseif keycode == "d" then
			multiplier = 60 * 24
		elseif keycode == "w" then
			multiplier = 60 * 24 * 7
		elseif keycode == "y" then
			multiplier = 60 * 24 * 365
		else
			return nil
		end
		str = str:sub( keycode_location + 1 )
		keycode_location = str:find( "%a" )
		minutes = minutes + num * multiplier
	end
	local num = 0
	if str ~= "" then
		num = tonumber( str )
	end
	if num == nil then
		return nil
	end
	return minutes + num
end
ULib.stringTimeToSeconds = ULib.stringTimeToMinutes
function ULib.secondsToStringTime( secs )
	local str = ""
	local mins = math.ceil(secs / 60)
	local minsInYear = 60 * 24 * 365
	if mins >= minsInYear then
		local years = math.floor( mins / minsInYear )
		mins = mins % minsInYear
		str = string.format( "%s%i year%s ", str, years, (years > 1 and "s" or "") )
	end
	local minsInWeek = 60 * 24 * 7
	if mins >= minsInWeek then
		local weeks = math.floor( mins / minsInWeek )
		mins = mins % minsInWeek
		str = string.format( "%s%i week%s ", str, weeks, (weeks > 1 and "s" or "") )
	end
	local minsInDay = 60 * 24
	if mins >= minsInDay then
		local days = math.floor( mins / minsInDay )
		mins = mins % minsInDay
		str = string.format( "%s%i day%s ", str, days, (days > 1 and "s" or "") )
	end
	local minsInHour = 60
	if mins >= minsInHour then
		local hours = math.floor( mins / minsInHour )
		mins = mins % minsInHour
		str = string.format( "%s%i hour%s ", str, hours, (hours > 1 and "s" or "") )
	end
	if mins > 0 then
		str = string.format( "%s%i minute%s ", str, mins, (mins > 1 and "s" or "") )
	end
	return str:Trim()
end
function inheritsFrom( base_class )
	local new_class = {}
	local instance_mt = { __index = new_class, class=new_class, base_class=base_class }
	local class_mt = table.Copy( instance_mt )
	class_mt.__index = base_class or root_class
	class_mt.__call = root_class.call
	class_mt.class = new_class
	class_mt.instance_mt = instance_mt
	setmetatable( new_class, class_mt )
	return new_class
end
root_class = {}
function root_class.call( parent_table, ... )
	return parent_table:class():create( ... )
end
function root_class:create( ... )
	local newinst = {}
	setmetatable( newinst, getmetatable( self ).instance_mt )
	newinst:instantiate( ... )
	return newinst
end
function root_class:class()
	return getmetatable( self ).class
end
function root_class:superClass()
	base_class = getmetatable( self ).base_class
	return base_class ~= root_class and base_class or nil
end
function root_class:instantiate()
end
function root_class:isa( target_class )
	local cur_class = self:class()
	while cur_class do
		if cur_class == target_class then
			return true
		else
			cur_class = cur_class:superClass()
		end
	end
	return false
end
function isClass( obj )
	return type( obj ) == "table" and type( obj.isa ) == "function" and obj:isa( root_class )
end
_ = nil
local meta = getmetatable( _G ) or {}
if type( meta ) == "boolean" then return end
local old__newindex = meta.__newindex
setmetatable( _G, meta )
function meta.__newindex( t, k, v )
	if k == "_" then
		return
	end
	if old__newindex then
		old__newindex( t, k, v )
	else
		rawset( t, k, v )
	end
end