local Players = game:GetService('Players')
local TeleportService = game:GetService('TeleportService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

local GameStateService = Knit.CreateService { Name = "GameStateService", Client = {}, }
local CheckpointService = false

GameStateService.IsGameOverScreenVisible = false
GameStateService.HasCompletedExtraction = false
GameStateService.AllowCheckpointReset = false

function GameStateService:ToggleGameOverScreen(Enabled, AllowCheckpoint)
	if GameStateService.IsGameOverScreenVisible then
		return
	end
	print('Toggle Game Over Screen; ', Enabled)
	GameStateService.IsGameOverScreenVisible = Enabled
	GameStateService.AllowCheckpointReset = AllowCheckpoint or false
end

function GameStateService:OnCheckpointResetOption()
	if (not GameStateService.IsGameOverScreenVisible) or (not GameStateService.AllowCheckpointReset) then
		return
	end
	print('Load last checkpoint')
	task.defer(function()
		CheckpointService:LoadLastCheckpoint()
	end)
	GameStateService:ToggleGameOverScreen(false)
end

function GameStateService:OnTeleportToLobbyOption()
	TeleportService:TeleportPartyAsync(
		game.PlaceId,
		Players:GetPlayers()
	)
end

function GameStateService:OnExtractionCompleted()
	if GameStateService.HasCompletedExtraction then
		return
	end
	GameStateService.HasCompletedExtraction = true

	warn('Extraction Completed - Reward players and teleport to lobby')
	-- TODO: REWARD PLAYERS
	GameStateService:ToggleGameOverScreen(true, false)
end

function GameStateService:KnitStart()
	print(script.Name, 'Start')
end

function GameStateService:KnitInit()
	print(script.Name, 'Init')
	CheckpointService = Knit.GetService('CheckpointService')
end

return GameStateService
