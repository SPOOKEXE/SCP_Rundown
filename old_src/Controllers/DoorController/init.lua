
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local DoorConfigTable = ReplicatedModules.Defined.DoorConfig

local Knit = require(ReplicatedStorage.Packages.Knit)

local DoorController = Knit.CreateController { Name = "DoorController" }

local ControllerFolder = script:WaitForChild('Controllers')
function DoorController:GetDoorControllerFromID( controllerID )
	return ControllerFolder:FindFirstChild( controllerID )
end

function DoorController:RegisterDoor( DoorModel )
	local Config = DoorConfigTable:GetConfigFromID( DoorModel.Name )
	if not Config then
		warn('No Door Config: ', DoorModel.Name)
		return false
	end

	local ControllerClass = ControllerFolder:FindFirstChild(Config.ClientControllerID or Config.ControllerID)
	if not ControllerClass then
		warn('No Door Controller: ', DoorModel.Name)
		return false
	end

	local Class = require(ControllerClass).New(DoorModel)
	--print(Class, getmetatable(Class))
	return true, Class
end

function DoorController:KnitStart()
	print(script.Name, "Start")
	local DoorsFolder = workspace:WaitForChild('Doors')
	for _, DoorModel in ipairs(DoorsFolder:GetChildren()) do
		task.defer(function()
			DoorController:RegisterDoor( DoorModel )
		end)
	end
end

function DoorController:KnitInit()
	print(script.Name, "Init")
end

return DoorController