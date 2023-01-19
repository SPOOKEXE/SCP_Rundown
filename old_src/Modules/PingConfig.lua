
local DoorsFolder = workspace:WaitForChild('Doors')

-- // Module // --

local Module = {}

Module.PingConfig = {
	{
		ID = 'DoorModel',
		Condition = function( Object )
			if not Object:IsDescendantOf(DoorsFolder) then
				return false
			end
			local Model = Object
			while Model.Parent ~= DoorsFolder do
				Model = Model.Parent
			end
			return true
		end,
		Icon = 'rbxassetid://9652768324',
	},
}

function Module:GetDataFromID( pingDataID )
	for i, Data in ipairs( Module.PingConfig ) do
		if Data.ID == pingDataID then
			return Data, i
		end
	end
	return nil
end

function Module:GetPingData( Object )
	for i, Data in ipairs( Module.PingConfig ) do
		if Data.Condition(Object) then
			return Data, i
		end
	end
	return nil
end

return Module
