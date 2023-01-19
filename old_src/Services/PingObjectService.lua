
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local PingConfig = ReplicatedModules.Defined.PingConfig

local Knit = require(ReplicatedStorage.Packages.Knit)
local PingObjectService = Knit.CreateService {
	Name = "PingObjectService",
	Client = {},
}

PingObjectService.Client.pingObject = Knit.CreateSignal()
PingObjectService.Client.deletePing = Knit.CreateSignal()

function PingObjectService:IsInView( Origin, Target )
	local direction = CFrame.new(Origin, Target).LookVector
	local rayResult = workspace:Raycast( Origin, direction * 100)
	return (rayResult and rayResult.Instance)
end

function PingObjectService:HandleIncomingPing( LocalPlayer, Object, Position )
	if typeof(Object) == 'Instance' and typeof(Position) == 'Vector3' then
		local PingData = PingConfig:GetPingData( Object )
		local PrimaryPartPosition = LocalPlayer.Character.PrimaryPart.Position
		if PingData and ReplicatedModules.Utility.Debounce:Debounce(LocalPlayer.Name..'PingDebounce', 0.5) and PingObjectService:IsInView( PrimaryPartPosition, Position ) and PingData then
			PingObjectService.Client.pingObject:FireAll( LocalPlayer, Object, PingData.ID, Position )
		end
	else
		PingObjectService.Client.deletePing:FireAll( LocalPlayer )
	end
end

function PingObjectService:KnitStart()
	PingObjectService.Client.pingObject:Connect(function(LocalPlayer, Object, Position)
		PingObjectService:HandleIncomingPing( LocalPlayer, Object, Position )
	end)
end

function PingObjectService:KnitInit()

end

return PingObjectService
