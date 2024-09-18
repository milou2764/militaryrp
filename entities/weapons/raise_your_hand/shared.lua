--
SWEP.Base = "leafy_base"
SWEP.AdminSpawnable = true
SWEP.AutoSwitchTo = false
SWEP.Slot = 4
SWEP.PrintName = "Lever la main"
SWEP.Author = "Leafdroid"
SWEP.Spawnable = true
SWEP.AutoSwitchFrom = false
SWEP.Weight = 5
SWEP.DrawCrosshair = false
SWEP.CustomCrosshair = false
SWEP.CrossColor = Color(0, 255, 0, 150)
SWEP.Category = "Gestes"
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.Instructions = "Hold left click to dab and right click to shout YEAH!"
SWEP.Contact = "Leafdroids@gmail.com"
SWEP.HoldType = "normal"
SWEP.ViewModelFOV = 113
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/c_pistol.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.LaserSight = 0
SWEP.Dissolve = 1
SWEP.IronsightTime = 0.1
SWEP.DisableMuzzle = 1

SWEP.ViewModelBoneMods = {
    ["ValveBiped.Bip01_R_Finger31"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 67.777, 0)
    },
    ["ValveBiped.Bip01_R_Finger11"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 52.222, 0)
    },
    ["ValveBiped.Bip01_R_UpperArm"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(-2.408, 9.074, -9.445),
        angle = Angle(-41.112, -41.112, -47.778)
    },
    ["ValveBiped.Bip01_L_UpperArm"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(-30, -30, -30),
        angle = Angle(0, 0, 0)
    },
    ["ValveBiped.Bip01_R_Finger42"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 94.444, 0)
    },
    ["ValveBiped.Bip01_R_Finger2"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 30, 0)
    },
    ["ValveBiped.Bip01_R_Finger41"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 38.888, 0)
    },
    ["ValveBiped.Bip01_R_Finger1"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(-10, -1.111, -1.111)
    },
    ["ValveBiped.Bip01_R_Finger21"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 83.333, 0)
    },
    ["ValveBiped.base"] = {
        scale = Vector(0.009, 0.009, 0.009),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 0, 0)
    },
    ["ValveBiped.Bip01_R_Finger22"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 58.888, 0)
    },
    ["ValveBiped.Bip01_R_Finger12"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 50, 0)
    },
    ["ValveBiped.Bip01_R_Finger4"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(3.332, 32.222, 10)
    },
    ["ValveBiped.Bip01_R_Hand"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(25.555, 1.11, 3.332)
    },
    ["ValveBiped.Bip01_R_Finger3"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(3.332, 30, 1.11)
    },
    ["ValveBiped.Bip01"] = {
        scale = Vector(0.009, 0.009, 0.009),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 0, 0)
    },
    ["ValveBiped.Bip01_R_Finger32"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, 70, 0)
    },
    ["ValveBiped.Bip01_R_Forearm"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(0, -10, -25.556)
    },
    ["ValveBiped.Bip01_R_Finger0"] = {
        scale = Vector(1, 1, 1),
        pos = Vector(0, 0, 0),
        angle = Angle(-1.111, -3.333, -38.889)
    }
}

SWEP.IronSightsPos = Vector(-0, -7, 1.629)
SWEP.IronSightsAng = Vector(-1, 0, 0)
--SWEP.PrimaryReloadSound = Sound("Weapon_SMG1.Reload")
SWEP.PrimarySound = Sound("weapons/ar1/ar1_dist2.wav")
SWEP.Primary.Damage = 20
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = "ar2"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Spread = 15
SWEP.Primary.Cone = 0.3
SWEP.IronCone = 0.1
SWEP.DefaultCone = 0.3
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 1.2
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 3
SWEP.Tracer = 10
SWEP.CustomTracerName = "blu_pulse_tracer"
SWEP.ShotEffect = "blupulse_light"
SWEP.IronFOV = 70

if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("vgui/inventory/raise_your_hand")
end

function SWEP:DoBones()
    local ply = self:GetOwner()
    local ang1 = ply:GetNWFloat("ang1")

    if IsValid(ply) then
        self.ViewModelBoneMods["ValveBiped.Bip01_R_UpperArm"].angle = Angle(-50, -15 * ang1, -100) -- 
        self.ViewModelBoneMods["ValveBiped.Bip01_R_UpperArm"].pos = Vector(70, -14 + (36 * ang1), -16) --zoom inclinaison hauteur gauche-droite
    end
end

--end
function SWEP:SecondThink()
    local ply = self:GetOwner()
    local FT = FrameTime()
    local ang1 = ply:GetNWFloat("ang1")
    local ang2 = ply:GetNWFloat("ang2")

    if self:GetOwner():KeyDown(IN_ATTACK) then
        ply:SetNWFloat("ang1", Lerp(FT * 15, ang1, 1))
        ply:SetNWFloat("ang2", Lerp(FT * 15, ang1, 45))
    else
        ply:SetNWFloat("ang1", Lerp(FT * 15, ang1, 0))
        ply:SetNWFloat("ang2", Lerp(FT * 15, ang2, 0))
    end

    if IsValid(ply) and SERVER then
        local bone = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")

        if bone then
            ply:ManipulateBoneAngles(bone, Angle(90 * ang1, -50 * ang1, -50 * ang1))
        end

        bone = ply:LookupBone("ValveBiped.Bip01_R_Forearm")

        if bone then
            ply:ManipulateBoneAngles(bone, Angle(90 * ang1, -10 * ang1, 90 * ang1))
        end
    end
end

function SWEP:Holster()
    local ply = self:GetOwner()

    if IsValid(ply) and SERVER then
        self.ViewModelBoneMods["ValveBiped.Bip01_R_UpperArm"].angle = Angle(0, 0, 0)
        local bone = ply:LookupBone("ValveBiped.Bip01_R_UpperArm")

        if bone then
            ply:ManipulateBoneAngles(bone, Angle(0, 0, 0))
        end

        bone = ply:LookupBone("ValveBiped.Bip01_R_Forearm")

        if bone then
            ply:ManipulateBoneAngles(bone, Angle(0, 0, 0))
        end
    end

    if CLIENT and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        local vm = self:GetOwner():GetViewModel()

        if IsValid(vm) then
            self:ResetBonePositions(vm)
        end
    end

    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:Reload()
end

SWEP.NxtSec = 0

function SWEP:QuadsHere()
end

SWEP.VElements = {}
SWEP.WElements = {}