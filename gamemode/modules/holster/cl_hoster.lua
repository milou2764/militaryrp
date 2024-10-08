MRP.Holsters = MRP.Holsters or {}
local boneNames = {
    [0] = "ValveBiped.Bip01_Pelvis",
    [1] = "ValveBiped.Bip01_Spine",
    [2] = "ValveBiped.Bip01_Spine1",
    [3] = "ValveBiped.Bip01_Spine2",
    [4] = "ValveBiped.Bip01_Spine4",
    [5] = "ValveBiped.Bip01_Neck1",
    [6] = "ValveBiped.Bip01_Head1",
    [7] = "ValveBiped.Bip01_R_Clavicle",
    [8] = "ValveBiped.Bip01_R_UpperArm",
    [9] = "ValveBiped.Bip01_R_Forearm",
    [10] = "ValveBiped.Bip01_R_Hand",
    [11] = "ValveBiped.Bip01_L_Clavicle",
    [12] = "ValveBiped.Bip01_L_UpperArm",
    [13] = "ValveBiped.Bip01_L_Forearm",
    [14] = "ValveBiped.Bip01_L_Hand",
    [15] = "ValveBiped.Bip01_R_Thigh",
    [16] = "ValveBiped.Bip01_R_Calf",
    [17] = "ValveBiped.Bip01_R_Foot",
    [18] = "ValveBiped.Bip01_R_Toe0",
    [19] = "ValveBiped.Bip01_L_Thigh",
    [20] = "ValveBiped.Bip01_L_Calf",
    [21] = "ValveBiped.Bip01_L_Foot",
    [22] = "ValveBiped.Bip01_L_Toe0",
    [23] = "ValveBiped.Bip01_R_Finger4",
    [24] = "ValveBiped.Bip01_R_Finger41",
    [25] = "ValveBiped.Bip01_R_Finger42"
}

local function updateModelPos(model, ply, wepClass)
    wepClass = wepClass or model.wepClass
    local boneID = MRP.Holsters[wepClass].boneID
    -- Set position
    local matrix = ply:GetBoneMatrix(boneID)

    if not matrix then

        return
    end

    local newpos, newang =
        LocalToWorld(
            MRP.Holsters[wepClass].OffsetVec,
            MRP.Holsters[wepClass].OffsetAng,
            matrix:GetTranslation(),
            matrix:GetAngles()
        )
    model:SetPos(newpos)
    model:SetAngles(newang)
end

hook.Add("PostPlayerDraw", "MRPPostPlayerDraw", function(ply)
    local uid = ply:UserID()
    if IsValid(ply) and ply:Alive() and ply ~= LocalPlayer() then
        for k, model in pairs(MRP.MountedWeps[uid] or {}) do
            local wepClass = model.wepClass
            if not MRP.Holsters[wepClass] then
                MRP.MountedWeps[uid][k] = nil
                return
            end

            local boneID = MRP.Holsters[wepClass].boneID
            local matrix = ply:GetBoneMatrix(boneID)
            if not matrix then return end
            local newpos, newang =
                LocalToWorld(
                    MRP.Holsters[wepClass].OffsetVec,
                    MRP.Holsters[wepClass].OffsetAng,
                    matrix:GetTranslation(),
                    matrix:GetAngles()
                )
            model:SetPos(newpos)
            model:SetAngles(newang)
        end
    end
end)

net.Receive("mrp_request_holsters", function()
    local ply = net.ReadEntity()
    local old = net.ReadEntity()
    local new = net.ReadEntity()
    MRP.MountedWeps[ply:UserID()] = MRP.MountedWeps[ply:UserID()] or {}

    if MRP.Holsters[old.ClassName] then
        local oldMRPCategory = MRP.Holsters[old.ClassName].mrpcategory
        local oldModel = MRP.MountedWeps[ply:UserID()][oldMRPCategory]

        if oldModel and oldModel.SetNoDraw and IsValid(oldModel) then
            -- si le holster est valide, on le montre
            oldModel:SetNoDraw(false)
        else
            -- s'il n'y a pas de holster existant, on en crée un nouveau et on le montre
            local model =
                ClientsideModel(
                    MRP.Holsters[old.ClassName].Model,
                    RENDERGROUP_OPAQUE
                )
            MRP.MountedWeps[ply:UserID()][oldMRPCategory] = model
            model.wepClass = old.ClassName
            updateModelPos(model, ply, old.ClassName)
            model:SetNoDraw(false)
        end
    end

    if MRP.Holsters[new.ClassName] then
        local newMRPCategory = MRP.Holsters[new.ClassName].mrpcategory
        local model = MRP.MountedWeps[ply:UserID()][newMRPCategory]

        if model and model.SetNoDraw and IsValid(model) then
            -- si le joueur a un holster pour cette catégorie, on le cache
            model:SetNoDraw(true)
        end
    end
end)

