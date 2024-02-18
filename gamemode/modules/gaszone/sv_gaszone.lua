gas_zones = {
    ["rp_cscdesert_v2-1"] = {
        [1] = {x1 = -12595,x2 = 12595,y1 = -14360,y2 = 14360,z1 = 60,z2 = 3125}
    }
}

local gasTriggerDelay = 0
hook.Add("PlayerPostThink", "GasZoneTrigger", function(ply)
    if CurTime() > gasTriggerDelay then
        gasTriggerDelay = CurTime() + 2
        plyPos = ply:GetPos()
        map = game.GetMap()
        for k = 1,#gas_zones[map] do
            if plyPos.x > gas_zones[map][k].x1 and plyPos.x < gas_zones[map][k].x2 and plyPos.y > gas_zones[map][k].y1 and plyPos.y < gas_zones[map][k].y2 and plyPos.z > gas_zones[map][k].z1 and plyPos.z < gas_zones[map][k].z2 then
                ply:TakeDamageInfo( MRP.GasDamage )
            end
        end
    end
end)