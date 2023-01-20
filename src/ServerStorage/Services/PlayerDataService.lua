
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local MiscConfigModule = ReplicatedModules.Data.MiscConfig

local PlayerDataService = Knit.CreateService { Name = "PlayerDataService", Client = {}, }

function PlayerDataService:OnCharacterAdded(LocalPlayer, Character)
	if not Character then
		return
	end
	print(LocalPlayer.Name, ' - character has spawned - ', Character:GetFullName())
end

function PlayerDataService:OnPlayerAdded(LocalPlayer)
	local PlayerCountIndex = #Players:GetPlayers()
	local PlayerColor = MiscConfigModule.PlayerColors[ PlayerCountIndex ] or Color3.new()
	LocalPlayer:SetAttribute('PlayerColor', PlayerColor)

	task.defer(function()
		PlayerDataService:OnCharacterAdded(LocalPlayer, LocalPlayer.Character)
	end)

	LocalPlayer.CharacterAdded:Connect(function(Character)
		PlayerDataService:OnCharacterAdded(LocalPlayer, Character)
	end)
end

function PlayerDataService:KnitStart()
	print(script.Name, 'Start')

	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.defer(function()
			PlayerDataService:OnPlayerAdded( LocalPlayer )
		end)
	end

	Players.PlayerAdded:Connect(function( LocalPlayer )
		PlayerDataService:OnPlayerAdded( LocalPlayer )
	end)
end

function PlayerDataService:KnitInit()
	print(script.Name, 'Init')
end

return PlayerDataService
