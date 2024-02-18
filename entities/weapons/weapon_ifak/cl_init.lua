include("shared.lua")

function SWEP:Initialize()
end

function SWEP:Holster()
    self.CurSoundTable = nil
    self.CurSoundEntry = nil
    self.SoundTime = nil
    self.SoundSpeed = 1
end