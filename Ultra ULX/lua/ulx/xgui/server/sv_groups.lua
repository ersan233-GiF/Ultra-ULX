local groups = {}
function groups.init()
	ULib.ucl.registerAccess( "xgui_managegroups", "superadmin", "允许通过 XGUI 用户组标签页管理用户组、用户和权限字符串。", "XGUI" )
	xgui.addDataType( "playermodels", player_manager.AllValidModels, "xgui_managegroups", 0, 10 )
	xgui.addDataType( "teams", function() return xgui.teams end, "xgui_managegroups", 0, -20 )
	xgui.addDataType( "accesses", function() return xgui.accesses end, "xgui_managegroups", 0, 5 )
	xgui.addDataType( "users", 	function()
									local temp = groups.garryUsers
									table.Merge( temp, ULib.ucl.users )
									return temp
								end, "xgui_managegroups", 20, -10 )
	function groups.setInheritance( ply, args )
		if ULib.ucl.query( ply, "ulx addgroup" ) then
			local group = ULib.ucl.groupInheritsFrom( args[2] )
			while group do
				if group == args[1] or args[1] == args[2] then
					ULib.clientRPC( ply, "Derma_Message", "Cannot set inheritance! You cannot inherit from something you're inheriting to!", "XGUI NOTICE" )
					return
				end
				group = ULib.ucl.groupInheritsFrom( group )
			end
			ULib.ucl.setGroupInheritance( args[1], args[2] )
		end
	end
	xgui.addCmd( "setinheritance", groups.setInheritance )
	function xgui.playerExistsByID( id )
		for k, v in ipairs( player.GetAll() ) do
			if v:SteamID() == id or v:UniqueID() == id or ULib.splitPort( v:IPAddress() ) == id then
				return v
			end
		end
		return false
	end
	local tempfuncadd = ULib.ucl.addUser
	ULib.ucl.addUser = function( id, allows, denies, group )
		local affectedply = xgui.playerExistsByID( id )
		if affectedply then groups.resetAllPlayerValues( affectedply ) end
		tempfuncadd( id, allows, denies, group )
		local temp = {}
		temp[id] = ULib.ucl.users[id]
		xgui.updateData( {}, "users", temp )
	end
	local tempfuncremove = ULib.ucl.removeUser
	ULib.ucl.removeUser = function( id )
		xgui.removeData( {}, "users", { id } )
		local affectedply = xgui.playerExistsByID( id )
		if affectedply then groups.resetAllPlayerValues( affectedply ) end
		tempfuncremove( id )
	end
	function groups.createTeam( ply, args )
		if ULib.ucl.query( ply, "xgui_managegroups" ) then
			local exists = false
			for i, v in ipairs( xgui.teams ) do
				if v.name == args[1] then
					exists = true
				end
			end
			if not exists then
				local team = {}
				team.name = args[1]
				team.color = Color( args[2], args[3], args[4], 255 )
				team.order = #xgui.teams+1
				team.groups = {}
				table.insert( xgui.teams, team )
				groups.refreshTeams()
			end
		end
	end
	xgui.addCmd( "createTeam", groups.createTeam )
	function groups.removeTeam( ply, args )
		if ULib.ucl.query( ply, "xgui_managegroups" ) then
			for i, v in ipairs( xgui.teams ) do
				if v.name == args[1] then
					for _,group in ipairs( v.groups ) do
						groups.doChangeGroupTeam( group, "" )
					end
					table.remove( xgui.teams, i )
					groups.setTeamsOrder()
					groups.refreshTeams()
					break
				end
			end
		end
	end
	xgui.addCmd( "removeTeam", groups.removeTeam )
	function groups.changeGroupTeam( ply, args, norefresh )
		if ULib.ucl.query( ply, "xgui_managegroups" ) then
			groups.doChangeGroupTeam( args[1], args[2], norefresh )
		end
	end
	xgui.addCmd( "changeGroupTeam", groups.changeGroupTeam )
	function groups.doChangeGroupTeam( group, newteam, norefresh )
		local resettable = {}
		for _,teamdata in ipairs( xgui.teams ) do
			for i,groupname in ipairs( teamdata.groups ) do
				if group == groupname then
					table.remove( teamdata.groups, i )
					for modifier, _ in pairs( teamdata ) do
						if modifier ~= "order" and modifier ~= "index" and modifier ~= "groups" and modifier ~= "name" and modifier ~= "color" then
							table.insert( resettable, modifier )
						end
					end
					break
				end
			end
			if teamdata.name == newteam then
				table.insert( teamdata.groups, group )
			end
		end
		groups.resetTeamValue( group, resettable, newteam=="" )
		if not norefresh then groups.refreshTeams() end
	end
	xgui.teamDefaults = {
		armor = { 0, 0, 255 },
		deaths = { 0, -2048, 2047 },
		duckSpeed = 0.3,
		frags = { 0, -2048, 2047 },
		gravity = 1,
		health = { 100, 1, 2.14748e+009 },
		jumpPower = 200,
		maxHealth = 100,
		model = "scientist",
		runSpeed = { 500, 1, nil },
		stepSize = { 18, 0, 512 },
		unDuckSpeed = 0.2,
		walkSpeed = { 250, 1, nil } }
	function groups.updateTeamValue( ply, args )
		if ULib.ucl.query( ply, "xgui_managegroups" ) then
			local modifier = args[2]
			local value = tonumber( args[3] ) or args[3]
			for k, v in ipairs( xgui.teams ) do
				if v.name == args[1] then
					if modifier == "color" then
						v.color = { r=tonumber(args[3]), g=tonumber(args[4]), b=tonumber(args[5]), a=255 }
					else
						if value ~= "" then
							local def = xgui.teamDefaults[modifier]
							if type(def) == "table" then
								if def[2] and value < def[2] then value = def[2] end
								if def[3] and value > def[3] then value = def[3] end
							end
							v[modifier] = value
						else
							v[modifier] = nil
							for _, group in ipairs( v.groups ) do
								groups.resetTeamValue( group, { args[2] } )
							end
						end
					end
					if v[modifier] ~= "order" or args[4] == "true" then
						groups.refreshTeams()
					end
					break
				end
			end
		end
	end
	xgui.addCmd( "updateTeamValue", groups.updateTeamValue )
	function groups.refreshTeams()
		if not ulx.uteamEnabled() then return	end
		ulx.teams = table.Copy( xgui.teams )
		ulx.saveTeams()
		ulx.refreshTeams()
		table.sort( xgui.teams, function(a, b) return a.order < b.order end )
		xgui.sendDataTable( {}, "teams" )
		hook.Call( ULib.HOOK_UCLCHANGED )
		local emptyteams = {}
		for _, teamdata in ipairs( xgui.teams ) do
			if #teamdata.groups == 0 then
				table.insert( emptyteams, teamdata )
			end
		end
		if #emptyteams > 0 then
			local output = "//This file stores teams that do not have any groups assigned to it (Since ULX would discard them). Do not edit this file!\n"
			output = output .. ULib.makeKeyValues( emptyteams )
			ULib.fileWrite( "data/ultra_ulx/empty_teams.txt", output )
		else
			if ULib.fileExists( "data/ultra_ulx/empty_teams.txt" ) then
				ULib.fileDelete( "data/ultra_ulx/empty_teams.txt" )
			end
		end
	end
	function groups.resetPlayerValue( ply, values )
		for _, modifier in ipairs( values ) do
			local defaultvalue = xgui.teamDefaults[modifier]
			if type( defaultvalue ) == "table" then defaultvalue = xgui.teamDefaults[modifier][1] end
			ply[ "Set" .. modifier:sub( 1, 1 ):upper() .. modifier:sub( 2 ) ]( ply, defaultvalue )
		end
	end
	function groups.resetTeamValue( group, values, teamIsUnassigned )
		for _, ply in ipairs( player.GetAll() ) do
			if ply:GetUserGroup() == group then
				groups.resetPlayerValue( ply, values )
				if teamIsUnassigned then ply:SetTeam(1001) end
			end
		end
	end
	function groups.resetAllPlayerValues( ply )
		for _, team in ipairs( ulx.teams ) do
			if team.groups == nil then break end
			for _, group in ipairs( team.groups ) do
				if group == ply:GetUserGroup() then
					local resettable = {}
					for modifier, _ in pairs( team ) do
						if modifier ~= "order" and modifier ~= "index" and modifier ~= "groups" and modifier ~= "name" and modifier ~= "color" then
							table.insert( resettable, modifier )
						end
					end
					groups.resetPlayerValue( ply, resettable )
					break
				end
			end
		end
	end
	function groups.setTeamsOrder()
		for i, v in ipairs( xgui.teams ) do
			v.order = i
		end
	end
	local tempfunc = ULib.ucl.renameGroup
	ULib.ucl.renameGroup = function( orig, new )
		for _, teamdata in ipairs( xgui.teams ) do
			for i, groupname in ipairs( teamdata.groups ) do
				if groupname == orig then
					teamdata.groups[i] = new
				end
				break
			end
		end
		tempfunc( orig, new )
		groups.refreshTeams()
	end
	local otherfunc = ULib.ucl.removeGroup
	ULib.ucl.removeGroup = function( name )
		groups.doChangeGroupTeam( name, "", true )
		otherfunc( name )
		groups.refreshTeams()
		xgui.sendDataTable( {}, "users" )
	end
