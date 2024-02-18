local plyMeta = FindMetaTable("Player")
function plyMeta:GetRegiment()
    return MRP.Regiments[self:GetNWInt("Faction")][self:GetNWInt("Regiment")]["name"]
end
function plyMeta:GetRPName()
    return self:GetNWString("RPName")
end
function plyMeta:GetCharacterID()
    return self:GetNWInt("CharacterID")
end

function plyMeta:Has(category)
    return self:GetNWInt(category) > 1
end

function plyMeta:GetMRPID(category)
    return self:GetNWInt(category)
end

function plyMeta:HasNVGs()
    return self:GetNWInt("NVGs") > 1
end