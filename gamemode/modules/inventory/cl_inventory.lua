MRP.dropZone = nil
MRP.plyInvPanel = nil
MRP.ragdollInvPanel = nil
MRP.chestPanel = nil

local function Rect(x, y, w, h)
    return { x = x, y = y, w = w, h = h }
end

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
        local entID = owner:GetNWInt("Inventory" .. inventoryID)
        local ent = MRP.EntityTable(entID)
        local MRPCategory = "Inventory" .. inventoryID
        local slotPanel = ent:CreatePane(
            p,
            owner,
            Rect( 25 + j * 125, yPos + i * 125, 100, 100 ),
            context,
            MRPCategory
        )
        slotPanel:MakeDroppable("inventory")
        slotPanel.Paint = function(self, w, h)
            baseclass.Get("MRPDragBase").Paint(self, w, h)
            surface.SetFont("Trebuchet18")
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
    MRP.dropZone = vgui.Create("DDragBase")
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
    MRP.dropZone:MakeDroppable("dropzone")
    MRP.dropZone.Remove = function(self)
        for _, v in pairs(self:GetChildren()) do
            v:Remove()
        end
        baseclass.Get("DDragBase").Remove(self)
    end
end

function MRP.OpenChest(ent)
    MRP.chestPanel = vgui.Create("EditablePanel", MRP.dropZone)
    MRP.chestPanel:SetX(ScrW() - 650)
    MRP.chestPanel:SetSize(650, 525)
    MRP.chestPanel.Paint = function( _, w, h )
        draw.RoundedBox(2, 0, 0, w, h, Color( 0, 0, 0, 200))
    end
    MRP.chestPanel:MakePopup( true )
    MRP.chestPanel:SetKeyboardInputEnabled( false )
    local inventory = {}
    LoadInventory(MRP.chestPanel, inventory, ent, "chestPanel", 1, 25, 20)
end

function MRP.OpenRagdollInvPanel(target)
    MRP.ragdollInvPanel = vgui.Create("EditablePanel", MRP.dropZone)
    MRP.ragdollInvPanel:SetX(ScrW() - 650)
    messageNames = {
        drop         = "RagdollDrop",
        dropAmmo     = "RagdollDropAmmo",
        dropNVGs     = "RagdollDropNVGs",
        dropHelmet   = "RagdollDropHelmet",
        dropGasmask  = "RagdollDropGasmask",
        dropVest     = "RagdollDropVest",
        dropRucksack = "RagdollDropRucksack",
        dropWep      = "RagdollDropWep",
    }

    CreateInventoryPanel(target, "ragdollInvPanel")
    local Rucksack       = MRP.ragdollInvPanel.Rucksack
    local Vest           = MRP.ragdollInvPanel.Vest
    local PrimaryWep     = MRP.ragdollInvPanel.PrimaryWep
    local SecondaryWep   = MRP.ragdollInvPanel.SecondaryWep
    local RocketLauncher = MRP.ragdollInvPanel.RocketLauncher

    if target:MRPHas("PrimaryWep") then
        local entityTable = target:MRPWep()
        PrimaryWep:SetTooltip(entityTable.PrintName)
        PrimaryWep.progressBar = vgui.Create("MRPProgress",  PrimaryWep)
        PrimaryWep.progressBar:SetX(340)
        PrimaryWep.progressBar:SetSize(10, 100)
        PrimaryWep.progressBar.getFraction = function()
            return target:MRPWepRounds() / entityTable.ClipSize
        end
    end
    if target:MRPHas("SecondaryWep") then
        local entityTable = target:MRPSecWep()
        SecondaryWep:SetTooltip(entityTable.PrintName)
        SecondaryWep.progressBar = vgui.Create("MRPProgress",  SecondaryWep)
        SecondaryWep.progressBar:SetX(215)
        SecondaryWep.progressBar:SetSize(10, 100)
        SecondaryWep.progressBar.getFraction = function()
            return target:MRPSecWepRounds() / entityTable.ClipSize
        end
    end
    if target:MRPHas("RocketLauncher") then
        RocketLauncher:SetTooltip("Lance-roquettes")
        RocketLauncher.progressBar = vgui.Create("MRPProgress",  RocketLauncher)
        RocketLauncher.progressBar:SetX(590)
        RocketLauncher.progressBar:SetSize(10, 100)
        RocketLauncher.progressBar.getFraction = function()
            return target:MRPRLRounds() / target:MRPRLauncher().ClipSize
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

