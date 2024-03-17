MRP.dropZone = nil
MRP.plyInvPanel = nil
MRP.ragdollInvPanel = nil
MRP.chestPanel = nil

-- inventory columns
local inv_columns = 5

-- Functions
local CreateInventoryPanel

local function removeSelectedContainer(panel, gearPanel)
    if panel.SelectedContainer == gearPanel then
        for k = 0, panel.SelectedContainer.gear.Capacity - 1 do
            panel.InvSlot[k]:Remove()
        end
    end
    gearPanel:Remove()
    panel.Uniform.OverlayFade = 255
    panel.SelectedContainer = panel.Uniform
    panel.ReloadSelectedContainer(1)
end

--[[
   Parameters:
   - p (Panel): The parent panel
--]]
local function LoadInventory(p, inventoryTab, owner, context, startingIndex, yPos, max)
    local i, j = 0, 0
    for k = 0, max-1 do
        local inventoryID = startingIndex + k
        local entID = owner:GetNWInt('Inventory' .. inventoryID)
        local ent = MRP.getMRPEnt(entID)
        local MRPCategory = 'Inventory' .. inventoryID
        local slotPanel = ent:createSlotPanel(p,
                                              owner,
                                              Rect( 25 + j * 125, yPos + i * 125, 100, 100 ),
                                              context,
                                              MRPCategory)
        slotPanel:MakeDroppable('inventory')
        slotPanel.Paint = function(self, w, h)
            baseclass.Get('MRPDragBase').Paint(self, w, h)
            surface.SetFont('Trebuchet18')
            surface.SetTextColor(255, 255, 255, 100)
            surface.SetTextPos(0, 0)
            surface.DrawText(tostring(inventoryID))
        end
        inventoryTab[k] = slotPanel
        j = j + 1
        if j == inv_columns then
            i = i + 1
            j = 0
        end
    end
end

function MRP.createDropZone()
    MRP.dropZone = vgui.Create('DDragBase')
    MRP.dropZone:MakePopup(true)
    MRP.dropZone:SetKeyboardInputEnabled(false)
    MRP.dropZone:SetSize(ScrW(), ScrH())
    function MRP.dropZone:MakeDroppable(name, _)
        self:Receiver(name, function(_, panels, bDoDrop, _, _, _)
            if bDoDrop then
                for _, v in pairs(panels) do
                    --local origin = v:GetParent()
                    v.gear:dropFromInventoryPanel(v)
                end
            end
        end)
    end
    MRP.dropZone:MakeDroppable('dropzone')
    MRP.dropZone.Remove = function(self)
        for _, v in pairs(self:GetChildren()) do
            v:Remove()
        end
        baseclass.Get('DDragBase').Remove(self)
    end
end

function MRP.OpenChest(ent)
    MRP.chestPanel = vgui.Create('EditablePanel', MRP.dropZone)
    MRP.chestPanel:SetX(ScrW() - 650)
    MRP.chestPanel:SetSize(650, 525)
    MRP.chestPanel.Paint = function( _, w, h )
        draw.RoundedBox(2, 0, 0, w, h, Color( 0, 0, 0, 200))
    end
    MRP.chestPanel:MakePopup( true )
    MRP.chestPanel:SetKeyboardInputEnabled( false )
    local inventory = {}
    LoadInventory(MRP.chestPanel, inventory, ent, 'chestPanel', 1, 25, 20)
end

