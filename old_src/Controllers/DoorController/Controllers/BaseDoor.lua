
-- // Class // --
local Class = {}
Class.__index = Class

function Class.New( Model )
	local DoorState = Model:FindFirstChild("DoorState")
	assert( DoorState, "No DoorState BoolValue found inside the door" )
	local self = setmetatable({
		Model = Model,
		StateValue = DoorState,
		_LastState = nil,
	}, Class)
	return self
end

function Class:Update( NoSound : boolean?)
	if self._LastState == self.StateValue.Value then
		return
	end
	self._LastState = self.StateValue.Value
	print('BaseDoor - Update Door - ', NoSound and "No Sound" or "Sound")
end

return Class
