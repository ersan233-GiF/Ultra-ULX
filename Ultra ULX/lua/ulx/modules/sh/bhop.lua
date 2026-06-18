-- 自动连跳 — Ultra ULX
-- 物理: Flow Network (250/250/290/0.8)  Cvar: 45.125.44.79:27807 (2000/5/4/10000)
local CAT = "移动"

if SERVER then
	util.AddNetworkString("ulx_bhop")

	-- ====== 引擎 Cvar 管理 ======
	local bhopCount = 0
	local savedCvars = {}
	local BHOP_CVARS  = { "sv_airaccelerate", "sv_accelerate", "sv_friction", "sv_gravity", "sv_maxspeed", "sv_maxvelocity" }
	local BHOP_VALUES = { "2000", "5", "4", "800", "10000", "10000" }

	local function applyCvars()
		if bhopCount == 1 then
			for i, cv in ipairs(BHOP_CVARS) do
				savedCvars[cv] = GetConVarString(cv) or ""
				RunConsoleCommand(cv, BHOP_VALUES[i])
			end
		end
	end

	local function restoreCvars()
		if bhopCount <= 0 then return end
		bhopCount = bhopCount - 1
		if bhopCount == 0 then
			for _, cv in ipairs(BHOP_CVARS) do
				if savedCvars[cv] and savedCvars[cv] ~= "" then RunConsoleCommand(cv, savedCvars[cv]) end
			end
			savedCvars = {}
		end
	end

	hook.Add("ShutDown", "ULXBHopRestore", function()
		if bhopCount > 0 then
			for i, cv in ipairs(BHOP_CVARS) do RunConsoleCommand(cv, savedCvars[cv] or BHOP_VALUES[i]) end
		end
	end)

	-- ====== 玩家物理 保存 / 应用 / 还原 ======
	local playerPhys = {}

	local function savePhysics(ply)
		local sid = ply:SteamID64()
		playerPhys[sid] = playerPhys[sid] or {}
		local p = playerPhys[sid]
		p.run  = ply:GetRunSpeed()
		p.walk = ply:GetWalkSpeed()
		p.jump = ply:GetJumpPower()
		p.grav = ply:GetGravity()
		p.step = ply:GetStepSize()
		p.maxspd = ply:GetMaxSpeed()
	end

	local function restorePhysics(ply)
		local p = playerPhys[ply:SteamID64()]
		if not p then return end
		ply:SetRunSpeed(p.run)
		ply:SetWalkSpeed(p.walk)
		ply:SetJumpPower(p.jump)
		ply:SetGravity(p.grav)
		ply:SetStepSize(p.step)
		ply:SetMaxSpeed(p.maxspd)
		playerPhys[ply:SteamID64()] = nil
	end

	local function applyPhysics(ply)
		ply:SetRunSpeed(250)
		ply:SetWalkSpeed(250)
		ply:SetJumpPower(290)
		ply:SetGravity(1)
		ply:SetStepSize(18)
		ply:SetMaxSpeed(10000)
	end

	-- ====== 连跳状态 ======
	local bhopActive = {} -- steamid64 → speedlimit (0=不限)

	-- ====== 核心函数 ======
	function ulx.bhop(calling_ply, target_plys, speedlimit, should_disable)
		local active = not should_disable
		speedlimit = tonumber(speedlimit) or 0

		for _, ply in ipairs(target_plys) do
			local sid = ply:SteamID64()

			if active then
				if bhopActive[sid] == nil then
					savePhysics(ply)
					bhopCount = bhopCount + 1
					applyCvars()
				end
				bhopActive[sid] = speedlimit
				applyPhysics(ply)
				local hint = speedlimit > 0 and (" 限速=" .. speedlimit) or " 不限速"
				ULib.tsayColor(ply, true, Color(100,255,100), "[BHop] 自动连跳已开启" .. hint .. "，按住空格即可跳跃，输入 !unbhop 可关闭")
			else
				if bhopActive[sid] ~= nil then
					restorePhysics(ply)
					bhopActive[sid] = nil
					restoreCvars()
					ULib.tsayColor(ply, true, Color(255,180,100), "[BHop] 自动连跳已关闭，移动参数已恢复")
				end
			end

			net.Start("ulx_bhop")
			net.WriteBool(active)
			net.WriteUInt(speedlimit, 16)
			net.Send(ply)
		end

		ulx.fancyLogAdmin(calling_ply, true, "#A 对 #T " .. (active and "开启" or "关闭") .. "了自动连跳", target_plys)
	end

	-- ====== Net 接收 ======
	net.Receive("ulx_bhop", function(len, ply)
		if not ply:query("ulx bhop") then return end
		local n = net.ReadUInt(8)
		local targets = {}
		for _ = 1, n do
			local p = player.GetBySteamID64(net.ReadString())
			if IsValid(p) then targets[#targets + 1] = p end
		end
		if #targets == 0 then return end

		local a = net.ReadBool()
		local sl = net.ReadUInt(16)

		for _, p in ipairs(targets) do
			local sid = p:SteamID64()
			if a then
				if bhopActive[sid] == nil then
					savePhysics(p)
					bhopCount = bhopCount + 1
					applyCvars()
				end
				bhopActive[sid] = sl
				applyPhysics(p)
			else
				if bhopActive[sid] ~= nil then
					restorePhysics(p)
					bhopActive[sid] = nil
					restoreCvars()
				end
			end
			net.Start("ulx_bhop")
			net.WriteBool(a)
			net.WriteUInt(sl, 16)
			net.Send(p)
		end
	end)

	-- ====== 限速 + 冲破 Murder 模式的 mv:SetMaxSpeed 封锁 ======
	hook.Add("SetupMove", "ULXBHopPhys", function(ply, mv)
		local sl = bhopActive[ply:SteamID64()]
		if sl == nil then return end
		if not ply:Alive() or ply:GetMoveType() ~= MOVETYPE_WALK or ply:InVehicle() then return end
		mv:SetMaxSpeed(10000)
		mv:SetMaxClientSpeed(10000)
		if sl > 0 and bit.band(ply:GetFlags(), FL_ONGROUND) == FL_ONGROUND then
			local v = mv:GetVelocity()
			local h = math.sqrt(v.x * v.x + v.y * v.y)
			if h > sl then
				local s = sl / h
				mv:SetVelocity(Vector(v.x * s, v.y * s, v.z))
			end
		end
	end)

	hook.Add("PlayerSpawn", "ULXBHopSpawn", function(ply)
		if bhopActive[ply:SteamID64()] ~= nil then
			timer.Simple(0.1, function()
				if IsValid(ply) then applyPhysics(ply) end
			end)
		end
	end)

	hook.Add("PlayerDisconnected", "ULXBHopDisc", function(ply)
		local sid = ply:SteamID64()
		if bhopActive[sid] ~= nil then
			restoreCvars()
		end
		bhopActive[sid] = nil
		playerPhys[sid] = nil
	end)

else
	-- ====== 客户端：按住空格自动跳跃 ======
	local bhopActive = false
	local groundTicks = 0

	net.Receive("ulx_bhop", function()
		bhopActive = net.ReadBool()
		net.ReadUInt(16) -- speedlimit, 客户端暂不使用
		if not bhopActive then groundTicks = 0 end
	end)

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

-- ====== 命令注册 (仿 freeze) ======
if not ulx.bhop then function ulx.bhop() end end
local bhopCmd = ulx.command(CAT, "ulx bhop", ulx.bhop, "!bhop")
bhopCmd:addParam{ type = ULib.cmds.PlayersArg }
bhopCmd:addParam{ type = ULib.cmds.NumArg, min = 0, max = 5000, default = 0, hint = "限速", ULib.cmds.optional, ULib.cmds.round }
bhopCmd:addParam{ type = ULib.cmds.BoolArg, invisible = true }
bhopCmd:defaultAccess(ULib.ACCESS_ADMIN)
bhopCmd:help("按住空格自动连跳")
bhopCmd:setOpposite("ulx unbhop", {_, _, _, true}, "!unbhop")

if not UltraULX_SilentReRegister then Msg("[ULX] 自动连跳已加载\n") end



