local function findPlayer(info)
    if not info or info == "" then return end
    for _, p in ipairs( player.GetAll() ) do
        if p:SteamID() == info then
            return p
        end
        if string.find(string.lower(p:GetNWString("RPName")), string.lower(tostring(info)), 1, true) ~= nil then
            return p
        end
    end
end

local function canPromote(ply, target)
    if ply:IsAdmin() then return true end
    if ply:GetNWInt("Rank") - target:GetNWInt("Rank") > 5 then return true end
    return false
end

concommand.Add("rpromote", function( ply, cmd, args )
    local target
    if not args[1] then
        ply:ChatPrint("Veuillez indiquer un nom ou un SteamID SVP")
        return
    else
        target = findPlayer(args[1])
    end
    if canPromote(ply,target) then
        local newRank = math.Clamp(target:GetNWInt("Rank") + 1, 0, 19)
        ply:SetNWInt("Rank", newRank)
        ply:SetBodygroup(MRP.PlayerModels[ply:GetNWInt("Faction")][ply:GetNWInt("ModelIndex")]["stripes"], MRP.Ranks[ply:GetNWInt("Faction")][ply:GetNWInt("Regiment")][ply:GetNWInt("Rank")]["bodygroupVal"])
        MRP.SaveBodyGroupsData(ply)
        sql.Query("UPDATE mrp_characters SET Rank = '" .. ply:GetNWInt("Rank") .. "' WHERE SteamID64 = " .. tostring(target:SteamID64()) .. " AND RPName = " .. "'" .. target:GetNWString("RPName") .. "'")
    else
        ply:ChatPrint("Commande non autorisée")
    end
end)

concommand.Add("rdemote", function( ply, cmd, args )
    local target
    if not args[1] then
        ply:ChatPrint("Veuillez indiquer un nom ou un SteamID SVP")
        return
    else
        target = findPlayer(args[1])
    end
    if canPromote(ply,args[1]) then
        local newRank = math.Clamp(target:GetNWInt("Rank") - 1, 0, 19)
        ply:SetNWInt("Rank", newRank)
        ply:SetBodygroup(MRP.PlayerModels[ply:GetNWInt("Faction")][ply:GetNWInt("Regiment")][ply:GetNWInt("ModelIndex")]["stripes"], MRP.Ranks[ply:GetNWInt("Faction")][ply:GetNWInt("Regiment")][ply:GetNWInt("Rank")]["bodygroupVal"])
        SaveBodyGroupsData(ply)
        sql.Query("UPDATE mrp_characters SET Rank = '" .. ply:GetNWInt("Rank") .. "' WHERE SteamID64 = " .. tostring(target:SteamID64()) .. " AND RPName = " .. "'" .. target:GetNWString("RPName") .. "'")
    else
        ply:ChatPrint("Commande non autorisée")
    end
end)