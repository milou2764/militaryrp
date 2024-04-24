local meta = FindMetaTable('Entity')

function meta:MRPHas(category)
    return self:GetNWInt(category) > 1
end

function meta:MRPRLauncher()
    return MRP.EntityTable(self:GetNWInt('RocketLauncher'))
end

function meta:MRPRLRounds()
    return self:GetNWInt('RocketLauncherRounds')
end

function meta:MRPPWep()
    return MRP.EntityTable(self:GetNWInt('PrimaryWep'))
end

function meta:MRPPWepRounds()
    return self:GetNWInt('PrimaryWepRounds')
end

function meta:MRPSecWep()
    return MRP.EntityTable(self:GetNWInt('SecondaryWep'))
end

function meta:MRPSecWepRounds()
    return self:GetNWInt('SecondaryWepRounds')
end
