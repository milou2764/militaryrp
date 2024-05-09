GM.Name = "MilitaryRP"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"
DeriveGamemode("sandbox")
include("player_class/player.lua")
include("player_class/spectator.lua")
include("config/config.lua")
include("config/sv_config.lua")
include("config/ammotypes.lua")
include("modules/log/sh_log.lua")
AddCSLuaFile("player_class/player.lua")
AddCSLuaFile("player_class/spectator.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/cl_config.lua")
AddCSLuaFile("config/ammotypes.lua")
AddCSLuaFile("vgui/misc.lua")
util.AddNetworkString("CharacterCreation")
util.AddNetworkString("DeleteCharacter")
util.AddNetworkString("CharacterSelection")
util.AddNetworkString("CharacterSelected")
util.AddNetworkString("CharacterInformation")
util.AddNetworkString("MRPDrop")
util.AddNetworkString("PlayerDrop")
util.AddNetworkString("PlayerDropAmmo")
util.AddNetworkString("PlayerDropNVGs")
util.AddNetworkString("PlayerDropHelmet")
util.AddNetworkString("PlayerDropGasmask")
util.AddNetworkString("PlayerDropRucksack")
util.AddNetworkString("PlayerDropVest")
util.AddNetworkString("PlayerDropWep")
util.AddNetworkString("RagdollDrop")
util.AddNetworkString("RagdollDropAmmo")
util.AddNetworkString("RagdollDropNVGs")
util.AddNetworkString("RagdollDropHelmet")
util.AddNetworkString("RagdollDropGasmask")
util.AddNetworkString("RagdollDropRucksack")
util.AddNetworkString("RagdollDropVest")
util.AddNetworkString("RagdollDropWep")
util.AddNetworkString("ChestDrop")
util.AddNetworkString("PlayerChangeHelmetWithRagdoll")
util.AddNetworkString("PlayerEquipRagdollHelmet")
util.AddNetworkString("PlayerChangeGasmaskWithRagdoll")
util.AddNetworkString("PlayerEquipRagdollGasmask")
util.AddNetworkString("PlayerChangeRucksackWithRagdoll")
util.AddNetworkString("PlayerEquipRagdollRucksack")
util.AddNetworkString("ItemSwitchSlot")
util.AddNetworkString("ItemSwitchOwner")
util.AddNetworkString("Use")
util.AddNetworkString("MRPClientNVGsToggle")
util.AddNetworkString("MRPPlayerNVGsToggle")
util.AddNetworkString("MRPPlayerTakeOnGasmask")
util.AddNetworkString("MRPPlayerTakeOffGasmask")
util.AddNetworkString("MRPPlayerDeath")
util.AddNetworkString("MRPCreateRagdollCS")
util.AddNetworkString("MRPPlayerSpawn")

local TAG = "mrpinit"

local existingTable =
    sql.QueryValue(
        "SELECT sql FROM sqlite_master " ..
        "WHERE name = " .. SQLStr(MRP.TABLE_CHAR)
    )
--print(existingTable.sql)
local request =
    "CREATE TABLE " .. SQLStr(MRP.TABLE_CHAR) .. "(" ..
    "UID INTEGER PRIMARY KEY autoincrement," ..
    "SteamID64 BIGINT NOT NULL," ..
    "Faction INT," ..
    "Regiment INT," ..
    "Rank INT DEFAULT '1'," ..
    "RPName TEXT," ..
    "ModelIndex INT," ..
    "Size SMALLINT NOT NULL," ..
    "Skin TINYINT," ..
    "BodyGroups TEXT," ..
    "PrimaryWep TINYINT DEFAULT '1'," ..
    "PrimaryWepRounds TINYINT DEFAULT '0'," ..
    "SecondaryWep TINYINT DEFAULT '1'," ..
    "SecondaryWepRounds TINYINT DEFAULT '0'," ..
    "RocketLauncher TINYINT DEFAULT '1'," ..
    "RocketLauncherRounds TINYINT DEFAULT '0'," ..
    "Vest TINYINT DEFAULT '1'," ..
    "VestArmor TINYINT DEFAULT '0'," ..
    "Rucksack TINYINT DEFAULT '1'," ..
    "Radio TINYINT DEFAULT '1'," ..
    "Gasmask TINYINT DEFAULT '1'," ..
    "Helmet TINYINT DEFAULT '1'," ..
    "HelmetArmor TINYINT DEFAULT '0'," ..
    "NVGs TINYINT DEFAULT '1'," ..
    "Inventory VARCHAR(60) DEFAULT '1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'," ..
    "InventoryAmmo VARCHAR(120) DEFAULT '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'," ..
    "InventoryArmor VARCHAR(120) DEFAULT '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'" ..
    ")"

