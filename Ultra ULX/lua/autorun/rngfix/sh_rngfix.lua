AddCSLuaFile()
local function rngfix_Apply()
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