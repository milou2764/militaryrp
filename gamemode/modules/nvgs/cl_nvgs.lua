NV_Status = false
local NV_Vector = 0
local NV_TimeToVector = 0
local ISIBIntens = 1
local reg = debug.getregistry()
local Length = reg.Vector.Length
CreateClientConVar("nv_toggspeed", 0.09, true, false)
CreateClientConVar("nv_illum_area", 512, true, false)
CreateClientConVar("nv_illum_bright", 1.0, true, false)
CreateClientConVar("nv_aim_status", 0, true, false)
CreateClientConVar("nv_aim_range", 200, true, false)
CreateClientConVar("nv_etisd_sensitivity_range", 200, true, false)
CreateClientConVar("nv_etisd_status", 0, true, false)
CreateClientConVar("nv_id_sens_darkness", 0.25, true, false)
CreateClientConVar("nv_id_status", 0, true, false)
CreateClientConVar("nv_id_reaction_time", 1, true, false)
CreateClientConVar("nv_isib_sensitivity", 5, true, false)
CreateClientConVar("nv_isib_status", 0, true, false)
CreateClientConVar("nv_fx_alphapass", 5, true, false)
CreateClientConVar("nv_fx_blur_status", 1, true, false)
CreateClientConVar("nv_fx_distort_status", 1, true, false)
CreateClientConVar("nv_fx_colormod_status", 1, true, false)
CreateClientConVar("nv_fx_blur_intensity", 1, true, false)
CreateClientConVar("nv_fx_goggle_overlay_status", 1, true, false)
CreateClientConVar("nv_fx_bloom_status", 0, true, false)
CreateClientConVar("nv_fx_goggle_status", 0, true, false)
CreateClientConVar("nv_fx_noise_status", 0, true, false)
CreateClientConVar("nv_fx_noise_variety", 20, true, false)
CreateClientConVar("nv_type", 1, true, false)
local IsBrighter = false
local IsMade = false
local Brightness, IllumArea, ISIBSensitivity, dlight, trace, BlurIntensity, GenInProgress
local tr = {}
local Color_Brightness = 0.8
local Color_Contrast = 1.1
local Color_AddGreen = -0.35
local Color_MultiplyGreen = 0.028
local Bloom_Darken = 0.75
local Bloom_Multiply = 1

local Color_Tab = {
    ["$pp_colour_addr"] = -1,
    ["$pp_colour_addg"] = Color_AddGreen,
    ["$pp_colour_addb"] = -1,
    ["$pp_colour_brightness"] = Color_Brightness,
    ["$pp_colour_contrast"] = Color_Contrast,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = Color_MultiplyGreen,
    ["$pp_colour_mulb"] = 0
}

local Clr_FLIR = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = -0.65,
    ["$pp_colour_contrast"] = 2.2,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local Clr_FLIR_Ents = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0.6,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local CurScale = 0
local sndOn = Sound("items/nvg/on.wav")
local sndOff = Sound("items/nvg/off.wav")
local surface, math, render, util = surface, math, render, util
local BloomStrength = 0
local OverlayTexture = surface.GetTextureID("effects/nv_overlaytex.vmt")
local Grain = surface.GetTextureID("effects/grain.vmt")
local GrainMat = Material("effects/grain")
local Line = surface.GetTextureID("effects/nvline.vmt")
local LineMat = Material("effects/nvline")
local utrace, rand = util.TraceLine, math.random
local clr, CT, Output, w, h, FT, OldRT
local AlphaPass = surface.GetTextureID("effects/nightvision.vmt")
local GrainTable = {}
local SetViewPort, Clear = render.SetViewPort, render.Clear

