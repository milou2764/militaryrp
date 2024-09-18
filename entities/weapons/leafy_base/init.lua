AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:Initialize()
    self:SetWeaponHoldType("ar2")

    if self:GetOwner():IsNPC() then
        if self:GetOwner():GetClass() == "npc_combine_s" then
            if self:GetOwner():LookupSequence("cover_crouch_low") == nil then return end
            local crouchseq = self:GetOwner():LookupSequence("cover_crouch_low")

            if self:GetOwner():GetSequenceName(crouchseq) == "cover_crouch_low" then
                self:SetWeaponHoldType("ar2")
            else
                self:SetWeaponHoldType("pistol")
            end
        end

        if self:GetOwner():GetClass() == "npc_combine_s" then
            hook.Add("Think", self, self.TheThink)
        end

        if self:GetOwner():GetClass() == "npc_metropolice" then
            self:SetWeaponHoldType("smg")
        end

        self:GetOwner():SetKeyValue("spawnflags", "256")

        if self:GetOwner():GetClass() == "npc_citizen" then
            self:GetOwner():Fire("DisableWeaponPickup")
        end
    end
end

function SWEP:TheThink()
    if self:GetOwner():IsNPC() then
        self:NextFire()
    end
end

function SWEP:NextFire()
    if not self:IsValid() or not self:GetOwner():IsValid() then return end

    if self:GetOwner():IsNPC() and self:GetOwner():GetActivity() == 16 then
        self:NPCShoot_Primary(ShootPos, ShootDir)
        hook.Remove("Think", self)

        timer.Simple(0.3, function()
            hook.Add("Think", self, self.NextFire)
        end)
    end
end

function SWEP:NPCShoot_Primary()
    --if self:GetOwner():IsNPC() then
    if (not self:IsValid()) or (not self:GetOwner():IsValid()) then return end
    self:PrimaryAttack()

    timer.Simple(0.15, function()
        if (not self:IsValid()) or (not self:GetOwner():IsValid()) then return end
        if (not self:GetOwner():GetEnemy()) then return end
        self:PrimaryAttack()
    end)

    timer.Simple(0.3, function()
        if (not self:IsValid()) or (not self:GetOwner():IsValid()) then return end
        if (not self:GetOwner():GetEnemy()) then return end
        self:PrimaryAttack()
    end)
    --end
end