local logEcho                   = ulx.convar( "logEcho", "2", "回显模式: 0=关闭 1=匿名 2=完整", ULib.ACCESS_SUPERADMIN )
local logEchoColors             = ulx.convar( "logEchoColors", "1", "聊天中的回显命令是否着色", ULib.ACCESS_SUPERADMIN )
local logEchoColorDefault       = ulx.convar( "logEchoColorDefault", "151 211 255", "默认文字颜色 (RGB)", ULib.ACCESS_SUPERADMIN )
local logEchoColorConsole       = ulx.convar( "logEchoColorConsole", "0 0 0", "控制台操作的颜色", ULib.ACCESS_SUPERADMIN )
local logEchoColorSelf          = ulx.convar( "logEchoColorSelf", "75 0 130", "回显中自己的颜色", ULib.ACCESS_SUPERADMIN )
local logEchoColorEveryone      = ulx.convar( "logEchoColorEveryone", "0 128 128", "目标为全体时的颜色", ULib.ACCESS_SUPERADMIN )
local logEchoColorPlayerAsGroup = ulx.convar( "logEchoColorPlayerAsGroup", "1", "是否对玩家使用其用户组颜色", ULib.ACCESS_SUPERADMIN )
local logEchoColorPlayer        = ulx.convar( "logEchoColorPlayer", "255 255 0", "ulx logEchoColorPlayerAsGroup 设为 0 时的玩家颜色", ULib.ACCESS_SUPERADMIN )
local logEchoColorMisc          = ulx.convar( "logEchoColorMisc", "0 255 0", "回显中其他内容的颜色", ULib.ACCESS_SUPERADMIN )
local logFile                   = ulx.convar( "logFile", "1", "是否写入日志文件 (关闭后仍可回显)。全局设置。", ULib.ACCESS_SUPERADMIN )
local logEvents                 = ulx.convar( "logEvents", "1", "记录事件 (玩家连接、断开、死亡)", ULib.ACCESS_SUPERADMIN )
local logChat                   = ulx.convar( "logChat", "1", "记录玩家聊天", ULib.ACCESS_SUPERADMIN )
local logSpawns                 = ulx.convar( "logSpawns", "1", "记录玩家生成实体 (道具、特效等)", ULib.ACCESS_SUPERADMIN )
local logSpawnsEcho             = ulx.convar( "logSpawnsEcho", "1", "服务器生成回显级别: -1=关闭 0=仅控制台 1=仅管理员 2=全体", ULib.ACCESS_SUPERADMIN )
local logJoinLeaveEcho          = ulx.convar( "logJoinLeaveEcho", "1", "向管理员回显玩家进出 (便于封禁捣乱者)", ULib.ACCESS_SUPERADMIN )
local logDir                    = ulx.convar( "logDir", "ultra_ulx_logs", "日志目录 (相对于 garrysmod/data)", ULib.ACCESS_SUPERADMIN )
local hiddenechoAccess = "ulx hiddenecho"
ULib.ucl.registerAccess( hiddenechoAccess, ULib.ACCESS_SUPERADMIN, "查看隐藏回显的权限", "Other" )
local seeanonymousechoAccess = "ulx seeanonymousechoes"
ULib.ucl.registerAccess( seeanonymousechoAccess, ULib.ACCESS_ADMIN, "即使 ulx logEcho 设为 1 也能看到命令执行者", "Other" )
local spawnechoAccess = "ulx spawnecho"
ULib.ucl.registerAccess( spawnechoAccess, ULib.ACCESS_ADMIN, "在控制台查看生成回显和加入玩家的 SteamID", "Other" )
local os = os
local string = string
local curDateStr = os.date( "%Y-%m-%d" )
ulx.log_file = ulx.log_file or nil
local function init()
	curDateStr = os.date( "%Y-%m-%d" )
	if logFile:GetBool() then
		ULib.fileCreateDir( "data/" .. logDir:GetString() )
		ulx.log_file = os.date( "data/" .. logDir:GetString() .. "/" .. "%m-%d-%y" .. ".txt" )
		if not ULib.fileExists( ulx.log_file ) then
			ULib.fileWrite( ulx.log_file, "" )
		else
			ulx.logWriteln( "\r\n\r\n" )
		end
		ulx.logString( "新地图: " .. game.GetMap() )
	end
