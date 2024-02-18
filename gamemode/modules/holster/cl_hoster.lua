local function TableToLua(tbl, indent)
    indent = indent or 4
    local str = "{\n"

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            str = str .. string.rep(" ", indent) .. tostring(k) .. " = " .. TableToLua(v, indent + 4) .. ",\n"
        else
            str = str .. string.rep(" ", indent) .. tostring(k) .. " = " .. tostring(v) .. ",\n"
        end
    end

    str = str .. string.rep(" ", indent - 4) .. "}"

    return str
end

local datafile = file.Open("mrp_holsters.txt", "r", "DATA")

if datafile then
    MRP.holsters = util.JSONToTable(datafile:Read(datafile:Size()))
else
    MRP.holsters = {
        m9k_m4a1 = {
            offsetvec = Vector(-13.054831, 13.577024, 5.744125),
            boneID = 4,
            model = "models/weapons/w_m4a1_iron.mdl",
            offsetang = Angle(47.937, -12.219, 3.760),
            mrpcategory = "PrimaryWep",
        },
        m9k_m92beretta = {
            offsetvec = Vector(1.562500, 2.593750, -5.218750),
            mrpcategory = "SecondaryWep",
            offsetang = Angle(-86.469, -14.094, 96.812),
            model = "models/weapons/w_beretta_m92.mdl",
            boneID = 18,
        },
    }
end

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
    --print("triggered for " .. tostring(ply))
    local boneID = MRP.holsters[wepClass].boneID
    -- Set position
    local matrix = ply:GetBoneMatrix(boneID)

    if not matrix then
        print("no matrix")

        return
    end

    local newpos, newang = LocalToWorld(MRP.holsters[wepClass].offsetvec, MRP.holsters[wepClass].offsetang, matrix:GetTranslation(), matrix:GetAngles())
    model:SetPos(newpos)
    model:SetAngles(newang)
end

hook.Add("PostPlayerDraw", "MRPPostPlayerDraw", function(ply)
    if IsValid(ply) and ply:Alive() then
        for _, model in pairs(MRP.mountedWeps[ply:UserID()] or {}) do
            local wepClass = wepClass or model.wepClass
            local boneID = MRP.holsters[wepClass].boneID
            local matrix = ply:GetBoneMatrix(boneID)
            if not matrix then return end
            local newpos, newang = LocalToWorld(MRP.holsters[wepClass].offsetvec, MRP.holsters[wepClass].offsetang, matrix:GetTranslation(), matrix:GetAngles())
            model:SetPos(newpos)
            model:SetAngles(newang)
        end
    end
end)

net.Receive("MRPRequestHolsters", function()
    local ply = net.ReadEntity()
    local old = net.ReadEntity()
    local new = net.ReadEntity()
    MRP.mountedWeps[ply:UserID()] = MRP.mountedWeps[ply:UserID()] or {}

    if MRP.holsters[old.ClassName] then
        local oldMRPCategory = MRP.holsters[old.ClassName].mrpcategory
        local oldModel = MRP.mountedWeps[ply:UserID()][oldMRPCategory]

        if oldModel and oldModel.SetNoDraw and IsValid(oldModel) then
            -- si le holster est valide, on le montre
            oldModel:SetNoDraw(false)
        else
            -- s'il n'y a pas de holster existant, on en crée un nouveau et on le montre
            local model = ClientsideModel(MRP.holsters[old.ClassName].model, RENDERGROUP_OPAQUE)
            MRP.mountedWeps[ply:UserID()][oldMRPCategory] = model
            model.wepClass = old.ClassName
            updateModelPos(model, ply, old.ClassName)
            model:SetNoDraw(false)
        end
    end

    if MRP.holsters[new.ClassName] then
        local newMRPCategory = MRP.holsters[new.ClassName].mrpcategory
        local model = MRP.mountedWeps[ply:UserID()][newMRPCategory]

        if model and model.SetNoDraw and IsValid(model) then
            -- si le joueur a un holster pour cette catégorie, on le cache
            model:SetNoDraw(true)
        end
    end
end)

