ULib.sayCmds = ULib.sayCmds or {}
local function sayCmdCheck( ply, strText, bTeam )
	local match
	for str, data in pairs( ULib.sayCmds ) do
		local str2 = str
		if strText:len() < str:len() then
			str2 = string.Trim( str )
		end
		if strText:sub( 1, str2:len() ):lower() == str2 then
			if not match or match:len() <= str:len() then
				match = str
			end
		end
	end
	if match then
		local data = ULib.sayCmds[ match ]
		local args = string.Trim( strText:sub( match:len() + 1 ) )
		local argv = ULib.splitArgs( args )
		if data.__cmd then
			local return_value = hook.Call( ULib.HOOK_COMMAND_CALLED, _, ply, data.__cmd, argv )
			if return_value == false then
				if data.hide then
					return ""
				else
					return nil
				end
			end
		end
		if not ULib.ucl.query( ply, data.access ) then
			ULib.tsay( ply, "You do not have access to this command, " .. ply:Nick() .. "." )
			return ""
		end
		local fn = data.fn
		local hide = data.hide
		ULib.pcallError( fn, ply, match:Trim(), argv, args )
		if hide then return "" end
	end
	return nil
end
hook.Add( "PlayerSay", "ULib_saycmd", sayCmdCheck, HOOK_HIGH )
function ULib.addSayCommand( say_cmd, fn_call, access, hide_say, nospace )
	say_cmd = string.Trim( say_cmd:lower() )
	if not nospace then
		say_cmd = say_cmd .. " "
	end
	ULib.sayCmds[ say_cmd ] = { fn=fn_call, hide=hide_say, access=access }
end
function ULib.removeSayCommand( say_cmd )
	ULib.sayCmds[ say_cmd ] = nil
	ULib.sayCmds[ say_cmd .. " " ] = nil
end