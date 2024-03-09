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
util.AddNetworkString("MRPClientPutNVGsOn")
util.AddNetworkString("MRPClientPutNVGsOff")
util.AddNetworkString("MRPPlayerTakeOnNVGs")
util.AddNetworkString("MRPPlayerTakeOffNVGs")
util.AddNetworkString("MRPPlayerTakeOnGasmask")
util.AddNetworkString("MRPPlayerTakeOffGasmask")
util.AddNetworkString("MRPPlayerDeath")
util.AddNetworkString("MRPCreateRagdollCS")
util.AddNetworkString("MRPPlayerSpawn")
local existingTable = sql.QueryValue("SELECT sql FROM sqlite_master WHERE name = 'mrp_characters';")
--print(existingTable.sql)
local request = "CREATE TABLE mrp_characters( UID INTEGER PRIMARY KEY autoincrement," .. "SteamID64 BIGINT NOT NULL," .. "Faction BOOL," .. "Regiment TINYINT," .. "Rank TINYINT DEFAULT '0'," .. "RPName VARCHAR(45)," .. "ModelIndex TINYINT," .. "Size SMALLINT NOT NULL," .. "Skin TINYINT," .. "BodyGroups VARCHAR(60)," .. "PrimaryWep TINYINT DEFAULT '1'," .. "PrimaryWepAmmo TINYINT DEFAULT '0'," .. "SecondaryWep TINYINT DEFAULT '1'," .. "SecondaryWepAmmo TINYINT DEFAULT '0'," .. "RocketLauncher TINYINT DEFAULT '1'," .. "RocketLauncherAmmo TINYINT DEFAULT '0'," .. "Vest TINYINT DEFAULT '1'," .. "VestArmor TINYINT DEFAULT '0'," .. "Rucksack TINYINT DEFAULT '1'," .. "Radio TINYINT DEFAULT '1'," .. "Gasmask TINYINT DEFAULT '1'," .. "Helmet TINYINT DEFAULT '1'," .. "HelmetArmor TINYINT DEFAULT '0'," .. "NVGs TINYINT DEFAULT '1'," .. "Inventory VARCHAR(60) DEFAULT '1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'," .. "InventoryAmmo VARCHAR(120) DEFAULT '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'," .. "InventoryArmor VARCHAR(120) DEFAULT '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'" .. ")"

if existingTable ~= request then
    --print(request)
    sql.Query("DROP TABLE mrp_characters;")
    sql.Query(request)
end

local fol = GM.FolderName .. "/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
local SortedPairs = SortedPairs

for _, v in ipairs(files) do
    if MRP.disabledDefaults["modules"][v:Left(-5)] then continue end
    if string.GetExtensionFromFilename(v) ~= "lua" then continue end
    include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
    if folder == "." or folder == ".." or MRP.disabledDefaults["modules"][folder] then continue end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/sh_*.lua", "LUA"), true) do
        if File == "sh_interface.lua" then continue end
        AddCSLuaFile(fol .. folder .. "/" .. File)
        include(fol .. folder .. "/" .. File)
    end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/sv_*.lua", "LUA"), true) do
        if File == "sv_interface.lua" then continue end
        include(fol .. folder .. "/" .. File)
    end

    for _, File in SortedPairs(file.Find(fol .. folder .. "/cl_*.lua", "LUA"), true) do
        if File == "cl_interface.lua" then continue end
        AddCSLuaFile(fol .. folder .. "/" .. File)
    end
end

