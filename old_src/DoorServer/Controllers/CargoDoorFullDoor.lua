
local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )

	for _, ClickDetector in ipairs( self.Model.Buttons:GetDescendants() ) do
		if ClickDetector:IsA('ClickDetector') then
			self.DoorMaid:Give(ClickDetector.MouseClick:Connect(function()
				self:Toggle()
			end))
		end
	end

	return self
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
