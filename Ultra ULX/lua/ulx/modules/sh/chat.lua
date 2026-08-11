local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_chat"
local string = string
local math = math
local table = table
local player = player
local team = team
local game = game
local Msg = Msg
local CurTime = CurTime
local GetConVarNumber = GetConVarNumber
local ULib = ULib
function ulx.psay( calling_ply, target_ply, message )
	if calling_ply:GetNWBool( "ulx_muted", false ) then
		ULib.tsayError( calling_ply, L.T("chat_psay_self"), true )
		return
	end
	local fromNick = calling_ply:IsValid() and calling_ply:Nick() or L.T("console")
	local toNick   = target_ply:Nick()
	ULib.tsayColor( target_ply, false, ULib.COLOR_INFO, "(" .. fromNick .. " → " .. L.T("cmd_psay") .. ") ", color_white, message )
	if calling_ply:IsValid() then
		ULib.tsayColor( calling_ply, false, ULib.COLOR_INFO, "(" .. L.T("cmd_psay") .. " → " .. toNick .. ") ", color_white, message )
	end
	ulx.fancyLogKeyed(_, "chat_psay_log_format", { target_ply, calling_ply }, calling_ply, target_ply, message )
end
local psay = ulx.command( CATEGORY_NAME, "ulx psay", ulx.psay, "!p", true )
psay:addParam{ type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget }
psay:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
psay:defaultAccess( ULib.ACCESS_ALL )
psay:help( L.T("help_psay") )
local seeasayAccess = "ulx seeasay"
if SERVER then ULib.ucl.registerAccess( seeasayAccess, ULib.ACCESS_OPERATOR, L.T("access_see_asay"), "Other" ) end
function ulx.asay( calling_ply, message )
	local format
	local me = "/me "
	if message:sub( 1, me:len() ) == me then
		format = L.T("chat_asay_me")
		message = message:sub( me:len() + 1 )
	else
		format = L.T("chat_asay_format")
	end
	local players = player.GetAll()
	for i=#players, 1, -1 do
		local v = players[ i ]
		if not ULib.ucl.query( v, seeasayAccess ) and v ~= calling_ply then
			table.remove( players, i )
		end
	end
	ulx.fancyLog( players, format, calling_ply, message )
end
local asay = ulx.command( CATEGORY_NAME, "ulx asay", ulx.asay, "@", true, true )
asay:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
asay:defaultAccess( ULib.ACCESS_ALL )
asay:help( L.T("help_asay") )
function ulx.tsay( calling_ply, message )
	ULib.tsay( _, message )
	if ULib.toBool( GetConVarNumber( "ulx_logChat" ) ) then
		ulx.logString( string.format( L.T("chat_tsay_from"), calling_ply:IsValid() and calling_ply:Nick() or L.T("console"), message ) )
	end
end
local tsay = ulx.command( CATEGORY_NAME, "ulx tsay", ulx.tsay, "@@", true, true )
tsay:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
tsay:defaultAccess( ULib.ACCESS_ADMIN )
tsay:help( L.T("help_tsay") )
function ulx.csay( calling_ply, message )
	ULib.csay( _, message )
	if ULib.toBool( GetConVarNumber( "ulx_logChat" ) ) then
		ulx.logString( string.format( "(csay from %s) %s", calling_ply:IsValid() and calling_ply:Nick() or "Console", message ) )
	end
end
local csay = ulx.command( CATEGORY_NAME, "ulx csay", ulx.csay, "@@@", true, true )
csay:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
csay:defaultAccess( ULib.ACCESS_ADMIN )
csay:help( L.T("help_csay") )
local waittime = 60
local lasttimeusage = -waittime
function ulx.thetime( calling_ply )
	if lasttimeusage + waittime > CurTime() then
		ULib.tsayError( calling_ply, string.format(L.T("chat_thetime_wait"), waittime), true )
		return
	end
	lasttimeusage = CurTime()
	ulx.fancyLogKeyed(_, "chat_thetime_log", {}, os.date( "%Y-%m-%d %H:%M") )
