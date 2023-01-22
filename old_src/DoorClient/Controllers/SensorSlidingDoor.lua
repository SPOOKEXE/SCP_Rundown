local TweenService = game:GetService('TweenService')

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

local defaultTweenInfo = TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )

	self.LeftCloseCFrame = self.Model.DoorLeft:GetPivot()
	self.LeftOpenCFrame = self.LeftCloseCFrame * CFrame.new(-3, 0, 0)

	self.RightCloseCFrame = self.Model.DoorRight:GetPivot()
	self.RightOpenCFrame = self.RightCloseCFrame * CFrame.new(3, 0, 0)

	local TCFValue = Instance.new('CFrameValue')
	TCFValue.Name = 'CFrameV'
	TCFValue.Changed:Connect(function()
		self.Model.DoorLeft:PivotTo( TCFValue.Value )
	end)
	TCFValue.Value = self:GetAttribute('StateValue') and self.LeftOpenCFrame or self.LeftCloseCFrame
	TCFValue.Parent = self.Model
	self.LeftCFrameValue = TCFValue

	local BCFValue = Instance.new('CFrameValue')
	BCFValue.Name = 'CFrameV'
	BCFValue.Changed:Connect(function()
		self.Model.DoorRight:PivotTo( BCFValue.Value )
	end)
	BCFValue.Value = self:GetAttribute('StateValue') and self.RightOpenCFrame or self.RightCloseCFrame
	BCFValue.Parent = self.Model
	self.RightCFrameValue = BCFValue

	self.DoorMaid:Give(TCFValue, BCFValue, function()
		self.LeftCloseCFrame = nil
		self.LeftOpenCFrame = nil
		self.RightCloseCFrame = nil
		self.RightOpenCFrame = nil
		self.TCFValue = nil
		self.BCFValue = nil
	end)

	self:Update(true)

	return self
end

function Class:Update( noSound )
	if not Class.super.Update(self, noSound) then
		return false
	end

	local isOpen = self:GetAttribute('StateValue')

	local nextLeftCFrame = isOpen and self.LeftOpenCFrame or self.LeftCloseCFrame
	TweenService:Create(self.LeftCFrameValue, defaultTweenInfo, { Value = nextLeftCFrame }):Play()

	local nextRightCFrame = isOpen and self.RightOpenCFrame or self.RightCloseCFrame
	local BTween = TweenService:Create(self.RightCFrameValue, defaultTweenInfo, { Value = nextRightCFrame })
	BTween.Completed:Connect(function()
		self:PlaySound( defaultTweenInfo.Time, nil, true )
	end)
	BTween:Play()

	if (not noSound) then
		task.delay(0.025, function()
			self:PlaySound( defaultTweenInfo.Time, isOpen, nil )
		end)
	end

	return true
end

return Class