function MRP.OpenRagdollInvPanel(target)
    MRP.ragdollInvPanel = vgui.Create('EditablePanel', MRP.dropZone)
    MRP.ragdollInvPanel:SetX(ScrW() - 650)
    messageNames = {
        drop         = 'RagdollDrop',
        dropAmmo     = 'RagdollDropAmmo',
        dropNVGs     = 'RagdollDropNVGs',
        dropHelmet   = 'RagdollDropHelmet',
        dropGasmask  = 'RagdollDropGasmask',
        dropVest     = 'RagdollDropVest',
        dropRucksack = 'RagdollDropRucksack',
        dropWep      = 'RagdollDropWep',
    }

    CreateInventoryPanel(target, 'ragdollInvPanel')
    local Rucksack       = MRP.ragdollInvPanel.Rucksack
    local Vest           = MRP.ragdollInvPanel.Vest
    local PrimaryWep     = MRP.ragdollInvPanel.PrimaryWep
    local SecondaryWep   = MRP.ragdollInvPanel.SecWep
    local RocketLauncher = MRP.ragdollInvPanel.RLauncher

    if target:GetNWInt('PrimaryWep') > 1 then
        PrimaryWep:SetTooltip('Arme principale')
        PrimaryWep.progressBar = vgui.Create('MRPProgress',  PrimaryWep)
        PrimaryWep.progressBar:SetX(340)
        PrimaryWep.progressBar:SetSize(10, 100)
        PrimaryWep.progressBar.getFraction = function()
            return target:GetPrimaryWepAmmo() / target:GetPrimaryWep().clipSize
        end
    end
    if target:GetNWInt('SecondaryWep') > 1 then
        SecondaryWep:SetTooltip('Arme secondaire')
        SecondaryWep.progressBar = vgui.Create('MRPProgress',  SecondaryWep)
        SecondaryWep.progressBar:SetX(215)
        SecondaryWep.progressBar:SetSize(10, 100)
        SecondaryWep.progressBar.getFraction = function()
            return target:GetSecondaryWepAmmo() / target:GetSecondaryWep().clipSize
        end
    end
    if target:MRPHas('RocketLauncher') then
        RocketLauncher:SetTooltip('Lance-roquettes')
        RocketLauncher.progressBar = vgui.Create('MRPProgress',  RocketLauncher)
        RocketLauncher.progressBar:SetX(590)
        RocketLauncher.progressBar:SetSize(10, 100)
        RocketLauncher.progressBar.getFraction = function()
            return target:GetRLAmmo() / target:GetRLauncher().clipSize
        end
    end

    Rucksack.DoRightClick = function(self)
        removeSelectedContainer(MRP.ragdollInvPanel, self)
        self.gear:dropFromInventoryPanel(self)
    end

    Vest.DoRightClick = function(self)
        removeSelectedContainer(MRP.ragdollInvPanel, self)
        self.gear:dropFromInventoryPanel(self)
    end
end

function MRP.OpenPlyInvPanel(ply)
    MRP.plyInvPanel = vgui.Create('EditablePanel', MRP.dropZone)
    messageNames = {
        drop         = 'PlayerDrop',
        dropAmmo     = 'PlayerDropAmmo',
        dropNVGs     = 'PlayerDropNVGs',
        dropHelmet   = 'PlayerDropHelmet',
        dropGasmask  = 'PlayerDropGasmask',
        dropVest     = 'PlayerDropVest',
        dropRucksack = 'PlayerDropRucksack',
        dropWep      = 'PlayerDropWep',
    }

    CreateInventoryPanel(ply, 'plyInvPanel')
    local NVGs           = MRP.plyInvPanel.NVGs
    local Rucksack       = MRP.plyInvPanel.Rucksack
    local Vest           = MRP.plyInvPanel.Vest
    local PrimaryWep     = MRP.plyInvPanel.PrimaryWep
    local SecondaryWep   = MRP.plyInvPanel.SecWep
    local RocketLauncher = MRP.plyInvPanel.RLauncher

    if ply:MRPHas('PrimaryWep') then
        PrimaryWep:SetTooltip('Arme principale')
        PrimaryWep.progressBar = vgui.Create('MRPProgress',  PrimaryWep)
        PrimaryWep.progressBar:SetX(340)
        PrimaryWep.progressBar:SetSize(10, 100)
        local swep = ply:GetWeapon(ply:GetPrimaryWep().wepClass)
        PrimaryWep.progressBar.getFraction = function()
            if IsValid(swep) then
                return swep:Clip1() / swep.Primary.ClipSize
            end
            return 1
        end
    end

    if ply:MRPHas('SecondaryWep') then
        SecondaryWep:SetTooltip('Arme secondaire')
        SecondaryWep.progressBar = vgui.Create('MRPProgress',  SecondaryWep)
        SecondaryWep.progressBar:SetX(215)
        SecondaryWep.progressBar:SetSize(10, 100)
        local sswep = ply:GetWeapon(ply:GetSecondaryWep().wepClass)
        SecondaryWep.progressBar.getFraction = function()
            if IsValid(sswep) then
                return sswep:Clip1() / sswep.Primary.ClipSize
            end
            return 1
        end
    end

    if ply:MRPHas('RocketLauncher') then
        RocketLauncher:SetTooltip('Lance-roquettes')
        RocketLauncher.progressBar = vgui.Create('MRPProgress',  RocketLauncher)
        RocketLauncher.progressBar:SetX(590)
        RocketLauncher.progressBar:SetSize(10, 100)
        local rlauncher = ply:GetWeapon(ply:GetRLauncher().wepClass)
        RocketLauncher.progressBar.getFraction = function()
            if IsValid(rlauncher) then
                return rlauncher:Clip1() / rlauncher.Primary.ClipSize
            end
            return 1
        end
    end

    MRP.plyInvPanel.DropNVGs = function()
        net.Start(messageNames.dropNVGs)
        net.SendToServer()
        NVGs:switchOff()
        if NV_Status then
            NV_Status = false
            net.Start('NVGPutOff')
            net.SendToServer()
        end
    end

    Rucksack.DoRightClick = function(self)
        removeSelectedContainer(MRP.plyInvPanel, self)
        self.gear:dropFromInventoryPanel(self)
    end

    Vest.DoRightClick = function(self)
        removeSelectedContainer(MRP.plyInvPanel, self)
        self.gear:dropFromInventoryPanel(self)
    end
