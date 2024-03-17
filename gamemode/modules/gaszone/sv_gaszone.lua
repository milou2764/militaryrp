gas_zones = {
    ["rp_cscdesert_v2-1"] = {
        [1] = { x1 = -12595, x2 = 12595, y1 = -14360, y2 = 14360, z1 = 60, z2 = 3125 }
    }
}

local gasTriggerDelay = 0
hook.Add("PlayerPostThink", "GasZoneTrigger", function(ply)
    if CurTime() > gasTriggerDelay then
        gasTriggerDelay = CurTime() + 2
        plyPos = ply:GetPos()
        map = game.GetMap()
        for k = 1, #gas_zones[map] do
            local x1 = gas_zones[map][k].x1
            local x2 = gas_zones[map][k].x2
            local y1 = gas_zones[map][k].y1
            local y2 = gas_zones[map][k].y2
            local z1 = gas_zones[map][k].z1
            local z2 = gas_zones[map][k].z2
            local betweenX = plyPos.x > x1 and plyPos.x < x2
            local betweenY = plyPos.y > y1 and plyPos.y < y2
            local betweenZ = plyPos.z > z1 and plyPos.z < z2
            if betweenX and betweenY and betweenZ then
                ply:TakeDamageInfo( MRP.GasDamage )
            end
        end
    end
end)