if existingTable ~= request then
    Log.e(TAG, "MRP TABLE CHANGED SINCE LAST TIME")
    Log.e(TAG, existingTable)
    Log.e(TAG, request)
    Log.e(TAG, "DELETING ...")
    sql.Query("DROP TABLE " .. SQLStr(MRP.TABLE_CHAR))
    sql.Query(request)
else
    Log.d(TAG, "TABLE DID NOT CHANGED")
end

local fol = GM.FolderName .. "/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
local SortedPairs = SortedPairs

for _, v in ipairs(files) do
    isDisabled = MRP.disabledDefaults["modules"][v:Left(-5)]
    isLuaFile = string.GetExtensionFromFilename(v) == "lua"
    if not isDisabled and isLuaFile then
        include(fol .. v)
    end
end

for _, folder in SortedPairs(folders, true) do
    isDisabled = MRP.disabledDefaults["modules"][folder]
    if folder ~= "." and folder ~= ".." and not isDisabled then
        for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
            AddCSLuaFile(fol .. folder .. "/" .. File)
            include(fol .. folder .. "/" .. File)
        end

        for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
            include(fol .. folder .. "/" .. File)
        end

        for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
            AddCSLuaFile(fol .. folder .. "/" .. File)
        end
    end
end

function MRP.SpawnPlayer(ply)
    player_manager.SetPlayerClass(ply, "player")
    ply:Spawn()
    ply:SetShouldServerRagdoll(true)
end

function MRP.SaveBodyGroupsData(ply)
    local BodyGroups = ply:GetBodygroup(0)

    for k = 1, ply:GetNumBodyGroups() - 1 do
        BodyGroups = BodyGroups .. "," .. ply:GetBodygroup(k)
    end

    sql.Query(
        "UPDATE mrp_characters SET BodyGroups = " .. SQLStr(BodyGroups) .. " " ..
        "WHERE UID = " .. ply:MRPCharacterID()
    )
end

function MRP.PickupAmmoBox(ply, ent)
    local taken = false

    for k = 1, 20 do
        local slotContainsSameAmmo = ply:GetNWInt("Inventory" .. k) == ent.MRPID
        local slotAmmo = ply:GetNWInt("Inventory" .. k .. "Rounds")
        local boxCap = MRP.EntityTable(ent.MRPID).Capacity
        local slotAmmoBoxNotFull = slotAmmo < boxCap
        if slotContainsSameAmmo and slotAmmoBoxNotFull and ent.Rounds > 0 then
            local ammoTillFull = boxCap - slotAmmo

            if ammoTillFull < ent.Rounds then
                ply:GiveAmmo(ammoTillFull, ent.Ammo)
                ent.Rounds = ent.Rounds - ammoTillFull
                ply:SetNWInt("Inventory" .. k .. "Rounds", boxCap)
            else
                ply:SetNWInt("Inventory" .. k .. "Rounds", slotAmmo + ent.Rounds)
                ply:GiveAmmo(ent.Rounds, ent.Ammo)
            end
        end

        if ply:GetNWInt("Inventory" .. k) == 1 and ent.Rounds > 0 then
            ply:GiveAmmo(ent.Rounds, ent.Ammo)
            ply:SetNWInt("Inventory" .. k, ent.MRPID)
            ply:SetNWInt("Inventory" .. k .. "Rounds", ent.Rounds)
            taken = true
            break
        end
    end

    if taken then
        MRP.SaveInventoryData(ply)
        ent:Remove()
    elseif CurTime() > ent.Delay then
        ent.Delay = CurTime() + 2
        ply:ChatPrint("You are full!")
    end
end

