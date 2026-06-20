ulx.common_kick_reasons = ulx.common_kick_reasons or {}
function ulx.populateKickReasons( reasons )
table.Empty( ulx.common_kick_reasons )
table.Merge( ulx.common_kick_reasons, reasons )
end
ulx.maps = ulx.maps or {}
function ulx.populateClMaps( maps )
table.Empty( ulx.maps )
table.Merge( ulx.maps, maps )
end
ulx.gamemodes = ulx.gamemodes or {}
function ulx.populateClGamemodes( gamemodes )
table.Empty( ulx.gamemodes )
table.Merge( ulx.gamemodes, gamemodes )
end
ulx.votemaps = ulx.votemaps or {}
function ulx.populateClVotemaps( votemaps )
table.Empty( ulx.votemaps )
table.Merge( ulx.votemaps, votemaps )
end
function ulx.soundComplete( ply, args )
local targs = string.Trim( args )
local soundList = {}
local relpath = targs:GetPathFromFilename()
local sounds = file.Find( "sound/" .. relpath .. "*", "GAME" )
for _, sound in ipairs( sounds ) do
if targs:len() == 0 or (relpath .. sound):sub( 1, targs:len() ) == targs then
table.insert( soundList, relpath .. sound )
end
end
return soundList
end
function ulx.blindUser( bool, amt )
if bool then
local function blind()
draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 255, 255, 255, amt ) )
end
hook.Add( "HUDPaint", "ulx_blind", blind )
else
hook.Remove( "HUDPaint", "ulx_blind" )
end
end
net.Receive( "ulx_blind", function( ln )
local bool = net.ReadBool()
local amt = net.ReadInt(16)
ulx.blindUser( bool, amt )
end )
local curVote
local function cleanupVote()
curVote = nil
hook.Remove( "HUDPaint", "ULXVoteHUDPaint" )
hook.Remove( "PlayerBindPress", "ULXVoteKeyPress" )
timer.Remove( "ULXVoteTimeout" )
end
local function optionsDraw()
if not curVote then return end
if CurTime() > curVote.endtime then
cleanupVote()
return
end
surface.SetFont( "Default" )
local w, h = surface.GetTextSize( curVote.title )
w = math.max( 200, w )
local totalh = h * 12 + 20
draw.RoundedBox( 8, 10, ScrH()*0.4 - 10, w + 20, totalh, Color( 111, 124, 138, 200 ) )
local lines = {}
for i = 1, 10 do
if curVote.options[ i ] and curVote.options[ i ] ~= "" then
lines[ #lines + 1 ] = i .. ". " .. curVote.options[ i ]
end
end
draw.DrawText( curVote.title .. "\n\n" .. table.concat( lines, "\n" ), "Default", 20, ScrH()*0.4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )
end
net.Receive( "ulx_vote", function( ln )
local title = net.ReadString()
local timeout = net.ReadInt(16)
local options = net.ReadTable()
local function callback( id )
if id == 0 then id = 10 end
if not options[ id ] then
return
end
RunConsoleCommand( "ulx_vote", id )
cleanupVote()
return true
end
hook.Add( "HUDPaint", "ULXVoteHUDPaint", optionsDraw )
timer.Create( "ULXVoteTimeout", timeout, 1, cleanupVote )
local function voteKeyPress( ply, bind, pressed )
if not curVote then
cleanupVote()
return
end
local id = tonumber( bind:match( "^slot(%d+)$" ) )
if not id then return end
if callback( id ) then
return true
end
end
hook.Add( "PlayerBindPress", "ULXVoteKeyPress", voteKeyPress )
curVote = { title=title, options=options, endtime=CurTime()+timeout }
end )
language.Add( "Undone_ulx_ent", "已撤销 ulx ent 命令" )
