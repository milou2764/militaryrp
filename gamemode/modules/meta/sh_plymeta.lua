local meta = FindMetaTable('Player')

function meta:MRPGetID(cat)
    return meta:GetNWInt(cat)
end

function meta:RPName()
    return self:GetNWString('RPName')
end

function meta:MRPRankID()
    return self:GetNWInt('Rank')
end

function meta:MRPRegimentID()
    return self:GetNWInt('Regiment')
end

function meta:MRPFactionID()
    return self:GetNWInt('Faction')
end

function meta:GetRegiment()
    return MRP.Regiments[self:MRPFactionID()][self:MRPRegimentID()]['name']
end

function meta:GetRPName()
    return self:GetNWString('RPName')
end
function meta:GetCharacterID()
    return self:GetNWInt('CharacterID')
end


function meta:Has(category)
    return self:GetNWInt(category) > 1
end

function meta:GetMRPID(category)
    return self:GetNWInt(category)
end

function meta:HasNVGs()
    return self:GetNWInt('NVGs') > 1
end
