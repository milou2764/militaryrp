util.AddNetworkString("mrp_save_holsters")
util.AddNetworkString("mrp_update_holsters")
util.AddNetworkString("mrp_request_holsters")

net.Receive("mrp_save_holsters", function(_, ply)
    if not ply:IsAdmin() then return end
    local wepClass = net.ReadString()
    local data = net.ReadTable()
    net.Start("mrp_update_holsters")
    net.WriteString(wepClass)
    net.WriteTable(data)
    net.Broadcast()
end)

hook.Add("PlayerSwitchWeapon", "MRPPlayerSwitchWeapon", function(ply, old, new)
    if not IsFirstTimePredicted() then return end
    net.Start("mrp_request_holsters")
    net.WriteEntity(ply)
    net.WriteEntity(old)
    net.WriteEntity(new)
    net.Broadcast()
end)
