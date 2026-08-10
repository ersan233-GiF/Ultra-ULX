local CATEGORY_NAME = "工具"
function ulx.who( calling_ply, steamid )
	if not steamid or steamid == "" then
		ULib.console( calling_ply, "ID Name                            Group" )
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			local id = tostring( player:UserID() )
			local nick = utf8.force( player:Nick() )
			local text = string.format( "%i%s %s%s ", id, string.rep( " ", 2 - id:len() ), nick, string.rep( " ", 31 - utf8.len( nick ) ) )
			text = text .. player:GetUserGroup()
			ULib.console( calling_ply, text )
		end
	else
		local data = ULib.ucl.getUserInfoFromID( steamid )
		if not data then
			ULib.console( calling_ply, "No information for provided id exists" )
		else
			ULib.console( calling_ply, "   ID: " .. steamid )
			ULib.console( calling_ply, " Name: " .. data.name )
			ULib.console( calling_ply, "Group: " .. data.group )
		end
	end
end
local who = ulx.command( CATEGORY_NAME, "ulx who", ulx.who )
who:addParam{ type=ULib.cmds.StringArg, hint="SteamID", ULib.cmds.optional }
who:defaultAccess( ULib.ACCESS_ALL )
who:help( "查看当前在线用户的信息." )
function ulx.versionCmd( calling_ply )
	ULib.tsay( calling_ply, "Ultra ULX " .. ( ulx.VERSION_STR or "v2.69.1" ), true )
	ULib.tsay( calling_ply, "ULX " .. ULib.pluginVersionStr("ULX") .. " (兼容层)", true )
	ULib.tsay( calling_ply, "ULib " .. ULib.pluginVersionStr("ULib"), true )
end
local version = ulx.command( CATEGORY_NAME, "ulx version", ulx.versionCmd, "!version" )
version:defaultAccess( ULib.ACCESS_ALL )
version:help( "查看版本信息." )
function ulx.map( calling_ply, map, gamemode )
	if not gamemode or gamemode == "" then
		ulx.fancyLogAdmin( calling_ply, "#A changed the map to #s", map )
	else
		ulx.fancyLogAdmin( calling_ply, "#A changed the map to #s with gamemode #s", map, gamemode )
	end
	if gamemode and gamemode ~= "" then
		game.ConsoleCommand( "gamemode " .. gamemode .. "\n" )
	end
	game.ConsoleCommand( "changelevel " .. map ..  "\n" )
end
local map = ulx.command( CATEGORY_NAME, "ulx map", ulx.map, "!map" )
map:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="地图", error="invalid map \"%s\" specified", ULib.cmds.restrictToCompletes }
map:addParam{ type=ULib.cmds.StringArg, completes=ulx.gamemodes, hint="游戏模式", error="invalid gamemode \"%s\" specified", ULib.cmds.restrictToCompletes, ULib.cmds.optional }
map:defaultAccess( ULib.ACCESS_SUPERADMIN )
map:help( "更换地图和游戏模式." )
function ulx.kick( calling_ply, target_ply, reason )
	if target_ply:IsListenServerHost() then
		ULib.tsayError( calling_ply, "该玩家免疫踢出", true )
		return
	end
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, "#A kicked #T (#s)", target_ply, reason )
	else
		reason = nil
		ulx.fancyLogAdmin( calling_ply, "#A kicked #T", target_ply )
	end
	ULib.queueFunctionCall( ULib.kick, target_ply, reason, calling_ply )
