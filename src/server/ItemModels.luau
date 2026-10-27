-- 3D models for every item, built from parts.
-- Each model sits with its bottom at y = 0, centered, with its front facing -Z.

local Build = require(script.Parent.Build)

local C = Build.Colors
local M = Enum.Material
local V = Vector3.new
local rgb = Color3.fromRGB

local ItemModels = {}

local builders = {}

-- Junk -----------------------------------------------------------------------

function builders.RubberDuck(b, m)
	local yellow = rgb(255, 215, 40)
	b.ball(m, "Body", 1, V(0, 0.5, 0.1), yellow)
	b.ball(m, "Tail", 0.4, V(0, 0.75, 0.55), yellow)
	b.ball(m, "Head", 0.7, V(0, 1.15, -0.25), yellow)
	b.part(m, "Beak", V(0.35, 0.12, 0.35), V(0, 1.08, -0.65), rgb(255, 130, 30))
	for _, x in { -0.15, 0.15 } do
		b.ball(m, "Eye", 0.12, V(x, 1.3, -0.55), C.DarkMetal)
	end
end

function builders.OldBoot(b, m)
	local leather = rgb(110, 75, 45)
	b.part(m, "Sole", V(0.9, 0.2, 2), V(0, 0.1, 0), C.DarkMetal)
	b.part(m, "Foot", V(0.85, 0.6, 1.8), V(0, 0.5, 0.05), leather, M.Leather)
	b.ball(m, "Toe", 0.85, V(0, 0.45, -0.85), leather, M.Leather)
	b.part(m, "Shaft", V(0.85, 1.3, 0.9), V(0, 1.4, 0.5), leather, M.Leather)
	b.part(m, "Laces", V(0.5, 0.05, 0.6), V(0, 0.82, -0.3), rgb(220, 210, 190))
	b.part(m, "Hole", V(0.3, 0.02, 0.3), V(0.1, 0.11, 0.5), rgb(30, 30, 30), nil, { rot = V(0, 30, 0) })
end

function builders.TinCan(b, m)
	b.column(m, "Can", 0.8, 1.1, V(0, 0, 0), C.Steel, M.Metal)
	b.column(m, "Label", 0.82, 0.6, V(0, 0.25, 0), rgb(200, 50, 50))
	b.column(m, "Lid", 0.7, 0.05, V(0, 1.1, 0), rgb(140, 145, 155), M.Metal)
end

-- Common ---------------------------------------------------------------------

function builders.Toaster(b, m)
	b.part(m, "Body", V(1.4, 1, 0.8), V(0, 0.5, 0), C.Steel, M.Metal)
	b.part(m, "Base", V(1.5, 0.12, 0.9), V(0, 0.06, 0), C.DarkMetal)
	for _, z in { -0.18, 0.18 } do
		b.part(m, "Slot", V(0.9, 0.04, 0.15), V(0, 1.0, z), C.DarkMetal)
	end
	b.part(m, "Toast", V(0.75, 0.55, 0.12), V(0, 1.2, -0.18), rgb(215, 160, 90))
	b.part(m, "Lever", V(0.12, 0.15, 0.3), V(0.75, 0.7, 0), C.DarkMetal)
end

function builders.DeskLamp(b, m)
	local color = rgb(60, 140, 220)
	b.column(m, "Base", 1, 0.15, V(0, 0, 0), color)
	b.part(m, "Pole", V(0.12, 1.4, 0.12), V(0, 0.85, 0.2), C.Steel, M.Metal)
	b.part(m, "Arm", V(0.12, 0.12, 1.1), V(0, 1.55, -0.3), C.Steel, M.Metal)
	b.part(m, "Shade", V(0.7, 0.45, 0.7), V(0, 1.38, -0.85), color)
	b.ball(m, "Bulb", 0.3, V(0, 1.12, -0.85), C.WarmLight, M.Neon)
end

