local L = ULib.ulx_lang
ulx.votemaps = ulx.votemaps or {}
local specifiedMaps = {}
local function init()
	local mode = GetConVarNumber( "ulx_votemapMapmode" ) or 1
	if mode == 1 then
		local maps = file.Find( "maps/*.bsp", "GAME" )
		for _, map in ipairs( maps ) do
			map = map:sub( 1, -5 )
			if not specifiedMaps[ map ] then
				table.insert( ulx.votemaps, map )
			end
		end
	else
		for map, _ in pairs( specifiedMaps ) do
			if ULib.fileExists( "maps/" .. map .. ".bsp" ) then
				table.insert( ulx.votemaps, map )
			end
		end
	end
	table.sort( ulx.votemaps )
end
hook.Add( ulx.HOOK_ULXDONELOADING, "ULXInitConfigs", init )
local userMapvote = {}
local mapvotes = {}
ulx.timedVeto = nil
ulx.convar( "votemapEnabled", "1", _, ULib.ACCESS_ADMIN )
ulx.convar( "votemapMintime", "10", _, ULib.ACCESS_ADMIN )
ulx.convar( "votemapWaittime", "5", _, ULib.ACCESS_ADMIN )
ulx.convar( "votemapSuccessratio", "0.5", _, ULib.ACCESS_ADMIN )
ulx.convar( "votemapMinvotes", "3", _, ULib.ACCESS_ADMIN )
ulx.convar( "votemapVetotime", "30", _, ULib.ACCESS_ADMIN )
ulx.convar( "votemapMapmode", "1", _, ULib.ACCESS_ADMIN )
function ulx.votemapVeto( calling_ply )
	if not ulx.timedVeto then
		ULib.tsayError( calling_ply, ULib.ulx_lang.T("votemap_no_veto"), true )
		return
	end
	timer.Remove( "ULXVotemap" )
	ulx.timedVeto = nil
	hook.Call( ulx.HOOK_VETO )
	ULib.tsay( _, L.T( "votemap_veto_success" ), true )
	ulx.logServAct( calling_ply, L.T( "votemap_veto_log" ) )
end
function ulx.votemapAddMap( map )
	specifiedMaps[ map ] = true
end
function ulx.clearVotemaps()
	table.Empty( specifiedMaps )
end
function ulx.votemap( calling_ply, map )
	if not ULib.toBool( GetConVarNumber( "ulx_votemapEnabled" ) ) then
		ULib.tsayError( calling_ply, ULib.ulx_lang.T("votemap_disabled"), true )
		return
	end
	if not calling_ply:IsValid() then
		Msg( ULib.ulx_lang.T("votemap_no_console") .. "\n" )
		return
	end
	if ulx.timedVeto then
		ULib.tsayError( calling_ply, ULib.ulx_lang.T("votemap_veto_pending"), true )
		return
	end
	if not map or map == "" then
		ULib.tsay( calling_ply, L.T( "votemap_list_printed" ), true )
		ULib.console( calling_ply, L.T( "votemap_list_header" ) )
		for id, map in ipairs( ulx.votemaps ) do
			ULib.console( calling_ply, "  " .. id .. " -\t" .. map )
		end
		return
	end
	local mintime = tonumber( GetConVarString( "ulx_votemapMintime" ) ) or 10
	if CurTime() < mintime * 60 then
		ULib.tsayError( calling_ply, L.T( "votemap_cooldown", mintime ), true )
		local timediff = mintime*60 - CurTime()
		ULib.tsayError( calling_ply, L.T( "votemap_wait_remaining", string.FormattedTime( timediff, "%02i:%02i:%02i" ) ), true )
		return
	end
	if userMapvote[ calling_ply ] then
		local waittime = tonumber( GetConVarString( "ulx_votemapWaittime" ) ) or 5
		if CurTime() - userMapvote[ calling_ply ].time < waittime * 60 then
			ULib.tsayError( calling_ply, L.T( "votemap_change_cooldown", waittime ), true )
			local timediff = waittime*60 - (CurTime() - userMapvote[ calling_ply ].time)
			ULib.tsayError( calling_ply, L.T( "votemap_wait_remaining", string.FormattedTime( timediff, "%02i:%02i:%02i" ) ), true )
			return
		end
	end
	local mapid
	if tonumber( map ) then
		mapid = tonumber( map )
		if not ulx.votemaps[ mapid ] then
			ULib.tsayError( calling_ply, ULib.ulx_lang.T("votemap_invalid_id"), true )
			return
		end
	else
		if string.sub( map, -4 ) == ".bsp" then
			map = string.sub( map, 1, -5 )
		end
		mapid = ULib.findInTable( ulx.votemaps, map )
		if not mapid then
			ULib.tsayError( calling_ply, ULib.ulx_lang.T("votemap_invalid_map"), true )
			return
		end
	end
	if userMapvote[ calling_ply ] then
		mapvotes[ userMapvote[ calling_ply ].mapid ] = mapvotes[ userMapvote[ calling_ply ].mapid ] - 1
	end
	userMapvote[ calling_ply ] = { mapid=mapid, time=CurTime() }
	mapvotes[ mapid ] = mapvotes[ mapid ] or 0
	mapvotes[ mapid ] = mapvotes[ mapid ] + 1
	local minvotes = tonumber( GetConVarString( "ulx_votemapMinvotes" ) ) or 0
	local successratio = tonumber( GetConVarString( "ulx_votemapSuccessratio" ) ) or 0.5
	local votes_needed = math.ceil( math.max( minvotes, successratio * #player.GetAll() ) )
	ULib.tsay( _, L.T( "votemap_vote_progress", calling_ply:Nick(), ulx.votemaps[ mapid ], mapvotes[ mapid ], votes_needed, mapid ), true )
	ulx.logString( L.T( "votemap_vote_log", calling_ply:Nick(), ulx.votemaps[ mapid ], mapvotes[ mapid ], votes_needed ) )
	if mapvotes[ mapid ] >= votes_needed then
		local vetotime = tonumber( GetConVarString( "ulx_votemapVetotime" ) ) or 30
		local admins = {}
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			if player:IsConnected() then
				if ULib.ucl.query( player, "ulx veto" ) then
					table.insert( admins, player )
				end
			end
		end
		if #admins <= 0 or vetotime < 1 then
			ULib.tsay( _, L.T( "votemap_success_change", ulx.votemaps[ mapid ] ), true )
			ulx.logString( L.T( "votemap_won_log", ulx.votemaps[ mapid ] ) )
			game.ConsoleCommand( "changelevel " .. ulx.votemaps[ mapid ] .. "\n" )
		else
			ULib.tsay( _, L.T( "votemap_success_pending", ulx.votemaps[ mapid ], vetotime ), true )
			for _, player in ipairs( admins ) do
				ULib.tsay( player, L.T( "votemap_veto_tip" ), true )
			end
			ulx.logString( L.T( "votemap_won_pending_log", ulx.votemaps[ mapid ] ) )
			ulx.timedVeto = true
			hook.Call( ulx.HOOK_VETO )
			timer.Create( "ULXVotemap", vetotime, 1, function() game.ConsoleCommand( "changelevel " .. ulx.votemaps[ mapid ] .. "\n" ) end )
		end
	end
end
function ulx.votemap_disconnect( ply )
	if userMapvote[ ply ] then
		mapvotes[ userMapvote[ ply ].mapid ] = mapvotes[ userMapvote[ ply ].mapid ] - 1
		userMapvote[ ply ] = nil
	end
end
hook.Add( "PlayerDisconnected", "ULXVoteDisconnect", ulx.votemap_disconnect )