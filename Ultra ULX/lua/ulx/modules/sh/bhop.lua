local L   = ULib.ulx_lang
local CAT = "cat_movement"
local MAX_SPEED = 10000
local function hSpeed(v)
	return math.sqrt(v.x * v.x + v.y * v.y)
end
if SERVER then
	util.AddNetworkString("ulx_bhop")
	local bhopCount  = 0
	local savedCvars = {}
	local BHOP_CVARS  = { "sv_airaccelerate" }
	local BHOP_VALUES = { "300"              }
	local globalAirAccel = CreateConVar("ulx_bhop_global_airaccelerate", "0", FCVAR_ARCHIVE, "Legacy mode: temporarily set sv_airaccelerate globally while ULX BHop is active.")
	local function applyGlobalCvars()
		bhopCount = bhopCount + 1
		if globalAirAccel:GetBool() and bhopCount == 1 then
			for i, cv in ipairs(BHOP_CVARS) do
				savedCvars[cv] = GetConVarString(cv) or BHOP_VALUES[i]
				RunConsoleCommand(cv, BHOP_VALUES[i])
			end
		end
	end
	local function restoreGlobalCvars()
		bhopCount = math.max(bhopCount - 1, 0)
		if bhopCount == 0 then
			for _, cv in ipairs(BHOP_CVARS) do
				if savedCvars[cv] then RunConsoleCommand(cv, savedCvars[cv]) end
			end
			savedCvars = {}
		end
	end
	hook.Add("ShutDown", "ULXBHopRestore", function()
		if bhopCount > 0 then
			for _, cv in ipairs(BHOP_CVARS) do
				if savedCvars[cv] then RunConsoleCommand(cv, savedCvars[cv]) end
			end
		end
	end)
	local active   = {}
	local sidCache = {}
	local function getPlayerKey(ply)
		local sid = sidCache[ply]
		if sid then return sid end
		if ply:IsBot() then
			sid = "BOT:" .. ply:UserID()
		else
			sid = ply:SteamID64()
			if not sid or sid == "" or sid == "0" then sid = ply:SteamID() end
			if not sid or sid == "" then sid = tostring(ply:UserID()) end
		end
		sidCache[ply] = sid
		return sid
	end
	function ulx.bhop(calling_ply, target_plys, speedlimit, should_disable)
		local enable = not should_disable
		speedlimit = tonumber(speedlimit) or 0
		for _, ply in ipairs(target_plys) do
			local sid = getPlayerKey(ply)
			if enable then
				if active[sid] == nil then
					applyGlobalCvars()
				end
				active[sid] = speedlimit
				ULib.tsayColor(ply, true, Color(100, 255, 100),
					speedlimit > 0 and L.T("bhop_enabled_limit", speedlimit) or L.T("bhop_enabled"))
			else
				if active[sid] ~= nil then
					active[sid] = nil
					restoreGlobalCvars()
					ULib.tsayColor(ply, true, Color(255, 180, 100), L.T("bhop_disabled"))
				end
			end
			net.Start("ulx_bhop")
			net.WriteBool(enable)
			net.WriteUInt(speedlimit, 16)
			net.Send(ply)
		end
		ulx.fancyLogKeyedSilent(calling_ply, enable and "bhop_enable_log" or "bhop_disable_log", target_plys)
	end
	local function validateXGUITargets(admin, steamIDs)
		local selectors = {}
		local seen = {}
		for _, sid64 in ipairs(steamIDs) do
			local ply = player.GetBySteamID64(sid64)
			if IsValid(ply) and not seen[ply] then
				local id = ULib.getUniqueIDForPlayer(ply)
				if id then
					selectors[#selectors + 1] = "$" .. id
					seen[ply] = true
				end
			end
		end
		if #selectors == 0 then return {} end
		local parser = ULib.cmds.PlayersArg()
		local targets, err = parser:parseAndValidate(admin, table.concat(selectors, ","), { cmd = "ulx bhop", type = ULib.cmds.PlayersArg })
		if not targets then
			ULib.tsayError(admin, err or L.T("cmd_cannot_target_any"), true)
			return {}
		end
		return targets
	end
	hook.Add("SetupMove", "ULXBHop", function(ply, mv, cmd)
		local sid = getPlayerKey(ply)
		local limit = active[sid]
		if limit == nil then return end
		if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK
			or ply:InVehicle() or ply:WaterLevel() > 1 then return end
		mv:SetMaxSpeed(MAX_SPEED)
		mv:SetMaxClientSpeed(MAX_SPEED)
		if ply:OnGround() then
			local buttons = mv:GetButtons()
			if bit.band(buttons, IN_SPEED) ~= 0 then
				mv:SetButtons(bit.band(buttons, bit.bnot(IN_SPEED)))
			end
		end
		if limit > 0 then
			local vel = mv:GetVelocity()
			local h = hSpeed(vel)
			if h > limit then
				local scale = limit / h
				mv:SetVelocity(Vector(vel.x * scale, vel.y * scale, vel.z))
			end
		end
	end)
	hook.Add("PlayerDisconnected", "ULXBHopDisc", function(ply)
		local sid = getPlayerKey(ply)
		if active[sid] ~= nil then
			active[sid] = nil
			restoreGlobalCvars()
		end
		sidCache[ply] = nil
	end)
else
	local bhopActive = false
	net.Receive("ulx_bhop", function()
		bhopActive = net.ReadBool()
		net.ReadUInt(16)
	end)
	hook.Add("CreateMove", "ULXBHopCM", function(cmd)
		if not bhopActive then return end
		if not cmd:KeyDown(IN_JUMP) then return end
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() then return end
		if ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() or ply:WaterLevel() > 1 then
			return
		end
		if ply:OnGround() then
			cmd:AddKey(IN_JUMP)
		else
			cmd:RemoveKey(IN_JUMP)
		end
	end)
end
if not ulx.bhop then function ulx.bhop() end end
local bhopCmd = ulx.command(CAT, "ulx bhop", ulx.bhop, "!bhop")
bhopCmd:addParam{ type = ULib.cmds.PlayersArg }
bhopCmd:addParam{ type = ULib.cmds.NumArg, min = 0, max = 5000, default = 0, hint = L.T("hint_speedlimit"), ULib.cmds.optional, ULib.cmds.round }
bhopCmd:addParam{ type = ULib.cmds.BoolArg, invisible = true }
bhopCmd:defaultAccess(ULib.ACCESS_ADMIN)
bhopCmd:help(L.T("cmd_bhop_help"))
bhopCmd:setOpposite("ulx unbhop", {_, _, _, true}, "!unbhop")
if not ulx._silentReReg then Msg(L.T("bhop_loaded") .. "\n") end