end
local kick = ulx.command( CATEGORY_NAME, "ulx kick", ulx.kick, "!kick" )
kick:addParam{ type=ULib.cmds.PlayerArg }
kick:addParam{ type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
kick:defaultAccess( ULib.ACCESS_ADMIN )
kick:help( "踢出目标." )
function ulx.ban( calling_ply, target_ply, minutes, reason )
	if target_ply:IsListenServerHost() or target_ply:IsBot() then
		ULib.tsayError( calling_ply, "该玩家免疫封禁", true )
		return
	end
	local time = "for #s"
	if minutes == 0 then time = "永久封禁" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
	ULib.queueFunctionCall( ULib.kickban, target_ply, minutes, reason, calling_ply )
end
local ban = ulx.command( CATEGORY_NAME, "ulx ban", ulx.ban, "!ban", false, false, true )
ban:addParam{ type=ULib.cmds.PlayerArg }
ban:addParam{ type=ULib.cmds.NumArg, hint="分钟, 0为永久", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
ban:addParam{ type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
ban:defaultAccess( ULib.ACCESS_ADMIN )
ban:help( "封禁目标." )
function ulx.banid( calling_ply, steamid, minutes, reason )
	steamid = steamid:upper()
	if not ULib.isValidSteamID( steamid ) then
		ULib.tsayError( calling_ply, "无效的 SteamID。" )
		return
	end
	local name, target_ply
	local plys = player.GetAll()
	for i=1, #plys do
		if plys[ i ]:SteamID() == steamid then
			target_ply = plys[ i ]
			name = target_ply:Nick()
			break
		end
	end
	if target_ply and (target_ply:IsListenServerHost() or target_ply:IsBot()) then
		ULib.tsayError( calling_ply, "该玩家免疫封禁", true )
		return
	end
	local time = "for #s"
	if minutes == 0 then time = "永久封禁" end
	local str = "#A banned steamid #s "
	local displayid = steamid
	if name then
		displayid = displayid .. "(" .. name .. ") "
	end
	str = str .. time
	if reason and reason ~= "" then str = str .. " (#4s)" end
	ulx.fancyLogAdmin( calling_ply, str, displayid, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )
	ULib.queueFunctionCall( ULib.addBan, steamid, minutes, reason, name, calling_ply )
end
local banid = ulx.command( CATEGORY_NAME, "ulx banid", ulx.banid, "!banid", false, false, true )
banid:addParam{ type=ULib.cmds.StringArg, hint="SteamID" }
banid:addParam{ type=ULib.cmds.NumArg, hint="分钟, 0为永久", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
banid:addParam{ type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
banid:defaultAccess( ULib.ACCESS_SUPERADMIN )
banid:help( "通过 SteamID 封禁玩家." )
function ulx.unban( calling_ply, steamid )
	steamid = steamid:upper()
	if not ULib.isValidSteamID( steamid ) then
		ULib.tsayError( calling_ply, "无效的 SteamID。" )
		return
	end
	local name = ULib.bans[ steamid ] and ULib.bans[ steamid ].name
	ULib.unban( steamid, calling_ply )
	if name then
		ulx.fancyLogAdmin( calling_ply, "#A unbanned steamid #s", steamid .. " (" .. name .. ")" )
	else
		ulx.fancyLogAdmin( calling_ply, "#A unbanned steamid #s", steamid )
	end
end
local unban = ulx.command( CATEGORY_NAME, "ulx unban", ulx.unban, "!unban", false, false, true )
unban:addParam{ type=ULib.cmds.StringArg, hint="SteamID" }
unban:defaultAccess( ULib.ACCESS_ADMIN )
unban:help( "解除 SteamID 的封禁." )
function ulx.noclip( calling_ply, target_plys )
	if not target_plys[ 1 ]:IsValid() then
		Msg( "You are god, you are not constrained by walls built by mere mortals.\n" )
		return
	end
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v.NoNoclip then
			ULib.tsayError( calling_ply, v:Nick() .. " 目前不能使用穿墙模式。", true )
		else
			if v:GetMoveType() == MOVETYPE_WALK then
				v:SetMoveType( MOVETYPE_NOCLIP )
				table.insert( affected_plys, v )
				v.Was_GodEnabled = v:HasGodMode()
				v:GodEnable()
				v:SetNoDraw( true )
				v:SetNoTarget( true )
				v:SetNoCollideWithTeammates( true )
				local steamid64 = v:SteamID64()
				timer.Create( "AdminObserver_" .. steamid64, 1, 0, function()
					if not IsValid( v ) then
						timer.Remove( "AdminObserver_" .. steamid64 )
						return
					end
					if v:GetMoveType() ~= MOVETYPE_NOCLIP then
						timer.Remove( "AdminObserver_" .. steamid64 )
						return
					end
				end )
			elseif v:GetMoveType() == MOVETYPE_NOCLIP then
				v:SetMoveType( MOVETYPE_WALK )
				table.insert( affected_plys, v )
				if not v.Was_GodEnabled then
					v:GodDisable()
				end
				v.Was_GodEnabled = nil
				v:SetNoDraw( false )
				v:SetNoCollideWithTeammates( false )
				v:SetNoTarget( false )
				local steamid64 = v:SteamID64()
				timer.Remove( "AdminObserver_" .. steamid64 )
			else
				ULib.tsayError( calling_ply, v:Nick() .. " 目前不能使用穿墙模式。", true )
			end
		end
	end
end
local noclip = ulx.command( CATEGORY_NAME, "ulx noclip", ulx.noclip, "!noclip" )
noclip:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional }
noclip:defaultAccess( ULib.ACCESS_ADMIN )
noclip:help( "切换目标的穿墙(noclip)模式。" )
function ulx.spectate( calling_ply, target_ply )
	if not calling_ply:IsValid() then
		Msg( "无法从专用服务器控制台进行观察。\n" )
		return
	end
	local hookTable = hook.GetTable()["KeyPress"]
	if hookTable and hookTable["ulx_unspectate_" .. calling_ply:EntIndex()] then
		hook.Call( "KeyPress", _, calling_ply, IN_FORWARD )
	end
	if ulx.getExclusive( calling_ply, calling_ply ) then
		ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
		return
	end
	ULib.getSpawnInfo( calling_ply )
	local pos = calling_ply:GetPos()
	local ang = calling_ply:GetAngles()
	local wasAlive = calling_ply:Alive()
	local function stopSpectate( player )
		if player ~= calling_ply then
			return
		end
		hook.Remove( "PlayerSpawn", "ulx_unspectatedspawn_" .. calling_ply:EntIndex() )
		hook.Remove( "KeyPress", "ulx_unspectate_" .. calling_ply:EntIndex() )
		hook.Remove( "PlayerDisconnected", "ulx_unspectatedisconnect_" .. calling_ply:EntIndex() )
		if player.ULXHasGod then player:GodEnable() end
		player:UnSpectate()
		ulx.fancyLogAdmin( calling_ply, true, "#A stopped spectating #T", target_ply )
		ulx.clearExclusive( calling_ply )
	end
	hook.Add( "PlayerSpawn", "ulx_unspectatedspawn_" .. calling_ply:EntIndex(), stopSpectate, HOOK_MONITOR_HIGH )
	local function unspectate( player, key )
		if calling_ply ~= player then return end
		if key ~= IN_FORWARD and key ~= IN_BACK and key ~= IN_MOVELEFT and key ~= IN_MOVERIGHT then return end
		hook.Remove( "PlayerSpawn", "ulx_unspectatedspawn_" .. calling_ply:EntIndex() )
		if wasAlive then
		    ULib.spawn( player, true )
		end
		stopSpectate( player )
		player:SetPos( pos )
		player:SetAngles( ang )
	end
	hook.Add( "KeyPress", "ulx_unspectate_" .. calling_ply:EntIndex(), unspectate, HOOK_MONITOR_LOW )
	local function disconnect( player )
		if player == target_ply or player == calling_ply then
			unspectate( calling_ply, IN_FORWARD )
		end
	end
	hook.Add( "PlayerDisconnected", "ulx_unspectatedisconnect_" .. calling_ply:EntIndex(), disconnect, HOOK_MONITOR_HIGH )
	calling_ply:Spectate( OBS_MODE_IN_EYE )
	calling_ply:SpectateEntity( target_ply )
	calling_ply:StripWeapons()
	ULib.tsay( calling_ply, "To get out of spectate, move forward.", true )
	ulx.setExclusive( calling_ply, "spectating" )
	ulx.fancyLogAdmin( calling_ply, true, "#A began spectating #T", target_ply )
end
local spectate = ulx.command( CATEGORY_NAME, "ulx spectate", ulx.spectate, "!spectate", true )
spectate:addParam{ type=ULib.cmds.PlayerArg, target="!^" }
spectate:defaultAccess( ULib.ACCESS_ADMIN )
spectate:help( "观察目标玩家." )
function ulx.addForcedDownload( path )
	if ULib.fileIsDir( path ) then
		local files = ULib.filesInDir( path )
		for _, v in ipairs( files ) do
			ulx.addForcedDownload( path .. "/" .. v )
		end
	elseif ULib.fileExists( path ) then
		resource.AddFile( path )
	else
		Msg( "[ULX] ERROR: Tried to add nonexistent or empty file to forced downloads '" .. path .. "'\n" )
	end
end
function ulx.debuginfo( calling_ply )
	local str = string.format( "ULX version: %s\nULib version: %s\n", ULib.pluginVersionStr( "ULX" ), ULib.pluginVersionStr( "ULib" ) )
	str = str .. string.format( "Gamemode: %s\nMap: %s\n", GAMEMODE.Name, game.GetMap() )
	str = str .. "Dedicated server: " .. tostring( game.IsDedicated() ) .. "\n\n"
	local players = player.GetAll()
	str = str .. string.format( "Currently connected players:\nNick%s steamid%s uid%s id lsh\n", str.rep( " ", 27 ), str.rep( " ", 12 ), str.rep( " ", 7 ) )
	for _, ply in ipairs( players ) do
		local id = string.format( "%i", ply:EntIndex() )
		local steamid = ply:SteamID()
		local uid = tostring( ply:UniqueID() )
		local name = utf8.force( ply:Nick() )
		local plyline = name .. str.rep( " ", 32 - utf8.len( name ) )
		plyline = plyline .. steamid .. str.rep( " ", 20 - steamid:len() )
		plyline = plyline .. uid .. str.rep( " ", 11 - uid:len() )
		plyline = plyline .. id .. str.rep( " ", 3 - id:len() )
		if ply:IsListenServerHost() then
			plyline = plyline .. "y	  "
		else
			plyline = plyline .. "n	  "
		end
		str = str .. plyline .. "\n"
	end
	local gmoddefault = ULib.parseKeyValues( ULib.stripComments( ULib.fileRead( "settings/users.txt", true ), "//" ) ) or {}
	str = str .. "\n\nULib.ucl.users (#=" .. table.Count( ULib.ucl.users ) .. "):\n" .. ulx.dumpTable( ULib.ucl.users, 1 ) .. "\n\n"
	str = str .. "ULib.ucl.groups (#=" .. table.Count( ULib.ucl.groups ) .. "):\n" .. ulx.dumpTable( ULib.ucl.groups, 1 ) .. "\n\n"
	str = str .. "ULib.ucl.authed (#=" .. table.Count( ULib.ucl.authed ) .. "):\n" .. ulx.dumpTable( ULib.ucl.authed, 1 ) .. "\n\n"
	str = str .. "Garrysmod default file (#=" .. table.Count( gmoddefault ) .. "):\n" .. ulx.dumpTable( gmoddefault, 1 ) .. "\n\n"
	str = str .. "Active workshop addons on this server:\n"
	local addons = engine.GetAddons()
	for i=1, #addons do
		local addon = addons[i]
		if addon.mounted then
			local name = utf8.force( addon.title )
			str = str .. string.format( "%s%s workshop ID %s\n", name, str.rep( " ", 32 - utf8.len( name ) ), addon.file:gsub( "%D", "" ) )
		end
	end
	str = str .. "\n"
	str = str .. "Active legacy addons on this server:\n"
	local _, possibleaddons = file.Find( "addons/*", "GAME" )
	for _, addon in ipairs( possibleaddons ) do
		if not ULib.findInTable( {"checkers", "chess", "common", "go", "hearts", "spades"}, addon:lower() ) then
			local name = addon
			local author, version, date
			if ULib.fileExists( "addons/" .. addon .. "/addon.txt" ) then
				local t = ULib.parseKeyValues( ULib.stripComments( ULib.fileRead( "addons/" .. addon .. "/addon.txt" ), "//" ) )
				if t and t.AddonInfo then
					t = t.AddonInfo
					if t.name then name = t.name end
					if t.version then version = t.version end
					if tonumber( version ) then version = string.format( "%g", version ) end
					if t.author_name then author = t.author_name end
					if t.up_date then date = t.up_date end
				end
			end
			name = utf8.force( name )
			str = str .. name .. str.rep( " ", 32 - utf8.len( name ) )
			if author then
				str = string.format( "%s by %s%s", str, author, version and "," or "" )
			end
			if version then
				str = str .. " version " .. version
			end
			if date then
				str = string.format( "%s (%s)", str, date )
			end
			str = str .. "\n"
		end
	end
	ULib.fileWrite( "data/ultra_ulx/debugdump.txt", str )
	Msg( "Debug information written to garrysmod/data/ultra_ulx/debugdump.txt on server.\n" )
end
local debuginfo = ulx.command( CATEGORY_NAME, "ulx debuginfo", ulx.debuginfo )
debuginfo:defaultAccess( ULib.ACCESS_SUPERADMIN )
debuginfo:help( "导出调试信息到文件." )
function ulx.resettodefaults( calling_ply, param )
	if param ~= "FORCE" then
		local str = "Are you SURE about this? It will remove all Ultra ULX config files and reset to defaults!"
		local str2 = "如果确定，请输入 \"ulx resettodefaults FORCE\""
		if calling_ply:IsValid() then
			ULib.tsayError( calling_ply, str, true )
			ULib.tsayError( calling_ply, str2, true )
		else
			Msg( str .. "\n" )
			Msg( str2 .. "\n" )
		end
		return
	end
	ULib.fileDelete( "data/ultra_ulx/adverts.txt" )
	ULib.fileDelete( "data/ultra_ulx/banreasons.txt" )
	ULib.fileDelete( "data/ultra_ulx/config.txt" )
	ULib.fileDelete( "data/ultra_ulx/downloads.txt" )
	ULib.fileDelete( "data/ultra_ulx/gimps.txt" )
	ULib.fileDelete( "data/ultra_ulx/sbox_limits.txt" )
	ULib.fileDelete( "data/ultra_ulx/votemaps.txt" )
	if sql.TableExists( "ulib_bans" ) then
		sql.Query( "DROP TABLE ulib_bans" )
	end
	local str = "请切换地图以完成重置。注意：data/ulib/ (用户/组权限) 未被删除，如需重置请手动操作。"
	if calling_ply:IsValid() then
		ULib.tsayError( calling_ply, str, true )
	else
		Msg( str .. "\n" )
	end
	ulx.fancyLogAdmin( calling_ply, "#A 重置了 Ultra ULX 配置（保留 data/ulib/ 权限文件）" )
end
local resettodefaults = ulx.command( CATEGORY_NAME, "ulx resettodefaults", ulx.resettodefaults )
resettodefaults:addParam{ type=ULib.cmds.StringArg, ULib.cmds.optional }
resettodefaults:defaultAccess( ULib.ACCESS_SUPERADMIN )
resettodefaults:help( "重置 Ultra ULX 配置为默认值（仅 data/ultra_ulx/ 目录下的文件）。" )
if SERVER then
	local ulx_kickAfterNameChanges = 			ulx.convar( "kickAfterNameChanges", "0", "<number> - Players can only change their name x times every ulx_kickAfterNameChangesCooldown seconds. 0 to disable.", ULib.ACCESS_ADMIN )
	local ulx_kickAfterNameChangesCooldown = 	ulx.convar( "kickAfterNameChangesCooldown", "60", "<time> - Players can change their name ulx_kickAfterXNameChanges times every x seconds.", ULib.ACCESS_ADMIN )
	local ulx_kickAfterNameChangesWarning = 	ulx.convar( "kickAfterNameChangesWarning", "1", "<1/0> - Display a warning to users to let them know how many more times they can change their name.", ULib.ACCESS_ADMIN )
	ulx.nameChangeTable = ulx.nameChangeTable or {}
	local function checkNameChangeLimit( ply, oldname, newname )
		local maxAttempts = ulx_kickAfterNameChanges:GetInt()
		local duration = ulx_kickAfterNameChangesCooldown:GetInt()
		local showWarning = ulx_kickAfterNameChangesWarning:GetInt()
		if maxAttempts ~= 0 then
			if not ulx.nameChangeTable[ply:SteamID()] then
				ulx.nameChangeTable[ply:SteamID()] = {}
			end
			for i=#ulx.nameChangeTable[ply:SteamID()], 1, -1 do
				if CurTime() - ulx.nameChangeTable[ply:SteamID()][i] > duration then
					table.remove( ulx.nameChangeTable[ply:SteamID()], i )
				end
			end
			table.insert( ulx.nameChangeTable[ply:SteamID()], CurTime() )
			local curAttempts = #ulx.nameChangeTable[ply:SteamID()]
			if curAttempts >= maxAttempts then
				ULib.kick( ply, "Changed name too many times" )
			else
				if showWarning == 1 then
					ULib.tsay( ply, "Warning: You have changed your name " .. curAttempts .. " out of " .. maxAttempts .. " time" .. ( maxAttempts ~= 1 and "s" ) .. " in the past " .. duration .. " second" .. ( duration ~= 1 and "s" ) )
				end
			end
		end
	end
	hook.Add( "ULibPlayerNameChanged", "ULXCheckNameChangeLimit", checkNameChangeLimit )
end
local cl_cvar_pickup = "cl_pickupplayers"
if CLIENT then CreateClientConVar( cl_cvar_pickup, "1", true, true ) end
local function playerPickup( ply, ent )
	local access, tag = ULib.ucl.query( ply, "ulx physgunplayer" )
	if ent:GetClass() == "player" and ULib.isSandbox() and access and not ent.NoNoclip and not ent.frozen and ply:GetInfoNum( cl_cvar_pickup, 1 ) == 1 then
		local restrictions = {}
		ULib.cmds.PlayerArg.processRestrictions( restrictions, ply, {}, tag and ULib.splitArgs( tag )[ 1 ] )
		if restrictions.restrictedTargets == false or (restrictions.restrictedTargets and not table.HasValue( restrictions.restrictedTargets, ent )) then
			return
		end
		ent:SetMoveType( MOVETYPE_NONE )
		return true
	end
end
hook.Add( "PhysgunPickup", "ulxPlayerPickup", playerPickup, HOOK_HIGH )
if SERVER then ULib.ucl.registerAccess( "ulx physgunplayer", ULib.ACCESS_ADMIN, "使用物理枪抓取其他玩家的权限", "Other" ) end
local function playerDrop( ply, ent )
	if ent:GetClass() == "player" then
		ent:SetMoveType( MOVETYPE_WALK )
	end
end
hook.Add( "PhysgunDrop", "ulxPlayerDrop", playerDrop )