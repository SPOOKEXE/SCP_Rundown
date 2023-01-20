
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

-- local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local CheckpointService = Knit.CreateService { Name = "CheckpointService", Client = {}, }

CheckpointService.ActiveCheckpointSaves = { }

function CheckpointService:HasCompletedACheckpoint()
	return #CheckpointService.ActiveCheckpointSaves > 0
end

function CheckpointService:CompileCheckpointData()
	local CheckpointData = {
		-- TODO: the last positions the players are attach
		-- change to 'set' positions at the checkpoint spot
		PlayerCFrames = { },

		-- TODO: all the player's downed status (true = downed)
		PlayerReviveStates = { },

		-- TODO: player's weapon datas (ammo)
		PlayerWeaponData = { },

		-- TODO: active alarms that don't require doors (error alarm > terminal code, etc)
		ActiveAlarms = { },

		-- TODO: active door scans that are active
		ActiveDoorScans = { },

		-- Enemy locations in the map
		ActiveEnemyLocations = { }, -- [EnemyType] = { { UUID, Position, EnemyHealthData }, ... }

		-- TODO: door states, all doors in this array are OPEN.
		-- all other doors will close and reset
		-- (including scan doors if the scan uuid is not in ActiveDoorScans)
		DoorStates = { },
	}

	return CheckpointData
end

function CheckpointService:LoadLastCheckpoint()
	-- TODO: load all the data back
	local LastCheckpointData = CheckpointService.ActiveCheckpointSaves[ #CheckpointService.ActiveCheckpointSaves ]
	warn('LOAD CHECKPOINT DATA; ', LastCheckpointData)
end

function CheckpointService:SaveNewCheckpoint()
	table.insert(CheckpointService.ActiveCheckpointSaves, CheckpointService:CompileCheckpointData())
end

function CheckpointService:KnitStart()
	print(script.Name, 'Start')
end

function CheckpointService:KnitInit()
	print(script.Name, 'Init')
end

return CheckpointService