end
hook.Add( ulx.HOOK_ULXDONELOADING, "InitULX", init )
local function next_log()
	if logFile:GetBool() then
		local new_log = os.date( "data/" .. logDir:GetString() .. "/" .. "%m-%d-%y" .. ".txt" )
		if new_log == ulx.log_file then
			return
		end
		local old_log = ulx.log_file
		ulx.logWriteln( "<日志继续于 \"" .. new_log .. "\">" )
		ulx.log_file = new_log
		ULib.fileWrite( ulx.log_file, "" )
		ulx.logWriteln( "<日志接续自 \"" .. old_log .. "\">" )
	end
	curDateStr = os.date( "%Y-%m-%d" )
end
function ulx.logUserAct( ply, target, action, hide_echo )
	local nick
	if ply:IsValid() then
		if not ply:IsConnected() or not target:IsConnected() then return end
		nick = ply:Nick()
	else
		nick = "(Console)"
	end
	action = action:gsub( "#T", target:Nick(), 1 )
	local level = logEcho:GetInt()
	if not hide_echo and level > 0 then
		if level == 1 then
			local echo = action:gsub( "#A", "(管理员)", 1 )
			ULib.tsay( _, echo, true )
			local echoFull = action:gsub( "#A", nick, 1 )
			local players = player.GetAll()
			for _, player in ipairs( players ) do
				if ULib.ucl.query( player, seeanonymousechoAccess ) then
					ULib.tsay( player, echoFull, true )
				end
			end
		else
			local echo = action:gsub( "#A", nick, 1 )
			ULib.tsay( _, echo, true )
		end
	elseif level > 0 then
		local echo = action:gsub( "#A", "(SILENT)" .. nick, 1 )
		ULib.tsay( ply, echo, true )
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			if ULib.ucl.query( player, hiddenechoAccess ) and player ~= ply then
				ULib.tsay( player, echo, true )
			end
		end
	end
	if game.IsDedicated() then
		Msg( action:gsub( "#A", nick, 1 ) .. "\n" )
	end
	if logFile:GetBool() then
		ulx.logString( action:gsub( "#A", nick, 1 ), true )
	end
end
function ulx.logServAct( ply, action, hide_echo )
	local nick
	if ply:IsValid() then
		if not ply:IsConnected() then return end
		nick = ply:Nick()
	else
		nick = "(Console)"
	end
	local level = logEcho:GetInt()
	if not hide_echo and level > 0 then
		if level == 1 then
			local echo = action:gsub( "#A", "(管理员)", 1 )
			ULib.tsay( _, echo, true )
			local echoFull = action:gsub( "#A", nick, 1 )
			local players = player.GetAll()
			for _, player in ipairs( players ) do
				if ULib.ucl.query( player, seeanonymousechoAccess ) then
					ULib.tsay( player, echoFull, true )
				end
			end
		else
			local echo = action:gsub( "#A", nick, 1 )
			ULib.tsay( _, echo, true )
		end
	elseif level > 0 then
		local echo = action:gsub( "#A", "(SILENT)" .. nick, 1 )
		ULib.tsay( ply, echo, true )
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			if ULib.ucl.query( player, hiddenechoAccess ) and player ~= ply then
				ULib.tsay( player, echo, true )
			end
		end
	end
	if game.IsDedicated() then
		Msg( action:gsub( "#A", nick, 1 ) .. "\n" )
	end
	if logFile:GetBool() then
		ulx.logString( action:gsub( "#A", nick, 1 ), true )
	end
end
local function dateToNum(dateStr)
	local y, m, d = dateStr:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
	if not y then return 0 end
	return tonumber(y) * 10000 + tonumber(m) * 100 + tonumber(d)
end
function ulx.logString( str, log_to_main )
	if not ulx.log_file then return end
	local dateStr = os.date( "%Y-%m-%d" )
	if dateToNum(curDateStr) < dateToNum(dateStr) then
		next_log()
	end
	if log_to_main then
		ServerLog( "[ULX] " .. str .. "\n" )
	end
	local date = os.date( "*t" )
	ulx.logWriteln( string.format( "[%02i:%02i:%02i] ", date.hour, date.min, date.sec ) .. str )
end
function ulx.logWriteln( str )
	if not ulx.log_file then return end
	if logFile:GetBool() and ulx.log_file then
		ULib.fileAppend( ulx.log_file, str .. "\r\n" )
	end