local function setupEditor(ply, wepClass)
    if not MRP.holsters[wepClass] then return end
    local model = ClientsideModel(MRP.holsters[wepClass].model, RENDERGROUP_OPAQUE)
    model.wepClass = wepClass
    updateModelPos(model, ply)
    local editMenu = vgui.Create("DFrame")
    editMenu:SetSize(ScrW() * 0.4, ScrH() * 0.5)
    editMenu:SetTitle("Edit Holster")
    editMenu:MakePopup()

    editMenu.OnClose = function(menu)
        model:Remove()
    end

    local xPos = vgui.Create("DNumSlider", editMenu)
    xPos:SetPos(5, 30)
    xPos:SetSize(ScrW() * 0.4 - 10, 20)
    xPos:SetText("X Offset")
    xPos:SetMin(-100)
    xPos:SetMax(100)
    xPos:SetDecimals(2)
    xPos:SetValue(MRP.holsters[wepClass].offsetvec.x)

    xPos.OnValueChanged = function(self, val)
        MRP.holsters[wepClass].offsetvec.x = val
        updateModelPos(model, ply, wepClass)
    end

    local yPos = vgui.Create("DNumSlider", editMenu)
    yPos:SetPos(5, 60)
    yPos:SetSize(ScrW() * 0.4 - 10, 20)
    yPos:SetText("Y Offset")
    yPos:SetMin(-100)
    yPos:SetMax(100)
    yPos:SetDecimals(2)
    yPos:SetValue(MRP.holsters[wepClass].offsetvec.y)

    yPos.OnValueChanged = function(self, val)
        MRP.holsters[wepClass].offsetvec.y = val
        updateModelPos(model, ply, wepClass)
    end

    local zPos = vgui.Create("DNumSlider", editMenu)
    zPos:SetPos(5, 90)
    zPos:SetSize(ScrW() * 0.4 - 10, 20)
    zPos:SetText("Z Offset")
    zPos:SetMin(-100)
    zPos:SetMax(100)
    zPos:SetDecimals(2)
    zPos:SetValue(MRP.holsters[wepClass].offsetvec.z)

    zPos.OnValueChanged = function(self, val)
        MRP.holsters[wepClass].offsetvec.z = val
        updateModelPos(model, ply, wepClass)
    end

    local xAng = vgui.Create("DNumSlider", editMenu)
    xAng:SetPos(5, 120)
    xAng:SetSize(ScrW() * 0.4 - 10, 20)
    xAng:SetText("X Ang")
    xAng:SetMin(-180)
    xAng:SetMax(180)
    xAng:SetDecimals(2)
    xAng:SetValue(MRP.holsters[wepClass].offsetang.p)

    xAng.OnValueChanged = function(self, val)
        MRP.holsters[wepClass].offsetang.p = val
        updateModelPos(model, ply, wepClass)
    end

    local yAng = vgui.Create("DNumSlider", editMenu)
    yAng:SetPos(5, 150)
    yAng:SetSize(ScrW() * 0.4 - 10, 20)
    yAng:SetText("Y Ang")
    yAng:SetMin(-180)
    yAng:SetMax(180)
    yAng:SetDecimals(2)
    yAng:SetValue(MRP.holsters[wepClass].offsetang.y)

    yAng.OnValueChanged = function(self, val)
        MRP.holsters[wepClass].offsetang.y = val
        updateModelPos(model, ply, wepClass)
    end

    local zAng = vgui.Create("DNumSlider", editMenu)
    zAng:SetPos(5, 180)
    zAng:SetSize(ScrW() * 0.4 - 10, 20)
    zAng:SetText("Z Ang")
    zAng:SetMin(-180)
    zAng:SetMax(180)
    zAng:SetDecimals(2)
    zAng:SetValue(MRP.holsters[wepClass].offsetang.r)

    zAng.OnValueChanged = function(self, val)
        MRP.holsters[wepClass].offsetang.r = val
        updateModelPos(model, ply, wepClass)
    end

    local boneName = vgui.Create("DComboBox", editMenu)
    boneName:SetPos(5, 210)
    boneName:SetSize(ScrW() * 0.4 - 10, 20)
    LocalPlayer():SetupBones()
    boneName:SetValue(LocalPlayer():GetBoneName(MRP.holsters[wepClass].boneID))

    for i = 0, #boneNames do
        boneName:AddChoice(boneNames[i])
    end

    boneName.OnSelect = function(self, index, value)
        LocalPlayer():SetupBones()
        MRP.holsters[wepClass].boneID = LocalPlayer():LookupBone(value)
        updateModelPos(model, ply, wepClass)
    end

    local mrpcategory = vgui.Create("DComboBox", editMenu)
    mrpcategory:SetPos(5, 240)
    mrpcategory:SetSize(ScrW() * 0.4 - 10, 20)
    mrpcategory:SetValue(MRP.holsters[wepClass].mrpcategory)
    mrpcategory:AddChoice("PrimaryWep")
    mrpcategory:AddChoice("SecondaryWep")
    mrpcategory:AddChoice("RocketLauncher")
    local save = vgui.Create("DButton", editMenu)
    save:SetPos(5, 270)
    save:SetSize(ScrW() * 0.4 - 10, 20)
    save:SetText("Save")

    save.DoClick = function()
        model:Remove()
        MRP.holsters[wepClass].mrpcategory = mrpcategory:GetValue()
        local currentModel = MRP.mountedWeps[LocalPlayer():UserID()][MRP.holsters[wepClass].mrpcategory]

        if currentModel then
            currentModel:Remove()
            MRP.mountedWeps[LocalPlayer():UserID()][MRP.holsters[wepClass].mrpcategory] = ClientsideModel(MRP.holsters[wepClass].model, RENDERGROUP_OPAQUE)
            MRP.mountedWeps[LocalPlayer():UserID()][MRP.holsters[wepClass].mrpcategory].wepClass = wepClass
        end

        print("[\"" .. wepClass .. "\"] = {")
        print("    offsetvec = Vector(" .. MRP.holsters[wepClass].offsetvec.x .. ", " .. MRP.holsters[wepClass].offsetvec.y .. ", " .. MRP.holsters[wepClass].offsetvec.z .. "),")
        print("    offsetang = Angle(" .. MRP.holsters[wepClass].offsetang.x .. ", " .. MRP.holsters[wepClass].offsetang.y .. ", " .. MRP.holsters[wepClass].offsetang.z .. "),")
        print("    boneID = " .. MRP.holsters[wepClass].boneID)
        print("},")
        datafile = file.Open("mrp_holsters.txt", "w", "DATA")
        datafile:Write(util.TableToJSON(MRP.holsters))
        datafile:Close()
        datafile = file.Open("mrp_holsters_lua.txt", "w", "DATA")
        datafile:Write(TableToLua(MRP.holsters))
        datafile:Close()
        net.Start("MRPSaveHolster")
        net.WriteString(wepClass)
        net.WriteTable(MRP.holsters[wepClass])
        net.SendToServer()
        editMenu:Close()
    end
