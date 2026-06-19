-- RNG Fix: Prevents broken spawns and NAN damage from faulty randomization
-- Original by justa, adapted for Ultra ULX

AddCSLuaFile()

-- Hook into InitPostEntity and apply fixes
local function rngfix_Apply()
	-- Fix Convars that cause NaN issues
	local fixCvars = {
		"sv_massreport", "sv_minrate", "sv_minupdaterate",
		"sv_mincmdrate", "phys_pushscale"
	}
	for _, cv in ipairs(fixCvars) do
		local val = GetConVarString(cv)
		if val and (val == "nan" or val == "inf" or tonumber(val) ~= tonumber(val)) then
			RunConsoleCommand(cv, "0")
		end
	end
end
hook.Add("InitPostEntity", "RngFixApply", rngfix_Apply)
hook.Add("OnGamemodeLoaded", "RngFixApply", rngfix_Apply)