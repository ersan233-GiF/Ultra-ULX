-- Ultra ULX - Garry's Mod auto-load entry point
if SERVER then
	include("ulx/init.lua")
else
	include("ulx/cl_init.lua")
end