function builders.TeddyBear(b, m)
	local fur = rgb(170, 110, 65)
	local light = rgb(225, 185, 140)
	b.ball(m, "Body", 1, V(0, 0.6, 0), fur, M.Fabric)
	b.ball(m, "Belly", 0.6, V(0, 0.55, -0.25), light, M.Fabric)
	b.ball(m, "Head", 0.8, V(0, 1.35, 0), fur, M.Fabric)
	b.ball(m, "Snout", 0.35, V(0, 1.27, -0.35), light, M.Fabric)
	b.ball(m, "Nose", 0.12, V(0, 1.33, -0.52), C.DarkMetal)
	for _, s in { -1, 1 } do
		b.ball(m, "Ear", 0.32, V(s * 0.3, 1.7, 0), fur, M.Fabric)
		b.ball(m, "Eye", 0.1, V(s * 0.15, 1.45, -0.34), C.DarkMetal)
		b.ball(m, "Arm", 0.4, V(s * 0.5, 0.75, -0.1), fur, M.Fabric)
		b.ball(m, "Leg", 0.45, V(s * 0.3, 0.22, -0.3), fur, M.Fabric)
	end
	b.part(m, "Bow", V(0.5, 0.15, 0.1), V(0, 0.98, -0.38), rgb(220, 50, 70))
end

function builders.Skateboard(b, m)
	b.part(m, "Deck", V(0.8, 0.12, 2.8), V(0, 0.36, 0), rgb(255, 90, 60), M.Wood)
	b.part(m, "Grip", V(0.76, 0.02, 2.6), V(0, 0.43, 0), C.DarkMetal)
	for _, z in { -1, 1 } do
		b.part(m, "Truck", V(0.6, 0.1, 0.2), V(0, 0.26, z), C.Steel, M.Metal)
		for _, x in { -0.35, 0.35 } do
			b.part(m, "Wheel", V(0.15, 0.32, 0.32), V(x, 0.16, z), rgb(250, 240, 120), nil, { shape = "Cylinder" })
		end
	end
end

function builders.OldRadio(b, m)
	b.part(m, "Body", V(1.4, 0.9, 0.6), V(0, 0.45, 0), C.Wood, M.Wood)
	b.part(m, "Top", V(1.45, 0.1, 0.65), V(0, 0.92, 0), C.DarkWood, M.Wood)
	b.disc(m, "Speaker", 0.6, 0.05, V(-0.3, 0.45, -0.31), rgb(215, 195, 155), M.Fabric)
	b.disc(m, "Dial", 0.3, 0.08, V(0.4, 0.58, -0.32), C.Gold, M.Metal)
	b.disc(m, "Knob", 0.18, 0.1, V(0.4, 0.25, -0.33), C.DarkMetal)
	b.part(m, "Antenna", V(0.05, 1, 0.05), V(0.65, 1.4, 0.15), C.Steel, M.Metal, { rot = V(0, 0, -20) })
end

-- Uncommon -------------------------------------------------------------------

function builders.Camera(b, m)
	b.part(m, "Body", V(1.2, 0.75, 0.5), V(0, 0.38, 0), C.DarkMetal)
	b.part(m, "Grip", V(1.22, 0.4, 0.52), V(0, 0.3, 0), rgb(110, 75, 50), M.Leather)
	b.part(m, "Top", V(0.5, 0.25, 0.4), V(0, 0.88, 0), C.Steel, M.Metal)
	b.disc(m, "Lens", 0.55, 0.4, V(0, 0.4, -0.42), rgb(30, 30, 35))
	b.disc(m, "LensGlass", 0.4, 0.05, V(0, 0.4, -0.63), rgb(120, 170, 230), M.Glass, { reflectance = 0.3 })
	b.part(m, "Button", V(0.15, 0.08, 0.15), V(0.4, 0.79, 0), rgb(220, 50, 50))
end