end
local function echoToAdmins( txt )
	local players = player.GetAll()
	for _, ply in ipairs( players ) do
		if ULib.ucl.authed[ ply:UniqueID() ] and ULib.ucl.query( ply, spawnechoAccess ) then
			ULib.console( ply, txt )
		end
	end
end
local function playerSay( ply, text, private )
	if logChat:GetBool() then
		if private then
			ulx.logString( string.format( "(TEAM) %s: %s", ply:Nick(), text ) )
		else
			ulx.logString( string.format( "%s: %s", ply:Nick(), text ) )
		end
	end
end
hook.Add( "PlayerSay", "ULXLogSay", playerSay, HOOK_MONITOR_LOW )
local joinTimer = {}
local mapStartTime = os.time()
local function playerConnect( name, address )
	joinTimer[address] = os.time()
	if logEvents:GetBool() then
		ulx.logString( string.format( "客户端 \"%s\" 已连接.", name ) )
	end
end
hook.Add( "PlayerConnect", "ULXLogConnect", playerConnect, HOOK_MONITOR_HIGH )
local function playerInitialSpawn( ply )
	local ip = ply:IPAddress()
	local seconds = os.time() - (joinTimer[ip] or mapStartTime)
	joinTimer[ip] = nil
	local txt = string.format( "客户端 \"%s\" 已在服务器生成 <%s> (用时 %i 秒).", ply:Nick(), ply:SteamID(), seconds )
	if logEvents:GetBool() then
		ulx.logString( txt )
	end
	if logJoinLeaveEcho:GetBool() then
		echoToAdmins( txt )
	end
end
hook.Add( "PlayerInitialSpawn", "ULXLogInitialSpawn", playerInitialSpawn, HOOK_MONITOR_HIGH )
local function playerDisconnect( ply )
	local ip = ply:IPAddress()
	joinTimer[ip] = nil
	local txt = string.format( "Dropped \"%s\" from server<%s>", ply:Nick(), ply:SteamID() )
	if logEvents:GetBool() then
		ulx.logString( txt )
	end
	if logJoinLeaveEcho:GetBool() then
		echoToAdmins( txt )
	end
end
hook.Add( "PlayerDisconnected", "ULXLogDisconnect", playerDisconnect, HOOK_MONITOR_HIGH )
local function playerDeath( victim, weapon, killer )
	if logEvents:GetBool() then
		if not IsValid( victim ) then return end
		if not IsValid( killer ) then return end
		if not killer:IsPlayer() then
			ulx.logString( string.format( "%s was killed by %s", victim:Nick(), killer:GetClass() ) )
		elseif weapon == nil or not weapon:IsValid() then
			ulx.logString( string.format( "%s killed %s", killer:Nick(), victim:Nick() ) )
		elseif victim ~= killer then
			ulx.logString( string.format( "%s killed %s using %s", killer:Nick(), victim:Nick(), weapon:GetClass() ) )
		else
			ulx.logString( string.format( "%s suicided!", victim:Nick() ) )
		end
	end
end
hook.Add( "PlayerDeath", "ULXLogDeath", playerDeath, HOOK_MONITOR_HIGH )
local function nameCheck( ply, oldnick, newnick )
	local msg = string.format( "%s<%s> changed their name to %s", oldnick, ply:SteamID(), newnick )
	if game.IsDedicated() then
		Msg( msg .. "\n" )
	end
	if logEvents:GetBool() then
		ulx.logString( msg )
	end
end
hook.Add( "ULibPlayerNameChanged", "ULXNameChange", nameCheck )
local function shutDown()
	if logEvents:GetBool() then
		ulx.logString( "Server is shutting down/changing levels." )
	end
end
hook.Add( "ShutDown", "ULXLogShutDown", shutDown, HOOK_MONITOR_HIGH )
function ulx.logSpawn( txt )
	if logSpawns:GetBool() then
		ulx.logString( txt, true )
	end
	if logSpawnsEcho:GetInt() >= 0 and game.IsDedicated() then
		Msg( txt .. "\n" )
	end
	if logSpawnsEcho:GetInt() == 1 then
		echoToAdmins( txt )
	elseif logSpawnsEcho:GetInt() == 2 then
		ULib.console( _, txt )
	end
