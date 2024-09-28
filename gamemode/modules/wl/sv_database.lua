
local tbName = "mrp_regwl"
local defaultWL = {
    {1,0,0},
    {1},
}
local defaultWlStr = util.TableToJSON(defaultWL)

local schema =
    "CREATE TABLE " .. SQLStr(tbName) .. "(" ..
    "SteamID64 INTEGER PRIMARY KEY," ..
    "Whitelists TEXT DEFAULT " .. SQLStr(defaultWlStr) ..
    ")"

MRP.UpdateTable(tbName, schema)

local insertPlayer = function(ply)
    local ret =  sql.Query(
        "INSERT INTO " .. tbName ..
        "(SteamID64) VALUES (" .. SQLStr(ply:SteamID64()) ..")"
    )
    if ret==false then
        Log.e("WL", "error when inserting player")
        Log.e("WL", sql.LastError())
        return
    end
    return defaultWL
end

MRP.GetWL = function(ply)
    local sqlRet =  sql.Query(
        "SELECT Whitelists FROM " .. tbName ..
        " WHERE SteamID64=" .. SQLStr(ply:SteamID64())
    )
    if sqlRet == false then
        Log.e("WL", "error when selecting wl")
        Log.e("WL", sql.LastError())
        return
    elseif sqlRet == nil then
        Log.d("WL", "no data when selecting wl")
        return insertPlayer(ply)
    end
    PrintTable(sqlRet)
    print(sqlRet[1]["Whitelists"])
    local tblStr = sqlRet[1]["Whitelists"]
    local tbl = util.JSONToTable(tblStr)
    PrintTable(tbl)
    return tbl
end

MRP.UpdateWL = function(ply, wl)
    local wl = util.TableToJSON(wl)
    local ret = sql.Query(
        "UPDATE " .. tbName .. " SET Whitelists = " .. SQLStr(wl) ..
        " WHERE SteamID64 = " .. ply:SteamID64()
    )
    if ret==false then
        Log.e("WL", "error update table")
        Log.e("WL", sql.LastError())
        return false
    end
    return true
end