function MRP.PickupRucksack(ply, ent)
    ply:SetNWInt("Rucksack", ent.MRPID)
    sql.Query(
        "UPDATE mrp_characters SET Rucksack = " .. ent.MRPID .. " " ..
        "WHERE UID = " .. ply:MRPCharacterID() .. ";"
    )
    local faction = ply:MRPFaction()
    local bodyGroup = ent.BodyGroup[faction][ply:GetNWInt("ModelIndex")][1]
    local bodyId = ent.BodyGroup[faction][ply:GetNWInt("ModelIndex")][2]
    ply:SetBodygroup(bodyGroup, bodyId)
    MRP.SaveBodyGroupsData(ply)
    local Inventory = {}

    for k = 1, 20 do
        Inventory[k] = ply:GetNWInt("Inventory" .. k)
    end

    for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
        Inventory[k] = ent["Slot" .. k]
        ply:SetNWInt("Inventory" .. k, ent["Slot" .. tostring(k)])

        if MRP.EntityTable(ent["Slot" .. k]).Ammo then
            local slotAmmo = ent["Slot" .. k .. "Rounds"]
            local ammoType = MRP.EntityTable(ent["Slot" .. k]).Ammo
            ply:GiveAmmo(slotAmmo, ammoType)
            ply:SetNWInt("Inventory" .. k .. "Rounds", slotAmmo)
        end
    end

    Inventory = table.concat(Inventory, ",")
    sql.Query(
        "UPDATE mrp_characters" ..
        "SET Inventory = " .. SQLStr(Inventory) .. " " ..
        "WHERE UID = " .. ply:MRPCharacterID())
    ent:Remove()
end

function MRP.PickupWep(ply, ent)
    -- local wep = ents.Create(ent.WeaponClass)
    -- wep.Primary.DefaultClip = ent.Rounds
    -- wep.Primary.Ammo = ent.Ammo
    local wep = ply:Give(ent.WeaponClass)
    Log.d("PickupWep", ent.Rounds)
    wep:SetClip1(ent.Rounds)
    ply:SetNWInt(ent.MRPCategory, ent.MRPID)
    ply:SetNWInt(ent.MRPCategory .. "Rounds", ent.Rounds)
    ent:Remove()
end


net.Receive("PlayerDropAmmo", function(_, ply)
    local slotID = net.ReadUInt(5)
    local ent = ents.Create(MRP.EntityTable(ply:GetNWInt("Inventory" .. slotID)).ClassName)
    ent.Rounds = ply:GetNWInt("Inventory" .. slotID .. "Rounds")
    ply:RemoveAmmo(ent.Rounds, ent.Ammo)
    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
end)

net.Receive("PlayerDropVest", function(_, ply)
    local ent = ents.Create(MRP.EntityTable(ply:GetNWInt("Vest")).ClassName)

    if ent.Capacity then
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. k] = ply:GetNWInt("Inventory" .. k)

            if MRP.EntityTable(ply:GetNWInt("Inventory" .. k)).Ammo then
                ent["Slot" .. k .. "Rounds"] = ply:GetNWInt("Inventory" .. k .. "Rounds")
            end

            ply:SetNWInt("Inventory" .. k, 1)
        end

        -- Since the "RemoveAmmo" function call the "PlayerAmmoChanged" function which
        -- change the "Inventory" networked value we have to do a boucle again ...
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            if MRP.EntityTable(ply:GetNWInt("Inventory" .. k)).Ammo then
                local ammoType = MRP.EntityTable(ply:GetNWInt("Inventory" .. k)).Ammo
                ply:RemoveAmmo(ply:GetNWInt("Inventory" .. k .. "Rounds"), ammoType)
            end
        end
    end

    if ent.Armor then
        ent.Armor = ply:GetNWInt("VestArmor")
    end

    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
    ply:SetNWInt("Vest", 1)
end)

net.Receive("RagdollDropVest", function(_, ply)
    local target = net.ReadEntity()
    local ent = ents.Create(MRP.EntityTable(target:GetNWInt("Vest")).ClassName)

    if ent.Capacity then
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. k] = target:GetNWInt("Inventory" .. k)

            if MRP.EntityTable(target:GetNWInt("Inventory" .. k)).Ammo then
                ent["Slot" .. k .. "Rounds"] = target:GetNWInt("Inventory" .. k .. "Rounds")
            end

            target:SetNWInt("Inventory" .. k, 1)
        end
    end

    if ent.Armor then
        ent.Armor = target:GetNWInt("VestArmor")
    end

    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
    target:SetNWInt("Vest", 1)
