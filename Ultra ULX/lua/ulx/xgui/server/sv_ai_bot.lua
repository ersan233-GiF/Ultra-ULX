local L = ULib.ulx_lang
local function init()
	ULib.ucl.registerAccess( "xgui_managebots", "superadmin", "允许在 XGUI 中使用 AI BOT 管理面板。", "XGUI" )
	local function getBotByUserID( userid )
		local uid = tonumber( userid )
		if not uid then return nil end
		for _, ply in ipairs( player.GetAll() ) do
			if ply:UserID() == uid and ply:IsBot() then
				return ply
			end
		end
		return nil
	end
	concommand.Add( "_xgui_bot_freeze", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			bot:Freeze( true )
			ulx.fancyLogKeyed( ply, "bot_freeze_log", bot )
		end
	end )
	concommand.Add( "_xgui_bot_unfreeze", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			bot:Freeze( false )
			ulx.fancyLogKeyed( ply, "bot_unfreeze_log", bot )
		end
	end )
	concommand.Add( "_xgui_bot_strip", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			bot:StripWeapons()
			ulx.fancyLogKeyed( ply, "bot_strip_log", bot )
		end
	end )
	concommand.Add( "_xgui_bot_hp", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		local hp = tonumber( args[2] )
		if bot and hp then
			bot:SetHealth( hp )
			ulx.fancyLogKeyed( ply, "bot_hp_log", bot, hp )
		end
	end )
	concommand.Add( "_xgui_bot_kick", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			ulx.fancyLogKeyed( ply, "bot_kick_log", bot )
		bot:Kick( L.T("community_bot_removed") )
		end
	end )
	hook.Add( "PlayerInitialSpawn", "ULXAIBotAutoStrip", function( ply )
		if ply:IsBot() then
			timer.Simple( 0.1, function()
				if IsValid( ply ) then
					ply:StripWeapons()
				end
			end )
		end
	end )
end
xgui.addSVModule( "ai_bot", init )