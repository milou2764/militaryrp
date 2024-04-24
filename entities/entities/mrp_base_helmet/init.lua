AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:equip(ply)
    ply:SetNWInt("HelmetArmor", self.Armor)
    baseclass.Get("mrp_base_gear").equip(self, ply)
end

function ENT:drop(slotName, target, activator)
    local ent = baseclass.Get("mrp_base_gear").drop(self, slotName, target, activator)
    ent.Armor = target:GetNWInt(slotName .. "Armor")
    target:SetNWInt("HelmetArmor", 0)
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName .. "Armor", self.Armor)
    baseclass.Get("mrp_base_gear").fitIn(self, slotName, target)
end
