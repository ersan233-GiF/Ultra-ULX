local meta = FindMetaTable( "Entity" )
if not meta then return end
ULib.delWhitelist =
{
	"colour",
	"material",
	"paint",
	"hoverball",
	"emitter",
	"elastic",
	"hydraulic",
	"muscle",
	"nail",
	"ballsocket",
	"ballsocket_adv",
	"pulley",
	"rope",
	"slider",
	"weld",
	"winch",
	"balloon",
	"button",
	"duplicator",
	"dynamite",
	"keepupright",
	"lamp",
	"nocollide",
	"thruster",
	"turret",
	"wheel",
	"eyeposer",
	"faceposer",
	"statue",
	"weld_ez",
	"axis",
	"gravity",
	"collision",
	"persist",
}
ULib.moveWhitelist =
{
	"colour",
	"material",
	"paint",
	"duplicator",
	"eyeposer",
	"faceposer",
	"remover",
	"persist",
}
function meta:DisallowMoving( bool )
	self.NoMoving = bool
end
function meta:DisallowDeleting( bool, callback, no_replication )
	self.NoDeleting = bool
	self.NoDeletingCallback = callback
	self.NoReplication = no_replication
end
local function tool( ply, tr, toolmode, second )
	if toolmode == "nail" and not second then
		local tr2 = {}
		tr2.start = tr.HitPos
		tr2.endpos = tr.HitPos + ply:GetAimVector() * 16
		tr2.filter = { ply, tr.Entity }
		local trace = util.TraceLine( tr2 )
		if trace.Entity and trace.Entity:IsValid() and not trace.Entity:IsPlayer() then
			local ret = tool( ply, trace, toolmode, true )
			if ret ~= nil then
				return ret
			end
		end
	end
	if toolmode == "remover" and ply:KeyDown( IN_ATTACK2 ) and not ply:KeyDownLast( IN_ATTACK2 ) then
		local ConstrainedEntities = constraint.GetAllConstrainedEntities( tr.Entity )
		if ConstrainedEntities then
			for _, ent in pairs( ConstrainedEntities ) do
				if ent.NoDeleting then
					ULib.tsay( ply, "You cannot use a right click delete on this ent because it is constrained to a non-deleteable entity." )
					return false
				end
			end
		end
	end
	if tr.Entity.NoMoving then
		if not table.HasValue( ULib.moveWhitelist, toolmode ) then
			return false
		end
	end
	if tr.Entity.NoDeleting then
		if not table.HasValue( ULib.delWhitelist, toolmode ) then
			return false
		end
	end
end
hook.Add( "CanTool", "ULibEntToolCheck", tool, HOOK_HIGH )
local function property( ply, propertymode, ent )
	if ent.NoMoving then
		if not table.HasValue( ULib.moveWhitelist, propertymode ) then
			return false
		end
	end
	if ent.NoDeleting then
		if not table.HasValue( ULib.delWhitelist, propertymode ) then
			return false
		end
	end
end
hook.Add( "CanProperty", "ULibEntPropertyCheck", property, HOOK_HIGH )
local function physgun( ply, ent )
	if ent.NoMoving then return false end
end
hook.Add( "PhysgunPickup", "ULibEntPhysCheck", physgun, HOOK_HIGH )
hook.Add( "CanPlayerUnfreeze", "ULibEntUnfreezeCheck", physgun, HOOK_HIGH )
local function physgunReload( weapon, ply )
	local trace = util.GetPlayerTrace( ply )
	local tr = util.TraceLine( trace )
	local ent = tr.Entity
	if not ent or not ent:IsValid() or ent:IsWorld() then return end
	if ent.NoMoving then return false end
end
hook.Add( "OnPhysgunReload", "ULibEntPhysReloadCheck", physgunReload, HOOK_HIGH )
local function removedCheck( ent )
	if ent.NoDeleting and not ent.NoReplication then
		local class = ent:GetClass()
		local pos = ent:GetPos()
		local ang = ent:GetAngles()
		local model = ent:GetModel()
		local frozen = false
		if ent:GetPhysicsObject():IsValid() and not ent:GetPhysicsObject():IsMoveable() then
			frozen = true
		end
		local t = ent:GetTable()
		ULib.queueFunctionCall( function()
			local ent2 = ents.Create( class )
			table.Merge( ent2:GetTable(), t )
			ent2:SetModel( model )
			ent2:SetPos( pos )
			ent2:SetAngles( ang )
			ent2:Spawn()
			if frozen then
				ent2:GetPhysicsObject():EnableMotion( false )
			end
			if ent2.NoDeletingCallback then
				ent2.NoDeletingCallback( ent, ent2 )
			end
		end )
	end
end
hook.Add( "EntityRemoved", "ULibEntRemovedCheck", removedCheck, HOOK_MONITOR_HIGH )