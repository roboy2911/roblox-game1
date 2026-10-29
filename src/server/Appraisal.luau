-- Step 8: appraisal. Players never see an item's true value; they get an estimate range
-- (always containing the true value) that gets narrower with their appraisal level.
-- Fakes and hidden treasures fool you unless you spot them (more likely at higher levels).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Appraisal = {}

local rng = Random.new()

function Appraisal.MaxLevel(): number
	return #Config.AppraisalWidth
end

-- Makes an estimate of `item` at appraisal `level`: { Low, High, Level, Note? }.
-- Note is "Fake" or "Treasure" when you spotted something.
function Appraisal.Estimate(item, level: number)
	level = math.clamp(level, 1, Appraisal.MaxLevel())
	local width = Config.AppraisalWidth[level]
	local spotted = (item.Fake or item.Treasure) and rng:NextNumber() < Config.AppraisalSpot[level]
	-- What you think it's worth: the real value if you spotted the trick, otherwise how it looks
	local value = if spotted or not (item.Fake or item.Treasure) then item.TrueValue else (item.ApparentValue or item.TrueValue)
	-- Center the range a bit off the value, so the middle isn't always the answer
	local center = value * (1 + rng:NextNumber(-width, width) * 0.5)
	local low = math.max(0, math.floor(center - value * width))
	local high = math.ceil(center + value * width)
	if not spotted and (item.Fake or item.Treasure) then
		-- Fooled: the range is around what it looks like, not the true value
		return { Low = low, High = high, Level = level }
	end
	-- Make sure the true value is inside the range
	low = math.min(low, item.TrueValue)
	high = math.max(high, item.TrueValue)
	return {
		Low = low,
		High = high,
		Level = level,
		Note = if spotted then (if item.Fake then "Fake" else "Treasure") else nil,
	}
end

return Appraisal
