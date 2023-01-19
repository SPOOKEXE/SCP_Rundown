local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Knit = require(ReplicatedStorage.Packages.Knit)

local NetworkPingFunction = ReplicatedModules.Services.RemoteService:GetRemote("NetworkPing", "RemoteFunction", false)

local __PingData = {}

-- // Local Handler // --
local function Update(LocalPlayer)
	local requestThread = coroutine.create(function()
		local GUID = HttpService:GenerateGUID(false)
		local StartClock = os.clock()
		local returnedGUID = nil
		local success, err = pcall(function()
			returnedGUID = NetworkPingFunction:InvokeClient(LocalPlayer, GUID)
		end)
		if not success then
			warn(err)
			return
		end
		if (GUID == returnedGUID) then -- Validate
			__PingData[LocalPlayer] = os.clock() - StartClock
		end
	end)
	task.delay(3, coroutine.close, requestThread)
	coroutine.resume(requestThread)
end

-- // Service // --
local NetworkPingService = Knit.CreateService { Name = "NetworkPingService", Client = {} }

function NetworkPingService:Get( LocalPlayer )
	return __PingData[LocalPlayer] or 0.1 -- 100ms
end

function NetworkPingService:KnitStart()
	print(script.Name, "Start")
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.delay(1, Update, LocalPlayer)
	end
	Players.PlayerAdded:Connect(function( LocalPlayer )
		task.delay(1, Update, LocalPlayer)
	end)
	Players.PlayerRemoving:Connect(function( LocalPlayer )
		__PingData[LocalPlayer] = nil
	end)
	task.spawn(function()
		while task.wait(0.75) do
			for _, LocalPlayer in pairs(Players:GetPlayers()) do
				task.spawn(Update, LocalPlayer)
			end
		end
	end)
end

function NetworkPingService:KnitInit()
	print(script.Name, "Init")
end

return NetworkPingService
