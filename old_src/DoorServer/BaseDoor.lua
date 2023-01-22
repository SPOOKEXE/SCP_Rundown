
local CollectionService = game:GetService('CollectionService')
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local DoorConfigModule = ReplicatedModules.Data.DoorConfig
local MaidInstanceClass = ReplicatedModules.Classes.Maid

type ClearanceConfigTable = {
	KeyLevel : number,
	Clearance : {
		AD : boolean,
		EC : boolean,
		ET : boolean,
		IA : boolean,
		ISD: boolean,
		LD : boolean,
		MD : boolean,
		MTF: boolean,
		MaD: boolean,
		SD : boolean,
		ScD : boolean,
		O5 : boolean,
	},
}

type DoorConfigTable = {
	ID : string,
	DoorClassID : string,
	ClearanceConfig : ClearanceConfigTable | { ClearanceConfigTable },
	CooldownPeriod : number,
	AutoClosePeriod : number,
}

-- // Class // --
local Class = { SystemsContainer = {} }
Class.__index = Class

function Class.New(Model)
	local ConfigTable = DoorConfigModule:GetDoorConfig( Model.Name ) :: DoorConfigTable

	local DoorClone = Model:Clone()
	DoorClone.Parent = script

	local self = setmetatable({
		UUID = HttpService:GenerateGUID(false),

		Model = Model,
		BackupModel = DoorClone,
		_BackupParent = Model.Parent,

		DoorMaid = MaidInstanceClass.New(),
		DoorControlNodes = {},
		Config = ConfigTable,

		_LastState = nil, -- last state of the door
	}, Class)

	self:_SetupAttributes()
	self:_Setup()

	return self
end

function Class:_SetupAttributes()
	self:SetAttribute('DoorID', self.Config.DoorClassID)
	self:SetAttribute('StateValue', false) -- false = open
	self:SetAttribute('DoorDestroyed', false)
	-- self:SetAttribute('PowerEnabledOverride', false)
	-- self:SetAttribute('ControlPanelOverride', false)
	-- self:SetAttribute('SCP079Override', false)
	-- self:SetAttribute('IsDoorBroken', false)
	self:SetAttribute('DoorSector', false)
	self:SetAttribute('DoorUUID', self.UUID)
end

function Class:_Setup()
	--[[local boundCF, boundSize = self.Model:GetBoundingBox()
	local bPart = Instance.new('Part')
	bPart.Name = 'Detector'
	bPart.CFrame = boundCF
	bPart.Size = boundSize
	bPart.Anchored = true
	bPart.CastShadow = false
	bPart.Transparency = 1
	bPart.CanCollide = false
	bPart.CanTouch = false
	bPart.Parent = self.Model]]

	local ControllersCount = 0
	for _, ObjectVal in ipairs(self.Model:GetChildren()) do
		if ObjectVal:IsA('ObjectValue') and ObjectVal.Name == 'ControlNode' then
			ControllersCount += 1
			self:_SetupControllerNode( ObjectVal )
		end
	end

	-- // TESTING PURPOSES // --
	if ControllersCount == 0 then
		local proximityPrompt = Instance.new('ProximityPrompt')
		proximityPrompt.Name = 'ToggleDoorPrompt'
		proximityPrompt.Enabled = true
		proximityPrompt.ActionText = 'Toggle Door'
		proximityPrompt.ObjectText = 'Door'
		proximityPrompt.ClickablePrompt = true
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
		proximityPrompt.HoldDuration = 0.25
		proximityPrompt.MaxActivationDistance = 12
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
		proximityPrompt.Triggered:Connect(function(LocalPlayer)
			self:Toggle( )
		end)
		proximityPrompt.Parent = self.Model:FindFirstChild('PromptNode') or self.Model
	end
	-- // ---------------- // --

	--[[self:GetAttributeChangedSignal('IsElectricalBrokenOverride'):Connect(function()
		if self:GetAttribute('IsElectricalBrokenOverride') then
			if Random.new():NextInteger(1, 2) == 1 then
				while self:GetAttribute('IsElectricalBrokenOverride') do
					self:Toggle()
					task.wait( 4 * Random.new():NextNumber() ) -- Random makes it much more Random ;)
				end
			else
				self:Toggle(false)
			end
		end
	end)]]
end

function Class:_SetupControllerNode( ObjectVal )
	local ControllerNodeState = (ObjectVal and ObjectVal.Value) and ObjectVal.Value
	if not ControllerNodeState then
		warn('Could not find door controller: ' .. self.Model:GetFullName())
		return false
	end

	task.defer(function()
		self:Toggle( ObjectVal.Value:GetAttribute('StateValue') )
	end)

	self.DoorMaid:Give(ObjectVal.Value:GetAttributeChangedSignal('StateValue'):Connect(function()
		self:Toggle( ObjectVal.Value:GetAttribute('StateValue') )
	end))
end

function Class:GetAttribute(attribute)
	return self.Model:GetAttribute(attribute)
end

function Class:SetAttribute(attribute, value)
	self.Model:SetAttribute(attribute, value)
end

function Class:GetAttributeChangedSignal(attribute)
	return self.Model:GetAttributeChangedSignal(attribute)
end

function Class:SetElectricalIsBroken(overridden)
	self:SetAttribute('IsElectricalBrokenOverride', overridden)
end

function Class:SetPowerDisabledOverride( overridden )
	self:SetAttribute('PowerEnabledOverride', overridden)
end

function Class:SetCommandControlOverride( overridden )
	self:SetAttribute('ControlPanelOverride', overridden)
end

function Class:Set079ControlOverride( overridden )
	self:SetAttribute('SCP079Override', overridden)
end

-- Respawn the door (destroys this class)
function Class:Respawn()
	-- spawn the backup model
	local BackupModel = self.BackupModel
	if BackupModel then
		BackupModel.Parent = self._BackupParent
		CollectionService:AddTag(BackupModel, 'DoorInstance')
	end
	self.BackupModel = nil
	-- destroy the current model
	if self.Model then
		self.Model:Destroy()
		self.Model = nil
	end
	self.DoorMaid:Cleanup()
end

-- Break the door
function Class:Demolish()
	if not self.Model then
		return false
	end
	self:SetAttribute('DoorDestroyed',true)
	for _, BasePart in ipairs( self.Model:GetDescendants() ) do
		if BasePart:IsA('BasePart') then
			BasePart.CanCollide = true
			BasePart.CanQuery = true
			BasePart.Anchored = false
			BasePart.CanTouch = false
		end
	end
	return true
end

function Class:Toggle( forceState )
	--print('Toggle Door - ', self.Model:GetFullName(), ' - ', forceState)
	if self:GetAttribute('DoorDestroyedValue') then
		return false
	end
	if typeof(forceState) == 'boolean' then
		self:SetAttribute('StateValue', forceState)
	else
		self:SetAttribute('StateValue', not self:GetAttribute('StateValue'))
	end
	return true
end

function Class:OnInteracted(LocalPlayer)
	if #self.DoorControlNodes > 0 then
		return false, 'Cannot interact with this door - uses a controller'
	end

	if not self.Model then
		return false, 'Door is invalid - no model in class.'
	end

	if self.Debounce then
		return false, 'Door is currently busy.'
	end

	print('Interaction Successful - ', LocalPlayer, self.Model:GetFullName())

	self.Debounce = true
	self:Toggle( )
	task.delay(2, function()
		self.Debounce = false
	end)

	return true, 'Successfully toggled door'
end

return Class
