local lastent = nil
hook.Add('simfphysPhysicsCollide', 'MRPsimfphysPhysicsCollide', function(ent, data, _)
    local item = data.HitEntity
    if item.MRPID and item ~= lastent then
        for k = 1, 20 do
            if ent:GetNWInt('Inventory' .. k) < 2 then
                lastent = item
                item:fitIn('Inventory' .. k, ent)
                break
            end
        end
    end
end)

function MRP.SaveInventoryData(ply)
    local Inventory = {}

    for k = 1, 20 do
        Inventory[k] = ply:GetNWInt('Inventory' .. k)
    end

    Inventory = table.concat(Inventory, ',')
    sql.Query(
        'UPDATE ' .. MRP.TABLE_INV .. ' SET Inventory = ' .. SQLStr(Inventory) .. ' ' ..
        'WHERE CharacterID = ' .. ply:MRPCharacterID() .. ';'
    )
end

local tbName = MRP.TABLE_INV

hook.Add("CharacterRegistration", "InvRegistration", function(ply, uid)
    local request = "insert into " .. tbName .. "(CharacterID) VALUES("..uid..")"
    MRP.SQLRequest(request)
end)

hook.Add("CharacterSelected", "InventoryInit", function(ply, uid)
    local Inv =
        sql.QueryRow(
            "SELECT * FROM " .. tbName ..
            " WHERE CharacterID = " .. tostring(uid)
        )
    ply:SetNWInt("PrimaryWep", tonumber(Inv.PrimaryWep))
    ply.PrimaryWepRounds = tonumber(Inv.PrimaryWepRounds)
    ply:SetNWInt("SecondaryWep", tonumber(Inv.SecondaryWep))
    ply.SecondaryWepRounds = tonumber(Inv.SecondaryWepRounds)
    ply:SetNWInt("RocketLauncher", tonumber(Inv.RocketLauncher))
    ply.RocketLauncherRounds = tonumber(Inv.RocketLauncherRounds)
    ply:SetNWInt("Vest", tonumber(Inv.Vest))
    ply:SetNWInt("VestArmor", tonumber(Inv.VestArmor))
    ply:SetNWInt("Rucksack", tonumber(Inv.Rucksack))
    ply:SetNWInt("Gasmask", tonumber(Inv.Gasmask))
    ply:SetNWInt("Helmet", tonumber(Inv.Helmet))
    ply:SetNWInt("HelmetArmor", tonumber(Inv.HelmetArmor))
    ply:SetNWInt("NVGs", tonumber(Inv.NVGs))
    Inv.Inventory = string.Split(Inv.Inventory, ",")
    Inv.InventoryRounds = string.Split(Inv.InventoryRounds, ",")
    Inv.InventoryArmor = string.Split(Inv.InventoryArmor, ",")

    for k = 1, 20 do
        local slot = "Inventory" .. k
        ply:SetNWInt(slot, tonumber(Inv.Inventory[k]))
        ply:SetNWInt(slot .. "Rounds", tonumber(Inv.InventoryRounds[k]))
        ply:SetNWInt(slot .. "Armor", tonumber(Inv.InventoryArmor[k]))
    end
end)

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
        "UPDATE " .. tbName .. " SET Rucksack = " .. ent.MRPID ..
        " WHERE CharacterID = " .. ply:MRPCharacterID() .. ";"
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
        "UPDATE " .. tbName
        " SET Inventory = " .. SQLStr(Inventory) ..
        " WHERE CharacterID = " .. ply:MRPCharacterID())
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

hook.Add(
    "PlayerAmmoChanged",
    "InvAmmoUpdate",
    function(ply, ammoID, oldCount, newCount)
        local ammo = game.GetAmmoName(ammoID)

        if newCount < oldCount then
            local roundsToRemove = oldCount - newCount
            local startingIndex = 1
            RemoveAmmoFromBoxes(startingIndex, roundsToRemove, ammo, ply)
        end
    end
)

hook.Add("MRP::SaveProgress", "MRP::InvSave", function(ply, cid)
    for _, cat in pairs(MRP.WeaponCat) do
        if ply:MRPHas(cat) then
            local wep = ply:GetWeapon(ply:MRPEntityTable(cat).WeaponClass)
            sql.Query(
                "UPDATE " .. tbName
                " SET " .. cat .. "Rounds = " .. wep:Clip1() ..
                " WHERE CharacterID = " .. cid
            )
        end
    end

    local inventoryRounds = tostring(ply:GetNWInt("Inventory1Rounds"))

    for k = 2, 20 do
        local rounds = ply:GetNWInt("Inventory" .. k .. "Rounds")
        inventoryRounds = inventoryRounds .. "," .. rounds
    end

    local inventoryArmor = tostring(ply:GetNWInt("Inventory1Armor"))

    for k = 2, 20 do
        inventoryArmor = inventoryArmor .. "," .. ply:GetNWInt("Inventory" .. k .. "Armor")
    end

    local inventory = {}

    for k = 1, 20 do
        inventory[k] = ply:GetNWInt("Inventory" .. k)
    end

    inventory = table.concat(inventory, ",")
    sql.Query(
        "UPDATE " .. tbName
        " SET " ..
            "PrimaryWep = " .. ply:GetNWInt("PrimaryWep") .. "," ..
            "SecondaryWep = " .. ply:GetNWInt("SecondaryWep") .. "," ..
            "RocketLauncher = " .. ply:GetNWInt("RocketLauncher") .. "," ..
            "Vest = " .. ply:GetNWInt("Vest") .. "," ..
            "VestArmor = " .. ply:GetNWInt("VestArmor") .. "," ..
            "Rucksack = " .. ply:GetNWInt("Rucksack") .. "," ..
            "Radio = " .. ply:GetNWInt("Radio") .. "," ..
            "Gasmask = " .. ply:GetNWInt("Gasmask") .. "," ..
            "Helmet = " .. ply:GetNWInt("Helmet") .. "," ..
            "HelmetArmor  = " .. ply:GetNWInt("HelmetArmor") .. "," ..
            "NVGs = " .. ply:GetNWInt("NVGS") .. "," ..
            "Inventory = '" .. inventory .. "'," ..
            "InventoryRounds = '" .. inventoryRounds .. "'," ..
            "InventoryArmor = '" .. inventoryArmor .. "'" ..
        " WHERE CharacterID = " .. cid .. ";"
    )
end)

