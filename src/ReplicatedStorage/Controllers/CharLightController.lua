
local ContextActionService = game:GetService('ContextActionService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalPlayer = game:GetService('Players').LocalPlayer

local CharLightController = Knit.CreateController { Name = "CharLightController" }

CharLightController.FlashLightInstance = false

function CharLightController:OnCharacterAdded()
	if not LocalPlayer.Character then
		return
	end

	local BodyLightInstance = Instance.new('PointLight')
	BodyLightInstance.Shadows = true
	BodyLightInstance.Range = 15
	BodyLightInstance.Brightness = 0.5
	BodyLightInstance.Color = Color3.new(1, 1, 1)
	BodyLightInstance.Parent = LocalPlayer.Character:WaitForChild('HumanoidRootPart')

	local ReachLightInstance = Instance.new('SpotLight')
	ReachLightInstance.Shadows = true
	ReachLightInstance.Range = 30
	ReachLightInstance.Brightness = 1.84
	ReachLightInstance.Color = Color3.new(1, 1, 1)
	ReachLightInstance.Angle = 36
	ReachLightInstance.Parent = LocalPlayer.Character:WaitForChild('HumanoidRootPart')

	CharLightController.FlashLightInstance = ReachLightInstance
end

function CharLightController:KnitStart()
	print(script.Name, "Start")

	task.defer(function()
		CharLightController:OnCharacterAdded()
	end)

	LocalPlayer.CharacterAdded:Connect(function()
		CharLightController:OnCharacterAdded()
	end)

	ContextActionService:BindAction('FlashlightToggle', function(actionName, inputState, _)
		if actionName == 'FlashlightToggle' and inputState == Enum.UserInputState.Begin then
			if CharLightController.FlashLightInstance then
				CharLightController.FlashLightInstance.Enabled = (not CharLightController.FlashLightInstance.Enabled)
				ReplicatedAssets.Sounds.FlashlightClick:Play()
			end
		end
	end, true, Enum.KeyCode.F)

	ContextActionService:SetPosition('FlashlightToggle', UDim2.fromScale(0.7, 0))
	ContextActionService:SetDescription('FlashlightToggle', "Toggles the character's flashlight")
end

function CharLightController:KnitInit()
	print(script.Name, "Init")
end

return CharLightController

