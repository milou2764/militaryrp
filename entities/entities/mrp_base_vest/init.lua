AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Use(activator, _, _, _)
    if CurTime() > activator:GetNWInt("pickupTime") then
        activator:SetNWInt("pickupTime", CurTime() + 1)
        if self:canBeEquipped(activator) then
            self:equip(activator)
        else
            activator:ChatPrint("Vous portez déjà un gilet tactique.")
        end
    end
end

function ENT:fitIn(slotName, target)
    target:SetNWInt(slotName .. "Armor", self.armor)
    baseclass.Get("mrp_base_gear").fitIn(self, slotName, target)
end