end
local function propSpawn( ply, model, ent )
	ulx.logSpawn( string.format( "%s<%s> spawned model %s", ply:Nick(), ply:SteamID(), ulx.standardizeModel( model ) ) )
end
hook.Add( "PlayerSpawnedProp", "ULXLogPropSpawn", propSpawn, HOOK_MONITOR_LOW )
local function ragdollSpawn( ply, model, ent )
	ulx.logSpawn( string.format( "%s<%s> spawned ragdoll %s", ply:Nick(), ply:SteamID(), ulx.standardizeModel( model ) ) )
end
hook.Add( "PlayerSpawnedRagdoll", "ULXLogRagdollSpawn", ragdollSpawn, HOOK_MONITOR_LOW )
local function effectSpawn( ply, model, ent )
	ulx.logSpawn( string.format( "%s<%s> spawned effect %s", ply:Nick(), ply:SteamID(), ulx.standardizeModel( model ) ) )
end
hook.Add( "PlayerSpawnedEffect", "ULXLogEffectSpawn", effectSpawn, HOOK_MONITOR_LOW )
local function vehicleSpawn( ply, ent )
	ulx.logSpawn( string.format( "%s<%s> spawned vehicle %s", ply:Nick(), ply:SteamID(), ulx.standardizeModel( ent:GetModel() or "unknown" ) ) )
end
hook.Add( "PlayerSpawnedVehicle", "ULXLogVehicleSpawn", vehicleSpawn, HOOK_MONITOR_LOW )
local function sentSpawn( ply, ent )
	ulx.logSpawn( string.format( "%s<%s> spawned sent %s", ply:Nick(), ply:SteamID(), ent:GetClass() ) )
end
hook.Add( "PlayerSpawnedSENT", "ULXLogSentSpawn", sentSpawn, HOOK_MONITOR_LOW )
local function NPCSpawn( ply, ent )
	ulx.logSpawn( string.format( "%s<%s> spawned NPC %s", ply:Nick(), ply:SteamID(), ent:GetClass() ) )
end
hook.Add( "PlayerSpawnedNPC", "ULXLogNPCSpawn", NPCSpawn, HOOK_MONITOR_LOW )
local default_color
local console_color
local self_color
local misc_color
local everyone_color
local player_color
local function updateColors()
	local cvars = { logEchoColorDefault, logEchoColorConsole, logEchoColorSelf, logEchoColorEveryone, logEchoColorPlayer, logEchoColorMisc }
	for i=1, #cvars do
		local cvar = cvars[ i ]
		local pieces = ULib.explode( "%s+", cvar:GetString() )
		if #pieces ~= 3 then Msg( "[ULX] 警告: 尝试设置日志颜色cvar时遇到无效数据\n" ) return end
		local color = Color( tonumber( pieces[ 1 ] ), tonumber( pieces[ 2 ] ), tonumber( pieces[ 3 ] ) )
		if cvar == logEchoColorDefault then default_color = color
		elseif cvar == logEchoColorConsole then console_color = color
		elseif cvar == logEchoColorSelf then self_color = color
		elseif cvar == logEchoColorEveryone then everyone_color = color
		elseif cvar == logEchoColorPlayer then player_color = color
		elseif cvar == logEchoColorMisc then misc_color = color
		end
	end
end
hook.Add( ulx.HOOK_ULXDONELOADING, "UpdateEchoColors", updateColors )
updateColors()
local function cvarChanged( sv_cvar, cl_cvar, ply, old_value, new_value )
	sv_cvar = sv_cvar:lower()
	if not sv_cvar:find( "^ulx_logechocolor" ) then return end
	if sv_cvar ~= "ulx_logechocolorplayerasgroup" then timer.Simple( 0.1, updateColors ) end
end
hook.Add( ULib.HOOK_REPCVARCHANGED, "ULXCheckLogColorCvar", cvarChanged )
local function plyColor( target_ply, showing_ply )
	if not target_ply:IsValid() then
		return console_color
	elseif showing_ply == target_ply then
		return self_color
	elseif logEchoColorPlayerAsGroup:GetBool() then
		return team.GetColor( target_ply:Team() )
	else
		return player_color
	end
