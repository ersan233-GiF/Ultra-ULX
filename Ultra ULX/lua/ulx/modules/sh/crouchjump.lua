-- 蹲跳增强 — 跳力倍率 + 蹲姿解锁 + 蹲走加速 -- Ultra ULX
-- 解决 Source 引擎三大蹲姿问题:
--   1. 蹲着按空格跳不起来 (引擎需要先站直)
--   2. 原地蹲下再走龟速 (加速到 0.34x 极速太慢)
--   3. 蹲跳高度不足
local CAT = "移动"

if SERVER then
	util.AddNetworkString("ulx_crouchjump")

	local cjData = {}
	local function getData(ply)
		if not IsValid(ply) then return nil end
		local sid = ply:SteamID64()
		cjData[sid] = cjData[sid] or {
			active     = false,
			multiplier = 1.0,   -- 蹲跳 Z 轴力度倍率
			unlock     = true,   -- 蹲姿跳跃解锁
			crouchspeed = 1.5,   -- 蹲姿地面移速倍率 (1.0=默认0.34x, 1.5=0.51x走路速度)
		}
		return cjData[sid]
	end

	local lastGround = {}
	local lastDuck   = {}

	hook.Add("SetupMove", "ULXCrouchJump", function(ply, mv, cmd)
		if not IsValid(ply) or not ply:Alive() then return end
		if ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() or ply:WaterLevel() > 1 then return end

		local sid      = ply:SteamID64()
		local d        = cjData[sid]  -- 可能为 nil (未启用)
		local onGround = bit.band(ply:GetFlags(), FL_ONGROUND) == FL_ONGROUND
		local ducking  = ply:Crouching()
		local vel      = mv:GetVelocity()
		local btns     = mv:GetButtons()

		-- ===== 蹲跳倍率增强 =====
		if d and d.active and d.multiplier > 1.0 then
			if lastGround[sid] and not onGround and lastDuck[sid] then
				local newZ = vel.z * d.multiplier
				if newZ > vel.z and newZ > 50 then
					mv:SetVelocity(Vector(vel.x, vel.y, newZ))
				end
			end
		end

		-- ===== 蹲姿跳跃解锁 =====
		if d and d.unlock then
			local oldBtns = mv:GetOldButtons()
			local justPressedJump = bit.band(btns, IN_JUMP) ~= 0 and bit.band(oldBtns, IN_JUMP) == 0
			if onGround and ducking and justPressedJump then
				mv:RemoveKey(IN_DUCK)
			end
			if not onGround and bit.band(btns, IN_DUCK) ~= 0 then
				cmd:AddKey(IN_DUCK)
			end
		end

		-- ===== 蹲走加速: 修复"原地蹲下移动龟速"问题 =====
		-- Source 的蹲姿移速上限 = 走路速度 × 0.34, 但加速度和走路一样
		-- 所以从 0 加速到蹲姿上限非常慢。这里给蹲走加一个地面加速倍率。
		if d and d.crouchspeed > 1.0 and onGround and ducking then
			local hasInput = bit.band(btns, IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT) ~= 0
			if hasInput then
				mv:SetSideSpeed(mv:GetSideSpeed() * d.crouchspeed)
				mv:SetForwardSpeed(mv:GetForwardSpeed() * d.crouchspeed)
			end
		end

		lastGround[sid] = onGround
		lastDuck[sid]   = ducking
	end)

	-- ===== 发送设置到客户端 =====
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

	-- ===== 命令 =====
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
		ulx.fancyLogAdmin(calling_ply, string.format("#A 启用了 #T 的蹲跳增强 (%.1fx跳力 + 蹲姿解锁 + %.1fx蹲速)",
			multiplier, crouchspeed), target_plys)
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
		ulx.fancyLogAdmin(calling_ply, "#A 关闭了 #T 的蹲跳增强", target_plys)
	end

	-- 客户端 XGUI → 服务端
	net.Receive("ulx_crouchjump", function(len, ply)
		if not ply:query("ulx crouchjump") then return end
		local count = net.ReadUInt(8)
		local targets = {}
		for _ = 1, count do
			local p = player.GetBySteamID64(net.ReadString())
			if IsValid(p) then table.insert(targets, p) end
		end
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
			ulx.fancyLogAdmin(ply, "#A 应用了蹲跳参数", targets)
		else
			ulx.fancyLogAdmin(ply, "#A 关闭了蹲跳增强", targets)
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
		for _ = 1, count do net.ReadString(); net.ReadBool(); net.ReadFloat(); net.ReadBool(); net.ReadFloat() end
	end)
end

-- ====== 命令注册 ======
local cjCmd = ulx.command(CAT, "ulx crouchjump", ulx.crouchjump, "!crouchjump")
cjCmd:addParam{ type = ULib.cmds.PlayersArg }
cjCmd:addParam{ type = ULib.cmds.NumArg, min = 1.0, max = 10.0, default = 2.0, hint = "跳力倍率", ULib.cmds.optional }
cjCmd:addParam{ type = ULib.cmds.NumArg, min = 1.0, max = 5.0,  default = 1.5, hint = "蹲走速度倍率", ULib.cmds.optional }
cjCmd:defaultAccess(ULib.ACCESS_ADMIN)
cjCmd:help("蹲跳增强: 跳力倍率(默认2x) + 蹲姿解锁 + 蹲走速度(默认1.5x)。解决蹲跳不起/蹲走龟速/蹲锁跳。!uncrouchjump 关闭。")
cjCmd:setOpposite("ulx uncrouchjump", {_, _, 1.0, 1.0}, "!uncrouchjump")
