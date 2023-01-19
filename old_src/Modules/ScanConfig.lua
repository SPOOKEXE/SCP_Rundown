
local Module = {}

Module.Scans = {
	{
		ID = 'ClassX',
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
	{
		ID = 'ClassIII',
		EnemiesPerWave = 12, -- incrementing count per wave; { 5, 7, 9, 11, 13, 15 }
		WaveInterval = 20, -- decrementing count per wave; { 20, 19, 18, 17 }
		ScanTypes = {
			{ {ID = 'TeamScan', NodeCount = 1} },
			{ {ID = 'ScanCircle', NodeCount = 3} },
			{ {ID = 'ScanCircle', NodeCount = 3} },
		},
	},
	{
		ID = 'CheckpointScan',
		EnemiesPerWave = false,
		WaveInterval = false,
		TriggerCheckpointSave = true,
		ScanTypes = {
			{ {ID = 'CheckpointScan', NodeCount = 1} }--'CheckpointScan',
		},
	}
}

function Module:GetScanFromID( scanID )
	for _, scanData in ipairs( Module.Scans ) do
		if scanData.ID == scanID then
			return scanData
		end
	end
	return nil
end

return Module
