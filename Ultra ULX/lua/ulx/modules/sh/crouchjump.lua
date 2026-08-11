local L = ULib.ulx_lang
local CAT = "cat_movement"
if SERVER then
	util.AddNetworkString("ulx_crouchjump")
	local cjData = {}
	local function getData(ply)
		if not IsValid(ply) then return nil end
		local sid = ply:SteamID64()
		cjData[sid] = cjData[sid] or {
			active     = false,
			multiplier = 1.0,
			unlock     = true,
			crouchspeed = 1.5,
		}
		return cjData[sid]
	end
	local lastGround = {}
	local lastDuck   = {}
	hook.Add("SetupMove", "ULXCrouchJump", function(ply, mv, cmd)
		if not IsValid(ply) or not ply:Alive() then return end
		if ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() or ply:WaterLevel() > 1 then return end
		local sid      = ply:SteamID64()
		local d        = cjData[sid]
		local onGround = bit.band(ply:GetFlags(), FL_ONGROUND) == FL_ONGROUND
		local ducking  = ply:Crouching()
		local vel      = mv:GetVelocity()
		local btns     = mv:GetButtons()
		local duckIntent = bit.band(btns, IN_DUCK) ~= 0
		if d and d.active and d.multiplier > 1.0 then
			if lastGround[sid] and not onGround and lastDuck[sid] then
				local newZ = vel.z * d.multiplier
				if newZ > vel.z and newZ > 50 then
					mv:SetVelocity(Vector(vel.x, vel.y, newZ))
				end
			end
		end
		if d and d.unlock then
			local oldBtns = mv:GetOldButtons()
			local justPressedJump = bit.band(btns, IN_JUMP) ~= 0 and bit.band(oldBtns, IN_JUMP) == 0
			if onGround and ducking and justPressedJump then
				mv:RemoveKey(IN_DUCK)
			end
			if not onGround and bit.band(btns, IN_DUCK) ~= 0 then
				mv:AddKey(IN_DUCK)
			end
		end
		if d and d.crouchspeed > 1.0 and onGround and ducking then
			local hasInput = bit.band(btns, IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT) ~= 0
			if hasInput then
				mv:SetSideSpeed(mv:GetSideSpeed() * d.crouchspeed)
				mv:SetForwardSpeed(mv:GetForwardSpeed() * d.crouchspeed)
			end
		end
		lastGround[sid] = onGround
		lastDuck[sid]   = duckIntent
	end)
	local function sendSettings(targets, d)
		net.Start("ulx_crouchjump")
		net.WriteUInt(#targets, 8)
		for _, p in ipairs(targets) do net.WriteString(p:SteamID64()) end
		net.WriteBool(d.active)
		net.WriteFloat(d.multiplier)
		net.WriteBool(d.unlock)
		net.WriteFloat(d.crouchspeed)
		net.Send(targets)
	end
	function ulx.crouchjump(calling_ply, target_plys, multiplier, crouchspeed)
		multiplier  = math.Clamp(multiplier  or 2.0, 1.0, 10.0)
		crouchspeed = math.Clamp(crouchspeed or 1.5, 1.0, 5.0)
		for _, p in ipairs(target_plys) do
			local d = getData(p)
			d.active      = true
			d.multiplier  = multiplier
			d.unlock      = true
			d.crouchspeed = crouchspeed
		end
		sendSettings(target_plys, getData(target_plys[1]))
		ulx.fancyLogKeyed(calling_ply, "cj_enable_log", target_plys, multiplier, crouchspeed)
	end
	function ulx.uncrouchjump(calling_ply, target_plys)
		for _, p in ipairs(target_plys) do
			local d = getData(p)
			d.active      = false
			d.multiplier  = 1.0
			d.unlock      = false
			d.crouchspeed = 1.0
		end
		sendSettings(target_plys, {active=false, multiplier=1.0, unlock=false, crouchspeed=1.0})
		ulx.fancyLogKeyed(calling_ply, "cj_disable_log", target_plys)
	end
	local function readValidatedTargets(admin, count)
		local selectors = {}
		local seen = {}
		for _ = 1, count do
			local p = player.GetBySteamID64(net.ReadString())
			if IsValid(p) and not seen[p] then
				local id = ULib.getUniqueIDForPlayer(p)
				if id then
					selectors[#selectors + 1] = "$" .. id
					seen[p] = true
				end
			end
		end
		if #selectors == 0 then return {} end
		local parser = ULib.cmds.PlayersArg()
		local targets, err = parser:parseAndValidate(admin, table.concat(selectors, ","), { cmd = "ulx crouchjump", type = ULib.cmds.PlayersArg })
		if not targets then
			ULib.tsayError(admin, err or L.T("cmd_cannot_target_any"), true)
			return {}
		end
		return targets
	end
	net.Receive("ulx_crouchjump", function(len, ply)
		if not ply:query("ulx crouchjump") then return end
		local count = net.ReadUInt(8)
		local targets = readValidatedTargets(ply, count)
		if #targets == 0 then return end
		local active      = net.ReadBool()
		local multiplier  = net.ReadFloat()
		local unlock      = net.ReadBool()
		local crouchspeed = net.ReadFloat()
		for _, p in ipairs(targets) do
			local d = getData(p)
			d.active      = active
			d.multiplier  = multiplier
			d.unlock      = unlock
			d.crouchspeed = crouchspeed
		end
		sendSettings(targets, getData(targets[1]))
		if active then
			ulx.fancyLogKeyed(ply, "cj_apply_log", targets)
		else
			ulx.fancyLogKeyed(ply, "cj_disable_log", targets)
		end
	end)
	hook.Add("PlayerDisconnected", "ULXCrouchJumpCleanup", function(ply)
		cjData[ply:SteamID64()] = nil
		lastGround[ply:SteamID64()] = nil
		lastDuck[ply:SteamID64()] = nil
	end)
else
	net.Receive("ulx_crouchjump", function()
		local count = net.ReadUInt(8)
		for _ = 1, count do net.ReadString() end
		net.ReadBool()
		net.ReadFloat()
		net.ReadBool()
		net.ReadFloat()
	end)
end
local cjCmd = ulx.command(CAT, "ulx crouchjump", ulx.crouchjump, "!crouchjump")
cjCmd:addParam{ type = ULib.cmds.PlayersArg }
cjCmd:addParam{ type = ULib.cmds.NumArg, min = 1.0, max = 10.0, default = 2.0, hint = L.T("hint_jump_power"), ULib.cmds.optional }
cjCmd:addParam{ type = ULib.cmds.NumArg, min = 1.0, max = 5.0,  default = 1.5, hint = L.T("hint_crouch_speed"), ULib.cmds.optional }
cjCmd:defaultAccess(ULib.ACCESS_ADMIN)
cjCmd:help( L.T("help_crouchjump") )
cjCmd:setOpposite("ulx uncrouchjump", {_, _, 1.0, 1.0}, "!uncrouchjump")