end
local function makePlayerList( calling_ply, target_list, showing_ply, use_self_suffix, is_admin_part )
	local players = player.GetAll()
	local anonymous = showing_ply ~= "CONSOLE" and not ULib.ucl.query( showing_ply, seeanonymousechoAccess ) and logEcho:GetInt() == 1
	if #players > 1 and #target_list == #players then
		return { everyone_color, "Everyone" }
	elseif is_admin_part then
		local target = target_list[ 1 ]
		if anonymous and target ~= showing_ply then
			return { everyone_color, "(Someone)" }
		elseif not target:IsValid() then
			return { console_color, "(Console)" }
		end
	end
	local strs = {}
	table.sort( target_list, function( ply_a, ply_b )
		if ply_a == showing_ply then return true end
		if ply_b == showing_ply then return false end
		if ply_a == calling_ply then return true end
		if ply_b == calling_ply then return false end
		return ply_a:Nick() < ply_b:Nick()
	end )
	for i=1, #target_list do
		local target = target_list[ i ]
		table.insert( strs, plyColor( target, showing_ply ) )
		if target == showing_ply then
			if not use_self_suffix or calling_ply ~= showing_ply then
				table.insert( strs, "You" )
			else
				table.insert( strs, "Yourself" )
			end
		elseif not use_self_suffix or calling_ply ~= target_list[ i ] or anonymous then
			table.insert( strs, target_list[ i ]:IsValid() and target_list[ i ]:Nick() or "(Console)" )
		else
			table.insert( strs, "Themself" )
		end
		table.insert( strs, default_color )
		table.insert( strs, "," )
	end
	table.remove( strs )
	table.remove( strs )
	return strs
end
local function insertToAll( t, data )
	for i=1, #t do
		table.insert( t[ i ], data )
	end
end
function ulx.fancyLogAdmin( calling_ply, format, ... )
	local use_self_suffix = false
	local hide_echo = false
	local players = {}
	if logEcho:GetInt() ~= 0 then
		players = player.GetAll()
	end
	local arg_pos = 1
	local args = { ... }
	if type( format ) == "boolean" then
		hide_echo = format
		format = args[ 1 ]
	 	arg_pos = arg_pos + 1
	end
	if type( format ) == "table" then
		players = format
		format = args[ 1 ]
		arg_pos = arg_pos + 1
	end
	if hide_echo then
		for i=#players, 1, -1 do
			if not ULib.ucl.query( players[ i ], hiddenechoAccess ) and players[ i ] ~= calling_ply then
				table.remove( players, i )
			end
		end
	end
	table.insert( players, "CONSOLE" )
	local playerStrs = {}
	for i=1, #players do
		playerStrs[ i ] = {}
	end
	if hide_echo then
		insertToAll( playerStrs, default_color )
		insertToAll( playerStrs, "(SILENT) " )
	end
	local no_targets = false
	format:gsub( "([^#]*)#([%.%d]*[%a])([^#]*)", function( prefix, tag, postfix )
		local arg = args[ arg_pos ]
		arg_pos = arg_pos + 1
		if prefix and prefix ~= "" then
			insertToAll( playerStrs, default_color )
			insertToAll( playerStrs, prefix )
		end
		local specifier = tag:sub( -1, -1 )
		local color, str
		local isAdminArg = specifier == "A" and calling_ply
		if not (arg or isAdminArg) then
			insertToAll( playerStrs, "#" .. tag )
		elseif specifier == "T" or specifier == "P" or isAdminArg then
			if isAdminArg then
				arg_pos = arg_pos - 1
				arg = { calling_ply }
			elseif type( arg ) ~= "table" then
				arg = { arg }
			end
			if #arg == 0 then no_targets = true end
			for i=1, #players do
				table.Add( playerStrs[ i ], makePlayerList( calling_ply, arg, players[ i ], use_self_suffix, specifier == "A" ) )
			end
			use_self_suffix = true
		else
			insertToAll( playerStrs, misc_color )
			local format_tag = tag
			if specifier == "i" or specifier == "d" then
				format_tag = tag:sub(1, -2) .. "g"
			end
			insertToAll( playerStrs, string.format( "%" .. format_tag, arg ) )
		end
		if postfix and postfix ~= "" then
			insertToAll( playerStrs, default_color )
			insertToAll( playerStrs, postfix )
		end
	end )
	if no_targets then
		return
	end
	for i=1, #players do
		if not logEchoColors:GetBool() or players[ i ] == "CONSOLE" then
			for j=#playerStrs[ i ], 1, -1 do
				if type( playerStrs[ i ][ j ] ) == "table" then
					table.remove( playerStrs[ i ], j )
				end
			end
		end
		if players[ i ] ~= "CONSOLE" then
			ULib.tsayColor( players[ i ], true, unpack( playerStrs[ i ] ) )
		else
			local msg = table.concat( playerStrs[ i ] )
			if game.IsDedicated() then
				Msg( msg .. "\n" )
			end
			if logFile:GetBool() then
				ulx.logString( msg, true )
			end
		end
	end
