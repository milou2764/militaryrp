
MRP.GasDamage = DamageInfo()
MRP.GasDamage:SetDamage( 1 )
MRP.GasDamage:SetDamageType( DMG_NERVEGAS )

game.AddAmmoType( {
    name = "5.56x45MM NATO",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 2000,
    minsplash = 5,
    maxsplash = 15
} )
game.AddAmmoType( {
    name = "5.56x45MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 2000,
    minsplash = 5,
    maxsplash = 15
} )

game.AddAmmoType( {
    name = "9x19MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_NONE,
    force = 1000,
    minsplash = 5,
    maxsplash = 10
} )
game.AddAmmoType( {
    name = ".45 ACP",
    dmgtype = DMG_BULLET,
    tracer = TRACER_NONE,
    force = 1500,
    minsplash = 5,
    maxsplash = 10
} )
game.AddAmmoType( {
    name = "12 Gauge",
    dmgtype = DMG_BULLET,
    tracer = TRACER_NONE,
    force = 1500,
    minsplash = 2,
    maxsplash = 7
} )
game.AddAmmoType( {
    name = "7.62x51MM",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 3000,
    minsplash = 5,
    maxsplash = 15
} )
game.AddAmmoType( {
    name = "7.62x39MM M43",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 3000,
    minsplash = 5,
    maxsplash = 15
} )
game.AddAmmoType( {
    name = "7.62x54MM R",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 3000,
    minsplash = 5,
    maxsplash = 15
} )
game.AddAmmoType( {
    name = ".50 BMG",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 4000,
    minsplash = 5,
    maxsplash = 20
} )
game.AddAmmoType( {
    name = ".357 Magnum",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE_AND_WHIZ,
    force = 4000,
    minsplash = 5,
    maxsplash = 20
} )
game.AddAmmoType( {
    name = "90MM HESH",
    dmgtype = DMG_BLAST,
    tracer = TRACER_NONE,
    force = 10000,
    minsplash = 20,
    maxsplash = 50
} )
