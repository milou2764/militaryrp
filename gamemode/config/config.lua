file.CreateDir("mrp") -- garrysmod/data/mrp
DarkRP = {}

local TAG = "mrpinit"

local function RegisterModel(ent)
    MRP.entityModels[ent.ClassName] = ent.Model
end

--[[
    Assign a unique and immutable ID to a scripted entity
    @param class The class name of the scripted entity
--]]
function MRPRegisterEntity(class)
    local ent = scripted_ents.Get(class) -- get sent
    local mrpid = MRP.classId[class]
    ent.MRPID = mrpid
    RegisterModel(ent)
    scripted_ents.Register(ent, class) -- save changes
end

local function MRPInitEntities()
    MRP.idClass = {
        [0] = "mrp_null_entity", -- no item slot
        [1] = "mrp_null_entity", -- empty item slot
    }
    for class, id in pairs(MRP.classId) do
        MRP.idClass[id] = class
    end
    MRP.entityModels = {}

    MRPRegisterEntity("mrp_ammobox_127x99mm")
	MRPRegisterEntity("mrp_ammobox_556x45mm")
	MRPRegisterEntity("mrp_ammobox_556x45mm_nato")
	MRPRegisterEntity("mrp_ammobox_762x51mm")
	MRPRegisterEntity("mrp_ammobox_9x19mm")
    MRPRegisterEntity("mrp_nvgs")
    hook.Call("MRPInitEntities")
    hook.Call("MRPEntitiesInitialized")
    MRP.EntitiesInitialized = true
end

MRP = MRP or {}
MRP.idClass = MRP.idClass or {}
MRP.mountedGear = MRP.mountedGear or {}
MRP.Commands = {}

MRP.TABLE_CHAR = "mrp_characters"
MRP.TABLE_INV = "mrp_inv"

--[[
    Returns the class name associated with the given ID
    @param MRPID Unique ID
--]]
function MRP.EntityTable(MRPID)
    return scripted_ents.Get(MRP.idClass[MRPID])
end

MRP.WeaponCat = {
    "PrimaryWep",
    "SecondaryWep",
    "RocketLauncher",
}

MRP.classId = {
    ["mrp_nvgs"] = 2,
    ["mrp_ent_gasmask"] = 3,

    ["mrp_helmet1"] = 4,
    ["mrp_helmet2"] = 5,
    ["mrp_helmet3"] = 6,

    ["mrp_musette"] = 7,
    ["mrp_sacf2"] = 8,

    ["mrp_vest1"] = 9,
    ["mrp_vest2"] = 10,
    ["mrp_vest3"] = 11,
    ["mrp_vest4"] = 12,
    ["mrp_vest5"] = 13,
    ["mrp_vest6"] = 14,
    ["mrp_vest7"] = 15,
    ["mrp_vest8"] = 16,

    ["mrp_beret_501rcc"] = 17,
    ["mrp_beret_rima"] = 18,
    ["mrp_beret_rpima"] = 19,
    ["mrp_beret_legion"] = 20,
    ["mrp_beret_2rep"] = 21,
    ["mrp_beret_ca"] = 22,
    ["mrp_beret_1rpima"] = 23,
    ["mrp_bob_ce"] = 24,
    ["mrp_beret_fm"] = 25,
    ["mrp_beret_genie"] = 26,
    ["mrp_beret_cm"] = 27,
    ["mrp_beret_1rpima"] = 28,
    ["mrp_beret_2rep"] = 29,
    ["mrp_beret_501rcc"] = 30,
    ["mrp_beret_alat"] = 31,
    ["mrp_beret_ca"] = 32,
    ["mrp_beret_cm"] = 33,
    ["mrp_beret_fm"] = 34,
    ["mrp_beret_genie"] = 35,
    ["mrp_beret_legion"] = 36,
    ["mrp_beret_rima"] = 37,
    ["mrp_beret_rpima"] = 38,
    ["mrp_bob_ce"] = 39,
    ["mrp_beret_alat"] = 40,

    ["mrp_fn_maximi_mk1"] = 41,
    ["mrp_fn_minimi_mk1"] = 42,
    ["mrp_fn_minimi_mk3"] = 43,
    ["mrp_fn_scarh_pr"] = 44,
    ["mrp_giat_famas_f1"] = 45,
    ["mrp_giat_famas_felin"] = 46,
    ["mrp_giat_famas_inf"] = 47,
    ["mrp_giat_famas_valorise"] = 48,
    ["mrp_giat_frf2"] = 49,
    ["mrp_giat_pamas_g1"] = 50,
    ["mrp_glock17_gen5"] = 51,
    ["mrp_hk416_fc"] = 52,
    ["mrp_hk416_fs"] = 53,
    ["mrp_hk417_dmr"] = 54,
    ["mrp_pgm_hecate_2"] = 55,
    ["mrp_at4cs"] = 56,

    ["mrp_ammobox_762x51mm"] = 57,
    ["mrp_ammobox_556x45mm"] = 58,
    ["mrp_ammobox_9x19mm"] = 59,
    ["mrp_ammobox_127x99mm"] = 60,
    ["mrp_ammobox_556x45mm_nato"] = 61,
}

