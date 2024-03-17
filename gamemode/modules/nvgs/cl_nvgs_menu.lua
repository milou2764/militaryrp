local nvspanel = {}
nvspanel.NVSPanelB = nil

surface.CreateFont("Default12", {
    font = "Default",
    size = 12,
    weight = 500,
    blursize = 0,
    antialias = true,
    shadow = false
})

function nvspanel.NVSPanelA(panel)
    panel:ClearControls()

    panel:AddControl("Label", {
        Text = "Main Controls"
    })

    panel:AddControl("Button", {
        Label = "Toggle Night Vision",
        Command = "nv_togg"
    })

    panel:AddControl("Slider", {
        Label = "Toggle Speed",
        Command = "nv_toggspeed",
        Type = "Float",
        Min = "0.02",
        Max = "1"
    })

    panel:AddControl("Slider", {
        Label = "Illumination Radius",
        Command = "nv_illum_area",
        Type = "Integer",
        Min = "64",
        Max = "1024"
    })

    panel:AddControl("Slider", {
        Label = "Illumination Brightness",
        Command = "nv_illum_bright",
        Type = "Float",
        Min = "0.2",
        Max = "1"
    })

    local Type = vgui.Create("DComboBox", panel)
    Type:SetText("Goggle Type")
    Type:AddChoice("Night Vision")
    Type:AddChoice("FLIR (Thermal)")

    -- param1: otherPanel
    -- param2: index
    -- param3: value
    -- param4: data
    Type.OnSelect = function(_, index, _, _)
        RunConsoleCommand("nv_type", tonumber(index))
    end

    panel:AddItem(Type)

    panel:AddControl("Label", {
        Text = "Alternate Illumination Method (AIM)"
    })

    panel:AddControl("CheckBox", {
        Label = "AIM: Status",
        Description = "",
        Command = "nv_aim_status"
    })

    panel:AddControl("Slider", {
        Label = "AIM: Range",
        Command = "nv_aim_range",
        Type = "Integer",
        Min = "50",
        Max = "300"
    })

    panel:AddControl("Label", {
        Text = "Illumination-Detection Controls"
    })

    panel:AddControl("Slider", {
        Label = "ID: Darkness sensitivity",
        Command = "nv_id_sens_darkness",
        Type = "Float",
        Min = "0.05",
        Max = "1"
    })

    panel:AddControl("Slider", {
        Label = "ID: Reaction Time",
        Command = "nv_id_reaction_time",
        Type = "Float",
        Min = "0.1",
        Max = "1.5"
    })

    panel:AddControl("CheckBox", {
        Label = "ID: Status",
        Description = "",
        Command = "nv_id_status"
    })

    panel:AddControl("Label", {
        Text = "Eye Trace Illumination-Sensitive Detection Controls"
    })

    panel:AddControl("Slider", {
        Label = "ETISD: Range",
        Command = "nv_etisd_sensitivity_range",
        Type = "Integer",
        Min = "100",
        Max = "500"
    })

    panel:AddControl("CheckBox", {
        Label = "ETISD: Status",
        Description = "",
        Command = "nv_etisd_status"
    })

    panel:AddControl("Label", {
        Text = "Illumination-Smart Intensity Balancing Controls"
    })

    panel:AddControl("Slider", {
        Label = "ISIB: sensitivity",
        Command = "nv_isib_sensitivity",
        Type = "Float",
        Min = "2",
        Max = "10"
    })

    panel:AddControl("CheckBox", {
        Label = "ISIB: Status",
        Description = "",
        Command = "nv_isib_status"
    })

    panel:AddControl("Label", {
        Text = "Night Vision FX Controls"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Distortion Effect?",
        Description = "Use Distortion Effect?",
        Command = "nv_fx_distort_status"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Blur Effect?",
        Description = "Use Blur Effect?",
        Command = "nv_fx_blur_status"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Color Mod? (Recommended)",
        Description = "Use Green Overlay Effect?",
        Command = "nv_fx_colormod_status"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Noise Effect?",
        Description = "Use Noise Effect?",
        Command = "nv_fx_noise_status"
    })

    panel:AddControl("Slider", {
        Label = "NOISE: Noise texture amount",
        Command = "nv_fx_noise_variety",
        Type = "Int",
        Min = "5",
        Max = "40"
    })

    panel:AddControl("Button", {
        Label = "NOISE: Generate textures",
        Command = "nv_generate_noise_textures"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Goggle Effect?",
        Description = "Use Camera Effect?",
        Command = "nv_fx_goggle_status"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Goggle Overlay Effect?",
        Description = "Use Goggle Effect?",
        Command = "nv_fx_goggle_overlay_status"
    })

    panel:AddControl("CheckBox", {
        Label = "FX: Use Bloom Effect?",
        Description = "Use Bloom Effect?",
        Command = "nv_fx_bloom_status"
    })

    panel:AddControl("Slider", {
        Label = "FX: Blur Effect Intensity",
        Command = "nv_fx_blur_intensity",
        Type = "Float",
        Min = "0.2",
        Max = "1.75"
    })

    panel:AddControl("Slider", {
        Label = "FX: Alpha pass amount",
        Command = "nv_fx_alphapass",
        Type = "Int",
        Min = "0",
        Max = "12"
    })

    panel:AddControl("Label", {
        Text = "Miscellaneous"
    })

    panel:AddControl("Button", {
        Label = "Reset Controls",
        Command = "nv_reset_everything"
    })
