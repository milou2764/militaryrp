file.CreateDir('mrp') -- garrysmod/data/mrp

local TAG = 'mrpinit'

local function RegisterModel(ent)
    MRP.entityModels[ent.ClassName] = ent.model
end

--[[
    Assign a unique and immutable ID to a scripted entity
    @param class The class name of the scripted entity
--]]
function MRPRegisterEntity(class)
    local ent = scripted_ents.Get(class) -- get sent
    local mrpid = MRP.classId[class]
    ent.MRPID = mrpid
    Log.d(TAG, class .. ' ' .. tostring(mrpid))
    RegisterModel(ent)
    scripted_ents.Register(ent, class) -- save changes
end

local function MRPInitEntities()
    MRP.idClass = {
        [0] = 'mrp_null_entity', -- no item slot
        [1] = 'mrp_null_entity', -- empty item slot
    }
    for class, id in pairs(MRP.classId) do
        MRP.idClass[id] = class
    end
    MRP.entityModels = {}
    MRP.weaponClasses = {}
    hook.Call('MRPInitEntities')
    hook.Call('MRPEntitiesInitialized')
    MRP.EntitiesInitialized = true
end

MRP = MRP or {}
MRP.idClass = MRP.idClass or {}
MRP.mountedGear = MRP.mountedGear or {}
MRP.mountedWeps = MRP.mountedWeps or {}

--[[
    Returns the class name associated with the given ID
    @param MRPID Unique ID
--]]
function MRP.getMRPEnt(MRPID)
    return scripted_ents.Get(MRP.idClass[MRPID])
end

MRP.classId = {
    ['mrp_nvgs'] = 2,
    ['mrp_ent_gasmask'] = 3,

    ['mrp_helmet1'] = 4,
    ['mrp_helmet2'] = 5,
    ['mrp_helmet3'] = 6,

    ['mrp_musette'] = 7,
    ['mrp_sacf2'] = 8,

    ['mrp_vest1'] = 9,
    ['mrp_vest2'] = 10,
    ['mrp_vest3'] = 11,
    ['mrp_vest4'] = 12,
    ['mrp_vest5'] = 13,
    ['mrp_vest6'] = 14,
    ['mrp_vest7'] = 15,
    ['mrp_vest8'] = 16,

    ['mrp_beret_501rcc'] = 17,
    ['mrp_beret_rima'] = 18,
    ['mrp_beret_rpima'] = 19,
    ['mrp_beret_legion'] = 20,
    ['mrp_beret_2rep'] = 21,
    ['mrp_beret_ca'] = 22,
    ['tompms_musette'] = 23,
    ['mrp_beret_1rpima'] = 24,
    ['mrp_bob_ce'] = 25,
    ['mrp_beret_fm'] = 26,
    ['mrp_beret_genie'] = 27,
    ['mrp_beret_cm'] = 28,
    ['mrp_beret_1rpima'] = 29,
    ['mrp_beret_2rep'] = 30,
    ['mrp_beret_501rcc'] = 31,
    ['mrp_beret_alat'] = 32,
    ['mrp_beret_ca'] = 33,
    ['mrp_beret_cm'] = 34,
    ['mrp_beret_fm'] = 35,
    ['mrp_beret_genie'] = 36,
    ['mrp_beret_legion'] = 37,
    ['mrp_beret_rima'] = 38,
    ['mrp_beret_rpima'] = 39,
    ['mrp_bob_ce'] = 40,
    ['mrp_beret_alat'] = 41,

    ['mrp_m92beretta'] = 42,
    ['mrp_matador'] = 43,
}

MRP.categoryID = { NVGs = 0,
                   Gasmask = 1,
                   Helmet = 2,
                   Vest = 3,
                   Rucksack = 4,
                   PrimaryWep = 5,
                   SecondaryWep = 6,
                   RocketLauncher = 7 }

MRP.disabledDefaults = {}
MRP.disabledDefaults.modules = {
    gaszone = true,
    loot = true,
    npcspawn = false,
    interactivemap = true,
}

MRP.Factions = {
    [0] = {
        name = 'France'
    },
    [1] = {
        name = 'Rebelles'
    }
}
MRP.Regiments = {
    -- France
     { { name = '2REI',
         insignia = 'materials/gui/regiment/2rei.png',
         -- width/height ratio of the insignia
         whratio = 219 / 295 },
        { name = '5RHC',
          insignia = 'materials/gui/regiment/5rhc.png',
          whratio = 6 / 8 },
        { name = '1REC',
          insignia = 'materials/gui/regiment/1rec.png',
          whratio = 800 / 925 },
        { name = '1RPIMA',
          insignia = 'materials/gui/regiment/1rpima.png',
          whratio = 800 / 1372 } },
    -- Rebels
    { { name = 'SansNom',
        insignia = 'null',
        whratio = 800 / 1372 } } }

