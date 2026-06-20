local CAT = "管理"
local _T = (ULib.ulx_lang and ULib.ulx_lang.T) or function(k, ...)
	local t = {
		admin_tmuted = "您已被禁言 %d 分钟",
		admin_tmuted_perm = "您已被永久禁言",
		admin_tgagged = "您已被禁聊 %d 分钟",
		admin_tgagged_perm = "您已被永久禁聊",
		admin_warn5 = "%s 警告已达5次，已自动封禁24小时",
		admin_warn3 = "%s 警告已达3次，已自动禁言1小时",
		admin_invalid_ply = "无效的玩家",
		admin_no_report_self = "不能举报自己",
		admin_report_cd = "举报冷却中，请等待 %d 秒",
		admin_report_submit = "举报已提交，管理员将尽快处理",
		admin_history_title = "===== %s 的行动记录 =====",
		admin_no_records = "无记录",
		admin_maintenance_on = "⚠ 服务器已进入维护模式",
		admin_maintenance_off = "服务器维护模式已解除",
		admin_mute_done = "禁言",
		admin_unmute_done = "解除",
		admin_gag_done = "禁聊",
		admin_ungag_done = "解除",
		admin_warn_lv = {"口头", "书面", "口头", "最终"},
		admin_warn_msg = "发出了%s警告(#%d): %s",
		admin_unwarn_msg = "撤销了一次警告",
		admin_banip_log = "IP封禁",
		admin_maint_on_log = "开启了",
		admin_maint_off_log = "关闭了",
	}
	if t[k] and ... then
		return string.format(t[k], ...)
	end
	return t[k] or k
