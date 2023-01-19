
local Module = {}

Module.Abilities = {

	DrBone_GhostRise = {
		Name = "Ghost Rise",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		COUNT_BASE = 2,
		COUNT_PLVL = 1,

		COOLDOWN_BASE = 30,
		COOLDOWN_PLVL = 5,
	},

	DrBone_UndeadGrave = {
		Name = "Undead Grave",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		HP_BASE = 50,
		HP_PLVL = 25,

		DMG_BASE = 10,
		DMG_PLVL = 5,

		SPAWN_BASE = 0.5, -- spawning interval
		SPAWN_PLVL = 0.25,

		COOLDOWN_BASE = 30,
		COOLDOWN_PLVL = 5,
	},

	DrBone_BlackVortex = {
		Name = "Black Vortex",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 10,
		DMG_PLVL = 5,

		COOLDOWN_BASE = 30,
		COOLDOWN_PLVL = 5,
	},

	-- // Infernal Wielder // --
	InfWield_InfernoDash = {
		Name = "Inferno Dash",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		STUN_BASE = 0.25,
		STUN_PLVL = 0.25,

		RANGE_BASE = 5,
		RANGE_PLVL = 0.5,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	InfWield_InfernoVortex = {
		Name = "Inferno Vortex",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		RANGE_BASE = 5,
		RANGE_PLVL = 0.5,

		DURATION_BASE = 0.25,
		DURATION_PLVL = 0.25,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	InfWield_InfernoOutburst = {
		Name = "Inferno Outburst",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		DURATION_BASE = 0.25,
		DURATION_PLVL = 0.25,

		RANGE_BASE = 5,
		RANGE_PLVL = 0.5,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	InfWield_InfernoPillars = {
		Name = "Pillars of Inferno",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		RANGE_BASE = 5,
		RANGE_PLVL = 0.5,

		STUN_BASE = 1,
		STUN_PLVl = 0.5,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	-- // Magma Disaster // --

	MagDisast_MagSpark = {
		Name = "Magma Spark",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	MagDisast_MagPike = {
		Name = "Magma Pike",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	MagDisast_MagBomb = {
		Name = "Magma Bomb",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

	MagDisast_MagNuke = {
		Name = "Magma Nuke",
		Icon = "rbxassetid://",
		MaxLevel = 5,

		-- leveling up info
		MANA_COST = 40,
		MANA_PLVL = 20,

		DMG_BASE = 20,
		DMG_PLVL = 10,

		COOLDOWN_BASE = 15,
		COOLDOWN_PLVL = 5,
	},

}

return Module

