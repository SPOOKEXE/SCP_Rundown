
local TweenService = game:GetService('TweenService')
local defaultTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- // Class // --
local BaseDoorClass = require(script.Parent.BaseDoor)
local Class = setmetatable({}, BaseDoorClass)
Class.__index = Class

function Class.New(...)
	local self = setmetatable( BaseDoorClass.New(...), Class )

	self.LeftDoorCloseCFrame = self.Model.LeftDoor:GetPrimaryPartCFrame()
	self.LeftDoorOpenCFrame = self.LeftDoorCloseCFrame * CFrame.new(4, 0, 0)

	self.RightDoorCloseCFrame = self.Model.RightDoor:GetPrimaryPartCFrame()
	self.RightDoorOpenCFrame = self.RightDoorCloseCFrame * CFrame.new(-4, 0, 0)

	local LeftDoorCFrameValue = Instance.new("CFrameValue")
	LeftDoorCFrameValue.Name = "LeftDoorCFrame"
	LeftDoorCFrameValue.Changed:Connect(function()
		self.Model.LeftDoor:SetPrimaryPartCFrame( LeftDoorCFrameValue.Value )
	end)
	LeftDoorCFrameValue.Value = self.LeftDoorCloseCFrame
	LeftDoorCFrameValue.Parent = self.Model
	self.LeftDoorCFrameValue = LeftDoorCFrameValue

	local RightDoorCFrameValue = Instance.new("CFrameValue")
	RightDoorCFrameValue.Name = "LeftDoorCFrame"
	RightDoorCFrameValue.Changed:Connect(function()
		self.Model.RightDoor:SetPrimaryPartCFrame( RightDoorCFrameValue.Value )
	end)
	RightDoorCFrameValue.Value = self.RightDoorCloseCFrame
	RightDoorCFrameValue.Parent = self.Model
	self.RightDoorCFrameValue = RightDoorCFrameValue

	self:Update( true )
	self.StateValue.Changed:Connect(function()
		self:Update()
	end)

	return self
end

function Class:Update( NoSound : boolean?)

	if self._LastState == self.StateValue.Value then
		return
	end
	self._LastState = self.StateValue.Value

	print(string.format("Updated %s Tweens - %s - %s Sounds", script.Name, self.StateValue.Value and "Opened" or "Closed", NoSound and "Without" or "With"))

	if (not NoSound) then
		local SoundObject = self.Model.PrimaryPart:FindFirstChildOfClass("Sound")
		if SoundObject then
			SoundObject:Play()
		else
			warn("No Open/Close Sound found within Door; ", self.Model.Name, SoundObject)
		end
	end

	local Tween = nil
	if self.StateValue.Value then
		Tween = TweenService:Create(self.LeftDoorCFrameValue, defaultTweenInfo, { Value = self.LeftDoorOpenCFrame })
		TweenService:Create(self.RightDoorCFrameValue, defaultTweenInfo, { Value = self.RightDoorOpenCFrame }):Play()
	else
		Tween = TweenService:Create(self.LeftDoorCFrameValue, defaultTweenInfo, { Value = self.LeftDoorCloseCFrame })
		TweenService:Create(self.RightDoorCFrameValue, defaultTweenInfo, { Value = self.RightDoorCloseCFrame }):Play()
	end

	--[[Tween.Completed:Connect(function()
		self.Model.PromptNode.Sound:Stop()
	end)]]
	Tween:Play()

	--[[
		local Tween = nil
		if self.StateValue.Value then
			Tween = TweenService:Create(self.Model.PrimaryPart, defaultTweenInfo, { Position = self.OpenPosition })
		else
			Tween = TweenService:Create(self.Model.PrimaryPart, defaultTweenInfo, { Position = self.ClosePosition })
		end

		Tween.Completed:Connect(function()
			self.Model.PromptNode.Sound:Stop()
		end)
		Tween:Play()

		if (not noSound) then
			self.Model.PromptNode.Sound:Play()
		end
	]]

end

return Class
