local RunService = game:GetService("RunService")

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
	self.OverlapParams = overlapParams

	self.DoorMaid:Give(RunService.Heartbeat:Connect(function()
		self:Toggle( self:IsHumanoidInSensors() )
	end))

	return self
end

function Class:IsHumanoidInSensors()
	for _, sensorPart in ipairs( self.Model.Sensors:GetChildren() ) do
		local touchingParts = workspace:GetPartBoundsInBox(sensorPart.CFrame, sensorPart.Size, self.OverlapParams)
		for _, basePart in ipairs( touchingParts ) do
			local humanoid = basePart.Parent:FindFirstChildWhichIsA('Humanoid')
			if humanoid and humanoid.Health > 0 then
				return true
			end
		end
	end
	return false
end

--[[function Class:Toggle( forceState )
	if not Class.super.Toggle(self, forceState) then
		return false
	end
	return true
end]]

--[[function Class:Demolish()
	if Class.super.Demolish(self) then
		return true
	end
	return false
end]]

return Class
