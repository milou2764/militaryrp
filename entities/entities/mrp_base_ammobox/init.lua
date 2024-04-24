AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Delay = 0

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysWake()
    self:SetCustomCollisionCheck(true)
end

function ENT:Use(activator, _, _, _)
    Log.d(self.ClassName, "MRPID " .. self.MRPID)
    MRP.PickupAmmoBox(activator, self)
end

function ENT:drop(slotName, target, activator)
    local ent = baseclass.Get("mrp_base_entity").drop(self, slotName, target, activator)
    ent.Rounds = target:GetNWInt(slotName .. "Rounds")
    return ent
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName .. "Rounds", self.Rounds)
    baseclass.Get("mrp_base_entity").fitIn(self, slotName, target)
end
