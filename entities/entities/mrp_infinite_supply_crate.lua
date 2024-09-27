AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Caisse de ravitaillement infini"
ENT.Category = "4 - Caisses de ravitaillement"
ENT.Spawnable = true
ENT.Editable = true

local itemClasses = {
    "mrp_nvgs",
    "mrp_ent_gasmask",

    "mrp_helmet1",
    "mrp_helmet2",
    "mrp_helmet3",

    "mrp_musette",
    "mrp_sacf2",

    "mrp_vest1",
    "mrp_vest2",
    "mrp_vest3",
    "mrp_vest4",
    "mrp_vest5",
    "mrp_vest6",
    "mrp_vest7",
    "mrp_vest8",

    "mrp_beret_501rcc",
    "mrp_beret_rima",
    "mrp_beret_rpima",
    "mrp_beret_legion",
    "mrp_beret_2rep",
    "mrp_beret_ca",
    "mrp_beret_1rpima",
    "mrp_bob_ce",
    "mrp_beret_fm",
    "mrp_beret_genie",
    "mrp_beret_cm",
    "mrp_beret_1rpima",
    "mrp_beret_2rep",
    "mrp_beret_501rcc",
    "mrp_beret_alat",
    "mrp_beret_ca",
    "mrp_beret_cm",
    "mrp_beret_fm",
    "mrp_beret_genie",
    "mrp_beret_legion",
    "mrp_beret_rima",
    "mrp_beret_rpima",
    "mrp_bob_ce",
    "mrp_beret_alat",

    "mrp_fn_maximi_mk1",
    "mrp_fn_minimi_mk1",
    "mrp_fn_minimi_mk3",
    "mrp_fn_scarh_pr",
    "mrp_giat_famas_f1",
    "mrp_giat_famas_felin",
    "mrp_giat_famas_inf",
    "mrp_giat_famas_valorise",
    "mrp_giat_frf2",
    "mrp_giat_pamas_g1",
    "mrp_glock17_gen5",
    "mrp_hk416_fc",
    "mrp_hk416_fs",
    "mrp_hk417_dmr",
    "mrp_pgm_hecate_2",
    "mrp_at4cs",

    "mrp_ammobox_762x51mm",
    "mrp_ammobox_556x45mm",
    "mrp_ammobox_556x45mm_nato",
    "mrp_ammobox_9x19mm",
    "mrp_ammobox_127x99mm",
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

    function ENT:Use(_, _)
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
    Filter = function(_, ent, _)
        if ent:GetClass() == "mrp_infinite_supply_crate" then return true end

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
