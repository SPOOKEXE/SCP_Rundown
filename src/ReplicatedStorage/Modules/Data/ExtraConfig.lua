

local Module = {}

Module.AbilityLevelRequirements = { 2, 5, 10 }
Module.MaxChampionLevel = 25

Module.RarityDisplay = {
	Common = {
		Text = 'Common',
		TextColor3 = Color3.fromRGB(255,255,255),
	},
	Uncommon = {
		Text = 'Uncommon',
		TextColor3 = Color3.fromRGB(49, 164, 0),
	},
	Rare = {
		Text = 'Rare',
		TextColor3 = Color3.fromRGB(0, 90, 164),
	},
	Epic = {
		Text = 'Epic',
		TextColor3 = Color3.fromRGB(77, 0, 164),
	},
	Legendary = {
		Text = 'Legendary',
		TextColor3 = Color3.fromRGB(208, 121, 0),
	},
}

function Module:GetExperienceForLevelUp(Level)
	return math.floor((Level * 50) + 30 * math.pow(1.15, Level-1))
end

return Module

