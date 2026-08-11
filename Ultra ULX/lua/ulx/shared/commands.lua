ULib.cmds = ULib.cmds or {}
local cmds = ULib.cmds
local function T(key, ...)
	if ULib.ulx_lang then return ULib.ulx_lang.T(key, ...) end
	if ... then return string.format(key, ...) end
	return key
end
cmds.optional = cmds.optional or {}
cmds.restrictToCompletes = cmds.restrictToCompletes or {}
cmds.takeRestOfLine = cmds.takeRestOfLine or {}
cmds.round = cmds.round or {}
cmds.ignoreCanTarget = cmds.ignoreCanTarget or {}
cmds.allowTimeString = cmds.allowTimeString or {}
cmds.BaseArg = inheritsFrom( nil )
function cmds.BaseArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	error( "Unimplemented BaseArg:parseAndValidate called" )
end
function cmds.BaseArg:complete( arg, cmdInfo, plyRestrictions )
	error( "Unimplemented BaseArg:complete called" )
end
function cmds.BaseArg:usage( cmdInfo, plyRestrictions )
	error( "Unimplemented BaseArg:usage called" )
end
cmds.NumArg = inheritsFrom( cmds.BaseArg )
function cmds.NumArg:processRestrictions( cmdRestrictions, plyRestrictions )
	self.min = nil
	self.max = nil
	local allowTimeString = table.HasValue( cmdRestrictions, cmds.allowTimeString )
	if plyRestrictions then
		if not plyRestrictions:find( ":" ) then
			self.min = plyRestrictions
			self.max = plyRestrictions
		else
			local timeStringMatcher = "[-hdwy%d]*"
			local dummy
			dummy, dummy, self.min, self.max = plyRestrictions:find( "^(" .. timeStringMatcher .. "):(" .. timeStringMatcher .. ")$" )
		end
		if not allowTimeString then
			self.min = tonumber( self.min )
			self.max = tonumber( self.max )
		else
			self.min = ULib.stringTimeToMinutes( self.min )
			self.max = ULib.stringTimeToMinutes( self.max )
		end
	end
	if allowTimeString and not self.timeStringsParsed then
		self.timeStringsParsed = true
		cmdRestrictions.min = ULib.stringTimeToMinutes( cmdRestrictions.min )
		cmdRestrictions.max = ULib.stringTimeToMinutes( cmdRestrictions.max )
		cmdRestrictions.default = ULib.stringTimeToMinutes( cmdRestrictions.default )
	end
	if cmdRestrictions.min and (not self.min or self.min < cmdRestrictions.min) then
		self.min = cmdRestrictions.min
	end
	if cmdRestrictions.max and (not self.max or self.max > cmdRestrictions.max) then
		self.max = cmdRestrictions.max
	end
end
function cmds.NumArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( cmdInfo, plyRestrictions )
	if not arg and self.min and self.min == self.max then
		return self.min
	end
	if not arg and table.HasValue( cmdInfo, cmds.optional ) then
		arg = cmdInfo.default or 0
	end
	local allowTimeString = table.HasValue( cmdInfo, cmds.allowTimeString )
	local num
	if not allowTimeString then
		num = tonumber( arg )
	else
		num = ULib.stringTimeToMinutes( arg )
	end
	local typeString
	if not allowTimeString then
		typeString = T("type_number")
	else
		typeString = T("type_number_or_time")
	end
	if not num then
		return nil, T("cmd_invalid_number", typeString, tostring(arg))
	end
	if self.min and num < self.min then
		return nil, T("cmd_number_below_min", typeString, arg, self.min)
	end
	if self.max and num > self.max then
		return nil, T("cmd_number_above_max", typeString, arg, self.max)
	end
	if table.HasValue( cmdInfo, cmds.round ) then
		return math.Round( num )
	end
	return num
end
function cmds.NumArg:complete( ply, arg, cmdInfo, plyRestrictions )
	return { self:usage( cmdInfo, plyRestrictions ) }