function builders.Trumpet(b, m)
	local brass = C.Gold
	b.part(m, "Pipe", V(0.18, 0.18, 2), V(0, 0.6, 0), brass, M.Metal)
	b.part(m, "LowerPipe", V(0.18, 0.18, 1.2), V(0, 0.25, 0.2), brass, M.Metal)
	b.part(m, "Bend", V(0.18, 0.53, 0.18), V(0, 0.42, 0.8), brass, M.Metal)
	b.disc(m, "BellOuter", 0.8, 0.15, V(0, 0.6, -1.05), brass, M.Metal)
	b.disc(m, "BellInner", 0.6, 0.35, V(0, 0.6, -0.85), brass, M.Metal)
	for _, z in { -0.2, 0, 0.2 } do
		b.column(m, "Valve", 0.15, 0.5, V(0, 0.45, z), brass, M.Metal)
		b.column(m, "ValveCap", 0.2, 0.08, V(0, 0.95, z), rgb(240, 240, 240))
	end
	b.disc(m, "Mouthpiece", 0.2, 0.15, V(0, 0.6, 1.05), C.Steel, M.Metal)
end

function builders.AcousticGuitar(b, m)
	local wood = rgb(225, 165, 90)
	b.part(m, "Body", V(1.4, 1.6, 0.4), V(0, 0.8, 0), wood, M.Wood)
	b.part(m, "UpperBody", V(1.1, 0.9, 0.4), V(0, 2.0, 0), wood, M.Wood)
	b.disc(m, "SoundHole", 0.45, 0.05, V(0, 1.65, -0.21), C.DarkMetal)
	b.part(m, "Bridge", V(0.6, 0.1, 0.05), V(0, 0.7, -0.22), C.DarkWood, M.Wood)
	b.part(m, "Neck", V(0.25, 1.8, 0.15), V(0, 3.35, 0), C.DarkWood, M.Wood)
	b.part(m, "Head", V(0.4, 0.55, 0.18), V(0, 4.5, 0), C.DarkWood, M.Wood)
end

function builders.GameConsole(b, m)
	b.part(m, "Console", V(1.4, 0.35, 1), V(0, 0.18, 0.2), rgb(70, 70, 85))
	b.part(m, "Light", V(0.2, 0.05, 0.05), V(0.5, 0.25, -0.31), rgb(80, 255, 120), M.Neon)
	b.part(m, "Slot", V(0.8, 0.02, 0.1), V(0, 0.36, 0.1), C.DarkMetal)
	b.part(m, "Controller", V(0.8, 0.15, 0.4), V(0, 0.08, -0.65), rgb(40, 40, 50))
	for _, s in { -1, 1 } do
		b.ball(m, "Handle", 0.35, V(s * 0.38, 0.1, -0.6), rgb(40, 40, 50))
	end
	local buttonColors = { rgb(240, 60, 60), rgb(60, 200, 90), rgb(60, 120, 240), rgb(250, 210, 50) }
	for i, offset in { V(0.15, 0, -0.08), V(0.25, 0, 0), V(0.15, 0, 0.08), V(0.05, 0, 0) } do
		b.part(m, "Button", V(0.06, 0.04, 0.06), V(0.08, 0.17, -0.65) + offset, buttonColors[i], M.Neon)
	end
	b.part(m, "DPad", V(0.18, 0.04, 0.06), V(-0.2, 0.17, -0.65), C.DarkMetal)
	b.part(m, "DPad", V(0.06, 0.04, 0.18), V(-0.2, 0.17, -0.65), C.DarkMetal)
end

-- Rare -----------------------------------------------------------------------

function builders.GoldWatch(b, m)
	b.part(m, "Stand", V(0.9, 0.2, 0.7), V(0, 0.1, 0), C.DarkMarble)
	b.part(m, "Cushion", V(0.45, 0.5, 0.4), V(0, 0.45, 0.05), rgb(130, 30, 50), M.Fabric)
	b.part(m, "StrapTop", V(0.38, 0.45, 0.08), V(0, 1.05, 0.0), C.Gold, M.Metal)
	b.part(m, "StrapBottom", V(0.38, 0.45, 0.08), V(0, 0.45, -0.18), C.Gold, M.Metal)
	b.disc(m, "Case", 0.75, 0.15, V(0, 0.75, -0.08), C.Gold, M.Metal, { reflectance = 0.25 })
	b.disc(m, "Face", 0.6, 0.05, V(0, 0.75, -0.17), C.White)
	b.part(m, "HourHand", V(0.04, 0.18, 0.02), V(0, 0.82, -0.2), C.DarkMetal)
	b.part(m, "MinuteHand", V(0.03, 0.25, 0.02), V(0.09, 0.78, -0.2), C.DarkMetal, nil, { rot = V(0, 0, -110) })
	b.part(m, "Crown", V(0.08, 0.08, 0.08), V(0.4, 0.75, -0.08), C.Gold, M.Metal)