end
function groups.setAccessData()
	xgui.accesses = {}
	for k, v in pairs( ULib.ucl.accessStrings ) do
		xgui.accesses[k] = {}
		xgui.accesses[k].hStr = v
	end
	for k, v in pairs( ULib.ucl.accessCategories ) do
		xgui.accesses[k].cat = v
	end
end
local function accessesUpdated()
	groups.setAccessData()
	xgui.sendDataTable( {}, "accesses" )
end
hook.Add( ULib.HOOK_ACCESS_REGISTERED, "xgui.accessesUpdated", accessesUpdated )
function groups.postinit()
	groups.garryUsers = {}
	if ULib.fileExists( "settings/users.txt" ) then
		local t = ULib.parseKeyValues( ULib.stripComments( ULib.fileRead( "settings/users.txt", true ), "//" ) ) or {}
		for group, users in pairs ( t ) do
			for user, steamID in pairs( users ) do
				groups.garryUsers[steamID] = { name=user, group=group }
			end
		end
	end
	groups.setAccessData()
	xgui.teams = table.Copy( ulx.teams )
	if ULib.fileExists( "data/ultra_ulx/empty_teams.txt" ) then
		local input = ULib.fileRead( "data/ultra_ulx/empty_teams.txt" )
		input = input:match( "^.-\n(.*)$" )
		local emptyteams = ULib.parseKeyValues( input )
		for _, teamdata in ipairs( emptyteams ) do
			for k,v in pairs( teamdata ) do
				teamdata[k] = tonumber( teamdata[k] ) or teamdata[k]
			end
			table.insert( xgui.teams, teamdata.order, teamdata )
		end
	end
	groups.setTeamsOrder()
	for _, v in ipairs( xgui.teams ) do
		if v.model then
			for shortname,modelpath in pairs( player_manager.AllValidModels() ) do
				if v.model == modelpath then v.model = shortname break end
			end
		end
	end
end
xgui.addSVModule( "groups", groups.init, groups.postinit )