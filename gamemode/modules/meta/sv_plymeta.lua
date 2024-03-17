local plyMeta = FindMetaTable("Player")

function plyMeta:EquipHelmet(helmet)
    self:SetNWInt("HelmetArmor", helmet.armor)
    self:SetNWInt("Helmet", helmet.MRPID)
    helmet:Remove()
end

function plyMeta:ChangeHelmet(newHelmet)
    local oldHelmet = ents.Create(MRP.getMRPEnt(self:GetNWInt("Helmet")).className)
    oldHelmet.armor = self:GetNWInt("HelmetArmor")
    oldHelmet:Spawn()
    oldHelmet:SetPos( self:EyePos() - Vector(0, 0, 10) )

    self:EquipHelmet(newHelmet)
end

function plyMeta:EquipGasmask(gasmask)
    self:SetNWInt("Gasmask", gasmask.MRPID)
    local faction = self:MRPFaction()
    local model = self:MRPModel()
    local bodyGroup = gasmask.BodyGroup[faction][model][1]
    local bodyId = gasmask.BodyGroup[faction][model][2]
    self:SetBodygroup(bodyGroup, bodyId)
    sql.Query(
        "UPDATE mrp_characters " ..
        "SET Gasmask = " .. gasmask.MRPID .. " " ..
        "WHERE UID = " .. self:GetCharacterID()
    )
    MRP.SaveBodyGroupsData(self)
    gasmask:Remove()
end

function plyMeta:ChangeGasmask(newGasmask)
    local oldGasmask = ents.Create(MRP.getMRPEnt(self:MRPGasmask()).className)
    oldGasmask:Spawn()
    oldGasmask:SetPos( self:EyePos() - Vector(0, 0, 10) )

    self:EquipGasmask(newGasmask)
end

function plyMeta:EquipRucksack(rucksack)
    self:SetNWInt( "Rucksack", rucksack.MRPID )
    for k = rucksack.StartingIndex, rucksack.StartingIndex + rucksack.Capacity - 1 do
        self:SetNWInt("Inventory" .. k, rucksack["Slot" .. k])
        if MRP.getMRPEnt(rucksack["Slot" .. k]).ammoName then
            local ammo = rucksack["Slot" .. k .. "ammoCount"]
            local ammoType = MRP.getMRPEnt(rucksack["Slot" .. k]).ammoName
            self:GiveAmmo(ammo, ammoType)
            self:SetNWInt("Inventory" .. k .. "Ammo", ammo)
        end
    end
    rucksack:Remove()
end

function plyMeta:ChangeRucksack(newRucksack)
    local oldRucksack = ents.Create(MRP.getMRPEnt(self:GetNWInt("Rucksack")).ClassName)
    for k = oldRucksack.StartingIndex, oldRucksack.StartingIndex + oldRucksack.Capacity - 1 do
        oldRucksack["Slot" .. 20-k] = self:GetNWInt("Inventory" .. k)
        if MRP.getMRPEnt(self:GetNWInt("Inventory" .. (20-k))).ammoName then
            local ammo = self:GetNWInt("Inventory" .. (20-k) .. "Ammo")
            local ammoType = MRP.getMRPEnt(self:GetNWInt("Inventory" .. (20-k))).ammoName
            oldRucksack["Slot" .. (20-k) .. "ammoCount"] = ammo
            self:RemoveAmmo(ammo, ammoType)
        end
        self:SetNWInt("Inventory" .. (20-k), 1)
    end
    oldRucksack:Spawn()
    oldRucksack:SetPos(self:EyePos() - Vector(0, 0, 10))

    self:EquipRucksack(newRucksack)
end

function plyMeta:inventoryPickup(ent)
    for k = 1, 20 do
        if self:GetNWInt("Inventory" .. k) == 1 then
            self:SetNWInt( "Inventory" .. k, ent.MRPID )
            self:SetNWInt( "Inventory" .. k .. "Armor", ent.armor )
            ent:Remove()
            return
        end
    end
end

function plyMeta:pickupGear(gear)
    self:SetNWInt(gear.MRPCategory, gear.MRPID)
    net.Start("PlayerEquipGear")
    net.WriteUInt(gear.MRPID, 7)
    net.WriteEntity(self)
    net.Broadcast()
    gear:Remove()
end
