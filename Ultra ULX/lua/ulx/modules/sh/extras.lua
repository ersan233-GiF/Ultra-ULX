-- 实用扩展命令模块 (基于 ULib API 构建)
-- cleanup / respawn / setmodel / setteam / giveweapon / scale / gravity
local CATEGORY_NAME = "工具"

------------------------------ Cleanup ------------------------------
if SERVER then
	function ulx.cleanup( calling_ply )
		game.CleanUpMap( false, { "player", "prop_vehicle*" } )
		ulx.fancyLogAdmin( calling_ply, "#A 清理了地图上的所有道具和NPC" )
	end
end
local cleanupCmd = ulx.command( CATEGORY_NAME, "ulx cleanup", ulx.cleanup, "!cleanup" )
cleanupCmd:defaultAccess( ULib.ACCESS_ADMIN )
cleanupCmd:help( "清理地图上的所有道具、布娃娃、NPC和散落武器。" )

------------------------------ Respawn ------------------------------
if SERVER then
	function ulx.respawn( calling_ply, target_plys )
		local affected = {}
		for _, ply in ipairs( target_plys ) do
			if not ply:Alive() then
				ply:UnSpectate()
				local teamId = ply:Team()
				if teamId == TEAM_SPECTATOR or teamId == TEAM_UNASSIGNED then
					for tid, _ in pairs( team.GetAllTeams() ) do
						if tid ~= TEAM_SPECTATOR and tid ~= TEAM_UNASSIGNED then
							ply:SetTeam( tid )
							break
						end
					end
				end
				if ROLE_INNOCENT and ply.SetRole then
					pcall( ply.SetRole, ply, ROLE_INNOCENT )
				end
				if ply.SetSubRole then
					pcall( ply.SetSubRole, ply, 1 )
				end
				ply:Spawn()
				table.insert( affected, ply )
			end
		end
		if #affected > 0 then
			ulx.fancyLogAdmin( calling_ply, "#A 复活了 #T", affected )
		else
			ULib.tsayError( calling_ply, "目标玩家已经存活，无需复活。", true )
		end
	end
end
local respawnCmd = ulx.command( CATEGORY_NAME, "ulx respawn", ulx.respawn, "!respawn" )
respawnCmd:addParam{ type=ULib.cmds.PlayersArg }
respawnCmd:defaultAccess( ULib.ACCESS_ADMIN )
respawnCmd:help( "复活目标玩家。" )

------------------------------ SetModel ------------------------------
if SERVER then
	function ulx.setmodel( calling_ply, target_plys, model_path )
		model_path = ulx.standardizeModel( model_path )
		if not util.IsValidModel( model_path ) then
			ULib.tsayError( calling_ply, "无效的模型路径: " .. model_path, true )
			return
		end
		for _, ply in ipairs( target_plys ) do
			ply:SetModel( model_path )
		end
		ulx.fancyLogAdmin( calling_ply, "#A 设置了 #T 的模型为 #s", target_plys, model_path )
	end
end
local setmodelCmd = ulx.command( CATEGORY_NAME, "ulx setmodel", ulx.setmodel, "!setmodel" )
setmodelCmd:addParam{ type=ULib.cmds.PlayersArg }
setmodelCmd:addParam{ type=ULib.cmds.StringArg, hint="模型路径", ULib.cmds.takeRestOfLine }
setmodelCmd:defaultAccess( ULib.ACCESS_ADMIN )
setmodelCmd:help( "设置目标玩家的模型。例如: ulx setmodel ^ models/player/alyx.mdl" )

------------------------------ SetTeam ------------------------------
if SERVER then
	function ulx.setteam( calling_ply, target_plys, team_id )
		team_id = tonumber( team_id )
		if not team_id then
			ULib.tsayError( calling_ply, "请指定有效的队伍编号。", true )
			return
		end
		local affected = {}
		for _, ply in ipairs( target_plys ) do
			if ply:Team() ~= team_id then
				ply:SetTeam( team_id )
				table.insert( affected, ply )
			end
		end
		if #affected > 0 then
			ulx.fancyLogAdmin( calling_ply, "#A 将 #T 切换到队伍 #i", affected, team_id )
		end
	end
end
local setteamCmd = ulx.command( CATEGORY_NAME, "ulx setteam", ulx.setteam, "!setteam" )
setteamCmd:addParam{ type=ULib.cmds.PlayersArg }
setteamCmd:addParam{ type=ULib.cmds.NumArg, min=1, max=32, hint="队伍编号", ULib.cmds.round }
setteamCmd:defaultAccess( ULib.ACCESS_ADMIN )
setteamCmd:help( "强制切换目标玩家的队伍。" )

------------------------------ GiveWeapon ------------------------------
if SERVER then
	function ulx.giveweapon( calling_ply, target_plys, weapon_class )
		weapon_class = weapon_class:lower()
		if not weapon_class:find( "^weapon_" ) and not weapon_class:find( "^gmod_" ) then
			weapon_class = "weapon_" .. weapon_class
		end
		local testWep = weapons.GetStored( weapon_class )
		if not testWep then
			ULib.tsayError( calling_ply, "无效的武器类名: " .. weapon_class, true )
			return
		end
		local affected = {}
		for _, ply in ipairs( target_plys ) do
			if ply:Alive() then
				ply:Give( weapon_class )
				table.insert( affected, ply )
			end
		end
		if #affected > 0 then
			ulx.fancyLogAdmin( calling_ply, "#A 给予了 #T 武器 #s", affected, weapon_class )
		end
	end
