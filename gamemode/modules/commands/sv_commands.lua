MRP.Commands.players = {
    addspawn = function(ply, class, entClass, weapon)
        local map = game.GetMap()
        if not MRP.Spawns then MRP.Spawns = {} end
        if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
        if not MRP.Spawns[map][class] then MRP.Spawns[map][class] = {} end
        table.insert(MRP.Spawns[map][class], { pos = ply:GetPos(),
                                               ang = ply:GetAngles(),
                                               class = entClass, weapon = weapon })
        file.Write("mrp/spawns.txt", util.TableToJSON(MRP.Spawns, true))
        ply:ChatPrint(class .. " spawn added")
    end,
    setspawn = function(ply, class, entClass, weapon)
        local map = game.GetMap()
        if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
        if not MRP.Spawns[map][class] then MRP.Spawns[map][class] = {} end
        MRP.Spawns[map][class] = {
            [1] = {
                pos = ply:GetPos(),
                ang = ply:GetAngles(),
                class = entClass,
                weapon = weapon,
            }
        }
        file.Write("mrp/spawns.txt", util.TableToJSON(MRP.Spawns, true))
        ply:ChatPrint(class .. " spawn set")
    end
}
MRP.Commands.reload_modules = MRP.ReloadModules

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
    Log.d("getposeye", "Vector(" .. tostring(pos.x) .. ", "
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
    Log.d("get_ent", tostring(ply:GetEyeTrace().Entity))
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

concommand.Add("mrp_admin", function(ply, _, args)
    if ply:IsAdmin() then
        MRP.Commands[args[1]][args[2]](ply, args[3], args[4], args[5])
    end
end)

concommand.Add("mrp players addspawn rebels", function() end)
concommand.Add("mrp players setspawn rebels", function() end)

concommand.Add("mrp players addspawn spectators", function() end)
concommand.Add("mrp players setspawn spectators", function() end)

concommand.Add("mrp players addspawn army", function() end)
concommand.Add("mrp players setspawn army", function() end)

concommand.Add("mrp players addspawn npcs", function() end)
