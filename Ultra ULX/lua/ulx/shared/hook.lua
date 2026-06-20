if hook.GetULibTable then return end
local gmod = gmod
local pairs = pairs
local isfunction = isfunction
local isstring = isstring
local isnumber = isnumber
local math = math
local IsValid = IsValid
local OldHooks = hook.GetTable()
local oldHookCall = hook.Call
local oldHookAdd = hook.Add
local oldHookRemove = hook.Remove
HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2
local Hooks = {}
local BackwardsHooks = {}
local hook_mt = hook
hook_mt.GetTable      = function() return BackwardsHooks end
hook_mt.GetULibTable  = function() return Hooks end
hook_mt.Add           = function(event_name, name, func, priority)
	if not isstring(name) then
		return oldHookAdd and oldHookAdd(event_name, name, func)
	end
	if not func and isfunction(name) then
		func = name
		name = tostring(func)
	end
	priority = priority or 0
	if not isfunction(func) then return end
	if not isstring(event_name) then return end
	if not isstring(name) then name = tostring(name) end
	if not isnumber(priority) then return end
	priority = math.floor(priority)
	if priority < -2 then priority = -2 end
	if priority > 2 then priority = 2 end
	hook_mt.Remove(event_name, name)
	if Hooks[event_name] == nil then
		Hooks[event_name] = {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
		BackwardsHooks[event_name] = {}
	end
	Hooks[event_name][priority][name] = {fn=func, isstring=true}
	BackwardsHooks[event_name][name] = func
end
hook_mt.Remove        = function(event_name, name)
	if not isstring(event_name) then return end
	if not isstring(name) then
		return oldHookRemove and oldHookRemove(event_name, name)
	end
	if not Hooks[event_name] then return end
	for i=-2, 2 do
		Hooks[event_name][i][name] = nil
	end
	BackwardsHooks[event_name][name] = nil
end
hook_mt.Run           = function(name, ...)
	return hook_mt.Call(name, gmod and gmod.GetGamemode() or GAMEMODE or nil, ...)
end
hook_mt.Call          = function(name, gm, ...)
	local HookTable = Hooks[name]
	if HookTable ~= nil then
		for i=-2, 2 do
			for k, v in pairs(HookTable[i]) do
				if v.isstring then
					local ok, a, b, c, d, e, f = pcall(v.fn, ...)
					if not ok then
						hook_mt.Remove(name, k)
						MsgC(Color(255,100,100), "[Ultra ULX] 钩子 [" .. tostring(name) .. "/" .. tostring(k) .. "] 已崩溃并自动移除: " .. tostring(a) .. "\n")
					elseif a ~= nil and i > -2 and i < 2 then
						return a, b, c, d, e, f
					end
				end
			end
		end
	end
	if oldHookCall then
		return oldHookCall(name, gm, ...)
	end
end
for event_name, t in pairs(OldHooks) do
	for name, func in pairs(t) do
		if isstring(name) then
			hook_mt.Add(event_name, name, func)
		end
	end
end
