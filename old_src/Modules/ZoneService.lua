
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CollectionService = game:GetService('CollectionService')

local ClassesModule = require(script.Parent.Parent.Classes)

local onZoneEntered = ClassesModule.Event.New("onZoneEntered")
local onZoneLeave = ClassesModule.Event.New("onZoneLeave")

local Module = {onZoneEntered = onZoneEntered, onZoneLeave = onZoneLeave}

local whitelistParam = RaycastParams.new()
whitelistParam.FilterType = Enum.RaycastFilterType.Whitelist
whitelistParam.IgnoreWater = true

local function GetZoneModels()
	return CollectionService:GetTagged("ZoneIdentifier")
end

local function RaycastDownZone( Position )
	whitelistParam.FilterDescendantsInstances = GetZoneModels()
	local rayResult = workspace:Raycast( Position, Vector3.new(0, -10, 0), whitelistParam )
	if rayResult then
		return rayResult.Instance.Parent
	end
	return false
end

if RunService:IsServer() then

	local ActiveRegions = {}

	RunService.Heartbeat:Connect(function()
		for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
			local PrimaryPart = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
			if not PrimaryPart then
				continue
			end
			local ZoneResult = RaycastDownZone( PrimaryPart.Position )
			if (not ActiveRegions[LocalPlayer]) or ActiveRegions[LocalPlayer] ~= ZoneResult then
				if ActiveRegions[LocalPlayer] then
					onZoneLeave:Fire(LocalPlayer, ActiveRegions[LocalPlayer])
				end
				ActiveRegions[LocalPlayer] = ZoneResult
				onZoneEntered:Fire(ZoneResult)
			end
		end
	end)

	function Module:AreAllPlayersInZone( ZoneModel )
		for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
			if (not ActiveRegions[LocalPlayer]) and ActiveRegions[LocalPlayer] ~= ZoneModel then
				return false
			end
		end
		return true
	end

else

	local LocalPlayer = Players.LocalPlayer
	local ActiveRegion = false

	RunService.Heartbeat:Connect(function()
		local PrimaryPart = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
		if PrimaryPart then
			local ZoneResult = RaycastDownZone( PrimaryPart.Position )
			if (not ActiveRegion) or ActiveRegion ~= ZoneResult then
				if ActiveRegion then
					onZoneLeave:Fire(LocalPlayer, ActiveRegion)
				end
				ActiveRegion = ZoneResult
				onZoneEntered:Fire(ZoneResult)
			end
		end
	end)

end

return Module
