function ULib.applyAccel( ent, magnitude, direction, dTime )
	if not IsValid( ent ) then return end
	if dTime == nil then dTime = 1 end
	if magnitude ~= nil then
		if direction:LengthSqr() == 0 then return end
		direction:Normalize()
	else
		magnitude = 1
	end
	local accel = magnitude * dTime
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
function ULib.applyForce( ent, magnitude, direction, dTime )
	if not IsValid( ent ) then return end
	if dTime == nil then dTime = 1 end
	if magnitude ~= nil then
		if direction:LengthSqr() == 0 then return end
		direction:Normalize()
	else
		magnitude = 1
	end
	local force = magnitude * dTime
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
function ULib.applyAccelInCurDirection( ent, magnitude, dTime )
	local vel = ent:GetVelocity()
	if vel:LengthSqr() == 0 then return end
	local direction = vel:GetNormalized()
	ULib.applyAccel( ent, magnitude, direction, dTime )
end
function ULib.applyForceInCurDirection( ent, magnitude, dTime )
	local vel = ent:GetVelocity()
	if vel:LengthSqr() == 0 then return end
	local direction = vel:GetNormalized()
	ULib.applyForce( ent, magnitude, direction, dTime )
end