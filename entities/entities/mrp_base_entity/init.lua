AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysWake()
    self:SetUseType(SIMPLE_USE)
    timer.Simple(
        30,
        function()
            if self:IsValid() then
                self:Remove()
            end
        end
    )
end

function ENT:drop(slotName, target, activator)
    target:SetNWInt(slotName, 1)
    local ent = ents.Create(self.ClassName)
    ent:SetPos(activator:GetPos() + Vector(0, 0, 10))
    ent:Spawn()
    return ent
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName, self.MRPID)
    self:Remove()
end
