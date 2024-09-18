
AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Player"

PLAYER.WalkSpeed			= 100		-- How fast to move when not running
PLAYER.RunSpeed				= 600		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= 0.3		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight		= false		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.MaxArmor				= 100		-- Max armor we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players
PLAYER.UseVMHands			= true		-- Uses viewmodel hands

--
-- Name: PLAYER:SetupDataTables
-- Desc: Set up the network table accessors
-- Arg1:
-- Ret1:
--
function PLAYER:SetupDataTables()
end

--
-- Name: PLAYER:Init
-- Desc: Called when the class object is created (shared)
-- Arg1:
-- Ret1:
--
function PLAYER:Init()
end

--
-- Name: PLAYER:Spawn
-- Desc: Called serverside only when the player spawns
-- Arg1:
-- Ret1:
--
function PLAYER:Spawn()
end

--
-- Name: PLAYER:Loadout
-- Desc: Called on spawn to give the player their default loadout
-- Arg1:
-- Ret1:
--
function PLAYER:Loadout()
	self.Player:Give("weapon_fists")
	self.Player:Give("gmod_tool")
	self.Player:Give("re_hands")
	self.Player:Give("wep_jack_job_drpradio")
    self.Player:Give("weapon_physgun")
    self.Player:Give("cross_arms_swep")
    self.Player:Give("cross_arms_infront_swep")
    self.Player:Give("surrender_animation_swep")
    self.Player:Give("french_salute")
    self.Player:Give("raise_your_hand")
end

function PLAYER:ViewModelChanged() end
function PLAYER:StartMove() end
function PLAYER:Move() end
function PLAYER:FinishMove() end
function PLAYER:CreateMove() end
function PLAYER:CalcView() end
function PLAYER:ShouldDrawLocal() end
function PLAYER:PreDrawViewModel() end
function PLAYER:PostDrawViewModel() end
function PLAYER:Death()
    hook.Run("MRP::PlayerDeath", self.Player)
end

function PLAYER:SetModel()

	local cl_playermodel = self.Player:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

--
-- Name: PLAYER:GetHandsModel
-- Desc: Called on player spawn to determine which hand model to use
-- Arg1:
-- Ret1: table|info|A table containing model, skin and body
--
function PLAYER:GetHandsModel()

	-- return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }

	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )

end

player_manager.RegisterClass( "player", PLAYER, nil )
