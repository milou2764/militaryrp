local npcspawn = {}
npcspawn.SpawnDelay = 0
npcspawn.MinSpawnDistance = 3000
npcspawn.MaxSpawnDistance = 20000
npcspawn.NPCCount = 0
npcspawn.NPCLimit = 20

local npcWep =
    {
        "weapon_vj_sentercarbine",
        "weapon_vj_sentercarbine",
        "weapon_vj_senterrifle",
        "weapon_vj_senterassault"
    }

local function NPCSpawnSystem()
    if npcspawn.SpawnDelay < CurTime() then
        npcspawn.SpawnDelay = CurTime() + 20
        for _, platform in pairs( MRP.Spawns[game.GetMap()].npcs ) do
            if not platform.npc or not IsValid(platform.npc) then
                local canSpawn = true
                for _, p in pairs( player.GetAll() ) do
                    local distance = p:GetPos():Distance( platform.pos )
                    local tooClose = distance < npcspawn.MinSpawnDistance
                    local tooFar = distance > npcspawn.MaxSpawnDistance
                    local limitReached = npcspawn.NPCCount >= npcspawn.NPCLimit
                    if tooClose or tooFar or limitReached then
                        canSpawn = false
                        break
                    end
                end
                if canSpawn then
                    platform.npc = ents.Create( platform.class or table.Random(MRP.npcs) )
                    platform.npc:SetPos(platform.pos)
                    platform.npc:SetAngles(platform.ang)
                    local equipment = platform.weapon or table.Random(npcWep)
                    platform.npc:SetKeyValue( "additionalequipment", equipment )
                    platform.npc.Equipment = equipment
                    platform.npc:Spawn()
                    platform.npc:Activate()
                    npcspawn.NPCCount = npcspawn.NPCCount + 1
                end
            end
        end
    end
end

hook.Add("Initialize", "InitNPCSpawn", function()
    local map = game.GetMap()
    if MRP.Spawns and MRP.Spawns[map].npcs and #MRP.Spawns[map].npcs > 0 then
        hook.Add("Think", "NPCSpawn", NPCSpawnSystem)
    end
end)

concommand.Add("mrp_activatenpcspawn", function(ply)
    if ply:IsAdmin() then
        if hook.GetTable().Think.NPCSpawn then
            hook.Remove("Think", "NPCSpawn")
            ply:ChatPrint("NPC Spawn System Disabled")
        else
            local map = game.GetMap()
            if MRP.Spawns[map].npcs and #MRP.Spawns[map].npcs > 0 then
                hook.Add("Think", "NPCSpawn", NPCSpawnSystem)
                ply:ChatPrint("NPC Spawn System Enabled")
                return
            end
            ply:ChatPrint("No NPC Spawns Found")
        end
    end
end)

hook.Add("OnNPCKilled", "UpdateNPCCount", function()
    npcspawn.NPCCount = npcspawn.NPCCount - 1
end)

hook.Add("PostCleanupMap", "ResetNPCCount", function()
    npcspawn.NPCCount = 0
end)
