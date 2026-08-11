local L = ULib.ulx_lang
local CAT = "cat_admin"
if SERVER then
	local db = ULib.getDatabase and ULib.getDatabase("ultra_ulx_admin")
	if not db then
		db = { _direct = true }
		function db:query(q, cb)
			local data = sql.Query(q)
			local err = data == false and sql.LastError() or nil
			if cb then cb(err, data) end
		end
	end
	local function esc(v)
		if v == nil then return "NULL" end
		if type(v) == "number" then return tostring(v) end
		return sql.SQLStr(tostring(v))
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
				",'mute'," .. esc(minutes > 0 and L.T("admin_timed_mute_reason", minutes) or L.T("admin_perm_mute_reason")) .. "," .. until_ts .. "," .. now() .. ",1)")
				applyMute(p, true)
				ULib.tsayColor(p, true, Color(255,100,100), "[Ultra ULX] " .. (minutes > 0 and L.T("admin_tmuted", minutes) or L.T("admin_tmuted_perm")))
			end
		end
	if should_unmute then
			ulx.fancyLogKeyed(calling_ply, "admin_unmute_log", target_plys)
		else
			ulx.fancyLogKeyed(calling_ply, "admin_mute_log", target_plys)
		end
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
			",'gag'," .. esc(minutes > 0 and L.T("admin_timed_gag_reason", minutes) or L.T("admin_perm_gag_reason")) .. "," .. until_ts .. "," .. now() .. ",1)")
				applyGag(p, true)
				ULib.tsayColor(p, true, Color(255,100,100), "[Ultra ULX] " .. (minutes > 0 and L.T("admin_tgagged", minutes) or L.T("admin_tgagged_perm")))
			end
		end
	if should_ungag then
			ulx.fancyLogKeyed(calling_ply, "admin_ungag_log", target_plys)
		else
			ulx.fancyLogKeyed(calling_ply, "admin_gag_log", target_plys)
		end
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
		reason = reason or L.T("admin_no_reason")
		db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(sid) .. "," .. esc(steamID(calling_ply)) ..
			",'warn'," .. esc(reason) .. ",0," .. now() .. ",1)")
		db:query("SELECT COUNT(*) as cnt FROM ultra_punishments WHERE steamid=" .. esc(sid) .. " AND type='warn' AND active=1",
		function(err, data)
			local count = data and data[1] and data[1].cnt or 1
			local lvl = count >= 5 and 3 or (count >= 3 and 2 or 1)
			if count >= 5 then
				ulx.banid(calling_ply, sid, 1440, L.T("admin_warn_auto_ban"))
				db:query("UPDATE ultra_punishments SET active=0 WHERE steamid=" .. esc(sid) .. " AND type='warn' AND active=1")
				ULib.tsayColor(_, true, Color(255,100,100), "[Ultra ULX] " .. L.T("admin_warn5", target_ply:Nick()))
			elseif count >= 3 then
				ulx.timedMute(calling_ply, {target_ply}, 60, false)
				ULib.tsayColor(_, true, Color(255,180,100), "[Ultra ULX] " .. L.T("admin_warn3", target_ply:Nick()))
			end
			local warn_lv_tbl = L.T("admin_warn_lv")
			if type(warn_lv_tbl) ~= "table" then
				warn_lv_tbl = {"1", "2", "3"}
			end
			ulx.fancyLogKeyed(calling_ply, "admin_warn_full_log", target_ply, warn_lv_tbl[lvl] or lvl, count, reason)
		end)
	end
	function ulx.unwarn(calling_ply, target_ply)
		local sid = steamID(target_ply)
		db:query("UPDATE ultra_punishments SET active=0 WHERE id=(SELECT id FROM ultra_punishments WHERE steamid=" ..
			esc(sid) .. " AND type='warn' AND active=1 ORDER BY created DESC LIMIT 1)", function(err)
			if not err then
				ulx.fancyLogKeyed(calling_ply, "admin_unwarn_full_log", target_ply)
			end
		end)
	end
	local reportCD = {}
	function ulx.report(calling_ply, target_ply, reason)
		if not IsValid(target_ply) then ULib.tsayError(calling_ply, L.T("admin_invalid_ply")); return end
		if target_ply == calling_ply then ULib.tsayError(calling_ply, L.T("admin_no_report_self")); return end
		local cdKey = steamID(calling_ply)
		local cd = reportCD[cdKey] or 0
		if cd > now() then
			ULib.tsayError(calling_ply, L.T("admin_report_cd", math.ceil(cd - now())))
			return
		end
		reportCD[cdKey] = now() + 60
		reason = reason or L.T("admin_default_reason")
		local msg = L.T("admin_report_format", calling_ply:Nick(), target_ply:Nick(), reason)
		for _, p in ipairs(player.GetAll()) do
			if p:IsAdmin() or p:IsSuperAdmin() then
				ULib.tsayColor(p, true, Color(255,180,60), msg)
			end
		end
		ULib.tsayColor(calling_ply, true, Color(100,200,100), "[Ultra ULX] " .. L.T("admin_report_submit"))
		db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(steamID(target_ply)) .. "," .. esc(steamID(calling_ply)) ..
			",'report'," .. esc(reason) .. ",0," .. now() .. ",1)")
	end
	function ulx.history(calling_ply, target_ply)
		local typeMap = {mute=L.T("punish_type_mute"), gag=L.T("punish_type_gag"), ban=L.T("punish_type_ban"),
			banip=L.T("punish_type_banip"), warn=L.T("punish_type_warn"), report=L.T("punish_type_report")}
		db:query("SELECT type,reason,expiry,created,active FROM ultra_punishments WHERE steamid=" .. esc(steamID(target_ply)) ..
			" ORDER BY created DESC LIMIT 20", function(err, data)
			ULib.tsayColor(calling_ply, true, Color(60,160,240), L.T("admin_history_title", target_ply:Nick()))
			if not data or #data == 0 then
				ULib.tsayColor(calling_ply, true, Color(160,160,170), L.T("admin_no_records"))
				return
			end
			for _, r in ipairs(data) do
				local st = isActive(r) and L.T("admin_status_active") or L.T("admin_status_expired")
				local tn = typeMap[r.type] or r.type
				local ds = os.date("%m-%d %H:%M", r.created)
				local us = r.expiry > 0 and (L.T("admin_expires_at") .. os.date("%m-%d %H:%M", r.expiry)) or (r.expiry == 0 and L.T("admin_perm_label") or "")
				ULib.tsayColor(calling_ply, true, Color(200,200,200), string.format("[%s] %s: %s%s (%s)", ds, tn, r.reason or "", us, st))
			end
		end)
	end
	function ulx.recordBanIP(calling_ply, ip, minutes, reason)
		local until_ts = (minutes or 0) > 0 and (now() + (minutes or 0) * 60) or 0
		db:query("INSERT INTO ultra_punishments VALUES(NULL," .. esc(ip) .. "," .. esc(steamID(calling_ply)) ..
			",'banip'," .. esc(reason or L.T("admin_banip_default")) .. "," .. until_ts .. "," .. now() .. ",1)")
	end
	local maintenanceMode = false
	function ulx.maintenance(calling_ply, should_disable)
		maintenanceMode = not should_disable
		ULib.tsayColor(_, true, maintenanceMode and Color(255,180,60) or Color(100,255,100),
			"[Ultra ULX] " .. (maintenanceMode and L.T("admin_maintenance_on") or L.T("admin_maintenance_off")))
	if maintenanceMode then
			ulx.fancyLogKeyed(calling_ply, "admin_maint_on_full_log")
		else
			ulx.fancyLogKeyed(calling_ply, "admin_maint_off_full_log")
		end
	end
	hook.Add("CheckPassword", "ULXMaintenance", function(steamid64, ip, svpw, clpw, name)
		if not maintenanceMode then return end
		local sid = util.SteamIDFrom64(steamid64)
		for _, p in ipairs(player.GetAll()) do
			if p:SteamID() == sid and (p:IsAdmin() or p:IsSuperAdmin()) then
				return
			end
		end
		return false, L.T("admin_maint_kick")
	end)
