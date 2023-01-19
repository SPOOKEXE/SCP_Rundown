
--[[
	<stroke color="#000000" thickness="2"><font color="rgb(255,0,0)">Class II - Diminished</font> - Door Scan</stroke>
]]

local PathfindingService = game:GetService('PathfindingService')
local Debris = game:GetService('Debris')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Packages.Knit)

local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local MaidClass = ReplicatedModules.Classes.Maid

local ScanController = Knit.CreateController { Name = "ScanController" }
local ScanService = false

local basePart = Instance.new('Part')
basePart.Name = 'WaypointNode'
basePart.Anchored = true
basePart.Transparency = 0.8
basePart.Size = Vector3.new(1, 1, 1)
basePart.CanCollide = false
basePart.CanQuery = false
basePart.CanTouch = false

type func = (...any?) -> (...any?)
local activeWormCache = {}
function ScanController:RunWormToPosition(wormuid, origin, pathwaypoints, goal) : string
	activeWormCache[wormuid] = true
	for i, waypoint in ipairs( pathwaypoints ) do
		local waypointPosition = waypoint.Position
		local nodePart = basePart:Clone()
		nodePart.Color = BrickColor.random().Color
		nodePart.Position = waypointPosition
		nodePart.Parent = workspace
		Debris:AddItem(nodePart, 5 + (i * 0.25 * 0.5))
		if activeWormCache[wormuid] then
			task.wait(0.25)
		end
	end
	activeWormCache[wormuid] = nil
end

function ScanController:ForceCompleteWorm(wormuid : string)
	activeWormCache[wormuid] = nil
end

local activePortalMaidCache = {}
function ScanController:CreateScanPortal(PortalUID, Model, PositionCFrame)
	Model = Model:Clone()
	for _, item in ipairs( Model.PrimaryPart:GetChildren() ) do
		item:Destroy()
	end
	Model:SetPrimaryPartCFrame(PositionCFrame)
	Model.Parent = workspace

	local maidInstance = MaidClass.New()
	maidInstance:Give(Model)
	activePortalMaidCache[PortalUID] = maidInstance
end

function ScanController:DestroyScanPortal(PortalUID, Model, Position)
	if activePortalMaidCache[PortalUID] then
		activePortalMaidCache[PortalUID]:Cleanup()
	end
	activePortalMaidCache[PortalUID] = nil
end

function ScanController:KnitStart()
	print(script.Name, "Start")

	ScanService.onScanStarted:Connect(function()
		print("Scan Sequence Started")
	end)

	ScanService.onScanWormCreated:Connect(function(wormuid, origin, waypoints : {PathWaypoint}, goal)
		print("Scan Worm Started")
		ScanController:RunWormToPosition(wormuid, origin, waypoints, goal)
	end)

	ScanService.onScanSpotCreated:Connect(function(wormuid, model, position)
		print("Scan Spot Start")
		ScanController:ForceCompleteWorm(wormuid)
		print(wormuid, model, position)
		ScanController:CreateScanPortal(wormuid, model, position)
	end)

	ScanService.onScanSpotEnded:Connect(function(wormuid)
		print("Scan Spot Ended")
		ScanController:DestroyScanPortal(wormuid)
	end)

	ScanService.onScanEnded:Connect(function()
		print("Scan Sequence Ended")
	end)
end

function ScanController:KnitInit()
	print(script.Name, "Init")
	ScanService = Knit.GetService("ScanService")
end

return ScanController