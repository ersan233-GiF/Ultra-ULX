local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_rcon"
function ulx.rcon( calling_ply, command )
	ULib.consoleCommand( command .. "\n" )
	ulx.fancyLogKeyedSilent( calling_ply, "rcon_rcon_log", nil, command )
end
local rcon = ulx.command( CATEGORY_NAME, "ulx rcon", ulx.rcon, "!rcon", true, false, true )
rcon:addParam{ type=ULib.cmds.StringArg, hint="server_cmd", ULib.cmds.takeRestOfLine }
rcon:defaultAccess( ULib.ACCESS_SUPERADMIN )
rcon:help( L.T("help_rcon") )
function ulx.luaRun( calling_ply, command )
	local return_results = false
	if command:sub( 1, 1 ) == "=" then
		command = "ulx.luaRunResult" .. command
		return_results = true
	end
	RunString( command )
	if return_results then
		local result = ulx.luaRunResult
		ulx.luaRunResult = nil
		if type( result ) == "table" then
			ULib.console( calling_ply, "结果:" )
			local lines = ULib.explode( "\n", ulx.dumpTable( result ) )
			local chunk_size = 50
			for i=1, #lines, chunk_size do
				ULib.queueFunctionCall( function()
					for j=i, math.min( i+chunk_size-1, #lines ) do
						ULib.console( calling_ply, lines[ j ]:gsub( "%%", "%%%%" ) )
					end
				end )
			end
		else
			ULib.console( calling_ply, "结果: " .. tostring( result ):gsub( "%%", "%%%%" ) )
		end
	end
		ulx.fancyLogKeyedSilent( calling_ply, "rcon_lua_log", nil, command )
end
local luarun = ulx.command( CATEGORY_NAME, "ulx luarun", ulx.luaRun, nil, false, false, true )
luarun:addParam{ type=ULib.cmds.StringArg, hint="lua_code", ULib.cmds.takeRestOfLine }
luarun:defaultAccess( ULib.ACCESS_SUPERADMIN )
luarun:help( L.T("help_luarun") )
function ulx.exec( calling_ply, config )
	if string.sub( config, -4 ) ~= ".cfg" then config = config .. ".cfg" end
	if not ULib.fileExists( "cfg/" .. config ) then
		ULib.tsayError( calling_ply, L.T("rcon_no_file"), true )
		return
	end
	ULib.execFile( "cfg/" .. config )
	ulx.fancyLogKeyed( calling_ply, "rcon_exec_log", nil, config )
end
local exec = ulx.command( CATEGORY_NAME, "ulx exec", ulx.exec, nil, false, false, true )
exec:addParam{ type=ULib.cmds.StringArg, hint="filename" }
exec:defaultAccess( ULib.ACCESS_SUPERADMIN )
exec:help( L.T("help_exec") )
function ulx.cexec( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
		v:ConCommand( command )
	end
	ulx.fancyLogKeyed(calling_ply, "rcon_cexec_log", target_plys, command )
end
local cexec = ulx.command( CATEGORY_NAME, "ulx cexec", ulx.cexec, "!cexec", false, false, true )
cexec:addParam{ type=ULib.cmds.PlayersArg }
cexec:addParam{ type=ULib.cmds.StringArg, hint="cmd", ULib.cmds.takeRestOfLine }
cexec:defaultAccess( ULib.ACCESS_SUPERADMIN )
cexec:help( L.T("help_cexec") )
function ulx.ent( calling_ply, classname, params )
	if not calling_ply:IsValid() then
		Msg( "无法从专用服务器控制台生成实体。\n" )
		return
	end
	classname = classname:lower()
	local newEnt = ents.Create( classname )
	if not newEnt or not newEnt:IsValid() then
		ULib.tsayError( calling_ply, string.format(L.T("rcon_unknown_ent"), classname), true )
		return
	end
	local trace = calling_ply:GetEyeTrace()
	local vector = trace.HitPos
	vector.z = vector.z + 20
	newEnt:SetPos( vector )
	if params and params ~= "" then
		params:gsub( "([^|:\"]+)\"?:\"?([^|]+)", function( key, value )
			key = key:Trim()
			value = value:Trim()
			newEnt:SetKeyValue( key, value )
		end )
	end
	newEnt:Spawn()
	newEnt:Activate()
	undo.Create( "ulx_ent" )
		undo.AddEntity( newEnt )
		undo.SetPlayer( calling_ply )
	undo.Finish()
	if not params or params == "" then
		ulx.fancyLogKeyed(calling_ply, "rcon_ent_log", classname )
	else
		ulx.fancyLogKeyed(calling_ply, "rcon_ent_param_log", classname, params )
	end
end
local ent = ulx.command( CATEGORY_NAME, "ulx ent", ulx.ent, nil, false, false, true )
ent:addParam{ type=ULib.cmds.StringArg, hint="ent_class" }
ent:addParam{ type=ULib.cmds.StringArg, hint="ent_kv", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
ent:defaultAccess( ULib.ACCESS_SUPERADMIN )
ent:help( L.T("help_ent") )