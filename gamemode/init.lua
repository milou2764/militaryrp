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

local tbName = MRP.TABLE_CHAR

local schema =
    "CREATE TABLE " .. SQLStr(tbName) .. "(" ..
    "CharacterID INTEGER PRIMARY KEY autoincrement," ..
    "SteamID64 BIGINT NOT NULL," ..
    "Faction INT," ..
    "Regiment INT," ..
    "Rank INT DEFAULT '1'," ..
    "RPName TEXT," ..
    "ModelIndex INT," ..
    "Size SMALLINT NOT NULL," ..
    "Skin TINYINT," ..
    "BodyGroups TEXT" ..
    ")"

MRP.UpdateTable = function(name, schema)
    local existingTable =
        sql.QueryValue(
            "SELECT sql FROM sqlite_master " ..
            "WHERE name = " .. SQLStr(name)
        )
    if existingTable ~= schema then
        Log.e(TAG, name .. " TABLE CHANGED SINCE LAST TIME")
        Log.e(TAG, "DELETING ...")
        sql.Query("DROP TABLE " .. SQLStr(name))
        sql.Query(schema)
    else
        Log.d(TAG, "TABLE DID NOT CHANGED")
    end
end

MRP.UpdateTable(MRP.TABLE_CHAR, schema)

MRP.SQLRequest = function(request)
    local sqlret = sql.Query(request)
    if sqlret == false then
        print("### MRP error in SQL request")
        print(request)
        print(sql.LastError())
    end
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
        "UPDATE " .. tbname .. " SET BodyGroups = " .. SQLStr(BodyGroups) ..
        " WHERE CharacterID = " .. ply:MRPCharacterID()
    )
end

net.Receive("Use", function(_, ply)
    ply:SelectWeapon(net.ReadString())
end)

function MRP.SaveProgress(ply)
    if player_manager.GetPlayerClass(ply) ~= "player" then return end
    local cid = ply:MRPCharacterID()
    hook.Run("MRP::SaveProgress", ply, cid)
    sql.Query(
        "UPDATE " .. tbName
        " SET " ..
            "Rank = " .. ply:GetNWInt("Rank") ..
        " WHERE CharacterID = " .. cid .. ";"
    )
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

-- Allow executing commands with the chat
function GM:PlayerSay(sender, text, _)
    if string.sub(text, 1, 1) == "/" then
        sender:ConCommand(string.sub(text, 2, #text))

        return ""
    end

    return text
end

function GM:PlayerNoClip(ply, _)
    if ply:IsAdmin() then
        return true
    else
        return false
    end
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