end
if SERVER then
	util.AddNetworkString("ulx_report_notify")
	util.AddNetworkString("ulx_maintenance")
	local db = ULib.getDatabase and ULib.getDatabase("ultra_ulx_admin")
	if not db then
		db = { _direct = true }
		function db:query(q, cb)
			local data, err = sql.Query(q)
			if cb then cb(err, data) end
		end
	end
	local function esc(v)
		if v == nil then return "NULL" end
		if type(v) == "number" then return tostring(v) end
		return "'" .. sql.SQLStr(tostring(v)) .. "'"
	end
	db:query("CREATE TABLE IF NOT EXISTS ultra_punishments (id INTEGER PRIMARY KEY AUTOINCREMENT, steamid TEXT NOT NULL, admin_steamid TEXT NOT NULL, type TEXT NOT NULL, reason TEXT, expiry INTEGER DEFAULT 0, created INTEGER NOT NULL, active INTEGER DEFAULT 1)")
	db:query("CREATE INDEX IF NOT EXISTS idx_punishments_steamid ON ultra_punishments(steamid)")
	local function now() return os.time() end
	local function steamID(ply) return IsValid(ply) and ply:SteamID() or "" end
	local function isActive(row)
		return row.active == 1 and (row.expiry == 0 or row.expiry > now())
	end
	local function cleanExpired()
		db:query("UPDATE ultra_punishments SET active=0 WHERE active=1 AND expiry>0 AND expiry<=" .. now())
	end
	timer.Create("ULXCleanPunish", 300, 0, cleanExpired)
	local function applyMute(p, active)
		p.ulx_muted = active or nil
		p:SetNWBool("ulx_muted", active or false)
	end
	local function applyGag(p, active)
		p.ulx_gagged = active or nil
		p:SetNWBool("ulx_gagged", active or false)
	end
	function ulx.timedMute(calling_ply, target_plys, duration, should_unmute)
		cleanExpired()
		local minutes = type(duration) == "string" and math.ceil(ULib.parseTime(duration) / 60) or (tonumber(duration) or 60)
		local until_ts = minutes > 0 and (now() + minutes * 60) or 0
		for _, p in ipairs(target_plys) do
			if should_unmute then
				db:query("UPDATE ultra_punishments SET active=0 WHERE steamid=" .. esc(steamID(p)) .. " AND type='mute' AND active=1")
				applyMute(p, false)
			else
				db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(steamID(p)) .. "," .. esc(steamID(calling_ply)) ..
					",'mute'," .. esc(minutes > 0 and "限时禁言(" .. minutes .. "分钟)" or "永久禁言") .. "," .. until_ts .. "," .. now() .. ",1)")
				applyMute(p, true)
				ULib.tsayColor(p, true, Color(255,100,100), "[Ultra ULX] " .. (minutes > 0 and _T("admin_tmuted", minutes) or _T("admin_tmuted_perm")))
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A " .. (should_unmute and _T("admin_unmute_done") or _T("admin_mute_done")) .. "了 #T", target_plys)
	end
	function ulx.timedGag(calling_ply, target_plys, duration, should_ungag)
		cleanExpired()
		local minutes = type(duration) == "string" and math.ceil(ULib.parseTime(duration) / 60) or (tonumber(duration) or 60)
		local until_ts = minutes > 0 and (now() + minutes * 60) or 0
		for _, p in ipairs(target_plys) do
			if should_ungag then
				db:query("UPDATE ultra_punishments SET active=0 WHERE steamid=" .. esc(steamID(p)) .. " AND type='gag' AND active=1")
				applyGag(p, false)
			else
				db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(steamID(p)) .. "," .. esc(steamID(calling_ply)) ..
					",'gag'," .. esc(minutes > 0 and "限时禁聊(" .. minutes .. "分钟)" or "永久禁聊") .. "," .. until_ts .. "," .. now() .. ",1)")
				applyGag(p, true)
				ULib.tsayColor(p, true, Color(255,100,100), "[Ultra ULX] " .. (minutes > 0 and _T("admin_tgagged", minutes) or _T("admin_tgagged_perm")))
			end
		end
		ulx.fancyLogAdmin(calling_ply, "#A " .. (should_ungag and _T("admin_ungag_done") or _T("admin_gag_done")) .. "了 #T", target_plys)
	end
	hook.Add("PlayerAuthed", "ULXRestorePunish", function(ply)
		cleanExpired()
		db:query("SELECT type FROM ultra_punishments WHERE steamid=" .. esc(steamID(ply)) .. " AND active=1", function(err, data)
			if data then
				for _, row in ipairs(data) do
					if row.type == "mute" then applyMute(ply, true) end
					if row.type == "gag" then applyGag(ply, true) end
				end
			end
		end)
	end)
	hook.Add("PlayerCanHearPlayersVoice", "ULXCheckTMute", function(_, talker)
		if talker.ulx_muted then return false end
	end)
	hook.Add("PlayerSay", "ULXCheckTGag", function(ply)
		if ply.ulx_gagged then return "" end
	end)
	function ulx.warn(calling_ply, target_ply, reason)
		cleanExpired()
		local sid = steamID(target_ply)
		reason = reason or "未指定原因"
		db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(sid) .. "," .. esc(steamID(calling_ply)) ..
			",'warn'," .. esc(reason) .. ",0," .. now() .. ",1)")
		db:query("SELECT COUNT(*) as cnt FROM ultra_punishments WHERE steamid=" .. esc(sid) .. " AND type='warn' AND active=1",
		function(err, data)
			local count = data and data[1] and data[1].cnt or 1
			local lvl = count >= 5 and 3 or (count >= 3 and 2 or 1)
			if count >= 5 then
				ulx.banid(calling_ply, sid, 1440, "警告已达5次，自动封禁24小时")
				db:query("UPDATE ultra_punishments SET active=0 WHERE steamid=" .. esc(sid) .. " AND type='warn' AND active=1")
				ULib.tsayColor(_, true, Color(255,100,100), "[Ultra ULX] " .. _T("admin_warn5", target_ply:Nick()))
			elseif count >= 3 then
				ulx.timedMute(calling_ply, {target_ply}, 60, false)
				ULib.tsayColor(_, true, Color(255,180,100), "[Ultra ULX] " .. _T("admin_warn3", target_ply:Nick()))
			end
			local warn_lv_tbl = {"口头", "书面", "最终"}
			ulx.fancyLogAdmin(calling_ply, "#A 对 #T " .. _T("admin_warn_msg", warn_lv_tbl[lvl] or "", count, reason), {target_ply})
		end)
	end
	function ulx.unwarn(calling_ply, target_ply)
		local sid = steamID(target_ply)
		db:query("UPDATE ultra_punishments SET active=0 WHERE id=(SELECT id FROM ultra_punishments WHERE steamid=" ..
			esc(sid) .. " AND type='warn' AND active=1 ORDER BY created DESC LIMIT 1)", function(err)
			if not err then
				ulx.fancyLogAdmin(calling_ply, "#A " .. _T("admin_unwarn_msg") .. " #T", {target_ply})
			end
		end)
	end
	local reportCD = {}
	function ulx.report(calling_ply, target_ply, reason)
		if not IsValid(target_ply) then ULib.tsayError(calling_ply, _T("admin_invalid_ply")); return end
		if target_ply == calling_ply then ULib.tsayError(calling_ply, _T("admin_no_report_self")); return end
		local cd = reportCD[calling_ply] or 0
		if cd > now() then
			ULib.tsayError(calling_ply, _T("admin_report_cd", math.ceil(cd - now())))
			return
		end
		reportCD[calling_ply] = now() + 60
		reason = reason or "未说明原因"
		local msg = string.format("[举报] %s 举报了 %s: %s", calling_ply:Nick(), target_ply:Nick(), reason)
		for _, p in ipairs(player.GetAll()) do
			if p:IsAdmin() or p:IsSuperAdmin() then
				ULib.tsayColor(p, true, Color(255,180,60), msg)
				net.Start("ulx_report_notify"); net.WriteString(msg); net.Send(p)
			end
		end
		ULib.tsayColor(calling_ply, true, Color(100,200,100), "[Ultra ULX] " .. _T("admin_report_submit"))
		db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(steamID(target_ply)) .. "," .. esc(steamID(calling_ply)) ..
			",'report'," .. esc(reason) .. ",0," .. now() .. ",1)")
	end
	function ulx.history(calling_ply, target_ply)
		db:query("SELECT type,reason,expiry,created,active FROM ultra_punishments WHERE steamid=" .. esc(steamID(target_ply)) ..
			" ORDER BY created DESC LIMIT 20", function(err, data)
			ULib.tsayColor(calling_ply, true, Color(60,160,240), _T("admin_history_title", target_ply:Nick()))
			if not data or #data == 0 then
				ULib.tsayColor(calling_ply, true, Color(160,160,170), _T("admin_no_records"))
				return
			end
			for _, r in ipairs(data) do
				local st = isActive(r) and "有效" or "已失效"
				local tn = ({mute="禁言", gag="禁聊", ban="封禁", banip="IP封禁", warn="警告", report="举报"})[r.type] or r.type
				local ds = os.date("%m-%d %H:%M", r.created)
				local us = r.expiry > 0 and (" 到期 " .. os.date("%m-%d %H:%M", r.expiry)) or (r.expiry == 0 and " 永久" or "")
				ULib.tsayColor(calling_ply, true, Color(200,200,200), string.format("[%s] %s: %s%s (%s)", ds, tn, r.reason or "", us, st))
			end
		end)
	end
	local origBanIP = ulx.banip
	function ulx.banip(calling_ply, ip, minutes, reason)
		if origBanIP then origBanIP(calling_ply, ip, minutes, reason) end
		local until_ts = (minutes or 0) > 0 and (now() + (minutes or 0) * 60) or 0
		db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(ip) .. "," .. esc(steamID(calling_ply)) ..
			",'banip'," .. esc(reason or "IP封禁") .. "," .. until_ts .. "," .. now() .. ",1)")
	end
	local maintenanceMode = false
	function ulx.maintenance(calling_ply, should_disable)
		maintenanceMode = not should_disable
		net.Start("ulx_maintenance"); net.WriteBool(maintenanceMode); net.Broadcast()
		ULib.tsayColor(_, true, maintenanceMode and Color(255,180,60) or Color(100,255,100),
			"[Ultra ULX] " .. (maintenanceMode and _T("admin_maintenance_on") or _T("admin_maintenance_off")))
		ulx.fancyLogAdmin(calling_ply, "#A " .. (maintenanceMode and _T("admin_maint_on_log") or _T("admin_maint_off_log")) .. "服务器维护模式")
	end
	hook.Add("CheckPassword", "ULXMaintenance", function(steamid64, ip, svpw, clpw, name)
		if not maintenanceMode then return end
		local sid = util.SteamIDFrom64(steamid64)
		for _, p in ipairs(player.GetAll()) do
			if p:SteamID() == sid and (p:IsAdmin() or p:IsSuperAdmin()) then
				return
			end
		end
		return false, "服务器正在维护中，请稍后再试。"
	end)