function MRP.OpenPlyInvPanel(target, ragdoll)
    MRP.plyInvPanel = vgui.Create("EditablePanel", MRP.dropZone)
    local msgSuffix
    local panelName
    if ragdoll then
        msgSuffix = "Ragdoll"
        panelName = "ragdollInvPanel"
    else
        msgSuffix = "Player"
        panelName = "plyInvPanel"
    end
    local pane = MRP[panelName]

    CreateInventoryPanel(target, panelName)
    local NVGs           = pane.NVGs
    local Rucksack       = pane.Rucksack
    local Vest           = pane.Vest

    local barconfs = {
        PrimaryWep = 340,
        SecondaryWep = 215,
        RocketLauncher = 590,
    }

    for _, wepcat in ipairs(MRP.WeaponCat) do
        if target:MRPHas(wepcat) then
            local wepPane = pane[wepcat]
            local entityTable = target:MRPEntityTable(wepcat)
            wepPane:SetTooltip(entityTable.PrintName)
            wepPane.progressBar = vgui.Create("MRPProgress",  wepPane)
            wepPane.progressBar:SetX(barconfs[wepcat])
            wepPane.progressBar:SetSize(10, 100)
            if ragdoll then
                wepPane.progressBar.getFraction = function()
                    return target:GetNWInt(wepcat .. "Rounds") / entityTable.ClipSize
                end
            else
                local swep = target:GetWeapon(entityTable.WeaponClass)
                wepPane.progressBar.getFraction = function()
                    if IsValid(swep) then
                        return swep:Clip1() / swep.Primary.ClipSize
                    end
                    return 0
                end
            end
        end
    end

    pane.DropNVGs = function()
        net.Start(msgSuffix + "DropNVGS")
        net.SendToServer()
        NVGs:switchOff()
        if NV_Status then
            NV_Status = false
            net.Start("NVGPutOff")
            net.SendToServer()
        end
    end

    Rucksack.DoRightClick = function(self)
        removeSelectedContainer(pane, self)
        self.gear:dropFromInventoryPanel(self)
    end

    Vest.DoRightClick = function(self)
        removeSelectedContainer(pane, self)
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
        baseclass.Get("EditablePanel").Remove(self)
    end
    function panel.ReloadSelectedContainer(startingIndex)
        function panel.SelectedContainer:Think() return end
        LoadInventory(
            panel,
            panel.InvSlot,
            target,
            context,
            startingIndex,
            830,
            panel.SelectedContainer.gear.Capacity
        )
    end

    panel:SetSize(650 * ScrW() / 1920, ScrH())
    panel.Paint = function(_, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color( 0, 0, 0, 200))
    end

    panel.pmodel = vgui.Create("MRPAdjustableModelPanel", panel) -- INDEX 0
    panel.pmodel:SetModel(target:GetModel())
    panel.pmodel:SetPos(25, 25)
    panel.pmodel:SetSize(325, ScrH() / 2)
    local ang = panel.pmodel.Entity:GetAngles()
    ang:RotateAroundAxis(Vector(0, 0, 1), 45)
    panel.pmodel.Entity:SetAngles(ang)
    local boneId = panel.pmodel.Entity:LookupBone("ValveBiped.Bip01_Head1") or 1
    local headpos = panel.pmodel.Entity:GetBonePosition(boneId)
    panel.pmodel.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))
    for k = 0, target:GetNumBodyGroups() - 1 do
        panel.pmodel.Entity:SetBodygroup(k, target:GetBodygroup(k))
    end
    panel.pmodel.Entity:SetSkin(target:GetNWInt("Skin"))
    panel.pmodel.Entity.AddGear = function(self, gearPanel)
        gearPanel.Model = gearPanel.gear:createCSModel(self)
        gearPanel.Model:SetNoDraw(true)
    end

    local panes = {
        { "mrp_nvgs", Rect(375, 25, 100, 100), "NVGs" },
        { "mrp_base_helmet", Rect(500, 25, 100, 100), "Helmet" },
        { "mrp_base_gear", Rect(500, 150, 100, 100), "Gasmask" },
        { "mrp_base_rucksack", Rect(375, 275, 100, 100), "Rucksack" },
        { "mrp_base_vest", Rect(500, 275, 100, 100), "Vest" },
        { "mrp_base_wep", Rect( 25, 580, 350, 100 ), "PrimaryWep", 100, 128 },
        { "mrp_base_wep", Rect( 400, 580, 225, 100 ), "SecondaryWep", 80 },
        { "mrp_base_wep", Rect( 25, 705, 600, 100 ), "RocketLauncher", 230, 128 },
    }


    for _, conf in ipairs(panes) do
        local bclassName = conf[1]
        local rect = conf[2]
        local mrpcat = conf[3]

        local bclass = baseclass.Get(bclassName)
        bclass.PaneLeftBorderW = (conf[4] or 18) * MRP.ScreenScale()
        bclass.PaneIconW = (conf[5] or 64) * MRP.ScreenScale()

        panel[mrpcat] = bclass:CreatePane(
            panel,
            target,
            rect,
            context,
            mrpcat
        ).entPanel or {} -- INDEX 1
        if IsValid(panel[mrpcat]) and bclassName ~= "mrp_base_wep" then
            panel.pmodel.Entity:AddGear(panel[mrpcat])
        end
    end

    if IsValid(panel.NVGs) and target:GetNWBool("NVGsOn") then
        panel.NVGs.Model:SetBodygroup(1, 1)
    end

    if IsValid(panel.Gasmask) and target:GetNWBool("GasmaskOn") then
        panel.Gasmask.Model:SetModel("models/gmod4phun/props/gasmask.mdl")
    end

    panel.Uniform = vgui.Create("MRPSpawnIcon", panel) -- INDEX 6
    panel.Uniform:SetPos(500, 400)
    panel.Uniform:SetSpawnIcon("icon64/uniform.png")
    panel.Uniform:SetSize(100, 100)
    panel.Uniform:SetTooltip("Treillis")
    panel.Uniform.gear = ents.CreateClientside("mrp_uniform")
    panel.Uniform.startingIndex = 1
    panel.Uniform.GetParent = function(_) return panel.pmodel end
    panel.Uniform.DoClick = MRP.selectContainer
    panel.Uniform.fullness = vgui.Create("MRPProgress", panel.Uniform)
    panel.Uniform.fullness:SetX(90)
    panel.Uniform.fullness:SetSize(10, 100)
    panel.Uniform.owner = target
    local function calcFilledUniformSlotCount()
        local filledUniformSlotCount = 0
        for k = 1, 5 do
            if target:MRPHas("Inventory" .. k) then
                filledUniformSlotCount = filledUniformSlotCount + 1
            end
        end
        return filledUniformSlotCount / 5
    end
    panel.Uniform.fullness.getFraction = calcFilledUniformSlotCount
    panel.Vest.startingIndex = 6
    panel.Rucksack.startingIndex = 11

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
hook.Add("CalcView", "InventoryOpening", function()
    if input.IsKeyDown(MRP.keybinds.inventory)
    and player_manager.GetPlayerClass(LocalPlayer()) ~= "player_spectator"
    and keyReleased then
        keyReleased = false
        if (not MRP.plyInvPanel or not MRP.plyInvPanel:IsValid())
            and not vgui.CursorVisible() then
            MRP.createDropZone()
            MRP.OpenPlyInvPanel(LocalPlayer(), false)
        elseif MRP.dropZone and MRP.dropZone.Remove then
            MRP.dropZone:Remove()
        end
    elseif not input.IsKeyDown(MRP.keybinds.inventory) then
        keyReleased = true
    end
end)

