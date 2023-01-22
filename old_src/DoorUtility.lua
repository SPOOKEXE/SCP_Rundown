local BlackCol3 = Color3.new()
local BeamCol = Color3.new(1, 0, 0)
local Padding = 0.035
local Delta = 0.025

local function ConstructSequenceInbetween(i)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, BlackCol3),
		ColorSequenceKeypoint.new(i - Padding, BlackCol3),
		ColorSequenceKeypoint.new(i, BeamCol),
		ColorSequenceKeypoint.new(i + Padding, BlackCol3),
		ColorSequenceKeypoint.new(1, BlackCol3),
	})
end

local function ConstructSequenceEnd(i)
	if i > 0.9 then -- right side of gradient
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, BlackCol3),
			ColorSequenceKeypoint.new(i - Padding, BlackCol3),
			ColorSequenceKeypoint.new(1, BeamCol),
		})
	else -- left side of gradient
		return ColorSequence.new({
			ColorSequenceKeypoint.new(1, BeamCol),
			ColorSequenceKeypoint.new(i + Padding, BlackCol3),
			ColorSequenceKeypoint.new(1, BlackCol3),
		})
	end
end

-- // Module // --
local Module = {}

-- Door Touchpad 'Red Line Scan' effect
function Module:RunScanBeamEffect(RedScanBeam, scanCount)
	for _ = 1, (scanCount or 2) do
		for i = Padding, (1 - Padding), Delta do
			RedScanBeam.Color = ConstructSequenceInbetween(i)
			task.wait()
		end
		RedScanBeam.Color = ConstructSequenceEnd(1)
		task.wait(0.1)
		for i = (1 - Padding), Padding, -Delta do
			RedScanBeam.Color = ConstructSequenceInbetween(i)
			task.wait()
		end
		RedScanBeam.Color = ConstructSequenceEnd(1)
		task.wait(0.1)
	end
	RedScanBeam.Color = ColorSequence.new( BlackCol3 )
end

return Module