end

function nvspanel.OpenMySpawnMenu()
    if (nvspanel.NVSPanelB) then
        nvspanel.NVSPanelA(nvspanel.NVSPanelB)
    end
end

hook.Add("SpawnMenuOpen", "nvspanel.OpenMySpawnMenu", nvspanel.OpenMySpawnMenu)

local function PopulateMyMenu_NVS()
    spawnmenu.AddToolMenuOption(
        "Options",
        "NVScript",
        "Night Vision Script",
        "Client",
        "",
        "",
        nvspanel.NVSPanelA
    )
end

hook.Add("PopulateToolMenu", "PopulateMyMenu_NVS", PopulateMyMenu_NVS)
-- localizing functions that are within tables increases speed
local clr, rect, orect = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect
local vcret = vgui.Create
local W, H
local PANEL = {}

function PANEL:Init()
end

function PANEL:Paint()
    W, H = self:GetSize()
    clr(0, 0, 0, 255)
    orect(0, 0, W, H)
    clr(100, 100, 100, 150)
    rect(1, 1, W - 2, H - 2)
    clr(0, 0, 0, 255)
    rect(2, 2, W - 4, 20)
end

vgui.Register("NV_Frame", PANEL, "DFrame")
PANEL = {}

function PANEL:Paint()
    W, H = self:GetSize()
    clr(0, 0, 0, 255)
    orect(0, 0, W, H)
    clr(200, 200, 200, 100)
    rect(1, 1, W - 2, H - 2)
end

vgui.Register("NV_Outline", PANEL, "DPanel")

function NV_CretSlider(p, x, y, w, t, c, d, min, max)
    local SL = vcret("DNumSlider", p)
    SL:SetPos(x, y)
    SL:SetWidth(w)
    SL:SetText(t)
    SL:SetMin(min)
    SL:SetMax(max)
    SL:SetDecimals(d)
    SL:SetConVar(c)
    SL:SetValue(GetConvar(c):GetFloat())
end

function NV_CretText(p, x, y, t, f)
    local T = vcret("DLabel", p)
    T:SetPos(x, y)
    T:SetText(t)
    T:SetFont(f)
    T:SizeToContents()
    T:SetExpensiveShadow(1, Color(0, 0, 0, 255))
end

function NV_CretMultiChoice(p, x, y, w, h, t, cv, ch)
    local MC = vcret("DComboBox", p)
    MC:SetPos(x, y)
    MC:SetSize(w, h)
    MC:SetText(t)
    MC.ConVar = cv

    for _, v in pairs(ch) do
        MC:AddChoice(v)
    end

    MC.OnSelect = function(_, index, _, _)
        RunConsoleCommand(MC.ConVar, tonumber(index))
    end
end

function NV_CretCheckBox(p, x, y, c)
    local CB = vcret("DCheckBox", p)
    CB:SetPos(x, y)
    CB:SetConVar(c)
end

function NV_CretOutline(p, x, y, w, h)
    local O = vcret("NV_Outline", p)
    O:SetPos(x, y)
    O:SetSize(w, h)
