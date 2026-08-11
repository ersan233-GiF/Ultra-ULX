if not (ulx and ulx._ultra) then
	if SERVER then include("ulx/init.lua") else include("ulx/cl_init.lua") end
end