local spawnData = file.Read("mrp/spawns.txt", "DATA")
MRP.SpawnEnts = MRP.SpawnEnts or {}
MRP.Spawns = {}
if spawnData then
    MRP.Spawns = util.JSONToTable(spawnData) or {}
end
