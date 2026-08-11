local function rngfix_Apply()
	local fixCvars = {
		sv_massreport    = "0",
		sv_minrate       = "0",
		sv_minupdaterate = "0",
		sv_mincmdrate    = "0",
		phys_pushscale   = "1",
	}
	for cv, default in pairs(fixCvars) do
		local val = GetConVarString(cv)
		local n = tonumber(val)
		if val and (val:lower():find("nan") or val:lower():find("inf") or not n or n ~= n) then
			RunConsoleCommand(cv, default)
		end
	end
end
hook.Add("InitPostEntity", "RngFixApply", rngfix_Apply)
hook.Add("OnGamemodeLoaded", "RngFixApply", rngfix_Apply)