end
local muteCmd = ulx.command(CAT, "ulx tmute", ulx.timedMute, "!tmute")
muteCmd:addParam{type=ULib.cmds.PlayersArg}
muteCmd:addParam{type=ULib.cmds.TimeArg, hint="时间(30m/1h/永久)", ULib.cmds.optional}
muteCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
muteCmd:defaultAccess(ULib.ACCESS_ADMIN)
muteCmd:help("限时禁言 (如 !tmute 玩家 30m / 1h / 永久)")
muteCmd:setOpposite("ulx untmute", {_, _, _, true}, "!untmute")
local gagCmd = ulx.command(CAT, "ulx tgag", ulx.timedGag, "!tgag")
gagCmd:addParam{type=ULib.cmds.PlayersArg}
gagCmd:addParam{type=ULib.cmds.TimeArg, hint="时间(30m/1h/永久)", ULib.cmds.optional}
gagCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
gagCmd:defaultAccess(ULib.ACCESS_ADMIN)
gagCmd:help("限时禁聊 (如 !tgag 玩家 1h / 永久)")
gagCmd:setOpposite("ulx untgag", {_, _, _, true}, "!untgag")
local warnCmd = ulx.command(CAT, "ulx warn", ulx.warn, "!warn")
warnCmd:addParam{type=ULib.cmds.PlayersArg}
warnCmd:addParam{type=ULib.cmds.StringArg, hint="原因", ULib.cmds.takeRestOfLine, ULib.cmds.optional}
warnCmd:defaultAccess(ULib.ACCESS_ADMIN)
warnCmd:help("警告玩家（3次自动禁言1h，5次自动封禁24h）")
local unwarnCmd = ulx.command(CAT, "ulx unwarn", ulx.unwarn, "!unwarn")
unwarnCmd:addParam{type=ULib.cmds.PlayersArg}
unwarnCmd:defaultAccess(ULib.ACCESS_ADMIN)
unwarnCmd:help("撤销玩家的最后一条警告")
local reportCmd = ulx.command(CAT, "ulx report", ulx.report, "!report")
reportCmd:addParam{type=ULib.cmds.PlayersArg}
reportCmd:addParam{type=ULib.cmds.StringArg, hint="原因", ULib.cmds.takeRestOfLine, ULib.cmds.optional}
reportCmd:defaultAccess(ULib.ACCESS_ALL)
reportCmd:help("举报违规玩家（管理员将收到通知）")
local historyCmd = ulx.command(CAT, "ulx history", ulx.history, "!history")
historyCmd:addParam{type=ULib.cmds.PlayersArg}
historyCmd:defaultAccess(ULib.ACCESS_ADMIN)
historyCmd:help("查询玩家的处罚记录")
local maintCmd = ulx.command(CAT, "ulx maintenance", ulx.maintenance, "!maintenance")
maintCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
maintCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
maintCmd:help("切换服务器维护模式（仅管理员可加入）")
maintCmd:setOpposite("ulx endmaintenance", {false}, "!endmaintenance")
