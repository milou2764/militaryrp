MRP.Commands.vehicles = {
    addspawn = function(ply, class)
        local map = game.GetMap()
        if not MRP.spawns then MRP.spawns = {} end
        if not MRP.spawns[map] then MRP.spawns[map] = {} end
        if not MRP.spawns[map]["vehicles"] then MRP.spawns[map]["vehicles"] = {} end
	local cat
	if string.find(class, "simfphys") then
		cat = "simfphys"
	else
		cat = "wac"
	end
        table.insert(
		MRP.spawns[map]["vehicles"],
		{
			pos = ply:GetPos(),
		        ang = ply:GetAngles(),
                        class = class,
			cat = cat,
		}
	)
        file.Write(
            "mrp/spawns.txt",
            util.TableToJSON(MRP.spawns, true)
        )
        ply:ChatPrint(class .. " spawn added")
    end,
}
MRP.Commands.vehicles.setspawn = function(ply, class)
        local map = game.GetMap()
        if not MRP.spawns then MRP.spawns = {} end
        if not MRP.spawns[map] then MRP.spawns[map] = {} end
        MRP.spawns[map]["vehicles"] = {}
	MRP.Commands.vehicles.addspawn(ply, class)
end

