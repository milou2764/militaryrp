local meta = FindMetaTable('Entity')

function meta:MRPHas(category)
    return self:GetNWInt(category) > 1
end

function meta:MRPRLauncher()
    return MRP.getMRPEnt(self:GetNWInt('RocketLauncher'))
end

function meta:MRPRLAmmo()
    return self:GetNWInt('RocketLauncherAmmo')
end

function meta:MRPPWep()
    return MRP.getMRPEnt(self:GetNWInt('PrimaryWep'))
end

function meta:MRPPWepAmmo()
    return self:GetNWInt('PrimaryWepAmmo')
end

function meta:MRPSecWep()
    return MRP.getMRPEnt(self:GetNWInt('SecondaryWep'))
end

function meta:MRPSecWepAmmo()
    return self:GetNWInt('SecondaryWepAmmo')
end
