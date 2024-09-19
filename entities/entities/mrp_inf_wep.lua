AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Ravitaillement Rebelles"
ENT.Category = "4 - Caisses de ravitaillement"
ENT.Spawnable = true
ENT.Editable = true

local itemClasses = {
    "cw_kk_ins2_makarov",
    "cw_kk_ins2_nade_molotov",
    "cw_kk_ins2_mosin",
    "cw_kk_ins2_rpg",
    "cw_kk_ins2_nade_ied",
    "cw_kk_ins2_ak74",
    "cw_kk_ins2_nade_m18",
    "cw_kk_ins2_rpk"
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

    function ENT:Use(ply)
        --spawn the item
        local item = ents.Create(self:GetItemClass())
        item:Spawn()
        item:Use(ply)
    end
else
    function ENT:Initialize()
        self:Draw()
    end

    function ENT:Draw()
        self:DrawModel()
    end
end

properties.Add("mrp-rebels-weps", {
    MenuLabel = "Rebelle Weapon",
    Order = 602,
    MenuIcon = "icon16/application_form_edit.png",
    Filter = function(_, ent, _)
        if ent:GetClass() == "mrp_inf_wep" then return true end

        return false
    end,
    MenuOpen = function(self, option, ent, _)
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
    Receive = function(_, _, _)
        local ent = net.ReadEntity()
        local itemClass = net.ReadString()
        if not IsValid(ent) then return end
        ent:SetItemClass(itemClass)
    end
})
