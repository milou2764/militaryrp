net.Receive("PlayerMountGear", function()
    local MRPID = net.ReadUInt(7)
    local MRPEnt = MRP.getMRPEnt(MRPID)
    local target = net.ReadEntity()
    local userid
    if target.UserID then
        userid = target:UserID()
    else
        userid = target:EntIndex()
    end
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    MRP.mountedGear[userid][MRPEnt.MRPCategory] = MRPEnt:createCSModel(target)
end)
net.Receive("PlayerUnmountGear", function()
    local MRPID = net.ReadUInt(7)
    local MRPEnt = MRP.getMRPEnt(MRPID)
    local target = net.ReadEntity()
    MRPEnt:unmount(target)
end)

function MRP.loadPlayerGear(p)
    local getMRPID = p.getMRPID or p.GetNWInt
    local userid
    if p.UserID then
        userid = p:UserID()
    else
        userid = p
    end
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    for _, gear in pairs(MRP.mountedGear[userid]) do
        if gear.Remove then
            gear:Remove()
        end
    end
    if p:MRPHas("NVGs") then
        MRP.mountedGear[userid]["NVGs"] = MRP.getMRPEnt(getMRPID(p, "NVGs")):createCSModel(p)
    end
    if p:MRPHas("Helmet") then
        MRP.mountedGear[userid]["Helmet"] =
            MRP.getMRPEnt(getMRPID(p, "Helmet")):createCSModel(p)
    end
    if p:MRPHas("Gasmask") then
        MRP.mountedGear[userid]["Gasmask"] =
            MRP.getMRPEnt(getMRPID(p, "Gasmask")):createCSModel(p)
    end
    if p:MRPHas("Rucksack") then
        MRP.mountedGear[userid]["Rucksack"] =
            MRP.getMRPEnt(getMRPID(p, "Rucksack")):createCSModel(p)
    end
    if p:MRPHas("Vest") then
        MRP.mountedGear[userid]["Vest"] = MRP.getMRPEnt(getMRPID(p, "Vest")):createCSModel(p)
    end
end
------------------------------------------------------------------
-- This hook initializes all player's gear when the client join --
------------------------------------------------------------------
hook.Add("InitPostEntity", "InitPlayersGear", function()
    timer.Simple(10, function()
        for _, v in pairs(player.GetAll()) do
            MRP.loadPlayerGear(v)
        end
    end)
end)

-----------------------------------------------------------
-- This hook initializes any player's gear when he spawn --
-----------------------------------------------------------
hook.Add("MRPPlayerSpawn", "InitPlayerGear", function(p)
    MRP.loadPlayerGear(p)
end)
hook.Add("NotifyShouldTransmit", "MRPNotifyShouldTransmitGear", function(ent, shouldTransmit)
    if ent:IsPlayer() and ent.UserID and MRP.mountedGear[ent:UserID()] then
        for _, v in pairs(MRP.mountedGear[ent:UserID()]) do
            if IsValid(v) and shouldTransmit then
                v:SetNoDraw(false)
                v:SetParent(ent)
                v:AddEffects(EF_BONEMERGE)
                v:SetIK(false)
            elseif IsValid(v) then
                v:SetNoDraw(true)
            end
        end
    end
end)

local function unmountGear(userid)
    MRP.mountedGear = MRP.mountedGear or {}
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    for _, v in pairs(MRP.mountedGear[userid]) do
        if v.Remove then v:Remove() end
    end
end
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "RemovePlayerGear", function(data)
    print("Player disconnected")
    unmountGear(data.userid)
end)
