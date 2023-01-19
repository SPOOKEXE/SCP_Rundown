
-- // Module // --
local RunService = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local Debris = game:GetService('Debris')
local CollectionService = game:GetService('CollectionService')

local Players = game:GetService('Players')
local PathfindingService = game:GetService('PathfindingService')
local Lighting = game:GetService('Lighting')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

--local ScanConfig = ReplicatedModules.Defined.ScanConfig
local ZoneService = ReplicatedModules.Services.ZoneService
local TableUtility = ReplicatedModules.Utility.Table

local Knit = require( ReplicatedStorage.Packages.Knit )
local ReviveSystemService = false
local CheckpointService = false

local ScanService = Knit.CreateService {
	Name = "ScanService",
	Client = { }
}

ScanService.ScanEventClasses = {} -- all scan event classes
ScanService.ActiveScanClasses = {} -- all active scans
ScanService.CompletedScanClasses = {} -- all completed scans
ScanService.ScannerModels = {} -- every active scan circle model

ScanService.Client.onScanStarted = Knit.CreateSignal() -- on scan started
ScanService.Client.onScanWormCreated = Knit.CreateSignal() -- traverse to position
ScanService.Client.onScanSpotCreated = Knit.CreateSignal() -- create scan spot at position
ScanService.Client.onScanSpotEnded = Knit.CreateSignal() -- create scan spot at position
ScanService.Client.onScanEnded = Knit.CreateSignal() -- on scan ended

local scansModelFolder = Instance.new('Folder')
scansModelFolder.Name = 'ScansModels'
scansModelFolder.Parent = workspace

local scanCircleNODERaycastParams = RaycastParams.new()
scanCircleNODERaycastParams.FilterDescendantsInstances = { workspace:WaitForChild('Map'), workspace.Terrain }
scanCircleNODERaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
scanCircleNODERaycastParams.IgnoreWater = true

local function TweenSize( Frame, endSize, duration )
	Frame:TweenSize( endSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, duration or 0.1 )
end

-- // Data Table // --
local ScanCircleData = {}
ScanCircleData.__index = ScanCircleData

function ScanCircleData.New( Model, NodePart, scanClass, scanDataTable )
	local valueObject = Instance.new('NumberValue')
	valueObject.Name = 'PercentValue'
	valueObject.Changed:Connect(function(value)
		TweenSize( Model.Center.Attachment.Billboard.ProgressBar.Frame, UDim2.fromScale(value/100 , 1) )
	end)
	Model.Center.Attachment.Billboard.ProgressBar.Frame.Size = UDim2.fromScale(0 , 1)
	valueObject.Parent = Model
	return setmetatable({
		UUID = HttpService:GenerateGUID(false),
		Completed = false,
		Callback = Instance.new('BindableEvent'),
		NodePart = NodePart,
		ScanClass = scanClass,
		ScanDataTable = scanDataTable,
		RequiresTeam = string.find( scanDataTable.ID, 'Team') or string.find(scanDataTable.ID, 'Checkpoint'),
		LoseValueOvertime = scanDataTable.LoseOvertime or false,
		ValueObject = valueObject,
	}, ScanCircleData)
end

function ScanCircleData:Increment( amount ) -- add and negate values
	self.ValueObject.Value = math.clamp( self.ValueObject.Value + amount, 0, 100 )
	if (not self.Completed) and self.ValueObject.Value >= 100 then
		self.Completed = true
		self.Callback:Fire()
	end
end

-- // Class // --
local ScanEventClass = {}
ScanEventClass.__index = ScanEventClass

function ScanEventClass.New( ScanData )
	local self = {}
	self.UUID = HttpService:GenerateGUID( false )
	self.ScanActive = false
	self.ScanIndex = 1
	self.ScanConfig = ScanData
	self.SoundObject = false
	self.ScanUUIDs = { }
	self.CompletedScanClassesUUIDs = {}
	self.ScanFolderInstance = false
	self.ScanData = TableUtility:DeepCopy(ScanData)
	self.LastNodePositions = {}
	self.LastNodeIndex = 0
	for _, scanTbl in pairs( self.ScanData.ScanTypes ) do
		scanTbl.UUID = HttpService:GenerateGUID(false)
	end
	setmetatable(self, ScanEventClass)
	table.insert(ScanService.ScanEventClasses, self)
	return self
end

function ScanEventClass:GetTotalNodeCount()
	local count = 0
	for _, tbl in ipairs( self.ScanData.ScanTypes[self.ScanIndex] ) do
		count += tbl.NodeCount
	end
	return count
end

function ScanEventClass:AreAllScansComplete()
	return (not self.ScanData.ScanTypes[self.ScanIndex])
end

function ScanEventClass:CanStartNextScans()
	return not table.find(self.ScanUUIDs, self.ScanData.ScanTypes[self.ScanIndex].UUID)
end

function ScanEventClass:HasCompletedScanClasses()
	local NodeData = self.ScanData.ScanTypes[self.ScanIndex]
	return self.CompletedScanClassesUUIDs[NodeData.UUID] and (self.CompletedScanClassesUUIDs[NodeData.UUID] >= self:GetTotalNodeCount())
