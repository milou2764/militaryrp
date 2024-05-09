local function GetPlayerData(ply)
    local data =
        sql.Query(
            "SELECT * FROM " .. SQLStr(MRP.TABLE_CHAR) .. " " ..
            "WHERE SteamID64 = " .. ply:SteamID64() .. ";"
        )
    return data
end

local function HandlePlayerData(ply, data)
    --PrintTable(data)
    if data == false then
        Log.e(TAG, "error selecting characters")
        Log.e(TAG, sql.LastError())
    elseif data == nil then
        net.Start("CharacterCreation")
        net.Send(ply)
    else
        net.Start("CharacterSelection")
        Log.d(TAG, "character selection")
        PrintTable(data)
        net.WriteUInt(#data, 5)

        for _, v in pairs(data) do
            net.WriteUInt(tonumber(v["UID"]), 32)
            net.WriteUInt(tonumber(v["Faction"]), 1)
            net.WriteUInt(tonumber(v["Regiment"]), 4)
            net.WriteUInt(tonumber(v["Rank"]), 5)
            net.WriteString(v["RPName"])
            net.WriteUInt(tonumber(v["ModelIndex"]), 5)
            net.WriteUInt(tonumber(v["Size"]), 8)
            net.WriteUInt(tonumber(v["Skin"]), 5)
            net.WriteString(v["BodyGroups"])
            net.WriteUInt(tonumber(v["NVGs"]), 7)
            net.WriteUInt(tonumber(v["Helmet"]), 7)
            net.WriteUInt(tonumber(v["Gasmask"]), 7)
            net.WriteUInt(tonumber(v["Rucksack"]), 7)
            net.WriteUInt(tonumber(v["Vest"]), 7)
        end

        net.Send(ply)
    end
end

hook.Add( "PlayerSpawn", "MRP::character::PlayerSpawn", function( ply )
    Log.d("character", "PlayerSpawn hook")
    if player_manager.GetPlayerClass(ply) == "spectator" then
        local data = GetPlayerData(ply)
        HandlePlayerData(ply, data)
    else
        ply:SetModel(MRP.PlayerModels[ply:MRPFaction()][ply:MRPModel()].Model)
        ply:SetModelScale(ply:GetNWInt("Size") / 180, 0)
        ply:SetViewOffset(Vector(0, 0, 64 * ply:GetNWInt("Size") / 180))
        ply:SetSkin(ply:GetNWInt("Skin"))

        for k, v in pairs(ply.BodyGroups) do
            ply:SetBodygroup(k - 1, v)
        end

        ply:SetupHands() -- Create the hands and call MRP:PlayerSetHandsModel
        player_manager.RunClass(ply, "Loadout")
        timer.Simple(2, function()
            net.Start("MRPPlayerSpawn")
            net.WriteEntity(ply)
            net.Broadcast()
        end)
    end

end )

local function EquipPlayer(ply)
    for _, cat in pairs(MRP.WeaponCat) do
        if ply:MRPHas(cat) then
            local entTable = ply:MRPEntityTable(cat)
            local ent = ply:Give(entTable.WeaponClass)
            local rounds = ply[cat .. "Rounds"]
            Log.d("EquipPlayer", cat .. " " .. rounds)
            ent:SetClip1(ply[cat .. "Rounds"])
        end
    end

    for k = 1, 20 do
        local entityTable = ply:MRPEntityTable("Inventory" .. k)
        if entityTable.Ammo then
            local ammo = ply:GetNWInt("Inventory" .. k .. "Rounds")
            local ammoType = entityTable.Ammo
            ply:GiveAmmo(ammo, ammoType, true)
        elseif entityTable.WeaponClass then
            ply:Give(entityTable.WeaponClass)
        end
    end
end

net.Receive("CharacterInformation", function(_, ply)
    ply:SetNWInt("Faction", net.ReadBit())
    ply:SetNWInt("Regiment", net.ReadUInt(4))
    ply:SetNWInt("Rank", 1)
    ply:SetNWString("RPName", net.ReadString())
    ply:SetNWInt("ModelIndex", net.ReadUInt(5))
    ply:SetNWInt("Size", net.ReadUInt(8))
    ply:SetNWInt("Skin", net.ReadUInt(5))
    ply:SetNWInt("Gasmask", 1)
    ply.BodyGroups = net.ReadString()
    ply:SetNWBool("GasmaskOn", false)
    ply:SetNWInt("PrimaryWep", 1)
    ply:SetNWInt("SecondaryWep", 1)
    ply:SetNWInt("RocketLauncher", 1)
    ply:SetNWInt("Vest", 1)
    ply:SetNWInt("VestArmor", 0)
    ply:SetNWInt("Rucksack", 1)
    ply:SetNWInt("Radio", 1)
    ply:SetNWInt("Gasmask", 1)
    ply:SetNWInt("Helmet", 1)
    ply:SetNWInt("HelmetArmor", 0)
    ply:SetNWInt("NVGs", 1)
    hook.Run("CharacterRegistration", ply)

    for k = 1, 5 do
        ply:SetNWInt("Inventory" .. k, 1)
        ply:SetNWInt("Inventory" .. k .. "Rounds", 0)
    end

    for k = 6, 20 do
        ply:SetNWInt("Inventory" .. k, 0)
        ply:SetNWInt("Inventory" .. k .. "Rounds", 0)
    end

    request =
        "INSERT INTO " .. MRP.TABLE_CHAR .. "(" ..
            "SteamID64, " ..
            "Faction, " ..
            "Regiment, " ..
            "RPName, " ..
            "ModelIndex, " ..
            "Size, " ..
            "Skin, " ..
            "BodyGroups)\n" ..
        "VALUES\n(" ..
            ply:SteamID64() .. ", " ..
            ply:GetNWInt("Faction") .. ", " ..
            ply:GetNWInt("Regiment") .. ", " ..
            SQLStr(ply:GetNWString("RPName")) .. ", " ..
            ply:GetNWInt("ModelIndex") .. ", " ..
            ply:GetNWInt("Size") .. ", " ..
            ply:GetNWInt("Skin") .. ", " ..
            SQLStr(ply.BodyGroups) .. ");"
    print(request)
    local sqlret = sql.Query(request)
    if sqlret == false then
        print("### MRP error in character insertion")
        print(sql.LastError())
    else
        print("### MRP character insertion succeed")
    end
    sqlret =
        sql.Query(
            "SELECT * " ..
            "FROM " .. MRP.TABLE_CHAR .. " " ..
            "WHERE SteamID64 = " .. ply:SteamID64() .. " " ..
            "AND RPName = " .. SQLStr(ply:GetNWString("RPName"))
        )
    if sqlret == false then
        print("### MRP SQL error could not get character UID")
        print(sql.LastError())
    elseif sqlret == nil then
        print("### MRP could not get character UID")
    else
        print("### MRP successfully got the character UID")
        ply:SetNWInt("CharacterID", tonumber(sqlret[#sqlret]["UID"]))
        ply.BodyGroups = string.Split(ply.BodyGroups, ",")

        MRP.SpawnPlayer(ply)
        EquipPlayer(ply)
   end
end)

net.Receive("DeleteCharacter", function(_, _)
    local uid = net.ReadUInt(32)
    sql.Query("DELETE FROM mrp_characters WHERE UID = " .. uid)
end)

net.Receive("CharacterSelected", function(_, ply)
    local uid = net.ReadUInt(32)
    local Character =
        sql.QueryRow("SELECT * FROM mrp_characters WHERE UID = " .. tostring(uid))
    hook.Run("CharacterSelected", ply)
    Character.Faction = tonumber(Character.Faction)
    ply:SetNWInt("CharacterID", tonumber(uid))
    ply:SetNWString("RPName", Character.RPName)
    ply:SetNWInt("Faction", tonumber(Character.Faction))
    ply:SetNWInt("Regiment", tonumber(Character.Regiment))
    ply:SetNWInt("Rank", tonumber(Character.Rank))
    ply:SetNWInt("ModelIndex", tonumber(Character.ModelIndex))
    ply:SetNWInt("Size", tonumber(Character.Size))
    ply:SetNWInt("Skin", tonumber(Character.Skin))
    ply.Size = tonumber(Character.Size)
    ply.Skin = tonumber(Character.Skin)
    ply.BodyGroups = string.Split(Character.BodyGroups, ",")
    ply:SetNWBool("GasmaskOn", false)
    ply:SetNWInt("PrimaryWep", tonumber(Character.PrimaryWep))
    ply.PrimaryWepRounds = tonumber(Character.PrimaryWepRounds)
    ply:SetNWInt("SecondaryWep", tonumber(Character.SecondaryWep))
    ply.SecondaryWepRounds = tonumber(Character.SecondaryWepRounds)
    ply:SetNWInt("RocketLauncher", tonumber(Character.RocketLauncher))
    ply.RocketLauncherRounds = tonumber(Character.RocketLauncherRounds)
    ply:SetNWInt("Vest", tonumber(Character.Vest))
    ply:SetNWInt("VestArmor", tonumber(Character.VestArmor))
    ply:SetNWInt("Rucksack", tonumber(Character.Rucksack))
    ply:SetNWInt("Gasmask", tonumber(Character.Gasmask))
    ply:SetNWInt("Helmet", tonumber(Character.Helmet))
    ply:SetNWInt("HelmetArmor", tonumber(Character.HelmetArmor))
    ply:SetNWInt("NVGs", tonumber(Character.NVGs))
    Character.Inventory = string.Split(Character.Inventory, ",")
    Character.InventoryRounds = string.Split(Character.InventoryRounds, ",")
    Character.InventoryArmor = string.Split(Character.InventoryArmor, ",")

    for k = 1, 20 do
        local slot = "Inventory" .. k
        ply:SetNWInt(slot, tonumber(Character.Inventory[k]))
        ply:SetNWInt(slot .. "Rounds", tonumber(Character.InventoryRounds[k]))
        ply:SetNWInt(slot .. "Armor", tonumber(Character.InventoryArmor[k]))
    end

    MRP.SpawnPlayer(ply)
    EquipPlayer(ply)
end)