function NV_GenerateGrainTextures()
    CT = SysTime()

    GrainTable = {
        cur = 1,
        wait = 0
    }

    MsgN("NVScript: Generating grain textures...")
    OldRT = render.GetRenderTarget()
    w, h = ScrW(), ScrH()

    for i = 1, GetConVar("nv_fx_noise_variety"):GetInt() do
        Output = GetRenderTarget("Grain" .. i, w / 4, h / 4, true)
        render.SetRenderTarget(Output)
        SetViewPort(0, 0, w / 4, h / 4)
        Clear(0, 0, 0, 0)
        cam.Start2D()

        for j = 1, h / 4 do
            -- 40 grains per every Y pixel
            for _ = 1, 40 do
                SetViewPort(rand(0, w / 4), j * 2, 1, 1)
                Clear(0, 0, 0, rand(100, 150))
            end
        end

        cam.End2D()
        Output = GetRenderTarget("Grain" .. i, w / 4, h / 4, true)
        GrainTable[i] = Output
        GrainTable.last = i
    end

    SetViewPort(0, 0, w, h)
    render.SetRenderTarget(OldRT)
    local ttaken = math.Round(SysTime() - CT, 2)
    MsgN("NVScript: Generation finished! Time taken: " .. ttaken .. " second(s).")
end

function NV_GenerateLineTexture()
    CT = SysTime()
    MsgN("NVScript: Generating night-vision line texture...")
    OldRT = render.GetRenderTarget()
    w, h = ScrW(), ScrH()
    Output = GetRenderTarget("NVLine", w, h, true)
    render.SetRenderTarget(Output)
    Clear(0, 0, 0, 0)
    SetViewPort(0, 0, w, h)
    cam.Start2D()

    for i = 1, h / 4 do
        SetViewPort(0, i * 4, w, 2)
        Clear(255, 255, 255, 200)
    end

    cam.End2D()
    SetViewPort(0, 0, w, h)
    render.SetRenderTarget(OldRT)
    Output = GetRenderTarget("NVLine", w, h, true)
    LineMat:SetTexture("$basetexture", Output)
    local ttaken = math.Round(SysTime() - CT, 2)
    MsgN("NVScript: Generation finished! Time taken: " ..  ttaken .. " second(s).")
end

local function NV_InitPostEntity()
    timer.Simple(2, function()
        NV_GenerateGrainTextures()
        NV_GenerateLineTexture()
    end)
end

hook.Add("InitPostEntity", "NV_InitPostEntity", NV_InitPostEntity)

local function NV_FX()
    local ply = LocalPlayer()

    if ply:Alive() and NV_Status == true then
        w, h = ScrW(), ScrH()
        FT = FrameTime()
        CurScale = Lerp(FT * (30 * GetConVar("nv_toggspeed"):GetFloat()), CurScale, 1)

        if GetConVar("nv_type"):GetInt() <= 1 then
            Bloom_Multiply = Lerp(0.025, Bloom_Multiply, 3)
            Bloom_Darken = Lerp(0.1, Bloom_Darken, 0.75 - BloomStrength)
            DrawBloom(Bloom_Darken, Bloom_Multiply, 9, 9, 1, 1, 1, 1, 1)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetTexture(AlphaPass)

            for _ = 1, GetConVar("nv_fx_alphapass"):GetInt() do
                surface.DrawTexturedRect(0, 0, w, h)
            end

            surface.SetTexture(Line)
            surface.SetDrawColor(25, 50, 25, 255)
            surface.DrawTexturedRect(0, 0, w, h)

            GrainMat:SetTexture("$basetexture", GrainTable[GrainTable.cur])
            surface.SetTexture(Grain)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawTexturedRect(0, 0, w, h)
            CT = SysTime()

            if CT > GrainTable.wait then
                if GrainTable.cur == GrainTable.last then
                    GrainTable.cur = 1
                    GrainTable.wait = CT + FT * 2
                else
                    GrainTable.cur = GrainTable.cur + 1
                    GrainTable.wait = CT + FT * 2
                end
            end

            if GetConVar("nv_fx_goggle_status"):GetInt() > 0 then
                DrawMaterialOverlay("models/props_c17/fisheyelens.vmt", -0.03)
            end

            BlurIntensity = GetConVar("nv_fx_blur_intensity"):GetFloat()

            if GetConVar("nv_fx_blur_status"):GetInt() > 0 then
                DrawMotionBlur(
                    0.05 * BlurIntensity,
                    0.2 * BlurIntensity,
                    0.023 * BlurIntensity
                )
            end

            if GetConVar("nv_fx_colormod_status"):GetInt() > 0 then
                Color_Tab["$pp_colour_brightness"] = CurScale * Color_Brightness
                Color_Tab["$pp_colour_contrast"] = CurScale * Color_Contrast
                DrawColorModify(Color_Tab)
            end
        else
            DrawColorModify(Clr_FLIR)
        end
    elseif not ply:Alive() then
        surface.PlaySound(sndOff)
        NV_Status = false
        hook.Remove("RenderScreenspaceEffects", "NV_FX")
    end