net.Receive("MRPPlayerNVGsToggle", function(_, _)
    local bodyId
    local uid = net.ReadUInt(16)
    local ply = Player(uid)
    if ply:GetNWBool("NVGsOn") then
        bodyId = 1
    else
        bodyId = 0
    end
    MRP.mountedGear[uid].NVGs:SetBodygroup(1, bodyId)
    if IsValid(MRP.plyInvPanel) then MRP.plyInvPanel.NVGs.Model:SetBodygroup(1, bodyId) end
end)

net.Receive("MRPPlayerTakeOnGasmask", function()
    local userid = net.ReadUInt(16)
    MRP.mountedGear[userid].Gasmask:SetModel("models/gmod4phun/props/gasmask.mdl")
    if IsValid(MRP.plyInvPanel) then
        MRP.plyInvPanel.Gasmask.Model:SetModel("models/gmod4phun/props/gasmask.mdl")
    end
end)

net.Receive("MRPPlayerTakeOffGasmask", function()
    local userid = net.ReadUInt(16)
    MRP.mountedGear[userid].Gasmask:SetModel("models/yukon/props/conscripts/maskbag.mdl")
    if IsValid(MRP.plyInvPanel) then
        MRP.plyInvPanel.Gasmask.Model:SetModel("models/yukon/props/conscripts/maskbag.mdl")
    end
end)

