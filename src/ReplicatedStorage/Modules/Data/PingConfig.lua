
local CollectionService = game:GetService('CollectionService')

-- // Module // --
local Module = {}

Module.PingData = {

	DoorModel = {
		Icon = 'rbxassetid://9652768324',

		Condition = function( Object )
			local ActiveDoorModels = CollectionService:GetTagged('DoorModels')
			for _, ActiveDoorModel in ipairs(ActiveDoorModels) do
				if Object:IsDescendantOf(ActiveDoorModel) then
					return true
				end
			end
			return false
		end,
	},

}

function Module:GetDataFromObject(Object)
	for PingID, Data in pairs(Module.PingData) do
		if Data.Condition(Object) then
			return Data, PingID
		end
	end
	return nil
end

return Module