end

local basePart = Instance.new('Part')
basePart.Name = 'WaypointNode'
basePart.Anchored = true
basePart.Transparency = 0.8
basePart.Size = Vector3.new(1, 1, 1)
basePart.CanCollide = false
basePart.CanQuery = false
basePart.CanTouch = false
function ScanEventClass:WormToPosition( FromHere, ToHere, Callback )
	local Dist = (FromHere - ToHere).Magnitude
	local IsFarDistance = Dist > 7
	--print( Dist, IsFarDistance, IsOccluded )
	if IsFarDistance then
		local PathObject = PathfindingService:CreatePath({AgentCanJump = false})
		PathObject:ComputeAsync( FromHere, ToHere )
		local Waypoints = PathObject:GetWaypoints()
		for i, waypoint in ipairs( Waypoints ) do
			local waypointPosition = waypoint.Position
			local nodePart = basePart:Clone()
			nodePart.Color = BrickColor.random().Color
			nodePart.Position = waypointPosition
			nodePart.Parent = workspace
			Debris:AddItem(nodePart, 5 + (i * 0.25 * 0.5))
			task.wait(0.25)
		end
	end
	task.spawn(Callback)
end

function ScanEventClass:SpawnScanCirclesFromNodes()
	local currentScanData = self.ScanData.ScanTypes[self.ScanIndex]
	--print(currentScanData)
	table.insert( self.ScanUUIDs, currentScanData.UUID )
	if self.ScanFolderInstance then
		self.LastNodeIndex += 1
		local AttribCache = {}
		for _, tbl in ipairs( currentScanData ) do
			tbl.UUID = currentScanData.UUID
			--print(self.ScanIndex, tbl)
			for _ = 1, tbl.NodeCount do
				if self.ScanIndex == 1 then
					local NodeParts = self.ScanFolderInstance.Start:GetChildren()
					local RandomNode = NodeParts[Random.new():NextInteger(1, #NodeParts)]
					task.spawn(function()
						self:WormToPosition(self.Model:GetPrimaryPartCFrame().Position, RandomNode.Position, function()
							ScanService:CreateScanPortal(RandomNode, self, tbl)
						end)
					end)
					table.insert(self.LastNodePositions, RandomNode.Position)
					self.LastNodeIndex = 0
				else
					local NodeParts = self.ScanFolderInstance['Nodes'..self.ScanIndex]:GetChildren()
					local RandomNode = false
					local c = 0
					while (not RandomNode) or c > 80 do
						RandomNode = NodeParts[Random.new():NextInteger(1, #NodeParts)]
						if RandomNode:GetAttribute("UsedNode") then
							RandomNode = false
						end
						c += 1
					end
					if c >= 80 then
						RandomNode = NodeParts[1]
					end
					RandomNode:SetAttribute("UsedNode", true)
					table.insert(AttribCache, RandomNode)
					task.spawn(function()
						self:WormToPosition( self.LastNodePositions[self.LastNodeIndex], RandomNode.Position, function()
							ScanService:CreateScanPortal(RandomNode, self, tbl, function()
								table.insert(self.LastNodePositions, RandomNode.Position)
								self.LastNodeIndex = (#self.LastNodePositions - 1)
							end)
						end)
					end)
				end
			end
		end
		for _, RandomNode in ipairs( AttribCache ) do
			RandomNode:SetAttribute("UsedNode", nil)
		end
	else
		for _, tbl in ipairs( currentScanData ) do
			ScanService:RegisterSpecialScan( self.ScanIndex, self, tbl )
		end
	end
end

function ScanEventClass:Update( _ )
	if self:HasCompletedScanClasses() then
		print("completed scans")
		self.ScanIndex += 1
		self.CompletedScanClassesUUIDs = {}
	elseif self:CanStartNextScans() then
		print("start next scan lot")
		self:SpawnScanCirclesFromNodes()
	end
end

-- // Module // --
function ScanService:CreateScanPortal( NodePart, scanClass, scanDataTable, Callback )
	--print("create scan portal; ", NodePart:GetFullName(), scanDataTable) --, scanClass, scanDataTable)

	local ScannerModel = ReplicatedAssets.Scans:FindFirstChild( scanDataTable.ID )
	if not ScannerModel then
		warn("Unknown Scan Model; ", scanDataTable.ID)
		ScannerModel = ReplicatedAssets.Scans.UNKNOWN
	end

	ScannerModel = ScannerModel:Clone()

	local positionVector = workspace:Raycast( NodePart.Position, Vector3.new(0, -10, 0), scanCircleNODERaycastParams )
	if positionVector then
		positionVector = positionVector.Position
	else
		positionVector = NodePart.Position
	end

	positionVector += Vector3.new(0, 0.25, 0)
	ScannerModel:SetPrimaryPartCFrame( CFrame.new( positionVector ) * CFrame.Angles(math.rad(-90), 0, 0) )
	ScannerModel.Parent = scansModelFolder

	local newScanCircle = ScanCircleData.New(ScannerModel, NodePart, scanClass, scanDataTable)
	newScanCircle.Callback.Event:Connect(function()
		ScanService.ScannerModels[ScannerModel] = nil
		ScannerModel:Destroy()
		-- print(scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] or 1)
		if typeof(Callback) == 'function' then
			pcall(Callback)
		end
		if scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] then
			scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] += 1
		else
			scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] = 1
		end
	end)
	ScanService.ScannerModels[ScannerModel] = newScanCircle
