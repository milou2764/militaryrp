ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false

function ENT:MRPRegisterModel()
    MRP.entityModels[self.ClassName] = self.model
end
