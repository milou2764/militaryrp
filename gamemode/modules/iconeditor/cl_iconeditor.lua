concommand.Add("mrp_iconeditor", function(_, _, _, _)
    local frame = vgui.Create( "DFrame" ) -- Container for the SpawnIcon
    frame:SetPos( 200, 200 )
    frame:SetSize( 1000, 1000 )
    frame:SetTitle( "Icon Editor" )
    frame:MakePopup()

    local modelPathSelect = vgui.Create("DComboBox", frame)
    modelPathSelect:SetPos(10, 30)
    modelPathSelect:SetSize(200, 20)
    modelPathSelect:SetValue("Select a model path")
    for k, _ in pairs(MRP.entityModels) do
        modelPathSelect:AddChoice(k)
    end

    local iconTypeSelect = vgui.Create("DComboBox", frame)
    iconTypeSelect:SetPos(10, 60)
    iconTypeSelect:SetSize(200, 20)
    iconTypeSelect:SetValue("PrimaryWep")
    iconTypeSelect:AddChoice("PrimaryWep")
    iconTypeSelect:AddChoice("SecondaryWep")
    iconTypeSelect:AddChoice("RocketLauncher")
    iconTypeSelect:AddChoice("spawnmenu")
    iconTypeSelect:AddChoice("weaponwheel")


    local selectButton = vgui.Create("DButton", frame)
    selectButton:SetPos(10, 90)
    selectButton:SetSize(200, 20)
    selectButton:SetText("Select")
    selectButton.DoClick = function()
        local icon = vgui.Create( "SpawnIcon", frame ) -- SpawnIcon, with blue barrel model
        icon:Center()
        -- It is important below to include the SkinID (0 = default skin); the IconEditor
        -- will not work otherwise
        icon:SetModel(MRP.entityModels[modelPathSelect:GetValue()], 0 )
        local iconType = iconTypeSelect:GetValue()
        if iconType == "PrimaryWep" then
            icon:SetSize(350, 100)
        elseif iconType == "SecondaryWep" then
            icon:SetSize(225, 100)
        elseif iconType == "RocketLauncher" then
            icon:SetSize(600, 100)
        elseif iconType == "spawnmenu" then
            icon:SetSize(100, 100)
        elseif iconType == "weaponwheel" then
            icon:SetSize(256, 128)
        end

        local editor = vgui.Create( "IconEditor" ) -- Create IconEditor
        editor:SetIcon( icon ) -- Set the SpawnIcon to modify
        editor:Refresh() -- Sets up the internal DAdjustableModelPanel and SpawnIcon
        editor:MakePopup()
        editor:Center()
    end

end)