MRP.PlayerModels = {
    { { model = 'models/tom/player/french_army/ce_male_white_01.mdl',
        -- authorized skins
        skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
                  19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
        -- authorized bodygroups
        bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
        stripes = 5 },
      { model = 'models/tom/player/french_army/ce_male_white_02.mdl',
        skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 16, 17, 18, 19, 20, 21, 22, 23, 24,
                  25, 26, 27, 28, 29, 30, 31 },
        bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
        stripes = 5 },
      { model = 'models/tom/player/french_army/ce_male_african.mdl',
        skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 },
        bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
        stripes = 5 },
      { model = 'models/tom/player/french_army/ce_male_asian.mdl',
        skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 },
        bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
        stripes = 5 },
      { model = 'models/tom/player/french_army/ce_male_greek.mdl',
        skins = { 0, 1, 2, 3, 4, 5, 6, 7, 14, 15, 16, 17, 18, 19, 20, 21 },
        bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
        stripes = 5 },
      { model = 'models/tom/player/french_army/ce_male_persian.mdl',
        skins = { 0, 1, 2, 3, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19 },
        bodygroups = { 0, 0, 0, 0, 0, { 0, 1, 2, 3, 4, 5, 6, 7, 8 } },
        stripes = 5 } },
    { {
        model = 'models/yukon/conscripts/conscript_a_w_pm_v2.mdl',
        skins = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 },
        bodygroups = { 0, 3, 0, 1, { 0, 2 }, 0, 0, 1, 1, 2, 17, 0, { 0, 1, 2 }, 0, 0,
                       0, 0, 0, 1 },
        gasmask_bodygroup = { 17, 2, 1 },
        nvg_bodygroup = { 14, 1, 2 },
        stripes = 5 },
      { model = 'models/yukon/conscripts/conscript_a_b_pm_v2.mdl',
        skins = { 0, 1, 2, 3, 4, 5 },
        bodygroups = { 0, 3, 0, 1, { 0, 2 }, 0, 0, 1, 1, 2, { 17 }, 0, { 0, 1, 2 },
                       0, 0, 0, 0, 0, 1 },
        gasmask_bodygroup = { 17, 2, 1 },
        nvg_bodygroup = { 16, 9, 10 },
        stripes = 5 } }
}

MRP.npcs = { 'npc_vj_ssenpirateh', 'npc_vj_ssenpirateleh', 'npc_vj_ssenpiratesch' }

MRP.Loot = {
    'mrp_ammobox_556mm',
    'mrp_ammobox_556mm',
    'mrp_ammobox_556mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_9mm',
    'mrp_ammobox_45acp',
    'mrp_ammobox_45acp',
    'mrp_ammobox_45acp',
    'mrp_ammobox_357magnum',
    'mrp_ammobox_357magnum',
    'mrp_ammobox_357magnum',
    'mrp_ammobox_762_nato',
    'mrp_ammobox_762_nato',
    'mrp_ammobox_762_nato',
    'mrp_ammobox_762_nato',
    'mrp_ammobox_762_nato',
    'mrp_ammobox_762_r',
    'mrp_ammobox_762_r',
    'mrp_ammobox_762_m43',
    'mrp_ammobox_762_m43',
    'mrp_ammobox_12gauge',
    'mrp_ammobox_12gauge',
    'mrp_ammobox_12gauge',
    'mrp_ammobox_12gauge',
    'mrp_ammobox_12gauge',
    'mrp_ammobox_12gauge',
    'mrp_ammobox_12gauge',
    'mrp_rucksack1',
    'mrp_helmet1',
    'mrp_m92beretta',
    'mrp_uzi',
    'mrp_glock',
    'mrp_hk45',
    'mrp_mp5',
    'mrp_sig_p229r',
    'mrp_tec9',
    'mrp_browningauto5',
    'mrp_dbarrel',
    'mrp_ithacam37',
    'mrp_mossberg590',
    'mrp_remington870',
    'mrp_spas12',
    'mrp_m3',
    'mrp_dragunov',
    'mrp_pkm',
    'mrp_ak47',
    'mrp_amd65',
    'mrp_fal',
    'mrp_g3a3',
    'mrp_m14sp',
    'mrp_m60',
    'mrp_m24',
    'mrp_m4a1',
    'mrp_m249lmg',
    'mrp_m16a4_acog',
    'mrp_colt1911',
    'mrp_ump45',
    'mrp_thompson',
    'mrp_coltpython',
    'mrp_deagle',
    'mrp_model627',
    'mrp_nvg',
    'mrp_gasmask',
    'mrp_gasmask',
    'mrp_gasmask',
    'mrp_gasmask',
}
-- character size
MRP.minSize = 165
MRP.maxSize = 190

MRP.FirstName = { 'Noah', 'Liam', 'Jacob', 'William', 'Mason', 'Ethan', 'Michael',
                  'Alexander', 'James', 'Elijah', 'Benjamin', 'Daniel', 'Aiden', 'Logan',
                  'Jayden', 'Matthew', 'Lucas', 'David', 'Jackson', 'Joseph', 'Anthony',
                  'Samuel', 'Joshua', 'Gabriel', 'Andrew', 'John', 'Christopher',
                  'Oliver', 'Dylan', 'Carter', 'Isaac', 'Luke', 'Henry', 'Owen', 'Ryan',
                  'Nathan', 'Wyatt', 'Caleb', 'Sebastian', 'Jack' }

MRP.LastName = { 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
                 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez',
                 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
                 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark',
                 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King',
                 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores' }

hook.Add('InitPostEntity', 'MRPInitEntities', MRPInitEntities)

MRP.icons = { NVGs = 'icon64/nvgs.png',
              Helmet = 'icon64/helmet.png',
              Gasmask = 'icon64/gasmask.png',
              Rucksack = 'icon64/rucksack.png',
              Vest = 'icon64/vest.png',
              PrimaryWep = 'icon128/assault-rifle',
              SecondaryWep = 'icon64/pistol',
              RocketLauncher = 'icon128/rocket-launcher' }
