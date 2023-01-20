
local GuiService = game:GetService('GuiService')
local UserInputService = game:GetService('UserInputService')
local ContextActionService = game:GetService('ContextActionService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local ReplicatedStorage = game:GetService('ReplicatedStorage')
--local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
--local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Knit = require(ReplicatedStorage.Packages.Knit)
local FirstPersonController = Knit.CreateController { Name = "FirstPersonController" }
FirstPersonController.IsHoldUnlock = false
FirstPersonController.IsLockActive = false

local CameraController = LocalModules.Services.CameraController
local MovementController = LocalModules.Services.MovementController

local LockStateID = 'FPSLockState'
local StateActionName = 'CameraStateUpdate'

function FirstPersonController:UpdateCameraLockedState()
	CameraController:PopByID(LockStateID)
	MovementController:PopByID(LockStateID)
	if FirstPersonController.IsLockActive then
		-- camera is locked in first person
		CameraController:SetStateWithPriority( 5, LockStateID, false, Enum.CameraMode.LockFirstPerson, 0.5, 0.5, false )
	else
		-- camera unlocked out of first person
		CameraController:SetStateWithPriority( 1, LockStateID, Enum.CameraType.Fixed, Enum.CameraMode.Classic, 1, 1, false )
		MovementController:SetMovementEnabledWithPriority( 5, LockStateID, false )
	end
end

function FirstPersonController:SetCameraLockedState( forceLocked )
	if typeof(forceLocked) == 'nil' then
		FirstPersonController.IsLockActive = (not FirstPersonController.IsLockActive)
	else
		FirstPersonController.IsLockActive = forceLocked
	end
	FirstPersonController:UpdateCameraLockedState()
end

function FirstPersonController:GetPlatform()
	if GuiService:IsTenFootInterface() or UserInputService.GamepadEnabled then
		return "Console"
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "Mobile"
	end
	return "Desktop"
end

function FirstPersonController:SetupControls()
	local Platform = FirstPersonController:GetPlatform()
	print('Setup Controls; ', Platform)
	if Platform == 'Desktop' then

		-- Hold key down to unlock mouse
		ContextActionService:BindAction(StateActionName, function(actionName, inputState, _)
			--print(StateActionName)
			if actionName == StateActionName then
				if FirstPersonController.IsHoldUnlock then
					FirstPersonController:SetCameraLockedState( inputState ~= Enum.UserInputState.Begin )
				elseif inputState == Enum.UserInputState.Begin then
					FirstPersonController:SetCameraLockedState()
				end
			end
		end, false, Enum.KeyCode.X)

	elseif Platform == 'Console' then

		-- Press ButtonY to flip the unlocked state of the mouse
		ContextActionService:BindAction(StateActionName, function(actionName, inputState, _)
			--print(StateActionName)
			if actionName == StateActionName and inputState == Enum.UserInputState.Begin then
				FirstPersonController:SetCameraLockedState()
			end
		end, false, Enum.KeyCode.ButtonY)

	else

		-- Press the button to flip the unlocked state of the mouse
		ContextActionService:BindAction(StateActionName, function(actionName, inputState, _)
			--print(StateActionName)
			if actionName == StateActionName and inputState == Enum.UserInputState.Begin then
				FirstPersonController:SetCameraLockedState()
			end
		end, false)

		ContextActionService:SetDescription(StateActionName, 'Holding X will unlock the mouse ingame so you can move it around.')
		ContextActionService:SetImage(StateActionName, 'rbxassetid://9653661214')
		ContextActionService:SetPosition(StateActionName, UDim2.fromOffset(0, 0))
	end
end

function FirstPersonController:ReleaseControls()
	ContextActionService:UnbindAction(StateActionName)
end

function FirstPersonController:KnitStart()
	print(script.Name, 'Started')
	FirstPersonController:SetCameraLockedState( true )
	FirstPersonController:SetupControls()
end

function FirstPersonController:KnitInit()
	print(script.Name, 'Init')
end

return FirstPersonController