end

function builders.ElectricGuitar(b, m)
	local red = rgb(210, 30, 50)
	b.part(m, "Body", V(1.3, 1.4, 0.3), V(0, 0.75, 0), red)
	for _, s in { -1, 1 } do
		b.part(m, "Horn", V(0.35, 0.55, 0.3), V(s * 0.45, 1.7, 0), red)
	end
	b.part(m, "Pickguard", V(0.5, 0.6, 0.04), V(0.32, 0.55, -0.17), C.White)
	for _, y in { 0.7, 1.05 } do
		b.part(m, "Pickup", V(0.35, 0.1, 0.05), V(-0.15, y, -0.18), C.DarkMetal)
	end
	b.part(m, "Bridge", V(0.35, 0.08, 0.05), V(-0.15, 0.4, -0.18), C.Steel, M.Metal)
	b.part(m, "Neck", V(0.22, 1.9, 0.12), V(0, 2.4, 0), C.LightWood, M.Wood)
	b.part(m, "Head", V(0.35, 0.5, 0.15), V(0, 3.6, 0), C.DarkMetal)
end

function builders.Katana(b, m)
	b.part(m, "Stand", V(3, 0.2, 0.6), V(0, 0.1, 0), C.DarkWood, M.Wood)
	for _, x in { -0.9, 0.9 } do
		b.part(m, "Post", V(0.15, 0.6, 0.3), V(x, 0.5, 0), C.DarkWood, M.Wood)
	end
	b.part(m, "Blade", V(2.4, 0.08, 0.16), V(0.3, 0.85, 0), C.Steel, M.Metal, { reflectance = 0.35 })
	b.part(m, "Tip", V(0.2, 0.08, 0.09), V(1.6, 0.85, -0.03), C.Steel, M.Metal, { reflectance = 0.35 })
	b.part(m, "Guard", V(0.08, 0.45, 0.45), V(-0.94, 0.85, 0), C.Gold, M.Metal, { shape = "Cylinder" })
	b.part(m, "Handle", V(0.8, 0.13, 0.13), V(-1.4, 0.85, 0), C.DarkMetal, M.Fabric)
end

function builders.Painting(b, m)
	b.part(m, "Easel", V(0.1, 2.2, 0.1), V(0, 1.05, 0.35), C.DarkWood, M.Wood, { rot = V(-15, 0, 0) })
	b.part(m, "Frame", V(1.8, 1.4, 0.15), V(0, 1.3, 0), C.Gold, M.Metal)
	b.part(m, "Sky", V(1.5, 1.1, 0.05), V(0, 1.3, -0.09), rgb(255, 170, 90))
	b.ball(m, "Sun", 0.35, V(0.35, 1.5, -0.1), rgb(255, 235, 120))
	b.part(m, "Sea", V(1.5, 0.45, 0.06), V(0, 0.98, -0.1), rgb(60, 110, 190))
	b.part(m, "Ledge", V(1.8, 0.1, 0.4), V(0, 0.55, -0.1), C.DarkWood, M.Wood)
	for _, x in { -0.7, 0.7 } do
		b.part(m, "Leg", V(0.1, 0.55, 0.1), V(x, 0.27, -0.1), C.DarkWood, M.Wood)
	end
end

-- Epic -----------------------------------------------------------------------

