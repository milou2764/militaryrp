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
    oldHelmet:SetPos( self:EyePos() - Vector(0,0,10) )

    self:EquipHelmet(newHelmet)
end

function plyMeta:EquipGasmask(gasmask)
    self:SetNWInt("Gasmask", gasmask.MRPID)
    self:SetBodygroup(gasmask.BodyGroup[self:GetNWInt("Faction")][self:GetNWInt("ModelIndex")][1], gasmask.BodyGroup[self:GetNWInt("Faction")][self:GetNWInt("ModelIndex")][2])
    sql.Query("UPDATE mrp_characters SET Gasmask = " .. gasmask.MRPID .. " WHERE UID = " .. tostring(self:GetCharacterID()))
    MRP.SaveBodyGroupsData(self)
    gasmask:Remove()
end

function plyMeta:ChangeGasmask(newGasmask)
    local oldGasmask = ents.Create(MRP.getMRPEnt(self:GetNWInt("Gasmask")).className)
    oldGasmask:Spawn()
    oldGasmask:SetPos( self:EyePos() - Vector(0,0,10) )

    self:EquipGasmask(newGasmask)
end

function plyMeta:EquipRucksack(rucksack)
    self:SetNWInt( "Rucksack", rucksack.MRPID )
    for k = rucksack.StartingIndex ,rucksack.StartingIndex + rucksack.Capacity - 1 do
        self:SetNWInt("Inventory" .. tostring(k), rucksack["Slot" .. tostring(k)])
        if MRP.getMRPEnt(rucksack["Slot" .. tostring(k)]).ammoName then
            self:GiveAmmo( rucksack["Slot" .. tostring(k) .. "ammoCount"], MRP.getMRPEnt(rucksack["Slot" .. tostring(k)]).ammoName )
            self:SetNWInt("AmmoBox" .. tostring(k), rucksack["Slot" .. tostring(k) .. "ammoCount"])
        end
    end
    rucksack:Remove()
end

function plyMeta:ChangeRucksack(newRucksack)
    local oldRucksack = ents.Create(MRP.getMRPEnt(self:GetNWInt("Rucksack")).ClassName)
    for k = oldRucksack.StartingIndex,oldRucksack.StartingIndex + oldRucksack.Capacity - 1 do
        oldRucksack["Slot" .. tostring(20-k)] = self:GetNWInt("Inventory" .. tostring(k))
        if MRP.getMRPEnt(self:GetNWInt("Inventory" .. tostring(20-k))).ammoName then
            oldRucksack["Slot" .. tostring(20-k) .. "ammoCount"] = self:GetNWInt("AmmoBox" .. tostring(20-k))
            self:RemoveAmmo( self:GetNWInt("AmmoBox" .. tostring(20-k)), MRP.getMRPEnt(self:GetNWInt("Inventory" .. tostring(20-k))).ammoName )
        end
        self:SetNWInt("Inventory" .. tostring(20-k), 1)
    end
    oldRucksack:Spawn()
    oldRucksack:SetPos(self:EyePos() - Vector(0,0,10))

    self:EquipRucksack(newRucksack)
end

function plyMeta:inventoryPickup(ent)
    for k = 1,20 do
        if self:GetNWInt("Inventory" .. tostring(k)) == 1 then
            self:SetNWInt( "Inventory" .. tostring(k), ent.MRPID )
            self:SetNWInt( "Inventory" .. tostring(k) .. "Armor", ent.armor )
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