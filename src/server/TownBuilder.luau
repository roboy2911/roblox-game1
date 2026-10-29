-- Builds the town around the shops: grass, street, sidewalks, lamps, trees,
-- hedges, benches, and a fountain plaza with a "PAWN STREET" arch.
-- The street runs north-south along x = 0. Shops line both sides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Build = require(script.Parent.Build)
local Props = require(script.Parent.Props)

local C = Build.Colors
local M = Enum.Material
local V = Vector3.new

local TownBuilder = {}

local SIDES = { -1, 1 }
local SIDEWALK_TOP = 0.7
local SHOP_HALF_DEPTH = 17
local SHOP_FRONT = Config.StreetToShop - SHOP_HALF_DEPTH -- distance from street middle to shop fronts
local SHOP_BACK = Config.StreetToShop + SHOP_HALF_DEPTH

-- Props, each built facing `cf.LookVector` --------------------------------

local function tree(parent, base: Vector3)
	-- Each tree is turned a different (but always the same) amount so they don't look copy-pasted
	local turn = math.rad((base.X * 37 + base.Z * 53) % 360)
	if Props.Place(parent, "Tree", CFrame.new(base) * CFrame.Angles(0, turn, 0)) then
		return
	end
	local m = Build.model(parent, "Tree")
	local b = Build.at(CFrame.new(base))
	b.column(m, "Trunk", 1.2, 6, V(0, 0, 0), C.Trunk, M.Wood)
	b.ball(m, "Leaves", 6, V(0, 7.5, 0), C.Leaf)
	b.ball(m, "Leaves", 4.2, V(1.8, 6.2, 0.8), C.DarkLeaf)
	b.ball(m, "Leaves", 4, V(-1.6, 6.5, -0.9), C.Leaf)
end

-- Street lamp; the arm reaches out in the direction cf is facing.
local function lamp(parent, cf: CFrame)
	if Props.Place(parent, "StreetLamp", cf, { light = { 20, 0.6 } }) then
		return
	end
	local m = Build.model(parent, "StreetLamp")
	local b = Build.at(cf)
	b.column(m, "Base", 1.4, 0.6, V(0, 0, 0), C.DarkMetal, M.Metal)
	b.column(m, "Pole", 0.5, 12, V(0, 0.6, 0), C.DarkMetal, M.Metal)
	b.column(m, "Ring", 0.8, 0.3, V(0, 3, 0), C.Gold, M.Metal)
	b.part(m, "Arm", V(0.3, 0.3, 3), V(0, 12.3, -1.5), C.DarkMetal, M.Metal)
	b.part(m, "Cap", V(1.6, 0.5, 1.6), V(0, 12.0, -3), C.DarkMetal, M.Metal)
	local bulb = b.part(m, "Bulb", V(1, 0.8, 1), V(0, 11.4, -3), C.WarmLight, M.Neon)
	b.part(m, "Bottom", V(1.2, 0.2, 1.2), V(0, 10.9, -3), C.DarkMetal, M.Metal)
	Build.light(bulb, 20, 0.6)
end

-- Park bench; people sitting on it face the direction cf is facing.
local function bench(parent, cf: CFrame)
	if Props.Place(parent, "Bench", cf) then
		return
	end
	local m = Build.model(parent, "Bench")
	local b = Build.at(cf)
	for _, z in { -0.55, 0, 0.55 } do
		b.part(m, "Seat", V(5, 0.25, 0.5), V(0, 1.7, z), C.Wood, M.Wood)
	end
	b.part(m, "Back", V(5, 0.5, 0.25), V(0, 2.6, 0.85), C.Wood, M.Wood)
	b.part(m, "Back", V(5, 0.5, 0.25), V(0, 3.3, 0.85), C.Wood, M.Wood)
	for _, x in { -2.2, 2.2 } do
		b.part(m, "Leg", V(0.3, 1.6, 1.8), V(x, 0.8, 0), C.DarkMetal, M.Metal)
		b.part(m, "BackPost", V(0.3, 2, 0.3), V(x, 2.6, 0.85), C.DarkMetal, M.Metal)
	end
end

-- Hedge: a plain part, covered by a row of detailed hedge pieces when they're uploaded.
local function hedge(parent, name, from: Vector3, to: Vector3, width: number)
	local b = Build.at(CFrame.identity)
	local length = (to - from).Magnitude
	local size = if math.abs(to.X - from.X) > 0 then V(length, 3, width) else V(width, 3, length)
	local part = b.part(parent, name, size, (from + to) / 2 + V(0, 1.5, 0), C.DarkLeaf)
	local across = (to - from).Unit:Cross(Vector3.yAxis)
	if Props.Row(parent, "Hedge", from, to, across, 8, { collide = false }) then
		part.Transparency = 1
		part.CastShadow = false
	end
