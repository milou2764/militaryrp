include("shared.lua")

ENT.droppable = "inventory"
ENT.entPanelName = "MRPHelmetPanel"

function ENT:createSlotPanel(parentPanel, target, rect, context, slotName)
    print("slotName: " .. slotName)
    local slotPanel =
        baseclass.Get("mrp_base_entity").createSlotPanel(
            self,
            parentPanel,
            target,
            rect,
            context,
            slotName
        )
    self:makeDroppable(slotPanel, slotName)
    slotPanel:MakeDroppable("inventory")
    return slotPanel
end
