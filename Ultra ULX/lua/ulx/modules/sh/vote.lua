local CATEGORY_NAME = "投票"
if SERVER then ulx.convar( "voteEcho", "0", _, ULib.ACCESS_SUPERADMIN ) end
if SERVER then
	util.AddNetworkString( "ulx_vote" )
end
function ulx.doVote( title, options, callback, timeout, filter, noecho, ... )
	timeout = timeout or 20
	if ulx.voteInProgress then
		Msg( "错误！ULX 尝试在另一个投票进行中时启动投票！\n" )
		return false
	end
	if not options[ 1 ] or not options[ 2 ] then
		Msg( "错误！ULX 尝试在少于两个选项的情况下启动投票！\n" )
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
		net.WriteInt( timeout, 16 )
		net.WriteTable( options )
	net.Send(rp)
	ulx.voteInProgress = { callback=callback, options=options, title=title, results={}, voters=voters, votes=0, noecho=noecho, args={...} }
	timer.Create( "ULXVoteTimeout", timeout, 1, ulx.voteDone )
	return true
end
function ulx.voteCallback( ply, command, argv )
	if not ulx.voteInProgress then
		ULib.tsayError( ply, "当前没有进行中的投票" )
		return
	end
	if not argv[ 1 ] or not tonumber( argv[ 1 ] ) or not ulx.voteInProgress.options[ tonumber( argv[ 1 ] ) ] then
		ULib.tsayError( ply, "无效或超出范围的投票选项。" )
		return
	end
	if ply.ulxVoted then
		ULib.tsayError( ply, "你已经投过票了！" )
		return
	end
	local echo = ULib.toBool( GetConVarNumber( "ulx_voteEcho" ) )
	local id = tonumber( argv[ 1 ] )
	ulx.voteInProgress.results[ id ] = ulx.voteInProgress.results[ id ] or 0
	ulx.voteInProgress.results[ id ] = ulx.voteInProgress.results[ id ] + 1
	ulx.voteInProgress.votes = ulx.voteInProgress.votes + 1
	ply.ulxVoted = true
	local str = ply:Nick() .. " voted for: " .. ulx.voteInProgress.options[ id ]
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
		str = "Vote results: No option won because no one voted!"
	else
		str = "Vote results: Option '" .. t.options[ winner ] .. "' won. (" .. winnernum .. "/" .. t.voters .. ")"
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	Msg( str .. "\n" )
end
function ulx.vote( calling_ply, title, ... )
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "当前已有投票正在进行，请等待当前投票结束。", true )
		return
	end
	ulx.doVote( title, { ... }, voteDone )
	ulx.fancyLogAdmin( calling_ply, "#A started a vote (#s)", title )
end
local vote = ulx.command( CATEGORY_NAME, "ulx vote", ulx.vote, "!vote" )
vote:addParam{ type=ULib.cmds.StringArg, hint="投票标题" }
vote:addParam{ type=ULib.cmds.StringArg, hint="选项", ULib.cmds.takeRestOfLine, repeat_min=2, repeat_max=10 }
vote:defaultAccess( ULib.ACCESS_ADMIN )
vote:help( "发起一个公开投票." )
function ulx.stopVote( calling_ply )
	if not ulx.voteInProgress then
		ULib.tsayError( calling_ply, "当前没有进行中的投票。", true )
		return
	end
	ulx.voteDone( true )
	ulx.fancyLogAdmin( calling_ply, "#A has stopped the current vote." )
