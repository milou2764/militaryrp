AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Use(activator, _, _, _)
    if activator:GetNWInt(self.MRPCategory) < 2 then
        MRP.PickupWep(activator, self)
    else
        local oldWep = ents.Create(MRP.ents[activator:GetNWInt(self.MRPCategory)])
        local wep = activator:GetWeapon(oldWep.wepClass)
        oldWep.ammoCount = wep:Clip1()
        activator:StripWeapon(oldWep.wepClass)
        oldWep:Spawn()
        oldWep:SetPos(activator:GetEyeTraceNoCursor()["HitPos"])
        MRP.PickupWep(activator, self)
    end
end

function ENT:drop(slotName, target, activator)
    local ent = baseclass.Get("mrp_base_gear").drop(self, slotName, target, activator)

    ent.ammoCount = target:GetNWInt(slotName .. "Ammo")
    target:SetNWInt(slotName .. "Ammo", 0)
    if target:IsPlayer() then
        target:StripWeapon(self.wepClass)
    end
    return ent
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName .. "Ammo", self.ammoCount)
    baseclass.Get("mrp_base_entity").fitIn(self, slotName, target)
end
