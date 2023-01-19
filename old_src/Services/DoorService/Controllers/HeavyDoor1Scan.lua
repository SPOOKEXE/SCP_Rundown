
local SuperClass = require(script.Parent.BaseDoor)

local Class = { ClassName = script.Name }
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
end

function Class:Toggle( forceState : boolean )
	self.super:Toggle(forceState)
end

return Class

