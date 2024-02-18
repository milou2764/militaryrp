AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Delay = 0

function ENT:Initialize()
    self:SetModel(self.model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysWake()
    self:SetCustomCollisionCheck(true)
end

function ENT:Use(activator, caller, useType, value)
    MRP.PickupAmmoBox(activator, self)
end

function ENT:drop(slotName, target, activator)
    local ent = baseclass.Get("mrp_base_entity").drop(self, slotName, target, activator)
    ent.ammoCount = target:GetNWInt(slotName .. "Ammo")
    return ent
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName .. "Ammo", self.ammoCount)
    baseclass.Get("mrp_base_entity").fitIn(self, slotName, target)
end