end

local function NV_ToggleNightVision(ply)
    if not ply:Alive() then return end
    if not ply:HasNVGs() then return end

    if NV_Status == true then
        NV_Status = false
        net.Start("MRPClientNVGsToggle")
        net.SendToServer()

        surface.PlaySound(sndOff)
        hook.Remove("RenderScreenspaceEffects", "NV_FX")
    elseif NV_Status == false and ply:GetNWInt("NVGs") > 0 then
        NV_Status = true
        net.Start("MRPClientNVGsToggle")
        net.SendToServer()

        CurScale = 0.2
        surface.PlaySound(sndOn)
        hook.Add("RenderScreenspaceEffects", "NV_FX", NV_FX)
    end
end

local keyReleased = true
hook.Add("Tick", "NVGsToggle", function()
    local inMenu = vgui.CursorVisible() or IsValid(MRP.plyInvPanel)
    if input.IsKeyDown(MRP.keybinds.nvgs) and keyReleased and not inMenu then
        keyReleased = false
        NV_ToggleNightVision(LocalPlayer())
    elseif not input.IsKeyDown(MRP.keybinds.nvgs) then
        keyReleased = true
    end
end)

local function NV_RegenerateGrainTextures(_)
    if GenInProgress then return end
    notification.AddLegacy(
        "NVScript: Grain texture generation starting in 2 seconds...",
        NOTIFY_GENERIC,
        7
    )
    GenInProgress = true

    timer.Simple(2, function()
        NV_GenerateGrainTextures()
        notification.AddLegacy(
            "NVScript: Grain texture generation finished. Check console for details.",
            NOTIFY_HINT,
            7
        )
        GenInProgress = false
    end)
end

concommand.Add("nv_generate_noise_textures", NV_RegenerateGrainTextures)

hook.Add("PostDrawOpaqueRenderables", "FLIRFX", function()
    if GetConVar("nv_type"):GetInt() < 2 or not NV_Status then return end
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    render.SetStencilReferenceValue(1)
    render.SuppressEngineLighting(true)
    FT = FrameTime()

    for _, ent in pairs(ents.GetAll()) do
        if ent:IsNPC() or ent:IsPlayer() then
            -- since there is no proper way to check if the NPC is dead, we just check if the
            -- NPC has a nodraw effect on him
            if not ent:IsEffectActive(EF_NODRAW) then
                render.SuppressEngineLighting(true)
                ent:DrawModel()
                render.SuppressEngineLighting(false)
            end
        elseif ent:GetClass() == "class C_ClientRagdoll" then
            if not ent.Int then
                ent.Int = 1
            else
                ent.Int = math.Clamp(ent.Int - FT * 0.015, 0, 1)
            end

            render.SetColorModulation(ent.Int, ent.Int, ent.Int)
            render.SuppressEngineLighting(true)
            ent:DrawModel()
            render.SuppressEngineLighting(false)
            render.SetColorModulation(1, 1, 1)
        end
    end

    render.SuppressEngineLighting(false)
    render.SetStencilReferenceValue(2)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilReferenceValue(1)
    DrawColorModify(Clr_FLIR_Ents)
    render.SetStencilEnable(false)
end)

