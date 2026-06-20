local CAT = "工具"
if SERVER then
	util.AddNetworkString("ulx_coordhud")
	util.AddNetworkString("ulx_coord_req")
	util.AddNetworkString("ulx_coord_data")
	local hudEnabled = {}
	function ulx.coordhud(calling_ply, target_plys, active)
		for _, p in ipairs(target_plys) do
			if active then hudEnabled[p:SteamID64()] = true else hudEnabled[p:SteamID64()] = nil end
			net.Start("ulx_coordhud"); net.WriteBool(active); net.Send(p)
		end
	end
	net.Receive("ulx_coordhud", function(len, ply)
		if not ply:query("ulx coordhud") then return end
		local n = net.ReadUInt(8)
		for _ = 1, n do
			local p = player.GetBySteamID64(net.ReadString())
			if IsValid(p) then
				if net.ReadBool() then hudEnabled[p:SteamID64()] = true else hudEnabled[p:SteamID64()] = nil end
				net.Start("ulx_coordhud"); net.WriteBool(hudEnabled[p:SteamID64()] == true); net.Send(p)
			end
		end
	end)
	hook.Add("PlayerDisconnected", "ULXCHUDClean", function(p) hudEnabled[p:SteamID64()] = nil end)
	local coordData = {}
	local function getData(ply)
		if not IsValid(ply) then return nil end
		local sid = ply:SteamID64()
		coordData[sid] = coordData[sid] or { enabled = false, mode = 1, targetSid = "" }
		return coordData[sid]
	end
	local function visibleTo(viewer, owner)
		local d = getData(owner); if not d or not IsValid(viewer) then return false end
		if viewer == owner then return true end
		if d.mode == 1 then return false end
		if d.mode == 2 then return viewer:IsAdmin() end
		if d.mode == 3 then return true end
		if d.mode == 4 then return viewer:SteamID64() == d.targetSid end
		return false
	end
	local function broadcast(target)
		local d = getData(target); if not d then return end
		for _, p in ipairs(player.GetAll()) do
			if visibleTo(p, target) then
				net.Start("ulx_coord_data")
				net.WriteEntity(target)
				net.WriteString(target:Nick())
				net.WriteBool(d.enabled)
				local pos = target:GetPos()
				net.WriteFloat(pos.x); net.WriteFloat(pos.y); net.WriteFloat(pos.z)
				net.Send(p)
			end
		end
	end
	function ulx.coord(calling_ply, target_plys, active, mode, targetSid)
		for _, p in ipairs(target_plys) do
			local d = getData(p); d.enabled = active; d.mode = mode or 1; d.targetSid = targetSid or ""
			broadcast(p)
		end
	end
	net.Receive("ulx_coord_req", function(len, ply)
		if not ply:query("ulx coord") then return end
		local n = net.ReadUInt(8); local tg = {}
		for _ = 1, n do local p = player.GetBySteamID64(net.ReadString()); if IsValid(p) then tg[#tg+1] = p end end
		if #tg == 0 then return end
		local a = net.ReadBool(); local m = net.ReadUInt(4); local ts = net.ReadString()
		for _, p in ipairs(tg) do local d = getData(p); d.enabled = a; d.mode = m; d.targetSid = ts; broadcast(p) end
	end)
	local lastPosCache = {}
	timer.Create("ULXCoordBC", 0.5, 0, function()
		for _, p in ipairs(player.GetAll()) do
			if getData(p).enabled then
				local pos = p:GetPos()
				local cache = lastPosCache[p:SteamID64()]
				if not cache or cache:DistToSqr(pos) > 1 then
					lastPosCache[p:SteamID64()] = pos
					broadcast(p)
				end
			end
		end
	end)
	hook.Add("PlayerDisconnected", "ULXCClean", function(p) coordData[p:SteamID64()] = nil end)
end
if CLIENT then
	local hudActive = false
	net.Receive("ulx_coordhud", function()
		hudActive = net.ReadBool()
		if hudActive then
			hook.Add("HUDPaint", "ULXCoordHUD", function()
				local p = LocalPlayer(); if not IsValid(p) then return end
				local pos = p:GetPos()
				local text = string.format("%.0f    %.0f    %.0f", pos.x, pos.y, pos.z)
				surface.SetFont("DermaLarge"); local tw, th = surface.GetTextSize(text)
				local x, y = (ScrW() - tw) / 2, ScrH() * 0.03
				draw.RoundedBox(8, x - 20, y - 6, tw + 40, th + 16, Color(0, 0, 0, 160))
				surface.SetTextPos(x, y); surface.SetTextColor(100, 200, 255, 240); surface.DrawText(text)
			end)
		else
			hook.Remove("HUDPaint", "ULXCoordHUD")
		end
	end)
	local headTargets = {}
	net.Receive("ulx_coord_data", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		local name   = net.ReadString()
		local active = net.ReadBool()
		if active then
			headTargets[ent] = { name = name, x = net.ReadFloat(), y = net.ReadFloat(), z = net.ReadFloat() }
		else
			headTargets[ent] = nil
		end
	end)
	hook.Add("HUDPaint", "ULXCoordOverhead", function()
		for ent, d in pairs(headTargets) do
			if IsValid(ent) and ent:Alive() then
				local sp = (Vector(d.x, d.y, d.z) + Vector(0, 0, 85)):ToScreen()
				if sp.visible then
					surface.SetFont("Default")
					local nw = surface.GetTextSize(d.name)
					local cx = sp.x - nw / 2
					draw.RoundedBox(4, cx - 3, sp.y - 16, nw + 6, 16, Color(0, 0, 0, 200))
					surface.SetTextPos(cx, sp.y - 15); surface.SetTextColor(255, 255, 255, 255); surface.DrawText(d.name)
					local ct = string.format("%.0f  %.0f  %.0f", d.x, d.y, d.z)
					local cw = surface.GetTextSize(ct)
					cx = sp.x - cw / 2
					draw.RoundedBox(4, cx - 3, sp.y + 1, cw + 6, 16, Color(0, 0, 0, 200))
					surface.SetTextPos(cx, sp.y + 2); surface.SetTextColor(255, 210, 60, 255); surface.DrawText(ct)
				end
			else
				headTargets[ent] = nil
			end
		end
	end)
end
local hudCmd = ulx.command(CAT, "ulx coordhud", ulx.coordhud, "!coordhud")
hudCmd:addParam{ type = ULib.cmds.PlayersArg, ULib.cmds.optional }
hudCmd:addParam{ type = ULib.cmds.BoolArg, invisible = true, ULib.cmds.optional }
hudCmd:defaultAccess(ULib.ACCESS_ALL)
hudCmd:help("屏幕上方半透明实时坐标 HUD，!uncoordhud 关闭")
hudCmd:setOpposite("ulx uncoordhud", {}, "!uncoordhud")
local coordCmd = ulx.command(CAT, "ulx coord", ulx.coord, "!coord")
coordCmd:addParam{ type = ULib.cmds.PlayersArg }
coordCmd:addParam{ type = ULib.cmds.BoolArg, invisible = true, ULib.cmds.optional }
coordCmd:addParam{ type = ULib.cmds.NumArg, min = 1, max = 4, default = 1, hint = "1=仅自己 2=管理员 3=公开 4=指定", ULib.cmds.optional, ULib.cmds.round }
coordCmd:addParam{ type = ULib.cmds.StringArg, hint = "指定SteamID(模式4)", ULib.cmds.optional }
coordCmd:defaultAccess(ULib.ACCESS_ADMIN)
coordCmd:help("目标头顶显示名字和实时坐标，!uncoord 关闭")
coordCmd:setOpposite("ulx uncoord", {}, "!uncoord")
coordCmd:setOpposite("ulx uncoord", {_, _, false}, "!uncoord")
if not UltraULX_SilentReRegister then Msg("[ULX] 坐标系统已加载 (coordhud + coord)\n") end
