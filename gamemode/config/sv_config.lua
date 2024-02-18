local spawnData = file.Read("mrp/spawns.txt", "DATA")
if spawnData then
    MRP.spawns = util.JSONToTable(spawnData)
end