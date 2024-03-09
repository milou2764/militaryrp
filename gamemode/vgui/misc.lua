local gwenFunc1 = GWEN.CreateTextureBorder(480, 32, 31, 31, 4, 4, 4, 4)

local function drawSlot(self, w, h)
    gwenFunc1(0, 0, w, h, Color(78, 78, 78, 169))
end

function Rect(_x, _y, _w, _h)
    return { x = _x, y = _y, w = _w, h = _h }
end

function MRP.selectContainer(entPanel)
    if not entPanel.owner:IsPlayer() then return end
    local panel = entPanel:GetParent():GetParent()

    if panel.SelectedContainer:IsVisible() and panel.SelectedContainer.gear.Capacity > 0 then
        for k = 0, panel.SelectedContainer.gear.Capacity - 1 do
            panel.InvSlot[k]:Remove()
        end
    end

    function panel.SelectedContainer:Think()
        self.OverlayFade = math.Clamp(self.OverlayFade - RealFrameTime() * 640 * 2, 0, 255)
        if dragndrop.IsDragging() or not self:IsHovered() then return end
        self.OverlayFade = math.Clamp(self.OverlayFade + RealFrameTime() * 640 * 8, 0, 255)
    end

    panel.SelectedContainer = entPanel
    panel.ReloadSelectedContainer(entPanel.startingIndex)
end

function MRP.drawSlotWithIcon(self, w, h)
    drawSlot(self, w, h)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetTexture(self.iconID)
    surface.DrawTexturedRect(self.leftBorderW * self.ss,
                             self.topBorderW * self.ss,
                             self.iconW, self.iconH)
end

function MRP.screenScale()
    return ScrH() / 1080
end

local MRPPanel = {}

function MRPPanel:Init()
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
end

function MRPPanel:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(77, 77, 77, 240))
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, ScrW(), 100)
end

vgui.Register("MRPPanel", MRPPanel, "EditablePanel")
local MRPSpawnIcon = {}

function MRPSpawnIcon:SetSize(width, height)
    baseclass.Get("Panel").SetSize(self, width * MRP.screenScale(), height * MRP.screenScale())
end

function MRPSpawnIcon:SetPos(x, y)
    baseclass.Get("Panel").SetPos(self, x * MRP.screenScale(), y * MRP.screenScale())
end

vgui.Register("MRPSpawnIcon", MRPSpawnIcon, "SpawnIcon")
local MRPAdjustableModelPanel = {}
MRPAdjustableModelPanel.SetSize = MRPSpawnIcon.SetSize
MRPAdjustableModelPanel.SetPos = MRPSpawnIcon.SetPos

function MRPAdjustableModelPanel:Init()
    self.mx = 0
    self.my = 0
    self.aLookAngle = Angle(0.000, 213.889, 0.000)
    self.vCamPos = Vector(33.666279, 23.161373, 37.288376)
end

function MRPAdjustableModelPanel:LayoutEntity(_)
    return
end

-- Disable cam rotation
function MRPAdjustableModelPanel:DrawModel()
    local curparent = self
    local leftx, topy = self:LocalToScreen(0, 0)
    local rightx, bottomy = self:LocalToScreen(self:GetWide(), self:GetTall())

    while curparent:GetParent() ~= nil do
        curparent = curparent:GetParent()
        local x1, y1 = curparent:LocalToScreen(0, 0)
        local x2, y2 = curparent:LocalToScreen(curparent:GetWide(), curparent:GetTall())
        leftx = math.max(leftx, x1)
        topy = math.max(topy, y1)
        rightx = math.min(rightx, x2)
        bottomy = math.min(bottomy, y2)
        previous = curparent
    end

    -- Causes issues with stencils, but only for some people?
    -- render.ClearDepth()
    render.SetScissorRect(leftx, topy, rightx, bottomy, true)
    local ret = self:PreDrawModel(self.Entity)

    if ret ~= false then
        self.Entity:DrawModel()
        self:PostDrawModel(self.Entity)

        for _, m in pairs(self.Entity:GetChildren()) do
            m:DrawModel()
            self:PostDrawModel(m)
        end
    end

    render.SetScissorRect(0, 0, 0, 0, false)
end

function MRPAdjustableModelPanel:FirstPersonControls()
    local x, _ = self:CaptureMouse()
    local scale = self:GetFOV() / 180
    x = x * -0.5 * scale

    if self.MouseKey == MOUSE_LEFT then
        self.aLookAngle = self.aLookAngle + Angle(0, x * 4, 0)
        self.vCamPos = self.OrbitPoint - self.aLookAngle:Forward() * self.OrbitDistance

        return
    end

    -- Look around
    self.aLookAngle = self.aLookAngle + Angle(0, x, 0)
    local Movement = vector_origin
    local speed = 4
    self.vCamPos = self.vCamPos + Movement * speed
