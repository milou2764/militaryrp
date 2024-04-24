include("shared.lua")

ENT.entPanelName = "MRPRucksackPanel"
ENT.droppable = "Rucksack"

function ENT:CreatePane(parentPanel, target, rect, context, slotName)
    local _baseclass = baseclass.Get("mrp_base_entity")
    local slotPanel = _baseclass.CreatePane(
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