end)

net.Receive("RagdollDropWep", function(_, ply)
    local category = net.ReadString()
    local target = net.ReadEntity()
    local ent = ents.Create(MRP.EntityTable(target:GetNWInt(category)).ClassName)
    ent.Rounds = target:GetNWInt(category .. "Rounds")
    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
    target:SetNWInt(category, 1)
end)

net.Receive("PlayerChangeRucksackWithRagdoll", function(_, ply)
    local ragdoll = net.ReadEntity()
    local entityTable = ply:MRPEntityTable("Rucksack")
    local ragdollRucksack = ents.Create(entityTable.ClassName)
    setupRagdollRucksack(ragdoll, ragdollRucksack)
    ply:ChangeRucksack(ragdollRucksack)
end)

net.Receive("PlayerEquipRagdollRucksack", function(_, ply)
    local ragdoll = net.ReadEntity()
    local entityTable = ply:MRPEntityTable("Rucksack")
    local ragdollRucksack = ents.Create(entityTable.ClassName)
    setupRagdollRucksack(ragdoll, ragdollRucksack)
    ply:EquipRucksack(ragdollRucksack)
end)

net.Receive("ItemSwitchSlot", function(_, _)
    local ent = net.ReadEntity()
    local oldSlotName = net.ReadString()
    local newSlotName = net.ReadString()
    ent:SetNWInt(newSlotName, ent:GetNWInt(oldSlotName))
    ent:SetNWInt(oldSlotName, 1)
    ent:SetNWInt(newSlotName .. "Rounds", ent:GetNWInt(oldSlotName .. "Rounds"))
    ent:SetNWInt(newSlotName .. "Armor", ent:GetNWInt(oldSlotName .. "Armor"))
    ent:SetNWInt(oldSlotName .. "Rounds", 0)
    ent:SetNWInt(oldSlotName .. "Armor", 0)
end)

net.Receive("ItemSwitchOwner", function(_, _)
    local oldOwner = net.ReadEntity()
    local oldSlotName = net.ReadString()
    local newOwner = net.ReadEntity()
    local newSlotName = net.ReadString()
    newOwner:SetNWInt(newSlotName, oldOwner:GetNWInt(oldSlotName))
    oldOwner:SetNWInt(oldSlotName, 1)
    newOwner:SetNWInt(newSlotName .. "Rounds", oldOwner:GetNWInt(oldSlotName .. "Rounds"))
    newOwner:SetNWInt(newSlotName .. "Armor", oldOwner:GetNWInt(oldSlotName .. "Armor"))
    oldOwner:SetNWInt(oldSlotName .. "Rounds", 0)
    oldOwner:SetNWInt(oldSlotName .. "Armor", 0)
end)

net.Receive("MRPDrop", function(_, ply)
    local MRPID = net.ReadUInt(7)
    local target = net.ReadEntity()
    local slotName = net.ReadString()
    MRP.EntityTable(MRPID):drop(slotName, target, ply)
end)

net.Receive("Use", function(_, ply)
    ply:SelectWeapon(net.ReadString())
end)

