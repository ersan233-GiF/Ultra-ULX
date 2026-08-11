function ulx.setExclusive( ply, action )
	ply.ULXExclusive = action
end
function ulx.getExclusive( target, ply )
	if not target.ULXExclusive then return end
	if target == ply then
		return string.format(ULib.ulx_lang.T("exclusive_self_state"), target.ULXExclusive)
	else
		return string.format(ULib.ulx_lang.T("exclusive_other_state"), target:Nick(), target.ULXExclusive)
	end
end
function ulx.clearExclusive( ply )
	ply.ULXExclusive = nil
end
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
		ply:AddDeaths( -1 )
		if killer == ply then
			ply:AddFrags( 1 )
		end
		local pos = ply:GetPos()
		local ang = ply:EyeAngles()
		ULib.queueFunctionCall( function()
			if not ply:IsValid() then return end
			ULib.spawn( ply, true )
			ply:SetPos( pos )
			ply:SetEyeAngles( ang )
		end )
		return true
	end
end
hook.Add( "PlayerDeath", "ULXCheckDeath", checkDeath, HOOK_HIGH )
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
			ULib.tsay( ply, string.format(ULib.ulx_lang.T("plugin_updates_available"), table.concat( updatesFor, ", " )) )
		end
		ply.ULX_UpdatesAdvertised = true
	end
end
hook.Add( ULib.HOOK_UCLAUTH, "ULXAdvertiseUpdates", advertiseNewVersions )
function ulx.standardizeModel( model )
	model = model:lower()
	model = model:gsub( "\\", "/" )
	model = model:gsub( "/+", "/" )
	return model
end