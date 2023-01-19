
local SuperClass = require(script.Parent.BaseDoor)

local Class = { ClassName = script.Name, ScanService = false, InteractionService = false }
Class.__index = function(self, index)
	return rawget(self, index) or rawget(getmetatable(self), index) or self.super[index]
end

function Class.New(...)
	local self = { super = SuperClass.New(...) }
	setmetatable(self, Class)
	return self
end

function Class:CheckScanTrigger() -- returns false if scan is not completed.
	return self.super:CheckScanTrigger()
end

function Class:CanOpen()
	return self.super:CanOpen()
end

function Class:Setup()
	self.super:Setup()
	if self.ScanClass then
		local interactionClass = Class.InteractionService:setupDoorInteraction(self.Model.Node, function( _ )
			print("Start ", self.ScanConfig.ID, "Alarm")
			Class.InteractionService:destroyInteractionFromAdornee( self.Model.Node )
			Class.ScanService:StartScan(self.ScanClass, function(successful : boolean)
				if successful then
					local secondInteractionClass = Class.InteractionService:setupDoorInteraction(self.Model.Node, function( _ )
						Class.InteractionService:destroyInteractionFromAdornee( self.Model.Node )
						self.StateValue.Value = true
					end)
					secondInteractionClass.ProximityPrompt.ActionText = "Open Door"
					secondInteractionClass.ProximityPrompt.ObjectText = self.Model.Name
				end
			end)
		end)
		interactionClass.ProximityPrompt.ActionText = "Start Door Alarm Scan"
		interactionClass.ProximityPrompt.ObjectText = self.ScanConfig.ID
		interactionClass.ProximityPrompt.HoldDuration = 1
	else
		local InteractionClasses = {}
		local function UpdateProximities()
			for _, interactionClass in ipairs( InteractionClasses ) do
				interactionClass.ProximityPrompt.ActionText = self.StateValue.Value and "Close Door" or "Open Door"
			end
		end
		local function ProximityTriggered()
			for _, interactionClass in ipairs( InteractionClasses ) do
				interactionClass.ProximityPrompt.Enabled = false
			end
			self:Toggle()
			task.defer(UpdateProximities)
			task.wait(self.Config.CooldownPeriod)
			for _, interactionClass in ipairs( InteractionClasses ) do
				interactionClass.ProximityPrompt.Enabled = true
			end
		end
		for _, ButtonPart in ipairs( self.Model.Buttons:GetChildren() ) do
			local InteractionObject = Class.InteractionService:setupDoorInteraction(ButtonPart, ProximityTriggered)
			InteractionObject.ProximityPrompt.ObjectText = self.Model.Name
			InteractionObject.ProximityPrompt.HoldDuration = 0
			table.insert(InteractionClasses, InteractionObject)
		end
	end

end

function Class:Toggle( forceState : boolean )
	self.super:Toggle(forceState)
end

return Class