local function CheckData(ply)
    local data = sql.Query(" SELECT * FROM mrp_characters WHERE SteamID64 = " .. tostring(ply:SteamID64()))

    --PrintTable(data)
    if not data then
        net.Start("CharacterCreation")
        net.Send(ply)
    else
        net.Start("CharacterSelection")
        net.WriteUInt(#data, 5)

        for k, v in pairs(data) do
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

local function RunEquipment(ply)
    player_manager.SetPlayerClass(ply, "player")
    ply:Spawn()
    ply:SetShouldServerRagdoll(true)

    if ply:GetNWInt("PrimaryWep") > 1 then
        local ent = ents.Create(MRP.getMRPEnt(ply:GetNWInt("PrimaryWep")).wepClass)
        ent.Primary.DefaultClip = 0
        ent.Primary.Ammo = MRP.getMRPEnt(ply:GetNWInt("PrimaryWep")).ammo
        ply:PickupWeapon(ent)
        ent:SetClip1(ply.PrimaryWepAmmo)
    end

    if ply:GetNWInt("SecondaryWep") > 1 then
        local ent = ents.Create(MRP.getMRPEnt(ply:GetNWInt("SecondaryWep")).wepClass)
        ent.Primary.DefaultClip = 0
        ent.Primary.Ammo = MRP.getMRPEnt(ply:GetNWInt("SecondaryWep")).ammo
        ply:PickupWeapon(ent)
        ent:SetClip1(ply.SecondaryWepAmmo)
    end

    if ply:GetNWInt("RocketLauncher") > 1 then
        local ent = ents.Create(MRP.getMRPEnt(ply:GetNWInt("RocketLauncher")).wepClass)
        ent.Primary.DefaultClip = 0
        ent.Primary.Ammo = MRP.getMRPEnt(ply:GetNWInt("RocketLauncher")).ammo
        ply:PickupWeapon(ent)
        ent:SetClip1(ply.RocketLauncherAmmo)
    end

    for k = 1, 20 do
        if MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).ammoName then
            ply:GiveAmmo(ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo"), MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).ammoName, true)
        elseif MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).wepClass then
            ply:Give(MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).wepClass)
        end
    end
end

function MRP.SaveInventoryData(ply)
    local Inventory = {}

    for k = 1, 20 do
        Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
    end

    Inventory = table.concat(Inventory, ",")
    sql.Query("UPDATE mrp_characters SET Inventory = '" .. Inventory .. "' WHERE UID = " .. tostring(ply:GetCharacterID()))
end

function MRP.SaveBodyGroupsData(ply)
    local BodyGroups = tostring(ply:GetBodygroup(0))

    for k = 1, ply:GetNumBodyGroups() - 1 do
        BodyGroups = BodyGroups .. "," .. tostring(ply:GetBodygroup(k))
    end

    sql.Query("UPDATE mrp_characters SET BodyGroups = '" .. BodyGroups .. "' WHERE UID = " .. tostring(ply:GetCharacterID()))
end

function MRP.PickupAmmoBox(ply, ent)
    local taken = false

    for k = 1, 20 do
        if ply:GetNWInt("Inventory" .. tostring(k)) == ent.MRPID and ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo") < MRP.getMRPEnt(ent.MRPID).capacity and ent.ammoCount > 0 then
            local temp = MRP.getMRPEnt(ent.MRPID).capacity - ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo")
            ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo") + ent.ammoCount)

            if ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo") > MRP.getMRPEnt(ent.MRPID).capacity then
                ply:GiveAmmo(temp, ent.ammoName)
                ent.ammoCount = ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo") - MRP.getMRPEnt(ent.MRPID).capacity
                ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", MRP.getMRPEnt(ent.MRPID).capacity)
            else
                ply:GiveAmmo(ent.ammoCount, ent.ammoName)
            end
        end

        if ply:GetNWInt("Inventory" .. tostring(k)) == 1 and ent.ammoCount > 0 then
            ply:GiveAmmo(ent.ammoCount, ent.ammoName)
            ply:SetNWInt("Inventory" .. tostring(k), ent.MRPID)
            ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", ent.ammoCount)
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
    sql.Query("UPDATE mrp_characters SET Rucksack = " .. tostring(ent.MRPID) .. " WHERE UID = " .. tostring(ply:GetCharacterID()))
    ply:SetBodygroup(ent.BodyGroup[ply:GetNWInt("Faction")][ply:GetNWInt("ModelIndex")][1], ent.BodyGroup[ply:GetNWInt("Faction")][ply:GetNWInt("ModelIndex")][2])
    MRP.SaveBodyGroupsData(ply)
    local Inventory = {}

    for k = 1, 20 do
        Inventory[k] = ply:GetNWInt("Inventory" .. tostring(k))
    end

    for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
        Inventory[k] = ent["Slot" .. tostring(k)]
        ply:SetNWInt("Inventory" .. tostring(k), ent["Slot" .. tostring(k)])

        if MRP.getMRPEnt(ent["Slot" .. tostring(k)]).ammoName then
            ply:GiveAmmo(ent["Slot" .. tostring(k) .. "ammoCount"], MRP.getMRPEnt(ent["Slot" .. tostring(k)]).ammoName)
            ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", ent["Slot" .. tostring(k) .. "ammoCount"])
        end
    end

    Inventory = table.concat(Inventory, ",")
    sql.Query("UPDATE mrp_characters SET Inventory = '" .. Inventory .. "' WHERE UID = " .. tostring(ply:GetCharacterID()))
    ent:Remove()
