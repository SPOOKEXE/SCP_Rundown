
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Knit = require(ReplicatedStorage.Packages.Knit)
local ScanService = false
local InteractionService = false

local DoorConfigTable = ReplicatedModules.Defined.DoorConfig
local ControllerModules = {}

local DoorService = Knit.CreateService { Name = "DoorService", Client = {} }
DoorService.ActiveDoors = {}

function DoorService:CloseAllDoors()
	for Model, DoorClass in pairs( DoorService.ActiveDoors ) do
		DoorClass:Toggle(false)
	end
end

function DoorService:ReRegisterDoorSetups( DoorsUUIDs )
	warn('Re-register door proximity prompts')
	--for Model, DoorClass in pairs( DoorService.ActiveDoors ) do
	--end
end

function DoorService:SetDoorStateWithUUIDsOf( DoorsUUIDs, doorActive )
	print(DoorsUUIDs, true)
	for Model, DoorClass in pairs( DoorService.ActiveDoors ) do
		if table.find(DoorsUUIDs, DoorClass.UUID) then
			DoorClass:Toggle(doorActive)
		end
	end
end

function DoorService:SaveDoorStatesForCheckpointData()
	print('Doors; ', #DoorService.ActiveDoors)
	local ActiveDoorStateIDs = {}
	for Model, DoorClass in pairs( DoorService.ActiveDoors ) do
		if DoorClass.StateValue.Value and not table.find(ActiveDoorStateIDs, DoorClass.UUID) then
			table.insert(ActiveDoorStateIDs, DoorClass.UUID)
		end
	end
	return ActiveDoorStateIDs
end

function DoorService:RegisterDoor( DoorModel )
	local DoorConfig = DoorConfigTable:GetConfigFromID( DoorModel.Name )
	if (not DoorConfig) then
		warn('No Door Config: ', DoorModel.Name)
		return
	end

	local ControllerClass = ControllerModules[ DoorConfig.ControllerID ]
	if not ControllerClass then
		warn('No Door Controller: ', DoorModel.Name)
		return
	end

	--print( "Register Door: ", DoorModel:GetFullName())--, DoorConfig )
	local DoorModelClass = ControllerClass.New( DoorModel, DoorConfig )
	DoorModelClass:Setup()
	DoorService.ActiveDoors[ DoorModel ] = DoorModelClass
	return DoorModelClass
end

function DoorService:KnitStart()
	print(script.Name, "Start")

	for _, ControllerModule in ipairs( script:WaitForChild('Controllers'):GetChildren() ) do
		if ControllerModule:IsA('ModuleScript') then
			local ControllerClass = require(ControllerModule)
			ControllerClass.ScanService = ScanService
			ControllerClass.InteractionService = InteractionService
			ControllerModules[ControllerModule.Name] = ControllerClass
		end
	end

	local DoorsFolder = workspace:WaitForChild('Doors')
	for _, DoorModel in ipairs( DoorsFolder:GetChildren() ) do
		task.defer(function()
			DoorService:RegisterDoor( DoorModel )
		end)
	end
end

function DoorService:KnitInit()
	print(script.Name, "Init")
	ScanService = Knit.GetService("ScanService")
	InteractionService = Knit.GetService("InteractionService")
end

return DoorService
