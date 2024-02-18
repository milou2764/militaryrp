include("shared.lua")

ENT.entPanelName = "MRPPocketVestPanel"
ENT.droppable = "Vest"

function ENT:createCSModel(target)
    local model = baseclass.Get("mrp_base_gear").createCSModel(self, target)
    model:SetBodygroup(1,self.pocketID)
    return model
end