end
-- menu back from 2011 version of this, needs revamping, will be (hopefully) revamped
-- post-release
--[[local function NV_OpenMenu()
	local Frame = vcret("NV_Frame")
	Frame:SetSize(440, 540)
	Frame:SetTitle("Night Vision Options Menu")
	Frame:Center()
	Frame:MakePopup()
	
	NV_CretText(Frame, 10, 30, "General Settings", "Default12")
	NV_CretSlider(Frame, 10, 50, 250, "NV: Toggle Speed", "nv_toggspeed", 2, 0.02, 1)
	NV_CretSlider(Frame, 10, 70, 250, "NV: Illumination Radius", "nv_illum_area", 0, 64, 2048)
	NV_CretSlider(Frame, 10, 90, 250, "NV: Brightness", "nv_illum_bright", 2, 0.2, 1)
	NV_CretMultiChoice(
        Frame,
        10,
        120,
        200,
        20,
        "NV: Vision Type",
        "nv_type",
        {"Night Vision", "FLIR Thermal Vision"}
    )
	
	NV_CretText(Frame, 262, 30, "Effect Settings", "Default12")
	
	NV_CretOutline(Frame, 260, 50, 130, 20)
	NV_CretText(Frame, 265, 54, "FX: Distortion", "Default12")
	NV_CretCheckBox(Frame, 370, 53, "nv_fx_distort_status")
	
	NV_CretOutline(Frame, 260, 80, 130, 20)
	NV_CretText(Frame, 265, 84, "FX: Color Mod", "Default12")
	NV_CretCheckBox(Frame, 370, 83, "nv_fx_colormod_status")
	
	NV_CretOutline(Frame, 260, 110, 130, 20)
	NV_CretText(Frame, 265, 114, "FX: Goggle Overlay", "Default12")
	NV_CretCheckBox(Frame, 370, 113, "nv_fx_goggle_overlay_status")
	
	NV_CretOutline(Frame, 260, 140, 130, 20)
	NV_CretText(Frame, 265, 144, "FX: Camera Effect", "Default12")
	NV_CretCheckBox(Frame, 370, 143, "nv_fx_goggle_status")
	
	NV_CretOutline(Frame, 260, 170, 130, 20)
	NV_CretText(Frame, 265, 174, "FX: Bloom", "Default12")
	NV_CretCheckBox(Frame, 370, 173, "nv_fx_bloom_status")
	
	NV_CretOutline(Frame, 260, 260, 130, 20)
	NV_CretText(Frame, 265, 264, "FX: Noise", "Default12")
	NV_CretCheckBox(Frame, 370, 263, "nv_fx_noise_status")
	
	NV_CretOutline(Frame, 260, 320, 130, 20)
	NV_CretText(Frame, 265, 324, "FX: Blur", "Default12")
	NV_CretCheckBox(Frame, 370, 324, "nv_fx_blur_status")
	NV_CretSlider(Frame, 12, 390, 250, "Blur Intensity", "nv_fx_blur_intensity", 2, 0.2, 1.75)
	
	NV_CretText(Frame, 12, 150, "AIM, ID, ISIB and ETISD Settings", "Default12")
	NV_CretOutline(Frame, 10, 170, 130, 20)
	NV_CretText(Frame, 15, 174, "AIM: Status", "Default12")
	NV_CretCheckBox(Frame, 120, 173, "nv_aim_status")
	
	NV_CretOutline(Frame, 10, 200, 130, 20)
	NV_CretText(Frame, 15, 204, "ID: Status", "Default12")
	NV_CretCheckBox(Frame, 120, 203, "nv_id_status")
	
	NV_CretOutline(Frame, 10, 230, 130, 20)
	NV_CretText(Frame, 15, 234, "ETISD: Status", "Default12")
	NV_CretCheckBox(Frame, 120, 233, "nv_etisd_status")
	
	NV_CretOutline(Frame, 10, 260, 130, 20)
	NV_CretText(Frame, 15, 264, "ISIB: Status", "Default12")
	NV_CretCheckBox(Frame, 120, 263, "nv_isib_status")
	
	NV_CretSlider(Frame, 12, 290, 250, "AIM: Range", "nv_aim_range", 0, 50, 300)
	NV_CretSlider(Frame, 12, 310, 250, "ID: Sensitivity", "nv_id_sens_darkness", 2, 0.05, 1)
	NV_CretSlider(Frame, 12, 330, 250, "ID: Reaction Time", "nv_id_reaction_time", 2, 0.1, 1.5)
	NV_CretSlider(Frame, 12, 350, 250, "ETISD: Range", "nv_etisd_sensitivity_range", 0, 100, 500)
	NV_CretSlider(Frame, 12, 370, 250, "ISIB: Sensitivity", "nv_isib_sensitivity", 2, 2, 10)
end

concommand.Add("nv_menu", NV_OpenMenu)]]
--
