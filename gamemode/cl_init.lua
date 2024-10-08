GM.Name = "MilitaryRP"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"
DeriveGamemode("sandbox")
include("player_class/player.lua")
include("player_class/spectator.lua")
include("lib/sh_log.lua")
include("config/config.lua")
include("config/cl_config.lua")
include("config/sh_debug_state.lua")
include("config/ammotypes.lua")
include("vgui/misc.lua")

local function LoadModules()
    local root = GM.FolderName .. "/gamemode/modules/"
    local _, folders = file.Find(root .. "*", "LUA")

    local activatedMods = {}

    for k, folder in pairs(folders) do
        if not MRP.DisabledModules[folder] then
            activatedMods[k] = folder
        end
    end

    for _, folder in pairs(activatedMods) do
        for _, File in SortedPairs(file.Find(root .. folder .. "/sh_*.lua", "LUA"), true) do
            if File ~= "sh_interface.lua" then
                include(root .. folder .. "/" .. File)
            end
        end

        for _, File in SortedPairs(file.Find(root .. folder .. "/cl_*.lua", "LUA"), true) do
            if File ~= "cl_interface.lua" then
                include(root .. folder .. "/" .. File)
            end
        end
    end
end

LoadModules()

function GM:CreateClientsideRagdoll(entity, ragdoll)
    if entity:IsPlayer() then
        ragdoll:SetNoDraw(true)
        --local userid = entity:UserID()
        --unmountGear(userid)
    end
end

net.Receive("MRPPlayerSpawn", function()
    local target = net.ReadEntity()

    hook.Call("MRPPlayerSpawn", nil, target)
end)

hook.Add("InitPostEntity", "MRPInitPostEntity", function()
    local firstTimeConnecting = file.Open("mrp/firsttime.txt", "r", "DATA")

    if firstTimeConnecting then
        firstTimeConnecting:Close()

        return
    else
        firstTimeConnecting = file.Open("mrp/firsttime.txt", "w", "DATA")
        firstTimeConnecting:Write("1")
        firstTimeConnecting:Close()
        local panel = vgui.Create("Panel")
        panel:SetSize(ScrW(), ScrH())

        function panel:Paint(width, height)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, width, height)
        end

        panel:MakePopup()
        local label = vgui.Create("DLabel", panel)
        label:SetFont("DermaLarge")
        label:SetTextColor(Color(255, 255, 255, 255))
        label:SetText("C'est la première fois que vous lancez une partie en militaryRP," ..
                      " nous allons configurer vos touches s'il vous plaît.")
        label:SizeToContents()
        label:Center()
        local button = vgui.Create("DButton", panel)
        button:SetPos(ScrW() / 2 - 100, ScrH() / 2 + 100)
        button:SetSize(200, 50)
        button:SetText("Continuer")

        button.DoClick = function()
            label:Remove()
            button:Remove()
            label = vgui.Create("DLabel", panel)
            label:SetFont("DermaLarge")
            label:SetTextColor(Color(255, 255, 255, 255))
            label:SetText("Touche pour ouvrir l'inventaire : ")
            label:SizeToContents()
            label:SetPos(200, ScrH() / 2 - 100)
            local key = vgui.Create("MRPBinder", panel)
            key:SetPos(ScrW() / 2 + 100, ScrH() / 2 - 100)
            key:SetSize(200, 50)
            key:SetValue(MRP.keybinds.inventory)

            key.OnChange = function(_, value)
                MRP.keybinds.inventory = value
                file.Write("mrp/keybinds.txt", util.TableToJSON(MRP.keybinds))
            end

            local gasmask = vgui.Create("DLabel", panel)
            gasmask:SetFont("DermaLarge")
            gasmask:SetTextColor(Color(255, 255, 255, 255))
            gasmask:SetText("Touche pour mettre le masque à gaz : ")
            gasmask:SizeToContents()
            gasmask:SetPos(200, ScrH() / 2 - 50)
            local gasmaskKey = vgui.Create("MRPBinder", panel)
            gasmaskKey:SetPos(ScrW() / 2 + 100, ScrH() / 2 - 50)
            gasmaskKey:SetSize(200, 50)
            gasmaskKey:SetValue(MRP.keybinds.gasmask)

            gasmaskKey.OnChange = function(_, value)
                MRP.keybinds.gasmask = value
                file.Write("mrp/keybinds.txt", util.TableToJSON(MRP.keybinds))
            end

            local nvgs = vgui.Create("DLabel", panel)
            nvgs:SetFont("DermaLarge")
            nvgs:SetTextColor(Color(255, 255, 255, 255))
            nvgs:SetText("Touche pour mettre les lunettes de vision nocturne : ")
            nvgs:SizeToContents()
            nvgs:SetPos(200, ScrH() / 2)
            local nvgsKey = vgui.Create("MRPBinder", panel)
            nvgsKey:SetPos(ScrW() / 2 + 100, ScrH() / 2)
            nvgsKey:SetSize(200, 50)
            nvgsKey:SetValue(MRP.keybinds.nvgs)

            nvgsKey.OnChange = function(_, value)
                MRP.keybinds.nvgs = value
                file.Write("mrp/keybinds.txt", util.TableToJSON(MRP.keybinds))
            end

            local done = vgui.Create("DButton", panel)
            done:SetPos(ScrW() / 2 - 100, ScrH() / 2 + 100)
            done:SetSize(200, 50)
            done:SetText("Terminer")

            done.DoClick = function()
                panel:Remove()
            end
        end
    end
end)

--[[---------------------------------------------------------
   Name: gamemode:HUDDrawTargetID( )
   Desc: Draw the target id (the name of the player you're currently looking at)
-----------------------------------------------------------]]
function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if not trace.Hit then return end
	if not trace.HitNonWorld then return end

	local text = "ERROR"
	local font = "TargetID"

	if ( trace.Entity:IsPlayer() ) then
        local ply = trace.Entity
        local faction = ply:MRPFaction()
        local regiment = ply:MRPRegiment()
        local rid = ply:GetNWInt("Rank")
        local rank = MRP.Ranks[faction][regiment][rid]["short"]
		text = rank .. " - " .. ply:RPName()
	else
		--text = trace.Entity:GetClass()
		return
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = input.GetCursorPos()

	if MouseX == 0 and MouseY == 0 or not vgui.CursorVisible() then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

	y = y + h + 5

	-- Draw the health
	text = trace.Entity:Health() .. "%"
	font = "TargetIDSmall"

	surface.SetFont( font )
	w, h = surface.GetTextSize( text )
	x = MouseX - w / 2

	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end
