local CleanupDelay = 0
local function MRPCleanup()
    for _, ent in pairs(ents.GetAll()) do
        ent:RemoveAllDecals()
        --ragdoll cleanup
        --if TempTable[k]:IsRagdoll() then
            --TempTable[k]:Remove()
        --end
    end
end

concommand.Add("mrp_cleanup", MRPCleanup)

local function AutoCleanup()
    if CurTime() > CleanupDelay then
        CleanupDelay = CurTime() + 500
        MRPCleanup()
    end
end

hook.Add("Think", "AutoClean", AutoCleanup)

hook.Add("OnEntityCreated", "MRPRemoveRagdoll", function(ent)
    if ent:IsRagdoll() and not ent:GetOwner():IsPlayer() then
        timer.Simple(30, function() if ent and ent.Remove then ent:Remove() end end)
    end
end)
