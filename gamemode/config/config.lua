file.CreateDir("mrp")
function registerMRPEntity(class)
    local ent = scripted_ents.Get(class) -- get sent
    ent.MRPID = table.insert(MRP.ents, ent.ClassName) -- assign ID to sent and register sent to MRP sent table
    ent:registerMRPEntity()
    scripted_ents.Register(ent, class) -- save changes
end
local function InitMRPEntities()
    MRP.ents = {
        [0] = "mrp_null_entity",-- no item slot
        [1] = "mrp_null_entity",-- empty item slot
    }
    MRP.entityModels = {}
    MRP.weaponClasses = {}
    registerMRPEntity("mrp_nvgs")
    registerMRPEntity("mrp_helmet1")
    registerMRPEntity("mrp_helmet2")
    registerMRPEntity("mrp_helmet3")
    registerMRPEntity("mrp_ent_gasmask")
    registerMRPEntity("mrp_rucksack1")
    registerMRPEntity("mrp_rucksack2")
    registerMRPEntity("mrp_vest1")
    registerMRPEntity("mrp_vest2")
    registerMRPEntity("mrp_vest3")
    registerMRPEntity("mrp_vest4")
    registerMRPEntity("mrp_vest5")
    registerMRPEntity("mrp_vest6")
    registerMRPEntity("mrp_vest7")
    registerMRPEntity("mrp_vest8")
    registerMRPEntity("mrp_ammobox_9mm")
    registerMRPEntity("mrp_ammobox_12gauge")
    registerMRPEntity("mrp_ammobox_45acp")
    registerMRPEntity("mrp_ammobox_50bmg")
    registerMRPEntity("mrp_ammobox_357magnum")
    registerMRPEntity("mrp_ammobox_545mm")
    registerMRPEntity("mrp_ammobox_556mm")
    registerMRPEntity("mrp_ammobox_762_m43")
    registerMRPEntity("mrp_ammobox_762_nato")
    registerMRPEntity("mrp_ammobox_762_r")
    registerMRPEntity("mrp_m92beretta")
    registerMRPEntity("mrp_matador")
    hook.Call("MRPInitEntities")
    hook.Call("MRPEntitiesInitialized")
    MRP.EntitiesInitialized = true
end

MRP = MRP or {}
MRP.ents = MRP.ents or {}
MRP.mountedGear = MRP.mountedGear or {}
MRP.mountedWeps = MRP.mountedWeps or {}
function MRP.getMRPEnt(MRPID)
    return scripted_ents.Get(MRP.ents[MRPID])
