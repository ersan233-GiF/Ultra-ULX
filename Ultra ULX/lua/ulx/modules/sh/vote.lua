local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_vote"
if SERVER then ulx.convar( "voteEcho", "0", _, ULib.ACCESS_SUPERADMIN ) end
if SERVER then
	util.AddNetworkString( "ulx_vote" )
end
function ulx.doVote( title, options, callback, timeout, filter, noecho, ... )
	timeout = timeout or 20
	if ulx.voteInProgress then
		Msg( L.T("vote_already_progress") .. "\n" )
		return false
	end
	if not options[ 1 ] or not options[ 2 ] then
		Msg( L.T("vote_need_options") .. "\n" )
		return false
	end
	local voters = 0
	local rp = RecipientFilter()
	if not filter then
		rp:AddAllPlayers()
		voters = #player.GetAll()
	else
		for _, ply in ipairs( filter ) do
			rp:AddPlayer( ply )
			voters = voters + 1
		end
	end
	net.Start("ulx_vote")
		net.WriteString( title )
		net.WriteUInt( timeout, 32 )
		net.WriteTable( options )
	net.Send(rp)
	ulx.voteInProgress = { callback=callback, options=options, title=title, results={}, voters=voters, votes=0, noecho=noecho, args={...} }
	timer.Create( "ULXVoteTimeout", timeout, 1, ulx.voteDone )
	return true
end
function ulx.voteCallback( ply, command, argv )
	if not ulx.voteInProgress then
		ULib.tsayError( ply, L.T("vote_not_active") )
		return
	end
	if not argv[ 1 ] or not tonumber( argv[ 1 ] ) or not ulx.voteInProgress.options[ tonumber( argv[ 1 ] ) ] then
		ULib.tsayError( ply, L.T("vote_invalid") )
		return
	end
	if ply.ulxVoted then
		ULib.tsayError( ply, L.T("vote_already_cast") )
		return
	end
	local echo = GetConVar( "ulx_voteEcho" ):GetBool()
	local id = tonumber( argv[ 1 ] )
	ulx.voteInProgress.results[ id ] = ulx.voteInProgress.results[ id ] or 0
	ulx.voteInProgress.results[ id ] = ulx.voteInProgress.results[ id ] + 1
	ulx.voteInProgress.votes = ulx.voteInProgress.votes + 1
	ply.ulxVoted = true
	local str = ply:Nick() .. L.T("vote_cast", "", ulx.voteInProgress.options[ id ]):sub(3)
	if echo and not ulx.voteInProgress.noecho then
		ULib.tsay( _, str )
	end
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
	if ulx.voteInProgress.votes >= ulx.voteInProgress.voters then
		ulx.voteDone()
	end
end
if SERVER then concommand.Add( "ulx_vote", ulx.voteCallback ) end
function ulx.voteDone( cancelled )
	local players = player.GetAll()
	for _, ply in ipairs( players ) do
		ply.ulxVoted = nil
	end
	local vip = ulx.voteInProgress
	ulx.voteInProgress = nil
	timer.Remove( "ULXVoteTimeout" )
	if not cancelled then
		ULib.pcallError( vip.callback, vip, unpack( vip.args, 1, 10 ) )
	end
end
local function voteDone( t )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end
	local str
	if not winner then
		str = L.T("vote_no_winner")
	else
		str = L.T("vote_winner", t.options[ winner ], winnernum, t.voters)
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	Msg( str .. "\n" )
end
function ulx.vote( calling_ply, title, ... )
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, L.T("vote_in_progress"), true )
		return
	end
	ulx.doVote( title, { ... }, voteDone )
	ulx.fancyLogKeyed(calling_ply, "vote_start_log", title )
end
local vote = ulx.command( CATEGORY_NAME, "ulx vote", ulx.vote, "!vote" )
vote:addParam{ type=ULib.cmds.StringArg, hint="vote_title" }
vote:addParam{ type=ULib.cmds.StringArg, hint="vote_option", ULib.cmds.takeRestOfLine, repeat_min=2, repeat_max=10 }
vote:defaultAccess( ULib.ACCESS_ADMIN )
vote:help( L.T("help_vote") )
function ulx.stopVote( calling_ply )
	if not ulx.voteInProgress then
		ULib.tsayError( calling_ply, L.T("vote_none_active"), true )
		return
	end
	ulx.voteDone( true )
	ulx.fancyLogKeyed(calling_ply, "vote_stop_log" )
