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
local _G = _G

module("hook")

-- 挂载优先级常量到 hook 命名空间（避免全局污染）
HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

-- 为向后兼容保留全局别名
_G.HOOK_MONITOR_HIGH = HOOK_MONITOR_HIGH
_G.HOOK_HIGH = HOOK_HIGH
_G.HOOK_NORMAL = HOOK_NORMAL
_G.HOOK_LOW = HOOK_LOW
_G.HOOK_MONITOR_LOW = HOOK_MONITOR_LOW

local Hooks = {}
local BackwardsHooks = {}

function GetTable() return BackwardsHooks end
function GetULibTable() return Hooks end

function Add(event_name, name, func, priority)
	priority = priority or 0
	if not isfunction(func) then return end
	if not isstring(event_name) then return end
	if not isnumber(priority) then return end

	priority = math.floor(priority)
	if priority < -2 then priority = -2 end
	if priority > 2 then priority = 2 end

	Remove(event_name, name)

	if Hooks[event_name] == nil then
		Hooks[event_name] = {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
		BackwardsHooks[event_name] = {}
	end

	Hooks[event_name][priority][name] = {fn=func, isstring=isstring(name)}
	BackwardsHooks[event_name][name] = func
end

function Remove(event_name, name)
	if not isstring(event_name) then return end
	if not Hooks[event_name] then return end

	for i=-2, 2 do
		Hooks[event_name][i][name] = nil
	end
	BackwardsHooks[event_name][name] = nil
end

local currentGM

function Run(name, ...)
	if not currentGM then
		currentGM = gmod and gmod.GetGamemode() or nil
	end
	return Call(name, currentGM, ...)
end

function Call(name, gm, ...)
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

	if not gm then return end
	local GamemodeFunction = gm[name]
	if GamemodeFunction == nil then return end
	return GamemodeFunction(gm, ...)
end

-- Import existing hooks
for event_name, t in pairs(OldHooks) do
	for name, func in pairs(t) do
		Add(event_name, name, func)
	end
end