end
MRP.categoryID = {
    NVGs = 0,
    Gasmask = 1,
    Helmet = 2,
    Vest = 3,
    Rucksack = 4,
    PrimaryWep = 5,
    SecondaryWep = 6,
    RocketLauncher = 7
}
MRP.disabledDefaults = {}
MRP.disabledDefaults.modules = {
    gaszone = true,
    loot = true,
    npcspawn = false,
    interactivemap = true,
}
MRP.Factions = {
    [0] = {
        name = "France"
    },
    [1] = {
        name = "Rebelles"
    }
}
MRP.Regiments = {
    [0] = { --France
        [0] = {
            name = "2REI",
            insignia = "materials/gui/regiment/2rei.png",
            whratio = 219 / 295 --width/height ratio of the insignia
        },
        [1] = {
            name = "5RHC",
            insignia = "materials/gui/regiment/5rhc.png",
            whratio = 6 / 8
        },
        [2] = {
            name = "1REC",
            insignia = "materials/gui/regiment/1rec.png",
            whratio = 800 / 925
        },
        [3] = {
            name = "1RPIMA",
            insignia = "materials/gui/regiment/1rpima.png",
            whratio = 800 / 1372
        }
    },
    [1] = { --Rebelles
        [0] = {name = "SansNom",
        insignia = "null",
        whratio = 800 / 1372
    }
    }
}
MRP.PlayerModels = {
    [0] = { --France
        [0] = {
            model = "models/tom/player/french_army/ce_male_white_01.mdl",
            skins = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31}, -- authorized skins
            bodygroups = { -- authorized bodygroups
                0, --0 head
                0, --1 uniformes
                0, --2 mains
                0, --5 grades bv
                0, --6 grades hv
                {0,1,2,3,4,5,6,7,8}, --7 Groupes sanguins
            },
            stripes = 5,
        },
        [1] = {
            model = "models/tom/player/french_army/ce_male_white_02.mdl",
            skins = {0,1,2,3,4,5,6,7,8,9,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31},
            bodygroups = {
                0,
                0,
                0,
                0,
                0,
                {0,1,2,3,4,5,6,7,8},
            },
            stripes = 5,
        },
        [2] = {
            model = "models/tom/player/french_army/ce_male_african.mdl",
            skins = {0,1,2,3,4,5,6,7,8,9},
            bodygroups = {
                0,
                0,
                0,
                0,
                0,
                {0,1,2,3,4,5,6,7,8},
            },
            stripes = 5,
        },
        [3] = {
            model = "models/tom/player/french_army/ce_male_asian.mdl",
            skins = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15},
            bodygroups = {
                0,
                0,
                0,
                0,
                0,
                {0,1,2,3,4,5,6,7,8},
            },
            stripes = 5,
        },
        [4] = {
            model = "models/tom/player/french_army/ce_male_greek.mdl",
            skins = {0,1,2,3,4,5,6,7,14,15,16,17,18,19,20,21},
            bodygroups = {
                0,
                0,
                0,
                0,
                0,
                {0,1,2,3,4,5,6,7,8},
            },
            stripes = 5,
        },
        [5] = {
            model = "models/tom/player/french_army/ce_male_persian.mdl",
            skins = {0,1,2,3,4,5,12,13,14,15,16,17,18,19},
            bodygroups = {
                0,
                0,
                0,
                0,
                0,
                {0,1,2,3,4,5,6,7,8},
            },
            stripes = 5,
        }
    },
    [1] = {
        [0] = {
            model = "models/yukon/conscripts/conscript_a_w_pm_v2.mdl",
            skins = {0,1,2,3,4,5,6,7,8,9,10,11,12,13},
            bodygroups = {0,3,0,1,{0,2},0,0,1,1,2,{17},0,{0,1,2},0,0,0,0,0,1},
            gasmask_bodygroup = {17,2,1},
            nvg_bodygroup = {14,1,2},
            stripes = 5
        },
        [1] = {
            model = "models/yukon/conscripts/conscript_a_b_pm_v2.mdl",
            skins = {0,1,2,3,4,5},
            bodygroups = {0,3,0,1,{0,2},0,0,1,1,2,{17},0,{0,1,2},0,0,0,0,0,1},
            gasmask_bodygroup = {17,2,1},
            nvg_bodygroup = {16,9,10},
            stripes = 5
        },
    }
}
MRP.npcs = {
    "npc_vj_ssenpirateh",
    "npc_vj_ssenpirateleh",
    "npc_vj_ssenpiratesch"
}
MRP.Loot = {
    "mrp_ammobox_556mm",
    "mrp_ammobox_556mm",
    "mrp_ammobox_556mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_9mm",
    "mrp_ammobox_45acp",
    "mrp_ammobox_45acp",
    "mrp_ammobox_45acp",
    "mrp_ammobox_357magnum",
    "mrp_ammobox_357magnum",
    "mrp_ammobox_357magnum",
    "mrp_ammobox_762_nato",
    "mrp_ammobox_762_nato",
    "mrp_ammobox_762_nato",
    "mrp_ammobox_762_nato",
    "mrp_ammobox_762_nato",
    "mrp_ammobox_762_r",
    "mrp_ammobox_762_r",
    "mrp_ammobox_762_m43",
    "mrp_ammobox_762_m43",
    "mrp_ammobox_12gauge",
    "mrp_ammobox_12gauge",
    "mrp_ammobox_12gauge",
    "mrp_ammobox_12gauge",
    "mrp_ammobox_12gauge",
    "mrp_ammobox_12gauge",
    "mrp_ammobox_12gauge",
    "mrp_rucksack1",
    "mrp_helmet1",
    "mrp_m92beretta",
    "mrp_uzi",
    "mrp_glock",
    "mrp_hk45",
    "mrp_mp5",
    "mrp_sig_p229r",
    "mrp_tec9",
    "mrp_browningauto5",
    "mrp_dbarrel",
    "mrp_ithacam37",
    "mrp_mossberg590",
    "mrp_remington870",
    "mrp_spas12",
    "mrp_m3",
    "mrp_dragunov",
    "mrp_pkm",
    "mrp_ak47",
    "mrp_amd65",
    "mrp_fal",
    "mrp_g3a3",
    "mrp_m14sp",
    "mrp_m60",
    "mrp_m24",
    "mrp_m4a1",
    "mrp_m249lmg",
    "mrp_m16a4_acog",
    "mrp_colt1911",
    "mrp_ump45",
    "mrp_thompson",
    "mrp_coltpython",
    "mrp_deagle",
    "mrp_model627",
    "mrp_nvg",
    "mrp_gasmask",
    "mrp_gasmask",
    "mrp_gasmask",
    "mrp_gasmask",
}
-- character size
MRP.minSize = 165
MRP.maxSize = 190