function builders.DiamondRing(b, m)
	local velvet = rgb(150, 20, 45)
	b.part(m, "Box", V(0.9, 0.55, 0.9), V(0, 0.28, 0), velvet, M.Fabric)
	b.part(m, "Lid", V(0.9, 0.75, 0.1), V(0, 0.95, 0.45), velvet, M.Fabric)
	b.part(m, "Cushion", V(0.7, 0.1, 0.7), V(0, 0.58, 0), C.White, M.Fabric)
	b.part(m, "Trim", V(0.92, 0.05, 0.92), V(0, 0.55, 0), C.Gold, M.Metal)
	b.disc(m, "Band", 0.45, 0.1, V(0, 0.82, 0), C.Gold, M.Metal, { reflectance = 0.3 })
	b.disc(m, "BandHole", 0.3, 0.12, V(0, 0.82, 0), C.White, M.Fabric)
	b.ball(m, "Diamond", 0.28, V(0, 1.1, 0), rgb(200, 240, 255), M.Glass, { reflectance = 0.4, transparency = 0.1 })
end

function builders.GoldTrophy(b, m)
	b.part(m, "Base", V(1, 0.35, 1), V(0, 0.18, 0), C.DarkMarble, M.Marble)
	b.part(m, "Plaque", V(0.6, 0.18, 0.02), V(0, 0.18, -0.51), C.Gold, M.Metal)
	b.column(m, "Stem", 0.25, 0.6, V(0, 0.35, 0), C.Gold, M.Metal)
	b.column(m, "StemTop", 0.5, 0.12, V(0, 0.9, 0), C.Gold, M.Metal)
	b.column(m, "Cup", 1, 0.9, V(0, 1.0, 0), C.Gold, M.Metal, { reflectance = 0.25 })
	b.column(m, "Rim", 1.1, 0.1, V(0, 1.9, 0), C.Gold, M.Metal, { reflectance = 0.25 })
	for _, s in { -1, 1 } do
		b.part(m, "Handle", V(0.15, 0.6, 0.15), V(s * 0.65, 1.45, 0), C.Gold, M.Metal)
		b.part(m, "HandleTop", V(0.25, 0.12, 0.15), V(s * 0.57, 1.75, 0), C.Gold, M.Metal)
		b.part(m, "HandleBottom", V(0.25, 0.12, 0.15), V(s * 0.57, 1.15, 0), C.Gold, M.Metal)
	end
	b.ball(m, "Star", 0.3, V(0, 1.45, -0.5), rgb(255, 245, 200), M.Neon)
end

function builders.AntiqueVase(b, m)
	local porcelain = rgb(245, 245, 250)
	local blue = rgb(40, 80, 180)
	b.column(m, "Foot", 0.7, 0.2, V(0, 0, 0), blue)
	b.ball(m, "Body", 1.3, V(0, 0.85, 0), porcelain)
	b.column(m, "Band", 1.32, 0.15, V(0, 0.75, 0), blue)
	b.column(m, "GoldBand", 1.2, 0.08, V(0, 1.15, 0), C.Gold, M.Metal)
	b.column(m, "Neck", 0.5, 0.6, V(0, 1.4, 0), porcelain)
	b.column(m, "NeckBand", 0.52, 0.12, V(0, 1.7, 0), blue)
	b.column(m, "Lip", 0.75, 0.15, V(0, 2.0, 0), blue)
	for _, s in { -1, 1 } do
		b.ball(m, "Flower", 0.25, V(s * 0.66, 0.85, -0.05), blue)
	end
	b.ball(m, "Flower", 0.25, V(0, 0.85, -0.66), blue)
end

-- Legendary ------------------------------------------------------------------

