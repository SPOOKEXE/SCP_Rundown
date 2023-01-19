
local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local LightingService = Knit.CreateService { Name = "LightingService", Client = {} }
LightingService.Client.setState = Knit.CreateSignal()

function LightingService:SetState(newState)
	LightingService.Client.setState:FireAll(newState)
end

function LightingService:KnitStart()
	print(script.Name, 'Start')
	LightingService:SetState('bright')
end

function LightingService:KnitInit()
	print(script.Name, 'Init')
end

return LightingService