end
local stopvote = ulx.command( CATEGORY_NAME, "ulx stopvote", ulx.stopVote, "!stopvote" )
stopvote:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopvote:help( L.T("help_stopvote") )
local function voteMapDone2( t, changeTo, ply )
	local shouldChange = false
	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logServAct( ply, L.T("vote_approved") )
		shouldChange = true
	else
		ulx.logServAct( ply, L.T("vote_rejected") )
	end
	if shouldChange then
		ULib.consoleCommand( "changelevel " .. changeTo .. "\n" )
	end
end
local function voteMapDone( t, argv, ply )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end
	local ratioNeeded = GetConVar( "ulx_votemap2Successratio" ):GetFloat()
	local minVotes = GetConVar( "ulx_votemap2Minvotes" ):GetInt()
	local str
	local changeTo
	if #argv > 1 then
		changeTo = t.options[ winner ]
	else
		changeTo = argv[ 1 ]
	end
	if (#argv < 2 and winner ~= 1) or not winner or winnernum < minVotes or t.voters <= 0 or winnernum / t.voters < ratioNeeded then
		str = L.T("vote_not_passed")
	elseif ply:IsValid() then
		str = L.T("vote_passed_wait", t.options[ winner ], winnernum, t.voters)
		ulx.doVote( L.T("vote_accept", changeTo), { L.T("vote_agree"), L.T("vote_reject") }, voteMapDone2, 30000, { ply }, true, changeTo, ply )
	else
		str = L.T("vote_winner", t.options[ winner ], winnernum, t.voters)
		ULib.tsay( _, str )
		ulx.logString( str )
		ULib.consoleCommand( "changelevel " .. changeTo .. "\n" )
		return
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end
function ulx.votemap2( calling_ply, ... )
	local argv = { ... }
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, L.T("vote_in_progress"), true )
		return
	end
	for i=2, #argv do
	    if ULib.findInTable( argv, argv[ i ], 1, i-1 ) then
	        ULib.tsayError( calling_ply, string.format(L.T("vote_duplicate_map"), argv[i]) )
	        return
	    end
	end
	if #argv > 1 then
	ulx.doVote( L.T("vote_select_map"), argv, voteMapDone, _, _, _, argv, calling_ply )
		ulx.fancyLogKeyed(calling_ply, "vote_votemap_multi_log", ... )
	else
		ulx.doVote( L.T("vote_switch", argv[ 1 ]), { L.T("vote_agree"), L.T("vote_reject") }, voteMapDone, _, _, _, argv, calling_ply )
		ulx.fancyLogKeyed(calling_ply, "vote_votemap_single_log", argv[ 1 ] )
	end