end

function MRP.PickupWep(ply, ent)
    local wep = ents.Create(ent.wepClass)
    wep.Primary.DefaultClip = ent.ammoCount
    wep.Primary.Ammo = ent.ammo
    ply:PickupWeapon(wep)
    wep:SetClip1(ent.ammoCount)
    ply:SetNWInt(ent.MRPCategory, ent.MRPID)
    ply:SetNWInt(ent.MRPCategory .. "Ammo", ent.ammoCount)
    ent:Remove()
end

net.Receive("CharacterInformation", function(len, ply)
    ply:SetNWInt("Faction", net.ReadBit())
    ply:SetNWInt("Regiment", net.ReadUInt(4))
    ply:SetNWInt("Rank", 0)
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
        ply:SetNWInt("Inventory" .. tostring(k), 1)
        ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", 0)
    end

    for k = 6, 20 do
        ply:SetNWInt("Inventory" .. tostring(k), 0)
        ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", 0)
    end

    request = [[INSERT INTO mrp_characters (SteamID64, Faction, Regiment, RPName, ModelIndex, Size, Skin, BodyGroups) VALUES( ]] .. ply:SteamID64() .. [[, ]] .. tostring(ply:GetNWInt("Faction")) .. [[, ]] .. tostring(ply:GetNWInt("Regiment")) .. [[, ]] .. SQLStr(ply:GetNWString("RPName")) .. [[, ]] .. tostring(ply:GetNWInt("ModelIndex")) .. [[, ]] .. tostring(ply:GetNWInt("Size")) .. [[, ]] .. tostring(ply:GetNWInt("Skin")) .. [[, ']] .. ply.BodyGroups .. [[') ]] --SteamID64 BIGINT NOT NULL --Faction BOOL --Regiment TINYINT --RPName VARCHAR(45) --ModelIndex TINYINT --Size SMALLINT NOT NULL --Skin TINYINT --BodyGroups VARCHAR(60)
    --print(request)
    sql.Query(request)
    local sqlret = sql.Query("SELECT * FROM mrp_characters WHERE SteamID64 = " .. ply:SteamID64() .. " AND RPName = " .. SQLStr(ply:GetNWString("RPName")) .. ";")
    ply:SetNWInt("CharacterID", tonumber(sqlret[#sqlret]["UID"]))
    ply.BodyGroups = string.Split(ply.BodyGroups, ",")
    RunEquipment(ply)
end)

net.Receive("DeleteCharacter", function(len, ply)
    local uid = net.ReadUInt(32)
    sql.Query("DELETE FROM mrp_characters WHERE UID = " .. tostring(uid))
end)

net.Receive("CharacterSelected", function(len, ply)
    local uid = net.ReadUInt(32)
    local Character = sql.QueryRow("SELECT * FROM mrp_characters WHERE UID = " .. tostring(uid))
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
    ply.PrimaryWepAmmo = tonumber(Character.PrimaryWepAmmo)
    ply:SetNWInt("SecondaryWep", tonumber(Character.SecondaryWep))
    ply.SecondaryWepAmmo = tonumber(Character.SecondaryWepAmmo)
    ply:SetNWInt("RocketLauncher", tonumber(Character.RocketLauncher))
    ply.RocketLauncherAmmo = tonumber(Character.RocketLauncherAmmo)
    ply:SetNWInt("Vest", tonumber(Character.Vest))
    ply:SetNWInt("VestArmor", tonumber(Character.VestArmor))
    ply:SetNWInt("Rucksack", tonumber(Character.Rucksack))
    ply:SetNWInt("Gasmask", tonumber(Character.Gasmask))
    ply:SetNWInt("Helmet", tonumber(Character.Helmet))
    ply:SetNWInt("HelmetArmor", tonumber(Character.HelmetArmor))
    ply:SetNWInt("NVGs", tonumber(Character.NVGs))
    Character.Inventory = string.Split(Character.Inventory, ",")
    Character.InventoryAmmo = string.Split(Character.InventoryAmmo, ",")
    Character.InventoryArmor = string.Split(Character.InventoryArmor, ",")

    for k = 1, 20 do
        ply:SetNWInt("Inventory" .. tostring(k), tonumber(Character.Inventory[k]))
        ply:SetNWInt("Inventory" .. tostring(k) .. "Ammo", tonumber(Character.InventoryAmmo[k]))
        ply:SetNWInt("Inventory" .. tostring(k) .. "Armor", tonumber(Character.InventoryArmor[k]))
    end

    RunEquipment(ply)
end)

net.Receive("PlayerDropAmmo", function(len, ply)
    local slotID = net.ReadUInt(5)
    local ent = ents.Create(MRP.getMRPEnt(ply:GetNWInt("Inventory" .. slotID)).ClassName)
    ent.ammoCount = ply:GetNWInt("Inventory" .. slotID .. "Ammo")
    ply:RemoveAmmo(ent.ammoCount, ent.ammoName)
    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
end)

net.Receive("PlayerDropVest", function(len, ply)
    local ent = ents.Create(MRP.getMRPEnt(ply:GetNWInt("Vest")).ClassName)

    if ent.Capacity then
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. tostring(k)] = ply:GetNWInt("Inventory" .. tostring(k))

            if MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).ammoName then
                ent["Slot" .. tostring(k) .. "ammoCount"] = ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo")
            end

            ply:SetNWInt("Inventory" .. tostring(k), 1)
        end

        -- Since the "RemoveAmmo" function call the "PlayerAmmoChanged" function which change the "Inventory" networked value we have to do a boucle again ...
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            if MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).ammoName then
                ply:RemoveAmmo(ply:GetNWInt("Inventory" .. tostring(k) .. "Ammo"), MRP.getMRPEnt(ply:GetNWInt("Inventory" .. tostring(k))).ammoName)
            end
        end
    end

    if ent.armor then
        ent.armor = ply:GetNWInt("VestArmor")
    end

    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
    ply:SetNWInt("Vest", 1)
end)

