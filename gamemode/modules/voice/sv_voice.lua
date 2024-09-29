local entMeta = FindMetaTable("Entity")

-- Maintains entities that are to be removed after disconnect
local queuedForRemoval = {}

--[[---------------------------------------------------------
 Gamemode functions
 ---------------------------------------------------------]]

-- IsInRoom function to see if the player is in the same room.
local roomTrResult = {}
local roomTr = {output = roomTrResult}
local function IsInRoom(listenerShootPos, talkerShootPos, talker)
    roomTr.start = talkerShootPos
    roomTr.endpos = listenerShootPos
    -- Listener needs not be ignored as that's the end of the trace
    roomTr.filter = talker
    roomTr.collisiongroup = COLLISION_GROUP_WORLD
    roomTr.mask = MASK_SOLID_BRUSHONLY
    util.TraceLine(roomTr)

    return not roomTrResult.HitWorld
end

local threed = GM.Config.voice3D
local vrad = GM.Config.voiceradius
local dynv = GM.Config.dynamicvoice
local deadv = GM.Config.deadvoice
local voiceDistance = GM.Config.voiceDistance * GM.Config.voiceDistance
local DrpCanHear = {}

-- Recreate DrpCanHear after Lua Refresh
-- This prevents an indexing nil error in PlayerCanHearPlayersVoice
for _, ply in ipairs(player.GetAll()) do
    DrpCanHear[ply] = {}
end

local gridSize = GM.Config.voiceDistance -- Grid cell size is equal to the size of the radius of player talking
local floor = math.floor -- Caching floor as we will need to use it a lot

-- Grid based position check
local grid
-- Translate player to grid coordinates. The first table maps players to x
-- coordinates, the second table maps players to y coordinates.
local plyToGrid = {
    {},
    {}
}

-- Set DarkRP.voiceCheckTimeDelay before DarkRP is loaded to set the time
-- between player voice radius checks.
DarkRP.voiceCheckTimeDelay = DarkRP.voiceCheckTimeDelay or 0.3
timer.Create("DarkRPCanHearPlayersVoice", DarkRP.voiceCheckTimeDelay, 0, function()
    -- Voiceradius is off, everyone can hear everyone
    if not vrad then
        return
    end

    local players = player.GetHumans()

    -- Clear old values
    plyToGrid[1] = {}
    plyToGrid[2] = {}
    grid = {}

    local plyPos = {}
    local eyePos = {}

    -- Get the grid position of every player O(N)
    for _, ply in ipairs(players) do
        local pos = ply:GetPos()
        plyPos[ply] = pos
        eyePos[ply] = ply:EyePos()
        local x = floor(pos.x / gridSize)
        local y = floor(pos.y / gridSize)

        local row = grid[x] or {}
        local cell = row[y] or {}

        table.insert(cell, ply)
        row[y] = cell
        grid[x] = row

        plyToGrid[1][ply] = x
        plyToGrid[2][ply] = y

        DrpCanHear[ply] = {} -- Initialize output variable
    end

    -- Check all neighbouring cells for every player.
    -- We are only checking in 1 direction to avoid duplicate check of cells
    for _, ply1 in ipairs(players) do
        local gridX = plyToGrid[1][ply1]
        local gridY = plyToGrid[2][ply1]
        local ply1Pos = plyPos[ply1]
        local ply1EyePos = eyePos[ply1]

        for i = 0, 3 do
            local vOffset = 1 - ((i >= 3) and 1 or 0)
            local hOffset = -(i % 3-1)
            local x = gridX + hOffset
            local y = gridY + vOffset

            local row = grid[x]
            if row then
                local cell = row[y]
                if cell then
                    for _, ply2 in ipairs(cell) do
                        local canTalk =
                            ply1Pos:DistToSqr(plyPos[ply2]) < voiceDistance and -- voiceradius is on and the two are within hearing distance
                                (not dynv or IsInRoom(ply1EyePos, eyePos[ply2], ply2)) -- Dynamic voice is on and players are in the same room

                        DrpCanHear[ply1][ply2] = canTalk and (deadv or ply2:Alive())
                        DrpCanHear[ply2][ply1] = canTalk and (deadv or ply1:Alive()) -- Take advantage of the symmetry
                    end
                end
            end
        end
    end

    -- Doing a pass-through inside every cell to compute the interactions inside of the cells.
    -- Each grid check is O(N(N+1)/2) where N is the number of players inside the cell.
    for _, row in pairs(grid) do
        for _, cell in pairs(row) do
            local count = #cell
            for i = 1, count do
                local ply1 = cell[i]
                for j = i + 1, count do
                    local ply2 = cell[j]
                    local canTalk =
                        plyPos[ply1]:DistToSqr(plyPos[ply2]) < voiceDistance and -- voiceradius is on and the two are within hearing distance
                            (not dynv or IsInRoom(eyePos[ply1], eyePos[ply2], ply2)) -- Dynamic voice is on and players are in the same room

                    DrpCanHear[ply1][ply2] = canTalk and (deadv or ply2:Alive())
                    DrpCanHear[ply2][ply1] = canTalk and (deadv or ply1:Alive()) -- Take advantage of the symmetry
                end
            end
        end
    end
end)