end

concommand.Add("mrp_editholster", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local wepClass = ""
    local wepClassSelect = vgui.Create("DFrame")
    wepClassSelect:SetSize(ScrW() * 0.4, ScrH() * 0.4)
    wepClassSelect:SetTitle("Select Weapon Class")
    wepClassSelect:MakePopup()
    local newWepClass = vgui.Create("DComboBox", wepClassSelect)
    newWepClass:SetPos(5, 30)
    newWepClass:SetSize(ScrW() * 0.4 - 10, 20)
    newWepClass:SetValue(MRP.weaponClasses[1])

    for _, v in pairs(MRP.weaponClasses) do
        newWepClass:AddChoice(v)
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
    newWepModel:SetText(weapons.Get(newWepClass:GetValue()).WorldModel)
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
        modelList:AddColumn("Model")
        modelList:AddColumn("Path")

        modelList.OnRowSelected = function(self, index, line)
            newWepModel:SetText(line:GetValue(2))
        end

        local modelSearch = vgui.Create("DTextEntry", browser)
        modelSearch:SetPos(5, 25)
        modelSearch:SetSize(ScrW() * 0.4 - 10, 20)
        modelSearch:SetPlaceholderText("Search")

        modelSearch.OnEnter = function()
            local search = modelSearch:GetValue()
            modelList:Clear()

            for k, v in pairs(file.Find("models/weapons/w_*.mdl", "GAME")) do
                if string.find(v, search) then
                    local line = modelList:AddLine(v, "models/weapons/" .. v)

                    line.OnRowSelected = function(self, index, row)
                        newWepModel:SetText(row:GetValue(2))
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
        wepClass = newWepClass:GetValue()

        MRP.holsters[wepClass] = {
            offsetvec = Vector(0, 0, 0),
            offsetang = Angle(0, 0, 0),
            boneID = 0,
            mrpcategory = newWepMRPCategory:GetValue(),
            model = newWepModel:GetValue()
        }

        wepClassSelect:Close()
        setupEditor(ply, wepClass)
    end

    local wepClassList = vgui.Create("DListView", wepClassSelect)
    wepClassList:SetPos(5, 150)
    wepClassList:SetSize(ScrW() * 0.4 - 10, ScrH() * 0.4 - 155)
    wepClassList:AddColumn("Weapon Class")

    for k, v in pairs(MRP.holsters) do
        wepClassList:AddLine(k)
    end

    wepClassList.OnRowSelected = function(self, lineID, line)
        wepClass = line:GetValue(1)
        wepClassSelect:Close()
        setupEditor(ply, wepClass)
    end
end)

net.Receive("MRPUpdateHolsters", function()
    local wepClass = net.ReadString()
    local data = net.ReadTable()
    MRP.holsters[wepClass] = data
end)