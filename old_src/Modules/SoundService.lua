
local Terrain = workspace.Terrain

-- // Module // --
local Module = {}

function Module:CreateAttachment( CF )
	local newAttachment = Instance.new('Attachment')
	newAttachment.Name = 'Sound_'..time()
	newAttachment.WorldCFrame = CF
	newAttachment.Parent = Terrain
	return newAttachment
end

function Module:PlaceSoundAtPosition( SoundObject, CharacterCFrame )
	local AttachmentInstance = Module:CreateAttachment( CharacterCFrame )
	SoundObject = SoundObject:Clone()
	SoundObject.Parent = AttachmentInstance
	return SoundObject, AttachmentInstance
end

return Module
