net.Receive("MRPClientNVGsToggle", function(_, ply)
    ply:SetNWBool("NVGsOn", not ply:GetNWBool("NVGsOn"))
    net.Start("MRPPlayerNVGsToggle")
    net.WriteUInt(ply:UserID(), 16)
    net.Broadcast()
end)
