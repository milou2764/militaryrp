
surface.CreateFont( "ScoreboardDefault", {
    font    = "Helvetica",
    size    = 22,
    weight    = 800
} )

surface.CreateFont( "ScoreboardDefaultTitle", {
    font    = "Helvetica",
    size    = 32,
    weight    = 800
} )

local scoreboard
local Menu
--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {
    Init = function( self )

        self.AvatarButton = self:Add( "DButton" )
        self.AvatarButton:Dock( LEFT )
        self.AvatarButton:SetSize( 40, 40 )
        self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

        self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
        self.Avatar:SetSize( 40, 40 )
        self.Avatar:SetMouseInputEnabled( false )

        self.Name = self:Add( "DLabel" )
        self.Name:Dock( FILL )
        self.Name:SetFont( "ScoreboardDefault" )
        self.Name:SetTextColor( Color( 255, 255, 255) )
        self.Name:DockMargin( 8, 0, 0, 0 )
        self.Name:SetMouseInputEnabled( true )
        self.Name.DoRightClick = function()
            if not LocalPlayer():IsAdmin() then return end
            local admin = LocalPlayer()
            local target = self.Player:Nick()
            Menu = DermaMenu()
            Menu.ban = Menu:AddOption( "Ban" )
            Menu.ban:SetIcon( "icon16/stop.png" )
            Menu.ban.DoClick = function()
                admin:ConCommand("ulx ban " .. target)
            end
            Menu.kick = Menu:AddOption( "Kick" )
            Menu.kick:SetIcon( "icon16/door_out.png" )
            Menu.kick.DoClick = function()
                admin:ConCommand("ulx kick " .. target)
            end
            Menu.bring = Menu:AddOption( "Bring" )
            Menu.bring:SetIcon( "icon16/lightning.png" )
            Menu.bring.DoClick = function()
                admin:ConCommand("ulx bring " .. target)
            end
            Menu.tp = Menu:AddOption( "Goto" )
            Menu.tp:SetIcon( "icon16/lightning_go.png" )
            Menu.tp.DoClick = function()
                admin:ConCommand("ulx goto " .. target)
            end
            Menu.noclip = Menu:AddOption( "Noclip" )
            Menu.noclip:SetIcon( "icon16/arrow_up.png" )
            Menu.noclip.DoClick = function()
                admin:ConCommand("ulx noclip " .. target)
            end
            Menu.cloak = Menu:AddOption( "Cloak" )
            Menu.cloak:SetIcon( "icon16/wand.png" )
            Menu.cloak.DoClick = function()
                admin:ConCommand("ulx cloak " .. target)
            end
            Menu.uncloak = Menu:AddOption( "Uncloak" )
            Menu.uncloak:SetIcon( "icon16/wand.png" )
            Menu.uncloak.DoClick = function()
                admin:ConCommand("ulx uncloak " .. target)
            end
            Menu.spectate = Menu:AddOption( "Spectate" )
            Menu.spectate:SetIcon( "icon16/user_gray.png" )
            Menu.spectate.DoClick = function()
                admin:ConCommand("ulx spectate " .. target)
            end
            Menu:Open()
        end


        self.Mute = self:Add( "DImageButton" )
        self.Mute:SetSize( 40, 40 )
        self.Mute:Dock( RIGHT )

        self.Ping = self:Add( "DLabel" )
        self.Ping:Dock( RIGHT )
        self.Ping:SetWidth( 50 )
        self.Ping:SetFont( "ScoreboardDefault" )
        self.Ping:SetTextColor( Color( 255, 255, 255) )
        self.Ping:SetContentAlignment( 5 )

        self.Deaths = self:Add( "DLabel" )
        self.Deaths:Dock( RIGHT )
        self.Deaths:SetWidth( 50 )
        self.Deaths:SetFont( "ScoreboardDefault" )
        self.Deaths:SetTextColor( Color( 255, 255, 255) )
        self.Deaths:SetContentAlignment( 5 )

        self.Kills = self:Add( "DLabel" )
        self.Kills:Dock( RIGHT )
        self.Kills:SetWidth( 50 )
        self.Kills:SetFont( "ScoreboardDefault" )
        self.Kills:SetTextColor( Color( 255, 255, 255) )
        self.Kills:SetContentAlignment( 5 )

        self.Regiment = self:Add( "DImage" )
        self.Regiment:Dock( RIGHT )
        self.Regiment:SetContentAlignment( 5 )

        self.Rank = self:Add( "DImage" )
        self.Rank:Dock( RIGHT )
        self.Rank:DockMargin(0, 0, 12, 0)
        self.Rank:SetSize( 30, 40 )
        self.Rank:SetContentAlignment( 5 )

        self:Dock( TOP )
        self:DockPadding( 3, 3, 3, 3 )
        self:SetHeight( 40 + 3 * 2 )
        self:DockMargin( 2, 0, 2, 2 )

        self.Name:SetText( self.Player:RPName() )

    end,

    Setup = function( self, pl )

        self.Player = pl

        self.Avatar:SetPlayer( pl )

        self:Think( self )

        self.faction = 0
        self.regiment = 0

        --local friend = self.Player:GetFriendStatus()
        --MsgN( pl, " Friend: ", friend )

    end,

    Think = function( self )

        if ( not IsValid( self.Player ) ) then
            self:SetZPos( 9999 ) -- Causes a rebuild
            self:Remove()
            return
        end

        if player_manager.GetPlayerClass(self.Player) ~= "spectator" then
            self.faction = self.Player:GetNWInt("Faction")
            self.regiment = self.Player:GetNWInt("Regiment")
            local width = MRP.Regiments[self.faction][self.regiment]["whratio"] * 40
            self.Regiment:SetSize( width, 40 )
            self.Regiment:SetImage(MRP.Regiments[self.faction][self.regiment]["insignia"])
            self.Rank:SetImage(MRP.Ranks[self.faction][self.regiment][self.Player:MRPRankID()]["shoulderrank"])
        end

        if ( self.NumKills == nil or self.NumKills ~= self.Player:Frags() ) then
            self.NumKills = self.Player:Frags()
            self.Kills:SetText( self.NumKills )
        end

        if ( self.NumDeaths == nil or self.NumDeaths ~= self.Player:Deaths() ) then
            self.NumDeaths = self.Player:Deaths()
            self.Deaths:SetText( self.NumDeaths )
        end

        if ( self.NumPing == nil or self.NumPing ~= self.Player:Ping() ) then
            self.NumPing = self.Player:Ping()
            self.Ping:SetText( self.NumPing )
        end

        --
        -- Change the icon of the mute button based on state
        --
        if ( self.Muted == nil or self.Muted ~= self.Player:IsMuted() ) then

            self.Muted = self.Player:IsMuted()
            if ( self.Muted ) then
                self.Mute:SetImage( "icon32/muted.png" )
            else
                self.Mute:SetImage( "icon32/unmuted.png" )
            end

            self.Mute.DoClick = function( _ )
                self.Player:SetMuted( not self.Muted )
            end
            self.Mute.OnMouseWheeled = function( s, delta )
                local vol = self.Player:GetVoiceVolumeScale() + ( delta / 100 * 5 )
                self.Player:SetVoiceVolumeScale( vol )
                s.LastTick = CurTime()
            end

            self.Mute.PaintOver = function( s, w, h )
                if ( not IsValid( self.Player ) ) then return end

                local a = 255 - math.Clamp( CurTime() - ( s.LastTick or 0 ), 0, 3 ) * 255
                if ( a <= 0 ) then return end

                draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, a * 0.75 ) )
                draw.SimpleText( math.ceil( self.Player:GetVoiceVolumeScale() * 100 ) .. "%", "DermaDefaultBold", w / 2, h / 2, Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

        end

        --
        -- Connecting players go at the very bottom
        --
        if ( self.Player:Team() == TEAM_CONNECTING ) then
            self:SetZPos( 2000 + self.Player:EntIndex() )
            return
        end

        --
        -- This is what sorts the list. The panels are docked in the z order,
        -- so if we set the z order according to kills they'll be ordered that way!
        -- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
        --
        self:SetZPos( ( self.NumKills * -50 ) + self.NumDeaths + self.Player:EntIndex() )

    end,

    Paint = function( self, w, h )

        if ( not IsValid( self.Player ) ) then
            return
        end

        --
        -- We draw our background a different colour based on the status of the player
        --

        if ( self.Player:Team() == TEAM_CONNECTING and not game.SinglePlayer() ) then
            draw.RoundedBox( 4, 0, 0, w, h, Color( 80, 203, 207, 160) )
            return
        end

        if ( not self.Player:Alive() ) then
            draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 160 ) )
            return
        end

        if ( self.Player:IsAdmin() ) then
            draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 0, 0, 160 ) )
            return
        end

        draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230, 160 ) )

    end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" )

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = {
    Init = function( self )

        self.Header = self:Add( "Panel" )
        self.Header:Dock( TOP )
        self.Header:SetHeight( 100 )
        self.Header:SetText( "100" )

        self.Name = self.Header:Add( "DLabel" )
        self.Name:SetFont( "ScoreboardDefaultTitle" )
        self.Name:SetTextColor( color_white )
        self.Name:Dock( TOP )
        self.Name:SetHeight( 40 )
        self.Name:SetContentAlignment( 5 )
        self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
        self.Name:SetText( "100" )

        --self.NumPlayers = self.Header:Add( "DLabel" )
        --self.NumPlayers:SetFont( "ScoreboardDefault" )
        --self.NumPlayers:SetTextColor( color_white )
        --self.NumPlayers:SetPos( 0, 100 - 30 )
        --self.NumPlayers:SetSize( 300, 30 )
        --self.NumPlayers:SetContentAlignment( 4 )

        self.Scores = self:Add( "DScrollPanel" )
        self.Scores:Dock( FILL )

    end,

    PerformLayout = function( self )

        self:SetSize( 700, ScrH() - 200 )
        self:SetPos( ScrW() / 2 - 350, 100 )

    end,

    Paint = function( self, w, h )

        --draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

    end,

    Think = function( self, w, h )

        self.Name:SetText( "BraverySoldiers" )

        --
        -- Loop through each player, and if one doesn't have a score entry - create it.
        --
        local plyrs = player.GetAll()
        for id, pl in pairs( plyrs ) do

            if ( IsValid( pl.ScoreEntry ) ) then continue end

            pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
            pl.ScoreEntry:Setup( pl )

            self.Scores:AddItem( pl.ScoreEntry )

        end

    end
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

--[[---------------------------------------------------------
    Name: gamemode:ScoreboardShow( )
    Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

    if ( not IsValid( scoreboard ) ) then
        scoreboard = vgui.CreateFromTable( SCORE_BOARD )
    end

    if ( IsValid( scoreboard ) ) then
        scoreboard:Show()
        scoreboard:MakePopup()
        scoreboard:SetKeyboardInputEnabled( false )
    end

end

--[[---------------------------------------------------------
    Name: gamemode:ScoreboardHide( )
    Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

    if ( IsValid( scoreboard ) ) then
        scoreboard:Hide()
        if IsValid(Menu) then Menu:Remove() end
    end

end

--[[---------------------------------------------------------
    Name: gamemode:HUDDrawScoreBoard( )
    Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()
end
