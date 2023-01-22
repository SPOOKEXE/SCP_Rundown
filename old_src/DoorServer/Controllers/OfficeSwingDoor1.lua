
local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	return setmetatable( BaseDoorClassModule.New(...), Class )
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
