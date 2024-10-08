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
    local TAG = "mrp_base_wep"
    Log.d(TAG, "drop")
    Log.d(TAG, "ent Rounds: " .. self.Rounds)
    Log.d(TAG, "ply Rounds: " .. target:GetNWInt(slotName .. "Rounds"))
    local bclass = baseclass.Get("mrp_base_gear")
    local ent = bclass.drop(self, slotName, target, activator)

    local rounds
    if target:IsPlayer() then
        local wep = target:GetWeapon(self.WeaponClass)
        if wep == nil then
            Log.d(TAG, "could not get player wep")
        else
            Log.d(TAG, "got player wep")
        end
        rounds = wep:Clip1()
    else
        rounds = target:GetNWInt(slotName .. "Rounds")
    end

    ent.Rounds = rounds
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
