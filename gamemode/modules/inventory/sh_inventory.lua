local chests = {
    ["mrp_crate"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true
}

properties.Add("chest", {
    MenuLabel = "Inventaire", -- Name to display on the context menu
    Order = 9999, -- The order to display this property relative to other properties
    MenuIcon = "icon16/application_form_edit.png", -- The icon to display next to the property
    Filter = function(_, ent, ply)
        if chests[ent.ClassName] and ply:GetPos():Distance(ent:GetPos()) < 200 then
            return true
        end
        return false
    end, -- A function that determines whether an entity is valid for this property
    Action = function(_, ent)
        MRP.createDropZone()
        MRP.OpenPlyInvPanel(LocalPlayer())
        MRP.OpenChest(ent)
    end, -- The action to perform upon using the property ( Clientside )

    -- @param self
    -- @param length
    -- @param ply
    Receive = function(_, _, _)
    end -- The action to perform upon using the property ( Serverside )
})
properties.Add("ragdollInventory", {
    MenuLabel = "Inventaire",
    Order = 9999,
    MenuIcon = "icon16/application_form_edit.png",

    -- @param self
    -- @param ent
    -- @param ply
    Filter = function(_, ent, _)
        if ent:GetNWInt("Inventory1") > 0 and not chests[ent.ClassName] then return true end
        return false
    end,

    -- @param self
    -- @param ent
    Action = function(_, ent)
        MRP.createDropZone()
        if not IsValid(MRP.plyInvPanel) then
            MRP.OpenPlyInvPanel(LocalPlayer())
        end
        MRP.OpenRagdollInvPanel(ent)
    end,

    -- @param self
    -- @param length
    -- @param ply
    Receive = function(_, _, _)
    end -- The action to perform upon using the property ( Serverside )
})
