local function processLineConfig( path, noMount, clearFn, addFn, useStripQuotes )
	local content = ULib.fileRead( path, noMount )
	if not content then return end
	if clearFn then clearFn() end
	local lines = ULib.explode( "\n+", ULib.stripComments( content, ";" ) )
	for _, line in ipairs( lines ) do
		line = line:Trim()
		if line:len() > 0 then
			addFn( useStripQuotes and ULib.stripQuotes( line ) or line )
		end
	end
end
local function doMainCfg( path, noMount )
	ULib.execStringULib( ULib.stripComments( ULib.fileRead( path, noMount ), ";" ), true )
end
local function doDownloadCfg( path, noMount )
	if not ulx.addForcedDownload then return end
	processLineConfig( path, noMount, nil, ulx.addForcedDownload, true )
end
local function doGimpCfg( path, noMount )
	if not ulx.clearGimpSays then return end
	processLineConfig( path, noMount, ulx.clearGimpSays, ulx.addGimpSay, true )
end
local function doAdvertCfg( path, noMount )
	if not ulx.addAdvert then return end
	local data_root, err = ULib.parseKeyValues( ULib.stripComments( ULib.fileRead( path, noMount ), ";" ) )
	if not data_root then Msg( "[ULX] 广告配置错误: " .. err .. "\n" ) return end
	for group_name, row in pairs( data_root ) do
		if type( group_name ) == "number" then
			local color = Color( tonumber( row.red ) or ULib.DEFAULT_TSAY_COLOR.r, tonumber( row.green ) or ULib.DEFAULT_TSAY_COLOR.g, tonumber( row.blue ) or ULib.DEFAULT_TSAY_COLOR.b )
			ulx.addAdvert( row.text or "NO TEXT SUPPLIED FOR THIS ADVERT", tonumber( row.time ) or 300, _, color, tonumber( row.time_on_screen ) )
		else
			if type( row ) ~= "table" then Msg( "[ULX] 广告配置错误: 格式不正确!\n" ) return end
			for i = 1, #row do
				local row2 = row[ i ]
				local color = Color( tonumber( row2.red ) or 151, tonumber( row2.green ) or 211, tonumber( row2.blue ) or 255 )
				ulx.addAdvert( row2.text or "NO TEXT SUPPLIED FOR THIS ADVERT", tonumber( row2.time ) or 300, group_name, color, tonumber( row2.time_on_screen ) )
			end
		end
	end
end
local function doVotemapsCfg( path, noMount )
	if not ulx.clearVotemaps then return end
	processLineConfig( path, noMount, ulx.clearVotemaps, ulx.votemapAddMap, false )
end
local function doReasonsCfg( path, noMount )
	if not ulx.addKickReason then return end
	processLineConfig( path, noMount, nil, ulx.addKickReason, true )
end
local function doMotdCfg( path, noMount )
	if not ulx.motd then return end
	local data_root, err = ULib.parseKeyValues( ULib.stripComments( ULib.fileRead( path, noMount ), ";" ) )
	if not data_root then Msg( "[ULX] MOTD 配置错误: " .. err .. "\n" ) return end
	ulx.motdSettings = data_root
	ulx.populateMotdData()
end
local function doMessageCfg( path, noMount )
	local message = ULib.stripComments( ULib.fileRead( path, noMount ), ";" ):Trim()
	if message and message:find( "%W" ) then
		ULib.BanMessage = message
	end
end
local function doCfg()
	local configHandlers = {
		["config.txt"]      = doMainCfg,
		["downloads.txt"]   = doDownloadCfg,
		["gimps.txt"]       = doGimpCfg,
		["adverts.txt"]     = doAdvertCfg,
		["votemaps.txt"]    = doVotemapsCfg,
		["banreasons.txt"]  = doReasonsCfg,
		["motd.txt"]        = doMotdCfg,
		["banmessage.txt"]  = doMessageCfg,
	}
	local gamemode_name = GAMEMODE and GAMEMODE.Name and GAMEMODE.Name:lower() or "sandbox"
	local map_name = game.GetMap()
	for filename, handler in pairs( configHandlers ) do
		if ULib.fileExists( "data/ultra_ulx/" .. filename ) then
			handler( "data/ultra_ulx/" .. filename )
		end
		if ULib.fileExists( "data/ultra_ulx/gamemodes/" .. gamemode_name .. "/" .. filename, true ) then
			handler( "data/ultra_ulx/gamemodes/" .. gamemode_name .. "/" .. filename, true )
		end
		if ULib.fileExists( "data/ultra_ulx/maps/" .. map_name .. "/" .. filename, true ) then
			handler( "data/ultra_ulx/maps/" .. map_name .. "/" .. filename, true )
		end
	end
	ULib.namedQueueFunctionCall( "ULXConfigExec", hook.Call, ulx.HOOK_ULXDONELOADING, _ )
	if not game.IsDedicated() then
		hook.Remove( "PlayerInitialSpawn", "ULXDoCfg" )
	end
end
if game.IsDedicated() then
	hook.Add( "Initialize", "ULXDoCfg", doCfg, HOOK_MONITOR_HIGH )
else
	hook.Add( "PlayerInitialSpawn", "ULXDoCfg", doCfg, HOOK_MONITOR_HIGH )
end