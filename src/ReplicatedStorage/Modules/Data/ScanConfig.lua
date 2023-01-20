
local Module = {}

Module.Scans = {
	ClassX = {
		EnemiesPerWave = 12, -- incrementing count per wave; { 5, 7, 9, 11, 13, 15 }
		WaveInterval = 20, -- decrementing count per wave; { 20, 19, 18, 17 }
		ScanTypes = {
			{ {ID = 'TeamScan', NodeCount = 1} },
			--{ {ID = 'ScanCircle', NodeCount = 3} },
			--{ {ID = 'LargeScanCircle', NodeCount = 1} },
			--{ {ID = 'TeamScan', NodeCount = 2, LoseOvertime = true}, {ID = 'ScanCircle', NodeCount = 3} },
			--{ {ID = 'LargeScanCircle', NodeCount = 2}, {ID = 'TeamScan', NodeCount = 2, LoseOvertime = true} },
		},
	},

	ClassIII = {
		EnemiesPerWave = 12, -- incrementing count per wave; { 5, 7, 9, 11, 13, 15 }
		WaveInterval = 20, -- decrementing count per wave; { 20, 19, 18, 17 }
		ScanTypes = {
			{ {ID = 'TeamScan', NodeCount = 1} },
			{ {ID = 'ScanCircle', NodeCount = 3} },
			{ {ID = 'ScanCircle', NodeCount = 3} },
		},
	},

	Checkpoint = {
		EnemiesPerWave = false,
		WaveInterval = false,
		TriggerCheckpointSave = true,
		ScanTypes = {
			{ {ID = 'CheckpointScan', NodeCount = 1} }--'CheckpointScan',
		},
	}
}

function Module:GetScanFromID( ID )
	return Module.Scans[ ID ]
end

return Module
