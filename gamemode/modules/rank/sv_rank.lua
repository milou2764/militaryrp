local function findPlayer(info)
    if not info or info == "" then return end
    for _, p in ipairs( player.GetAll() ) do
        if p:SteamID() == info then
            return p
        end
        local rpname = string.lower(p:RPName())
        if string.find(rpname, string.lower(tostring(info)), 1, true) ~= nil then
            return p
        end
    end
end

local function canPromote(ply, target)
    if ply:IsAdmin() then return true end
    if ply:GetNWInt("Rank") - target:GetNWInt("Rank") > 5 then return true end
    return false
end

concommand.Add("rpromote", function( ply, _, args )
    local target
    if not args[1] then
        ply:ChatPrint("Veuillez indiquer un nom ou un SteamID SVP")
        return
    else
        target = findPlayer(args[1])
    end
    if canPromote(ply, target) then
        local newRank = math.Clamp(target:GetNWInt("Rank") + 1, 0, 19)
        ply:SetNWInt("Rank", newRank)
        local faction = ply:MRPFaction()
        local regiment = ply:MRPRegiment()
        local bgroup = MRP.PlayerModels[faction][ply:GetNWInt("ModelIndex")]["stripes"]
        local bodyId = MRP.Ranks[faction][regiment][ply:GetNWInt("Rank")]["bodygroupVal"]
        ply:SetBodygroup(bgroup, bodyId)
        MRP.SaveBodyGroupsData(ply)
        sql.Query(
            "UPDATE mrp_characters SET Rank = '" .. ply:GetNWInt("Rank") ..
            "' WHERE SteamID64 = " .. tostring(target:SteamID64()) ..
            " AND RPName = " .. "'" .. target:RPName() .. "'"
        )
    else
        ply:ChatPrint("Commande non autorisée")
    end
end)

concommand.Add("rdemote", function( ply, _, args )
    local target
    if not args[1] then
        ply:ChatPrint("Veuillez indiquer un nom ou un SteamID SVP")
        return
    else
        target = findPlayer(args[1])
    end
    if canPromote(ply, args[1]) then
        local newRank = math.Clamp(target:GetNWInt("Rank") - 1, 0, 19)
        ply:SetNWInt("Rank", newRank)
        local faction = ply:MRPFaction()
        local regiment = ply:MRPRegiment()
        local bodyGroup = MRP.PlayerModels[faction][ply:GetNWInt("ModelIndex")]["stripes"]
        local bodyId = MRP.Ranks[faction][regiment][ply:MRPRank()]["bodygroupVal"]
        ply:SetBodygroup(bodyGroup, bodyId)
        SaveBodyGroupsData(ply)
        sql.Query(
            "UPDATE mrp_characters SET Rank = '" .. ply:MRPRank() ..
            "' WHERE SteamID64 = " .. tostring(target:SteamID64()) ..
            " AND RPName = " .. "'" .. target:GetNWString("RPName") .. "'"
        )
    else
        ply:ChatPrint("Commande non autorisée")
    end
end)
