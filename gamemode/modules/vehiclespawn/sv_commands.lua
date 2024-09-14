MRP.Commands.vehicles = {
    addspawn = function(ply, class)
        local map = game.GetMap()
        if not MRP.Spawns then MRP.Spawns = {} end
        if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
        if not MRP.Spawns[map]["vehicles"] then MRP.Spawns[map]["vehicles"] = {} end
	local cat
	if string.find(class, "simfphys") then
		cat = "simfphys"
	else
		cat = "wac"
	end
        table.insert(
		MRP.Spawns[map]["vehicles"],
		{
			pos = ply:GetPos(),
		        ang = ply:GetAngles(),
                        class = class,
			cat = cat,
		}
	)
        file.Write(
            "mrp/spawns.txt",
            util.TableToJSON(MRP.Spawns, true)
        )
        ply:ChatPrint(class .. " spawn added")
    end,
}
MRP.Commands.vehicles.setspawn = function(ply, class)
        local map = game.GetMap()
        if not MRP.Spawns then MRP.Spawns = {} end
        if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
        MRP.Spawns[map]["vehicles"] = {}
	MRP.Commands.vehicles.addspawn(ply, class)
end

