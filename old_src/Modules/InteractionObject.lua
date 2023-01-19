
local MaidClass = require(script.Parent.Maid)

-- // Class // --
local Class = {}
Class.__index = Class

function Class.New()
	local clockTime = os.clock() -- time does not work here

	local VirtualProximityPrompt = Instance.new('ProximityPrompt')
	VirtualProximityPrompt.Name = 'VirtualProximity_'..clockTime
	VirtualProximityPrompt.HoldDuration = 0.5
	VirtualProximityPrompt.ObjectText = 'No Object Text'
	VirtualProximityPrompt.ActionText = 'No Action Text'
	VirtualProximityPrompt.ClickablePrompt = true
	VirtualProximityPrompt.MaxActivationDistance = 16
	VirtualProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	VirtualProximityPrompt.Parent = script

	local self = {
		type = 'Unknown',
		ProximityPrompt = VirtualProximityPrompt,
		Adornee = false,

		BillboardUI = false,
		OnscreenUI = false,

		__Maid = MaidClass.New(),
	}

	self.__Maid:Give(VirtualProximityPrompt)

	self.__Maid:Give(VirtualProximityPrompt.PromptShown:Connect(function()
		if self.BillboardUI then
			self.BillboardUI.Enabled = true
		end
		if self.OnscreenUI then
			self.OnscreenUI.Enabled = true
		end
	end))

	self.__Maid:Give(VirtualProximityPrompt.PromptHidden:Connect(function()
		if self.BillboardUI then
			self.BillboardUI.Enabled = false
		end
		if self.OnscreenUI then
			self.OnscreenUI.Enabled = false
		end
	end))

	setmetatable(self, Class)
	return self
end

-- Set the adornee
function Class:SetAdornee( AdorneeInstance )
	self.Adornee = AdorneeInstance
	self.ProximityPrompt.Parent = AdorneeInstance
end

-- Cleanup the maid
function Class:__Cleanup()
	if self.__Maid then
		print('cleanup maid')
		self.__Maid:Cleanup()
	end
end

-- Destroy the interaction
function Class:Destroy()
	print('destroy the interaction')
	self:__Cleanup()
	self.KeybindsChangedEvent = false
	self.__Maid = nil
	setmetatable(self, nil)
	self.Destroyed = true
end

return Class
