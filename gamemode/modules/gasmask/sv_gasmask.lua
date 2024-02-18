include( "sh_gasmask.lua" )
util.AddNetworkString("GASMASK_RequestToggle")

concommand.Add("gasmask_toggle", function(ply)
    if ply:GetNWInt("Gasmask") > 1 then
        if not ply:GetNWInt("GASMASK_SpamDelay") or ply:GetNWInt("GASMASK_SpamDelay") < CurTime() then
            ply:SetNWInt("GASMASK_SpamDelay", math.Round(CurTime()) + 4)
            ply.GASMASK_LastWeapon = ply:GetActiveWeapon()
            ply:SetSuppressPickupNotices(true)
            ply:StripWeapon("weapon_gasmask")
            ply:Give("weapon_gasmask")
            ply:SelectWeapon("weapon_gasmask")

            if ply:GetNWBool("GasmaskOn") then
                ply:SetNWBool("GasmaskOn", false)
                net.Start("GASMASK_RequestToggle")
                net.WriteBool(false)
                net.Send(ply)
                net.Start("MRPPlayerTakeOffGasmask")
                net.WriteUInt(ply:UserID(), 16)
                net.Broadcast()
            else
                ply:SetNWBool("GasmaskOn", true)
                net.Start("GASMASK_RequestToggle")
                net.WriteBool(true)
                net.Send(ply)
                net.Start("MRPPlayerTakeOnGasmask")
                net.WriteUInt(ply:UserID(), 16)
                net.Broadcast()
            end

            timer.Simple(1.8, function()
                if ply.GASMASK_LastWeapon:IsValid() then ply:SelectWeapon(ply.GASMASK_LastWeapon) end -- eliminate the case where the player do not hold a weapon
                ply:StripWeapon("weapon_gasmask")
                ply:SetSuppressPickupNotices(false)
            end)
        end
    else
        ply:ChatPrint("Vous devez avoir en votre possession un masque à gaz pour cela")
    end
end)

local gasmask_dmgtypes = {
    [DMG_NERVEGAS] = 0,
    [DMG_RADIATION] = 0.05
}

hook.Add("EntityTakeDamage", "GASMASK_TakeDamage", function(ent, dmginfo)
    if ent:IsPlayer() and ent:GetNWBool("GasmaskOn") then
        local dmgtype = dmginfo:GetDamageType()

        if gasmask_dmgtypes[dmgtype] then
            dmginfo:ScaleDamage(gasmask_dmgtypes[dmgtype])
        end
    elseif ent:IsPlayer() and player_manager.GetPlayerClass(ent) == "player_spectator" then
        dmginfo:ScaleDamage(0)
    end
end)