end
function CreateInventoryPanel(target, context)
    local panel = MRP[context]
    panel.InvSlot = {}
    panel.Remove = function(self)
        for _, v in pairs(self.pmodel.Entity:GetChildren()) do
            v:Remove()
        end
        baseclass.Get('EditablePanel').Remove(self)
    end
    function panel.ReloadSelectedContainer(startingIndex)
        function panel.SelectedContainer:Think() return end
        LoadInventory(panel,
                      panel.InvSlot,
                      target, context,
                      startingIndex,
                      830,
                      panel.SelectedContainer.gear.Capacity)
    end

    panel:SetSize(650 * ScrW() / 1920, ScrH())
    panel.Paint = function(_, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color( 0, 0, 0, 200))
    end

    panel.pmodel = vgui.Create('MRPAdjustableModelPanel', panel) -- INDEX 0
    panel.pmodel:SetModel(target:GetModel())
    panel.pmodel:SetPos(25, 25)
    panel.pmodel:SetSize(325, ScrH() / 2)
    local ang = panel.pmodel.Entity:GetAngles()
    ang:RotateAroundAxis(Vector(0, 0, 1), 45)
    panel.pmodel.Entity:SetAngles(ang)
    local boneId = panel.pmodel.Entity:LookupBone('ValveBiped.Bip01_Head1')
    local headpos = panel.pmodel.Entity:GetBonePosition(boneId)
    panel.pmodel.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))
    for k = 0, target:GetNumBodyGroups() - 1 do
        panel.pmodel.Entity:SetBodygroup(k, target:GetBodygroup(k))
    end
    panel.pmodel.Entity:SetSkin(target:GetNWInt('Skin'))
    panel.pmodel.Entity.AddGear = function(self, gearPanel)
        gearPanel.model = gearPanel.gear:createCSModel(self)
        gearPanel.model:SetNoDraw(true)
    end

    --TODO trouver et simplifier la fonction createSlotPanel
    panel.NVGs = baseclass.Get('mrp_nvgs'):createSlotPanel( panel,
                                                            target,
                                                            Rect( 375, 25, 100, 100 ),
                                                            context,
                                                            'NVGs').entPanel or {} -- INDEX 1
    if IsValid(panel.NVGs) then
        panel.pmodel.Entity:AddGear(panel.NVGs)
        if target:GetNWBool('NVGsOn') then panel.NVGs.model:SetBodygroup(1, 1) end
    end

    local _baseclass = baseclass.Get('mrp_base_helmet')
    panel.Helmet = _baseclass:createSlotPanel( panel,
                                               target,
                                               Rect( 500, 25, 100, 100 ),
                                               context,
                                               'Helmet').entPanel or {} -- INDEX 2
    if IsValid(panel.Helmet) then
        panel.pmodel.Entity:AddGear(panel.Helmet)
    end

    _baseclass = baseclass.Get('mrp_base_gear')
    panel.Gasmask = _baseclass:createSlotPanel( panel,
                                                target,
                                                Rect( 500, 150, 100, 100 ),
                                                context,
                                                'Gasmask' ).entPanel or {} -- INDEX 3
    if IsValid(panel.Gasmask) then
        panel.pmodel.Entity:AddGear(panel.Gasmask)
        if target:GetNWBool('GasmaskOn') then
            panel.Gasmask.model:SetModel('models/gmod4phun/props/gasmask.mdl')
        end
    end

    _baseclass = baseclass.Get('mrp_base_rucksack')
    panel.Rucksack = _baseclass:createSlotPanel( panel,
                                                 target,
                                                 Rect( 375, 275, 100, 100 ),
                                                 context,
                                                 'Rucksack').entPanel or {} -- INDEX 4
    if IsValid(panel.Rucksack) then
        panel.Rucksack.startingIndex = 11
        panel.pmodel.Entity:AddGear(panel.Rucksack)
    end

    _baseclass = baseclass.Get('mrp_base_vest')
    panel.Vest = _baseclass:createSlotPanel( panel,
                                             target,
                                             Rect( 500, 275, 100, 100 ),
                                             context,
                                             'Vest').entPanel or {} -- INDEX 5
    if IsValid(panel.Vest) then
        panel.Vest.startingIndex = 6
        panel.pmodel.Entity:AddGear(panel.Vest)
    end

    panel.Uniform = vgui.Create('MRPSpawnIcon', panel) -- INDEX 6
    panel.Uniform:SetPos(500, 400)
    panel.Uniform:SetSpawnIcon('icon64/uniform.png')
    panel.Uniform:SetSize(100, 100)
    panel.Uniform:SetTooltip('Treillis')
    panel.Uniform.gear = ents.CreateClientside('mrp_uniform')
    panel.Uniform.startingIndex = 1
    panel.Uniform.GetParent = function(_) return panel.pmodel end
    panel.Uniform.DoClick = MRP.selectContainer
    panel.Uniform.fullness = vgui.Create('MRPProgress', panel.Uniform)
    panel.Uniform.fullness:SetX(90)
    panel.Uniform.fullness:SetSize(10, 100)
    panel.Uniform.owner = target
    local function calcFilledUniformSlotCount()
        local filledUniformSlotCount = 0
        for k = 1, 5 do
            if target:GetNWInt('Inventory' .. tostring(k)) > 1 then
                filledUniformSlotCount = filledUniformSlotCount + 1
            end
        end
        return filledUniformSlotCount / 5
    end
    panel.Uniform.fullness.getFraction = calcFilledUniformSlotCount

    local targetPrimaryWep = target:GetPrimaryWep()
    panel.PrimaryWep = targetPrimaryWep:createSlotPanel( panel,
                                                         target,
                                                         Rect( 25, 580, 350, 100 ),
                                                         context,
                                                         'PrimaryWep',
                                                         100,
                                                         128).entPanel

    panel.SecWep = target:GetSecWep():createSlotPanel( panel,
                                                       target,
                                                       Rect( 25 + 350 + 25, 580, 225, 100 ),
                                                       context,
                                                       'SecondaryWep',
                                                       80).entPanel

    panel.RLauncher = target:GetRLauncher():createSlotPanel(panel,
                                                            target,
                                                            Rect( 25, 705, 600, 100 ),
                                                            context,
                                                            'RocketLauncher',
                                                            170,
                                                            256).entPanel

    if IsValid(panel.Rucksack) then
        panel.Rucksack.OverlayFade = 255
        panel.SelectedContainer = panel.Rucksack
        panel.ReloadSelectedContainer(11)
    elseif IsValid(panel.Vest) and panel.Vest.gear.Capacity then
        panel.Vest.OverlayFade = 255
        panel.SelectedContainer = panel.Vest
        panel.ReloadSelectedContainer(6)
    else
        panel.Uniform.OverlayFade = 255
        panel.SelectedContainer = panel.Uniform
        panel.ReloadSelectedContainer(1)
    end