end
local muteCmd = ulx.command(CAT, "ulx tmute", ulx.timedMute, "!tmute")
muteCmd:addParam{type=ULib.cmds.PlayersArg}
muteCmd:addParam{type=ULib.cmds.TimeArg, hint=L.T("hint_admin_time"), ULib.cmds.optional}
muteCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
muteCmd:defaultAccess(ULib.ACCESS_ADMIN)
muteCmd:help(L.T("help_tmute"))
muteCmd:setOpposite("ulx untmute", {_, _, _, true}, "!untmute")
local gagCmd = ulx.command(CAT, "ulx tgag", ulx.timedGag, "!tgag")
gagCmd:addParam{type=ULib.cmds.PlayersArg}
gagCmd:addParam{type=ULib.cmds.TimeArg, hint=L.T("hint_admin_time"), ULib.cmds.optional}
gagCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
gagCmd:defaultAccess(ULib.ACCESS_ADMIN)
gagCmd:help(L.T("help_tgag"))
gagCmd:setOpposite("ulx untgag", {_, _, _, true}, "!untgag")
local warnCmd = ulx.command(CAT, "ulx warn", ulx.warn, "!warn")
warnCmd:addParam{type=ULib.cmds.PlayersArg}
warnCmd:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine, ULib.cmds.optional}
warnCmd:defaultAccess(ULib.ACCESS_ADMIN)
warnCmd:help(L.T("help_warn"))
local unwarnCmd = ulx.command(CAT, "ulx unwarn", ulx.unwarn, "!unwarn")
unwarnCmd:addParam{type=ULib.cmds.PlayersArg}
unwarnCmd:defaultAccess(ULib.ACCESS_ADMIN)
unwarnCmd:help(L.T("help_unwarn"))
local reportCmd = ulx.command(CAT, "ulx report", ulx.report, "!report")
reportCmd:addParam{type=ULib.cmds.PlayersArg}
reportCmd:addParam{type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine, ULib.cmds.optional}
reportCmd:defaultAccess(ULib.ACCESS_ALL)
reportCmd:help(L.T("help_report"))
local historyCmd = ulx.command(CAT, "ulx history", ulx.history, "!history")
historyCmd:addParam{type=ULib.cmds.PlayersArg}
historyCmd:defaultAccess(ULib.ACCESS_ADMIN)
historyCmd:help(L.T("help_history"))
local maintCmd = ulx.command(CAT, "ulx maintenance", ulx.maintenance, "!maintenance")
maintCmd:addParam{type=ULib.cmds.BoolArg, invisible=true}
maintCmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
maintCmd:help(L.T("help_maintenance"))
maintCmd:setOpposite("ulx endmaintenance", {false}, "!endmaintenance")