include("shared.lua")

ENT.entPanelName = "MRPVestPanel"
ENT.droppable = "Vest"

function ENT:createSlotPanel(parentPanel, target, rect, context, slotName)
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
    return slotPanel
end
