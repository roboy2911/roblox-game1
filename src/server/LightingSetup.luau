-- Sets up the game's lighting so it isn't too bright or glary.
-- Tweak the numbers here: lower = darker / less glow.

local Lighting = game:GetService("Lighting")

local LightingSetup = {}

local SETTINGS = {
	Brightness = 1.6, -- strength of the sun (Roblox default is 2-3)
	ExposureCompensation = -0.3, -- below 0 darkens the whole picture a bit
	EnvironmentDiffuseScale = 0.4, -- light bouncing off the sky
	EnvironmentSpecularScale = 0.3, -- shiny reflections on marble/metal
	ClockTime = 14, -- 2 PM
}

local BLOOM = {
	Intensity = 0.25, -- how much bright things glow
	Size = 20,
	Threshold = 2.5, -- only very bright things glow
}

function LightingSetup.Start()
	for property, value in SETTINGS do
		Lighting[property] = value
	end

	local bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	for property, value in BLOOM do
		bloom[property] = value
	end

	-- Sun rays add a lot of glare, so tone them down if the place has them.
	local sunRays = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
	if sunRays then
		sunRays.Intensity = 0.03
	end
end

return LightingSetup
