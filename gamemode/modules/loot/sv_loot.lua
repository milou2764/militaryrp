local SpawnDelay = 0
local MinSpawnDistance = 3000
local MaxSpawnDistance = 20000
local LootCount = 0
local LootLimit = 30

local loot = {
    ["rp_cscdesert_v2-1"] = {
        [1] = { pos = Vector(-1187.29, 6872.5, 25) },
        [2] = { pos = Vector(-1216, 6836, 73.1166) },
        [3] = { pos = Vector(-1232, 6880, 76) },
        [4] = { pos = Vector(-978.503, 7296.3, 65) },
        [5] = { pos = Vector(-1004.87, 7363.91, 25) },
        [6] = { pos = Vector(3925.28, 4357.26, 17) },
        [7] = { pos = Vector(2626.99, -8585.93, 57) },
        [8] = { pos = Vector(2591.81, -8675.71, 17) },
        [9] = { pos = Vector(2100.1, -7881.49, 17) },
        [10] = { pos = Vector(2066, -7956, 59) },
        [11] = { pos = Vector(2729.94, -7884.01, 53.028) },
        [12] = { pos = Vector(2477.3, -7993.21, 60.134) },
        [13] = { pos = Vector(2519.9, -8124.84, 38.948) },
        [14] = { pos = Vector(2828.14, -8168.94, 52.876) },
        [15] = { pos = Vector(2705.39, -7887.14, 53.028) },
        [16] = { pos = Vector(4186.49, -9617.55, 52.876) },
        [17] = { pos = Vector(4223.65, -9574.92, 58.7535) },
        [18] = { pos = Vector(4461.09, -9510.63, 53.028) },
        [19] = { pos = Vector(4431.85, -9555.43, 36.2458) },
        [20] = { pos = Vector(4478.45, -9299.73, 38.948) },
        [21] = { pos = Vector(4229.83, -9303.72, 38.948) },
        [22] = { pos = Vector(3436.87, -9656.13, 8) },
        [23] = { pos = Vector(3252.15, -9675.31, 8) },
        [24] = { pos = Vector(3335.33, -9608.73, 46.9262) },
        [25] = { pos = Vector(1652.32, -9420.02, 53.028) },
        [26] = { pos = Vector(1604.2, -9280.2, 53.028) },
        [27] = { pos = Vector(1973.84, -9495.26, 54.9262) },
        [28] = { pos = Vector(1963.81, -9522.33, 54.9262) },
        [29] = { pos = Vector(1937.05, -9517.97, 16) },
        [30] = { pos = Vector(1776.19, -9456.13, 56) },
        [31] = { pos = Vector(1621.21, -9407.96, -91.008) },
        [32] = { pos = Vector(1638, -9311.36, -136) },
        [33] = { pos = Vector(1665.52, -9162.54, -136) },
        [34] = { pos = Vector(1832.58, -9305.59, -136) },
        [35] = { pos = Vector(1787.48, -9291.78, -136) },
        [36] = { pos = Vector(1854.72, -9371.3, -136) },
        [37] = { pos = Vector(1801.94, -9504.73, -136) },
        [38] = { pos = Vector(1967.68, -9266.76, -232.493) },
        [39] = { pos = Vector(2017.19, -9264.25, -232.493) },
        [40] = { pos = Vector(2577.21, -9624.14, 58.7535) },
        [41] = { pos = Vector(2515.29, -9680.84, 52.876) },
        [42] = { pos = Vector(2803.19, -9573.49, 53.028) },
        [43] = { pos = Vector(2786.75, -9529.46, 16) },
        [44] = { pos = Vector(2816.44, -9362.02, 38.948) },
        [45] = { pos = Vector(2555.27, -9353.56, 38.948) },
        [46] = { pos = Vector(4673.48, -9081.65, 8) },
        [47] = { pos = Vector(2785.34, -8120.95, 56.064) },
        [48] = { pos = Vector(2513.53, -7869.12, 38.948) },
        [49] = { pos = Vector(2488.94, -8121.24, 38.948) },
        [50] = { pos = Vector(2322.84, 2965.81, -344) },
        [51] = { pos = Vector(2133.37, 2162.23, -349.046) },
        [52] = { pos = Vector(1965.96, 2146.66, -349.835) },
        [53] = { pos = Vector(2051.85, 2141.58, -376) },
        [54] = { pos = Vector(2218.78, 2124.54, -376) },
        [55] = { pos = Vector(1717.52, 2602.28, -331.879) },
        [56] = { pos = Vector(2194.77, 2680.91, -328.719) },
        [57] = { pos = Vector(1922.41, 2699.93, -328.719) },
        [58] = { pos = Vector(2380.01, 2447.77, -331.504) },
        [59] = { pos = Vector(2949.77, 2530.7, -376) },
        [60] = { pos = Vector(2961.51, 2588.08, -376) },
        [61] = { pos = Vector(2913.45, 2556.79, -376) },
        [62] = { pos = Vector(2513.59, 2957.11, -670.579) },
        [63] = { pos = Vector(2244.63, 3010.93, -696) },
        [64] = { pos = Vector(3018.96, 2789.48, -648.719) },
        [65] = { pos = Vector(3024.8, 2744.22, -648.719) },
        [66] = { pos = Vector(2951.11, 2966.55, -668.788) },
        [67] = { pos = Vector(3242.83, 2690.86, -652.215) },
        [68] = { pos = Vector(3148.41, 2684.88, -696) },
        [69] = { pos = Vector(3144.23, 2734.85, -696) },
        [70] = { pos = Vector(3605.56, 2803.04, -696) },
        [71] = { pos = Vector(3670.66, 2320.18, -696) },
        [72] = { pos = Vector(2432.09, 2438.47, -984.433) },
        [73] = { pos = Vector(2391.24, 2433.12, -984.433) },
        [74] = { pos = Vector(2469.53, 2442.08, -984.433) },
        [75] = { pos = Vector(2474.66, 2302.83, -984.433) },
        [76] = { pos = Vector(2420.74, 2292.68, -984.433) },
        [77] = { pos = Vector(2119.02, 2288.76, -984.433) },
        [78] = { pos = Vector(2195.59, 2292.55, -984.433) },
        [79] = { pos = Vector(2131.18, 2435.32, -984.433) },
        [80] = { pos = Vector(2191.95, 2427.99, -984.433) },
        [81] = { pos = Vector(2479.31, 3016.22, -1014) },
        [82] = { pos = Vector(3296.6, 2918.96, -970.35) },
        [83] = { pos = Vector(3419.38, 2658.46, -970.654) },
        [84] = { pos = Vector(2069.04, 2828.54, -1014) },
        [85] = { pos = Vector(1926.94, 2827.37, -1014) },
        [86] = { pos = Vector(1922.91, 3546.28, -971.228) },
        [87] = { pos = Vector(1609.21, 3476.94, -1016) },
        [88] = { pos = Vector(1354.29, 3200.76, -1016) },
        [89] = { pos = Vector(1357.09, 3425.01, -1016) },
        [90] = { pos = Vector(3165.92, 2653.03, -1016) },
        [91] = { pos = Vector(3418.05, 2753, -1016) },
        [92] = { pos = Vector(3407.29, 2589.29, -1016) },
        [93] = { pos = Vector(3245.51, 2622.08, -1016) }
    }
}

local function LootSpawnSystem()
    if SpawnDelay < CurTime() and LootCount < LootLimit then
        SpawnDelay = CurTime() + 20
        for _, v in pairs( player.GetAll() ) do
            local PlayerPos = v:GetPos()
            for _, platform in pairs( loot[game.GetMap()] ) do
                if not platform.ent or not platform.ent:IsValid() then
                    local distance = PlayerPos:Distance( platform.pos )
                    if distance > MinSpawnDistance and distance < MaxSpawnDistance then
                        platform.ent = ents.Create( table.Random(MRP.Loot) )
                        platform.ent:SetPos(platform.pos)
                        platform.ent:Spawn()
                    end
                end
            end
        end
    end
end

hook.Add("Think", "LootSpawn", LootSpawnSystem)

hook.Add("PostCleanupMap", "ResetLootCount", function()
    LootCount = 0
end)

hook.Add("PlayerSpawnedSENT", "IterateLootCount", function(_, _)
    LootCount = LootCount + 1
end)

hook.Add("EntityRemoved", "DisminushLootCount", function(_, _)
    LootCount = LootCount - 1
end)
