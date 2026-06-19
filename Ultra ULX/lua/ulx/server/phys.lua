--[[
	Title: Physics Helpers

	Various functions to make dealing with the HL2 physics engine a little easier.
]]


--[[
	Function: applyAccel

	Parameters:

		ent - The entity to apply the acceleration to
		magnitude - The amount of acceleration ( Use nil if the magnitude is specified in the direction )
		direction - The direction to apply the acceleration in ( if the magnitude is part of the direction, specify nil for the magnitude )
		dTime - *(Optional, defaults to 1)* The time passed since the last update in seconds ( IE: 0.5 for dTime would only apply half the acceleration )
]]
function ULib.applyAccel( ent, magnitude, direction, dTime )
	if not IsValid( ent ) then return end
	if dTime == nil then dTime = 1 end

	if magnitude ~= nil then
		if direction:LengthSqr() == 0 then return end
		direction:Normalize()
	else
		magnitude = 1
	end

	-- Times it by the time elapsed since the last update.
	local accel = magnitude * dTime
	-- Convert our scalar accel to a vector accel
	accel = direction * accel

	if ent:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then
			local force = accel * phys:GetMass()
			phys:ApplyForceCenter( force )
		end
	else
		ent:SetVelocity( accel )
	end
end


--[[
	Function: applyForce

	Parameters:

		ent - The entity to apply the force to
		magnitude - The amount of force ( Use nil if the magnitude is specified in the direction )
		direction - The direction to apply the force in ( if the magnitude is part of the direction, specify nil for the magnitude )
		dTime - *(Optional, defaults to 1)* The time passed since the last update in seconds ( IE: 0.5 for dTime would only apply half the force )
]]
function ULib.applyForce( ent, magnitude, direction, dTime )
	if not IsValid( ent ) then return end
	if dTime == nil then dTime = 1 end

	if magnitude ~= nil then
		if direction:LengthSqr() == 0 then return end
		direction:Normalize()
	else
		magnitude = 1
	end

	-- Times it by the time elapsed since the last update.
	local force = magnitude * dTime
	-- Convert our scalar force to a vector force
	force = direction * force

	if ent:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then
			phys:ApplyForceCenter( force )
		end
	else
		local phys = ent:GetPhysicsObject()
		local mass = IsValid( phys ) and phys:GetMass() or 1
		local accel = force * 1/mass
		ent:SetVelocity( accel )
	end
end


--[[
	Function: applyAccelInCurDirection

	Applies an acceleration in the entities current *velocity* direction ( not the entity's heading ). See <applyAccel>.
        Basically makes the entity go faster or slower ( if a negative magnitude is passed ).

	Parameters:

		ent - The entity to apply the force to
		magnitude - The amount of acceleration
		dTime - *(Optional, defaults to 1)* The time passed since the last update in seconds ( IE: 0.5 for dTime would only apply half the acceleration )
]]
function ULib.applyAccelInCurDirection( ent, magnitude, dTime )
	local vel = ent:GetVelocity()
	if vel:LengthSqr() == 0 then return end
	local direction = vel:GetNormalized()
	ULib.applyAccel( ent, magnitude, direction, dTime )
end


--[[
	Function: applyForceInCurDirection

	Applies a force in the entities current *velocity* direction ( not the entity's heading ). See <applyForce>.
        Basically makes the entity go faster or slower ( if a negative magnitude is passed ).

	Parameters:

		ent - The entity to apply the force to
		magnitude - The amount of force
		dTime - *(Optional, defaults to 1)* The time passed since the last update in seconds ( IE: 0.5 for dTime would only apply half the force )
]]
function ULib.applyForceInCurDirection( ent, magnitude, dTime )
	local vel = ent:GetVelocity()
	if vel:LengthSqr() == 0 then return end
	local direction = vel:GetNormalized()
	ULib.applyForce( ent, magnitude, direction, dTime )
end