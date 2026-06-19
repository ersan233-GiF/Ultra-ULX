-- ULib Hook System - 5-level priority hook library
if hook.GetULibTable then return end

local gmod = gmod
local pairs = pairs
local isfunction = isfunction
local isstring = isstring
local isnumber = isnumber
local math = math
local IsValid = IsValid

local OldHooks = hook.GetTable()
-- Preserve GMod's original hook.Call for base hooks and gamemode functions
local oldHookCall = hook.Call

-- 优先级常量（全局，兼容旧代码）
HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

local Hooks = {}
local BackwardsHooks = {}

-- Mount functions onto the global hook table (replaces module("hook"))
local hook_mt = hook
hook_mt.GetTable      = function() return BackwardsHooks end
hook_mt.GetULibTable  = function() return Hooks end
hook_mt.Add           = function(event_name, name, func, priority)
	-- 支持匿名函数：如果 name 是函数而没传 func，交换参数
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
	if not Hooks[event_name] then return end

	for i=-2, 2 do
		Hooks[event_name][i][name] = nil
	end
	BackwardsHooks[event_name][name] = nil
end

hook_mt.Run           = function(name, ...)
	return hook_mt.Call(name, gmod and gmod.GetGamemode() or nil, ...)
end
hook_mt.Call          = function(name, gm, ...)
	-- 先运行 ULib 自定义优先级钩子
	local HookTable = Hooks[name]
	if HookTable ~= nil then
		for i=-2, 2 do
			for k, v in pairs(HookTable[i]) do
				if v.isstring then
					local a, b, c, d, e, f = v.fn(...)
					if a ~= nil and i > -2 and i < 2 then
						return a, b, c, d, e, f
					end
				else
					if IsValid(k) then
						local a, b, c, d, e, f = v.fn(k, ...)
						if a ~= nil and i > -2 and i < 2 then
							return a, b, c, d, e, f
						end
					else
						HookTable[i][k] = nil
						BackwardsHooks[name][k] = nil
					end
				end
			end
		end
	end

	-- 回退到原始 hook.Call 处理 GMod 基础钩子和游戏模式函数
	if oldHookCall then
		return oldHookCall(name, gm, ...)
	end
end

-- Import existing hooks
for event_name, t in pairs(OldHooks) do
	for name, func in pairs(t) do
		hook_mt.Add(event_name, name, func)
	end
end