MRP.FirstName = {
    [1] = "Noah",
    [2] = "Liam",
    [3] = "Jacob",
    [4] = "William",
    [5] = "Mason",
    [6] = "Ethan",
    [7] = "Michael",
    [8] = "Alexander",
    [9] = "James",
    [10] = "Elijah",
    [11] = "Benjamin",
    [12] = "Daniel",
    [13] = "Aiden",
    [14] = "Logan",
    [15] = "Jayden",
    [16] = "Matthew",
    [17] = "Lucas",
    [18] = "David",
    [19] = "Jackson",
    [20] = "Joseph",
    [21] = "Anthony",
    [22] = "Samuel",
    [23] = "Joshua",
    [24] = "Gabriel",
    [25] = "Andrew",
    [26] = "John",
    [27] = "Christopher",
    [28] = "Oliver",
    [29] = "Dylan",
    [30] = "Carter",
    [31] = "Isaac",
    [32] = "Luke",
    [33] = "Henry",
    [34] = "Owen",
    [35] = "Ryan",
    [36] = "Nathan",
    [37] = "Wyatt",
    [38] = "Caleb",
    [39] = "Sebastian",
    [40] = "Jack"
}
MRP.LastName = {
    [1] = "Smith",
    [2] = "Johnson",
    [3] = "Williams",
    [4] = "Brown",
    [5] = "Jones",
    [6] = "Garcia",
    [7] = "Miller",
    [8] = "Davis",
    [9] = "Rodriguez",
    [10] = "Martinez",
    [11] = "Hernandez",
    [12] = "Lopez",
    [13] = "Gonzalez",
    [14] = "Wilson",
    [15] = "Anderson",
    [16] = "Thomas",
    [17] = "Taylor",
    [18] = "Moore",
    [19] = "Jackson",
    [20] = "Martin",
    [21] = "Lee",
    [22] = "Perez",
    [23] = "Thompson",
    [24] = "White",
    [25] = "Harris",
    [26] = "Sanchez",
    [27] = "Clark",
    [28] = "Ramirez",
    [29] = "Lewis",
    [30] = "Robinson",
    [31] = "Walker",
    [32] = "Young",
    [33] = "Allen",
    [34] = "King",
    [35] = "Wright",
    [36] = "Scott",
    [37] = "Torres",
    [38] = "Nguyen",
    [39] = "Hill",
    [40] = "Flores"
}
hook.Add("InitPostEntity", "InitMRPEntities", InitMRPEntities)

MRP.icons = {
    NVGs = "icon64/nvgs.png",
    Helmet = "icon64/helmet.png",
    Gasmask = "icon64/gasmask.png",
    Rucksack = "icon64/rucksack.png",
    Vest = "icon64/vest.png",
    PrimaryWep = "icon128/assault-rifle",
    SecondaryWep = "icon64/pistol",
    RocketLauncher = "icon128/rocket-launcher",
}