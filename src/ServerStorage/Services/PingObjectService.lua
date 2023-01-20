
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local PingConfigModule = ReplicatedModules.Defined.PingConfig

local Knit = require(ReplicatedStorage.Knit)
local PingObjectService = Knit.CreateService { Name = "PingObjectService", Client = {}, }

PingObjectService.Client.CreatePing = Knit.CreateSignal()
PingObjectService.Client.RemovePing = Knit.CreateSignal()

function PingObjectService:IsPositionInRaycastView( OriginPosition, TargetPosition )
	local direction = CFrame.lookAt(OriginPosition, TargetPosition).LookVector
	local rayResult = workspace:Raycast( OriginPosition, direction * 100)
	return (rayResult and rayResult.Instance)
end

function PingObjectService:HandleIncomingPing( LocalPlayer, Reference, Position )
	if typeof(Reference) == 'Instance' and typeof(Position) == 'Vector3' then
		local PingData, PingID = PingConfigModule:GetDataFromId( Reference )
		if not PingData then
			return
		end
		local PrimaryPartPosition = LocalPlayer.Character.PrimaryPart.Position
		local Debounce = ReplicatedModules.Utility.Debounce:Debounce(LocalPlayer.Name..'PingDebounce', 0.5)
		if Debounce and PingObjectService:IsPositionInRaycastView( PrimaryPartPosition, Position ) then
			PingObjectService.Client.CreatePing:FireAll( LocalPlayer, Reference, PingID, Position )
		end
	else
		PingObjectService.Client.RemovePing:FireAll( LocalPlayer )
	end
end

function PingObjectService:KnitStart()
	print(script.Name, 'Start')
	PingObjectService.Client.CreatePing:Connect(function(LocalPlayer, Reference, Position)
		PingObjectService:HandleIncomingPing( LocalPlayer, Reference, Position )
	end)
end

function PingObjectService:KnitInit()
	print(script.Name, 'Init')
end

return PingObjectService
