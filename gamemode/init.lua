GM.Name = "MilitaryRP"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"
DeriveGamemode("sandbox")
util.AddNetworkString("mrp_characters_update")
util.AddNetworkString("mrp_characters_creation")
util.AddNetworkString("mrp_characters_selection")
util.AddNetworkString("mrp_characters_deletion")
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

include("player_class/player.lua")
include("player_class/spectator.lua")
include("config/config.lua")
include("config/sv_config.lua")
include("config/sh_debug_state.lua")
include("config/ammotypes.lua")
include("lib/sv_utils.lua")
include("lib/sh_log.lua")
AddCSLuaFile("player_class/player.lua")
AddCSLuaFile("player_class/spectator.lua")
AddCSLuaFile("lib/sh_log.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("config/config.lua")
AddCSLuaFile("config/cl_config.lua")
AddCSLuaFile("config/sh_debug_state.lua")
AddCSLuaFile("config/ammotypes.lua")
AddCSLuaFile("vgui/misc.lua")

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


MRP.UpdateTable(MRP.TABLE_CHAR, schema)

MRP.SQLRequest = function(request)
    local TAG = "SQLReq"
    local sqlret = sql.Query(request)
    if sqlret == false then
        Log.d(TAG, "error in SQL request")
        Log.d(TAG, request)
        Log.d(TAG, sql.LastError())
    end
end

local fol = GM.FolderName .. "/gamemode/modules/"
local files, folders = file.Find(fol .. "*", "LUA")
function MRP.ReloadModules()
    local SortedPairs = SortedPairs

    for _, v in ipairs(files) do
        isDisabled = MRP.DisabledModules[v:Left(-5)]
        isLuaFile = string.GetExtensionFromFilename(v) == "lua"
        if not isDisabled and isLuaFile then
            include(fol .. v)
        end
    end

    for _, folder in SortedPairs(folders, true) do
        isDisabled = MRP.DisabledModules[folder]
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
end
MRP.ReloadModules()

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
        "UPDATE " .. tbName .. " SET BodyGroups = " .. SQLStr(BodyGroups) ..
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
        "UPDATE " .. tbName ..
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

function GM:PlayerSpawn(ply)
    ply:SetWalkSpeed(120)
    ply:SetRunSpeed(240)
end

function GM:InitPostEntity()
    local TAG = "InitPostEntity"
    local map = game.GetMap()
    local spawn
    local tableExists = MRP.Spawns and MRP.Spawns[map]
    local factions =
        {
            [0] = "spectators",
            [1] = "army",
            [2] = "rebels",
        }


    if tableExists then
        Log.d(TAG, "spawn data found")
        for _, faction in pairs(factions) do
            MRP.SpawnEnts[faction] = {}
            local factionTab = MRP.Spawns[map][faction]
            if factionTab ~=nil then
                for k = 1, #factionTab do
                    spawn = ents.Create("info_player_start")
                    spawn:SetPos(MRP.Spawns[map][faction][k].pos)
                    spawn:SetAngles(MRP.Spawns[map][faction][k].ang)
                    spawn:Spawn()
                    table.insert(MRP.SpawnEnts[faction], spawn)
                end
            end
        end

        function self:PlayerSelectSpawn(ply, _)
            local faction = factions[ply:GetNWInt("Faction")]
            local spawn_ents = MRP.SpawnEnts[faction]
            local random_entry = math.random(#spawn_ents)
            return spawn_ents[random_entry]
        end
    else
        Log.d(TAG, "spawn data NOT found")
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

function GM:PlayerGiveSWEP(ply, _, _)
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
