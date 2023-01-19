local PhysicsService = game:GetService('PhysicsService')

local function IterateBaseParts(Parent, callback)
	local Array = Parent:GetDescendants()
	table.insert(Array, Parent)
	for _, BasePart in ipairs( Array ) do
		if BasePart:IsA('BasePart') then
			callback(BasePart)
		end
	end
end

-- // Module // --
local Module = {}

function Module:CreateCollisionGroup(GroupName)
	if not PhysicsService:IsCollisionGroupRegistered(GroupName) then
		PhysicsService:RegisterCollisionGroup(GroupName)
	end
end

function Module:SetCollisionOfGroups(GroupA, GroupB, Enabled)
	Module:CreateCollisionGroup(GroupA)
	Module:CreateCollisionGroup(GroupB)
	PhysicsService:CollisionGroupSetCollidable(GroupA, GroupB, Enabled)
end

function Module:AddDescendantsToGroup(Parent, GroupName)
	Module:CreateCollisionGroup(GroupName)
	IterateBaseParts(Parent, function(BasePart)
		BasePart.CollisionGroup = GroupName
		-- PhysicsService:SetPartCollisionGroup(BasePart, GroupName)
	end)
end

function Module:RemoveDescendantsFromGroup(Parent, GroupName)
	Module:CreateCollisionGroup(GroupName)
	IterateBaseParts(Parent, function(BasePart)
		if BasePart.CollisionGroup == GroupName then
			BasePart.CollisionGroup = nil
		end
		-- PhysicsService:RemoveCollisionGroup(BasePart, GroupName)
	end)
end

return Module