end

vgui.Register("MRPAdjustableModelPanel", MRPAdjustableModelPanel, "DAdjustableModelPanel")
local MRPDragBase = {}
MRPDragBase.SetSize = MRPSpawnIcon.SetSize
MRPDragBase.SetPos = MRPSpawnIcon.SetPos
MRPDragBase.drawSlotFunc = drawSlot

function MRPDragBase.Paint(self, w, h)
    self.drawSlotFunc(self, w, h)
end

function MRPDragBase:Init()
    baseclass.Get("DDragBase").Init(self)
    self.ss = MRP.screenScale()
    self.iconW = 64 * self.ss
    self.iconH = 64 * self.ss
    self.leftBorderW = 18 * self.ss
    self.topBorderW = 18 * self.ss
end

local function MRPDragnDrop(dest, panels, bDoDrop, _, _, _)
    if bDoDrop then
        for _, v in pairs(panels) do
            local origin = v:GetParent()

            if origin.owner ~= dest.owner then
                net.Start("ItemSwitchOwner")
                net.WriteEntity(origin.owner)
                net.WriteString(origin:GetName())
                net.WriteEntity(dest.owner)
                net.WriteString(dest:GetName())
                net.SendToServer()
            else
                net.Start("ItemSwitchSlot")
                net.WriteEntity(origin.owner)
                net.WriteString(origin:GetName())
                net.WriteString(dest:GetName())
                net.SendToServer()
            end

            if v.gear and scripted_ents.IsBasedOn(v.gear.ClassName, "mrp_base_gear") and origin:GetName() == v.gear.MRPCategory and origin.owner:IsPlayer() then
                net.Start("PlayerUnmountGearWithDragnDrop")
                net.WriteUInt(v.gear.MRPID, 7)
                net.WriteEntity(origin.owner)
                net.SendToServer()
                v.model:Remove()
            end

            origin.drawSlotFunc = MRP.drawSlotWithIcon
            v:SetParent(dest)
            v:SetName(dest:GetName())
            dest.entPanel = v
            v:switchOwner(dest)
        end
    end
end

function MRPDragBase:MakeDroppable(name, _)
    self:Receiver(name, MRPDragnDrop)
end

vgui.Register("MRPDragBase", MRPDragBase, "DDragBase")
local MRPProgress = {}
MRPProgress.fraction = 0
MRPProgress.color = Color(255, 255, 255, 100)

MRPProgress.getFraction = function()
    return 0
end

MRPProgress.SetSize = MRPSpawnIcon.SetSize
MRPProgress.SetPos = MRPSpawnIcon.SetPos

function MRPProgress:Init()
    self.ss = MRP.screenScale()
end

MRPProgress.Paint = function(self, _, _)
    local fraction = self.getFraction()
    surface.SetDrawColor(self.color)
    surface.DrawRect(0, (100 - 100 * fraction) * self.ss, 10 * self.ss, 100 * fraction * self.ss)
end

vgui.Register("MRPProgress", MRPProgress, "Panel")
local MRPEntPanel = {}

function MRPEntPanel:Init()
    self.ss = MRP.screenScale()
    baseclass.Get("MRPSpawnIcon").Init(self)
    self.iconW = 64 * self.ss
    self.iconH = 64 * self.ss
    self.leftBorderW = 18 * self.ss
    self.topBorderW = 18 * self.ss
end

function MRPEntPanel:switchOff()
    local parent = self:GetParent()
    self:Remove()
    parent.drawSlotFunc = MRP.drawSlotWithIcon
end

function MRPEntPanel:switchOn()
    self:SetModel(self.gear.model)
    self:SetTooltip(self.gear.PrintName)
end

function MRPEntPanel:DoRightClick()
    self.gear:dropFromInventoryPanel(self)
end

function MRPEntPanel:OnDrop()
    local newSlot = vgui.GetHoveredPanel()

    if not newSlot.context then
        dragndrop.StopDragging()

        return
    end

    return self
end

function MRPEntPanel:switchOwner(dest)
    self.owner = dest.owner
    self:SetParent(dest)
    dest.drawSlotFunc = drawSlot
end

vgui.Register("MRPEntPanel", MRPEntPanel, "MRPSpawnIcon")
local MRPVestPanel = {}

function MRPVestPanel:switchOn()
    baseclass.Get("MRPEntPanel").switchOn(self)
    self.progressBar = vgui.Create("MRPProgress", self)
    self.progressBar:SetX(90)
    self.progressBar:SetSize(10, 100)

    self.progressBar.getFraction = function()
        return self.owner:GetNWInt(self:GetName() .. "Armor") / self.gear.armor
    end

    self.progressBar.color = Color(26, 19, 158, 100)