end

local keyReleased = true
hook.Add('Tick', 'InventoryOpening', function()
    if input.IsKeyDown(MRP.keybinds.inventory)
    and player_manager.GetPlayerClass(LocalPlayer()) ~= 'player_spectator'
    and keyReleased then
        keyReleased = false
        if not MRP.plyInvPanel or
        not MRP.plyInvPanel:IsValid() and not vgui.CursorVisible() then
            MRP.createDropZone()
            MRP.OpenPlyInvPanel(LocalPlayer())
        else
            MRP.dropZone:Remove()
        end
    elseif not input.IsKeyDown(MRP.keybinds.inventory) then
        keyReleased = true
    end
end)
net.Receive('MRPPlayerNVGsToggle', function()
    local bodyId
    if ply:GetNWBool('NVGsOn') then
        bodyId = 1
    else
        bodyId = 0
    end
    local userid = net.ReadUInt(16)
    MRP.mountedGear[userid].NVGs:SetBodygroup(1, bodyId)
    if IsValid(MRP.plyInvPanel) then MRP.plyInvPanel.NVGs.model:SetBodygroup(1, bodyId) end
end)
net.Receive('MRPPlayerTakeOnGasmask', function()
    local userid = net.ReadUInt(16)
    MRP.mountedGear[userid].Gasmask:SetModel('models/gmod4phun/props/gasmask.mdl')
    if IsValid(MRP.plyInvPanel) then
        MRP.plyInvPanel.Gasmask.model:SetModel('models/gmod4phun/props/gasmask.mdl')
    end
end)
net.Receive('MRPPlayerTakeOffGasmask', function()
    local userid = net.ReadUInt(16)
    MRP.mountedGear[userid].Gasmask:SetModel('models/yukon/props/conscripts/maskbag.mdl')
    if IsValid(MRP.plyInvPanel) then
        MRP.plyInvPanel.Gasmask.model:SetModel('models/yukon/props/conscripts/maskbag.mdl')
    end
end)

