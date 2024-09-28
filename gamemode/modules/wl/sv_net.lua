util.AddNetworkString("mrp_wl_update")
util.AddNetworkString("mrp_wl_sv_update")

MRP.SendWL = function(ply)
    local wl = MRP.GetWL(ply)
    net.Start("mrp_wl_update")
    net.WriteUInt(#wl,3)
    for _, fac in pairs(wl) do
        net.WriteUInt(#fac, 4)
        for _, v in pairs(fac) do
            net.WriteUInt(tonumber(v), 2)
        end
    end
    net.Send(ply)
end

hook.Add("PlayerSpawn", "MRP::wl::PlayerSpawn", MRP.SendWL)


