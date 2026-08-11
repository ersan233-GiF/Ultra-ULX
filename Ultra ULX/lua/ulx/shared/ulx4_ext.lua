function ULib.parseTime(str)
	if not str then return 0 end
	if type(str) == "number" then return math.max(0, math.floor(str)) end
	local s = string.lower(str:Trim())
	if s == "永久" or s == "0" or s == "permanent" or s == "perm" then return 0 end
	local total = 0
	local unitMultipliers = {
		["秒"] = 1, ["s"] = 1, ["sec"] = 1, ["seconds"] = 1, ["second"] = 1,
		["分"] = 60, ["分钟"] = 60, ["m"] = 60, ["min"] = 60, ["minutes"] = 60, ["minute"] = 60,
		["小"] = 3600, ["时"] = 3600, ["小时"] = 3600, ["h"] = 3600, ["hour"] = 3600, ["hours"] = 3600,
		["天"] = 86400, ["d"] = 86400, ["day"] = 86400, ["days"] = 86400,
		["周"] = 604800, ["星期"] = 604800, ["礼拜"] = 604800, ["w"] = 604800, ["week"] = 604800, ["weeks"] = 604800,
		["月"] = 2592000, ["个月"] = 2592000, ["mo"] = 2592000, ["month"] = 2592000, ["months"] = 2592000,
	}
	for numStr, unit in s:gmatch("(%d*)%s*([^%d]+)") do
		local n = tonumber(numStr) or 1
		unit = unit:Trim():lower()
		local multiplier = unitMultipliers[unit]
		if multiplier then
			total = total + n * multiplier
		end
	end
	if total == 0 then
		local n = tonumber(s)
		if n then total = n * 60 end
	end
	return math.floor(total)
end
ULib.table = ULib.table or {}
function ULib.table.DeepCopy(t, seen)
	if type(t) ~= "table" then return t end
	seen = seen or {}
	if seen[t] then return seen[t] end
	local r = {}
	seen[t] = r
	for k, v in pairs(t) do
		r[ULib.table.DeepCopy(k, seen)] = ULib.table.DeepCopy(v, seen)
	end
	return setmetatable(r, getmetatable(t))
end
function ULib.table.Count(t)
	if not t then return 0 end
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n
end
function ULib.table.Merge(t1, t2)
	if not t2 then return t1 end
	for k, v in pairs(t2) do t1[k] = v end
	return t1
end
function ULib.table.Union(t1, t2)
	local r = {}
	for k in pairs(t1) do r[k] = true end
	for k in pairs(t2) do r[k] = true end
	return r
end
function ULib.table.Difference(t1, t2)
	local r = {}
	for k in pairs(t1) do
		if not t2[k] then r[k] = true end
	end
	return r
end
function ULib.table.Intersection(t1, t2)
	local r = {}
	for k in pairs(t1) do
		if t2[k] then r[k] = true end
	end
	return r
end
function ULib.table.FirstKey(t)
	if not t then return nil end
	for k in pairs(t) do return k end
	return nil
end
function ULib.table.Keys(t)
	local r = {}
	for k in pairs(t) do r[#r + 1] = k end
	return r
end
function ULib.table.Values(t)
	local r = {}
	for _, v in pairs(t) do r[#r + 1] = v end
	return r
end
local function registerTimeArg()
	if not ULib.cmds or not ULib.cmds.NumArg then return end
	ULib.cmds.TimeArg = inheritsFrom(ULib.cmds.NumArg)
	function ULib.cmds.TimeArg:parseAndValidate(ply, arg, cmdInfo, plyRestrictions)
		self:processRestrictions(cmdInfo, plyRestrictions)
		if not arg and table.HasValue(cmdInfo, ULib.cmds.optional) then
			arg = cmdInfo.default or 0
		end
		if arg then
			return ULib.parseTime(tostring(arg))
		end
		return 0
	end
	function ULib.cmds.TimeArg:usage(cmdInfo, plyRestrictions)
		return "<时间: 30m/1h/2d/永久>"
	end
end
if ULib.cmds and ULib.cmds.NumArg then
	registerTimeArg()
else
	hook.Add("InitPostEntity", "ULX4_RegTimeArg", registerTimeArg)
	hook.Add("ULibLocalPlayerReady", "ULX4_RegTimeArg", registerTimeArg)
end
function ULib.template(str, data)
	if not str then return "" end
	return string.gsub(str, "{(%w+)(|?([^}]*))}", function(key, _, default)
		local val = data[key]
		if val == nil then return default ~= "" and default or ("{" .. key .. "}") end
		return tostring(val)
	end)
end