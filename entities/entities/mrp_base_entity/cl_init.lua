include("shared.lua")

function ENT:Initialize()
    self:Draw()
end

function ENT:Draw()
    self:DrawModel()
end

ENT.entPanelName = "MRPEntPanel"
ENT.droppable = "nil"

function ENT:dropFromInventoryPanel(entPanel)
    net.Start("MRPDrop")
    net.WriteUInt(self.MRPID, 7)
    net.WriteEntity(entPanel.owner)
    net.WriteString(entPanel:GetName())
    net.SendToServer()
    entPanel:switchOff()
end

function ENT:makeDroppable(slotPanel, slotName)
    slotPanel:MakeDroppable(slotName)
end

function ENT:createSlotPanel(parentPanel, target, rect, context, slotName, leftBorderW, _)
    local slotPanel = vgui.Create("MRPDragBase", parentPanel)
    slotPanel:SetName(slotName)
    slotPanel:SetDropPos("5")
    slotPanel:SetPos(rect.x, rect.y)
    slotPanel:SetSize(rect.w, rect.h)
    slotPanel.leftBorderW = leftBorderW or slotPanel.leftBorderW
    slotPanel.iconW = leftBorderW or slotPanel.iconW
    slotPanel.owner = target
    slotPanel.context = context
    local iconName = MRP.icons[slotPanel:GetName()]
    if iconName then
        slotPanel.iconID = surface.GetTextureID(iconName)
    else
        slotPanel.iconID = surface.GetTextureID("null")
    end
    local mrpid = target:GetNWInt(slotName)
    if mrpid > 1 then
        slotPanel.entPanel = self.fillSlotPanel(MRP.getMRPEnt(mrpid), slotPanel)
    else
        slotPanel.drawSlotFunc = MRP.drawSlotWithIcon
    end
    return slotPanel
end

function ENT:fillSlotPanel(slotPanel)
    local entPanel = vgui.Create(self.entPanelName, slotPanel)
    entPanel:Dock(FILL)
    entPanel:Droppable(self.MRPCategory)
    entPanel:Droppable(self.droppable)
    entPanel:Droppable("dropzone")
    entPanel:SetName(slotPanel:GetName())
    entPanel.gear = self
    entPanel.owner = entPanel:GetParent().owner
    entPanel:switchOn()
    return entPanel
end
