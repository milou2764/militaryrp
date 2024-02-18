AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Caisse de ravitaillement infini"
ENT.Category = "4 - Caisses de ravitaillement"
ENT.Spawnable = true
ENT.Editable = true

local itemClasses = {
    [1] = "mrp_vest1",
    [2] = "mrp_vest2",
    [3] = "mrp_vest3",
    [4] = "mrp_vest4",
    [5] = "mrp_vest5",
    [6] = "mrp_vest6",
    [7] = "mrp_vest7",
    [8] = "mrp_helmet1",
    [9] = "mrp_helmet2",
    [10] = "mrp_helmet3"
}

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ItemClass", {
        KeyName = "ItemClass",
        Edit = {
            type = "String"
        }
    })
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/wood_crate001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetItemClass(itemClasses[1])
        self:GetPhysicsObject():EnableMotion(false)
    end

    function ENT:Use(activator, caller)
        -- check if there is an item on top of the crate
        local items = ents.FindInSphere(self:GetPos() + Vector(0, 0, 30), 5)

        --check if the table contains an item
        for i = 1, #items do
            if items[i]:GetClass() == self:GetItemClass() then return end
        end

        --spawn the item
        local item = ents.Create(self:GetItemClass())
        item:SetPos(self:GetPos() + Vector(0, 0, 40))
        item:Spawn()
    end
else
    function ENT:Initialize()
        self:Draw()
    end

    function ENT:Draw()
        self:DrawModel()
    end
end

properties.Add("classe d'items", {
    MenuLabel = "Classe d'items",
    Order = 601,
    MenuIcon = "icon16/application_form_edit.png",
    Filter = function(self, ent, ply)
        if ent:GetClass() == "mrp_infinite_supply_crate" then return true end

        return false
    end,
    MenuOpen = function(self, option, ent, tr)
        --
        -- Add a submenu to our automatically created menu option
        --
        local submenu = option:AddSubMenu()

        --
        -- Create a check item for each skin
        --
        for i = 1, #itemClasses do
            local itemClass = itemClasses[i]

            local option1 = submenu:AddOption(itemClass, function()
                self:setItemClass(ent, itemClass)
            end)

            if ent:GetItemClass() == itemClass then
                option1:SetChecked(true)
            end
        end
    end,
    setItemClass = function(self, ent, itemClass)
        self:MsgStart()
        net.WriteEntity(ent)
        net.WriteString(itemClass)
        self:MsgEnd()
    end,
    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        local itemClass = net.ReadString()
        if not IsValid(ent) then return end
        ent:SetItemClass(itemClass)
    end
})