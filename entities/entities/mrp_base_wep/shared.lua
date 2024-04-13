ENT.Type = "anim"
ENT.Base = "mrp_base_gear"

ENT.WeaponClass = nil
ENT.Spawnable = false

function ENT:MRPRegisterModel()
    baseclass.Get("mrp_base_gear").MRPRegisterModel(self)
    table.insert(MRP.weaponClasses, self.wepClass)
end

function ENT:Initialize()
    local w = scripted_ents.get(self.WeaponClass)
    self.PrintName = w.PrintName
    self.Model = w.WorldModel
    self.Ammo = w.Primary.Ammo
    self.ClipSize = w.Primary.ClipSize
end
