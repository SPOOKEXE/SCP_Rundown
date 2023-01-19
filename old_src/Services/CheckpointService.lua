
--[[
	TODO:
	Save active alarms
	Save doors up to previous checkpoint that are completed
		(have a table of UUIDs for doors that need to stay open,
		then have a table for current finished doors and reset those doors
		when restarting from last checkpoint)

]]

local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Knit = require(ReplicatedStorage.Packages.Knit)
local DoorService = false
local ScanService = false
local PlayerDataService = false

local CheckpointService = Knit.CreateService {
	Name = "CheckpointService",
	Client = {},
}

CheckpointService.CheckpointData = { ActiveCheckpoints = {} }

function CheckpointService:GetActiveData()
	local Data = CheckpointService.CheckpointData.ActiveCheckpoints
	return Data[#Data]
end

function CheckpointService:RegisterNewCheckpointData()
	print("Save Checkpoint: Compile all open doors / open boxes / etc into a table and save it.")
	local DoorUUIDs = DoorService:SaveDoorStatesForCheckpointData()
	local PlayerStates = PlayerDataService:SaveCharacterData()
	local CompiledData = { DoorUUIDs = DoorUUIDs, PlayerStates = PlayerStates }
	table.insert(CheckpointService.CheckpointData.ActiveCheckpoints, CompiledData)
	warn('New Checkpoint Data; ', CompiledData)
end

function CheckpointService:LoadLastCheckpoint()
	warn('Loading Checkpoint Data')
	DoorService:CloseAllDoors()
	ScanService:ResetActiveScanClasses()
	local CheckpointData = CheckpointService:GetActiveData()
	if CheckpointData then
		DoorService:SetDoorStateWithUUIDsOf( CheckpointData.DoorUUIDs, true )
		DoorService:ReRegisterDoorSetups()
		PlayerDataService:LoadCharacterData( CheckpointData.PlayerStates )
	end
end

function CheckpointService:KnitStart()
	print(script.Name, "Start")
	task.delay(3, function()
		CheckpointService:RegisterNewCheckpointData()
		PlayerDataService:UnAnchorPlayers()
	end)

	local testTrigger = Instance.new('BindableEvent')
	testTrigger.Name = 'TriggerLastCheckpoint'
	testTrigger.Parent = script

	testTrigger.Event:Connect(function()
		if not ReplicatedModules.Utility.Debounce('CheckpointReset', 2) then
			return
		end
		CheckpointService:LoadLastCheckpoint()
	end)

end

function CheckpointService:KnitInit()
	print(script.Name, "Init")
	DoorService = Knit.GetService("DoorService")
	ScanService = Knit.GetService("ScanService")
	PlayerDataService = Knit.GetService('PlayerDataService')
end

return CheckpointService


