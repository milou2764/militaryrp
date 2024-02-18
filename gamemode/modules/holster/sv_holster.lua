util.AddNetworkString("MRPSaveHolster")
util.AddNetworkString("MRPUpdateHolsters")
util.AddNetworkString("MRPRequestHolsters")

net.Receive("MRPSaveHolster", function(len,ply)
    if not ply:IsAdmin() then return end
    local wepClass = net.ReadString()
    local data = net.ReadTable()
    net.Start("MRPUpdateHolsters")
    net.WriteString(wepClass)
    net.WriteTable(data)
    net.Broadcast()
end)

hook.Add("PlayerSwitchWeapon", "MRPPlayerSwitchWeapon", function(ply, old, new)
    if not IsFirstTimePredicted() then return end
    net.Start("MRPRequestHolsters")
    net.WriteEntity(ply)
    net.WriteEntity(old)
    net.WriteEntity(new)
    net.Broadcast()
end)