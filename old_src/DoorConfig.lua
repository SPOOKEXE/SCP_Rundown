-- SPOOK_EXE

export type ClearanceConfigTable = {
	KeyLevel : number,
	Clearance : {
		AD 	: boolean,
		EC 	: boolean,
		ET 	: boolean,
		IA 	: boolean,
		ISD : boolean,
		LD 	: boolean,
		MD 	: boolean,
		MTF : boolean,
		MaD : boolean,
		SD 	: boolean,
		ScD : boolean,
		O5 	: boolean,
	},
}

export type DoorConfigTable = {
	ID : string,
	DoorClassID : string,
	ClearanceConfig : ClearanceConfigTable | { ClearanceConfigTable }, -- can be one ClearanceConfigTable or an array of them
	CooldownPeriod : number,
	AutoClosePeriod : number,
}

-- // Module // --
local Module = { }

function Module:GetClearanceConfig( clearanceID )
	if Module.ClearanceConfig[clearanceID] then
		return Module.ClearanceConfig[clearanceID]
	end
	warn(' [DOOR HANDLER] Unable to find clearance config by ID: ', clearanceID)
	return false
end

function Module:GetDoorConfig( doorID )
	if Module.DoorConfig[doorID] then
		return Module.DoorConfig[doorID]
	end
	warn(' [DOOR HANDLER] Unable to find door config by ID: ', doorID, '\n', debug.traceback())
	return false
end

function Module:GetLevelAndDepartmentFromTool( Tool )
	if typeof(Tool) == 'Instance' then
		local LevelAttrib = Tool:GetAttribute('Level')
		local DepartAttrib = Tool:GetAttribute('Department')
		return LevelAttrib and tonumber(LevelAttrib), DepartAttrib and tonumber(DepartAttrib)
	end
	return false, false
end

function Module:IsPlayer079( LocalPlayer )
	return LocalPlayer:GetAttribute('IsSCP079')
end

function Module:HasClearance( ClearanceConfigTable, HighestLevel, Departments )
	if #ClearanceConfigTable == 0 then
		ClearanceConfigTable = { ClearanceConfigTable }
	end
	for i, ClearanceConfig in ipairs( ClearanceConfigTable ) do
		-- If they have any high enough level OR the correct department cards then allow access
		local enoughKeyLevel = (HighestLevel >= ClearanceConfig.KeyLevel)
		local hasAllowedDepartment = false
		-- Check if they have a allowed department
		for _, departmentIndex in ipairs( Departments ) do
			hasAllowedDepartment = ClearanceConfig.Clearance[departmentIndex]
			if hasAllowedDepartment then
				break
			end
		end
		--print(i, ClearanceConfig, enoughKeyLevel, hasAllowedDepartment)
		if enoughKeyLevel or hasAllowedDepartment then
			-- warn( HighestLevel and 'Level' or 'No Level', hasAllowedDepartment and 'Department' or 'No Department' )
			return true
		end
	end
	--print('cannot')
	return false
end

function Module:CanOpenDoor( LocalPlayer, DoorClass )
	--print(LocalPlayer.Name)
	if DoorClass:GetAttribute('SCP079Override') and (not Module:IsPlayer079( LocalPlayer )) then
		--print('SCP-079 override')
		return false
	elseif DoorClass:GetAttribute('ControlPanelOverride') then
		--print('Control panel override')
		return false
	end

	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA('Humanoid')
	local ClearanceConfig : ClearanceConfigTable = self.Config.ClearanceConfig

	if Humanoid and Humanoid.Health > 0 and ClearanceConfig then
		local HighestLevel = -1
		local Departments = { }

		local function CheckToolData(Tool)
			local LevelValue, DepartmentValue = Module:GetLevelAndDepartmentFromTool(Tool)
			if LevelValue and LevelValue >= HighestLevel then
				HighestLevel = LevelValue
			end
			if DepartmentValue and not table.find(Departments, DepartmentValue) then
				table.insert(Departments, DepartmentValue)
			end
		end

		-- Check all tools for their level/department values
		local ActiveTool = LocalPlayer.Backpack:FindFirstChildOfClass('Tool')
		if ActiveTool then
			CheckToolData(ActiveTool)
		end
		for _, Tool in ipairs( LocalPlayer.Backpack:GetChildren() ) do
			CheckToolData(Tool)
		end

		--print(HighestLevel, Departments, ClearanceConfig)
		return Module:HasClearance( ClearanceConfig, HighestLevel, Departments )
	end

	--print('no config - open for all')
	return (ClearanceConfig == nil) -- no config = open for all
