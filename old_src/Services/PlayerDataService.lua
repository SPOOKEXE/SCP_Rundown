
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Knit = require(ReplicatedStorage.Packages.Knit)
local PlayerDataService = Knit.CreateService {
	Name = "PlayerDataService",
	Client = {},
}
local ReviveSystemService = false

local ColorList = { Color3.fromRGB(200, 50, 200), Color3.fromRGB(29, 91, 179), Color3.fromRGB(70, 194, 66), Color3.fromRGB(218, 214, 13) }

local AnchorState = true
function PlayerDataService:UpdateAllPlayers()
	for i, LocalPlayer in ipairs( Players:GetPlayers() ) do
		local Character = LocalPlayer.Character
		if (not Character) then
			continue
		end
		Character.PrimaryPart.Anchored = AnchorState
	end
end

function PlayerDataService:UnAnchorPlayers()
	AnchorState = false
	PlayerDataService:UpdateAllPlayers()
end

function PlayerDataService:AnchorPlayers()
	AnchorState = true
	PlayerDataService:UpdateAllPlayers()
end

function PlayerDataService:SaveCharacterData()
	print('Player States; ', #Players:GetPlayers())
	local PlayerStates = {}
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		PlayerStates[LocalPlayer.UserId] = { CFrame = LocalPlayer.Character:GetPrimaryPartCFrame() }
	end
	return PlayerStates
end

function PlayerDataService:LoadCharacterData( PlayerStates )
	print('Load Character Data; ', PlayerStates)
	for PlayerUserId, StateData in pairs( PlayerStates ) do
		local LocalPlayer = Players:GetPlayerByUserId(PlayerUserId)
		if (not LocalPlayer) then
			continue
		end
		LocalPlayer.Character:SetPrimaryPartCFrame( StateData.CFrame )
		ReviveSystemService:SetPlayerDownedState( LocalPlayer, false )
	end
end

function PlayerDataService:OnCharacterAdded( LocalPlayer, Character )
	if not Character then
		return
	end
	Character.PrimaryPart.Anchored = AnchorState
end

function PlayerDataService:OnPlayerAdded( LocalPlayer )
	LocalPlayer:SetAttribute('PlayerColor', ColorList[1] or BrickColor.Random().Color)
	table.remove(ColorList, 1)
	task.spawn(function()
		PlayerDataService:OnCharacterAdded(LocalPlayer, LocalPlayer.Character)
	end)
	LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
		PlayerDataService:OnCharacterAdded(LocalPlayer, NewCharacter)
	end)
end

function PlayerDataService:KnitStart()
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.spawn(function()
			PlayerDataService:OnPlayerAdded( LocalPlayer )
		end)
	end

	Players.PlayerAdded:Connect(function( LocalPlayer )
		PlayerDataService:OnPlayerAdded( LocalPlayer )
	end)
end

function PlayerDataService:KnitInit()
	print(script.Name, 'Init')
	ReviveSystemService = Knit.GetService('ReviveSystemService')
end

return PlayerDataService

