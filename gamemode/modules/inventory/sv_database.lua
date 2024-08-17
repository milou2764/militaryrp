local tbName = MRP.TABLE_INV

local schema =
    "CREATE TABLE " .. SQLStr(tbName) .. "(" ..
    "CharacterID INTEGER PRIMARY KEY," ..
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
    "InventoryRounds VARCHAR(120) DEFAULT '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'," ..
    "InventoryArmor VARCHAR(120) DEFAULT '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'" ..
    ")"

MRP.UpdateTable(tbName, schema)