local function NV_ResetEverything()
    -- Effects
    RunConsoleCommand("nv_fx_blur_status", "1")
    RunConsoleCommand("nv_fx_distort_status", "0")
    RunConsoleCommand("nv_fx_colormod_status", "1")
    RunConsoleCommand("nv_fx_goggle_overlay_status", "1")
    RunConsoleCommand("nv_fx_goggle_status", "0")
    RunConsoleCommand("nv_fx_noise_status", "1")
    RunConsoleCommand("nv_fx_noise_variety", "20")
    RunConsoleCommand("nv_fx_bloom_status", "0")
    RunConsoleCommand("nv_fx_blur_intensity", "1.0")
    RunConsoleCommand("nv_fx_alphapass", "5")
    -- Various features/etc
    RunConsoleCommand("nv_id_status", "0")
    RunConsoleCommand("nv_id_sens_darkness", "0.25")
    RunConsoleCommand("nv_id_reaction_time", "1")
    RunConsoleCommand("nv_etisd_status", "0")
    RunConsoleCommand("nv_etisd_sensitivity_range", "200")
    RunConsoleCommand("nv_isib_status", "0")
    RunConsoleCommand("nv_isib_sensitivity", "5")

    if NV_Status == true then
        surface.PlaySound(sndOff)
        NV_Status = false
    end

    hook.Remove("RenderScreenspaceEffects", "NV_FX")
    hook.Remove("Think", "Think")
    RunConsoleCommand("nv_toggspeed", "0.2")
    RunConsoleCommand("nv_illum_area", "512")
    RunConsoleCommand("nv_illum_bright", "1.0")
    RunConsoleCommand("nv_aim_status", "1")
    RunConsoleCommand("nv_aim_range", "200")
    RunConsoleCommand("nv_type", "1")
    LocalPlayer():ChatPrint([[Everything has been reset to default:

-/ FX \-
Color mod - ON
Blur - ON
Blur Intensity - 1.0
Distort - OFF
Green Overlay - ON
Goggle Overlay - ON
Goggle Effect - OFF
Noise - ON
Noise texture variety - 20 textures
Bloom Effect - OFF
Alpha pass - 5 times

-/ Features \-
Illumination-Detection - OFF
Eye Trace Illumination-Sensitive Detection - OFF
Illumination-Smart Intensity Balancing - OFF
ID Darkness sensitivity - 0.25
ID Reaction Time - 1 second
ETISD sensitivity Range - 200
ISIB sensitivity - 5.00

-/ Miscellaneous \-
Illuminated Area - 512 units
Illumination Brightness - 100%
Toggle Speed -  20%
AIM - ON
AIM range - 200
Vision Type - Night Vision]])
end

concommand.Add("nv_reset_everything", NV_ResetEverything)
local Vec001 = Vector(0, 0, -1)
local EP, EA, aim

local function setVectors()
    if CT > NV_TimeToVector then
        NV_Vector = math.Clamp(NV_Vector - 1, 0, 20)
        NV_TimeToVector = CT + 0.005
    end
end