hook.Add("NetworkEntityCreated", "MRPNetworkEntityCreated", function(ent)
    local owner = ent:GetOwner()
    if owner:IsPlayer() and ent:GetClass() == "prop_ragdoll" then
        local ragdoll = ent
        ragdoll:CallOnRemove("MRPCallOnRemove", function()
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
            ragdoll:SetNWInt("Inventory" .. k,
                             owner:GetNWInt("Inventory" .. k))
            ragdoll:SetNWInt("Inventory" .. k .. "Rounds",
                             owner:GetNWInt("Inventory" .. k .. "Rounds"))
        end
        ragdoll:SetNWInt("Helmet", owner:GetNWInt("Helmet"))
        ragdoll:SetNWInt("HelmetArmor", owner:GetNWInt("HelmetArmor"))
        ragdoll:SetNWInt("NVGs", owner:GetNWInt("NVGs"))
        ragdoll:SetNWInt("Gasmask", owner:GetNWInt("Gasmask"))
        ragdoll:SetNWInt("Rucksack", owner:GetNWInt("Rucksack"))
        ragdoll:SetNWInt("Vest", owner:GetNWInt("Vest"))
        ragdoll:SetNWInt("VestArmor", owner:GetNWInt("VestArmor"))
        ragdoll:SetNWInt("PrimaryWep", owner:GetNWInt("PrimaryWep"))
        ragdoll:SetNWInt("SecondaryWep", owner:GetNWInt("SecondaryWep"))
        ragdoll:SetNWInt("RocketLauncher", owner:GetNWInt("RocketLauncher"))
        ragdoll:SetNWInt("Faction", owner:GetNWInt("Faction"))
        ragdoll:SetNWInt("ModelIndex", owner:GetNWInt("ModelIndex"))
        ragdoll:SetNWInt("GasmaskOn", owner:GetNWInt("GasmaskOn"))
        ragdoll:CallOnRemove("MRPCleanUpRagdoll", function()
            for _, gear in pairs(MRP.mountedGear[ragdollid]) do
                if gear.Remove then
                    gear:Remove()
                end
            end
        end)
    end
end)