end

function ScanService:RegisterSpecialScan( scanIndex, scanClass, scanDataTable )
	print("register special scan; ", scanIndex, scanClass, scanDataTable)
	if scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] then
		scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] += 1
	else
		scanClass.CompletedScanClassesUUIDs[scanDataTable.UUID] = 1
	end
end

function ScanService:SetupScanClass( ScanData )
	local class = ScanEventClass.New( ScanData )
	--print( class )
	return class
end

function ScanService:CanTriggerScan( ScanClass )
	return (not ScanClass.ScanActive)
end

function ScanService:StartScan( ScanClass, ... )
	local callbackFunctions = { ... }
	if ScanService:CanTriggerScan( ScanClass ) then
		ScanClass.ScanActive = true
		ScanClass.Callbacks = callbackFunctions
		if ScanClass.SoundObject then
			ScanClass.SoundObject.Parent = workspace
			ScanClass.SoundObject.Looped = true
			ScanClass.SoundObject:Play()
		end
		table.insert(ScanService.ActiveScanClasses, ScanClass)
	end
end

function ScanService:ResetActiveScan( ScanClass )
	print('Reset Scan; ', ScanClass)
	ScanClass.Active = false
	ScanClass.ScanIndex = 1
	for _, scanUUID in ipairs( ScanClass.ScanUUIDs ) do
		local index = table.find( ScanService.CompletedScanClasses, scanUUID )
		if index then
			table.remove(ScanService.CompletedScanClasses, index)
		end
	end
end

function ScanService:ResetActiveScanClasses()
	local oldScanData = ScanService.ActiveScanClasses
	ScanService.ActiveScanClasses = {}
	for _, scanClass in ipairs( oldScanData ) do
		ScanService:ResetActiveScan( scanClass )
	end
end

function ScanService:KnitStart()
	print(script.Name, "Start")

	-- // Updating the scan classes and such // --
	RunService.Heartbeat:Connect(function(deltaTime)
		local index = 1
		while index <= #ScanService.ActiveScanClasses do
			local scanClass = ScanService.ActiveScanClasses[index]
			if scanClass and scanClass:AreAllScansComplete() then
				table.remove(ScanService.ActiveScanClasses, index)
				table.insert(ScanService.CompletedScanClasses, scanClass.UUID)
				if scanClass.SoundObject then
					scanClass.SoundObject.Parent = Lighting
					scanClass.SoundObject.Looped = false
					scanClass.SoundObject:Stop()
				end
				--print(scanClass)
				if scanClass.ScanConfig.TriggerCheckpointSave then
					CheckpointService:RegisterNewCheckpointData()
				end
				if scanClass.Callbacks then
					for _, func in ipairs( scanClass.Callbacks ) do
						task.spawn(pcall, func, true)
					end
				end
				warn('Scan Completed')
				--warn("Scan Completed: ", scanClass)
			else
				task.spawn(function()
					scanClass:Update(deltaTime)
				end)
				index += 1
			end
		end
	end)

	-- // Updating all the individual scans // --
	local scanCircleRegionRaycastParams = RaycastParams.new()
	scanCircleRegionRaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	scanCircleRegionRaycastParams.IgnoreWater = true
	scanCircleRegionRaycastParams.FilterDescendantsInstances = {scansModelFolder}

	local function RaycastCircle( Position, Model )
		local Result = workspace:Raycast( Position, Vector3.new(0, -10, 0), scanCircleRegionRaycastParams )
		if Result and Result.Instance:IsDescendantOf(Model) then
			return true
		end
		return false
	end

	RunService.Heartbeat:Connect(function()
		for Model, classData in pairs( ScanService.ScannerModels ) do
			local counter = 0
			for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
				local PlayerCharacter = LocalPlayer.Character
				local WithinCircle = PlayerCharacter and PlayerCharacter.PrimaryPart and RaycastCircle( PlayerCharacter.PrimaryPart.Position, Model )
				if WithinCircle and (not ReviveSystemService:GetPlayerDownedState( LocalPlayer )) then
					counter += 1
				end
			end
			-- print( classData.ScanClass.ScanIndex, counter )
			if (not classData.RequiresTeam) and (counter > 0) or counter == #Players:GetPlayers() then
				classData:Increment(1.5)
			elseif classData.LoseValueOvertime then
				classData:Increment(-0.25)
			end
		end
	end)

end

function ScanService:KnitInit()
	print(script.Name, "Init")
	-- AlarmService = Knit.GetService('AlarmService')
	ReviveSystemService = Knit.GetService('ReviveSystemService')
	CheckpointService = Knit.GetService('CheckpointService')
end

return ScanService