end
local stopvote = ulx.command( CATEGORY_NAME, "ulx stopvote", ulx.stopVote, "!stopvote" )
stopvote:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopvote:help( "停止正在进行的投票." )
local function voteMapDone2( t, changeTo, ply )
	local shouldChange = false
	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logServAct( ply, "#A approved the votemap" )
		shouldChange = true
	else
		ulx.logServAct( ply, "#A denied the votemap" )
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
	local ratioNeeded = GetConVarNumber( "ulx_votemap2Successratio" )
	local minVotes = GetConVarNumber( "ulx_votemap2Minvotes" )
	local str
	local changeTo
	if #argv > 1 then
		changeTo = t.options[ winner ]
	else
		changeTo = argv[ 1 ]
	end
	if (#argv < 2 and winner ~= 1) or not winner or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Vote results: Vote was unsuccessful."
	elseif ply:IsValid() then
		str = "Vote results: Option '" .. t.options[ winner ] .. "' won, changemap pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
		ulx.doVote( "Accept result and changemap to " .. changeTo .. "?", { "Yes", "No" }, voteMapDone2, 30000, { ply }, true, changeTo, ply )
	else
		str = "Vote results: Option '" .. t.options[ winner ] .. "' won. (" .. winnernum .. "/" .. t.voters .. ")"
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
		ULib.tsayError( calling_ply, "当前已有投票正在进行，请等待当前投票结束。", true )
		return
	end
	for i=2, #argv do
	    if ULib.findInTable( argv, argv[ i ], 1, i-1 ) then
	        ULib.tsayError( calling_ply, "地图 " .. argv[ i ] .. " 被列出了两次，请重试" )
	        return
	    end
	end
	if #argv > 1 then
		ulx.doVote( "Change map to..", argv, voteMapDone, _, _, _, argv, calling_ply )
		ulx.fancyLogAdmin( calling_ply, "#A started a votemap with options" .. string.rep( " #s", #argv ), ... )
	else
		ulx.doVote( "Change map to " .. argv[ 1 ] .. "?", { "Yes", "No" }, voteMapDone, _, _, _, argv, calling_ply )
		ulx.fancyLogAdmin( calling_ply, "#A started a votemap for #s", argv[ 1 ] )
	end
end
local votemap2 = ulx.command( CATEGORY_NAME, "ulx votemap2", ulx.votemap2, "!votemap2" )
votemap2:addParam{ type=ULib.cmds.StringArg, completes=ulx.maps, hint="地图", error="invalid map \"%s\" specified", ULib.cmds.restrictToCompletes, ULib.cmds.takeRestOfLine, repeat_min=1, repeat_max=10 }
votemap2:defaultAccess( ULib.ACCESS_ADMIN )
votemap2:help( "发起一个公开的换图投票." )
if SERVER then ulx.convar( "votemap2Successratio", "0.5", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votemap2Minvotes", "3", _, ULib.ACCESS_ADMIN ) end
local function voteKickDone2( t, target, time, ply, reason )
	local shouldKick = false
	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logUserAct( ply, target, "#A approved the votekick against #T (" .. (reason or "") .. ")" )
		shouldKick = true
	else
		ulx.logUserAct( ply, target, "#A denied the votekick against #T" )
	end
	if shouldKick then
		if reason and reason ~= "" then
			ULib.kick( target, "Vote kick successful. (" .. reason .. ")" )
		else
			ULib.kick( target, "Vote kick successful." )
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
	local ratioNeeded = GetConVarNumber( "ulx_votekickSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_votekickMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Vote results: User will not be kicked. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		if not target:IsValid() then
			str = "Vote results: User voted to be kicked, but has already left."
		elseif ply:IsValid() then
			str = "Vote results: User will now be kicked, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
			ulx.doVote( "Accept result and kick " .. target:Nick() .. "?", { "Yes", "No" }, voteKickDone2, 30000, { ply }, true, target, time, ply, reason )
		else
			str = "Vote results: User will now be kicked. (" .. winnernum .. "/" .. t.voters .. ")"
			ULib.kick( target, "Vote kick successful." )
		end
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end
function ulx.votekick( calling_ply, target_ply, reason )
	if target_ply:IsListenServerHost() then
		ULib.tsayError( calling_ply, "该玩家免疫踢出", true )
		return
	end
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "当前已有投票正在进行，请等待当前投票结束。", true )
		return
	end
	local msg = "Kick " .. target_ply:Nick() .. "?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end
	ulx.doVote( msg, { "Yes", "No" }, voteKickDone, _, _, _, target_ply, nil, calling_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, "#A started a votekick against #T (#s)", target_ply, reason )
	else
		ulx.fancyLogAdmin( calling_ply, "#A started a votekick against #T", target_ply )
	end
end
local votekick = ulx.command( CATEGORY_NAME, "ulx votekick", ulx.votekick, "!votekick" )
votekick:addParam{ type=ULib.cmds.PlayerArg }
votekick:addParam{ type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
votekick:defaultAccess( ULib.ACCESS_ADMIN )
votekick:help( "发起一个针对目标的公开踢出投票." )
if SERVER then ulx.convar( "votekickSuccessratio", "0.6", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votekickMinvotes", "2", _, ULib.ACCESS_ADMIN ) end
local function voteBanDone2( t, nick, steamid, time, ply, reason )
	local shouldBan = false
	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.fancyLogAdmin( ply, "#A approved the voteban against #s (#s minutes) (#s))", nick, time, reason or "" )
		shouldBan = true
	else
		ulx.fancyLogAdmin( ply, "#A denied the voteban against #s", nick )
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
	local ratioNeeded = GetConVarNumber( "ulx_votebanSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_votebanMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Vote results: User will not be banned. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		reason = ("[ULX 投票封禁] " .. (reason or "")):Trim()
		if ply:IsValid() then
			str = "Vote results: User will now be banned, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
			ulx.doVote( "Accept result and ban " .. nick .. "?", { "Yes", "No" }, voteBanDone2, 30000, { ply }, true, nick, steamid, time, ply, reason )
		else
			str = "Vote results: User will now be banned. (" .. winnernum .. "/" .. t.voters .. ")"
			ULib.addBan( steamid, time, reason, nick, ply )
		end
	end
	ULib.tsay( _, str )
	ulx.logString( str )
	Msg( str .. "\n" )
end
function ulx.voteban( calling_ply, target_ply, minutes, reason )
	if target_ply:IsListenServerHost() or target_ply:IsBot() then
		ULib.tsayError( calling_ply, "该玩家免疫封禁", true )
		return
	end
	if ulx.voteInProgress then
		ULib.tsayError( calling_ply, "当前已有投票正在进行，请等待当前投票结束。", true )
		return
	end
	local msg = "Ban " .. target_ply:Nick() .. " for " .. minutes .. " minutes?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end
	ulx.doVote( msg, { "Yes", "No" }, voteBanDone, _, _, _, target_ply:Nick(), target_ply:SteamID(), minutes, calling_ply, reason )
	if reason and reason ~= "" then
		ulx.fancyLogAdmin( calling_ply, "#A started a voteban of #i minute(s) against #T (#s)", minutes, target_ply, reason )
	else
		ulx.fancyLogAdmin( calling_ply, "#A started a voteban of #i minute(s) against #T", minutes, target_ply )
	end
end
local voteban = ulx.command( CATEGORY_NAME, "ulx voteban", ulx.voteban, "!voteban" )
voteban:addParam{ type=ULib.cmds.PlayerArg }
voteban:addParam{ type=ULib.cmds.NumArg, min=0, default=1440, hint="分钟", ULib.cmds.allowTimeString, ULib.cmds.optional }
voteban:addParam{ type=ULib.cmds.StringArg, hint="原因", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
voteban:defaultAccess( ULib.ACCESS_ADMIN )
voteban:help( "发起一个针对目标的公开封禁投票." )
if SERVER then ulx.convar( "votebanSuccessratio", "0.7", _, ULib.ACCESS_ADMIN ) end
if SERVER then ulx.convar( "votebanMinvotes", "3", _, ULib.ACCESS_ADMIN ) end
local votemap = ulx.command( CATEGORY_NAME, "ulx votemap", ulx.votemap, "!votemap" )
votemap:addParam{ type=ULib.cmds.StringArg, completes=ulx.votemaps, hint="地图", ULib.cmds.takeRestOfLine, ULib.cmds.optional }
votemap:defaultAccess( ULib.ACCESS_ALL )
votemap:help( "投票换图，不加参数则列出可用地图." )
local veto = ulx.command( CATEGORY_NAME, "ulx veto", ulx.votemapVeto, "!veto" )
veto:defaultAccess( ULib.ACCESS_ADMIN )
veto:help( "否决一个已通过的换图投票." )
function ulx.mapvote( calling_ply, votetime, should_cancel )
	if PMapVote and PMapVote.Start then
		SetGlobalEntity( "MapVoteCallingPly", calling_ply )
		if not should_cancel then
			OverrideGamemodeSkipConfig = false
			PMapVote.Start(votetime or 28, nil, nil, nil, "map")
			ulx.fancyLogAdmin( calling_ply, "#A 发起了地图投票" )
		else
			PMapVote.Cancel()
			ulx.fancyLogAdmin( calling_ply, "#A 取消了地图投票" )
		end
		return
	end
	if not calling_ply:IsValid() then
		Msg( "无法从控制台使用 mapvote。\n" )
		return
	end
	ulx.fancyLogAdmin( calling_ply, "#A 发起了地图投票" )
	ULib.tsay( _, calling_ply:Nick() .. " 发起了一个地图投票！输入 !votemap <地图名> 来投票。", true )
end
local mapvoteCmd = ulx.command( CATEGORY_NAME, "ulx mapvote", ulx.mapvote, "!mapvote" )
mapvoteCmd:addParam{ type=ULib.cmds.NumArg, min=5, default=28, hint="time", ULib.cmds.optional, ULib.cmds.round }
mapvoteCmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
mapvoteCmd:defaultAccess( ULib.ACCESS_ADMIN )
mapvoteCmd:help( "发起地图投票（已安装 Perfect MapVote 时使用增强版）。" )
mapvoteCmd:setOpposite( "ulx unmapvote", {_, _, true}, "!unmapvote" )
function ulx.gmvote( calling_ply, votetime, should_cancel )
	if PMapVote and PMapVote.Start then
		SetGlobalEntity( "MapVoteCallingPly", calling_ply )
		if not should_cancel then
			OverrideGamemodeSkipConfig = true
			PMapVote.Start(votetime or 15, nil, nil, nil, "gamemode")
			ulx.fancyLogAdmin( calling_ply, "#A 发起了游戏模式投票" )
		else
			OverrideGamemodeSkipConfig = false
			PMapVote.Cancel()
			ulx.fancyLogAdmin( calling_ply, "#A 取消了游戏模式投票" )
		end
		return
	end
	if not calling_ply:IsValid() then
		Msg( "无法从控制台使用 gmvote。\n" )
		return
	end
	ulx.fancyLogAdmin( calling_ply, "#A 发起了游戏模式投票" )
	ULib.tsay( _, calling_ply:Nick() .. " 发起了一个游戏模式投票！", true )
end
local gmvoteCmd = ulx.command( CATEGORY_NAME, "ulx gmvote", ulx.gmvote, "!gmvote" )
gmvoteCmd:addParam{ type=ULib.cmds.NumArg, min=5, default=15, hint="time", ULib.cmds.optional, ULib.cmds.round }
gmvoteCmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
gmvoteCmd:defaultAccess( ULib.ACCESS_ADMIN )
gmvoteCmd:help( "发起游戏模式投票（已安装 Perfect MapVote 时使用增强版）。" )
gmvoteCmd:setOpposite( "ulx ungmvote", {_, _, true}, "!ungmvote" )
