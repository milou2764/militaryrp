include("shared.lua")

ENT.entPanelName = "MRPRucksackPanel"
ENT.droppable = "Rucksack"

function ENT:createSlotPanel(parentPanel, target, rect, context, slotName)
    local _baseclass = baseclass.Get("mrp_base_entity")
    local slotPanel = _baseclass.createSlotPanel(
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