local function setupEditor(ply, wepClass)
    if not MRP.Holsters[wepClass] then return end
    local modelStr = MRP.Holsters[wepClass].Model or "models/props_c17/oildrum001_explosive.mdl"
    local model = ClientsideModel(modelStr, RENDERGROUP_OPAQUE)
    model.wepClass = wepClass
    updateModelPos(model, ply)
    local editMenu = vgui.Create("DFrame")
    editMenu:SetSize(ScrW() * 0.4, ScrH() * 0.5)
    editMenu:SetTitle("Edit Holster")
    editMenu:MakePopup()

    local xPos = vgui.Create("DNumSlider", editMenu)
    xPos:SetPos(5, 30)
    xPos:SetSize(ScrW() * 0.4 - 10, 20)
    xPos:SetText("X Offset")
    xPos:SetMin(-100)
    xPos:SetMax(100)
    xPos:SetDecimals(2)
    xPos:SetValue(MRP.Holsters[wepClass].OffsetVec.x)

    xPos.OnValueChanged = function(_, val)
        MRP.Holsters[wepClass].OffsetVec.x = val
        updateModelPos(model, ply, wepClass)
    end

    local yPos = vgui.Create("DNumSlider", editMenu)
    yPos:SetPos(5, 60)
    yPos:SetSize(ScrW() * 0.4 - 10, 20)
    yPos:SetText("Y Offset")
    yPos:SetMin(-100)
    yPos:SetMax(100)
    yPos:SetDecimals(2)
    yPos:SetValue(MRP.Holsters[wepClass].OffsetVec.y)

    yPos.OnValueChanged = function(_, val)
        MRP.Holsters[wepClass].OffsetVec.y = val
        updateModelPos(model, ply, wepClass)
    end

    local zPos = vgui.Create("DNumSlider", editMenu)
    zPos:SetPos(5, 90)
    zPos:SetSize(ScrW() * 0.4 - 10, 20)
    zPos:SetText("Z Offset")
    zPos:SetMin(-100)
    zPos:SetMax(100)
    zPos:SetDecimals(2)
    zPos:SetValue(MRP.Holsters[wepClass].OffsetVec.z)

    zPos.OnValueChanged = function(_, val)
        MRP.Holsters[wepClass].OffsetVec.z = val
        updateModelPos(model, ply, wepClass)
    end

    local xAng = vgui.Create("DNumSlider", editMenu)
    xAng:SetPos(5, 120)
    xAng:SetSize(ScrW() * 0.4 - 10, 20)
    xAng:SetText("X Ang")
    xAng:SetMin(-180)
    xAng:SetMax(180)
    xAng:SetDecimals(2)
    xAng:SetValue(MRP.Holsters[wepClass].OffsetAng.p)

    xAng.OnValueChanged = function(_, val)
        MRP.Holsters[wepClass].OffsetAng.p = val
        updateModelPos(model, ply, wepClass)
    end

    local yAng = vgui.Create("DNumSlider", editMenu)
    yAng:SetPos(5, 150)
    yAng:SetSize(ScrW() * 0.4 - 10, 20)
    yAng:SetText("Y Ang")
    yAng:SetMin(-180)
    yAng:SetMax(180)
    yAng:SetDecimals(2)
    yAng:SetValue(MRP.Holsters[wepClass].OffsetAng.y)

    yAng.OnValueChanged = function(_, val)
        MRP.Holsters[wepClass].OffsetAng.y = val
        updateModelPos(model, ply, wepClass)
    end

    local zAng = vgui.Create("DNumSlider", editMenu)
    zAng:SetPos(5, 180)
    zAng:SetSize(ScrW() * 0.4 - 10, 20)
    zAng:SetText("Z Ang")
    zAng:SetMin(-180)
    zAng:SetMax(180)
    zAng:SetDecimals(2)
    zAng:SetValue(MRP.Holsters[wepClass].OffsetAng.r)

    zAng.OnValueChanged = function(_, val)
        MRP.Holsters[wepClass].OffsetAng.r = val
        updateModelPos(model, ply, wepClass)
    end

    local boneName = vgui.Create("DComboBox", editMenu)
    boneName:SetPos(5, 210)
    boneName:SetSize(ScrW() * 0.4 - 10, 20)
    LocalPlayer():SetupBones()
    boneName:SetValue(LocalPlayer():GetBoneName(MRP.Holsters[wepClass].boneID))

    for i = 0, #boneNames do
        boneName:AddChoice(boneNames[i])
    end

    boneName.OnSelect = function(_, _, value)
        LocalPlayer():SetupBones()
        MRP.Holsters[wepClass].boneID = LocalPlayer():LookupBone(value)
        updateModelPos(model, ply, wepClass)
    end

    local mrpcategory = vgui.Create("DComboBox", editMenu)
    mrpcategory:SetPos(5, 240)
    mrpcategory:SetSize(ScrW() * 0.4 - 10, 20)
    mrpcategory:SetValue(MRP.Holsters[wepClass].mrpcategory)
    mrpcategory:AddChoice("PrimaryWep")
    mrpcategory:AddChoice("SecondaryWep")
    mrpcategory:AddChoice("RocketLauncher")
    local save = vgui.Create("DButton", editMenu)
    save:SetPos(5, 270)
    save:SetSize(ScrW() * 0.4 - 10, 20)
    save:SetText("Save")

    save.DoClick = function()
        model:Remove()
        MRP.Holsters[wepClass].mrpcategory = mrpcategory:GetValue()
        local uid = LocalPlayer():UserID()
        local wepCat = MRP.Holsters[wepClass].mrpcategory
        local currentModel = MRP.MountedWeps[uid][wepCat]

        if currentModel then
            currentModel:Remove()
            MRP.MountedWeps[uid][MRP.Holsters[wepClass].mrpcategory] =
                ClientsideModel(MRP.Holsters[wepClass].Model, RENDERGROUP_OPAQUE)
            MRP.MountedWeps[uid][MRP.Holsters[wepClass].mrpcategory].WeaponClass = wepClass
        end


        net.Start("mrp_save_holsters")
        net.WriteString(wepClass)
        net.WriteTable(MRP.Holsters[wepClass])
        net.SendToServer()
        editMenu:Close()
    end
