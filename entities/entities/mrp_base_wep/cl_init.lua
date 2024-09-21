include("shared.lua")

ENT.entPanelName = "MRPWepPanel"

function ENT:unmount(target)
    local userid
    if target.UserID then
        userid = target:UserID()
    else
        userid = target:EntIndex()
    end
    MRP.MountedWeps[userid] = MRP.MountedWeps[userid] or {}
    local model = MRP.MountedWeps[userid][self.MRPCategory]
    if IsValid(model) and model.Remove then
        table.RemoveByValue(MRP.MountedWeps[userid], model)
        model:Remove()
    end
end
