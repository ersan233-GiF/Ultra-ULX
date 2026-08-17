local L   = ULib.ulx_lang
local CAT = "cat_movement"
local function hSpeed(v)
	return math.sqrt(v.x * v.x + v.y * v.y)
end
if SERVER then
	util.AddNetworkString("ulx_bhop")
	util.AddNetworkString("ulx_bhop_sync")
	util.AddNetworkString("ulx_bhop_state")
	local bhopCount  = 0
	local savedCvars = {}
	local REQUIRED_CVARS  = { "sv_enablebunnyhopping" }
	local REQUIRED_VALUES = { "1"                     }
	local AIRACCEL_CVAR = "sv_airaccelerate"
	local MAXSPEED_CVAR = "sv_maxspeed"
	local globalAirAccel = CreateConVar("ulx_bhop_global_airaccelerate", "1", FCVAR_ARCHIVE, "While BHop is active, tune global movement cvars (sv_airaccelerate/sv_maxspeed/gravity/stopspeed...). Set 0 to keep server defaults.")
	local airAccelValue  = CreateConVar("ulx_bhop_airaccelerate", "2000", FCVAR_ARCHIVE, "sv_airaccelerate while BHop active. CS:S=100 (classic), pro bhop servers=2000 (default). 0=don't touch.")
	local maxSpeedValue  = CreateConVar("ulx_bhop_maxspeed", "10000", FCVAR_ARCHIVE, "sv_maxspeed while BHop active (air wishspeed cap; does NOT affect walk speed). 0=don't touch.")
	local accelValue     = CreateConVar("ulx_bhop_accelerate", "5",   FCVAR_ARCHIVE, "sv_accelerate while BHop active (reference server: 5). 0=don't touch.")
	local frictionValue  = CreateConVar("ulx_bhop_friction", "4",    FCVAR_ARCHIVE, "sv_friction while BHop active (reference server: 4). 0=don't touch.")
	local stopSpeedValue = CreateConVar("ulx_bhop_stopspeed", "75",  FCVAR_ARCHIVE, "sv_stopspeed while BHop active (reference: 75, sandbox default 100). 0=don't touch.")
	local gravityValue   = CreateConVar("ulx_bhop_gravity", "800",   FCVAR_ARCHIVE, "sv_gravity while BHop active (reference: 800, sandbox default 600). 0=don't touch (gamemode controls gravity).")
	local stepSizeValue  = CreateConVar("ulx_bhop_stepsize", "18",   FCVAR_ARCHIVE, "sv_stepsize while BHop active (reference: 18). 0=don't touch.")
	local GLOBAL_SET = {
		{ AIRACCEL_CVAR, airAccelValue },
		{ MAXSPEED_CVAR, maxSpeedValue },
		{ "sv_accelerate", accelValue },
		{ "sv_friction", frictionValue },
		{ "sv_stopspeed", stopSpeedValue },
		{ "sv_gravity", gravityValue },
		{ "sv_stepsize", stepSizeValue },
	}
	local function saveAndSet(cv, value)
		if not GetConVar(cv) then return false end
		if savedCvars[cv] == nil then
			savedCvars[cv] = GetConVarString(cv) or value
		end
		RunConsoleCommand(cv, value)
		return true
	end
	local function applyGlobalCvars()
		bhopCount = bhopCount + 1
		if bhopCount ~= 1 then return end
		for i, cv in ipairs(REQUIRED_CVARS) do
			saveAndSet(cv, REQUIRED_VALUES[i])
		end
		if globalAirAccel:GetBool() then
			for _, pair in ipairs(GLOBAL_SET) do
				local v = pair[2]:GetFloat()
				if v > 0 then saveAndSet(pair[1], tostring(v)) end
			end
		end
	end
	local function restoreGlobalCvars()
		bhopCount = math.max(bhopCount - 1, 0)
		if bhopCount == 0 then
			for _, cv in ipairs(REQUIRED_CVARS) do
				if savedCvars[cv] then RunConsoleCommand(cv, savedCvars[cv]) end
			end
			if globalAirAccel:GetBool() then
				for _, pair in ipairs(GLOBAL_SET) do
					if savedCvars[pair[1]] then RunConsoleCommand(pair[1], savedCvars[pair[1]]) end
				end
			end
			savedCvars = {}
		end
	end
	hook.Add("ShutDown", "ULXBHopRestore", function()
		for _, cv in pairs(savedCvars) do
			RunConsoleCommand(cv, savedCvars[cv])
		end
		savedCvars = {}
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
	local playerPhys = {}
	local function savePhysics(ply)
		local sid = getPlayerKey(ply)
		if playerPhys[sid] then return end
		playerPhys[sid] = {
			run  = ply:GetRunSpeed(),
			walk = ply:GetWalkSpeed(),
			jump = ply:GetJumpPower(),
			grav = ply:GetGravity(),
			step = ply:GetStepSize(),
			max  = ply:GetMaxSpeed(),
		}
	end
	local function restorePhysics(ply)
		local sid = getPlayerKey(ply)
		local p = playerPhys[sid]
		if not p then return end
		ply:SetRunSpeed(p.run)
		ply:SetWalkSpeed(p.walk)
		ply:SetJumpPower(p.jump)
		ply:SetGravity(p.grav)
		ply:SetStepSize(p.step)
		ply:SetMaxSpeed(p.max)
		playerPhys[sid] = nil
	end
	local function applyPhysics(ply)
		ply:SetRunSpeed(250)
		ply:SetWalkSpeed(250)
		ply:SetJumpPower(290)
		ply:SetGravity(1)
		ply:SetStepSize(18)
		ply:SetMaxSpeed(10000)
	end
	net.Receive("ulx_bhop_sync", function(len, ply)
		if not IsValid(ply) then return end
		local sid = getPlayerKey(ply)
		local limit = active[sid]
		net.Start("ulx_bhop_state")
		net.WriteBool(limit ~= nil)
		net.WriteUInt(limit or 0, 16)
		net.Send(ply)
	end)
	function ulx.bhop(calling_ply, target_plys, speedlimit, should_disable)
		local enable = not should_disable
		speedlimit = tonumber(speedlimit) or 0
		for _, ply in ipairs(target_plys) do
			local sid = getPlayerKey(ply)
			if enable then
				if active[sid] == nil then
					savePhysics(ply)
					applyGlobalCvars()
				end
				active[sid] = speedlimit
				applyPhysics(ply)
				ULib.tsayColor(ply, true, Color(100, 255, 100),
					speedlimit > 0 and L.T("bhop_enabled_limit", speedlimit) or L.T("bhop_enabled"))
			else
				if active[sid] ~= nil then
					restorePhysics(ply)
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
	hook.Add("SetupMove", "ULXBHopPhys", function(ply, mv, cmd)
		local sid = getPlayerKey(ply)
		local limit = active[sid]
		if limit == nil then return end
		if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() then return end
		mv:SetMaxSpeed(10000)
		mv:SetMaxClientSpeed(10000)
		if ply:OnGround() then
			local buttons = mv:GetButtons()
			if bit.band(buttons, IN_SPEED) ~= 0 then
				mv:SetButtons(bit.band(buttons, bit.bnot(IN_SPEED)))
			end
		end
		if limit > 0 and bit.band(ply:GetFlags(), FL_ONGROUND) == FL_ONGROUND then
			local v = mv:GetVelocity()
			local h = math.sqrt(v.x * v.x + v.y * v.y)
			if h > limit then
				local s = limit / h
				mv:SetVelocity(Vector(v.x * s, v.y * s, v.z))
			end
		end
	end)
	hook.Add("SetupMove", "ULXBHopAuto", function(ply, mv, cmd)
		local sid = getPlayerKey(ply)
		if active[sid] == nil then return end
		if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() then return end
		if not ply:IsOnGround() and bit.band(cmd:GetButtons(), IN_JUMP) ~= 0 then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
		end
	end)
	local function ClipVelocity(vel, nrm, overbounce)
		overbounce = overbounce or 1.0
		local backoff = vel:Dot(nrm) * overbounce
		local out = vel - nrm * backoff
		local adjust = out:Dot(nrm)
		if adjust < 0 then out = out - nrm * adjust end
		return out
	end
	local lastGround, lastVel = {}, {}
	hook.Add("SetupMove", "ULXBHopSlope", function(ply, mv)
		local sid = getPlayerKey(ply)
		if active[sid] == nil then return end
		if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() then return end
		local onGround = ply:IsOnGround()
		local wasOnGround = lastGround[ply]
		local cv = mv:GetVelocity()
		local ch2 = cv.x * cv.x + cv.y * cv.y
		if onGround and not wasOnGround then
			local pos = ply:GetPos()
			local trace = util.TraceHull({
				start = pos,
				endpos = Vector(pos.x, pos.y, pos.z - 256),
				mins = ply:OBBMins(),
				maxs = ply:OBBMaxs(),
				mask = MASK_PLAYERSOLID_BRUSHONLY,
				filter = ply
			})
			if trace.Hit and trace.HitNormal.z < 1.0 and trace.HitNormal.z >= 0.7 then
				local lv = lastVel[ply]
				if lv then
					local proj = ClipVelocity(lv, trace.HitNormal)
					proj.z = 0
					if proj.x * proj.x + proj.y * proj.y > ch2 then
						mv:SetVelocity(proj)
					end
				end
			end
		end
		lastGround[ply] = onGround
		lastVel[ply] = mv:GetVelocity()
	end)
	hook.Add("PlayerSpawn", "ULXBHopSpawn", function(ply)
		if active[getPlayerKey(ply)] ~= nil then
			timer.Simple(0.1, function()
				if IsValid(ply) then applyPhysics(ply) end
			end)
		end
	end)
	hook.Add("PlayerDisconnected", "ULXBHopDisc", function(ply)
		local sid = getPlayerKey(ply)
		if active[sid] ~= nil then
			restorePhysics(ply)
			active[sid] = nil
			restoreGlobalCvars()
		end
		lastGround[ply] = nil
		lastVel[ply] = nil
		sidCache[ply] = nil
	end)
else
	local bhopActive = false
	local speedLimit = 0
	net.Receive("ulx_bhop", function()
		bhopActive = net.ReadBool()
		speedLimit = net.ReadUInt(16)
	end)
	net.Receive("ulx_bhop_state", function()
		bhopActive = net.ReadBool()
		speedLimit = net.ReadUInt(16)
	end)
	hook.Add("InitPostEntity", "ULXBHopStateSync", function()
		net.Start("ulx_bhop_sync")
		net.SendToServer()
		if not timer.Exists("ULXBHopStateSync") then
			timer.Create("ULXBHopStateSync", 3, 0, function()
				net.Start("ulx_bhop_sync")
				net.SendToServer()
			end)
		end
	end)
	hook.Add("SetupMove", "ULXBHopClient", function(ply, mv, cmd)
		if not bhopActive or ply ~= LocalPlayer() then return end
		if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK
			or ply:InVehicle() or ply:WaterLevel() > 1 then return end
		mv:SetMaxSpeed(10000)
		mv:SetMaxClientSpeed(10000)
		if ply:OnGround() then
			local buttons = mv:GetButtons()
			if bit.band(buttons, IN_SPEED) ~= 0 then
				mv:SetButtons(bit.band(buttons, bit.bnot(IN_SPEED)))
			end
		end
		if speedLimit > 0 then
			local vel = mv:GetVelocity()
			local h = hSpeed(vel)
			if h > speedLimit then
				local scale = speedLimit / h
				mv:SetVelocity(Vector(vel.x * scale, vel.y * scale, vel.z))
			end
		end
	end)
	local groundTicks = 0
	hook.Add("CreateMove", "ULXBHopCM", function(cmd)
		if not bhopActive then groundTicks = 0; return end
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() then groundTicks = 0; return end
		if ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() or ply:WaterLevel() > 1 then
			groundTicks = 0; return
		end
		if not cmd:KeyDown(IN_JUMP) then groundTicks = 0; return end
		if bit.band(ply:GetFlags(), FL_ONGROUND) == FL_ONGROUND then
			groundTicks = groundTicks + 1
			if groundTicks > 15 then
				cmd:RemoveKey(IN_JUMP)
				groundTicks = 0
			else
				cmd:AddKey(IN_JUMP)
			end
		else
			groundTicks = 0
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