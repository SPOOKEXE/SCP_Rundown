local ContextActionService = game:GetService('ContextActionService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local PingConfigModule = ReplicatedModules.Data.PingConfig

local Knit = require(ReplicatedStorage.Knit)
local PingObjectController = Knit.CreateController { Name = "PingObjectController" }

local PingObjectService = false
local CurrentCamera = workspace.CurrentCamera

local PingRaycastParams = RaycastParams.new()
PingRaycastParams.FilterType = Enum.RaycastFilterType.Whitelist

function PingObjectController:ClearPing( Reference )

	--[[
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
	]]

end

--[[
	local baseBlock = Instance.new('Part')
	baseBlock.Anchored = true
	baseBlock.Size = Vector3.new(0.01, 0.01, 0.01)
	baseBlock.CanCollide = false
	baseBlock.CanTouch = false
	baseBlock.CanQuery = false
	baseBlock.CastShadow = false
	baseBlock.Transparency = 1
]]
function PingObjectController:CreatePing( Reference, Object, PingDataID, Position )
	local PingData = PingConfigModule:GetDataFromID( PingDataID )
	if not PingData then
		warn('Invalid Ping Received ; ', Reference.Name, Object:GetFullName())
		return
	end

	--[[
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
	]]

end

function PingObjectController:AttemptPing( Object, Position )
	local PingConfig = PingConfigModule:GetPingData( Object )
	if PingConfig then
		PingObjectService.CreatePing:Fire(Object, Position)
	end
end

function PingObjectController:KnitStart()
	print(script.Name, 'Init')

	-- objects that can be pinged
	PingRaycastParams.FilterDescendantsInstances = { }

	local PingCounter = 0
	ContextActionService:BindAction('MiddleClickPing', function(actionName, inputState, _)
		if actionName == 'MiddleClickPing' and inputState == Enum.UserInputState.Begin then
			local viewportRay = CurrentCamera:ViewportPointToRay( LocalMouse.X, LocalMouse.Y + 35 )
			local raycastResult = workspace:Raycast( viewportRay.Origin, viewportRay.Direction * 200 )

			PingCounter += 1
			if raycastResult and PingObjectController:IsPingable( raycastResult.Instance ) then
				PingCounter = 0
				PingObjectController:AttemptPing( raycastResult.Instance, raycastResult.Position )
			elseif PingCounter >= 3 then
				PingCounter = 0
				PingObjectService.CreatePing:Fire()
			end
		end
	end, false, Enum.UserInputType.MouseButton3)

	--[[
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
	]]

end

function PingObjectController:KnitInit()
	print(script.Name, 'Start')

	PingObjectService = Knit.GetService('PingObjectService')

	PingObjectService.CreatePing:Connect(function( Owner, Object, PingDataID, Position )
		PingObjectController:CreatePing( Owner, Object, PingDataID, Position )
	end)

	PingObjectService.RemovePing:Connect(function( Owner )
		PingObjectController:ClearPlayerPing( Owner )
	end)

	warn('Fix Middle Click Ping System (sometimes awkward to use)')
end

return PingObjectController
