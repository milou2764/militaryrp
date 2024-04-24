local meta = FindMetaTable('Player')

function meta:MRPGetID(cat)
    return meta:GetNWInt(cat)
end

function meta:MRPWeapon(cat)
    local wepClass = self:MRPEntityTable(cat).WeaponClass
    return self:GetWeapon(wepClass)
end

function meta:MRPEntityTable(cat)
    return MRP.EntityTable(self:GetNWInt(cat))
end

function meta:MRPCharacterID()
    return self:GetNWInt('CharacterID')
end

function meta:RPName()
    return self:GetNWString('RPName')
end

function meta:MRPRank()
    return self:GetNWInt('Rank')
end

function meta:MRPRegiment()
    return self:GetNWInt('Regiment')
end

function meta:MRPFaction()
    return self:GetNWInt('Faction')
end

function meta:MRPGasmask()
    return self:GetNWInt('Gasmask')
end

function meta:MRPModel()
    return self:GetNWInt('ModelIndex')
end

function meta:GetRegiment()
    return MRP.Regiments[self:MRPFaction()][self:MRPRegiment()]['name']
end

function meta:GetRPName()
    return self:GetNWString('RPName')
end

function meta:MRPSecondaryWep()
    return self:GetNWInt('SecondaryWep')
end

function meta:MRPHas(category)
    return self:GetNWInt(category) > 1
end

function meta:GetMRPID(category)
    return self:GetNWInt(category)
end

function meta:HasNVGs()
    return self:GetNWInt('NVGs') > 1
end
