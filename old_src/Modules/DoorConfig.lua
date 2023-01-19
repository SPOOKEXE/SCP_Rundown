
local Module = {}

Module.Doors = {
	{
		ID = 'HeavyDoor1',
		ControllerID = 'HeavyDoor1',
		ClientControllerID = 'HeavyDoor1',
		CooldownPeriod = 4, -- MATCH WITH THE LOCAL SCRIPT'S TWEEN DURATION
	},
}

function Module:GetConfigFromID( doorID )
	for _, data in ipairs( Module.Doors ) do
		if data.ID == doorID then
			return data
		end
	end
	return nil
end

return Module
