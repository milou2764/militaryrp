AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:createServerModel(target)
    local model = ents.Create("prop_dynamic")
    model:SetModel("models/yukon/props/conscripts/maskbag.mdl")
    model:SetParent(target)
    model:AddEffects(EF_BONEMERGE)

    return model
end