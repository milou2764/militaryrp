include("shared.lua")

ENT.entPanelName = "MRPWepPanel"

function ENT:unmount(target)
    local userid
    if target.UserID then
        userid = target:UserID()
    else
        userid = target:EntIndex()
    end
    MRP.mountedWeps[userid] = MRP.mountedWeps[userid] or {}
    local model = MRP.mountedWeps[userid][self.MRPCategory]
    if IsValid(model) and model.Remove then
        table.RemoveByValue(MRP.mountedWeps[userid], model)
        model:Remove()
    end
end