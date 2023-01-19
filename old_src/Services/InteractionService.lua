
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local InteractionObjectClass = ReplicatedModules.Classes.InteractionObject

local Knit = require(ReplicatedStorage.Packages.Knit)
local InteractionService = Knit.CreateService { Name = "InteractionService", Client = {} }
InteractionService.Client.setupInteraction = Knit.CreateSignal()
InteractionService.Client.removeInteraction = Knit.CreateSignal()

local InteractionObjects = {}

-- // Interaction Service // --
function InteractionService:setupGenericInteraction( adorneeInstance, callback )
	local interactionObject = InteractionObjectClass.New()
	local proximityPrompt = interactionObject.ProximityPrompt
	interactionObject:SetAdornee( adorneeInstance )
	proximityPrompt.Triggered:Connect(callback)
	table.insert(InteractionObjects, interactionObject)
	return interactionObject
end

function InteractionService:setupPickupInteraction( adorneeInstance, callback )
	local interactionObject = InteractionService:setupGenericInteraction( adorneeInstance, callback )
	interactionObject.type = 'PickupInteraction'
	local proximityPrompt = interactionObject.ProximityPrompt :: ProximityPrompt
	proximityPrompt.ObjectText = adorneeInstance.Name
	proximityPrompt.ActionText = 'Pick Up'
	InteractionService.Client.setupInteraction:FireAll( interactionObject )
	return interactionObject
end

function InteractionService:setupDoorInteraction( adorneeInstance, callback )
	local interactionObject = InteractionService:setupGenericInteraction( adorneeInstance, callback )
	interactionObject.type = 'DoorInteraction'
	local proximityPrompt = interactionObject.ProximityPrompt
	proximityPrompt.ObjectText = adorneeInstance.Name
	proximityPrompt.ActionText = 'Interact with Door'
	InteractionService.Client.setupInteraction:FireAll( interactionObject )
	return interactionObject
end

function InteractionService:destroyInteractionFromAdornee( adorneeInstance )
	InteractionService.Client.removeInteraction:FireAll( adorneeInstance )
	for index, interactClass in ipairs( InteractionObjects ) do
		if interactClass.Adornee == adorneeInstance then
			interactClass:Destroy()
			table.remove(InteractionObjects, index)
			break
		end
	end
end

function InteractionService:KnitStart()
	print(script.Name, 'Start')
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		for _, interactClass in ipairs( InteractionObjects ) do
			InteractionService.Client.setupInteraction:Fire(LocalPlayer, interactClass )
		end
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		for _, interactClass in ipairs( InteractionObjects ) do
			InteractionService.Client.setupInteraction:Fire(LocalPlayer, interactClass )
		end
	end)
end

function InteractionService:KnitInit()
	print(script.Name, 'Init')
end

return InteractionService
