local vehiclespawn = {}
vehiclespawn.SpawnDelay = 0
vehiclespawn.MinSpawnDistance = 300
vehiclespawn.vehicleCount = 0
vehiclespawn.vehicleLimit = 20

local spawnFuncs = {
	simfphys = function(platform)
        local vname = platform.class
        local vehicle = list.Get( "simfphys_vehicles" )[vname]
        platform.vehicle =
            simfphys.SpawnVehicle(
                nil,
                platform.pos,
                platform.ang,
                vehicle.Model,
                vehicle.Class,
                vname,
                vehicle
            )
        platform.vehicle:SetSkin(0)
        platform.vehicle.isMRPVehicle = true
        vehiclespawn.vehicleCount = vehiclespawn.vehicleCount + 1
    end,
	wac = function(platform)
        local className = platform.class
        local vehicle = ents.Create(className)
        if IsValid(vehicle) then
            vehicle:SetPos(platform.pos+Vector(0,0,100))
            vehicle:SetAngles(platform.ang)
            vehicle:Spawn()
            vehicle:Activate()
            platform.vehicle = vehicle
            platform.vehicle.isMRPVehicle = true
            vehiclespawn.vehicleCount = vehiclespawn.vehicleCount + 1
        end
	end
}


local function vehicleSpawnSystem()
    if vehiclespawn.SpawnDelay < CurTime() then
        vehiclespawn.SpawnDelay = CurTime() + 20
        for _, platform in pairs( MRP.Spawns[game.GetMap()].vehicles ) do
            if not platform.vehicle or not platform.vehicle:IsValid() then
                local canSpawn = true
                for _, p in pairs( player.GetAll() ) do
                    local distance = p:GetPos():Distance( platform.pos )
                    local incorrectDistance = distance < vehiclespawn.MinSpawnDistance
                    local limitReached = vehiclespawn.vehicleCount >= vehiclespawn.vehicleLimit
                    if incorrectDistance or limitReached then
                        canSpawn = false
                        break
                    end
                end
                if canSpawn then
                    spawnFuncs[platform.cat](platform)
                end
            end
        end
    end
end

hook.Add("Initialize", "InitvehicleSpawn", function()
    local map = game.GetMap()
    if not MRP.Spawns[map] then return end
    if MRP.Spawns[map].vehicles and #MRP.Spawns[map].vehicles > 0 then
        hook.Add("Think", "vehicleSpawn", vehicleSpawnSystem)
    end
end)

concommand.Add("mrp_activatevehiclespawn", function(ply)
    if ply:IsAdmin() then
        if hook.GetTable().Think.vehicleSpawn then
            hook.Remove("Think", "vehicleSpawn")
            ply:ChatPrint("vehicle Spawn System Disabled")
        else
            local map = game.GetMap()
            if MRP.Spawns[map].vehicles and #MRP.Spawns[map].vehicles > 0 then

                for _, platform in pairs( MRP.Spawns[game.GetMap()].vehicles ) do
                    if platform.vehicle and platform.vehicle:IsValid() then
                        platform.vehicle:Remove()
                    end
                    platform.vehicle = nil
                end
                vehiclespawn.vehicleCount = 0
                hook.Add("Think", "vehicleSpawn", vehicleSpawnSystem)
                ply:ChatPrint("vehicle Spawn System Enabled")
                return
            end
            ply:ChatPrint("No vehicle Spawns Found")
        end
    end
end)

hook.Add("EntityRemoved", "UpdatevehicleCount", function(ent)
    if not ent.isMRPVehicle then return end
    vehiclespawn.vehicleCount = vehiclespawn.vehicleCount - 1
end)

hook.Add("PostCleanupMap", "ResetvehicleCount", function()
    vehiclespawn.vehicleCount = 0
end)