end
local giveweaponCmd = ulx.command( CATEGORY_NAME, "ulx giveweapon", ulx.giveweapon, "!giveweapon" )
giveweaponCmd:addParam{ type=ULib.cmds.PlayersArg }
giveweaponCmd:addParam{ type=ULib.cmds.StringArg, hint="武器类名", ULib.cmds.takeRestOfLine }
giveweaponCmd:defaultAccess( ULib.ACCESS_ADMIN )
giveweaponCmd:help( "给予目标玩家指定武器。例如: ulx giveweapon ^ crowbar" )

------------------------------ Scale ------------------------------
if SERVER then
	util.AddNetworkString( "ulx_scale_sync" )
	ulx_playerscales = ulx_playerscales or {}; hook.Add("PlayerDisconnected", "ULXScaleCleanup", function(p) ulx_playerscales[p:SteamID64()] = nil end)

	local function applyScale( ply, scale_val )
		scale_val = math.Clamp( scale_val, 0.1, 10 )
		ply:SetModelScale( scale_val, 0 )
		-- 视角始终等比同步
		ply:SetViewOffset( Vector( 0, 0, 64 * scale_val ) )
		ply:SetViewOffsetDucked( Vector( 0, 0, 28 * scale_val ) )
		if scale_val > 1 then
			ply:SetJumpPower( 200 * scale_val )
			ply:SetGravity( 2.0 - scale_val / 10 )
			ply:SetWalkSpeed( 200 * scale_val )
			ply:SetRunSpeed( 400 * scale_val )
		else
			ply:SetJumpPower( 200 )
			ply:SetGravity( 1 )
			ply:SetWalkSpeed( 200 )
			ply:SetRunSpeed( 400 )
		end
		net.Start( "ulx_scale_sync" )
		net.WriteFloat( scale_val )
		net.Send( ply )
	end

	function ulx.scale( calling_ply, target_plys, scale_val )
		scale_val = math.Clamp( scale_val, 0.1, 10 )
		for _, ply in ipairs( target_plys ) do
			ulx_playerscales[ ply:SteamID64() ] = scale_val
			applyScale( ply, scale_val )
		end
		ulx.fancyLogAdmin( calling_ply, "#A 将 #T 的体型缩放设为 #i", target_plys, scale_val )
	end

	-- 死亡复活后恢复缩放属性 (仅已缩放过)
	hook.Add( "PlayerSpawn", "ULXScaleRespawn", function( ply )
		local scale = ulx_playerscales[ ply:SteamID64() ]
		if scale and scale ~= 1 then
			timer.Simple( 0.1, function()
				if ply:IsValid() then applyScale( ply, scale ) end
			end )
		end
		-- 未缩放的玩家不做任何修改, 保持游戏模式原始速度
	end )

	-- 等比提升摔落伤害生效距离，并消除低于阈值的落地抖动
	hook.Add( "GetFallDamage", "ULXScaleFall", function( ply, speed )
		local scale = ulx_playerscales[ ply:SteamID64() ]
		if scale and scale > 1 then
			local s = speed / scale  -- 相对速度
			local safeSpeed = 350    -- 基准安全速度
			if s < safeSpeed then return 0 end
			return ( s - safeSpeed ) * ( 100 / 350 )
		end
	end )
	hook.Add( "OnPlayerHitGround", "ULXScaleHitGround", function( ply, inWater, onFloater, speed )
		local scale = ulx_playerscales[ ply:SteamID64() ]
		if scale and scale > 1 and speed / scale < 350 then
			return true -- 抑制落地音效和屏幕抖动
		end
	end )
end
local scaleCmd = ulx.command( CATEGORY_NAME, "ulx scale", ulx.scale, "!scale" )
scaleCmd:addParam{ type=ULib.cmds.PlayersArg }
scaleCmd:addParam{ type=ULib.cmds.NumArg, min=0.1, max=10, default=1, hint="缩放倍率" }
scaleCmd:defaultAccess( ULib.ACCESS_ADMIN )
scaleCmd:help( "调整目标玩家的体型大小 (0.1~10)。" )

------------------------------ Gravity ------------------------------
if SERVER then
	function ulx.setgravity( calling_ply, target_plys, grav )
		grav = math.Clamp( grav, 0, 6 )
		for _, ply in ipairs( target_plys ) do
			ply:SetGravity( grav )
		end
		ulx.fancyLogAdmin( calling_ply, "#A 将 #T 的重力设为 #i", target_plys, grav )
	end
end
local gravityCmd = ulx.command( CATEGORY_NAME, "ulx gravity", ulx.setgravity, "!gravity" )
gravityCmd:addParam{ type=ULib.cmds.PlayersArg }
gravityCmd:addParam{ type=ULib.cmds.NumArg, min=0, max=6, default=1, hint="重力倍率" }
gravityCmd:defaultAccess( ULib.ACCESS_ADMIN )
gravityCmd:help( "设置目标玩家的重力倍率 (0=无重力, 1=正常, 最大6)。" )

if not UltraULX_SilentReRegister then Msg( "[ULX] 扩展命令模块已加载 (cleanup/respawn/setmodel/setteam/giveweapon/scale/gravity)\n" ) end

-- 客户端：接收体型缩放值
if CLIENT then
	ulx_playerscale = ulx_playerscale or 1
	net.Receive( "ulx_scale_sync", function()
		ulx_playerscale = net.ReadFloat()
	end )
end