function MRP.SaveProgress(ply)
    if player_manager.GetPlayerClass(ply) == "player" then
        for _, cat in pairs(MRP.WeaponCat) do
            if ply:MRPHas(cat) then
                local wep = ply:GetWeapon(ply:MRPEntityTable(cat).WeaponClass)
                sql.Query(
                    "UPDATE mrp_characters " ..
                    "SET " .. cat .. "Rounds = " .. wep:Clip1() .. " " ..
                    "WHERE UID = " .. ply:MRPCharacterID()
                )
            end
        end

        local InventoryAmmo = tostring(ply:GetNWInt("Inventory1Ammo"))

        for k = 2, 20 do
            InventoryAmmo = InventoryAmmo .. "," .. ply:GetNWInt("Inventory" .. k .. "Rounds")
        end

        local InventoryArmor = tostring(ply:GetNWInt("Inventory1Armor"))

        for k = 2, 20 do
            InventoryArmor = InventoryArmor .. "," .. ply:GetNWInt("Inventory" .. k .. "Armor")
        end

        local Inventory = {}

        for k = 1, 20 do
            Inventory[k] = ply:GetNWInt("Inventory" .. k)
        end

        Inventory = table.concat(Inventory, ",")
        sql.Query(
            "UPDATE mrp_characters " ..
            "SET " ..
                "Rank = " .. ply:GetNWInt("Rank") .. "," ..
                "PrimaryWep = " .. ply:GetNWInt("PrimaryWep") .. "," ..
                "SecondaryWep = " .. ply:GetNWInt("SecondaryWep") .. "," ..
                "RocketLauncher = " .. ply:GetNWInt("RocketLauncher") .. "," ..
                "Vest = " .. ply:GetNWInt("Vest") .. ", " ..
                "VestArmor = " .. ply:GetNWInt("VestArmor") .. ", " ..
                "Rucksack = " .. ply:GetNWInt("Rucksack") .. ", " ..
                "Radio = " .. ply:GetNWInt("Radio") .. "," ..
                "Gasmask = " .. ply:GetNWInt("Gasmask") .. ", " ..
                "Helmet = " .. ply:GetNWInt("Helmet") .. ", " ..
                "HelmetArmor  = " .. ply:GetNWInt("HelmetArmor") .. ", " ..
                "NVGs = " .. ply:GetNWInt("NVGS") .. "," ..
                "Inventory = '" .. Inventory .. "'," ..
                "InventoryAmmo = '" .. InventoryAmmo .. "'," ..
                "InventoryArmor = '" .. InventoryArmor .. "' " ..
            "WHERE UID = " .. ply:MRPCharacterID() .. ";"
        )
    end
end

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "BackupPlayerData", function(userdata)
    MRP.SaveProgress(Player(userdata.userid))
end)

hook.Add("ShutDown", "ServerShuttingDown", function()
    for _, ply in pairs(player.GetAll()) do
        MRP.SaveProgress(ply)
    end
end)

local function RemoveAmmoFromBoxes(index, ammoToRemove, Ammo, ply)
    for k = index, 20 do
        if MRP.EntityTable(ply:GetNWInt("Inventory" .. (21 - k)))["Ammo"] == Ammo then
            local dataField = "Inventory" .. (21 - k) .. "Rounds"
            local newAmmo = ply:GetNWInt(dataField) - ammoToRemove
            Log.d("RemoveAmmoFromBoxes", dataField .. " " .. newAmmo)
            ply:SetNWInt(dataField, newAmmo)

            if newAmmo <= 0 then
                ply:SetNWInt("Inventory" .. (21 - k), 1)
                RemoveAmmoFromBoxes(k, -newAmmo, Ammo, ply)
            end

            break
        end
    end
end

function GM:PlayerSpawn()
end

