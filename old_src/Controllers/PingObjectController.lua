
local ContextActionService = game:GetService('ContextActionService')
local Debris = game:GetService('Debris')
local RunService = game:GetService('RunService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local PingConfig = ReplicatedModules.Defined.PingConfig

local Knit = require(ReplicatedStorage.Packages.Knit)
local PingObjectController = Knit.CreateController { Name = "PingObjectController" }
local PingObjectService = false

local PingSFX = ReplicatedAssets.Sounds.PingSFX

local CurrentCamera = workspace.CurrentCamera
local Terrain = workspace.Terrain

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.IgnoreWater = true

local PingBillboardCache = {}
function PingObjectController:ClearPlayerPing( Owner )
	local index = 1
	while index <= #PingBillboardCache do
		local item = PingBillboardCache[index]
		if item and item.Parent then
			if item:GetAttribute('Owner') == Owner.Name then
				item:Destroy()
				table.remove(PingBillboardCache, index)
			else
				index += 1
			end
		else
			table.remove(PingBillboardCache, index)
		end
	end
end

local baseBlock = Instance.new('Part')
baseBlock.Anchored = true
baseBlock.Size = Vector3.new(0.01, 0.01, 0.01)
baseBlock.CanCollide = false
baseBlock.CanTouch = false
baseBlock.CanQuery = false
baseBlock.CastShadow = false
baseBlock.Transparency = 1
function PingObjectController:CreatePing( Owner, Object, PingDataID, Position )
	local PingData = PingConfig:GetDataFromID( PingDataID )
	if (not PingData) then
		warn('Invalid Ping Received ; ', Owner.Name, Object:GetFullName())
		return
	end

	local PlayerColor = Owner:GetAttribute('PlayerColor') or Color3.new(1, 1, 1)
	local BillboardBlock = baseBlock:Clone()
	BillboardBlock.Position = Position
	BillboardBlock.Parent = Terrain
	local BasePingBillboard = ReplicatedAssets.UI.PingBillboard:Clone()
	BasePingBillboard.Adornee = BillboardBlock
	BasePingBillboard.Frame.Dot.BackgroundColor3 = PlayerColor
	BasePingBillboard.Frame.DistLabel.TextColor3 = PlayerColor
	BasePingBillboard.Frame.IconLabel.Image = PingData.Icon
	BasePingBillboard:SetAttribute('Owner', Owner.Name)

	PingObjectController:ClearPlayerPing( Owner )
	BasePingBillboard.Parent = BillboardBlock
	table.insert(PingBillboardCache, BasePingBillboard)

	local SampleSFX = PingSFX:Clone()
	SampleSFX.Parent = LocalPlayer.PlayerGui
	SampleSFX:Play()
	Debris:AddItem(SampleSFX, SampleSFX.TimeLength + 1)

	task.delay(9, function()
		if BasePingBillboard and BasePingBillboard.Parent then
			BasePingBillboard:Destroy()
		end
	end)
end

function PingObjectController:TryPingInstance( Object, Position )
	local PingData = PingConfig:GetPingData( Object )
	if not PingData then
		return
	end
	PingObjectService.pingObject:Fire(Object, Position)
end

function PingObjectController:IsPingable( Object )
	return Object:IsDescendantOf(workspace.Doors)
end

function PingObjectController:KnitStart()

	raycastParams.FilterDescendantsInstances = { workspace:WaitForChild('Doors') }

	local Counter = 0
	ContextActionService:BindAction('MiddleClickPing', function(actionName, inputState, inputObject)
		if actionName == 'MiddleClickPing' and inputState == Enum.UserInputState.Begin then
			local viewportRay = CurrentCamera:ViewportPointToRay( LocalMouse.X, LocalMouse.Y + 35 )
			local raycastResult = workspace:Raycast( viewportRay.Origin, viewportRay.Direction * 200 )
			Counter += 1
			if raycastResult and PingObjectController:IsPingable( raycastResult.Instance ) then
				Counter = 0
				PingObjectController:TryPingInstance( raycastResult.Instance, raycastResult.Position )
			elseif Counter >= 3 then
				Counter = 0
				PingObjectService.pingObject:Fire()
			end
		end
	end, false, Enum.UserInputType.MouseButton3)

	RunService.Heartbeat:Connect(function()
		local PrimaryPart = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
		if not PrimaryPart then
			return
		end
		local Position = PrimaryPart.Position
		for _, Billboard in ipairs( PingBillboardCache ) do
			if (not Billboard) or (not Billboard.Parent) then
				continue
			end
			local rawDistance = (Position - Billboard.Parent.Position).Magnitude
			Billboard.Frame.DistLabel.Text = math.floor(rawDistance)..'m'
		end
	end)

end

function PingObjectController:KnitInit()

	PingObjectService = Knit.GetService('PingObjectService')

	PingObjectService.pingObject:Connect(function( Owner, Object, PingDataID, Position )
		PingObjectController:CreatePing( Owner, Object, PingDataID, Position )
	end)

	PingObjectService.deletePing:Connect(function( Owner )
		PingObjectController:ClearPlayerPing( Owner )
	end)

	warn('Fix Middle Click Ping System (sometimes awkward to use)')

end

return PingObjectController

