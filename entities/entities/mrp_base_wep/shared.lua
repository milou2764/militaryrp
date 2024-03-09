ENT.Type = "anim"
ENT.Base = "mrp_base_gear"

function ENT:MRPRegisterModel()
    baseclass.Get("mrp_base_gear").MRPRegisterModel(self)
    table.insert(MRP.weaponClasses, self.wepClass)
end
