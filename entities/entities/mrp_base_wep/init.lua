AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Use(activator, _, _, _)
    if not activator:MRPHas(self.MRPCategory) then
        MRP.PickupWep(activator, self)
    else
        local oldWep = ents.Create(MRP.idClass[activator:GetNWInt(self.MRPCategory)])
        local wep = activator:GetWeapon(oldWep.WeaponClass)
        oldWep.Rounds = wep:Clip1()
        activator:StripWeapon(oldWep.WeaponClass)
        oldWep:Spawn()
        oldWep:SetPos(activator:GetEyeTraceNoCursor()["HitPos"])
        MRP.PickupWep(activator, self)
    end
end

function ENT:drop(slotName, target, activator)
    Log.d("mrp_base_wep", "drop")
    local ent = baseclass.Get("mrp_base_gear").drop(self, slotName, target, activator)

    ent.Rounds = target:GetNWInt(slotName .. "Rounds")
    target:SetNWInt(slotName .. "Rounds", 0)
    if target:IsPlayer() then
        target:StripWeapon(self.WeaponClass)
    end
    return ent
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName .. "Rounds", self.Rounds)
    baseclass.Get("mrp_base_entity").fitIn(self, slotName, target)
end