end
function cmds.NumArg:usage( cmdInfo, plyRestrictions )
	self:processRestrictions( cmdInfo, plyRestrictions )
	local isOptional = table.HasValue( cmdInfo, cmds.optional )
	local str = cmdInfo.hint or "number"
	if self.min == self.max and self.min then
		return "<" .. str .. ": " .. self.min .. ">"
	else
		str = "<" .. str
		if self.min or self.max or cmdInfo.default or isOptional then
			str = str .. ": "
		end
		if self.min then
			str = str .. self.min .. "<="
		end
		if self.min or self.max then
			str = str .. "x"
		end
		if self.max then
			str = str .. "<=" .. self.max
		end
		if cmdInfo.default or isOptional then
			if self.min or self.max then
					str = str .. ", "
			end
			str = str .. "default " .. (cmdInfo.default or 0)
		end
		str = str .. ">"
		if isOptional then
			str = "[" .. str .. "]"
		end
		return str
	end
end
cmds.BoolArg = inheritsFrom( cmds.BaseArg )
function cmds.BoolArg:processRestrictions( cmdRestrictions, plyRestrictions )
	self.restrictedTo = nil
	if plyRestrictions and plyRestrictions ~= "*" then
		self.restrictedTo = ULib.toBool( plyRestrictions )
	end
end
function cmds.BoolArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( cmdInfo, plyRestrictions )
	if not arg and table.HasValue( cmdInfo, cmds.optional ) then
		arg = cmdInfo.default or false
	end
	local desired = ULib.toBool( arg )
	if self.restrictedTo ~= nil and desired ~= self.restrictedTo then
		return nil, T("cmd_bool_not_allowed", tostring(desired))
	end
	return desired
