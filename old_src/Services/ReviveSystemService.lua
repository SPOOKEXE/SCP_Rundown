
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Knit = require(ReplicatedStorage.Packages.Knit)
local ReviveSystemService = Knit.CreateService { Name = "ReviveSystemService", Client = {} }
local CheckpointService = false

function ReviveSystemService:AreAllPlayersDowned()
	for i, LocalPlayer in ipairs( Players:GetPlayers() ) do
		if not LocalPlayer:GetAttribute('IsDowned') then
			return false
		end
	end
	return true
end

function ReviveSystemService:SetPlayerDownedState( LocalPlayer, isDowned )
	print('Set Player Downed State; ' ,LocalPlayer.Name, isDowned)
	LocalPlayer:SetAttribute('IsDowned', isDowned and true or nil)
	if ReviveSystemService:AreAllPlayersDowned() then
		warn('All players are Downed!')
		--CheckpointService:RegisterNewCheckpointData()
		task.delay(4, function()
			warn('Load Last Checkpoint')
			--CheckpointService:TriggerGameOver()
			CheckpointService:LoadLastCheckpoint()
		end)
	end
end

function ReviveSystemService:GetPlayerDownedState( LocalPlayer )
	print('Get Player Downed State; ' ,LocalPlayer.Name)
	return LocalPlayer:SetAttribute('IsDowned') ~= nil
end

function ReviveSystemService:KnitStart()
	print(script.Name, 'Started')
	for _, LocalPlayer in ipairs(Players:GetPlayers()) do
		LocalPlayer:SetAttribute('IsDowned', false)
	end
	Players.PlayerAdded:Connect(function(LocalPlayer)
		LocalPlayer:SetAttribute('IsDowned', false)
	end)
end

function ReviveSystemService:KnitInit()
	print(script.Name, 'Init')
	CheckpointService = Knit.GetService('CheckpointService')
end

return ReviveSystemService

