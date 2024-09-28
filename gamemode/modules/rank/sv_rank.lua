local function canPromote(ply, target)
    if ply:IsAdmin() then return true end
    if ply:GetNWInt("Rank") - target:GetNWInt("Rank") > 5 then return true end
    return false
end

local function rankChange(admin, targetId, inc)
    local TAG = "rankChange"
    admin:ChatPrint("rankChange")
    local target
    if not targetId then
        admin:ChatPrint("Veuillez indiquer un nom ou un SteamID SVP")
        return
    else
        Log.d(TAG, "targetId ", targetId)
        target = MRP.FindPlayer(targetId)
        admin:ChatPrint("Found" .. tostring(target))
    end
    if canPromote(admin, target) then
        local faction = target:MRPFaction()
        local regiment = target:MRPRegiment()
        local limitUp = #MRP.Ranks[faction][regiment]
        Log.d("regiment is " .. tostring(regiment))
        Log.d("limit up is " .. tostring(limitUp))
        local newRank
        if inc == 0 then
            newRank = 0
        else
            newRank = math.Clamp(target:GetNWInt("Rank") + inc, 0, limitUp)
        end
        Log.d(target, "will be", newRank)
        target:SetNWInt("Rank", newRank)
        local bgroup = MRP.PlayerModels[faction][target:GetNWInt("ModelIndex")]["stripes"]
        local bodyId = MRP.Ranks[faction][regiment][target:GetNWInt("Rank")]["bodygroupVal"]
        target:SetBodygroup(bgroup, bodyId)
        MRP.SaveBodyGroupsData(target)
        sql.Query(
            "UPDATE mrp_characters SET Rank = '" .. target:GetNWInt("Rank") ..
            "' WHERE SteamID64 = " .. tostring(target:SteamID64()) ..
            " AND RPName = " .. "'" .. target:RPName() .. "'"
        )
        Log.d(target, " new rank is ", newRank)
    else
        admin:ChatPrint("Commande non autorisée")
    end
end

concommand.Add("mrp rank reset", function( ply, _, args )
    rankChange(ply, args[1], 0)
end)

concommand.Add("rpromote", function( ply, _, args )
    ply:ChatPrint("rpromote triggered")
    rankChange(ply, args[1], 1)
end)

concommand.Add("rdemote", function( ply, _, args )
    rankChange(ply, args[1], -1)
end)
