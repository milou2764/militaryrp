local meta = FindMetaTable('Entity')

function meta:Has(category)
    return self:GetNWInt(category) > 1
end

function meta:GetRLAmmo()
    return self:GetNWInt('RocketLauncherAmmo')
end

function meta:GetRLauncher()
    return MRP.getMRPEnt(self:GetNWInt('RocketLauncher'))
end

function meta:GetPrimaryWep()
    return MPR.getMRPEnt(self:GetNWInt('PrimaryWep'))
end

--[[
    Get primary weapon ammo
--]]
function meta:GetPWepAmmo()
    return self:GetNWInt('PrimaryWepAmmo')
end

function meta:GetSecWep()
    return MPR.getMRPEnt(self:GetNWInt('SecondaryWep'))
end

function meta:GetPrimaryWep()
    return MPR.getMRPEnt(self:GetNWInt('PrimaryWep'))
end