end
function cmds.BoolArg:complete( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( cmdInfo, plyRestrictions )
	local ret = { self:usage( cmdInfo, plyRestrictions ) }
	if not self.restrictedTo then
		table.insert( ret, "0" )
	end
	if self.restrictedTo ~= false then
		table.insert( ret, "1" )
	end
	return ret
end
function cmds.BoolArg:usage( cmdInfo, plyRestrictions )
	self:processRestrictions( cmdInfo, plyRestrictions )
	local isOptional = table.HasValue( cmdInfo, cmds.optional )
	local str = "<"
	if cmdInfo.hint then
		str = str .. cmdInfo.hint .. ": "
	end
	if self.restrictedTo ~= nil then
		str = str .. (self.restrictedTo and "1>" or "0>")
	else
		str = str .. "0/1>"
	end
	if isOptional then
		str = "[" .. str .. "]"
	end
	return str
end
cmds.PlayerArg = inheritsFrom( cmds.BaseArg )
function cmds.PlayerArg:processRestrictions( ply, cmdRestrictions, plyRestrictions )
	self.restrictedTargets = nil
	cmds.PlayerArg.restrictedTargets = nil
	local ignore_can_target = false
	if plyRestrictions and plyRestrictions:sub( 1, 1 ) == "$" then
		plyRestrictions = plyRestrictions:sub( 2 )
		ignore_can_target = true
	end
	if cmdRestrictions.target then
		self.restrictedTargets = ULib.getUsers( cmdRestrictions.target, true, ply )
	end
	if plyRestrictions and plyRestrictions ~= "" then
		local restricted = ULib.getUsers( plyRestrictions, true, ply )
		if not restricted or not self.restrictedTargets then
			self.restrictedTargets = restricted
		else
			local i = 1
			while self.restrictedTargets[ i ] do
				if not table.HasValue( restricted, self.restrictedTargets[ i ] ) then
					table.remove( self.restrictedTargets, i )
				else
					i = i + 1
				end
			end
		end
	end
	if ply:IsValid() and not ignore_can_target and not table.HasValue( cmdRestrictions, cmds.ignoreCanTarget ) and ULib.ucl.getGroupCanTarget( ply:GetUserGroup() ) then
		local selfTarget = "$" .. ULib.getUniqueIDForPlayer( ply )
		local restricted = ULib.getUsers( ULib.ucl.getGroupCanTarget( ply:GetUserGroup() ) .. "," .. selfTarget, true, ply )
		if not restricted or not self.restrictedTargets then
			self.restrictedTargets = restricted
		else
			local i = 1
			while self.restrictedTargets[ i ] do
				if not table.HasValue( restricted, self.restrictedTargets[ i ] ) then
					table.remove( self.restrictedTargets, i )
				else
					i = i + 1
				end
			end
		end
	end
end
function cmds.PlayerArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( ply, cmdInfo, plyRestrictions )
	if not arg and table.HasValue( cmdInfo, cmds.optional ) then
		if not cmdInfo.default and not ply:IsValid() then
			return nil, T("cmd_target_required")
		end
		arg = cmdInfo.default or "$" .. ULib.getUniqueIDForPlayer( ply )
	end
	local target, err_msg1 = ULib.getUser( arg, true, ply )
	local return_value, err_msg2 = hook.Call( ULib.HOOK_PLAYER_TARGET, _, ply, cmdInfo.cmd, target )
	if return_value == false then
		return nil, err_msg2 or T("cmd_cannot_target")
	elseif type( return_value ) == "Player" then
		target = return_value
	end
	if return_value ~= true then
		if not target then return nil, err_msg1 or T("cmd_no_target_found") end
		if self.restrictedTargets == false or (self.restrictedTargets and not table.HasValue( self.restrictedTargets, target )) then
			return nil, T("cmd_cannot_target")
		end
	end
	return target
end
function cmds.PlayerArg:complete( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( ply, cmdInfo, plyRestrictions )
	local targets
	if self.restrictedTargets == false then
		targets = {}
	elseif arg == "" then
		targets = player.GetAll()
	else
		targets = ULib.getUsers( arg, true, ply )
		if not targets then targets = {} end
	end
	if self.restrictedTargets then
		local i = 1
		while targets[ i ] do
			if not table.HasValue( self.restrictedTargets, targets[ i ] ) then
				table.remove( targets, i )
			else
				i = i + 1
			end
		end
	end
	local names = {}
	for _, ply in ipairs( targets ) do
		table.insert( names, string.format( '"%s"', ply:Nick() ) )
	end
	table.sort( names )
	if #names == 0 then
		return { self:usage( cmdInfo, plyRestrictions ) }
	end
	return names
end
function cmds.PlayerArg:usage( cmdInfo, plyRestrictions )
	local isOptional = table.HasValue( cmdInfo, cmds.optional )
	if isOptional then
		if not cmdInfo.default or cmdInfo.default == "^" then
			return "[<player, defaults to self>]"
		else
			return "[<player, defaults to \"" .. cmdInfo.default .. "\">]"
		end
	end
	return "<player>"
end
cmds.PlayersArg = inheritsFrom( cmds.PlayerArg )
function cmds.PlayersArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( ply, cmdInfo, plyRestrictions )
	if not arg and table.HasValue( cmdInfo, cmds.optional ) then
		if not cmdInfo.default and not ply:IsValid() then
			return nil, T("cmd_target_required")
		end
		arg = cmdInfo.default or "$" .. ULib.getUniqueIDForPlayer( ply )
	end
	local targets = ULib.getUsers( arg, true, ply )
	local return_value, err_msg = hook.Call( ULib.HOOK_PLAYER_TARGETS, _, ply, cmdInfo.cmd, targets )
	if return_value == false then
		return nil, err_msg or T("cmd_cannot_target_any")
	elseif type( return_value ) == "table" then
		if #return_value == 0 then
			return nil, err_msg or T("cmd_cannot_target_any")
		else
			targets = return_value
		end
	end
	if return_value ~= true then
		if not targets then return nil, T("cmd_no_targets_found") end
		if self.restrictedTargets then
			local i = 1
			while targets[ i ] do
				if not table.HasValue( self.restrictedTargets, targets[ i ] ) then
					table.remove( targets, i )
				else
					i = i + 1
				end
			end
		end
		if self.restrictedTargets == false or #targets == 0 then
			return nil, T("cmd_cannot_target_any")
		end
	end
	return targets
end
function cmds.PlayersArg:usage( cmdInfo, plyRestrictions )
	local isOptional = table.HasValue( cmdInfo, cmds.optional )
	if isOptional then
		if not cmdInfo.default or cmdInfo.default == "^" then
			return "[<players, defaults to self>]"
		else
			return "[<players, defaults to \"" .. cmdInfo.default .. "\">]"
		end
	end
	return "<players>"
end
cmds.CallingPlayerArg = inheritsFrom( cmds.BaseArg )
cmds.CallingPlayerArg.invisible = true
function cmds.CallingPlayerArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	return ply
end
cmds.StringArg = inheritsFrom( cmds.BaseArg )
function cmds.StringArg:processRestrictions( cmdRestrictions, plyRestrictions )
	self.restrictedCompletes = table.Copy( cmdRestrictions.completes )
	self.playerLevelRestriction = nil
	if plyRestrictions and plyRestrictions ~= "*" then
		self.playerLevelRestriction = true
		local restricted = ULib.explode( ",", plyRestrictions )
		if not self.restrictedCompletes or not table.HasValue( cmdRestrictions, cmds.restrictToCompletes ) then
			self.restrictedCompletes = restricted
		else
			local i = 1
			while self.restrictedCompletes[ i ] do
				if not table.HasValue( restricted, self.restrictedCompletes[ i ] ) then
					table.remove( self.restrictedCompletes, i )
				else
					i = i + 1
				end
			end
		end
	end
end
function cmds.StringArg:parseAndValidate( ply, arg, cmdInfo, plyRestrictions )
	self:processRestrictions( cmdInfo, plyRestrictions )
	if not arg and table.HasValue( cmdInfo, cmds.optional ) then
		return cmdInfo.default or ""
	end
	if arg:find( "%c" ) then
		return nil, "string cannot contain control characters"
	end
	if table.HasValue( cmdInfo, cmds.restrictToCompletes ) or self.playerLevelRestriction then
		if self.restrictedCompletes and not table.HasValue( self.restrictedCompletes, arg ) then
			if cmdInfo.error then
				return nil, string.format( cmdInfo.error, arg )
			else
				return nil, "invalid string"
			end
		end
	end
	return arg
end
function cmds.StringArg:complete( ply, arg, cmdInfo, plyRestrictions )
	if cmdInfo.autocomplete_fn then
		return cmdInfo.autocomplete_fn( ply, arg, cmdInfo, plyRestrictions )
	end
	self:processRestrictions( cmdInfo, plyRestrictions )
	if self.restrictedCompletes then
		local ret = {}
		for _, v in ipairs( self.restrictedCompletes ) do
			if v:lower():sub( 1, arg:len() ) == arg:lower() then
				if v:find( "%s" ) then
					v = string.format( '"%s"', v )
				end
				table.insert( ret, v )
			end
		end
		if #ret == 0 then
			return {self:usage( cmdInfo, plyRestrictions )}
		end
		return ret
	else
		return {self:usage( cmdInfo, plyRestrictions )}
	end
end
function cmds.StringArg:usage( cmdInfo, plyRestrictions )
	local isOptional = table.HasValue( cmdInfo, cmds.optional )
	local str = cmdInfo.hint or "string"
	if cmdInfo.repeat_min or table.HasValue( cmdInfo, cmds.takeRestOfLine ) then
		str = "{" .. str .. "}"
	else
		str = "<" .. str .. ">"
	end
	if isOptional then
		str = "[" .. str .. "]"
	end
	return str
end
cmds.translatedCmds = cmds.translatedCmds or {}
local translatedCmds = cmds.translatedCmds
local function translateCmdCallback( ply, commandName, argv )
	local cmd = translatedCmds[ commandName:lower() ]
	if not cmd then return error( "Invalid command!" ) end
	local isOpposite = string.lower( cmd.opposite or "" ) == string.lower( commandName )
	local access, accessTag = ULib.ucl.query( ply, commandName )
	if not access then
		ULib.tsayError( ply, "You don't have access to this command, " .. ply:Nick() .. "!", true )
		return
	end
	local accessPieces = {}
	if accessTag then
		accessPieces = ULib.splitArgs( accessTag, "<", ">" )
	end
	local args = {}
	local argNum = 1
	for i, argInfo in ipairs( cmd.args ) do
		if isOpposite and cmd.oppositeArgs[ i ] then
			table.insert( args, cmd.oppositeArgs[ i ] )
		else
			if not argInfo.type.invisible and not argInfo.invisible and not argv[ argNum ] and not table.HasValue( argInfo, cmds.optional ) then
				ULib.tsayError( ply, "Usage: " .. commandName .. " " .. cmd:getUsage( ply ), true )
				return
			end
			local arg
			if not argInfo.repeat_min and not table.HasValue( argInfo, cmds.takeRestOfLine ) then
				arg = argv[ argNum ]
			elseif not argInfo.repeat_min then
				arg = ""
				for i=argNum, #argv do
					if argv[ i ]:find( "%s" ) then
						arg = arg .. " " .. string.format( '"%s"', argv[ i ] )
					else
						arg = arg .. " " .. argv[ i ]
					end
				end
				arg = arg:Trim()
				if arg:sub( 1, 1 ) == "\"" and arg:sub( -1, -1 ) == "\""
					and arg:find( "\"", 2, true ) == arg:len() then
					arg = ULib.stripQuotes( arg )
				end
			end
			if not argInfo.repeat_min then
				local ret, err = argInfo.type:parseAndValidate( ply, arg, argInfo, accessPieces[ argNum ] )
				if ret == nil then
					ULib.tsayError( ply, string.format( T("cmd_error_format"), commandName, argNum, err ), true )
					return
				end
				table.insert( args, ret )
			else
				if #argv - argNum + 1 < argInfo.repeat_min then
					ULib.tsayError( ply, string.format( T("cmd_error_format"), commandName, #argv+1, T("cmd_expected_more_args") ), true )
					return
				end
				for i=argNum, #argv do
					local ret, err = argInfo.type:parseAndValidate( ply, argv[ i ], argInfo, accessPieces[ argNum ] )
					if ret == nil then
						ULib.tsayError( ply, string.format( T("cmd_error_format"), commandName, i, err ), true )
						return
					end
					table.insert( args, ret )
				end
			end
		end
		if not argInfo.type.invisible and not argInfo.invisible then
			argNum = argNum + 1
		end
	end
	local callResult = cmd:call( isOpposite, unpack( args ) )
	hook.Call( ULib.HOOK_POST_TRANSLATED_COMMAND, _, ply, commandName, args, callResult )
end
local function translateAutocompleteCallback( commandName, args )
	local cmd = translatedCmds[ commandName:lower() ]
	if not cmd then return error( "Invalid command!" ) end
	local isOpposite = string.lower( cmd.opposite or "" ) == string.lower( commandName )
	local ply
	if CLIENT then
		ply = LocalPlayer()
	else
		ply = Entity( 1 )
		if not ply or not ply:IsValid() or not ply:IsListenServerHost() then
			return error( "Assumption fail!" )
		end
	end
	local access, accessTag = ULib.ucl.query( ply, commandName )
	local takes_rest_of_line = table.HasValue( cmd.args[ #cmd.args ], cmds.takeRestOfLine ) or cmd.args[ #cmd.args ].repeat_min
	local accessPieces = {}
	if accessTag then
		accessPieces = ULib.splitArgs( accessTag, "<", ">" )
	end
	local ret = {}
	local argv, mismatched_quotes = ULib.splitArgs( args )
	local argn = #argv
	local on_new_arg = args == "" or (args:sub( -1 ) == " " and not mismatched_quotes)
	if on_new_arg then argn = argn + 1 end
	local hidden_argn = argn
	for i=1, argn do
		if cmd.args[ i ] and (cmd.args[ i ].type.invisible or cmd.args[ i ].invisible) then
			hidden_argn = hidden_argn + 1
		end
	end
	while cmd.args[ hidden_argn ] and (cmd.args[ hidden_argn ].type.invisible or cmd.args[ hidden_argn ].invisible) do
		hidden_argn = hidden_argn + 1
	end
	if hidden_argn > #cmd.args and takes_rest_of_line then
		hidden_argn = #cmd.args
		argn = hidden_argn
		for i=1, argn do
			if cmd.args[ i ] and (cmd.args[ i ].type.invisible or cmd.args[ i ].invisible) then
				argn = argn - 1
			end
		end
	end
	local completedArgs = ""
	local partialArg = ""
	for i=1, #argv do
		local str = argv[ i ]
		if str:find( "%s" ) then
			str = string.format( '"%s"', str )
		end
		if i < argn or (cmd.args[ #cmd.args ].repeat_min and i < #argv+(on_new_arg and 1 or 0)) then
			completedArgs = completedArgs .. str .. " "
		else
			partialArg = partialArg .. str .. " "
		end
	end
	completedArgs = completedArgs:Trim()
	partialArg = ULib.stripQuotes( partialArg:Trim() )
	if isOpposite and cmd.oppositeArgs[ hidden_argn ] then
		local str = commandName .. " "
		if completedArgs and completedArgs:len() > 0 then
			str = str .. completedArgs .. " "
		end
		table.insert( ret, str .. cmd.oppositeArgs[ hidden_argn ] )
	elseif cmd.args[ hidden_argn ] then
		if cmd.args[ #cmd.args ].repeat_min then
			partialArg = argv[ #argv ]
			if args == "" or (args:sub( -1 ) == " " and not mismatched_quotes) then partialArg = nil end
		end
		ret = cmd.args[ hidden_argn ].type:complete( ply, partialArg or "", cmd.args[ hidden_argn ], accessPieces[ argn ] )
		local prefix = commandName .. " "
		if completedArgs:len() > 0 then
			prefix = prefix .. completedArgs .. " "
		end
		for k, v in ipairs( ret ) do
			ret[ k ] = prefix .. v
		end
	end
	return ret
end
cmds.TranslateCommand = inheritsFrom( nil )
function cmds.TranslateCommand:instantiate( cmd, fn, say_cmd, hide_say, no_space_in_say, unsafe )
	ULib.checkArg( 1, "ULib.cmds.TranslateCommand", "string", cmd, 5 )
	if SERVER then
		ULib.checkArg( 2, "ULib.cmds.TranslateCommand", "function", fn, 5 )
	else
		ULib.checkArg( 2, "ULib.cmds.TranslateCommand", {"nil", "function"}, fn, 5 )
	end
	ULib.checkArg( 3, "ULib.cmds.TranslateCommand", {"nil", "string", "table"}, say_cmd, 5 )
	ULib.checkArg( 4, "ULib.cmds.TranslateCommand", {"nil", "boolean"}, hide_say, 5 )
	ULib.checkArg( 5, "ULib.cmds.TranslateCommand", {"nil", "boolean"}, no_space_in_say, 5 )
	ULib.checkArg( 6, "ULib.cmds.TranslateCommand", {"nil", "boolean"}, unsafe, 5 )
	self.args = {}
	self.fn = fn
	self.cmd = cmd
	translatedCmds[ cmd:lower() ] = self
	cmds.addCommand( cmd, translateCmdCallback, translateAutocompleteCallback, cmd, say_cmd, hide_say, no_space_in_say, unsafe )
end
function cmds.TranslateCommand:addParam( t )
	ULib.checkArg( 1, "ULib.cmds.TranslateCommand:addParam", "table", t )
	t.cmd = self.cmd
	table.insert( self.args, t )
end
function cmds.TranslateCommand:setOpposite( cmd, args, say_cmd, hide_say, no_space_in_say )
	ULib.checkArg( 1, "ULib.cmds.TranslateCommand:setOpposite", "string", cmd )
	ULib.checkArg( 2, "ULib.cmds.TranslateCommand:setOpposite", "table", args )
	ULib.checkArg( 3, "ULib.cmds.TranslateCommand:setOpposite", {"nil", "string", "table"}, say_cmd )
	ULib.checkArg( 4, "ULib.cmds.TranslateCommand:setOpposite", {"nil", "boolean"}, hide_say )
	ULib.checkArg( 5, "ULib.cmds.TranslateCommand:setOpposite", {"nil", "boolean"}, no_space_in_say )
	self.opposite = cmd
	translatedCmds[ cmd:lower() ] = self
	self.oppositeArgs = args
	cmds.addCommand( cmd, translateCmdCallback, translateAutocompleteCallback, cmd, say_cmd, hide_say, no_space_in_say )
	if self.default_access then
		self:defaultAccess( self.default_access )
	end
end
function cmds.TranslateCommand:getUsage( ply )
	ULib.checkArg( 1, "ULib.cmds.TranslateCommand:getUsage", {"Entity", "Player"}, ply )
	local access, accessTag = ULib.ucl.query( ply, self.cmd )
	local accessPieces = {}
	if accessTag then
		accessPieces = ULib.explode( "%s+", accessTag )
	end
	local str = ""
	local argNum = 1
	for i, argInfo in ipairs( self.args ) do
		if not argInfo.type.invisible and not argInfo.invisible then
			str = str .. " " .. argInfo.type:usage( argInfo, accessPieces[ argNum ] )
			argNum = argNum + 1
		end
	end
	return str:Trim()
end
function cmds.TranslateCommand:call( isOpposite, ... )
	return self.fn( ... )
end
function cmds.TranslateCommand:defaultAccess( access )
	ULib.checkArg( 1, "ULib.cmds.TranslateCommand:defaultAccess", "string", access )
	if CLIENT then return end
	ULib.ucl.registerAccess( self.cmd, access, "Grants access to the " .. self.cmd .. " command", "Command" )
	if self.opposite then
		ULib.ucl.registerAccess( self.opposite, access, "Grants access to the " .. self.opposite .. " command", "Command" )
	end
	self.default_access = access
end
local routedCmds = {}
local sayCmds = {}
local sayCommandCallback
function cmds.getCommandTableAndArgv( commandName, argv, valveErrorCorrection )
	if valveErrorCorrection then
		local args = ""
		for k, v in ipairs( argv ) do
			args = string.format( '%s"%s" ', args, v )
		end
		args = string.Trim( args )
		args = args:gsub( "\" \":\" \"", ":" )
		args = args:gsub( "\" \"'\" \"", "'" )
		argv = ULib.splitArgs( args )
	else
		argv = table.Copy( argv )
	end
	local currTable = routedCmds[ commandName:lower() ]
	if not currTable then return nil end
	local nextWord = table.remove( argv, 1 )
	while nextWord and currTable[ nextWord:lower() ] do
		commandName = commandName .. " " .. nextWord
		currTable = currTable[ nextWord:lower() ]
		nextWord = table.remove( argv, 1 )
	end
	table.insert( argv, 1, nextWord )
	return currTable, commandName, argv
end
function cmds.execute( cmdTable, ply, commandName, argv )
	if CLIENT and not cmdTable.__client_only then
		ULib.redirect( ply, commandName, argv )
		return
	end
	if not cmdTable.__fn then
		return error( "Attempt to call undefined command: " .. commandName )
	end
	local return_value = hook.Call( ULib.HOOK_COMMAND_CALLED, _, ply, commandName, argv )
	if return_value ~= false then
		cmdTable.__fn( ply, commandName, argv )
	end
end
local function routedCommandCallback( ply, commandName, argv )
	local curtime = CurTime()
	if not ply.ulib_threat_level or ply.ulib_threat_time <= curtime then
		ply.ulib_threat_level = 1
		ply.ulib_threat_time = curtime + 3
		ply.ulib_threat_warned = nil
	elseif ply.ulib_threat_level >= 100 then
		if not ply.ulib_threat_warned then
			ULib.tsay( ply, "You are running too many commands too quickly, please wait before executing more" )
			ply.ulib_threat_warned = true
		end
		return
	else
		ply.ulib_threat_level = ply.ulib_threat_level + 1
	end
	if not routedCmds[ commandName:lower() ] then
		return error( "Base command \"" .. commandName .. "\" is not defined!" )
	end
	local currTable
	currTable, commandName, argv = cmds.getCommandTableAndArgv( commandName, argv, true )
	cmds.execute( currTable, ply, commandName, argv )
end
if SERVER then
	sayCommandCallback = function( ply, sayCommand, argv )
		if not sayCmds[ sayCommand ] then
			return error( "Say command \"" .. sayCommand .. "\" is not defined!" )
		end
		sayCmds[ sayCommand ].__fn( ply, sayCmds[ sayCommand ].__cmd, argv )
	end
	local function hookRoute( ply, command, argv )
		if #argv > 0 then
			local commandName = table.remove( argv, 1 )
			if routedCmds[ commandName:lower() ] then
				routedCommandCallback( ply, commandName, argv )
			end
		end
	end
	concommand.Add( "_u", hookRoute )
end
local function autocompleteCallback( commandName, args )
	args = args:gsub( "^%s*", "" )
	local currTable = routedCmds[ commandName:lower() ]
	local dummy, dummy, nextWord = args:find( "^(%S+)%s" )
	while nextWord and currTable[ nextWord:lower() ] do
		commandName = commandName .. " " .. nextWord
		currTable = currTable[ nextWord:lower() ]
		args = args:gsub( ULib.makePatternSafe( nextWord ) .. "%s+", "", 1 )
		local dummy
		dummy, dummy, nextWord = args:find( "^(%S+)%s" )
	end
	if not currTable.__autocomplete then
		local ply
		if CLIENT then
			ply = LocalPlayer()
		else
			ply = Entity( 1 )
			if not ply or not ply:IsValid() or not ply:IsListenServerHost() then
				return error( "Assumption fail!" )
			end
		end
		local ret = {}
		for cmd, cmdInfo in pairs( currTable ) do
			if cmd ~= "__fn" and cmd ~= "__word" and cmd ~= "__access_string" and cmd ~= "__client_only" then
				if cmd:sub( 1, args:len() ) == args and (not cmdInfo.__access_string or ply:query( cmdInfo.__access_string )) then
					table.insert( ret, commandName .. " " .. cmdInfo.__word )
				end
			end
		end
		table.sort( ret )
		return ret
	end
	return currTable.__autocomplete( commandName, args )
end
function cmds.addCommand( cmd, fn, autocomplete, access_string, say_cmd, hide_say, no_space_in_say, unsafe )
	ULib.checkArg( 1, "ULib.cmds.addCommand", "string", cmd )
	if SERVER then
		ULib.checkArg( 2, "ULib.cmds.addCommand", "function", fn )
	else
		ULib.checkArg( 2, "ULib.cmds.addCommand", {"nil", "function"}, fn )
	end
	ULib.checkArg( 3, "ULib.cmds.addCommand", {"nil", "function"}, autocomplete )
	ULib.checkArg( 4, "ULib.cmds.addCommand", {"nil", "string"}, access_string )
	ULib.checkArg( 5, "ULib.cmds.addCommand", {"nil", "string", "table"}, say_cmd )
	ULib.checkArg( 6, "ULib.cmds.addCommand", {"nil", "boolean"}, hide_say )
	ULib.checkArg( 7, "ULib.cmds.addCommand", {"nil", "boolean"}, no_space_in_say )
	ULib.checkArg( 8, "ULib.cmds.addCommand", {"nil", "boolean"}, unsafe )
	local words = ULib.explode( "%s", cmd )
	local currTable = routedCmds
	for _, word in ipairs( words ) do
		local lowerWord = word:lower()
		currTable[ lowerWord ] = currTable[ lowerWord ] or {}
		currTable = currTable[ lowerWord ]
		currTable.__word = word
	end
	currTable.__fn = fn
	currTable.__autocomplete = autocomplete
	currTable.__access_string = access_string
	currTable.__unsafe = unsafe
	local dummy, dummy, prefix = cmd:find( "^(%S+)" )
	concommand.Add( prefix, routedCommandCallback, autocompleteCallback )
	if SERVER and say_cmd then
		if type( say_cmd ) == "string" then say_cmd = { say_cmd } end
		for i=1, #say_cmd do
			local t = {}
			sayCmds[ say_cmd[ i ] ] = t
			t.__fn = fn
			t.__cmd = cmd
			ULib.addSayCommand( say_cmd[ i ], sayCommandCallback, cmd, hide_say, no_space_in_say )
			local translatedCommand =  say_cmd[ i ] .. (no_space_in_say and "" or " ")
			ULib.sayCmds[ translatedCommand:lower() ].__cmd = cmd
		end
	end
end
function cmds.addCommandClient( cmd, fn, autocomplete, unsafe )
	ULib.checkArg( 1, "ULib.cmds.addCommandClient", "string", cmd )
	ULib.checkArg( 2, "ULib.cmds.addCommandClient", {"nil", "function"}, fn )
	ULib.checkArg( 3, "ULib.cmds.addCommandClient", {"nil", "function"}, autocomplete )
	ULib.checkArg( 4, "ULib.cmds.addCommandClient", {"nil", "boolean"}, unsafe )
	local words = ULib.explode( "%s", cmd )
	local currTable = routedCmds
	for _, word in ipairs( words ) do
		local lowerWord = word:lower()
		currTable[ lowerWord ] = currTable[ lowerWord ] or {}
		currTable = currTable[ lowerWord ]
		currTable.__word = word
	end
	currTable.__fn = fn
	currTable.__autocomplete = autocomplete
	currTable.__client_only = true
	currTable.__unsafe = unsafe
	local dummy, dummy, prefix = cmd:find( "^(%S+)" )
	concommand.Add( prefix, routedCommandCallback, autocompleteCallback )
end