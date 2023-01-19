local HttpService = game:GetService('HttpService')

local Lighting = game:GetService('Lighting')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local ScanConfig = ReplicatedModules.Defined.ScanConfig

local Knit = require(ReplicatedStorage.Packages.Knit)
local DoorService = false
local ScanService = false
--local InteractionService = false

Knit:OnStart():andThen(function()
	DoorService = Knit.GetService('DoorService')
	ScanService = Knit.GetService('ScanService')
	--InteractionService = Knit.GetService("InteractionService")
	print("Setup Knit References; ", DoorService ~= nil, ScanService ~= nil)
end):catch(warn)

local function getScanDataFromFolder( scanFolder )
	if not scanFolder then
		return false
	end
	local scanConfig = ScanConfig:GetScanFromID( scanFolder.ScanID.Value )
	if not scanConfig then
		return false
	end
	return ScanService:SetupScanClass( scanConfig ), scanConfig
end

-- // Class // --
local Class = { ClassName = 'BaseDoor' }
Class.__index = Class

function Class.New( Model, Config )
	local ScanFolderInstance = Model:FindFirstChild('ScanData')
	local StateValue = Instance.new('BoolValue')
	StateValue.Name = 'DoorState'
	StateValue.Value = false
	StateValue.Parent = Model
	local scanClass, scanConfig = getScanDataFromFolder( ScanFolderInstance )
	if scanClass then
		local SoundNameInstance = ScanFolderInstance and ScanFolderInstance:FindFirstChild('AlarmSFXName')
		local SoundInstance = SoundNameInstance and ReplicatedStorage.Assets.Sounds:FindFirstChild( SoundNameInstance.Value )
		if SoundInstance then
			SoundInstance = SoundInstance:Clone()
			SoundInstance.Parent = Lighting
		end
		scanClass.ScanFolderInstance = ScanFolderInstance
		scanClass.SoundObject = SoundInstance or false
		scanClass.Model = Model
	end
	return setmetatable({
		UUID = HttpService:GenerateGUID(false),
		Model = Model,
		Config = Config,
		StateValue = StateValue,
		ScanFolderInstance = ScanFolderInstance,
		ScanConfig = scanConfig,
		ScanClass = scanClass,
		_LastState = nil,
	}, Class)
end

function Class:CheckScanTrigger() -- return false if scan is not completed.
	if not self.ScanClass then
		return
	end
	print('check scan')
end

function Class:CanOpen()
	print('Check Door Toggle')
	return true
end

function Class:Setup()
	print('Door Setup')
end

function Class:Toggle( forcedState : boolean )
	print('Door Toggle')
	if typeof(forcedState) == 'boolean' then
		self.StateValue.Value = forcedState or false
	else
		self.StateValue.Value = (not self.StateValue.Value)
	end
end

return Class
