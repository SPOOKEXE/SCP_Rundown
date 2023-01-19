
local HttpService = game:GetService('HttpService')
local TweenService = game:GetService('TweenService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local MaidClass = ReplicatedModules.Classes.Maid

local Knit = require(ReplicatedStorage.Packages.Knit)
local InteractionController = Knit.CreateController {Name = "InteractionController"}
local InteractionService = false

local Interface = false

local InteractionCache = {}

local ProximityUICache = {}

local function ToggleUIElement( UIElement, isVisible )
	if UIElement:IsA('ScreenGui') or UIElement:IsA('SurfaceGui') or UIElement:IsA('BillboardGui') then
		UIElement.Enabled = isVisible
	elseif UIElement:IsA('GuiObject') then
		UIElement.Visible = isVisible
	end
end

function InteractionController:ShowProximityUI( UIElement, UUID )
	if UIElement then
		ToggleUIElement( UIElement, true )
		ProximityUICache[UIElement] = UUID
	end
end

function InteractionController:HideProximityUI( UIElement, UUID )
	if UIElement and ProximityUICache[UIElement] == UUID then
		ToggleUIElement( UIElement, false )
		ProximityUICache[UIElement] = nil
	end
end

function InteractionController:SetupInteraction( interactionClass )
	--print(interactionClass)
	local proximityPrompt = interactionClass.ProximityPrompt :: ProximityPrompt
	interactionClass.Maid = MaidClass.New()
	interactionClass.UUID = HttpService:GenerateGUID(false)
	interactionClass.ActiveTweenMaid = false
	if interactionClass.type == 'DoorInteraction' or interactionClass.type == 'PickupInteraction' then
		interactionClass.OnscreenUI = Interface:WaitForChild('InteractionPrompt', 3)
	end
	interactionClass.Maid:Give(proximityPrompt.PromptShown:Connect(function(proximityInputType)
		InteractionController:ShowProximityUI( interactionClass.OnscreenUI, interactionClass.UUID )
		interactionClass.OnscreenUI.ObjectLabel.Text = proximityPrompt.ObjectText
		interactionClass.OnscreenUI.ActionLabel.Text = proximityPrompt.ActionText
		interactionClass.OnscreenUI.Progress.Visible = (proximityPrompt.HoldDuration > 0)
	end))
	interactionClass.Maid:Give(proximityPrompt.PromptHidden:Connect(function(proximityInputType)
		InteractionController:HideProximityUI( interactionClass.OnscreenUI, interactionClass.UUID )
	end))
	interactionClass.Maid:Give(proximityPrompt.PromptButtonHoldBegan:Connect(function( _ )
		if interactionClass.OnscreenUI and interactionClass.OnscreenUI.Progress.Visible then
			local ProgressFrame = interactionClass.OnscreenUI.Progress
			local tweenInfo = TweenInfo.new( proximityPrompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut )
			local TweenA = TweenService:Create(ProgressFrame.Bar, tweenInfo, {Size = UDim2.fromScale(1, 1)})
			interactionClass.ActiveTweenMaid = MaidClass.New()
			interactionClass.ActiveTweenMaid:Give(function()
				TweenA:Cancel()
			end)
			local intValue = Instance.new('IntValue')
			intValue.Value = 0
			intValue.Changed:Connect(function()
				ProgressFrame.Label.Text = intValue.Value..'%'
			end)
			interactionClass.ActiveTweenMaid:Give(function()
				intValue.Value = 0
				intValue:Destroy()
			end)
			ProgressFrame.Bar.Size = UDim2.fromScale(0, 1)
			TweenService:Create(intValue, tweenInfo, { Value = 100 }):Play()
			TweenA:Play()
		end
	end))
	interactionClass.Maid:Give(proximityPrompt.PromptButtonHoldEnded:Connect(function( _ )
		if interactionClass.ActiveTweenMaid then
			interactionClass.ActiveTweenMaid:Cleanup()
		end
		if interactionClass.OnscreenUI and interactionClass.OnscreenUI.Progress.Visible then
			local ProgressBar = interactionClass.OnscreenUI.Progress.Bar
			ProgressBar.Size = UDim2.fromScale(0, 1)
		end
	end))
	interactionClass.Maid:Give(function()
		InteractionController:HideProximityUI( interactionClass.OnscreenUI, interactionClass.UUID )
	end)
	table.insert(InteractionCache, interactionClass)
end

function InteractionController:RemoveInteractionFromAdornee( adorneeInstance )
	for i, activeInteraction in ipairs( InteractionCache ) do
		if activeInteraction.Adornee == adorneeInstance then
			activeInteraction.Maid:Cleanup()
			InteractionController:HideProximityUI( activeInteraction.OnscreenUI, activeInteraction.UUID )
			table.remove(InteractionCache, i)
			break
		end
	end
end

function InteractionController:KnitStart()
	print(script.Name, 'Start')
end

function InteractionController:KnitInit()
	print(script.Name, 'Init')

	Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
	Interface.InteractionPrompt.Visible = false
	Interface.InteractionPrompt.Progress.Label.Text = '0%'
	Interface.InteractionPrompt.Progress.Bar.Size = UDim2.fromScale(0, 1)

	InteractionService = Knit.GetService("InteractionService")
	InteractionService.setupInteraction:Connect(function( interactionClass )
		--print('setup interaction', interactionClass)
		InteractionController:SetupInteraction( interactionClass )
	end)

	InteractionService.removeInteraction:Connect(function( adorneeInstance )
		--print('remove interaction', interactionClass)
		InteractionController:RemoveInteractionFromAdornee( adorneeInstance )
	end)
end

return InteractionController