hook.Add('NetworkEntityCreated', 'MRPNetworkEntityCreated', function(ent)
    local owner = ent:GetOwner()
    if owner:IsPlayer() and ent:GetClass() == 'prop_ragdoll' then
        local ragdoll = ent
        ragdoll:CallOnRemove('MRPCallOnRemove', function()
            if MRP.ragdollInvPanel and MRP.ragdollInvPanel:IsValid() then
                MRP.ragdollInvPanel:Remove()
            end
        end)
        local userid = owner:UserID()
        local ragdollid = ragdoll:EntIndex()
        MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
        MRP.mountedGear[ragdollid] = {}
        for k, gear in pairs(MRP.mountedGear[userid]) do
            MRP.mountedGear[userid][k] = nil
            MRP.mountedGear[ragdollid][k] = ClientsideModel(gear:GetModel(),
                                                            RENDERGROUP_OPAQUE)
            MRP.mountedGear[ragdollid][k]:SetParent(ragdoll)
            MRP.mountedGear[ragdollid][k]:AddEffects(EF_BONEMERGE)
            MRP.mountedGear[ragdollid][k]:SetIK(false)
            MRP.mountedGear[ragdollid][k]:SetTransmitWithParent(true)
            gear:Remove()
        end
        for k = 1, 20 do
            ragdoll:SetNWInt('Inventory' .. k,
                             owner:GetNWInt('Inventory' .. k))
            ragdoll:SetNWInt('Inventory' .. k .. 'Ammo',
                             owner:GetNWInt('Inventory' .. k .. 'Ammo'))
        end
        ragdoll:SetNWInt('Helmet', owner:GetNWInt('Helmet'))
        ragdoll:SetNWInt('HelmetArmor', owner:GetNWInt('HelmetArmor'))
        ragdoll:SetNWInt('NVGs', owner:GetNWInt('NVGs'))
        ragdoll:SetNWInt('Gasmask', owner:GetNWInt('Gasmask'))
        ragdoll:SetNWInt('Rucksack', owner:GetNWInt('Rucksack'))
        ragdoll:SetNWInt('Vest', owner:GetNWInt('Vest'))
        ragdoll:SetNWInt('VestArmor', owner:GetNWInt('VestArmor'))
        ragdoll:SetNWInt('PrimaryWep', owner:GetNWInt('PrimaryWep'))
        ragdoll:SetNWInt('SecondaryWep', owner:GetNWInt('SecondaryWep'))
        ragdoll:SetNWInt('RocketLauncher', owner:GetNWInt('RocketLauncher'))
        ragdoll:SetNWInt('Faction', owner:GetNWInt('Faction'))
        ragdoll:SetNWInt('ModelIndex', owner:GetNWInt('ModelIndex'))
        ragdoll:SetNWInt('GasmaskOn', owner:GetNWInt('GasmaskOn'))
        ragdoll:CallOnRemove('MRPCleanUpRagdoll', function()
            for _, gear in pairs(MRP.mountedGear[ragdollid]) do
                if gear.Remove then
                    gear:Remove()
                end
            end
        end)
    end
end)
