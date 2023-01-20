local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

local ReviveSystemService = Knit.CreateService { Name = "ReviveSystemService", Client = {}, }
local GameStateService = false
local CheckpointService = false

function ReviveSystemService:AreAllPlayersDowned()
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		if not LocalPlayer:GetAttribute('IsDowned') then
			return false
		end
	end
	return true
end

function ReviveSystemService:SetPlayerDownedState( LocalPlayer, IsDowned )
	LocalPlayer:SetAttribute('IsDowned', IsDowned or nil)
	if ReviveSystemService:AreAllPlayersDowned() then
		GameStateService:ToggleGameOverScreen(true, CheckpointService:HasCompletedACheckpoint())
	end
end

function ReviveSystemService:IsPlayerDowned( LocalPlayer )
	return LocalPlayer:SetAttribute('IsDowned') or nil
end

function ReviveSystemService:KnitStart()
	print(script.Name, 'Start')

	for _, LocalPlayer in ipairs(Players:GetPlayers()) do
		task.defer(function()
			LocalPlayer:SetAttribute('IsDowned', false)
		end)
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		LocalPlayer:SetAttribute('IsDowned', false)
	end)
end

function ReviveSystemService:KnitInit()
	print(script.Name, 'Init')
	GameStateService = Knit.GetService('GameStateService')
	CheckpointService = Knit.GetService('CheckpointService')
end

return ReviveSystemService
