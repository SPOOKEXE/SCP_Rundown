local Lighting = game:GetService('Lighting')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local LightingController = Knit.CreateController { Name = "LightingController" }
local LightingService = false

function LightingController:SetBrightLighting()
	Lighting.Ambient = Color3.new(0.9, 0.9, 0.9)
end

function LightingController:SetDarkLighting()
	Lighting.Ambient = Color3.new()
end

function LightingController:KnitStart()
	print(script.Name, 'Start')
	Lighting.OutdoorAmbient = Color3.new()
	Lighting.Brightness = 3
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.ExposureCompensation = -1.43
	Lighting.ClockTime = 0
	Lighting.FogEnd = 200
	Lighting.FogColor = Color3.new()
	Lighting.Brightness = 0
	LightingController:SetDarkLighting()

	LightingService.setState:Connect(function(state)
		if state == 'bright' then
			LightingController:SetBrightLighting()
		else
			LightingController:SetDarkLighting()
		end
	end)
end

function LightingController:KnitInit()
	print(script.Name, 'Init')
	LightingService = Knit.GetService('LightingService')
end

return LightingController
