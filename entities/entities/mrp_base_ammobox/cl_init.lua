include("shared.lua")

ENT.droppable = "inventory"
ENT.entPanelName = "MRPAmmoboxPanel"

function ENT:CreatePane(parentPanel, target, rect, context, slotName, leftBorderW, iconW)
    local slotPanel =
        baseclass.Get("mrp_base_entity").CreatePane(
            self,
            parentPanel,
            target,
            rect,
            context,
            slotName,
            leftBorderW,
            iconW
        )
    self:makeDroppable(slotPanel, slotName)
    return slotPanel
end
