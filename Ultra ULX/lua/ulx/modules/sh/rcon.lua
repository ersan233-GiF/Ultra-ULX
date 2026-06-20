local CATEGORY_NAME = "远程控制"
function ulx.rcon( calling_ply, command )
	ULib.consoleCommand( command .. "\n" )
	ulx.fancyLogAdmin( calling_ply, true, "#A ran rcon command: #s", command )
end
local rcon = ulx.command( CATEGORY_NAME, "ulx rcon", ulx.rcon, "!rcon", true, false, true )
rcon:addParam{ type=ULib.cmds.StringArg, hint="服务器命令", ULib.cmds.takeRestOfLine }
rcon:defaultAccess( ULib.ACCESS_SUPERADMIN )
rcon:help( "在服务器控制台上执行命令." )
function ulx.luaRun( calling_ply, command )
	local return_results = false
	if command:sub( 1, 1 ) == "=" then
		command = "tmp_var" .. command
		return_results = true
	end
	RunString( command )
	if return_results then
		if type( tmp_var ) == "table" then
			ULib.console( calling_ply, "结果:" )
			local lines = ULib.explode( "\n", ulx.dumpTable( tmp_var ) )
			local chunk_size = 50
			for i=1, #lines, chunk_size do
				ULib.queueFunctionCall( function()
					for j=i, math.min( i+chunk_size-1, #lines ) do
						ULib.console( calling_ply, lines[ j ]:gsub( "%%", "%%%%" ) )
					end
				end )
			end
		else
			ULib.console( calling_ply, "Result: " .. tostring( tmp_var ):gsub( "%%", "%%%%" ) )
		end
	end
	ulx.fancyLogAdmin( calling_ply, true, "#A ran lua: #s", command )
end
local luarun = ulx.command( CATEGORY_NAME, "ulx luarun", ulx.luaRun, nil, false, false, true )
luarun:addParam{ type=ULib.cmds.StringArg, hint="Lua代码", ULib.cmds.takeRestOfLine }
luarun:defaultAccess( ULib.ACCESS_SUPERADMIN )
luarun:help( "在服务器控制台执行 Lua 代码。(使用 '=' 获取返回值)" )
function ulx.exec( calling_ply, config )
	if string.sub( config, -4 ) ~= ".cfg" then config = config .. ".cfg" end
	if not ULib.fileExists( "cfg/" .. config ) then
		ULib.tsayError( calling_ply, "该配置文件不存在！", true )
		return
	end
	ULib.execFile( "cfg/" .. config )
	ulx.fancyLogAdmin( calling_ply, "#A executed file #s", config )
end
local exec = ulx.command( CATEGORY_NAME, "ulx exec", ulx.exec, nil, false, false, true )
exec:addParam{ type=ULib.cmds.StringArg, hint="文件名" }
exec:defaultAccess( ULib.ACCESS_SUPERADMIN )
exec:help( "从服务器 cfg 目录执行一个文件." )
function ulx.cexec( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
		v:ConCommand( command )
	end
	ulx.fancyLogAdmin( calling_ply, "#A ran #s on #T", command, target_plys )
end
local cexec = ulx.command( CATEGORY_NAME, "ulx cexec", ulx.cexec, "!cexec", false, false, true )
cexec:addParam{ type=ULib.cmds.PlayersArg }
cexec:addParam{ type=ULib.cmds.StringArg, hint="命令", ULib.cmds.takeRestOfLine }
cexec:defaultAccess( ULib.ACCESS_SUPERADMIN )
cexec:help( "在目标客户端的控制台上执行命令." )
function ulx.ent( calling_ply, classname, params )
	if not calling_ply:IsValid() then
		Msg( "无法从专用服务器控制台生成实体。\n" )
		return
	end
	classname = classname:lower()
	local newEnt = ents.Create( classname )
	if not newEnt or not newEnt:IsValid() then
		ULib.tsayError( calling_ply, "未知实体类型 (" .. classname .. ")，操作中止。", true )
		return
	end
	local trace = calling_ply:GetEyeTrace()
	local vector = trace.HitPos
	vector.z = vector.z + 20
	newEnt:SetPos( vector )
	params:gsub( "([^|:\"]+)\"?:\"?([^|]+)", function( key, value )
		key = key:Trim()
		value = value:Trim()
		newEnt:SetKeyValue( key, value )
	end )
	newEnt:Spawn()
	newEnt:Activate()
	undo.Create( "ulx_ent" )
		undo.AddEntity( newEnt )
		undo.SetPlayer( calling_ply )
	undo.Finish()
	if not params or params == "" then
		ulx.fancyLogAdmin( calling_ply, "#A created ent #s", classname )
	else
		ulx.fancyLogAdmin( calling_ply, "#A created ent #s with params #s", classname, params )
	end
end
local ent = ulx.command( CATEGORY_NAME, "ulx ent", ulx.ent, nil, false, false, true )
ent:addParam{ type=ULib.cmds.StringArg, hint="实体类名" }
ent:addParam{ type=ULib.cmds.StringArg, hint="<flag> : <value> |", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
ent:defaultAccess( ULib.ACCESS_SUPERADMIN )
ent:help( "生成实体，用 ':' 分隔键值，用 '|' 分隔多组键值对." )
