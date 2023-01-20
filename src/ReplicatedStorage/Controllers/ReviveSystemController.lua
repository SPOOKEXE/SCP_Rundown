local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
-- local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

-- local MovementController = LocalModules.Services.MovementController
-- local CameraController = LocalModules.Services.CameraController

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage:WaitForChild("Knit"))

-- local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

-- local AnimationsModule = ReplicatedModules.Defined.Animations

local ReviveSystemController = Knit.CreateController { Name = "ReviveSystemController" }

-- local CurrentCamera = workspace.CurrentCamera

-- local ActiveDownedIdle = false
-- local DownedIdleAnimationObj = Instance.new('Animation')
-- DownedIdleAnimationObj.AnimationId = AnimationsModule.DownedIdleAnimation

-- local LockStateID = 'ReviveLockState'

function ReviveSystemController:LoadAnimations()
	--[[
		local Humanoid = LocalPlayer.Character and LocalPlayer.Character:WaitForChild('Humanoid', 1)
		if not Humanoid then
			return
		end
		local AnimatorInstance = Humanoid and Humanoid:WaitForChild('Animator', 1)
		if not AnimatorInstance then
			return
		end
		if ActiveDownedIdle then
			ActiveDownedIdle:Stop()
			ActiveDownedIdle = nil
		end
		ActiveDownedIdle = AnimatorInstance:LoadAnimation(DownedIdleAnimationObj)
		if ReviveSystemController:GetDownedState() then
			ActiveDownedIdle:Play()
		end
	]]
end

function ReviveSystemController:SetDownedState( isDowned )
	--[[
		print('Set ', LocalPlayer.Name, ' downed state to ', isDowned)
		MovementController:PopByID(LockStateID)
		CameraController:PopByID(LockStateID)
		if isDowned then
			MovementController:SetMovementEnabledWithPriority(5, LockStateID, false)
			CameraController:SetStateWithPriority(5, LockStateID, Enum.CameraType.Attach,  Enum.CameraMode.Classic, 1, 1, false)
			if ActiveDownedIdle then
				ActiveDownedIdle:Play()
			end
		else
			MovementController:SetMovementEnabled(LockStateID, true)
			if ActiveDownedIdle then
				ActiveDownedIdle:Stop()
			end
		end
	]]
end

function ReviveSystemController:GetDownedState()
	return LocalPlayer:GetAttribute('IsDowned')
end

function ReviveSystemController:KnitStart()
	print(script.Name, 'Started')

	ReviveSystemController:SetDownedState( LocalPlayer:GetAttribute('IsDowned') )
	LocalPlayer:GetAttributeChangedSignal('IsDowned'):Connect(function()
		ReviveSystemController:SetDownedState( LocalPlayer:GetAttribute('IsDowned') )
	end)

	task.defer(function()
		ReviveSystemController:LoadAnimations()
	end)

	LocalPlayer.CharacterAdded:Connect(function()
		ReviveSystemController:LoadAnimations()
	end)
end

function ReviveSystemController:KnitInit()
	print(script.Name, 'Init')
end

return ReviveSystemController
