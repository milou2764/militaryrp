AddCSLuaFile()

SWEP.HoldType = "camera"
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.PrintName = "Gas Mask"
SWEP.Slot = 99
SWEP.SlotPos = 99
SWEP.IconLetter = "G"
SWEP.IconLetterSelect = "G"
SWEP.ViewModelFOV = 60
SWEP.SwayScale = 0
SWEP.BobScale = 0
SWEP.Instructions = ""
SWEP.Author = "Gmod4phun"
SWEP.Contact = ""
SWEP.Weight = 0
SWEP.ViewModelFlip = false
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/gmod4phun/c_contagion_gasmask.mdl"
SWEP.WorldModel = "models/hunter/plates/plate.mdl"
SWEP.UseHands = false
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 0
SWEP.Primary.NumShots = 0
SWEP.Primary.Cone = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.Delay = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

function SWEP:DoDrawCrosshair(_, _)
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    return pos, ang
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
    if SERVER then
        local ply = self:GetOwner()

        local vm = ply:GetViewModel()

        if IsValid(vm) then
            vm:SendViewModelMatchingSequence(vm:LookupSequence("idle_holstered"))
        end
    end

    return true
end

function SWEP:PrimaryAttack()
    return false
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Holster()
    return true
end

function SWEP:Think()
    return true
end
