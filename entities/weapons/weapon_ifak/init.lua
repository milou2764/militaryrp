AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"
SWEP.Bandages = 2
SWEP.Quikclots = 3
SWEP.Hemostats = 3

local td = {}

function SWEP:Equip()
    self:GetOwner():GiveAmmo(self.Bandages, "Bandages", true)
    self:GetOwner():GiveAmmo(self.Hemostats, "Hemostats", true)
    self:GetOwner():GiveAmmo(self.Quikclots, "Quikclots", true)
end

function SWEP:Deploy()
    self:SetUpBodygroups()
end

local Mins, Maxs = Vector(-8, -8, -8), Vector(8, 8, 8)

function SWEP:FindHealTarget()
    td.start = self:GetOwner():GetShootPos()
    td.endpos = td.start + self:GetOwner():GetAimVector() * 50
    td.filter = self:GetOwner()
    td.mins = Mins
    td.maxs = Maxs
    tr = util.TraceHull(td)

    if tr.Hit then
        ent = tr.Entity
        if IsValid(ent) and ent:IsPlayer() then return ent end
    end

    return self:GetOwner()
end

function SWEP:PrimaryAttack()
    if self:GetOwner():GetAmmo()[game.GetAmmoID("Bandages")] then
        self:GetOwner():RemoveAmmo(1, "Bandages")
        target = self:FindHealTarget()
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_1)

        timer.Simple(3, function()
            self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)
            self:SetUpBodygroups()
        end)

        self.Bandages = self.Bandages - 1
        target:SetHealth(math.Clamp(target:Health() + 10, 0, 100))
    end
end

function SWEP:SecondaryAttack()
    if self:GetOwner():GetAmmo()[game.GetAmmoID("Hemostats")] then
        target = self:FindHealTarget()
        self:SendWeaponAnim(ACT_SPECIAL_ATTACK1)

        timer.Simple(4, function()
            self:SendWeaponAnim(ACT_SPECIAL_ATTACK2)
            timer.Simple(2, function()
                self:SetUpBodygroups()
            end)
        end)

        self:GetOwner():RemoveAmmo(1, "Hemostats")
        self.Hemostats = self.Hemostats - 1
        target:SetHealth(math.Clamp(target:Health() + 30, 0, 100))
    elseif self:GetOwner():GetAmmo()[game.GetAmmoID("Quikclots")] then
        self:SetUpBodygroups()
        target = self:FindHealTarget()
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_3)

        timer.Simple(4, function()
            self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_4)
            self:SetUpBodygroups()
        end)

        self:GetOwner():RemoveAmmo(1, "Quikclots")
        self.Quikclots = self.Quikclots - 1
        target:SetHealth(math.Clamp(target:Health() + 10, 0, 100))
    end
end

function SWEP:SetUpBodygroups()
    self:GetOwner():GetViewModel():SetBodygroup(
        2,
        math.Clamp(self:GetOwner():GetAmmoCount("Bandages"),
        0,
        2)
    )
    am = self:GetOwner():GetAmmoCount("Hemostats")

    if am > 0 then
        self:GetOwner():GetViewModel():SetBodygroup(3, 2)
    else
        am = self:GetOwner():GetAmmoCount("Quikclots")

        if am > 0 then
            self:GetOwner():GetViewModel():SetBodygroup(3, 1)
        else
            self:GetOwner():GetViewModel():SetBodygroup(3, 0)
        end
    end
end
