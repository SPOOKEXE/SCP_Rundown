local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Knit = require(ReplicatedStorage.Packages.Knit)

local NetworkPingController = Knit.CreateController { Name = "NetworkPingController" }

local NetworkPingFunction = ReplicatedModules.Services.RemoteService:GetRemote("NetworkPing", "RemoteFunction", false)

function NetworkPingController:KnitStart()
	print(script.Name, "Start")
	NetworkPingFunction.OnClientInvoke = function(UUID)
		return UUID
	end
end

function NetworkPingController:KnitInit()
	print(script.Name, "Init")
end

return NetworkPingController
