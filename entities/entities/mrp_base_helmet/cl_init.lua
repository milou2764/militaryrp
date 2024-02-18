include("shared.lua")

ENT.droppable = "inventory"
ENT.entPanelName = "MRPHelmetPanel"

function ENT:createSlotPanel(parentPanel, target, x, y, w, h, context, slotName, leftBorderW, iconW)
    local slotPanel = baseclass.Get("mrp_base_entity").createSlotPanel(self, parentPanel, target, x, y, w, h, context, slotName, leftBorderW, iconW)
    self:makeDroppable(slotPanel, slotName)
    slotPanel:MakeDroppable("inventory")
    return slotPanel
end