end


local function editHolsters(ply)
    if not ply:IsAdmin() then return end
    local wepClass = ""
    local wepClassSelect = vgui.Create("DFrame")
    wepClassSelect:SetSize(ScrW() * 0.4, ScrH() * 0.4)
    wepClassSelect:SetTitle("Select Weapon Class")
    wepClassSelect:MakePopup()
    local cbox = vgui.Create("DComboBox", wepClassSelect)
    cbox:SetPos(5, 30)
    cbox:SetSize(ScrW() * 0.4 - 10, 20)

    for _, v in pairs(MRP.WeaponClasses) do
        if not MRP.Holsters[v] then
            cbox:AddChoice(v)
        end
    end

    local newWepMRPCategory = vgui.Create("DComboBox", wepClassSelect)
    newWepMRPCategory:SetPos(5, 60)
    newWepMRPCategory:SetSize(ScrW() * 0.4 - 10, 20)
    newWepMRPCategory:SetValue("PrimaryWep")
    newWepMRPCategory:AddChoice("PrimaryWep")
    newWepMRPCategory:AddChoice("SecondaryWep")
    newWepMRPCategory:AddChoice("RocketLauncher")
    local newWepModel = vgui.Create("DLabel", wepClassSelect)
    newWepModel:SetPos(5, 90)
    newWepModel:SetSize(ScrW() * 0.4 - 10, 20)
    newWepModel:SetText("worlmodel")
    local openBrowser = vgui.Create("DButton", wepClassSelect)
    openBrowser:SetPos(ScrW() * 0.4 - 300, 90)
    openBrowser:SetSize(295, 20)
    openBrowser:SetText("Open Model Browser")

    openBrowser.DoClick = function()
        local browser = vgui.Create("DFrame")
        browser:SetSize(ScrW() * 0.4, ScrH() * 0.6)
        browser:SetTitle("Model Browser")
        browser:MakePopup()
        local modelList = vgui.Create("DListView", browser)
        modelList:SetPos(5, 50)
        modelList:SetSize(ScrW() * 0.4 - 10, ScrH() * 0.4 - 35)
        modelList:AddColumn("Path")

        modelList.OnRowSelected = function(_, _, line)
            newWepModel:SetText(line:GetValue(2))
        end

        local modelSearch = vgui.Create("DTextEntry", browser)
        modelSearch:SetPos(5, 25)
        modelSearch:SetSize(ScrW() * 0.4 - 10, 20)
        modelSearch:SetPlaceholderText("Search")

        modelSearch.OnEnter = function()
            local search = modelSearch:GetValue()
            modelList:Clear()
            local modelTab = {}
            local paths = {
                "models/weapons/",
                "models/tom/weapons/famas/",
                "models/tom/weapons/frf2/",
                "models/tom/weapons/glock/",
                "models/tom/weapons/hecate/",
                "models/tom/weapons/hk416/",
                "models/tom/weapons/hk417/",
                "models/tom/weapons/minimi/",
                "models/tom/weapons/scar_hpr/",
                "models/bs/weapons/rif/",
                "models/bs/weapons/snip/",
                "models/bs/weapons/mg/",
            }
            for _, p in pairs(paths) do
                local tmp = file.Find(p.."w_*.mdl", "GAME")
                for k, v in pairs(tmp) do
                    tmp[k] = p..v
                end
                table.Add(modelTab, tmp)
            end

            for _, v in pairs(modelTab) do
                if string.find(v, search) then
                    local line = modelList:AddLine(v)

                    line.OnMousePressed = function(code)
                        newWepModel:SetText(v)
                    end
                end
            end
        end

        modelSearch:OnEnter()
        local confirm = vgui.Create("DButton", browser)
        confirm:SetPos(5, ScrH() * 0.4 + 25)
        confirm:SetSize(ScrW() * 0.4 - 10, 20)
        confirm:SetText("Confirm")

        confirm.DoClick = function()
            browser:Close()
        end
    end

    local newWep = vgui.Create("DButton", wepClassSelect)
    newWep:SetPos(5, 120)
    newWep:SetSize(ScrW() * 0.4 - 10, 20)
    newWep:SetText("Create New Weapon")

    newWep.DoClick = function()
        wepClass = cbox:GetValue()

        MRP.Holsters[wepClass] = {
            OffsetVec = Vector(0, 0, 0),
            OffsetAng = Angle(0, 0, 0),
            boneID = 0,
            mrpcategory = newWepMRPCategory:GetValue(),
            Model = newWepModel:GetValue()
        }

        wepClassSelect:Close()
        setupEditor(ply, wepClass)
    end

    local wepClassList = vgui.Create("DScrollPanel", wepClassSelect)
    wepClassList:SetPos(5, 150)
    wepClassList:SetSize(ScrW() * 0.4 - 10, ScrH() * 0.4 - 155)
    for class, _ in pairs(MRP.Holsters) do
        local p = wepClassList:Add("DPanel")
        p:Dock(TOP)
        local b = vgui.Create("DButton",p)
        b:SetText(class)
        b:SetWidth(200)
        b.DoClick = function()
            wepClassSelect:Close()
            setupEditor(ply, class)
        end
        local d = vgui.Create("DButton",p)
        d:SetText("DEL")
        d:Dock(RIGHT)
        d:DockMargin( 0, 0, 0, 5 )
        d.DoClick = function()
            table.RemoveByValue(MRP.Holsters, MRP.Holsters[class])
            p:Remove()
        end

    end
end

concommand.Add("mrp_editholster", editHolsters)

net.Receive("mmrp_request_holsters", function()
    local wepClass = net.ReadString()
    local data = net.ReadTable()
    MRP.Holsters[wepClass] = data
end)