function GM:InitPostEntity()
    local map = game.GetMap()
    local spawn
    local tableExists = MRP.spawns and MRP.spawns[map]
    local spawnClassNames =
        {
            spectators = "info_spectator",
            rebels = "info_player_rebel",
            army = "info_player_army",
        }

    if tableExists then
        for faction, className in ipairs(spawnClassNames) do
            for k = 1, #MRP.spawns[map][faction] do
                spawn = ents.Create(className)
                spawn:SetPos(MRP.spawns[map][faction][k].pos)
                spawn:Spawn()
            end
        end

        function self:PlayerSelectSpawn(ply, _)
            if ply:GetNWInt("Faction") == 1 then
                local army_spawns = ents.FindByClass("info_player_army")
                local random_entry = math.random(#army_spawns)

                return army_spawns[random_entry]
            elseif ply:GetNWInt("Faction") == 2 then
                local rebel_spawns = ents.FindByClass("info_player_rebel")
                local random_entry = math.random(#rebel_spawns)

                return rebel_spawns[random_entry]
            elseif player_manager.GetPlayerClass(ply) == "spectator" then
                local spectator_spawns = ents.FindByClass("info_spectator")
                local random_entry = math.random(#spectator_spawns)

                return spectator_spawns[random_entry]
            end
        end
    end
end

function GM:PlayerInitialSpawn(ply, _)
    player_manager.SetPlayerClass(ply, "spectator")
    ply:SetShouldServerRagdoll(true)
    ply:SetNWString("RPName", ply:Nick())
    ply:AllowFlashlight(true)
end

function GM:PlayerAmmoChanged(ply, ammoID, oldCount, newCount)
    local ammo = game.GetAmmoName(ammoID)

    if newCount < oldCount then
        local roundsToRemove = oldCount - newCount
        local startingIndex = 1
        RemoveAmmoFromBoxes(startingIndex, roundsToRemove, ammo, ply)
    end
end

function GM:PlayerNoClip(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

MRP.removeCharacterFromDatabase = function(ply)
    if player_manager.GetPlayerClass(ply) ~= "spectator" then
        sql.Query("DELETE FROM mrp_characters WHERE UID = " .. tostring(ply:MRPCharacterID()))
        player_manager.SetPlayerClass(ply, "spectator")
    end
end

function GM:CreateEntityRagdoll(owner, ragdoll)
    if owner:IsPlayer() then
        ragdoll:AddEFlags(EFL_IN_SKYBOX)

        for k = 1, 20 do
            local dataField = "Inventory" .. k
            ragdoll:SetNWInt(dataField, owner:GetNWInt(dataField))
            ragdoll:SetNWInt(dataField .. "Rounds", owner:GetNWInt(dataField .. "Rounds"))
        end

        ragdoll:SetNWInt("Helmet", owner:GetNWInt("Helmet"))
        ragdoll:SetNWInt("HelmetArmor", owner:GetNWInt("HelmetArmor"))
        ragdoll:SetNWInt("NVGs", owner:GetNWInt("NVGs"))
        ragdoll:SetNWInt("Gasmask", owner:GetNWInt("Gasmask"))
        ragdoll:SetNWInt("Rucksack", owner:GetNWInt("Rucksack"))
        ragdoll:SetNWInt("Vest", owner:GetNWInt("Vest"))
        ragdoll:SetNWInt("VestArmor", owner:GetNWInt("VestArmor"))
        ragdoll:SetNWInt("PrimaryWep", owner:GetNWInt("PrimaryWep"))
        ragdoll:SetNWInt("SecondaryWep", owner:GetNWInt("SecondaryWep"))
        ragdoll:SetNWInt("RocketLauncher", owner:GetNWInt("RocketLauncher"))
        ragdoll:SetNWInt("Faction", owner:GetNWInt("Faction"))
        ragdoll:SetNWInt("ModelIndex", owner:GetNWInt("ModelIndex"))
        ragdoll:SetNWInt("GasmaskOn", owner:GetNWInt("GasmaskOn"))

        for _, wepCat in pairs(MRP.WeaponCat) do
            if owner:MRPHas(wepCat) then
                ragdoll:SetNWInt(wepCat .. "Rounds", owner:MRPWeapon(wepCat):Clip1())
            end
        end
    end
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    local gear
    local function ScaleDamage()
        local baseArmor = MRP.EntityTable(ply:GetNWInt(gear)).Armor
        local newArmor =
            math.Clamp(
                math.floor(ply:GetNWInt(gear .. "Armor") - dmginfo:GetDamage()),
                0,
                baseArmor
            )
        ply:SetNWInt(gear .. "Armor", newArmor)
        dmginfo:SetDamage(
            dmginfo:GetDamage() * (1 - ply:GetNWInt(gear .. "Armor") / baseArmor)
        )
    end

    if hitgroup == HITGROUP_HEAD and ply:MRPHas("Helmet") then
        gear = "Helmet"
        ScaleDamage()
    elseif hitgroup == HITGROUP_CHEST and ply:MRPHas("Vest") then
        gear = "Vest"
        ScaleDamage()
    end
end

function GM:PlayerSay(sender, text, _)
    if string.sub(text, 1, 1) == "/" then
        sender:ConCommand(string.sub(text, 2, #text))

        return ""
    end

    return text
end

function GM:PlayerSpawnEffect(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnNPC(ply, _, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnObject(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnProp(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnRagdoll(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnSENT(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnSWEP(ply, _, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnVehicle(ply, _, _, _)
    if IsValid(ply) then
        if ply:IsAdmin() then
            return true
        else
            return false
        end
    else
        return true
    end
end
