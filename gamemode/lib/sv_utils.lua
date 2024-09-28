local TAG = "Utils"

function MRP.FindPlayer(info)
    Log.d("findPlayer", "triggered")
    if not info or info == "" then
        Log.d("findPlayer", "no id provided")
        return nil
    end
    for _, p in ipairs( player.GetAll() ) do
        if p:SteamID() == info then
            return p
        end
        local rpname = string.lower(p:RPName())
        Log.d("findPlayer", rpname)
        if string.find(rpname, string.lower(tostring(info)), 1, true) ~= nil then
            return p
        end
    end
end

MRP.CreateTable = function(schema)
    local TAG = "TableCreation"
    Log.d(TAG, schema)
    local ret = sql.Query(schema)
    if ret == false then
        Log.d(TAG, "error")
        Log.d(TAG, sql.LastError())
    end
end

MRP.UpdateTable = function(name, schema)
    local existingTable =
        sql.QueryValue(
            "SELECT sql FROM sqlite_master " ..
            "WHERE name = " .. SQLStr(name)
        )
    if existingTable == nil then
        Log.d(TAG, "creating " .. name)
        MRP.CreateTable(schema)
    elseif existingTable ~= schema then
        Log.d(TAG, name .. " TABLE CHANGED SINCE LAST TIME")
        print(existingTable)
        Log.d(TAG, "DELETING ...")
        sql.Query("DROP TABLE " .. SQLStr(name))
        sql.Query(schema)
    else
        Log.d(TAG, "TABLE " .. name .. " DID NOT CHANGED")
    end
end
