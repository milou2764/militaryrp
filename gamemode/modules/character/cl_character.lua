local faction = 1
local regiment = 1
local CharacPanel
local bdyGrpSlider

local function drawWarning(msg)
    local tmpLabel = vgui.Create("DLabel")
    tmpLabel:SetFont("DermaLarge")
    tmpLabel:SetText(msg)
    tmpLabel:SizeToContents()
    tmpLabel:Center()
    tmpLabel:SetColor(Color(255,0,0))
    tmpLabel:SetDrawOnTop(true)
    timer.Simple(2, function()
        tmpLabel:Remove()
    end)
end

local function characterCreation(ply)
    local ply = ply or LocalPlayer()
    local specsScroll
    local leftArrow
    CharacPanel = vgui.Create("MRPPanel")

    local header = vgui.Create( "DLabel", CharacPanel )
    header:SetFont( "DermaLarge" )
    header:SetText( "Création de personnage" )
    header:SizeToContents()
    header:CenterHorizontal( 0.5 )
    header:CenterVertical( 0.05 )

    local chooseLbl = vgui.Create( "DLabel", CharacPanel )
    chooseLbl:SetFont( "DermaLarge" )
    chooseLbl:SetText( "Choisissez votre faction" )
    chooseLbl:SizeToContents()
    chooseLbl:SetPos( ScrW() / 2 - chooseLbl:GetWide() / 2, 200 )

    local closeLbl = vgui.Create( "DLabel", CharacPanel )
    closeLbl:SetFont( "DermaLarge" )
    closeLbl:SetText( "CLOSE" )
    closeLbl:SizeToContents()
    closeLbl:Dock(BOTTOM)
    closeLbl:SetMouseInputEnabled( true )
    function closeLbl:DoClick()
        CharacPanel:SetVisible( false )
    end

    local armyBtn = vgui.Create( "DImageButton", CharacPanel )
    armyBtn:SetImage(MRP.Factions[0]["flag"])
    armyBtn:SizeToContents()
    armyBtn:SetPos( ScrW() / 2 - armyBtn:GetWide() - 100, ScrH() / 2 - 150 )

    local rebelBtn = vgui.Create( "DImageButton", CharacPanel )
    rebelBtn:SetImage(MRP.Factions[1]["flag"])
    rebelBtn:SizeToContents()
    rebelBtn:SetPos( ScrW() / 2 + 100, ScrH() / 2 - 150 )

    local function drawCharac()
        local function generateRPName()
            local fname = MRP.FirstName[math.random(#MRP.FirstName)]
            local lname = MRP.LastName[math.random(#MRP.LastName)]
            return fname .. " " .. lname
        end

        RPName = generateRPName()
        Size = math.random(MRP.minSize, MRP.maxSize)

        local rpnameEntry = vgui.Create("DTextEntry", CharacPanel)
        rpnameEntry:SetSize( 200, 35 )
        rpnameEntry:SetPlaceholderText( RPName )
        rpnameEntry:SetPos(ScrW() / 2 - 100, ScrH() / 10 + 20)
        rpnameEntry.OnLoseFocus = function( self )
            RPName = self:GetValue()
        end

        local generateBtn = vgui.Create( "DButton", CharacPanel )
        generateBtn:SetText( "Generate" )
        generateBtn:SetSize( 100, 30)
        local x = ScrW() / 2 - 100 + rpnameEntry:GetWide() + 20
        local y = ScrH() / 10 + 20
        generateBtn:SetPos( x, y )
        generateBtn.DoClick = function()
            RPName = generateRPName()
            rpnameEntry:SetPlaceholderText( RPName )
        end

        local mdlPanel = vgui.Create( "MRPAdjustableModelPanel", CharacPanel )
        mdlPanel:SetSize(ScrW() * 0.5, ScrH() * 0.8)
        mdlPanel:SetPos( 0.1 * ScrW(), 1.6 * ScrH() / 10 )
        local modelIdx = math.random( #MRP.PlayerModels[faction] )
        mdlPanel:SetModel( MRP.PlayerModels[faction][modelIdx].Model )
        mdlPanel.Entity:SetModelScale(Size / 180)
        mdlPanel.vCamPos = Vector(60, 40, 37.288376)

        function mdlPanel:LayoutEntity( _ ) return end	-- Disable cam rotation

        --local headpos =
         --   mdlPanel.Entity:GetBonePosition(mdlPanel.Entity:LookupBone("ValveBiped.Bip01_Head1"))
        --mdlPanel.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))

        local specsPanel = vgui.Create( "EditablePanel", CharacPanel )
        specsPanel:SetPos( ScrW() / 2, 4 * ScrH() / 10 )
        specsPanel:SetSize( ScrW() / 3, mdlPanel:GetTall() )

        local function loadBodygroup()
            local sizeSlider = vgui.Create("DNumSlider", specsScroll)
            sizeSlider:Dock(TOP)				-- Set the position
            sizeSlider:DockMargin(0, 0, 0, 0)
            sizeSlider:SetSize(300, 30)			-- Set the size
            sizeSlider:SetText("Size(cm)")	-- Set the text above the slider
            sizeSlider:SetMin(MRP.minSize)				 	-- Set the minimum number you can slide to
            sizeSlider:SetMax(MRP.maxSize)
            sizeSlider:SetDecimals(0)				-- Decimal places - zero for whole number
            sizeSlider:SetValue(math.random(MRP.minSize, MRP.maxSize))
            Size = sizeSlider:GetValue()
            mdlPanel.Entity:SetModelScale(Size / 180)
            sizeSlider.OnValueChanged = function(self)
                -- Called when the slider value changes
                Size = math.Round(self:GetValue(), 0)
                mdlPanel.Entity:SetModelScale(Size / 180)
            end
            if istable(MRP.PlayerModels[faction][modelIdx].skins) then
                local skinCount = #MRP.PlayerModels[faction][modelIdx].skins
                local skinSLider = vgui.Create( "DNumSlider", specsScroll )
                skinSLider:Dock(TOP)				-- Set the position
                skinSLider:DockMargin(0, 0, 0, 0)
                skinSLider:SetSize(300, 30)			-- Set the size
                skinSLider:SetText("Skin")	-- Set the text above the slider
                skinSLider:SetMin(1)				 	-- Set the minimum number you can slide to
                skinSLider:SetMax(skinCount)
                skinSLider:SetDecimals(0)				-- Decimal places - zero for whole number
                skinSLider:SetValue(math.random(1, skinCount))
                skin = MRP.PlayerModels[faction][modelIdx].skins[skinSLider:GetValue()]
                mdlPanel.Entity:SetSkin(skin)
                skinSLider.OnValueChanged = function( self )
                    -- Called when the slider value changes
                    local val = math.Round(self:GetValue(), 0)
                    skin = MRP.PlayerModels[faction][modelIdx].skins[val]
                    mdlPanel.Entity:SetSkin(skin)
                end
            else
                skin = MRP.PlayerModels[faction][modelIdx].skins
                mdlPanel.Entity:SetSkin(MRP.PlayerModels[faction][modelIdx].skins)
            end

            for i = 1, mdlPanel.Entity:GetNumBodyGroups() do
                if istable(MRP.PlayerModels[faction][modelIdx].bodygroups[i]) then
                    local lentgh = #MRP.PlayerModels[faction][modelIdx].bodygroups[i]
                    bdyGrpSlider = vgui.Create( "DNumSlider", specsScroll )
                    bdyGrpSlider:Dock(TOP)
                    bdyGrpSlider:DockMargin(0, 0, 0, 0)
                    bdyGrpSlider:SetSize( 300, 30 )
                    bdyGrpSlider:SetText( mdlPanel.Entity:GetBodygroupName(i - 1) )
                    bdyGrpSlider:SetMin( 1 )
                    bdyGrpSlider:SetMax(lentgh)
                    -- Decimal places - zero for whole number
                    bdyGrpSlider:SetDecimals( 0 )
                    local sliderVal = math.random(1, lentgh)
                    bdyGrpSlider:SetValue(sliderVal)
                    mdlPanel.Entity:SetBodygroup(
                        i - 1,
                        MRP.PlayerModels[faction][modelIdx].bodygroups[i][sliderVal])
                    bdyGrpSlider.OnValueChanged = function( self )
                        -- Called when the slider value changes
                        local val = math.Round(self:GetValue(), 0)
                        mdlPanel.Entity:SetBodygroup(
                            i - 1,
                            MRP.PlayerModels[faction][modelIdx].bodygroups[i][val]
                        )
                    end
                else
                    mdlPanel.Entity:SetBodygroup(
                        i - 1,
                        MRP.PlayerModels[faction][modelIdx].bodygroups[i]
                    )
                end
            end
        end

        local modelCount = #MRP.PlayerModels[faction]
        local modelSlider = vgui.Create("DNumSlider", specsPanel)
        modelSlider:Dock(TOP)
        modelSlider:DockMargin(0, 0, 0, 0)
        modelSlider:SetSize(300, 30 )
        modelSlider:SetText("Model")
        modelSlider:SetMin(0)
        modelSlider:SetMax(modelCount)
        modelSlider:SetDecimals(0)
        modelSlider:SetValue(modelIdx)
        mdlPanel.Entity:SetModelScale(Size / 180)

        local function loadModel()
            if specsScroll and specsScroll:IsValid() then specsScroll:Remove() end

            specsScroll = vgui.Create("DScrollPanel", specsPanel)
            specsScroll:Dock(TOP)
            specsScroll:SetSize(mdlPanel:GetWide(), mdlPanel:GetTall() - 30)

            mdlPanel:SetModel(MRP.PlayerModels[faction][modelIdx].Model)
            mdlPanel.Entity:SetModelScale(Size / 180)
            --mdlPanel.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))

            loadBodygroup()
        end
        loadModel()

        modelSlider.OnValueChanged = function(self)
            local val = math.Round(self:GetValue(), 0)
            if val - modelIdx ~= 0 then
                modelIdx = val
                loadModel()
            end
        end

        local doneBtn = vgui.Create( "DButton", CharacPanel )
        doneBtn:SetText("Done")
        doneBtn:SetSize(100, 30)
        doneBtn:SetPos(ScrW() / 2 - 50, 9 * ScrH() / 10)
        doneBtn.DoClick = function()
            net.Start("CharacterInformation")
            net.WriteUInt(faction, 2)
            net.WriteUInt(regiment, 4)
            net.WriteString(RPName)
            net.WriteUInt(modelIdx, 5)
            net.WriteUInt(Size, 8)
            net.WriteUInt(skin, 5)
            local BodyGroups = tostring(mdlPanel.Entity:GetBodygroup(0))
            for i = 1, mdlPanel.Entity:GetNumBodyGroups() - 1 do
                BodyGroups = BodyGroups .. "," .. tostring(mdlPanel.Entity:GetBodygroup(i))
            end
            net.WriteString(BodyGroups)
            net.SendToServer()

            CharacPanel:Remove()
        end
    end

    local function chooseRegiment()
        local h = 200
        local scrollPanel = vgui.Create("DHorizontalScroller", CharacPanel)
        scrollPanel:SetPos(0, 300)
        scrollPanel:SetSize(ScrW(), h)
        scrollPanel:SetOverlap( -40 )

        for i = 1, #MRP.Regiments[faction] do
            local reg = vgui.Create("DImageButton")
            reg:SetImage(MRP.Regiments[faction][i]["insignia"])
            reg:SizeToContents()
            local ratio = reg:GetWide() / reg:GetTall()
            reg:SetWide(h * ratio)
            reg.DoClick = function()
                if MRP.IsRegWL(LocalPlayer(), faction, i) then
                    regiment = i
                    scrollPanel:Remove()
                    chooseLbl:Remove()
                    drawCharac()
                else
                    drawWarning("Vous n'êtes pas inscrit")
                end
            end
            scrollPanel:AddPanel(reg)
        end
    end

    local function facButton(fac)
        if fac == 2 then
            drawWarning("Faction temporairement inaccessible")
            return
        end
        faction = fac
        chooseLbl:SetText("Choisissez votre régiment")
        chooseLbl:SizeToContents()
        chooseLbl:SetPos( ScrW() / 2 - chooseLbl:GetWide() / 2, 200 )
        armyBtn:Remove()
        rebelBtn:Remove()
        chooseRegiment()
    end


    armyBtn.DoClick = function()
        facButton(1)
    end

    rebelBtn.DoClick = function()
        facButton(2)
    end
end

local function characterSelection(ply)
    local selecPanel = vgui.Create("MRPPanel")
    selecPanel.Remove = function(self)
        if self.pmodel.Entity then
            for _, v in pairs(self.pmodel.Entity:GetChildren()) do
                v:Remove()
            end
        end
        baseclass.Get("MRPPanel").Remove(self)
    end

    local selecLabel = vgui.Create( "DLabel", selecPanel )
    selecLabel:SetFont("DermaLarge")
    selecLabel:SetTextColor(Color(255, 255, 255))
    selecLabel:SetText("Character selection")
    selecLabel:SizeToContents()
    selecLabel:CenterHorizontal(0.5)
    selecLabel:CenterVertical(0.05)

    local closeLbl = vgui.Create("DLabel", selecPanel)
    closeLbl:SetFont("DermaLarge")
    closeLbl:SetText("CLOSE")
    closeLbl:SizeToContents()
    closeLbl:Dock(BOTTOM)
    closeLbl:SetMouseInputEnabled(true)
    function closeLbl:DoClick()
        selecPanel:SetVisible(false)
    end

    

    local index = 1
    local rpname = vgui.Create("DLabel", selecPanel)
    rpname:SetFont("Trebuchet24")

    local regimentPanel = vgui.Create("DImage", selecPanel)
    regimentPanel:SetPos(ScrW() / 2 - 250, 250)
    regimentPanel:SetImageColor(Color(255, 255, 255, 160))

    selecPanel.pmodel = vgui.Create( "MRPAdjustableModelPanel", selecPanel )
    selecPanel.pmodel:SetSize(ScrW() / 2, 0.8 * ScrH())
    selecPanel.pmodel:SetPos(ScrW() / 2 - selecPanel.pmodel:GetWide() / 2, 200)
    selecPanel.pmodel.vCamPos = Vector(60, 40, 37.288376)


    local rankPanel = vgui.Create("DImage", selecPanel)

    function loadCharacter()
        local gears = {
            {"mrp_nvgs", "NVGs"},
            {"mrp_base_helmet", "Helmet"},
            {"mrp_base_gear", "Gasmask"},
            {"mrp_base_rucksack", "Rucksack"},
            {"mrp_base_vest", "Vest"},
        }
        local faction = MRP.Character[index]["Faction"]
        local regiment = MRP.Character[index]["Regiment"]
        Log.d("CharSelection", "faction: " .. tostring(faction))
        Log.d("CharSelection", "regiment: " .. tostring(regiment))
        local regImg = MRP.Regiments[faction][regiment]
        regimentPanel:SetImage(regImg["insignia"])
        regimentPanel:SetSize(500, 500 / regImg["whratio"])

        rpname:SetText( MRP.Character[index]["RPName"] )
        rpname:SizeToContents()
        rpname:SetPos( ScrW() / 2 - rpname:GetWide() / 2, ScrH() / 10 + 50 )

        rankPanel:SetPos(rpname:GetX() + rpname:GetWide() + 40, rpname:GetY())
        local rank = MRP.Character[index]["Rank"]
        rankPanel:SetImage(MRP.Ranks[faction][regiment][rank]["shoulderrank"])
        rankPanel:SizeToContents()

        local model = MRP.Character[index]["ModelIndex"]
        selecPanel.pmodel:SetModel( MRP.PlayerModels[faction][model].Model )
        for k, v in pairs(MRP.Character[index]["BodyGroups"]) do
            selecPanel.pmodel.Entity:SetBodygroup( k - 1, v )
        end
        selecPanel.pmodel.Entity:SetModelScale(tonumber(MRP.Character[index]["Size"]) / 180)
        selecPanel.pmodel.Entity:SetSkin( MRP.Character[index]["Skin"] )
        selecPanel.pmodel.Entity.Has = function(_, MRPCategory)
            return MRP.Character[index][MRPCategory] > 1
        end
        selecPanel.pmodel.Entity.getMRPID = function(_, MRPCategory)
            return MRP.Character[index][MRPCategory]
        end
        for _, conf in pairs(gears) do
            local className = conf[1]
            local cat = conf[2]
            local bclass = baseclass.Get(className)
            local entTab = MRP.EntityTable(MRP.Character[index][cat])
            local pm = selecPanel.pmodel.Entity
            if entTab.createCSModel then
                local gearModel = entTab:createCSModel(pm)
                gearModel:SetNoDraw(true)
            end
        end

        if leftArrow then leftArrow:Remove() RightArrow:Remove() end

        if #MRP.Character > 1 then
            leftArrow = vgui.Create( "DImageButton", selecPanel )
            leftArrow:SetSize( 16, 32)
            leftArrow:SetImage( "icon32/mvsa_arrow_left.png" )
            local x = selecPanel.pmodel:GetX() - 16
            local y = selecPanel.pmodel:GetY() + selecPanel.pmodel:GetTall() / 2
            leftArrow:SetPos(x, y)
            leftArrow.DoClick = function()
                if index > 1 then
                    index = index - 1
                    loadCharacter()
                else
                    index = #MRP.Character
                    loadCharacter()
                end
            end

            RightArrow = vgui.Create( "DImageButton", selecPanel )
            RightArrow:SetSize( 16, 32)
            RightArrow:SetImage( "icon32/mvsa_arrow_right.png" )
            local x1 = selecPanel.pmodel:GetX() + selecPanel.pmodel:GetWide()
            local y1 = selecPanel.pmodel:GetY() + selecPanel.pmodel:GetTall() / 2
            RightArrow:SetPos(x1, y1)
            RightArrow.DoClick = function()
                if index < #MRP.Character then
                    index = index + 1
                    loadCharacter()
                else
                    index = 1
                    loadCharacter()
                end
            end
        end
    end
    hook.Add("MRPEntitiesInitialized", "MRPDrawSelectionCharacter", function()
        loadCharacter()
    end)
    if MRP.EntitiesInitialized then
        loadCharacter()
    end

    local SelectButton = vgui.Create( "DLabel", selecPanel )
    SelectButton:SetFont( "DermaLarge" )
    SelectButton:SetText( "SELECT" )
    SelectButton:SizeToContents()
    SelectButton:Dock(LEFT)
    SelectButton:DockMargin( 200, ScrH() - ScrH() / 10, 0, 0)
    SelectButton:SetMouseInputEnabled( true )
    function SelectButton:DoClick()
        net.Start("CharacterSelected")
        net.WriteUInt(MRP.Character[index]["CharacterID"], 32)
        net.SendToServer()
        selecPanel:Remove()
    end

    local DeleteButton = vgui.Create( "DLabel", selecPanel )
    DeleteButton:SetFont( "DermaLarge" )
    DeleteButton:SetText( "DELETE" )
    DeleteButton:SizeToContents()
    DeleteButton:Dock(RIGHT)
    DeleteButton:DockMargin( 0, ScrH() - ScrH() / 10, 100, 0)
    DeleteButton:SetMouseInputEnabled( true )
    function DeleteButton:DoClick()
        local ConfirmationPanel = vgui.Create("DFrame", selecPanel)
        ConfirmationPanel:Center()
        ConfirmationPanel:SetTitle("Warning")
        ConfirmationPanel:SetSize( 400, 200 )

        local ConfirmationLabel = vgui.Create("DLabel", ConfirmationPanel)
        ConfirmationLabel:SetText("Your character will be removed permanently\nAre you sure?")
        ConfirmationLabel:SizeToContents()
        ConfirmationLabel:Center()

        local yesBtn = vgui.Create( "DButton", ConfirmationPanel )
        yesBtn:SetText("Yes")
        yesBtn:SetSize(60, 30)
        yesBtn:SetPos(375 - 60, 150)
        yesBtn.DoClick = function()
            net.Start("mrp_characters_deletion")
            net.WriteUInt(MRP.Character[index]["CharacterID"], 32)
            net.SendToServer()
            table.remove(MRP.Character, index)
            if index == 1 then index = #MRP.Character else index = index - 1 end
            if #MRP.Character > 0 then
                loadCharacter()
            else
                selecPanel:Remove()
                characterCreation( LocalPlayer() )
            end
            ConfirmationPanel:Remove()
        end

        local noBtn = vgui.Create( "DButton", ConfirmationPanel )
        noBtn:SetText("No")
        noBtn:SetSize(60, 30)
        noBtn:SetPos(25, 150)
        noBtn.DoClick = function()
            ConfirmationPanel:Remove()
        end
    end

    local sepLbl = vgui.Create("DLabel", selecPanel)
    sepLbl:SetFont("DermaLarge")
    sepLbl:SetText(" | ")
    sepLbl:SizeToContents()
    sepLbl:Dock(RIGHT)
    sepLbl:DockMargin( 0, ScrH() - ScrH() / 10, 0, 0)

    local newBtn = vgui.Create("DLabel", selecPanel)
    newBtn:SetFont("DermaLarge")
    newBtn:SetText("NEW")
    newBtn:SizeToContents()
    newBtn:Dock(RIGHT)
    newBtn:DockMargin(0, ScrH() - ScrH() / 10, 0, 0)
    newBtn:SetMouseInputEnabled(true)
    function newBtn:DoClick()
        selecPanel:Remove()
        characterCreation(ply)
    end
end

net.Receive("mrp_characters_creation", function()
    characterCreation(LocalPlayer())
end)

function charactersUpdate()
    MRP.Character = {}
    local namesCount = net.ReadUInt( 5 )
    for i = 1, namesCount do
        MRP.Character[i] = {}
        MRP.Character[i]["CharacterID"] = net.ReadUInt(32)
        MRP.Character[i]["Faction"] = net.ReadUInt(2)
        MRP.Character[i]["Regiment"] = net.ReadUInt(4)
        MRP.Character[i]["Rank"] = net.ReadUInt(5)
        MRP.Character[i]["RPName"] = net.ReadString()
        MRP.Character[i]["ModelIndex"] = net.ReadUInt(5)
        MRP.Character[i]["Size"] = tostring(net.ReadUInt(8))
        MRP.Character[i]["Skin"] = net.ReadUInt(5)
        MRP.Character[i]["BodyGroups"] = net.ReadString()
        MRP.Character[i]["BodyGroups"] = string.Split(MRP.Character[i]["BodyGroups"], ",")
        MRP.Character[i]["NVGs"] = net.ReadUInt(7)
        MRP.Character[i]["Helmet"] = net.ReadUInt(7)
        MRP.Character[i]["Gasmask"] = net.ReadUInt(7)
        MRP.Character[i]["Rucksack"] = net.ReadUInt(7)
        MRP.Character[i]["Vest"] = net.ReadUInt(7)
    end
end

net.Receive("mrp_characters_update", function(_, ply)
    charactersUpdate()
end)

net.Receive("mrp_characters_selection", function(_, ply)
    charactersUpdate()
    characterSelection(ply)
end)

concommand.Add(
    'mrp_characters',
    function(ply)
        characterSelection(ply)
    end,
    nil,
    'Open the character management menu'
)
