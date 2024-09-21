local keyData = file.Open("mrp/keybinds.txt", "r", "DATA")
MRP.MountedWeps = MRP.MountedWeps or {}

if keyData then
    MRP.keybinds = util.JSONToTable(keyData:Read(keyData:Size()))
    keyData:Close()
else
    MRP.keybinds = {
        gasmask = KEY_G,
        nvgs = KEY_N,
        inventory = KEY_I,
    }
end

if not MRP.keybinds then
    MRP.keybinds = {
        gasmask = KEY_G,
        nvgs = KEY_N,
        inventory = KEY_I,
    }
end

hook.Add("AddToolMenuCategories", "CustomCategory", function()
    spawnmenu.AddToolCategory("Utilities", "Stuff", "#Stuff")
end)

hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
    local gasmaskKeyBinder = vgui.Create("MRPBinder")
    gasmaskKeyBinder:SetValue(MRP.keybinds.gasmask)

    gasmaskKeyBinder.OnChange = function(_, val)
        MRP.keybinds.gasmask = val
        file.Write("mrp/keybinds.txt", util.TableToJSON(MRP.keybinds))
    end

    gasmaskKeyBinder:Hide()
    local nvgsKeyBinder = vgui.Create("MRPBinder")
    nvgsKeyBinder:SetValue(MRP.keybinds.nvgs)

    nvgsKeyBinder.OnChange = function(_, val)
        MRP.keybinds.nvgs = val
        file.Write("mrp/keybinds.txt", util.TableToJSON(MRP.keybinds))
    end

    nvgsKeyBinder:Hide()
    local inventoryKeyBinder = vgui.Create("MRPBinder")
    inventoryKeyBinder:SetValue(MRP.keybinds.inventory)

    inventoryKeyBinder.OnChange = function(_, val)
        MRP.keybinds.inventory = val
        file.Write("mrp/keybinds.txt", util.TableToJSON(MRP.keybinds))
    end

    inventoryKeyBinder:Hide()

    spawnmenu.AddToolMenuOption(
        "Utilities",
        "Stuff",
        "Custom_Menu",
        "#My Custom Menu",
        "",
        "",
        function(panel)
            panel:ClearControls()
            panel:NumSlider("Gravity", "sv_gravity", 0, 600)
        end
    )

    -- Add stuff here
    spawnmenu.AddToolMenuOption(
        "Options",
        "MilitaryRP",
        "MilitaryRP_keybinds",
        "#Bind keys",
        "",
        "",
        function(panel)
            panel:ClearControls()
            panel:Help("Gasmask")
            panel:AddItem(gasmaskKeyBinder)
            gasmaskKeyBinder:Show()
            panel:Help("NVGs")
            panel:AddItem(nvgsKeyBinder)
            nvgsKeyBinder:Show()
            panel:Help("Inventory")
            panel:AddItem(inventoryKeyBinder)
            inventoryKeyBinder:Show()
        end
    )
end)