end
function ulx.fancyLog( format, ... )
	ulx.fancyLogAdmin( _, format, ... )
end
function ulx.keyedLog(key, ...)
	local L = ULib.ulx_lang
	if logFile:GetBool() then
		local msg = L.T(key, ...)
		ulx.logString(msg, true)
	end
	if game.IsDedicated() then
		local msg = L.T(key, ...)
		Msg("[ULX] " .. msg .. "\n")
	end
	L.keyedBroadcast(key, ...)
end
function ulx.fancyLogKeyed(calling_ply, key, targets, ...)
	ulx._fancyLogKeyedInternal(calling_ply, false, key, targets, ...)
end
function ulx.fancyLogKeyedSilent(calling_ply, key, targets, ...)
	ulx._fancyLogKeyedInternal(calling_ply, true, key, targets, ...)
end
local function getTargetStr(t)
	if not t then return "" end
	local names = {}
	if type(t) == "table" then
		for _, p in ipairs(t) do if IsValid(p) then table.insert(names, p:Nick()) end end
	elseif IsValid(t) then table.insert(names, t:Nick()) end
	return table.concat(names, ", ")
end
function ulx._fancyLogKeyedInternal(calling_ply, hide_echo, key, targets, ...)
	local L = ULib.ulx_lang
	local extra = { ... }
	local recipients = {}
	if logEcho:GetInt() == 0 then
		recipients = {}
	elseif hide_echo then
		for _, p in ipairs(player.GetAll()) do
			if p == calling_ply or ULib.ucl.query(p, hiddenechoAccess) then
				table.insert(recipients, p)
			end
		end
	else
		recipients = player.GetAll()
	end
	local template = L.T(key)
	local admin_name = IsValid(calling_ply) and calling_ply:Nick() or "Console"
	local target_str = getTargetStr(targets)
	local spec_list = {}
	local ei = 1
	for spec in template:gmatch("#([%.%d]*[%a])") do
		local st = spec:sub(-1, -1)
		if st == "A" then
			table.insert(spec_list, {type="A", value=admin_name})
		elseif st == "T" or st == "P" then
			table.insert(spec_list, {type="T", value=target_str})
		else
			local val = ei <= #extra and tostring(extra[ei]) or ""
			ei = ei + 1
			table.insert(spec_list, {type="V", value=val})
		end
	end
	if not ULib.RELEASE and #extra ~= (ei - 1) then
		local spec_count = 0
		for _, s in ipairs(spec_list) do
			if s.type == "V" then spec_count = spec_count + 1 end
		end
		if #extra ~= spec_count then
			ErrorNoHalt(string.format("[ULX] fancyLogKeyed arg mismatch: key=%s templateValues=%d passedArgs=%d\n",
				key, spec_count, #extra))
		end
	end
	local ei2 = 1
	local log_msg = template:gsub("#[%.%d]*[aAdDiIgGtTsSpP]", function(spec)
		local st = spec:sub(-1, -1)
		if st == "A" then return admin_name
		elseif st == "T" or st == "P" then return target_str
		elseif ei2 <= #extra then ei2 = ei2 + 1; return tostring(extra[ei2 - 1])
		else return spec end
	end)
	if hide_echo then log_msg = "(SILENT) " .. log_msg end
	if logFile:GetBool() then ulx.logString("[ULX] " .. log_msg, true) end
	if game.IsDedicated() then Msg("[ULX] " .. log_msg .. "\n") end
	if #recipients > 0 then
		local client_args = {}
		for _, s in ipairs(spec_list) do
			table.insert(client_args, s.value)
		end
		L.keyedBroadcastFiltered(key, recipients, unpack(client_args))
	end
end