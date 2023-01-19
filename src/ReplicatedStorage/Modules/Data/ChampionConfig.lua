
local Module = {}

Module.Champions = {

	DrBones = {
		ChampionInfo = {

			Name = 'Dr. Bones',
			Icon = 'rbxassetid://',
			Bonus = 'Support',

			CharacterModelName = 'Dr.Bones',
			WeaponModel = 'MetalScythe',
			WeaponCFrameOffset = false,

			HipHeight = 3,

			Multipliers = {
				Strength = 0.9,
				Agility = 0.9,
				Intelligence = 1.2
			},
		},

		BaseStats = {

			Strength = 2, --// Health, HP Regen, Magic Resistance, Armor
			Agility = 4, --// Attack Speed, Movement Speed, Critical Chance
			Intelligence = 6, --// Max Mana, Mana Regen, Spell Amplification

			MovementSpeed = 12, -- Affected by agility and items (max 30)
			EvasionChance = 8, -- if math.random() < (EvasionChance / 100) then end
			AttackSpeed = 0.25, -- Attacks / Second
			SpellAmplification = 1, -- multiplier for bonus damage	
			BaseDamage = 7, -- base damage for attacks

			PhysicalDefense = 0,
			MagicDefense = 0,

			MaxHealth = 325, -- Minimum is 300, Maximum is 6000
			MaxMana = 170,
			-- CurrentMana = 0,
			HealthRegen = 0.05, -- % of health
			ManaRegen = 0.035 -- % of max mana

		},

		Abilities = {'DrBone_GhostRise', 'DrBone_UndeadGrave', 'DrBone_BlackVortex'},

	},

	-- // -- // -- // -- // -- // -- // --

	InfernalWielder = {
		ChampionInfo = {
			Name = 'Infernal Wielder',
			Icon = 'rbxassetid://',
			Bonus = 'Melee',

			CharacterName = 'Infernal Wielder',
			WeaponModel = 'CrescendoSoulStealer',
			WeaponBodyPart = "RightHand",
			WeaponCFrameOffset = false,

			HipHeight = 2.6,

			Multipliers = {
				Strength = 1.25,
				Agility = 0.9,
				Intelligence = 0.9
			},
		},

		BaseStats = {
			Strength = 7, --// Health, HP Regen, Magic Resistance, Armor
			Agility = 3, --// Attack Speed, Movement Speed, Critical Chance
			Intelligence = 2, --// Max Mana, Mana Regen, Spell Amplification

			MovementSpeed = 8, -- Affected by agility and items (max 30)
			EvasionChance = 6, -- if math.random() < (EvasionChance / 100) then end
			AttackSpeed = 0.3, -- Attacks / Second
			SpellAmplification = 1, -- multiplier for bonus damage	
			BaseDamage = 20, -- base damage for attacks

			PhysicalDefense = 0,
			MagicDefense = 0,

			MaxHealth = 500, -- Minimum is 300, Maximum is 6000
			MaxMana = 110,
			-- CurrentMana = 0,
			HealthRegen = 0.075, -- % of health
			ManaRegen = 0.015 -- % of max mana
		},

		Abilities = {'InfWield_InfernoDash', 'InfWield_InfernoVortex', 'InfWield_InfernoOutburst', 'InfWield_InfernoPillars'},
	},

	-- // -- // -- // -- // -- // -- // --

	MagmaDisaster = {
		ChampionInfo = {
			Name = 'Magma Disaster',
			Icon = 'rbxassetid://',
			Bonus = 'Ranged',

			CharacterName = 'Magma Disaster',
			WeaponModel = false,
			WeaponBodyPart = false,
			WeaponCFrameOffset = false,

			HipHeight = 3,

			Multipliers = {
				Strength = 0.9,
				Agility = 1.15,
				Intelligence = 1.2
			},
		},

		BaseStats = {
			Strength = 3, --// Health, HP Regen, Magic Resistance, Armor
			Agility = 5, --// Attack Speed, Movement Speed, Critical Chance
			Intelligence = 5, --// Max Mana, Mana Regen, Spell Amplification

			MovementSpeed = 12, -- Affected by agility and items (max 30)
			EvasionChance = 7, -- if math.random() < (EvasionChance / 100) then end
			AttackSpeed = 0.4, -- Attacks / Second
			SpellAmplification = 1, -- multiplier for bonus damage	
			BaseDamage = 15, -- base damage for attacks

			PhysicalDefense = 0,
			MagicDefense = 0,

			MaxHealth = 400, -- Minimum is 300, Maximum is 6000
			MaxMana = 135,
			-- CurrentMana = 0,
			HealthRegen = 0.05, -- % of health
			ManaRegen = 0.02 -- % of max mana
		},

		Abilities = {'MagDisast_MagSpark', 'MagDisast_MagPike', 'MagDisast_MagBomb', 'MagDisast_MagNuke'}
	},
}

Module.AvailableChampions = {} do
	for ID, _ in pairs(Module.Champions) do
		table.insert(Module.AvailableChampions, ID)
	end
end

return Module

