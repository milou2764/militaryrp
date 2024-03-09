file.CreateDir('mrp') -- garrysmod/data/mrp

--[[
    Assign a unique and immutable ID to a scripted entity
    @param class The class name of the scripted entity
--]]
local function RegisterEntity(class)
    local ent = scripted_ents.Get(class) -- get sent
    ent.MRPID = table.insert(MRP.ents, class)
    ent:MRPRegisterModel()
    scripted_ents.Register(ent, class) -- save changes
end

local function MRPInitEntities()
    MRP.ents = {
        [0] = 'mrp_null_entity', -- no item slot
        [1] = 'mrp_null_entity', -- empty item slot
    }
    MRP.entityModels = {}
    MRP.weaponClasses = {}
    RegisterEntity('mrp_nvgs')
    RegisterEntity('mrp_helmet1')
    RegisterEntity('mrp_helmet2')
    RegisterEntity('mrp_helmet3')
    RegisterEntity('mrp_ent_gasmask')
    RegisterEntity('mrp_rucksack1')
    RegisterEntity('mrp_rucksack2')
    RegisterEntity('mrp_vest1')
    RegisterEntity('mrp_vest2')
    RegisterEntity('mrp_vest3')
    RegisterEntity('mrp_vest4')
    RegisterEntity('mrp_vest5')
    RegisterEntity('mrp_vest6')
    RegisterEntity('mrp_vest7')
    RegisterEntity('mrp_vest8')
    RegisterEntity('mrp_ammobox_9mm')
    RegisterEntity('mrp_ammobox_12gauge')
    RegisterEntity('mrp_ammobox_45acp')
    RegisterEntity('mrp_ammobox_50bmg')
    RegisterEntity('mrp_ammobox_357magnum')
    RegisterEntity('mrp_ammobox_545mm')
    RegisterEntity('mrp_ammobox_556mm')
    RegisterEntity('mrp_ammobox_762_m43')
    RegisterEntity('mrp_ammobox_762_nato')
    RegisterEntity('mrp_ammobox_762_r')
    RegisterEntity('mrp_m92beretta')
    RegisterEntity('mrp_matador')
    hook.Call('MRPInitEntities')
    hook.Call('MRPEntitiesInitialized')
    MRP.EntitiesInitialized = true
end

MRP = MRP or {}
MRP.ents = MRP.ents or {}
MRP.mountedGear = MRP.mountedGear or {}
MRP.mountedWeps = MRP.mountedWeps or {}

--[[
    Returns the class name associated with the given ID
    @param MRPID Unique ID
--]]
function MRP.getMRPEnt(MRPID)
    return scripted_ents.Get(MRP.ents[MRPID])
end

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