end
local thetime = ulx.command( CATEGORY_NAME, "ulx thetime", ulx.thetime, "!thetime" )
thetime:defaultAccess( ULib.ACCESS_ALL )
thetime:help( L.T("help_thetime") )
ulx.adverts = ulx.adverts or {}
local adverts = ulx.adverts
local function doAdvert( group, id )
	if adverts[ group ][ id ] == nil then
		if adverts[ group ].removed_last then
			adverts[ group ].removed_last = nil
			id = 1
		else
			id = #adverts[ group ]
		end
	end
	local info = adverts[ group ][ id ]
	local message = string.gsub( info.message, "%%curmap%%", game.GetMap() )
	message = string.gsub( message, "%%host%%", GetConVarString( "hostname" ) )
	message = string.gsub( message, "%%ulx_version%%", ULib.pluginVersionStr( "ULX" ) )
	if not info.len then
		local lines = ULib.explode( "\\n", message )
		for i, line in ipairs( lines ) do
			local trimmed = line:Trim()
			if trimmed:len() > 0 then
				ULib.tsayColor( _, true, info.color, trimmed )
			end
		end
	else
		ULib.csay( _, message, info.color, info.len )
	end
	ULib.queueFunctionCall( function()
		local nextid = math.fmod( id, #adverts[ group ] ) + 1
		timer.Remove( "ULXAdvert" .. type( group ) .. group )
		timer.Create( "ULXAdvert" .. type( group ) .. group, adverts[ group ][ nextid ].rpt, 1, function() doAdvert( group, nextid ) end )
	end )
end
function ulx.addAdvert( message, rpt, group, color, len )
	local t
	if group then
		t = adverts[ tostring( group ) ]
		if not t then
			t = {}
			adverts[ tostring( group ) ] = t
		end
	else
		group = table.insert( adverts, {} )
		t = adverts[ group ]
	end
	local id = table.insert( t, { message=message, rpt=rpt, color=color, len=len } )
	if not timer.Exists( "ULXAdvert" .. type( group ) .. group ) then
		timer.Create( "ULXAdvert" .. type( group ) .. group, rpt, 1, function() doAdvert( group, id ) end )
	end
end
ulx.gimpSays = ulx.gimpSays or {}
local gimpSays = ulx.gimpSays
local ID_GIMP = 1
local ID_MUTE = 2
function ulx.addGimpSay( say )
	table.insert( gimpSays, say )
end
function ulx.clearGimpSays()
	table.Empty( gimpSays )
end
function ulx.gimp( calling_ply, target_plys, should_ungimp )
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if should_ungimp then
			v.gimp = nil
		else
			v.gimp = ID_GIMP
		end
		v:SetNWBool("ulx_gimped", not should_ungimp)
	end
	if not should_ungimp then
		ulx.fancyLogKeyed(calling_ply, "chat_gimp_log", target_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "chat_ungimp_log", target_plys )
	end
end
local gimp = ulx.command( CATEGORY_NAME, "ulx gimp", ulx.gimp, "!gimp" )
gimp:addParam{ type=ULib.cmds.PlayersArg }
gimp:addParam{ type=ULib.cmds.BoolArg, invisible=true }
gimp:defaultAccess( ULib.ACCESS_ADMIN )
gimp:help( L.T("help_gimp") )
gimp:setOpposite( "ulx ungimp", {_, _, true}, "!ungimp" )
function ulx.mute( calling_ply, target_plys, should_unmute )
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if should_unmute then
			v.gimp = nil
		else
			v.gimp = ID_MUTE
		end
		v:SetNWBool("ulx_muted", not should_unmute)
	end
	if not should_unmute then
		ulx.fancyLogKeyed(calling_ply, "chat_mute_log", target_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "chat_unmute_log", target_plys )
	end
end
local mute = ulx.command( CATEGORY_NAME, "ulx mute", ulx.mute, "!mute" )
mute:addParam{ type=ULib.cmds.PlayersArg }
mute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
mute:defaultAccess( ULib.ACCESS_ADMIN )
mute:help( L.T("help_mute") )
mute:setOpposite( "ulx unmute", {_, _, true}, "!unmute" )
if SERVER then
	local function gimpCheck( ply, strText )
		if ply.gimp == ID_MUTE then return "" end
		if ply.gimp == ID_GIMP then
			if #gimpSays < 1 then return nil end
			return gimpSays[ math.random( #gimpSays ) ]
		end
	end
	hook.Add( "PlayerSay", "ULXGimpCheck", gimpCheck, HOOK_LOW )
end
function ulx.gag( calling_ply, target_plys, should_ungag )
	local players = player.GetAll()
	for i=1, #target_plys do
		local v = target_plys[ i ]
		v.ulx_gagged = not should_ungag
		v:SetNWBool("ulx_gagged", v.ulx_gagged)
	end
	if not should_ungag then
		ulx.fancyLogKeyed(calling_ply, "chat_gag_log", target_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "chat_ungag_log", target_plys )
	end
end
local gag = ulx.command( CATEGORY_NAME, "ulx gag", ulx.gag, "!gag" )
gag:addParam{ type=ULib.cmds.PlayersArg }
gag:addParam{ type=ULib.cmds.BoolArg, invisible=true }
gag:defaultAccess( ULib.ACCESS_ADMIN )
gag:help( L.T("help_gag") )
gag:setOpposite( "ulx ungag", {_, _, true}, "!ungag" )
function ulx.silence( calling_ply, target_plys, should_unsilence )
	ulx.mute( calling_ply, target_plys, should_unsilence )
	ulx.gag( calling_ply, target_plys, should_unsilence )
	if not should_unsilence then
		ulx.fancyLogKeyed(calling_ply, "comm_silence_add", target_plys )
	else
		ulx.fancyLogKeyed(calling_ply, "comm_silence_remove", target_plys )
	end
end
local silence = ulx.command( CATEGORY_NAME, "ulx silence", ulx.silence, "!silence" )
silence:addParam{ type=ULib.cmds.PlayersArg }
silence:addParam{ type=ULib.cmds.BoolArg, invisible=true }
silence:defaultAccess( ULib.ACCESS_ADMIN )
silence:help( L.T("comm_silence_help") )
silence:setOpposite( "ulx unsilence", {_, _, true}, "!unsilence" )
local function gagHook( listener, talker )
	if talker.ulx_gagged then
		return false
	end
end
hook.Add( "PlayerCanHearPlayersVoice", "ULXGag", gagHook )
if SERVER then
	local chattime_cvar = ulx.convar( "chattime", "1.5", "<time> - Players can only chat every x seconds (anti-spam). 0 to disable.", ULib.ACCESS_ADMIN )
	local function playerSay( ply )
		if not ply.lastChatTime then ply.lastChatTime = 0 end
		local chattime = chattime_cvar:GetFloat()
		if chattime <= 0 then return end
		if ply.lastChatTime + chattime > CurTime() then
			return ""
		else
			ply.lastChatTime = CurTime()
			return
		end
	end
	hook.Add( "PlayerSay", "ulxPlayerSay", playerSay, HOOK_LOW )
	local function meCheck( ply, strText, bTeam )
		local meChatEnabled = GetConVarNumber( "ulx_meChatEnabled" )
		if ply.gimp or meChatEnabled == 0 or (meChatEnabled ~= 2 and GAMEMODE.Name ~= "Sandbox") then return end
		if strText:sub( 1, 4 ) == "/me " then
			strText = string.format( "*** %s %s", ply:Nick(), strText:sub( 5 ) )
			if not bTeam then
				ULib.tsay( _, strText )
			else
				strText = "(TEAM) " .. strText
				local teamid = ply:Team()
				local players = team.GetPlayers( teamid )
				for _, ply2 in ipairs( players ) do
					ULib.tsay( ply2, strText )
				end
			end
			if game.IsDedicated() then
				Msg( strText .. "\n" )
			end
			if ULib.toBool( GetConVarNumber( "ulx_logChat" ) ) then
				ulx.logString( strText )
			end
			return ""
		end
	end
	hook.Add( "PlayerSay", "ULXMeCheck", meCheck, HOOK_LOW )
end
local function showWelcome( ply )
	local message = GetConVarString( "ulx_welcomemessage" )
	if not message or message == "" then return end
	message = string.gsub( message, "%%curmap%%", game.GetMap() )
	message = string.gsub( message, "%%host%%", GetConVarString( "hostname" ) )
	message = string.gsub( message, "%%ulx_version%%", ULib.pluginVersionStr( "ULX" ) )
	ply:ChatPrint( message )
end
hook.Add( "PlayerInitialSpawn", "ULXWelcome", showWelcome )
if SERVER then
	ulx.convar( "meChatEnabled", "1", "Allow players to use '/me' in chat. 0 = Disabled, 1 = Sandbox only (Default), 2 = Enabled", ULib.ACCESS_ADMIN )
	ulx.convar( "welcomemessage", "", "<msg> - This is shown to players on join.", ULib.ACCESS_ADMIN )
end