end

-- Street and sidewalks -----------------------------------------------------

local function buildStreet(town, length)
	local b = Build.at(CFrame.identity)
	-- Grass covers the street area, the plaza at the south end, and a border all around
	b.part(town, "Grass", V((SHOP_BACK + 40) * 2, 0.2, length + 100), V(0, 0.1, -20), C.Grass, M.Grass)
	b.part(town, "Street", V(24, 0.2, length), V(0, 0.3, 0), C.Asphalt, M.Asphalt)

	-- Dashed yellow middle line and white edge lines
	local half = length / 2
	for z = -half + 5, half - 5, 10 do
		b.part(town, "CenterLine", V(0.5, 0.05, 5), V(0, 0.425, z), C.Yellow)
	end
	for _, s in SIDES do
		b.part(town, "EdgeLine", V(0.35, 0.05, length), V(s * 10.8, 0.425, 0), C.White)
		b.part(town, "Sidewalk", V(8, 0.5, length), V(s * 16, 0.45, 0), C.Concrete, M.Concrete)
		b.part(town, "Curb", V(0.6, 0.55, length), V(s * 12.3, 0.475, 0), C.Marble)
	end

	-- Detailed road and sidewalk pieces, lined up along the street (the plain parts stay as the floor)
	local road = Props.Row(town, "Road", V(0, 0.2, -half), V(0, 0.2, half), V(1, 0, 0), 8, { collide = false })
	if road then
		Props.Hide(town, { Street = true, CenterLine = true, EdgeLine = true })
	end
	for _, s in SIDES do
		local from, to = V(s * 16, 0.2, -half), V(s * 16, 0.2, half)
		if Props.Row(town, "Sidewalk", from, to, V(-s, 0, 0), 8, { collide = false }) then
			Props.Hide(town, { Sidewalk = true, Curb = true })
		end
	end
end

-- Hedges, trees, lamps and benches along the street -------------------------

