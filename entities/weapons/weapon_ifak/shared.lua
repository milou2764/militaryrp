SWEP.ViewModel = "models/weapons/v_ifak.mdl"
SWEP.WorldModel = "models/items/ifak.mdl"
SWEP.PrintName = "Infantry First Aid Kit"
SWEP.Sounds = {}

SWEP.Sounds["bandage"] = {
    [1] = {
        time = 0.4,
        sound = Sound("FAS2_Bandage.Retrieve")
    },
    [2] = {
        time = 1.25,
        sound = Sound("FAS2_Bandage.Open")
    },
    [3] = {
        time = 2.15,
        sound = Sound("FAS2_Hemostat.Retrieve")
    }
}

SWEP.Sounds["quikclot"] = {
    [1] = {
        time = 0.3,
        sound = Sound("FAS2_QuikClot.Retrieve")
    },
    [2] = {
        time = 1.45,
        sound = Sound("FAS2_QuikClot.Loosen")
    },
    [3] = {
        time = 2.55,
        sound = Sound("FAS2_QuikClot.Open")
    }
}

SWEP.Sounds["suture"] = {
    [1] = {
        time = 0.3,
        sound = Sound("FAS2_Hemostat.Retrieve")
    },
    [2] = {
        time = 3.5,
        sound = Sound("FAS2_Hemostat.Close")
    }
}

function SWEP:Holster()
    self:EmitSound("weapons/weapon_holster" .. math.random(1, 3) .. ".wav", 50, 100)
end