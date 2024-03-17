AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:canBeEquipped(ply)
    if ply:GetNWInt(self.MRPCategory) == 1 then
        return true
    end
    return false
end

function ENT:equip(ply)
    ply:SetNWInt(self.MRPCategory, self.MRPID)
    net.Start("PlayerMountGear")
    net.WriteUInt(self.MRPID, 7)
    net.WriteEntity(ply)
    net.Broadcast()
    self:Remove()
end

function ENT:Use(activator, _, _, _)
    if self:canBeEquipped(activator) then
        self:equip(activator)
    else
        activator:inventoryPickup(self)
    end
end


function ENT:drop(slotName, target, activator)
    if target.mountedGear and target.mountedGear[slotName] then
        target.mountedGear[slotName]:Remove()
    end
    return baseclass.Get("mrp_base_entity").drop(self, slotName, target, activator)
end

function ENT:createServerModel(target)
    local model = ents.Create("prop_dynamic")
    model:SetModel(self.model)
    model:SetParent(target)
    model:AddEffects(EF_BONEMERGE)

    return model
end