local function buildStreetProps(town, rowZs, spacing)
	local props = Build.model(town, "StreetProps")
	local b = Build.at(CFrame.identity)

	-- Between shops (and at both ends): hedge, tree, lamp
	local firstGap = rowZs[1] - spacing / 2
	for i = 0, #rowZs do
		local z = firstGap + i * spacing
		for _, s in SIDES do
			hedge(props, "Hedge", V(s * SHOP_FRONT, 0.2, z), V(s * SHOP_BACK, 0.2, z), 2)
			tree(props, V(s * (SHOP_FRONT - 3), 0.2, z))
			local pos = V(s * 18.5, SIDEWALK_TOP, z)
			lamp(props, CFrame.lookAt(pos, pos - V(s, 0, 0)))
		end
	end

	-- Hedge along the back of the shops, with a row of trees behind it
	local half = (#rowZs * spacing + 24) / 2
	for _, s in SIDES do
		hedge(props, "BackHedge", V(s * (SHOP_BACK + 3), 0.2, -half), V(s * (SHOP_BACK + 3), 0.2, half), 2)
		for z = -half + 8, half - 8, 30 do
			tree(props, V(s * (SHOP_BACK + 14), 0.2, z))
		end
	end

	-- One bench on the sidewalk in front of each shop, facing the street
	for _, z in rowZs do
		for _, s in SIDES do
			local pos = V(s * 18.8, SIDEWALK_TOP, z + 12)
			bench(props, CFrame.lookAt(pos, pos - V(s, 0, 0)))
		end
	end
end

-- Fountain plaza at the south end of the street -----------------------------

local function buildPlaza(town, streetEndZ)
	local plaza = Build.model(town, "Plaza")
	local b = Build.at(CFrame.identity)
	local cz = streetEndZ - 20
	local top = 0.7

	b.part(plaza, "Floor", V(60, top, 40), V(0, top / 2, cz), C.Plaza, M.Marble)
	b.column(plaza, "GoldRing", 22, 0.05, V(0, top, cz), C.Gold, M.Metal)
	if Props.Place(plaza, "PlazaFloor", CFrame.new(0, 0, cz), { collide = false }) then
		Props.Hide(plaza, { Floor = true, GoldRing = true })
	end

	-- Fountain (the glowing spout with the spray stays a part either way)
	local spoutY = 8.1
	if Props.Place(plaza, "Fountain", CFrame.new(0, top, cz)) then
		spoutY = top + 7.55
	else
		b.column(plaza, "Basin", 16, 2, V(0, top, cz), C.Marble, M.Marble)
		b.column(plaza, "Water", 14.4, 0.3, V(0, 2.5, cz), C.Water, M.Glass, { transparency = 0.3 })
		b.column(plaza, "Pillar", 2, 4, V(0, 2.7, cz), C.Marble, M.Marble)
		b.column(plaza, "Bowl", 6, 0.8, V(0, 6.7, cz), C.Gold, M.Metal)
		b.column(plaza, "BowlWater", 5.2, 0.2, V(0, 7.4, cz), C.Water, M.Glass, { transparency = 0.3 })
	end
	local spout = b.ball(plaza, "Spout", 1.2, V(0, spoutY, cz), Color3.fromRGB(150, 220, 255), M.Neon)

	local spray = Instance.new("ParticleEmitter")
	spray.Color = ColorSequence.new(Color3.fromRGB(170, 225, 255))
	spray.LightEmission = 0.3
	spray.Size = NumberSequence.new(0.4, 0.15)
	spray.Transparency = NumberSequence.new(0.2, 1)
	spray.Lifetime = NumberRange.new(0.8, 1.2)
	spray.Rate = 60
	spray.Speed = NumberRange.new(10, 12)
	spray.SpreadAngle = Vector2.new(20, 20)
	spray.Acceleration = V(0, -30, 0)
	spray.Parent = spout

	-- "PAWN STREET" arch where the street meets the plaza
	for _, s in SIDES do
		b.part(plaza, "ArchBase", V(2.6, 1, 2.6), V(s * 14, top + 0.5, streetEndZ), C.Marble, M.Marble)
		b.column(plaza, "ArchPillar", 2, 13, V(s * 14, top + 1, streetEndZ), C.Marble, M.Marble)
		b.part(plaza, "ArchTop", V(2.6, 0.8, 2.6), V(s * 14, top + 14.4, streetEndZ), C.Gold, M.Metal)
	end
	local archSign = b.part(plaza, "ArchSign", V(31, 3, 1), V(0, 16.5, streetEndZ), Color3.fromRGB(140, 80, 220))
	Build.text(archSign, Enum.NormalId.Front, "PAWN STREET", C.Gold, { stroke = C.DarkMarble })
	Build.text(archSign, Enum.NormalId.Back, "PAWN STREET", C.Gold, { stroke = C.DarkMarble })
	b.part(plaza, "ArchTrim", V(31.4, 0.4, 1.2), V(0, 18.2, streetEndZ), C.Gold, M.Metal)
	b.part(plaza, "ArchTrim", V(31.4, 0.4, 1.2), V(0, 14.8, streetEndZ), C.Gold, M.Metal)
	if Props.Place(plaza, "Arch", CFrame.new(0, top, streetEndZ), { collide = false }) then
		Props.Hide(plaza, { ArchBase = true, ArchPillar = true, ArchTop = true, ArchTrim = true })
	end

	-- Benches around the fountain, facing it
	local center = V(0, top, cz)
	for k = 0, 3 do
		local angle = math.rad(45 + k * 90)
		local pos = center + V(12 * math.cos(angle), 0, 12 * math.sin(angle))
		bench(plaza, CFrame.lookAt(pos, center))
	end

	-- Lamps in the corners and trees on the sides
	for _, s in SIDES do
		for _, dz in { 16, -16 } do
			local pos = V(s * 26, top, cz + dz)
			lamp(plaza, CFrame.lookAt(pos, center))
		end
		tree(plaza, V(s * 26, top, cz))
	end

	return V(0, top, streetEndZ - 6) -- a good spawn spot just inside the plaza
end

-- Builds everything. rowZs = the z position of each row of shops.
function TownBuilder.Build(parent, rowZs)
	local town = Build.model(parent, "Town")
	local spacing = Config.PlotSpacing
	local length = #rowZs * spacing + 24

	buildStreet(town, length)
	buildStreetProps(town, rowZs, spacing)
	local spawnSpot = buildPlaza(town, -length / 2)

	-- Move the default spawn into the plaza so it isn't sitting in the road.
	-- (Players are sent to their own shop right after spawning anyway.)
	local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		spawn.CFrame = CFrame.new(spawnSpot + V(0, spawn.Size.Y / 2, 0))
	end

	return town
end

return TownBuilder
