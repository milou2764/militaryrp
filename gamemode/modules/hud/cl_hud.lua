local hide = {
	["CHudHealth"] = true,
	["CHudAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[name] ) then
		return false
	end
end )
