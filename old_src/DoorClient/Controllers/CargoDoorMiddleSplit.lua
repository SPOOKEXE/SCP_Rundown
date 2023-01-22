local TweenService = game:GetService('TweenService')

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

local defaultTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )

	self.TopCloseCFrame = self.Model.DoorTop:GetPivot()
	self.TopOpenCFrame = self.TopCloseCFrame + Vector3.new(0, 5.3, 0)

	self.BottomCloseCFrame = self.Model.DoorBottom:GetPivot()
	self.BottomOpenCFrame = self.BottomCloseCFrame - Vector3.new(0, 5.7, 0)

	local TCFValue = Instance.new('CFrameValue')
	TCFValue.Name = 'CFrameV'
	TCFValue.Changed:Connect(function()
		self.Model.DoorTop:PivotTo( TCFValue.Value )
	end)
	TCFValue.Value = self:GetAttribute('StateValue') and self.TopOpenCFrame or self.TopCloseCFrame
	TCFValue.Parent = self.Model
	self.TopCFrameValue = TCFValue

	local BCFValue = Instance.new('CFrameValue')
	BCFValue.Name = 'CFrameV'
	BCFValue.Changed:Connect(function()
		self.Model.DoorBottom:PivotTo( BCFValue.Value )
	end)
	BCFValue.Value = self:GetAttribute('StateValue') and self.BottomOpenCFrame or self.BottomCloseCFrame
	BCFValue.Parent = self.Model
	self.BottomCFrameValue = BCFValue

	self.DoorMaid:Give(TCFValue, BCFValue, function()
		self.TopCloseCFrame = nil
		self.TopOpenCFrame = nil
		self.BottomCloseCFrame = nil
		self.BottomOpenCFrame = nil
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

	local nextTopCFrame = isOpen and self.TopOpenCFrame or self.TopCloseCFrame
	TweenService:Create(self.TopCFrameValue, defaultTweenInfo, { Value = nextTopCFrame }):Play()

	local nextBottomCFrame = isOpen and self.BottomOpenCFrame or self.BottomCloseCFrame
	local BTween = TweenService:Create(self.BottomCFrameValue, defaultTweenInfo, { Value = nextBottomCFrame })
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
