
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ReplicatedModulesInstance = ReplicatedStorage.Modules

local EventClassModule = require(ReplicatedModulesInstance.Classes.Event)
local MaidClassModule = require(ReplicatedModulesInstance.Classes.Maid)

-- // Class // --
local Class = { ParentTable = false }
Class.__index = Class

function Class.New( InteractableInstance, CanUseInteractableCallback )
	local MaidInstance = MaidClassModule.New()

	local _OnInteracted = EventClassModule.New()
	MaidInstance:Give(_OnInteracted)

	local self ={
		Interactable = InteractableInstance,

		_CanUseInteractable = CanUseInteractableCallback or false,
		_OnInteracted = _OnInteracted,
		_Args = {},

		_destroyed = false,
		_maid = MaidInstance,
	}

	if RunService:IsClient() then
		local _OnHoldStart = EventClassModule.New()
		local _OnHoldRelease = EventClassModule.New()
		self._OnHoldStart = _OnHoldStart
		self._OnHoldRelease = _OnHoldRelease
		MaidInstance:Give(_OnHoldStart, _OnHoldRelease)
	end

	return setmetatable(self, Class)
end

function Class:DistanceFrom(Position)
	return (self.Interactable:GetPivot().Position - Position).Magnitude
end

function Class:SetFireArgs(Args)
	self._Args = Args
	return self
end

function Class:OnInteracted(...)
	local connection = self._OnInteracted:Connect(...)
	self._maid:Give(connection)
	return connection
end

if RunService:IsClient() then
	function Class:OnHoldStart(...)
		local connection = self._OnHoldStart:Connect(...)
		self._maid:Give(connection)
		return connection
	end

	function Class:OnHoldRelease(...)
		local connection = self._OnHoldRelease:Connect(...)
		self._maid:Give(connection)
		return connection
	end
end

function Class:Destroy()
	self._destroyed = true
	self._maid:Cleanup()

	local index = Class.ParentTable and table.find(Class.ParentTable, self)
	if index then
		table.remove(Class.ParentTable, index)
	end
end

return Class
