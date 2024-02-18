-- sounds
local sndpath = "gmod4phun/gasmask/"

sound.Add({
    name = "GASMASK_OnOff",
    channel = CHAN_AUTO,
    volume = 0.5,
    level = 80,
    pitch = 100,
    sound = sndpath .. "unprone.wav"
})

sound.Add({
    name = "GASMASK_DrawHolster",
    channel = CHAN_AUTO,
    volume = 0.5,
    level = 80,
    pitch = 100,
    sound = sndpath .. "uni_weapon_holster.wav"
})

sound.Add({
    name = "GASMASK_Foley",
    channel = CHAN_AUTO,
    volume = 0.35,
    level = 80,
    pitch = 100,
    sound = sndpath .. "goprone_03.wav"
})

sound.Add({
    name = "GASMASK_Inhale",
    channel = CHAN_WEAPON,
    volume = 1,
    level = 120,
    pitch = {98, 102},
    sound = {sndpath .. "focus_inhale_01.wav", sndpath .. "focus_inhale_02.wav", sndpath .. "focus_inhale_03.wav", sndpath .. "focus_inhale_04.wav"}
})

sound.Add({
    name = "GASMASK_Exhale",
    channel = CHAN_WEAPON,
    volume = 1,
    level = 120,
    pitch = {98, 102},
    sound = {sndpath .. "focus_exhale_01.wav", sndpath .. "focus_exhale_02.wav", sndpath .. "focus_exhale_03.wav", sndpath .. "focus_exhale_04.wav", sndpath .. "focus_exhale_05.wav"}
})

sound.Add({
    name = "GASMASK_BreathingLoop",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = sndpath .. "gasmask_breathing_loop.wav"
})

sound.Add({
    name = "GASMASK_BreathingLoop2",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = sndpath .. "breathe_mask_loop.wav"
})

sound.Add({
    name = "GASMASK_BreathingMetroLight",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = sndpath .. "metro_gas_mask_light.wav"
})

sound.Add({
    name = "GASMASK_BreathingMetroMiddle",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = sndpath .. "metro_gas_mask_middle.wav"
})

sound.Add({
    name = "GASMASK_BreathingMetroHard",
    channel = CHAN_AUTO,
    volume = 1,
    level = 100,
    pitch = 100,
    sound = sndpath .. "metro_gas_mask_hard.wav"
})