net.Receive("RagdollDropVest", function(len, ply)
    local target = net.ReadEntity()
    local ent = ents.Create(MRP.getMRPEnt(target:GetNWInt("Vest")).ClassName)

    if ent.Capacity then
        for k = ent.StartingIndex, ent.StartingIndex + ent.Capacity - 1 do
            ent["Slot" .. k] = target:GetNWInt("Inventory" .. k)

            if MRP.getMRPEnt(target:GetNWInt("Inventory" .. k)).ammoName then
                ent["Slot" .. k .. "ammoCount"] = target:GetNWInt("Inventory" .. k .. "Ammo")
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

net.Receive("RagdollDropWep", function(len, ply)
    local category = net.ReadString()
    local target = net.ReadEntity()
    local ent = ents.Create(MRP.getMRPEnt(target:GetNWInt(category)).ClassName)
    ent.ammoCount = target:GetNWInt(category .. "Ammo")
    ent:Spawn()
    ent:SetPos(ply:EyePos() - Vector(0, 0, 10))
    target:SetNWInt(category, 1)
end)

net.Receive("PlayerChangeRucksackWithRagdoll", function(len, ply)
    local ragdoll = net.ReadEntity()
    local ragdollRucksack = ents.Create(MRP.getMRPEnt(ragdoll:GetNWInt("Rucksack")).ClassName)
    setupRagdollRucksack(ragdoll, ragdollRucksack)
    ply:ChangeRucksack(ragdollRucksack)
end)

net.Receive("PlayerEquipRagdollRucksack", function(len, ply)
    local ragdoll = net.ReadEntity()
    local ragdollRucksack = ents.Create(MRP.getMRPEnt(ragdoll:GetNWInt("Rucksack")).ClassName)
    setupRagdollRucksack(ragdoll, ragdollRucksack)
    ply:EquipRucksack(ragdollRucksack)
end)

net.Receive("ItemSwitchSlot", function(len, ply)
    local ent = net.ReadEntity()
    local oldSlotName = net.ReadString()
    local newSlotName = net.ReadString()
    ent:SetNWInt(newSlotName, ent:GetNWInt(oldSlotName))
    ent:SetNWInt(oldSlotName, 1)
    ent:SetNWInt(newSlotName .. "Ammo", ent:GetNWInt(oldSlotName .. "Ammo"))
    ent:SetNWInt(newSlotName .. "Armor", ent:GetNWInt(oldSlotName .. "Armor"))
    ent:SetNWInt(oldSlotName .. "Ammo", 0)
    ent:SetNWInt(oldSlotName .. "Armor", 0)
end)

net.Receive("ItemSwitchOwner", function(len, ply)
    local oldOwner = net.ReadEntity()
    local oldSlotName = net.ReadString()
    local newOwner = net.ReadEntity()
    local newSlotName = net.ReadString()
    newOwner:SetNWInt(newSlotName, oldOwner:GetNWInt(oldSlotName))
    oldOwner:SetNWInt(oldSlotName, 1)
    newOwner:SetNWInt(newSlotName .. "Ammo", oldOwner:GetNWInt(oldSlotName .. "Ammo"))
    newOwner:SetNWInt(newSlotName .. "Armor", oldOwner:GetNWInt(oldSlotName .. "Armor"))
    oldOwner:SetNWInt(oldSlotName .. "Ammo", 0)
    oldOwner:SetNWInt(oldSlotName .. "Armor", 0)
end)

net.Receive("MRPDrop", function(len, ply)
    local MRPID = net.ReadUInt(7)
    local target = net.ReadEntity()
    local slotName = net.ReadString()
    MRP.getMRPEnt(MRPID):drop(slotName, target, ply)
end)

net.Receive("Use", function(len, ply)
    ply:SelectWeapon(net.ReadString())
end)

function MRP.SaveProgress(ply)
    if player_manager.GetPlayerClass(ply) == "player" then
        if ply:GetNWInt("PrimaryWep") > 1 then
            sql.Query("UPDATE mrp_characters SET PrimaryWepAmmo = " .. ply:GetWeapon(MRP.getMRPEnt(ply:GetNWInt("PrimaryWep")).wepClass):Clip1() .. " WHERE UID = " .. ply:GetCharacterID())
        end

        if ply:GetNWInt("SecondaryWep") > 1 then
            sql.Query("UPDATE mrp_characters SET SecondaryWepAmmo = " .. ply:GetWeapon(MRP.getMRPEnt(ply:GetNWInt("SecondaryWep")).wepClass):Clip1() .. " WHERE UID = " .. ply:GetCharacterID())
        end

        if ply:GetNWInt("RocketLauncher") > 1 then
            sql.Query("UPDATE mrp_characters SET RocketLauncherAmmo = " .. ply:GetWeapon(MRP.getMRPEnt(ply:GetNWInt("RocketLauncher")).wepClass):Clip1() .. " WHERE UID = " .. ply:GetCharacterID())
        end

        local InventoryAmmo = tostring(ply:GetNWInt("Inventory1Ammo"))

        for k = 2, 20 do
            InventoryAmmo = InventoryAmmo .. "," .. ply:GetNWInt("Inventory" .. k .. "Ammo")
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
        sql.Query("UPDATE mrp_characters SET " .. "Rank = " .. ply:GetNWInt("Rank") .. "," .. "PrimaryWep = " .. ply:GetNWInt("PrimaryWep") .. "," .. "SecondaryWep = " .. ply:GetNWInt("SecondaryWep") .. "," .. "RocketLauncher = " .. ply:GetNWInt("RocketLauncher") .. "," .. "Vest = " .. ply:GetNWInt("Vest") .. ", " .. "VestArmor = " .. ply:GetNWInt("VestArmor") .. ", " .. "Rucksack = " .. ply:GetNWInt("Rucksack") .. ", " .. "Radio = " .. ply:GetNWInt("Radio") .. "," .. "Gasmask = " .. ply:GetNWInt("Gasmask") .. ", " .. "Helmet = " .. ply:GetNWInt("Helmet") .. ", " .. "HelmetArmor  = " .. ply:GetNWInt("HelmetArmor") .. ", " .. "NVGs = " .. ply:GetNWInt("NVGS") .. "," .. "Inventory = '" .. Inventory .. "'," .. "InventoryAmmo = '" .. InventoryAmmo .. "'," .. "InventoryArmor = '" .. InventoryArmor .. "'" .. " WHERE UID = " .. ply:GetCharacterID() .. ";")
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

local function RemoveAmmoFromBoxes(index, AmmoCountToRemove, ammoName, ply)
    for k = index, 20 do
        if MRP.getMRPEnt(ply:GetNWInt("Inventory" .. (21 - k)))["ammoName"] == ammoName then
            ply:SetNWInt("Inventory" .. (21 - k) .. "Ammo", ply:GetNWInt("Inventory" .. (21 - k) .. "Ammo") - AmmoCountToRemove)

            if ply:GetNWInt("Inventory" .. (21 - k) .. "Ammo") <= 0 then
                ply:SetNWInt("Inventory" .. (21 - k), 1)
                RemoveAmmoFromBoxes(k, -ply:GetNWInt("Inventory" .. (21 - k) .. "Ammo"), ammoName, ply)
            end

            break
        end
    end
end

function GM:InitPostEntity()
    local map = game.GetMap()
    local spawn

    if MRP.spawns and MRP.spawns[map] and MRP.spawns[map].spectators and MRP.spawns[map].rebels and MRP.spawns[map].army then
        for k = 1, #MRP.spawns[map].spectators do
            spawn = ents.Create("info_spectator")
            spawn:SetPos(MRP.spawns[map].spectators[k].pos)
            spawn:Spawn()
        end

        for k = 1, #MRP.spawns[map].rebels do
            spawn = ents.Create("info_player_rebel")
            spawn:SetPos(MRP.spawns[map].rebels[k].pos)
            spawn:Spawn()
        end

        for k = 1, #MRP.spawns[map].army do
            spawn = ents.Create("info_player_army")
            spawn:SetPos(MRP.spawns[map].army[k].pos)
            spawn:Spawn()
        end

        function self:PlayerSelectSpawn(ply, transition)
            if ply:GetNWInt("Faction") == 0 then
                local army_spawns = ents.FindByClass("info_player_army")
                local random_entry = math.random(#army_spawns)

                return army_spawns[random_entry]
            elseif ply:GetNWInt("Faction") == 1 then
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

function GM:PlayerInitialSpawn(ply, transition)
    player_manager.SetPlayerClass(ply, "spectator")
    ply:SetShouldServerRagdoll(true)
    ply:SetNWString("RPName", ply:Nick())
    ply:AllowFlashlight(true)
end

function GM:PlayerSpawn(ply, transition)
    if player_manager.GetPlayerClass(ply) == "spectator" then
        --local view_ent = ents.FindByName("spectator_view")[1]
        --ply:SetViewEntity(view_ent)
        CheckData(ply)
    else
        --ply:SetViewEntity(ply)
        ply:SetModel(MRP.PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].model)
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
end

function GM:PlayerAmmoChanged(ply, ammoID, oldCount, newCount)
    local ammoName = game.GetAmmoName(ammoID)

    if newCount < oldCount then
        local AmmoCountToRemove = oldCount - newCount
        local startingIndex = 1
        RemoveAmmoFromBoxes(startingIndex, AmmoCountToRemove, ammoName, ply)
    end
end

function GM:PlayerNoClip(ply, desiredState)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

MRP.removeCharacterFromDatabase = function(ply)
    if player_manager.GetPlayerClass(ply) ~= "spectator" then
        sql.Query("DELETE FROM mrp_characters WHERE UID = " .. tostring(ply:GetCharacterID()))
        player_manager.SetPlayerClass(ply, "spectator")
    end
end

function GM:CreateEntityRagdoll(owner, ragdoll)
    if owner:IsPlayer() then
        ragdoll:AddEFlags(EFL_IN_SKYBOX)

        for k = 1, 20 do
            ragdoll:SetNWInt("Inventory" .. k, owner:GetNWInt("Inventory" .. k))
            ragdoll:SetNWInt("Inventory" .. k .. "Ammo", owner:GetNWInt("Inventory" .. k .. "Ammo"))
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

        if owner:GetNWInt("PrimaryWep") > 1 then
            ragdoll:SetNWInt("PrimaryWepAmmo", owner:GetWeapon(MRP.getMRPEnt(owner:GetNWInt("PrimaryWep")).wepClass):Clip1())
        end

        if owner:GetNWInt("SecondaryWep") > 1 then
            ragdoll:SetNWInt("SecondaryWepAmmo", owner:GetWeapon(MRP.getMRPEnt(owner:GetNWInt("SecondaryWep")).wepClass):Clip1())
        end

        if owner:GetNWInt("RocketLauncher") > 1 then
            ragdoll:SetNWInt("RocketLauncherAmmo", owner:GetWeapon(MRP.getMRPEnt(owner:GetNWInt("RocketLauncher")).wepClass):Clip1())
        end
    end
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    if hitgroup == HITGROUP_HEAD and ply:GetNWInt("Helmet") > 1 then
        ply:SetNWInt("HelmetArmor", math.Clamp(math.floor(ply:GetNWInt("HelmetArmor") - dmginfo:GetDamage()), 0, MRP.getMRPEnt(ply:GetNWInt("Helmet")).armor))
        dmginfo:SetDamage(dmginfo:GetDamage() * (1 - ply:GetNWInt("HelmetArmor") / MRP.getMRPEnt(ply:GetNWInt("Helmet")).armor))
    elseif hitgroup == HITGROUP_CHEST and ply:GetNWInt("Vest") > 1 then
        ply:SetNWInt("VestArmor", math.Clamp(math.floor(ply:GetNWInt("VestArmor") - dmginfo:GetDamage()), 0, MRP.getMRPEnt(ply:GetNWInt("Vest")).armor))
        dmginfo:SetDamage(dmginfo:GetDamage() * (1 - ply:GetNWInt("VestArmor") / MRP.getMRPEnt(ply:GetNWInt("Vest")).armor))
    end
end

function GM:PlayerSay(sender, text, teamChat)
    if string.sub(text, 1, 1) == "/" then
        sender:ConCommand(string.sub(text, 2, #text))

        return ""
    end

    return text
end

function GM:PlayerSpawnEffect(ply, model)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnNPC(ply, npc_type, weapon)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnObject(ply, model)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnProp(ply, model)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnRagdoll(ply, model)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnSENT(ply, sent)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnSWEP(ply, swep, info)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
end

function GM:PlayerSpawnVehicle(ply, model, name, vtable)
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
