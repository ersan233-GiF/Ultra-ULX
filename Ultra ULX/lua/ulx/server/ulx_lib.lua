-- 设置独占命令。命令可以通过 getExclusive() 检查是否设置了独占命令，
-- 并根据结果决定是否继续处理。只有像监禁、maul 等"重要"操作才应检查和设置此标志。
function ulx.setExclusive( ply, action )
	ply.ULXExclusive = action
end

function ulx.getExclusive( target, ply )
	if not target.ULXExclusive then return end

	if target == ply then
		return "你正处于 " .. target.ULXExclusive .. " 状态!"
	else
		return target:Nick() .. " 正处于 " .. target.ULXExclusive .. " 状态!"
	end
end

function ulx.clearExclusive( ply )
	ply.ULXExclusive = nil
end

--- 不死模式。禁止玩家死亡！
function ulx.setNoDie( ply, bool )
	ULib.getSpawnInfo( ply )
	ply.ulxNoDie = bool
end

local function checkDeath( ply, weapon, killer )
	if ply.frozen then
		ULib.queueFunctionCall( function()
			if ply and ply:IsValid() then
				ply:UnLock()
				ply:Lock()
			end
		end )
	end

	if ply.ulxNoDie then
		ply:AddDeaths( -1 ) -- 不会在记分板上显示
		if killer == ply then -- 自杀
			ply:AddFrags( 1 ) -- 不会在记分板上显示
		end

		local pos = ply:GetPos()
		local ang = ply:EyeAngles()
		ULib.queueFunctionCall( function() -- 下一帧执行
			if not ply:IsValid() then return end -- 因为是定时器回调，必须确认玩家仍然有效
			ULib.spawn( ply, true )
			ply:SetPos( pos )
			ply:SetEyeAngles( ang )
		end )
		return true -- 不在 HUD 上记录死亡
	end
end
hook.Add( "PlayerDeath", "ULXCheckDeath", checkDeath, HOOK_HIGH ) -- 高优先级钩子，因为我们要阻止死亡

local function checkSuicide( ply )
	if ply.ulxNoDie then
		return false
	end
end
hook.Add( "CanPlayerSuicide", "ULXCheckSuicide", checkSuicide, HOOK_HIGH )


local function advertiseNewVersions( ply )
	if ply:IsAdmin() and not ply.ULX_UpdatesAdvertised then
		local updatesFor = {}
		for name, plugin in pairs (ULib.plugins) do
			local myBuild = tonumber( plugin.BuildNumLocal )
			local curBuild = tonumber( plugin.BuildNumRemote )
			if myBuild and curBuild and myBuild < curBuild then
				table.insert( updatesFor, name )
			end
		end
		if #updatesFor > 0 then
			ULib.tsay( ply, "[ULX] 以下插件有可用更新: " .. string.Implode( ", ", updatesFor ) )
		end
		ply.ULX_UpdatesAdvertised = true
	end
end
hook.Add( ULib.HOOK_UCLAUTH, "ULXAdvertiseUpdates", advertiseNewVersions )


function ulx.standardizeModel( model ) -- 将所有模型字符串统一为 Linux 风格路径 + 单正斜杠
	model = model:lower()
	model = model:gsub( "\\", "/" )
	model = model:gsub( "/+", "/" ) -- 合并多个正斜杠
	return model
end
