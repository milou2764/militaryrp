MRP.commands = {
    addspawn = function(ply, class, entClass, weapon)
        local map = game.GetMap()
        if not MRP.spawns then MRP.spawns = {} end
        if not MRP.spawns[map] then MRP.spawns[map] = {} end
        if not MRP.spawns[map][class] then MRP.spawns[map][class] = {} end
        table.insert(MRP.spawns[map][class], { pos = ply:GetPos(),
                                               ang = ply:GetAngles(),
                                               class = entClass, weapon = weapon })
        file.Write("mrp/spawns.txt", util.TableToJSON(MRP.spawns))
        ply:ChatPrint(class .. " spawn added")
    end,
    setspawn = function(ply, class, entClass, weapon)
        local map = game.GetMap()
        if not MRP.spawns then MRP.spawns = {} end
        if not MRP.spawns[map] then MRP.spawns[map] = {} end
        if not MRP.spawns[map][class] then MRP.spawns[map][class] = {} end
        MRP.spawns[map][class] = {
            [1] = { pos = ply:GetPos(),
                    ang = ply:GetAngles(),
                    class = entClass,
                    weapon = weapon }
        }
        file.Write("mrp/spawns.txt", util.TableToJSON(MRP.spawns))
        ply:ChatPrint(class .. " spawn set")
    end
}

concommand.Add("spawn", function( ply, _, args )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        local ent = ents.Create( args[1] )
        if IsValid(ent) then
            ent:Spawn()
            ent:SetPos(ply:GetEyeTraceNoCursor()["HitPos"])
        else
            ply:ChatPrint("The specified class does not exist")
        end
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("getposeye", function(ply)
    local pos = ply:GetEyeTrace().HitPos
    print("Vector(" .. tostring(pos.x) .. ", "
                    .. tostring(pos.y) .. ", "
                    .. tostring(pos.z) .. ")")
end)

concommand.Add("cleanup", function(ply)
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        game.CleanUpMap()
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("get_ent", function(ply)
    print( ply:GetEyeTrace().Entity )
end)

concommand.Add("removedecals", function(ply)
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        for _, ent in ipairs( ents.GetAll() ) do
            ent:RemoveAllDecals()
        end
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("removeragdolls", function( ply )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        for _, ent in ipairs( ents.GetAll() ) do
            if ent:IsRagdoll() then
                ent:Remove()
            end
        end
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("mrp", function(ply, _, args)
    if ply:IsAdmin() then
        MRP.commands[args[1]](ply, args[2], args[3], args[4])
    end
end)

concommand.Add("mrp addspawn rebels", function()
end)
concommand.Add("mrp addspawn spectators", function()
end)
concommand.Add("mrp addspawn army", function()
end)
concommand.Add("mrp addspawn npcs", function()
end)
