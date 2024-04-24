AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.StartingIndex = 6
ENT.Slot6 = 1
ENT.Slot7 = 1
ENT.Slot8 = 1
ENT.Slot9 = 1
ENT.Slot10 = 1

function ENT:Initialize()
    baseclass.Get("mrp_base_gear").Initialize(self)
    self:SetBodygroup(1, self.pocketID)
end

function ENT:equip(ply)
    ply:SetNWInt("VestArmor", self.Armor)
    baseclass.Get("mrp_base_rucksack").equip(self, ply)
end

function ENT:drop(slotName, target, activator)
    local ent = baseclass.Get("mrp_base_rucksack").drop(self, slotName, target, activator)
    ent.Armor = target:GetNWInt(slotName .. "Armor")
    target:SetNWInt("VestArmor", 0)
end
