ENT.Type = "anim"
ENT.Base = "mrp_base_gear"

function ENT:registerMRPEntity()
    baseclass.Get("mrp_base_gear").registerMRPEntity(self)
    table.insert(MRP.weaponClasses, self.wepClass)
end