include("shared.lua")

ENT.entPanelName = "MRPVestPanel"
ENT.droppable = "Vest"

function ENT:CreatePane(parentPanel, target, rect, context, slotName)
    local slotPanel =
        baseclass.Get("mrp_base_entity").CreatePane(
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