hook.Add("PlayerDisconnect", "DarkRPCanHear", function(ply)
    DrpCanHear[ply] = nil -- Clear to avoid memory leaks
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if not deadv and not talker:Alive() then return false end

    return not vrad or DrpCanHear[listener][talker] == true, threed
end

hook.Add("PlayerInitialSpawn", "MRP::InitialSpawn::Voice", function(ply)
    self.Sandbox.PlayerInitialSpawn(self, ply)
    -- Initialize DrpCanHear for player (used for voice radius check)
    DrpCanHear[ply] = {}

    local sid = ply:SteamID()
    DarkRP.log(ply:Nick() .. " (" .. sid .. ") has joined the game", Color(0, 130, 255))
    ply:setDarkRPVarsAttribute()
    ply:restorePlayerData()
    initPlayer(ply)
    ply.SID = ply:UserID()

    timer.Simple(1, function()
        if not IsValid(ply) then return end
        local group = GAMEMODE.Config.DefaultPlayerGroups[sid]
        if group then
            ply:SetUserGroup(group)
        end
    end)

    restoreReconnectedEnts(ply)
end)

-- Collect entities that are to be removed
local function collectRemoveEntities(ply)
    if not GAMEMODE.Config.removeondisconnect then return {} end

    local collect = {}
    -- Get the classes of entities to remove
    local remClasses = {}
    for _, customEnt in pairs(DarkRPEntities) do
        remClasses[string.lower(customEnt.ent)] = true
    end

    local sid = ply.SID
    for _, v in ipairs(ents.GetAll()) do
        if v.SID ~= sid or not v:IsVehicle() and not remClasses[string.lower(v:GetClass() or "")] then continue end

        table.insert(collect, v)
    end

    if not ply:isMayor() then return collect end

    for _, ent in pairs(ply.lawboards or {}) do
        if not IsValid(ent) then continue end
        table.insert(collect, ent)
    end

    return collect
end

function GM:PlayerDisconnected(ply)
    self.Sandbox.PlayerDisconnected(self, ply)
    timer.Remove(ply:SteamID64() .. "jobtimer")
    timer.Remove(ply:SteamID64() .. "propertytax")

    local isMayor = ply:isMayor()

    local remList = collectRemoveEntities(ply)
    removeDelayed(remList, ply)

    DarkRP.destroyQuestionsWithEnt(ply)
    DarkRP.destroyVotesWithEnt(ply)

    if isMayor and GetGlobalBool("DarkRP_LockDown") then -- Stop the lockdown
        DarkRP.unLockdown(ply)
    end

    if isMayor and GAMEMODE.Config.shouldResetLaws then
        DarkRP.resetLaws()
    end

    if IsValid(ply.SleepRagdoll) then
        ply.SleepRagdoll:Remove()
    end

    ply:keysUnOwnAll()
    DarkRP.log(ply:Nick() .. " (" .. ply:SteamID() .. ") disconnected", Color(0, 130, 255))

    local agenda = ply:getAgendaTable()

    -- Clear agenda
    if agenda and ply:Team() == agenda.Manager and team.NumPlayers(ply:Team()) <= 1 then
        agenda.text = nil
        for _, v in ipairs(player.GetAll()) do
            if v:getAgendaTable() ~= agenda then continue end
            v:setSelfDarkRPVar("agenda", agenda.text)
        end
    end

    local jobTable = ply:getJobTable()
    if jobTable.PlayerDisconnected then
        jobTable.PlayerDisconnected(ply)
    end
end

function GM:GetFallDamage(ply, flFallSpeed)
    if GetConVar("mp_falldamage"):GetBool() or GAMEMODE.Config.realisticfalldamage then
        if GAMEMODE.Config.falldamagedamper then return flFallSpeed / GAMEMODE.Config.falldamagedamper else return flFallSpeed / 15 end
    else
        if GAMEMODE.Config.falldamageamount then return GAMEMODE.Config.falldamageamount else return 10 end
    end
end

local function fuckQAC()
    local netRecs = {"Debug1", "Debug2", "checksaum", "gcontrol_vars", "control_vars", "QUACK_QUACK_MOTHER_FUCKER"}
    for _, v in pairs(netRecs) do
        net.Receivers[v] = fn.Id
    end
end

function GM:InitPostEntity()
    self.InitPostEntityCalled = true

    local physData = physenv.GetPerformanceSettings()
    physData.MaxVelocity = 2000
    physData.MaxAngularVelocity = 3636

    physenv.SetPerformanceSettings(physData)

    -- Scriptenforcer enabled by default? Fuck you, not gonna happen.
    if not GAMEMODE.Config.disallowClientsideScripts then
        game.ConsoleCommand("sv_allowcslua 1\n")
        timer.Simple(1, fuckQAC) -- Also, fuck QAC which bans innocent people when allowcslua = 1
    end
    game.ConsoleCommand("physgun_DampingFactor 0.9\n")
    game.ConsoleCommand("sv_sticktoground 0\n")
    game.ConsoleCommand("sv_airaccelerate 1000\n")
    -- sv_alltalk must be 0
    -- Note, everyone will STILL hear everyone UNLESS GM.Config.voiceradius is set to true
    -- This will fix the GM.Config.voiceradius not working
    game.ConsoleCommand("sv_alltalk 0\n")

    if GAMEMODE.Config.unlockdoorsonstart then
        for _, v in ipairs(ents.GetAll()) do
            if not v:isDoor() then continue end
            v:Fire("unlock", "", 0)
        end
    end
end
timer.Simple(0.1, function()
    if not GAMEMODE.InitPostEntityCalled then
        GAMEMODE:InitPostEntity()
    end
end)

function GM:loadCustomDarkRPItems()
    -- Error when the default team isn't set
    if not GAMEMODE.DefaultTeam or not RPExtraTeams[GAMEMODE.DefaultTeam] then
        -- Re-set to first available team to hopefully prevent further errors.
        -- Because this error is more important than any that follow because of it.
        GAMEMODE.DefaultTeam = next(RPExtraTeams)

        local hints = {
            "This may happen when you disable the default citizen job. Make sure you update GAMEMODE.DefaultTeam to the new default team.",
            "GAMEMODE.DefaultTeam may be set to a job that does not exist anymore. Did you remove the job you had set to default?",
            "The error being in jobs.lua is a guess. This is usually right, but the problem might lie somewhere else."
        }

        -- Gotta be totally clear here
        local stack = "\tjobs.lua, settings.lua, disabled_defaults.lua or any of your other custom files."
        DarkRP.error("GAMEMODE.DefaultTeam is not set to an existing job.", 1, hints, "lua/darkrp_customthings/jobs.lua", -1, stack)
    end
end

function GM:PlayerLeaveVehicle(ply, vehicle)
    if GAMEMODE.Config.autovehiclelock and vehicle:isKeysOwnedBy(ply) then
        vehicle:keysLock()
    end
    self.Sandbox.PlayerLeaveVehicle(self, ply, vehicle)
end

local function ClearDecals()
    if GAMEMODE.Config.decalcleaner then
        for _, p in ipairs(player.GetAll()) do
            p:ConCommand("r_cleardecals")
        end
    end
end
timer.Create("RP_DecalCleaner", GM.Config.decaltimer, 0, ClearDecals)

function GM:PlayerSpray()
    return not GAMEMODE.Config.allowsprays
end

function GM:GravGunOnPickedUp(ply, ent, ...)
    self.Sandbox.GravGunOnPickedUp(self, ply, ent, ...)
    -- Keeping track of who is holding an entity is done to make sure the entity
    -- cannot be pocketed. This is because holding an entity with the gravgun
    -- changes some properties. One such property is setting the mass to 1,
    -- causing the mass check of the pocket to always succeed.
    ent.DarkRPBeingGravGunHeldBy = ply
end

function GM:GravGunOnDropped(ply, ent, ...)
    self.Sandbox.GravGunOnDropped(self, ply, ent, ...)
    -- See comment at GravGunOnPickedUp
    ent.DarkRPBeingGravGunHeldBy = nil
end
