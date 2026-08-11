if SERVER then
	AddCSLuaFile("ulib/cl_init.lua")
	include("ulx/init.lua")
else
	include("ulx/cl_init.lua")
end