end
local votemap2 = ulx.command( CATEGORY_NAME, "ulx votemap2", ulx.votemap2, "!votemap2" )
votemap2:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="map", error=L.T("util_invalid_map"), ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min=1, repeat_max=10 }
votemap2:defaultAccess( ULib.ACCESS_ADMIN )
votemap2:help( L.T("help_votemap") )
if SERVER then ulx.convar( "votemap2Successratio", "0.5", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votemap2Minvotes", "3", _, ULib.ACCESS_ADMIN ) end
local function voteKickDone2( t, target, time, ply, reason )
	local shouldKick = false
	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logUserAct( ply, target, L.T("vote_kick_approved", reason or "") )
		shouldKick = true
	else
		ulx.logUserAct( ply, target, L.T("vote_kick_rejected") )
	end
	if shouldKick then
		if reason and reason ~= "" then
			ULib.kick( target, L.T("vote_kick_success", reason) )
		else
			ULib.kick( target, L.T("vote_kick_success2") )
		end
	end
end
local function voteKickDone( t, target, time, ply, reason )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end
	local ratioNeeded = GetConVar( "ulx_votekickSuccessratio" ):GetFloat()
	local minVotes = GetConVar( "ulx_votekickMinvotes" ):GetInt()
	local str
	if winner ~= 1 or winnernum < minVotes or t.voters <= 0 or winnernum / t.voters < ratioNeeded then
		str = L.T("vote_kick_not_passed", (results[ 1 ] or "0"), t.voters)
	else
		if not target:IsValid() then
			str = L.T("vote_kick_left")
		elseif ply:IsValid() then
			str = L.T("vote_kick_pending", winnernum, t.voters)
			ulx.doVote( L.T("vote_kick_accept", target:Nick()), { L.T("vote_agree"), L.T("vote_reject") }, voteKickDone2, 30000, { ply }, true, target, time, ply, reason )
		else
			str = L.T("vote_kick_passed", winnernum, t.voters)
			ULib.kick( target, L.T("vote_kick_success2") )
		end
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end
function ulx.votekick( calling_ply, target_ply, reason )
	if target_ply:IsListenServerHost() then
		ULib.tsayError( calling_ply, L.T("vote_kick_immune"), true )
		return
	end
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, L.T("vote_in_progress"), true )
		return
	end
	local msg = L.T("vote_kick_title", target_ply:Nick())
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end
	ulx.doVote( msg, { L.T("vote_agree"), L.T("vote_reject") }, voteKickDone, _, _, _, target_ply, nil, calling_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogKeyed(calling_ply, "vote_votekick_reason_log", target_ply, reason )
	else
		ulx.fancyLogKeyed(calling_ply, "vote_votekick_log", target_ply )
	end
end
local votekick = ulx.command( CATEGORY_NAME, "ulx votekick", ulx.votekick, "!votekick" )
votekick:addParam{ type=ULib.cmds.PlayerArg }
votekick:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
votekick:defaultAccess( ULib.ACCESS_ADMIN )
votekick:help( L.T("help_votekick") )
if SERVER then ulx.convar( "votekickSuccessratio", "0.6", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votekickMinvotes", "2", _, ULib.ACCESS_ADMIN ) end
local function voteBanDone2( t, nick, steamid, time, ply, reason )
	local shouldBan = false
	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.fancyLogKeyed( ply, "vote_voteban_approve_log", nil, nick, time, reason or "" )
		shouldBan = true
	else
		ulx.fancyLogKeyed( ply, "vote_voteban_deny_log", nil, nick )
	end
	if shouldBan then
		ULib.addBan( steamid, time, reason, nick, ply )
	end
end
local function voteBanDone( t, nick, steamid, time, ply, reason )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end
	local ratioNeeded = GetConVar( "ulx_votebanSuccessratio" ):GetFloat()
	local minVotes = GetConVar( "ulx_votebanMinvotes" ):GetInt()
	local str
	if winner ~= 1 or winnernum < minVotes or t.voters <= 0 or winnernum / t.voters < ratioNeeded then
		str = L.T("vote_ban_not_passed", (results[ 1 ] or "0"), t.voters)
	else
		reason = (L.T("vote_ban_reason_prefix") .. (reason or "")):Trim()
		if ply:IsValid() then
			str = L.T("vote_ban_pending", winnernum, t.voters)
			ulx.doVote( L.T("vote_ban_accept", nick), { L.T("vote_agree"), L.T("vote_reject") }, voteBanDone2, 30000, { ply }, true, nick, steamid, time, ply, reason )
		else
			str = L.T("vote_ban_passed", winnernum, t.voters)
			ULib.addBan( steamid, time, reason, nick, ply )
		end
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	Msg( str .. "\n" )
end
function ulx.voteban( calling_ply, target_ply, minutes, reason )
	if target_ply:IsListenServerHost() or target_ply:IsBot() then
		ULib.tsayError( calling_ply, L.T("vote_ban_immune"), true )
		return
	end
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, L.T("vote_in_progress"), true )
		return
	end
	local msg = L.T("vote_ban_title", target_ply:Nick(), minutes)
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end
	ulx.doVote( msg, { L.T("vote_agree"), L.T("vote_reject") }, voteBanDone, _, _, _, target_ply:Nick(), target_ply:SteamID(), minutes, calling_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogKeyed( calling_ply, "vote_voteban_reason_log", target_ply, minutes, reason or "" )
	else
		ulx.fancyLogKeyed( calling_ply, "vote_voteban_log", target_ply, minutes )
	end
end
local voteban = ulx.command( CATEGORY_NAME, "ulx voteban", ulx.voteban, "!voteban" )
voteban:addParam{ type=ULib.cmds.PlayerArg }
voteban:addParam{ type=ULib.cmds.NumArg, min=0, default=1440, hint="vote_minutes", ULib.cmds.allowTimeString, ULib.cmds.optional }
voteban:addParam{ type=ULib.cmds.StringArg, hint="vote_reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
voteban:defaultAccess( ULib.ACCESS_ADMIN )
voteban:help( L.T("help_voteban") )
if SERVER then ulx.convar( "votebanSuccessratio", "0.7", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votebanMinvotes", "3", _, ULib.ACCESS_ADMIN ) end
local votemap = ulx.command( CATEGORY_NAME, "ulx votemap", ulx.votemap, "!votemap" )
votemap:addParam{ type=ULib.cmds.StringArg, completes=ulx.votemaps, hint="map", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
votemap:defaultAccess( ULib.ACCESS_ALL )
votemap:help( L.T("help_mapvote") )
local veto = ulx.command( CATEGORY_NAME, "ulx veto", ulx.votemapVeto, "!veto" )
veto:defaultAccess( ULib.ACCESS_ADMIN )
veto:help( L.T("help_veto") )
function ulx.mapvote( calling_ply, votetime, should_cancel )
	if PMapVote and PMapVote.Start then
		SetGlobalEntity( "MapVoteCallingPly", calling_ply )
		if not should_cancel then
			OverrideGamemodeSkipConfig = false
			PMapVote.Start(votetime or 28, nil, nil, nil, "map")
			ulx.fancyLogKeyed(calling_ply, "vote_mapvote_log" )
		else
			PMapVote.Cancel()
			ulx.fancyLogKeyed(calling_ply, "vote_mapvote_stop" )
		end
		return
	end
	if not calling_ply:IsValid() then
		Msg( L.T("vote_console_mapvote") .. "\n" )
		return
	end
	ulx.fancyLogKeyed(calling_ply, "vote_mapvote_log" )
	ULib.tsay( _, L.T("vote_staff_started", calling_ply:Nick()), true )
end
local mapvoteCmd = ulx.command( CATEGORY_NAME, "ulx mapvote", ulx.mapvote, "!mapvote" )
mapvoteCmd:addParam{ type=ULib.cmds.NumArg, min=5, default=28, hint="vote_time", ULib.cmds.optional, ULib.cmds.round }
mapvoteCmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
mapvoteCmd:defaultAccess( ULib.ACCESS_ADMIN )
mapvoteCmd:help( L.T("help_mapvote") )
mapvoteCmd:setOpposite( "ulx unmapvote", {_, _, true}, "!unmapvote" )
function ulx.gmvote( calling_ply, votetime, should_cancel )
	if PMapVote and PMapVote.Start then
		SetGlobalEntity( "MapVoteCallingPly", calling_ply )
		if not should_cancel then
			OverrideGamemodeSkipConfig = true
			PMapVote.Start(votetime or 15, nil, nil, nil, "gamemode")
			ulx.fancyLogKeyed(calling_ply, "vote_gmvote_log" )
		else
			OverrideGamemodeSkipConfig = false
			PMapVote.Cancel()
			ulx.fancyLogKeyed(calling_ply, "vote_gmvote_stop" )
		end
		return
	end
	if not calling_ply:IsValid() then
		Msg( L.T("vote_console_gmvote") .. "\n" )
		return
	end
	ulx.fancyLogKeyed(calling_ply, "vote_gmvote_log" )
	ULib.tsay( _, L.T("vote_gm_started", calling_ply:Nick()), true )
end
local gmvoteCmd = ulx.command( CATEGORY_NAME, "ulx gmvote", ulx.gmvote, "!gmvote" )
gmvoteCmd:addParam{ type=ULib.cmds.NumArg, min=5, default=15, hint="vote_time", ULib.cmds.optional, ULib.cmds.round }
gmvoteCmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
gmvoteCmd:defaultAccess( ULib.ACCESS_ADMIN )
gmvoteCmd:help( L.T("help_gmvote") )
gmvoteCmd:setOpposite( "ulx ungmvote", {_, _, true}, "!ungmvote" )