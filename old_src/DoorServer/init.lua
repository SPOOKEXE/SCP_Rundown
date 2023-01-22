local CollectionService = game:GetService("CollectionService")

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local DoorConfigModule = ReplicatedModules.Data.DoorConfig

local SystemsContainer = {}

local DoorControllersFolder = script:WaitForChild('Controllers')

local CachedDoorControllerClasses = {}
local ActiveDoorControllers = {}

local function RemoveDoorByCondition(conditionCallback)
	local index = 1
	while index <= #ActiveDoorControllers do
		local Class = ActiveDoorControllers[index]
		if conditionCallback( Class ) then
			Class:Destroy()
			table.remove(ActiveDoorControllers, index)
		else
			index += 1
		end
	end
end

-- // Module // --
local Module = {}

function Module:RegisterDoor( DoorModel )
	-- Is the door an instance?
	if typeof(DoorModel) ~= 'Instance' then
		warn('DoorModel is not an instance. ' .. typeof(DoorModel) .. "\n" .. debug.traceback())
		return false
	end

	-- Does the door have a doorId attribute?
	local doorID = DoorModel.Name --DoorModel:GetAttribute('DoorID')

	-- does this doorId have a configuration setup?
	local ConfigData = doorID and DoorConfigModule:GetDoorConfig( doorID )
	if not ConfigData then
		warn('DoorID does not have a configuration setup: ' .. tostring(doorID))
		return false
	end

	-- Get the controller class
	local ControllerClass = false
	if ConfigData.ClientDoorClassID == 'BaseDoor' or ConfigData.DoorClassID == 'BaseDoor' then
		ControllerClass = CachedDoorControllerClasses.BaseDoor
	else
		ControllerClass = CachedDoorControllerClasses[ConfigData.DoorClassID or ConfigData.ClientDoorClassID]
	end

	if not ControllerClass then
		warn('[DOOR CONTROLLER - SERVER] No Door Controller Found: '..tostring(ConfigData.ClientDoorClassID or ConfigData.DoorClassID))
		return false
	end

	--print(DoorModel.Name, ControllerClass)
	local Class = ControllerClass.New(DoorModel, false)
	table.insert(ActiveDoorControllers, Class)
	return true, Class
end

function Module:RemoveDoorByUUID(DoorUUID)
	RemoveDoorByCondition(function(Class)
		return Class.DoorUUID == DoorUUID
	end)
end

function Module:RemoveDoorByModel(Model)
	RemoveDoorByCondition(function(Class)
		return Class.Model == Model
	end)
end

function Module:AttemptDoorInteraction( LocalPlayer, DoorModel )
	local TargetDoorClass = ActiveDoorControllers[ DoorModel ]
	if not TargetDoorClass then
		return false, 'Cannot find the door class.'
	end
	local Success, err = TargetDoorClass:OnInteractAttempt( LocalPlayer )
	return Success or false, err or 'Cannot interact with this door.'
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	-- require all the controller classes
	CachedDoorControllerClasses.BaseDoor = require(script.BaseDoor)
	for _, ControllerModule in ipairs( DoorControllersFolder:GetChildren() ) do
		CachedDoorControllerClasses[ControllerModule.Name] = require(ControllerModule)
	end

	-- Set the SystemsContainer for all cached modules
	for _, Cached in pairs( CachedDoorControllerClasses ) do
		Cached.SystemsContainer = SystemsContainer
	end

	for _, Model in ipairs( CollectionService:GetTagged("DoorInstance") ) do
		Module:RegisterDoor(Model)
	end

	CollectionService:GetInstanceAddedSignal("DoorInstance"):Connect(function(Model)
		Module:RegisterDoor(Model)
	end)
end

return Module
