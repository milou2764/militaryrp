AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.StartingIndex = 11
ENT.Slot11 = 1
ENT.Slot12 = 1
ENT.Slot13 = 1
ENT.Slot14 = 1
ENT.Slot15 = 1
ENT.Slot16 = 1
ENT.Slot17 = 1
ENT.Slot18 = 1
ENT.Slot19 = 1
ENT.Slot20 = 1

function ENT:drop(slotName, target, activator)
    local ent = baseclass.Get("mrp_base_gear").drop(self, slotName, target, activator)
    if target:IsPlayer() then
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. k] = target:GetNWInt("Inventory" .. k)
            ent["Slot" .. k .. "Armor"] = target:GetNWInt("Inventory" .. k .. "Armor")
            ent["Slot" .. k .. "Rounds"] = target:GetNWInt("Inventory" .. k .. "Rounds")
            if MRP.EntityTable(target:GetNWInt("Inventory" .. k)).Ammo then
                local ammo = target:GetNWInt("Inventory" .. k .. "Rounds")
                local ammoType = MRP.EntityTable(target:GetNWInt("Inventory" .. k)).Ammo
                target:RemoveAmmo(ammo, ammoType)
            else
                target:SetNWInt("Inventory" .. k, 1)
            end
            target:SetNWInt("Inventory" .. k .. "Armor", 0)
        end
    end
    return ent
end

function ENT:equip(ply)
    for k = self.StartingIndex, self.StartingIndex + self.Capacity - 1 do
        ply:SetNWInt("Inventory" .. k, self["Slot" .. k])
        ply:SetNWInt("Inventory" .. k .. "Armor", self["Slot" .. k .. "Armor"])
        if MRP.EntityTable(self["Slot" .. k]).Ammo then
            local ammo = self["Slot" .. k .. "Rounds"]
            local ammoType = MRP.EntityTable(self["Slot" .. k]).Ammo
            ply:GiveAmmo(ammo, ammoType)
            ply:SetNWInt("Inventory" .. k .. "Rounds", self["Slot" .. k .. "Rounds"])
        end
    end
    baseclass.Get("mrp_base_gear").equip(self, ply)
end

function ENT:Use(activator, _, _, _)
    if CurTime() > activator:GetNWInt("pickupTime") then
        activator:SetNWInt("pickupTime", CurTime() + 1)
        if self:canBeEquipped(activator) then
            self:equip(activator)
        else
            activator:ChatPrint("Vous portez déjà un sac à dos.")
        end
    end
end
