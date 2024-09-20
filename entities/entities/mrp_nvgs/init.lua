AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    baseclass.Get("mrp_base_gear").Initialize(self)
    self:SetBodygroup(0, 1)
end

function ENT:CanBeEquipped(ply)
    local ret = baseclass.Get("mrp_base_gear").CanBeEquipped(self, ply)
    if not ply:MRPHas("Helmet") or not ply:MRPEntityTable("Helmet").NVGsHolder then
        ply:ChatPrint("Il faut un casque pour équiper les LVN.")
        return false
    end
    return ret
end
