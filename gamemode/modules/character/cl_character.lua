local faction = 1
local Regiment = 1
local CharacPanel
local BodygroupSlider

local function character_creation( ply )
    ply = ply or LocalPlayer()
    CharacPanel = vgui.Create("MRPPanel")

    local CharacCreationLabel = vgui.Create( "DLabel", CharacPanel )
    CharacCreationLabel:SetFont( "DermaLarge" )
    CharacCreationLabel:SetText( "Création de personnage" )
    CharacCreationLabel:SizeToContents()
    CharacCreationLabel:CenterHorizontal( 0.5 )
    CharacCreationLabel:CenterVertical( 0.05 )

    local ChooseLabel = vgui.Create( "DLabel", CharacPanel )
    ChooseLabel:SetFont( "DermaLarge" )
    ChooseLabel:SetText( "Choisissez votre faction" )
    ChooseLabel:SizeToContents()
    ChooseLabel:SetPos( ScrW() / 2 - ChooseLabel:GetWide() / 2, 200 )

    local CloseLabel = vgui.Create( "DLabel", CharacPanel )
    CloseLabel:SetFont( "DermaLarge" )
    CloseLabel:SetText( "CLOSE" )
    CloseLabel:SizeToContents()
    CloseLabel:Dock(BOTTOM)
    CloseLabel:SetMouseInputEnabled( true )
    function CloseLabel:DoClick()
        CharacPanel:SetVisible( false )
    end

    local FranceButton = vgui.Create( "DImageButton", CharacPanel )
    FranceButton:SetImage(MRP.Factions[0]["flag"])
    FranceButton:SizeToContents()
    FranceButton:SetPos( ScrW() / 2 - FranceButton:GetWide() - 100, ScrH() / 2 - 150 )

    local RebelButton = vgui.Create( "DImageButton", CharacPanel )
    RebelButton:SetImage(MRP.Factions[1]["flag"])
    RebelButton:SizeToContents()
    RebelButton:SetPos( ScrW() / 2 + 100, ScrH() / 2 - 150 )

    local function DrawCharacPerso()
        local function generateRPName()
            local fname = MRP.FirstName[math.random(#MRP.FirstName)]
            local lname = MRP.LastName[math.random(#MRP.LastName)]
            return fname .. " " .. lname
        end

        RPName = generateRPName()
        Size = math.random(MRP.minSize, MRP.maxSize)

        local RPNameEntry = vgui.Create("DTextEntry", CharacPanel)
        RPNameEntry:SetSize( 200, 35 )
        RPNameEntry:SetPlaceholderText( RPName )
        RPNameEntry:SetPos(ScrW() / 2 - 100, ScrH() / 10 + 20)
        RPNameEntry.OnLoseFocus = function( self )
            RPName = self:GetValue()
        end

        local GenerateButton = vgui.Create( "DButton", CharacPanel )
        GenerateButton:SetText( "Generate" )
        GenerateButton:SetSize( 100, 30)
        local x = ScrW() / 2 - 100 + RPNameEntry:GetWide() + 20
        local y = ScrH() / 10 + 20
        GenerateButton:SetPos( x, y )
        GenerateButton.DoClick = function()
            RPName = generateRPName()
            RPNameEntry:SetPlaceholderText( RPName )
        end

        local Model = vgui.Create( "MRPAdjustableModelPanel", CharacPanel )
        Model:SetSize(ScrW() * 0.5, ScrH() * 0.8)
        Model:SetPos( 0.1 * ScrW(), 1.6 * ScrH() / 10 )
        ModelIndex = math.random( #MRP.PlayerModels[faction] )
        Model:SetModel( MRP.PlayerModels[faction][ModelIndex].Model )
        Model.Entity:SetModelScale(Size / 180)
        Model.vCamPos = Vector(60, 40, 37.288376)

        function Model:LayoutEntity( _ ) return end	-- Disable cam rotation

        --local headpos =
         --   Model.Entity:GetBonePosition(Model.Entity:LookupBone("ValveBiped.Bip01_Head1"))
        --Model.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))

        SpecPanel = vgui.Create( "EditablePanel", CharacPanel )
        SpecPanel:SetPos( ScrW() / 2, 4 * ScrH() / 10 )
        SpecPanel:SetSize( ScrW() / 3, Model:GetTall() )

        local function LoadBodygroup()
            SizeSlider = vgui.Create( "DNumSlider", ScrollPanel )
            SizeSlider:Dock( TOP )				-- Set the position
            SizeSlider:DockMargin(0, 0, 0, 0)
            SizeSlider:SetSize(300, 30)			-- Set the size
            SizeSlider:SetText("Size(cm)")	-- Set the text above the slider
            SizeSlider:SetMin(MRP.minSize)				 	-- Set the minimum number you can slide to
            SizeSlider:SetMax(MRP.maxSize)
            SizeSlider:SetDecimals(0)				-- Decimal places - zero for whole number
            SizeSlider:SetValue(math.random(MRP.minSize, MRP.maxSize))
            Size = SizeSlider:GetValue()
            Model.Entity:SetModelScale(Size / 180)
            SizeSlider.OnValueChanged = function(self)
                -- Called when the slider value changes
                Size = math.Round(self:GetValue(), 0)
                Model.Entity:SetModelScale(Size / 180)
            end
            if istable(MRP.PlayerModels[faction][ModelIndex].skins) then
                local skinCount = #MRP.PlayerModels[faction][ModelIndex].skins
                local skinSLider = vgui.Create( "DNumSlider", ScrollPanel )
                skinSLider:Dock(TOP)				-- Set the position
                skinSLider:DockMargin(0, 0, 0, 0)
                skinSLider:SetSize(300, 30)			-- Set the size
                skinSLider:SetText("Skin")	-- Set the text above the slider
                skinSLider:SetMin(1)				 	-- Set the minimum number you can slide to
                skinSLider:SetMax(skinCount)
                skinSLider:SetDecimals(0)				-- Decimal places - zero for whole number
                skinSLider:SetValue(math.random(1, skinCount))
                skin = MRP.PlayerModels[faction][ModelIndex].skins[skinSLider:GetValue()]
                Model.Entity:SetSkin(skin)
                skinSLider.OnValueChanged = function( self )
                    -- Called when the slider value changes
                    local val = math.Round(self:GetValue(), 0)
                    skin = MRP.PlayerModels[faction][ModelIndex].skins[val]
                    Model.Entity:SetSkin(skin)
                end
            else
                skin = MRP.PlayerModels[faction][ModelIndex].skins
                Model.Entity:SetSkin(MRP.PlayerModels[faction][ModelIndex].skins)
            end

            for i = 1, Model.Entity:GetNumBodyGroups() do
                if istable(MRP.PlayerModels[faction][ModelIndex].bodygroups[i]) then
                    local lentgh = #MRP.PlayerModels[faction][ModelIndex].bodygroups[i]
                    BodygroupSlider = vgui.Create( "DNumSlider", ScrollPanel )
                    BodygroupSlider:Dock(TOP)
                    BodygroupSlider:DockMargin(0, 0, 0, 0)
                    BodygroupSlider:SetSize( 300, 30 )
                    BodygroupSlider:SetText( Model.Entity:GetBodygroupName(i - 1) )
                    BodygroupSlider:SetMin( 1 )
                    BodygroupSlider:SetMax(lentgh)
                    -- Decimal places - zero for whole number
                    BodygroupSlider:SetDecimals( 0 )
                    local sliderVal = math.random(1, lentgh)
                    BodygroupSlider:SetValue(sliderVal)
                    Model.Entity:SetBodygroup(
                        i - 1,
                        MRP.PlayerModels[faction][ModelIndex].bodygroups[i][sliderVal])
                    BodygroupSlider.OnValueChanged = function( self )
                        -- Called when the slider value changes
                        local val = math.Round(self:GetValue(), 0)
                        Model.Entity:SetBodygroup(
                            i - 1,
                            MRP.PlayerModels[faction][ModelIndex].bodygroups[i][val]
                        )
                    end
                else
                    Model.Entity:SetBodygroup(
                        i - 1,
                        MRP.PlayerModels[faction][ModelIndex].bodygroups[i]
                    )
                end
            end
        end

        local modelCount = #MRP.PlayerModels[faction]
        ModelSlider = vgui.Create("DNumSlider", SpecPanel)
        ModelSlider:Dock(TOP)
        ModelSlider:DockMargin(0, 0, 0, 0)
        ModelSlider:SetSize(300, 30 )
        ModelSlider:SetText("Model")
        ModelSlider:SetMin(0)
        ModelSlider:SetMax(modelCount)
        ModelSlider:SetDecimals(0)
        ModelSlider:SetValue(ModelIndex)
        Model.Entity:SetModelScale(Size / 180)

        local function LoadModel()
            if ScrollPanel and ScrollPanel:IsValid() then ScrollPanel:Remove() end

            ScrollPanel = vgui.Create("DScrollPanel", SpecPanel)
            ScrollPanel:Dock(TOP)
            ScrollPanel:SetSize(Model:GetWide(), Model:GetTall() - 30)

            Model:SetModel(MRP.PlayerModels[faction][ModelIndex].Model)
            Model.Entity:SetModelScale(Size / 180)
            --Model.Entity:SetEyeTarget(headpos-Vector(-15, 0, 0))

            LoadBodygroup()
        end
        LoadModel()

        ModelSlider.OnValueChanged = function(self)
            local val = math.Round(self:GetValue(), 0)
            if val - ModelIndex ~= 0 then
                ModelIndex = val
                LoadModel()
            end
        end

        local doneBtn = vgui.Create( "DButton", CharacPanel )
        doneBtn:SetText( "Done" )
        doneBtn:SetSize( 100, 30)
        doneBtn:SetPos( ScrW() / 2 - 50, 9 * ScrH() / 10 )
        doneBtn.DoClick = function()
            net.Start( "CharacterInformation" )
            net.WriteUInt( faction, 2 )
            net.WriteUInt( Regiment, 4 )
            net.WriteString( RPName )
            net.WriteUInt( ModelIndex, 5 )
            net.WriteUInt( Size, 8 )
            net.WriteUInt( skin, 5 )
            local BodyGroups = tostring(Model.Entity:GetBodygroup(0))
            for i = 1, Model.Entity:GetNumBodyGroups() - 1 do
                BodyGroups = BodyGroups .. "," .. tostring(Model.Entity:GetBodygroup(i))
            end
            net.WriteString(BodyGroups)
            net.SendToServer()

            CharacPanel:Remove()
        end
    end

    local function chooseRegiment()
        local h = 700
        local scrollPanel = vgui.Create("DHorizontalScroller", CharacPanel)
        scrollPanel:SetPos(0, 300)
        scrollPanel:SetSize(ScrW(), h)
        scrollPanel:SetOverlap( -40 )

        for i = 1, #MRP.Regiments[faction] do
            local Reg = vgui.Create("DImageButton")
            Reg:SetImage(MRP.Regiments[faction][i]["insignia"])
            Reg:SizeToContents()
            local ratio = Reg:GetWide() / Reg:GetTall()
            Reg:SetWide(h * ratio)
            Reg.DoClick = function()
                Regiment = i
                scrollPanel:Remove()
                ChooseLabel:Remove()
                DrawCharacPerso()
            end
            scrollPanel:AddPanel(Reg)
        end
    end

    local function facButton(fac)
        faction = fac
        ChooseLabel:SetText("Choisissez votre régiment")
        ChooseLabel:SizeToContents()
        ChooseLabel:SetPos( ScrW() / 2 - ChooseLabel:GetWide() / 2, 200 )
        FranceButton:Remove()
        RebelButton:Remove()
        chooseRegiment()
    end


    FranceButton.DoClick = function()
        facButton(1)
    end

    RebelButton.DoClick = function()
        facButton(2)
    end
end

local function character_selection(ply)
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

    local CloseLabel = vgui.Create( "DLabel", selecPanel )
    CloseLabel:SetFont( "DermaLarge" )
    CloseLabel:SetText( "CLOSE" )
    CloseLabel:SizeToContents()
    CloseLabel:Dock(BOTTOM)
    CloseLabel:SetMouseInputEnabled( true )
    function CloseLabel:DoClick()
        selecPanel:SetVisible( false )
    end

    local Character = {}
    local namesCount = net.ReadUInt( 5 )
    for i = 1, namesCount do
        Character[i] = {}
        Character[i]["CharacterID"] = net.ReadUInt(32)
        Character[i]["Faction"] = net.ReadUInt(1)
        Character[i]["Regiment"] = net.ReadUInt(4)
        Character[i]["Rank"] = net.ReadUInt(5)
        Character[i]["RPName"] = net.ReadString()
        Character[i]["ModelIndex"] = net.ReadUInt(5)
        Character[i]["Size"] = tostring(net.ReadUInt(8))
        Character[i]["Skin"] = net.ReadUInt(5)
        Character[i]["BodyGroups"] = net.ReadString()
        Character[i]["BodyGroups"] = string.Split(Character[i]["BodyGroups"], ",")
        Character[i]["NVGs"] = net.ReadUInt(7)
        Character[i]["Helmet"] = net.ReadUInt(7)
        Character[i]["Gasmask"] = net.ReadUInt(7)
        Character[i]["Rucksack"] = net.ReadUInt(7)
        Character[i]["Vest"] = net.ReadUInt(7)
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

    function LoadCharacter()
        local gears = {
            {"mrp_nvgs", "NVGs"},
            {"mrp_base_helmet", "Helmet"},
            { "mrp_base_gear", "Gasmask" },
            { "mrp_base_rucksack", "Rucksack" },
            { "mrp_base_vest", "Vest" },
        }
        local faction = Character[index]["Faction"]
        local regiment = Character[index]["Regiment"]
        Log.d("CharSelection", "faction: " .. tostring(faction))
        Log.d("CharSelection", "regiment: " .. tostring(regiment))
        local regImg = MRP.Regiments[faction][regiment]
        regimentPanel:SetImage(regImg["insignia"])
        regimentPanel:SetSize(500, 500 / regImg["whratio"])

        rpname:SetText( Character[index]["RPName"] )
        rpname:SizeToContents()
        rpname:SetPos( ScrW() / 2 - rpname:GetWide() / 2, ScrH() / 10 + 50 )

        rankPanel:SetPos(rpname:GetX() + rpname:GetWide() + 40, rpname:GetY())
        local rank = Character[index]["Rank"]
        rankPanel:SetImage(MRP.Ranks[faction][regiment][rank]["shoulderrank"])
        rankPanel:SizeToContents()

        local model = Character[index]["ModelIndex"]
        selecPanel.pmodel:SetModel( MRP.PlayerModels[faction][model].Model )
        for k, v in pairs(Character[index]["BodyGroups"]) do
            selecPanel.pmodel.Entity:SetBodygroup( k - 1, v )
        end
        selecPanel.pmodel.Entity:SetModelScale(tonumber(Character[index]["Size"]) / 180)
        selecPanel.pmodel.Entity:SetSkin( Character[index]["Skin"] )
        selecPanel.pmodel.Entity.Has = function(_, MRPCategory)
            return Character[index][MRPCategory] > 1
        end
        selecPanel.pmodel.Entity.getMRPID = function(_, MRPCategory)
            return Character[index][MRPCategory]
        end
        for _, conf in pairs(gears) do
            local className = conf[1]
            local cat = conf[2]
            local bclass = baseclass.Get(className)
            local entTab = MRP.EntityTable(Character[index][cat])
            local pm = selecPanel.pmodel.Entity
            if entTab.createCSModel then
                local gearModel = entTab:createCSModel(pm)
                gearModel:SetNoDraw(true)
            end
        end

        if LeftArrow then LeftArrow:Remove() RightArrow:Remove() end

        if namesCount > 1 then
            LeftArrow = vgui.Create( "DImageButton", selecPanel )
            LeftArrow:SetSize( 16, 32)
            LeftArrow:SetImage( "icon32/mvsa_arrow_left.png" )
            local x = selecPanel.pmodel:GetX() - 16
            local y = selecPanel.pmodel:GetY() + selecPanel.pmodel:GetTall() / 2
            LeftArrow:SetPos(x, y)
            LeftArrow.DoClick = function()
                if index > 1 then
                    index = index - 1
                    LoadCharacter()
                else
                    index = namesCount
                    LoadCharacter()
                end
            end

            RightArrow = vgui.Create( "DImageButton", selecPanel )
            RightArrow:SetSize( 16, 32)
            RightArrow:SetImage( "icon32/mvsa_arrow_right.png" )
            local x1 = selecPanel.pmodel:GetX() + selecPanel.pmodel:GetWide()
            local y1 = selecPanel.pmodel:GetY() + selecPanel.pmodel:GetTall() / 2
            RightArrow:SetPos(x1, y1)
            RightArrow.DoClick = function()
                if index < namesCount then
                    index = index + 1
                    LoadCharacter()
                else
                    index = 1
                    LoadCharacter()
                end
            end
        end
    end
    hook.Add("MRPEntitiesInitialized", "MRPDrawSelectionCharacter", function()
        LoadCharacter()
    end)
    if MRP.EntitiesInitialized then
        LoadCharacter()
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
        net.WriteUInt(Character[index]["CharacterID"], 32)
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

        local YesButton = vgui.Create( "DButton", ConfirmationPanel )
        YesButton:SetText("Yes")
        YesButton:SetSize(60, 30)
        YesButton:SetPos(375 - 60, 150)
        YesButton.DoClick = function()
            net.Start("DeleteCharacter")
            net.WriteUInt(Character[index]["CharacterID"], 32)
            net.SendToServer()
            table.remove(Character, index)
            namesCount = namesCount - 1
            if index == 1 then index = namesCount else index = index - 1 end
            if namesCount > 0 then
                LoadCharacter()
            else
                selecPanel:Remove()
                character_creation( LocalPlayer() )
            end
            ConfirmationPanel:Remove()
        end

        local NoButton = vgui.Create( "DButton", ConfirmationPanel )
        NoButton:SetText("No")
        NoButton:SetSize(60, 30)
        NoButton:SetPos(25, 150)
        NoButton.DoClick = function()
            ConfirmationPanel:Remove()
        end
    end

    local SeparationLabel = vgui.Create("DLabel", selecPanel)
    SeparationLabel:SetFont("DermaLarge")
    SeparationLabel:SetText(" | ")
    SeparationLabel:SizeToContents()
    SeparationLabel:Dock(RIGHT)
    SeparationLabel:DockMargin( 0, ScrH() - ScrH() / 10, 0, 0)

    local NewButton = vgui.Create("DLabel", selecPanel)
    NewButton:SetFont("DermaLarge")
    NewButton:SetText("NEW")
    NewButton:SizeToContents()
    NewButton:Dock(RIGHT)
    NewButton:DockMargin(0, ScrH() - ScrH() / 10, 0, 0)
    NewButton:SetMouseInputEnabled(true)
    function NewButton:DoClick()
        selecPanel:Remove()
        character_creation(ply)
    end
end

net.Receive("CharacterCreation", function()
    character_creation()
end)

net.Receive("CharacterSelection", function(_, ply)
    character_selection(ply)
end)