local function AutoSwitch(ply)
    if not IsBrighter then
        if clr < GetConVar("nv_id_sens_darkness"):GetFloat() and not IsMade then
            timer.Create(
                "MonitorIllumTimer",
                GetConVar("nv_id_reaction_time"):GetInt(),
                1,
                function()
                    if clr < GetConVar("nv_id_sens_darkness"):GetInt() and not NV_Status then
                        RunConsoleCommand("nvg_toggle")
                    elseif NV_Status then
                        RunConsoleCommand("nvg_toggle")
                    end

                    IsMade = false
                end
            )

            IsMade = true
        else
            timer.Start("MonitorIllumMeter")
        end
    end

    if GetConVar("nv_etisd_status"):GetInt() > 0 then
        tr.start = EP
        tr.endpos = tr.start + EA * GetConVar("nv_etisd_sensitivity_range"):GetInt()
        tr.filter = ply
        trace = ute(tr)
        local lighting = render.ComputeLighting(trace.HitPos, Vec001)
        local dynamicLighting = render.ComputeDynamicLighting(trace.HitPos, Vec001)
        clr = Length(lighting - dynamicLighting) * 33

        -- If we're looking from darkness into somewhere bright
        if clr > GetConVar("nv_id_sens_darkness"):GetInt() then
            if not IsBrighter then
                if NV_Status then
                    RunConsoleCommand("nvg_toggle") -- turn off our night vision
                end

                IsBrighter = true
                timer.Stop("MonitorIllumTimer")
            else
                timer.Start("MonitorIllumTimer")
            end
        else
            IsBrighter = false
        end
    end
end

local function NV_MonitorIllumination()
    local ply = LocalPlayer()

    if ply:Alive() then
        EP, EA = ply:EyePos(), ply:EyeAngles():Forward()
        CT = CurTime()


        if NV_Status then
            Brightness = GetConVar("nv_illum_bright"):GetFloat()
            IllumArea = GetConVar("nv_illum_area"):GetInt()
            ISIBSensitivity = GetConVar("nv_isib_sensitivity"):GetInt()
            dlight = DynamicLight(ply:EntIndex())

            if dlight then
                FT = FrameTime()
                aim = GetConVar("nv_aim_status"):GetInt()

                if aim > 0 then
                    tr.start = EP
                    tr.endpos = tr.start + EA * GetConVar("nv_aim_range"):GetInt()
                    tr.filter = ply
                    trace = utrace(tr)

                    if not trace.Hit then
                        setVectors()

                        dlight.Pos = trace.HitPos + Vector(0, 0, NV_Vector)
                    else
                        setVectors()

                        dlight.Pos = trace.HitPos + Vector(0, 0, NV_Vector)
                    end
                else
                    dlight.Pos = ply:GetShootPos()
                end

                dlight.r = 125 * Brightness
                dlight.g = 255 * Brightness
                dlight.b = 125 * Brightness
                dlight.Brightness = 1

                if GetConVar("nv_isib_status"):GetInt() < 1 then
                    dlight.Size = IllumArea * CurScale
                    dlight.Decay = IllumArea * CurScale
                else
                    local lighting, dynamicLighting
                    if aim > 0 then
                        local hitpos = trace.Hitpos
                        lighting = render.ComputeLighting(hitpos, Vec001)
                        dynamicLighting = render.ComputeDynamicLighting(hitpos, Vec001)
                    else
                        lighting = render.ComputeLighting(EP, Vec001)
                        dynamicLighting = render.ComputeDynamicLighting(EP, Vec001)
                    end
                    clr = Length(lighting - dynamicLighting) * 33
                    ISIBIntens = Lerp(FT * 10, ISIBIntens, clr * ISIBSensitivity)
                    dlight.Size = math.Clamp(IllumArea * CurScale / ISIBIntens, 0, IllumArea)
                    dlight.Decay = math.Clamp(IllumArea * CurScale / ISIBIntens, 0, IllumArea)
                end

                dlight.DieTime = CT + FT * 3
            end
        end

        if GetConVar("nv_id_status"):GetInt() > 0 then
           AutoSwitch(ply)
        end
    end
end


hook.Add("Think", "NV_MonitorIllumination", NV_MonitorIllumination)

local function NV_HUDPaint()
    local ply = LocalPlayer()

    if ply:Alive() and NV_Status then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetTexture(OverlayTexture)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end
end

hook.Add("HUDPaint", "NV_HUDPaint", NV_HUDPaint)
