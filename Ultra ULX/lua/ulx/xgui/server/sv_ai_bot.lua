--sv_ai_bot -- Server-side native bot control for AI Bot management tab

local function init()
	ULib.ucl.registerAccess( "xgui_managebots", "superadmin", "允许在 XGUI 中使用 AI BOT 管理面板。", "XGUI" )

	-- 辅助函数：通过 userid 获取 BOT 实体
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

	-- 冻结 BOT
	concommand.Add( "_xgui_bot_freeze", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			bot:Freeze( true )
			ulx.fancyLogAdmin( ply, "#A 冻结了 BOT #T", bot )
		end
	end )

	-- 解冻 BOT
	concommand.Add( "_xgui_bot_unfreeze", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			bot:Freeze( false )
			ulx.fancyLogAdmin( ply, "#A 解冻了 BOT #T", bot )
		end
	end )

	-- 缴械
	concommand.Add( "_xgui_bot_strip", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			bot:StripWeapons()
			ulx.fancyLogAdmin( ply, "#A 缴械了 BOT #T", bot )
		end
	end )

	-- 设置血量
	concommand.Add( "_xgui_bot_hp", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		local hp = tonumber( args[2] )
		if bot and hp then
			bot:SetHealth( hp )
			ulx.fancyLogAdmin( ply, "#A 设置了 BOT #T 血量为 #i", bot, hp )
		end
	end )

	-- 踢出 BOT
	concommand.Add( "_xgui_bot_kick", function( ply, cmd, args )
		if not ULib.ucl.query( ply, "xgui_managebots" ) then return end
		local bot = getBotByUserID( args[1] )
		if bot then
			ulx.fancyLogAdmin( ply, "#A 踢出了 BOT #T", bot )
			bot:Kick( "已被管理员移除" )
		end
	end )
	-- BOT 生成时自动去除所有武器和工具
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
