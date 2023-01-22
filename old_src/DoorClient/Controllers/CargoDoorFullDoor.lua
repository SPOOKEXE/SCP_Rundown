local TweenService = game:GetService('TweenService')

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

local defaultTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )

	self.CloseCFrame = self.Model.Door:GetPivot()
	self.OpenCFrame = self.CloseCFrame + Vector3.new(0, 10, 0)

	local CFValue = Instance.new('CFrameValue')
	CFValue.Name = 'CFrameV'
	CFValue.Changed:Connect(function()
		self.Model.Door:PivotTo( CFValue.Value )
	end)
	CFValue.Value = self:GetAttribute('StateValue') and self.OpenCFrame or self.CloseCFrame
	CFValue.Parent = self.Model
	self.CFrameValue = CFValue

	self.DoorMaid:Give(CFValue, function()
		self.CloseCFrame = nil
		self.OpenCFrame = nil
		self.CFrameValue = nil
	end)

	self:Update(true)

	return self
end

function Class:Update( noSound )
	if not Class.super.Update(self, noSound) then
		return false
	end

	local isOpen = self:GetAttribute('StateValue')
	local nextCFrame = isOpen and self.OpenCFrame or self.CloseCFrame

	local Tween = TweenService:Create(self.CFrameValue, defaultTweenInfo, { Value = nextCFrame })
	Tween.Completed:Connect(function()
		self:PlaySound( defaultTweenInfo.Time, nil, true )
	end)
	Tween:Play()

	if (not noSound) then
		task.delay(0.025, function()
			self:PlaySound( defaultTweenInfo.Time, isOpen, nil )
		end)
	end

	return true
end

return Class
