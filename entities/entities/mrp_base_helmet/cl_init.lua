include("shared.lua")

ENT.droppable = "inventory"
ENT.entPanelName = "MRPHelmetPanel"

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
    slotPanel:MakeDroppable("inventory")
    return slotPanel
end