function builders.RoyalCrown(b, m)
	b.part(m, "Pillow", V(1.6, 0.35, 1.6), V(0, 0.18, 0), rgb(150, 20, 45), M.Fabric)
	b.column(m, "Ring", 1.2, 0.5, V(0, 0.35, 0), C.Gold, M.Metal, { reflectance = 0.3 })
	b.ball(m, "Velvet", 1, V(0, 0.9, 0), rgb(170, 25, 50), M.Fabric)
	local gemColors = { rgb(230, 40, 60), rgb(50, 110, 240), rgb(60, 210, 120) }
	for k = 0, 5 do
		local angle = math.rad(k * 60)
		local x, z = math.cos(angle), math.sin(angle)
		b.part(m, "Point", V(0.22, 0.5, 0.22), V(x * 0.55, 1.05, z * 0.55), C.Gold, M.Metal, { rot = V(0, -k * 60, 0) })
		b.ball(m, "PointBall", 0.18, V(x * 0.55, 1.35, z * 0.55), C.Gold, M.Metal)
		b.ball(m, "Gem", 0.18, V(x * 0.62, 0.6, z * 0.62), gemColors[k % 3 + 1], M.Glass, { reflectance = 0.3 })
	end
	b.part(m, "CrossV", V(0.08, 0.35, 0.08), V(0, 1.55, 0), C.Gold, M.Metal)
	b.part(m, "CrossH", V(0.22, 0.08, 0.08), V(0, 1.6, 0), C.Gold, M.Metal)
end

function builders.GoldenStatue(b, m)
	local gold = { reflectance = 0.25 }
	b.part(m, "Pedestal", V(1.2, 0.5, 1.2), V(0, 0.25, 0), C.Marble, M.Marble)
	b.part(m, "PedestalTrim", V(1.3, 0.1, 1.3), V(0, 0.5, 0), C.Gold, M.Metal)
	for _, s in { -1, 1 } do
		b.part(m, "Leg", V(0.22, 0.8, 0.25), V(s * 0.15, 0.95, 0), C.Gold, M.Metal, gold)
	end
	b.part(m, "Torso", V(0.6, 0.75, 0.35), V(0, 1.72, 0), C.Gold, M.Metal, gold)
	b.ball(m, "Head", 0.45, V(0, 2.32, 0), C.Gold, M.Metal, gold)
	b.part(m, "ArmDown", V(0.18, 0.7, 0.18), V(-0.4, 1.65, 0), C.Gold, M.Metal, gold)
	b.part(m, "ArmUp", V(0.18, 0.7, 0.18), V(0.42, 2.35, 0), C.Gold, M.Metal, gold)
	b.ball(m, "Torch", 0.3, V(0.42, 2.8, 0), rgb(255, 160, 40), M.Neon)
end

function builders.Meteorite(b, m)
	local rock = rgb(70, 60, 80)
	local glow = rgb(170, 90, 255)
	b.column(m, "Stand", 1.2, 0.3, V(0, 0, 0), C.DarkMarble, M.Marble)
	b.column(m, "StandTrim", 1.25, 0.06, V(0, 0.3, 0), C.Gold, M.Metal)
	b.ball(m, "Rock", 1.1, V(0, 0.85, 0), rock, M.Basalt)
	b.ball(m, "Rock", 0.75, V(0.3, 1.1, 0.15), rock, M.Basalt)
	b.ball(m, "Rock", 0.6, V(-0.3, 0.75, -0.2), rock, M.Basalt)
	for _, pos in { V(0.1, 0.9, -0.5), V(-0.45, 1.0, 0.1), V(0.4, 1.35, -0.15), V(0.15, 0.6, 0.45) } do
		b.ball(m, "Crystal", 0.22, pos, glow, M.Neon)
	end
end

-- Public functions -----------------------------------------------------------

-- Builds the model for `id` at `cf` (cf = where the bottom-center of the item goes).
function ItemModels.Build(id: string, cf: CFrame): Model
	local model = Instance.new("Model")
	model.Name = id
	local builder = builders[id]
	if builder then
		builder(Build.at(cf), model)
	else
		warn(`[ItemModels] No model for item "{id}", using a box.`)
		Build.at(cf).part(model, "Box", V(1, 1, 1), V(0, 0.5, 0), C.Cardboard, M.Cardboard)
	end
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
	return model
end

function ItemModels.Has(id: string): boolean
	return builders[id] ~= nil
end

return ItemModels