end

vgui.Register("MRPVestPanel", MRPVestPanel, "MRPEntPanel")
local MRPPocketVestPanel = {}
MRPPocketVestPanel.DoClick = MRP.selectContainer

function MRPPocketVestPanel:switchOn()
    baseclass.Get("MRPVestPanel").switchOn(self)
    self:SetModel(self.gear.model, 0, "0" .. self.gear.pocketID .. "0000000")

    if self.owner:IsPlayer() then
        self.fullness = vgui.Create("MRPProgress", self)
        self.fullness:SetX(80)
        self.fullness:SetSize(10, 100)

        local function calcFilledVestSlotCount()
            local filledVestSlotCount = 0

            for k = 6, self.gear.Capacity + 5 do
                if self.owner:GetNWInt("Inventory" .. k) > 1 then
                    filledVestSlotCount = filledVestSlotCount + 1
                end
            end

            return filledVestSlotCount / self.gear.Capacity
        end

        self.fullness.getFraction = calcFilledVestSlotCount
    end
end

vgui.Register("MRPPocketVestPanel", MRPPocketVestPanel, "MRPVestPanel")
local MRPHelmetPanel = {}

function MRPHelmetPanel:showArmorBar()
    self.progressBar = vgui.Create("MRPProgress", self)
    self.progressBar:SetX(90)
    self.progressBar:SetSize(10, 100)

    self.progressBar.getFraction = function()
        return self.owner:GetNWInt(self:GetName() .. "Armor") / self.gear.armor
    end

    self.progressBar.color = Color(26, 19, 158, 100)
end

function MRPHelmetPanel:switchOn()
    self:SetModel(self.gear.model, self.gear.skin or 0)
    self:SetTooltip(self.gear.PrintName)
    self:showArmorBar()
end

vgui.Register("MRPHelmetPanel", MRPHelmetPanel, "MRPEntPanel")
local MRPRucksackPanel = {}
MRPRucksackPanel.DoClick = MRP.selectContainer

function MRPRucksackPanel:switchOn(ent)
    baseclass.Get("MRPEntPanel").switchOn(self, ent)

    if self.owner:IsPlayer() then
        self.fullness = vgui.Create("MRPProgress", self)
        self.fullness:SetX(90)
        self.fullness:SetSize(10, 100)

        local function calcFilledRucksackSlotCount()
            local filledRucksackSlotCount = 0

            for k = 11, self.gear.Capacity + 10 do
                if self.owner:GetNWInt("Inventory" .. tostring(k)) > 1 then
                    filledRucksackSlotCount = filledRucksackSlotCount + 1
                end
            end

            return filledRucksackSlotCount / self.gear.Capacity
        end

        self.fullness.getFraction = calcFilledRucksackSlotCount
    end
end

vgui.Register("MRPRucksackPanel", MRPRucksackPanel, "MRPEntPanel")
local MRPAmmoboxPanel = {}

function MRPAmmoboxPanel:switchOff()
    baseclass.Get("MRPEntPanel").switchOff(self)
    self.fullness:Remove()
end

function MRPAmmoboxPanel:switchOn(ent)
    baseclass.Get("MRPEntPanel").switchOn(self, ent)
    self.fullness = vgui.Create("MRPProgress", self)
    self.fullness:SetX(90)
    self.fullness:SetSize(10, 100)

    local function calcAmmoboxFullness()
        return self.owner:GetNWInt(self:GetName() .. "Ammo") / self.gear.capacity
    end

    self.fullness.getFraction = calcAmmoboxFullness
end

vgui.Register("MRPAmmoboxPanel", MRPAmmoboxPanel, "MRPEntPanel")
local MRPWepPanel = {}

function MRPWepPanel:switchOn()
    self:SetSpawnIcon(MRP.getMRPEnt(self.owner:GetNWInt(self:GetName())).icon)

    if not self.owner:IsPlayer() then
        self.progressBar = vgui.Create("MRPProgress", self)
        self.progressBar:SetX(90)
        self.progressBar:SetSize(10, 100)

        self.progressBar.getFraction = function()
            return self.owner:GetNWInt(self:GetName() .. "Ammo") / self.gear.clipSize
        end
    end
end

vgui.Register("MRPWepPanel", MRPWepPanel, "MRPEntPanel")
local MRPBinder = {}

function MRPBinder:UpdateText()
    local str = input.GetKeyName(self:GetSelectedNumber())

    if not str then
        str = "NONE"
    end

    str = language.GetPhrase(str)
    self:SetText(string.upper(str))
end

vgui.Register("MRPBinder", MRPBinder, "DBinder")