end

Module.ClearanceConfig = {
	NoRestriction = {
		KeyLevel = 0,
		Clearance = {
			AD = true,
			EC = true,
			ET = true,
			IA = true,
			ISD = true,
			LD = true,
			MD = true,
			MTF = true,
			MaD = true,
			SD = true,
			ScD = true,
			O5 = true,
		},
	},

	L0Restriction = {
		KeyLevel = 1,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	L1Restriction = {
		KeyLevel = 1,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	L2Restriction = {
		KeyLevel = 2,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	L3Restriction = {
		KeyLevel = 3,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	L4Restriction = {
		KeyLevel = 4,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	L5Restriction = {
		KeyLevel = 5,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	L6Restriction = {
		KeyLevel = 6,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	SDRestriction = {
		KeyLevel = false,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = true,
			ScD = false,
			O5 = false,
		},
	},

	MTFRestriction = {
		KeyLevel = false,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = true,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = false,
		},
	},

	O5Restrictio = {
		KeyLevel = false,
		Clearance = {
			AD = false,
			EC = false,
			ET = false,
			IA = false,
			ISD = false,
			LD = false,
			MD = false,
			MTF = false,
			MaD = false,
			SD = false,
			ScD = false,
			O5 = true,
		},
	},

} :: { [string] : ClearanceConfigTable }

Module.DoorConfig = {
	BlastDoor1 = {
		ClearanceConfig = { Module:GetClearanceConfig( 'NoRestriction' ) },
		DoorClassID = 'BlastDoor1',
		ClientDoorClassID = 'BlastDoor1',
		CooldownPeriod = 6, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	BlastDoor2 = {
		ClearanceConfig = { Module:GetClearanceConfig( 'NoRestriction' ) },
		DoorClassID = 'BaseDoor',
		ClientDoorClassID = 'BlastDoor2',
		CooldownPeriod = 6, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	GateJuliet = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'GateJuliet',
		ClientDoorClassID = 'GateJuliet',
		CooldownPeriod = 9, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 20,
	},
	CargoDoorFullDoor = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'CargoDoorFullDoor',
		ClientDoorClassID = 'CargoDoorFullDoor',
		CooldownPeriod = 7, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	CargoDoorMiddleSplit = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'CargoDoorMiddleSplit',
		ClientDoorClassID = 'CargoDoorMiddleSplit',
		CooldownPeriod = 7, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	HatchDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'HatchDoor1',
		ClientDoorClassID = 'HatchDoor1',
		CooldownPeriod = 7, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	LockdownDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig('NoRestriction' ),
		DoorClassID = 'LockdownDoor1',
		ClientDoorClassID = 'LockdownDoor1',
		CooldownPeriod = 7, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	OfficeSwingDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'OfficeSwingDoor1',
		ClientDoorClassID = 'OfficeSwingDoor1',
		CooldownPeriod = 2, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	Q1SingleDoor = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'OfficeSwingDoor1',
		ClientDoorClassID = 'OfficeSwingDoor1',
		CooldownPeriod = 2, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	Q2SingleDoor = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'BaseDoor',
		ClientDoorClassID = 'OfficeSwingDoor1',
		CooldownPeriod = 2, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	SwingDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'OfficeSwingDoor1',
		ClientDoorClassID = 'OfficeSwingDoor1',
		CooldownPeriod = 1.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	CabinetDoor = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'CabinetDoor1',
		ClientDoorClassID = 'CabinetDoor1',
		CooldownPeriod = 1.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	LargeCabinetDoor = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'CabinetDoor1',
		ClientDoorClassID = 'CabinetDoor1',
		CooldownPeriod = 1.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	SensorSlidingDoor = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'SensorSlidingDoor',
		ClientDoorClassID = 'SensorSlidingDoor',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	KeycardDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'KeycardDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	Lv0KeycardDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'L0Restriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'KeycardDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	Lv1KeycardDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'L1Restriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'KeycardDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	Lv2KeycardDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'L2Restriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'KeycardDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	SDKeycardDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'SDRestriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'KeycardDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	MTFKeycardDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'SDRestriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'KeycardDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
	TouchpadSwingDoor1 = {
		ClearanceConfig = Module:GetClearanceConfig( 'NoRestriction' ),
		DoorClassID = 'KeycardDoor1',
		ClientDoorClassID = 'OfficeSwingDoor1',
		CooldownPeriod = 2.5, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
		AutoClosePeriod = 7,
	},
} :: { [string] : ClearanceConfigTable }

return Module
