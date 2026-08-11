local ulxBuildNumURL = ulx.release and "https://teamulysses.github.io/ulx/ulx.build" or "https://raw.githubusercontent.com/TeamUlysses/ulx/master/ulx.build"
ULib.registerPlugin{
	Name          = "ULX",
	Version       = string.format( "%.2f", ulx.version ),
	IsRelease     = ulx.release,
	Author        = "Team Ulysses",
	URL           = "https://ulyssesmod.net",
	WorkshopID    = 557962280,
	BuildNumLocal         = tonumber(ULib.fileRead( "ulx.build" )),
	BuildNumRemoteURL      = ulxBuildNumURL,
}
function ulx.getVersion()
	return ULib.pluginVersionStr( "ULX" )
end
local ulxCommand = inheritsFrom( ULib.cmds.TranslateCommand )
function ulxCommand:logString( str )
	Msg( "Warning: <ulx command>:logString() was called, this function is being phased out!\n" )
end
function ulxCommand:oppositeLogString( str )
	Msg( "Warning: <ulx command>:oppositeLogString() was called, this function is being phased out!\n" )
end
function ulxCommand:help( str )
	self.helpStr = str
end
function ulxCommand:getUsage( ply )
	local str = self:superClass().getUsage( self, ply )
	if self.helpStr or self.say_cmd or self.opposite then
		str = str:Trim() .. " - "
		if self.helpStr then
			str = str .. self.helpStr
		end
		if self.helpStr and self.say_cmd then
			str = str .. " "
		end
		if self.say_cmd then
			str = str .. "(say: " .. self.say_cmd[1] .. ")"
		end
		if self.opposite and (self.helpStr or self.say_cmd) then
			str = str .. " "
		end
		if self.opposite then
			str = str .. "(opposite: " .. self.opposite .. ")"
		end
	end
	return str
end
ulx.cmdsByCategory = ulx.cmdsByCategory or {}
function ulx.command( categoryKey, command, fn, say_cmd, hide_say, nospace, unsafe )
	if type( say_cmd ) == "string" then say_cmd = { say_cmd } end
	local obj = ulxCommand( command, fn, say_cmd, hide_say, nospace, unsafe )
	obj:addParam{ type=ULib.cmds.CallingPlayerArg }
	local catDisplay = ULib.ulx_lang.T(categoryKey)
	ulx.cmdsByCategory[ catDisplay ] = ulx.cmdsByCategory[ catDisplay ] or {}
	for cat, cmds in pairs( ulx.cmdsByCategory ) do
		for i=1, #cmds do
			if cmds[i].cmd == command then
				table.remove( ulx.cmdsByCategory[ cat ], i )
				break
			end
		end
	end
	table.insert( ulx.cmdsByCategory[ catDisplay ], obj )
	obj.category = catDisplay
	obj.categoryKey = categoryKey
	obj.say_cmd = say_cmd
	obj.hide_say = hide_say
	return obj
end
local function cc_ulx( ply, command, argv )
	local argn = #argv
	if argn == 0 then
		ULib.console( ply, ULib.ulx_lang.T("cmd_no_command") )
	else
		local cvar = ulx.cvars[ argv[ 1 ]:lower() ]
		if cvar and not argv[ 2 ] then
			ULib.console( ply, "\"ulx " .. argv[ 1 ] .. "\" = \"" .. GetConVarString( "ulx_" .. cvar.cvar ) .. "\"" )
			if cvar.help and cvar.help ~= "" then
				ULib.console( ply, cvar.help .. "\n" .. ULib.ulx_lang.T("cmd_ulx_cvar_desc") )
			else
				ULib.console( ply, ULib.ulx_lang.T("cmd_ulx_cvar") )
			end
			return
		elseif cvar then
			local args = table.concat( argv, " ", 2, argn )
			if ply:IsValid() then
				ply:ConCommand( "ulx_" .. cvar.cvar .. " \"" .. args:gsub( "(%%)", "%%%1" ) .. "\"" )
			else
				cvar.obj:SetString( argv[ 2 ] )
			end
			return
		end
		ULib.console( ply, ULib.ulx_lang.T("cmd_invalid") )
	end
end
ULib.cmds.addCommand( "ulx", cc_ulx )
function ulx.help( ply )
	ULib.console( ply, ULib.ulx_lang.T("cmd_help_header") )
	for catDisplay, cmds in pairs( ulx.cmdsByCategory ) do
		local lines = {}
		for _, cmd in ipairs( cmds ) do
			local tag = cmd.manual and cmd.access_tag or cmd.cmd
			if ULib.ucl.query( ply, tag ) then
				local usage = cmd.manual and cmd.helpStr or cmd:getUsage( ply )
				table.insert( lines, "  " .. cmd.cmd .. " " .. usage:Trim() )
			end
		end
		if #lines > 0 then
			table.sort( lines )
			local firstCmd = cmds[1]
			local catLabel = (firstCmd and firstCmd.categoryKey and ULib.ulx_lang.T(firstCmd.categoryKey)) or catDisplay
			ULib.console( ply, "\n" .. ULib.ulx_lang.T("cmd_category") .. catLabel )
			for _, line in ipairs( lines ) do
				ULib.console( ply, line )
			end
		end
	end
	local totalCmds = 0
	for _, cmds in pairs( ulx.cmdsByCategory ) do totalCmds = totalCmds + #cmds end
	ULib.console( ply, "\n" .. ULib.ulx_lang.T("cmd_help_end", totalCmds) .. "\n" )
end
local help = ulx.command( "cat_utility", "ulx help", ulx.help )
help:help( ULib.ulx_lang.T("help_help") )
help:defaultAccess( ULib.ACCESS_ALL )
function ulx.dumpTable( t, indent, done )
	done = done or {}
	indent = indent or 0
	local str = ""
	for k, v in pairs( t ) do
		str = str .. string.rep( "\t", indent )
		if type( v ) == "table" and not done[ v ] then
			done[ v ] = true
			str = str .. tostring( k ) .. ":" .. "\n"
			str = str .. ulx.dumpTable( v, indent + 1, done )
		else
			str = str .. tostring( k ) .. "\t=\t" .. tostring( v ) .. "\n"
		end
	end
	return str
end
function ulx.uteamEnabled()
	return ULib.isSandbox() and GAMEMODE.Name ~= "DarkRP"
end