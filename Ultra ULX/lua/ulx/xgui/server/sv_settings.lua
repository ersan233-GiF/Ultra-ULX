local settings = {}
function settings.init()
	ULib.ucl.registerAccess( "xgui_gmsettings", "superadmin", "允许在 XGUI 设置标签页中更改游戏模式相关设置。", "XGUI" )
	ULib.ucl.registerAccess( "xgui_svsettings", "superadmin", "允许在 XGUI 设置标签页中更改服务器和 ULX 相关设置。", "XGUI" )
	xgui.addDataType( "gimps", function() return ulx.gimpSays end, "xgui_svsettings", 0, -10 )
	xgui.addDataType( "adverts", function() return ulx.adverts end, "xgui_svsettings", 0, -10 )
	xgui.addDataType( "banreasons", function() return ulx.common_kick_reasons end, "ulx ban", 0, -10 )
	xgui.addDataType( "votemaps", function() return settings.votemaps end, nil, 0, -20 )
	xgui.addDataType( "motdsettings", function() return ulx.motdSettings end, nil, 0, -20 )
	xgui.addDataType( "banmessage", function() return {message=ULib.BanMessage} end, nil, 0, 0 )
	ULib.replicatedWritableCvar( "sv_alltalk", "rep_sv_alltalk", GetConVarNumber( "sv_alltalk" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_voiceenable", "rep_sv_voiceenable", GetConVarNumber( "sv_voiceenable" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "ai_disabled", "rep_ai_disabled", GetConVarNumber( "ai_disabled" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "ai_ignoreplayers", "rep_ai_ignoreplayers", GetConVarNumber( "ai_ignoreplayers" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "ai_serverragdolls", "rep_ai_serverragdolls", GetConVarNumber( "ai_serverragdolls" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_sticktoground", "rep_sv_sticktoground", GetConVarNumber( "sv_sticktoground" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_playerpickupallowed", "rep_sv_playerpickupallowed", GetConVarNumber( "sv_playerpickupallowed" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "mp_falldamage", "rep_mp_falldamage", GetConVarNumber( "mp_falldamage" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "gmod_suit", "rep_gmod_suit", GetConVarNumber( "gmod_suit" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_gravity", "rep_sv_gravity", GetConVarNumber( "sv_gravity" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_friction", "rep_sv_friction", GetConVarNumber( "sv_friction" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "phys_timescale", "rep_phys_timescale", GetConVarNumber( "phys_timescale" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_defaultdeployspeed", "rep_sv_defaultdeployspeed", GetConVarNumber( "sv_defaultdeployspeed" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_noclipspeed", "rep_sv_noclipspeed", GetConVarNumber( "sv_noclipspeed" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "gmod_maxammo", "rep_gmod_maxammo", GetConVarNumber( "gmod_maxammo" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "gmod_physiterations", "rep_gmod_physiterations", GetConVarNumber( "gmod_physiterations" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_timeout", "rep_sv_timeout", GetConVarNumber( "sv_timeout" ), false, false, "xgui_svsettings" )
	function settings.addGimp( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			ulx.addGimpSay( args[1] )
			xgui.sendDataTable( {}, "gimps" )
			settings.saveGimps()
		end
	end
	xgui.addCmd( "addGimp", settings.addGimp )
	function settings.removeGimp( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			for a, b in ipairs( ulx.gimpSays ) do
				if b == args[1] then
					table.remove( ulx.gimpSays, a )
					xgui.sendDataTable( {}, "gimps" )
					settings.saveGimps()
					return nil
				end
			end
		end
	end
	xgui.addCmd( "removeGimp", settings.removeGimp )
	function settings.saveGimps()
		local orig_file = ULib.fileRead( "data/ultra_ulx/gimps.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment
		for i, gimpSay in ipairs( ulx.gimpSays ) do
			new_file = new_file .. gimpSay .. "\n"
		end
		ULib.fileWrite( "data/ultra_ulx/gimps.txt", new_file )
	end
	function settings.addBanReason( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			ulx.addKickReason( args[1] )
			xgui.sendDataTable( {}, "banreasons" )
			settings.saveBanReasons()
		end
	end
	xgui.addCmd( "addBanReason", settings.addBanReason )
	function settings.removeBanReason( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			for a, b in ipairs( ulx.common_kick_reasons ) do
				if b == args[1] then
					table.remove( ulx.common_kick_reasons, a )
					xgui.sendDataTable( {}, "banreasons" )
					settings.saveBanReasons()
					return nil
				end
			end
		end
	end
	xgui.addCmd( "removeBanReason", settings.removeBanReason )
	function settings.saveBanReasons()
		local orig_file = ULib.fileRead( "data/ultra_ulx/banreasons.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment
		for i, banReason in ipairs( ulx.common_kick_reasons ) do
			new_file = new_file .. banReason .. "\n"
		end
		ULib.fileWrite( "data/ultra_ulx/banreasons.txt", new_file )
	end
	function settings.addAdvert( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			if args[3] == "<No Group>" then args[3] = nil end
			local color = Color( tonumber( args[4] ), tonumber( args[5] ), tonumber( args[6] ), 255 ) or nil
			ulx.addAdvert( args[1], tonumber( args[2] ), args[3], color, tonumber( args[7] ) )
			if args[8] ~= "hold" then
				xgui.sendDataTable( {}, "adverts" )
				settings.saveAdverts()
			end
		end
	end
	xgui.addCmd( "addAdvert", settings.addAdvert )
	 function settings.updateAdvert( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local group = ( args[1] == "number" ) and tonumber( args[2] ) or args[2]
			local number = tonumber( args[3] )
			local advert = ulx.adverts[group][number]
			advert.message = args[4]
			advert.rpt = tonumber( args[5] )
			advert.color = Color( tonumber( args[6] ), tonumber( args[7] ), tonumber( args[8] ), 255 )
			advert.len = tonumber( args[9] )
			xgui.sendDataTable( {}, "adverts" )
			settings.saveAdverts()
		end
	end
	xgui.addCmd( "updateAdvert", settings.updateAdvert )
	function settings.moveAdvert( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local group = ( args[1] == "number" ) and tonumber( args[2] ) or args[2]
			local number = tonumber( args[3] )
			local advert = ulx.adverts[group][number]
			table.remove( ulx.adverts[group], args[3] )
			table.insert( ulx.adverts[group], args[4], advert )
			xgui.sendDataTable( {}, "adverts" )
			settings.saveAdverts()
		end
	end
	xgui.addCmd( "moveAdvert", settings.moveAdvert )
	function settings.renameAdvertGroup( ply, args )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local old = args[1]
			local new = args[2]
			if ulx.adverts[old] then
				for k, v in pairs( ulx.adverts[old] ) do
					ulx.addAdvert( v.message, v.rpt, new, v.color, v.len )
				end
				settings.removeAdvertGroup( ply, { old, type( k ) } )
			end
		end
	end
	xgui.addCmd( "renameAdvertGroup", settings.renameAdvertGroup )
	function settings.removeAdvert( ply, args, hold )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			if args[4] == "hold" then hold = true end
			local group = ( args[3] == "number" ) and tonumber( args[1] ) or args[1]
			local number = tonumber( args[2] )
			if number == #ulx.adverts[group] then
				ulx.adverts[group].removed_last = true
			end
			table.remove( ulx.adverts[group], number )
			if #ulx.adverts[group] == 0 then
				ulx.adverts[group] = nil
				timer.Remove( "ULXAdvert" .. type( group ) .. group )
			end
			if not hold then
				xgui.sendDataTable( {}, "adverts" )
				settings.saveAdverts()
			end
		end
	end
	xgui.addCmd( "removeAdvert", settings.removeAdvert )
	function settings.removeAdvertGroup( ply, args, hold )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local group = ( args[2] == "number" ) and tonumber( args[1] ) or args[1]
			for i=#ulx.adverts[group],1,-1 do
				settings.removeAdvert( ply, { group, i, args[2] }, true )
			end
			if not hold then
				xgui.sendDataTable( {}, "adverts" )
				settings.saveAdverts()
			end
		end
	end
	xgui.addCmd( "removeAdvertGroup", settings.removeAdvertGroup )
	function settings.saveAdverts()
		local orig_file = ULib.fileRead( "data/ultra_ulx/adverts.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment
		for group_name, group_data in pairs( ulx.adverts ) do
			local output = ""
			for i, data in ipairs( group_data ) do
				if not data.len then
					output = output .. string.format( '{\n\t"text" %q\n\t"red" %q\n\t"green" %q\n\t"blue" %q\n\t"time" %q\n}\n',
						data.message, data.color.r, data.color.g, data.color.b, data.rpt )
				else
					output = output .. string.format( '{\n\t"text" %q\n\t"red" %q\n\t"green" %q\n\t"blue" %q\n\t"time_on_screen" %q\n\t"time" %q\n}\n',
						data.message, data.color.r, data.color.g, data.color.b, data.len, data.rpt )
				end
			end
			if type( group_name ) ~= "number" then
				output = string.format( "%q\n{\n\t%s}\n", group_name, output:gsub( "\n", "\n\t" ) )
			end
			new_file = new_file .. output
		end
		ULib.fileWrite( "data/ultra_ulx/adverts.txt", new_file )
	end
	util.AddNetworkString( "XGUI.AddVotemaps" )
	net.Receive( "XGUI.AddVotemaps", function( len, ply )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local maps = net.ReadTable()
			for i=1,#maps do
				table.insert( ulx.votemaps, maps[i] )
			end
			settings.saveVotemaps( GetConVar( "ulx_votemapMapmode" ):GetInt() )
			xgui.sendDataTable( {}, "votemaps" )
		end
	end )
	util.AddNetworkString( "XGUI.RemoveVotemaps" )
	net.Receive( "XGUI.RemoveVotemaps", function( len, ply )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local maps = net.ReadTable()
			if not maps then return end
			for i=1,#maps do
				for j=1,#ulx.votemaps do
					if maps[i] == ulx.votemaps[j] then
						table.remove( ulx.votemaps, j )
						break
					end
				end
			end
			settings.saveVotemaps( GetConVar( "ulx_votemapMapmode" ):GetInt() )
			xgui.sendDataTable( {}, "votemaps" )
		end
	end )
	function settings.updatevotemaps()
		settings.votemaps = {}
		for _, v in ipairs( ulx.votemaps ) do
			table.insert( settings.votemaps, v )
		end
	end
	function settings.saveVotemaps( mapmode )
		local orig_file = ULib.fileRead( "data/ultra_ulx/votemaps.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment
		if mapmode == 1 then
			for _, map in ipairs( ulx.maps ) do
				if not table.HasValue( ulx.votemaps, map ) then
					new_file = new_file .. map .. "\n"
				end
			end
		elseif mapmode == 2 then
			for _, map in ipairs( ulx.votemaps ) do
				new_file = new_file .. map .. "\n"
			end
		else
			Msg( "XGUI: Could not save votemaps- Invalid or nonexistent ulx_votemapMapmode cvar!\n" )
			return
		end
		ULib.fileWrite( "data/ultra_ulx/votemaps.txt", new_file )
		settings.updatevotemaps()
	end
	util.AddNetworkString( "XGUI.PreviewBanMessage" )
	net.Receive( "XGUI.PreviewBanMessage", function( len, ply )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local banData = {
				admin   = "Mr. Admin Man (STEAM_1:1:1111111)",
				name    = "Bob Troll",
				reason  = "Disobeying the rules",
				steamID = "STEAM_1:1:1111111",
				time    = os.time(),
				unban   = os.time() + 1654654
			}
			local templateMessage = net.ReadString():Trim()
			local message = ULib.getBanMessage( "STEAM_1:1:1111111", banData, templateMessage )
			ULib.clientRPC( ply, "xgui.handleBanPreview", message )
		end
	end)
	util.AddNetworkString( "XGUI.SaveBanMessage" )
	net.Receive( "XGUI.SaveBanMessage", function( len, ply )
		if ULib.ucl.query( ply, "xgui_svsettings" ) then
			local orig_file = ULib.fileRead( "data/ultra_ulx/banmessage.txt" )
			local comment = xgui.getCommentHeader( orig_file )
			local new_file = comment
			ULib.BanMessage = net.ReadString():Trim()
			ULib.fileWrite( "data/ultra_ulx/banmessage.txt", new_file .. ULib.BanMessage )
			xgui.sendDataTable( {}, "banmessage" )
		end
	end)
	local function updateMOTDGeneratorData(setting, data)
		local success, prev = ULib.setVar( setting, data, ulx.motdSettings )
		if (success and prev ~= data) then
			settings.saveMotdSettings()
			ulx.populateMotdData()
			ulx.motdUpdated()
			xgui.sendDataTable( {}, "motdsettings" )
		end
	end
	util.AddNetworkString( "XGUI.UpdateMotdData" )
	net.Receive( "XGUI.UpdateMotdData", function( len, ply )
		if ULib.ucl.query( ply, "ulx showmotd" ) then
			local setting = net.ReadString()
			local value = net.ReadString()
			updateMOTDGeneratorData( setting, value )
		end
	end)
	util.AddNetworkString( "XGUI.SetMotdData" )
	net.Receive( "XGUI.SetMotdData", function( len, ply )
		if ULib.ucl.query( ply, "ulx showmotd" ) then
			local setting = net.ReadString()
			local data = net.ReadTable()
			updateMOTDGeneratorData( setting, data )
		end
	end)
	function settings.saveMotdSettings()
		local orig_file = ULib.fileRead( "data/ultra_ulx/motd.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment
		local motdSave = { info=ulx.motdSettings.info, style=ulx.motdSettings.style }
		new_file = new_file .. ULib.makeKeyValues( motdSave )
		ULib.fileWrite( "data/ultra_ulx/motd.txt", new_file )
	end
end
function settings.postinit()
	settings.updatevotemaps()
	xgui.sendDataTable( {}, "adverts" )
	xgui.sendDataTable( {}, "votemaps" )
	local function votemapCvarUpdate( sv_cvar, cl_cvar, ply, old_val, new_val )
		if cl_cvar == "ulx_votemapmapmode" then
			settings.saveVotemaps( tonumber( new_val ) )
		end
	end
	hook.Add( "ULibReplicatedCvarChanged", "XGUI_CatchVotemapCvarUpdate", votemapCvarUpdate )
end
xgui.addSVModule( "settings", settings.init, settings.postinit )