MRP.CategoryID = {
    NVGs = 0,
    Gasmask = 1,
    Helmet = 2,
    Vest = 3,
    Rucksack = 4,
    PrimaryWep = 5,
    SecondaryWep = 6,
    RocketLauncher = 7
}

MRP.DisabledModules = {
    gaszone = true,
    loot = true,
    npcspawn = true,
    interactivemap = true,
    holster = true,
}

MRP.Factions = {
    [0] = {
        name = "France",
        flag = "gui/faction/france.png",
    },
    [1] = {
        name = "Rebelles",
        flag = "gui/faction/latvia-nationalist.png",
    }
}
MRP.Regiments = {
   -- France
    [1] = {    
        {
            name = "2REP",
            insignia = "materials/gui/regiment/2rep.png",
            whratio = 500/500,
        },
        {
            name = "5RHC",
            insignia = "materials/gui/regiment/5rhc.png",
            whratio = 6 / 8
        },
        {
            name = "1REC",
            insignia = "materials/gui/regiment/1rec.png",
            whratio = 800 / 925
        },
    },
    -- Rebels
    [2] = {
        {
            name = "5e Régiment National de la Libération ( 5-y polk natsional'nogo osvobozhdeniya )",
            insignia = "materials/gui/regiment/latvijai.png",
            whratio = 960 / 720
        }
    }
}

MRP.PlayerModels = {
    -- 1 France
    {
        {
            Model = "models/tom/player/french_army/ce_male_white_01.mdl",
            -- authorized skins
            skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
            -- authorized bodygroups
            bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
            stripes = 5
        },
        {
            Model = "models/tom/player/french_army/ce_male_white_02.mdl",
            skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
            bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
            stripes = 5
        },
        {
            Model = "models/tom/player/french_army/ce_male_african.mdl",
            skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 },
            bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
            stripes = 5
        },
        {
            Model = "models/tom/player/french_army/ce_male_asian.mdl",
            skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
            bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
            stripes = 5
        },
        {
            Model = "models/tom/player/french_army/ce_male_greek.mdl",
            skins = { 0, 1, 2, 3, 4, 5, 6, 7, 14, 15, 16, 17, 18, 19, 20, 21 },
            bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
            stripes = 5
        },
        {
            Model = "models/tom/player/french_army/ce_male_persian.mdl",
            skins = { 0, 1, 2, 3, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19 },
            bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
            stripes = 5
        }
    },
    -- 2 Rebels
    {
        {
            Model = "models/arachnit/hdtf/characters/soldier/soldier_player_blck.mdl",
            skins = 0,
            bodygroups = {0},
        },
        {
            Model = "models/arachnit/hdtf/characters/soldier/soldier_player_digicam.mdl",
            skins = 0,
            bodygroups = {0},
        },
        {
            Model = "models/arachnit/hdtf/characters/soldier/soldier_player_hecu.mdl",
            skins = 0,
            bodygroups = {0},
        },
        {
            Model = "models/arachnit/hdtf/characters/soldier/soldier_player_sand.mdl",
            skins = 0,
            bodygroups = {0},
        },
        {
            Model = "models/arachnit/hdtf/characters/soldier/soldier_player_woodland.mdl",
            skins = 0,
            bodygroups = {0},
        },
    }
}

MRP.npcs = { "npc_vj_ssenpirateh", "npc_vj_ssenpirateleh", "npc_vj_ssenpiratesch" }

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

MRP.FirstName = { "Noah", "Liam", "Jacob", "William", "Mason", "Ethan", "Michael",
                  "Alexander", "James", "Elijah", "Benjamin", "Daniel", "Aiden", "Logan",
                  "Jayden", "Matthew", "Lucas", "David", "Jackson", "Joseph", "Anthony",
                  "Samuel", "Joshua", "Gabriel", "Andrew", "John", "Christopher",
                  "Oliver", "Dylan", "Carter", "Isaac", "Luke", "Henry", "Owen", "Ryan",
                  "Nathan", "Wyatt", "Caleb", "Sebastian", "Jack" }

MRP.LastName = { "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
                 "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
                 "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
                 "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark",
                 "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King",
                 "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores" }

hook.Add("InitPostEntity", "MRPInitEntities", MRPInitEntities)

MRP.icons = { NVGs = "icon64/nvgs.png",
              Helmet = "icon64/helmet.png",
              Gasmask = "icon64/gasmask.png",
              Rucksack = "icon64/rucksack.png",
              Vest = "icon64/vest.png",
              PrimaryWep = "icon128/assault-rifle",
              SecondaryWep = "icon64/pistol",
              RocketLauncher = "icon128/rocket-launcher" }
