local chests = {
    ["mrp_crate"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true
}

properties.Add("chest", {
    MenuLabel = "Inventaire", -- Name to display on the context menu
    Order = 9999, -- The order to display this property relative to other properties
    MenuIcon = "icon16/application_form_edit.png", -- The icon to display next to the property
    Filter = function(self, ent, ply)
        if chests[ent.ClassName] and ply:GetPos():Distance(ent:GetPos()) < 200 then return true end
        return false
    end, -- A function that determines whether an entity is valid for this property
    Action = function(self, ent)
        MRP.createDropZone()
        MRP.OpenPlyInvPanel(LocalPlayer())
        MRP.OpenChest(ent)
    end, -- The action to perform upon using the property ( Clientside )
    Receive = function(self, length, ply)
    end -- The action to perform upon using the property ( Serverside )

})
properties.Add("ragdollInventory", {
    MenuLabel = "Inventaire",
    Order = 9999,
    MenuIcon = "icon16/application_form_edit.png",
    Filter = function(self, ent, ply)
        if ent:GetNWInt("Inventory1") > 0 and not chests[ent.ClassName] then return true end
        return false
    end,
    Action = function(self, ent)
        MRP.createDropZone()
        if not IsValid(MRP.plyInvPanel) then
            MRP.OpenPlyInvPanel(LocalPlayer())
        end
        MRP.OpenRagdollInvPanel(ent)
    end,
    Receive = function(self, length, ply)
    end

})