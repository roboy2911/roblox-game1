-- Builds one pawn shop out of parts: bright cartoony colors with fancy marble + gold.
--
-- Layout (relative to the shop's center, in studs):
--   X: -20 .. 20    Z: -17 (front, door side) .. 33 (back)    Y: floor top is 1
-- One big room. The checkout is a closed-in island of counters in the middle (x -10..10, z 3..17)
-- with its gate on the back side; aisles down both sides lead to the back area (z 18..32), which
-- is roped off until the owner buys the Bigger shop upgrade. Customers come in the front door
-- and stand at the register on the front counter.

local Build = require(script.Parent.Build)
local Props = require(script.Parent.Props)

local C = Build.Colors
local M = Enum.Material
local V = Vector3.new

local ShopBuilder = {}

local SIDES = { -1, 1 } -- left, right

-- Plain parts that the detailed meshes cover. When a mesh loads, these are hidden but stay solid,
-- so walking, item spots and later scripts keep working the same.
local function names(list)
	local set = {}
	for _, name in list do
		set[name] = true
	end
	return set
end
local EXTERIOR_PARTS = names({
	"Floor", "Tile", "BackWall", "LeftWall", "RightWall", "FrontWall", "UnderWindow", "OverWindow",
	"Window", "WindowFrame", "WindowBar", "WindowSill", "BaseStrip", "RoofTrim", "AboveDoor", "Ceiling",
	"Roof", "Parapet", "ParapetCap", "SignFrame", "NeonStrip", "Awning", "AwningEdge", "DoorFrame",
	"Door", "DoorEdge", "Threshold", "Path", "PillarBase", "Pillar", "PillarTop",
})
local INTERIOR_PARTS = names({
	"Wainscot", "Rail", "RugBorder", "Rug", "CeilingLight", "GuitarBoard", "Body", "UpperBody", "SoundHole",
	"Neck", "Head", "PaintingFrame", "PaintingSky",
	"PaintingHills", "Box",
})
local COUNTER_PARTS = names({ "Body", "Panel", "Kick", "Top", "TopEdge", "CounterPost" })
local CASE_PARTS = names({ "Base", "Kick", "DisplaySurface", "Glass", "Post", "TopBar" })
local SHELF_PARTS = names({ "Back", "Side", "Top", "Plinth", "Level1", "Level2", "Level3", "Lip" })

-- Floor, walls, windows, roof ------------------------------------------------
local function buildShell(b, m, accent)
	b.part(m, "Floor", V(40, 1, 50), V(0, 0.5, 8), C.Marble, M.Marble)

	-- Checkered marble tiles
	for ix = 0, 9 do
		for iz = 0, 11 do
			if (ix + iz) % 2 == 0 then
				b.part(m, "Tile", V(4, 0.05, 4), V(-18 + ix * 4, 1.025, -14 + iz * 4), C.DarkMarble, M.Marble)
			end
		end
	end

	b.part(m, "BackWall", V(40, 16, 1), V(0, 9, 32.5), C.Cream)
	b.part(m, "LeftWall", V(1, 16, 50), V(-19.5, 9, 8), C.Cream)
	b.part(m, "RightWall", V(1, 16, 50), V(19.5, 9, 8), C.Cream)

	-- Front wall: doorway in the middle (x -4..4), a big window on each side (x 7..16)
	for _, s in SIDES do
		b.part(m, "FrontWall", V(3, 16, 1), V(s * 5.5, 9, -16.5), C.Cream)
		b.part(m, "FrontWall", V(4, 16, 1), V(s * 18, 9, -16.5), C.Cream)
		b.part(m, "UnderWindow", V(9, 2.5, 1), V(s * 11.5, 2.25, -16.5), C.Cream)
		b.part(m, "OverWindow", V(9, 5.5, 1), V(s * 11.5, 14.25, -16.5), C.Cream)

		b.part(m, "Window", V(9, 8, 0.2), V(s * 11.5, 7.5, -16.5), C.Glass, M.Glass, { transparency = 0.55 })
		b.part(m, "WindowFrame", V(9.6, 0.4, 0.4), V(s * 11.5, 3.5, -17.2), C.Gold, M.Metal)
		b.part(m, "WindowFrame", V(9.6, 0.4, 0.4), V(s * 11.5, 11.5, -17.2), C.Gold, M.Metal)
		b.part(m, "WindowFrame", V(0.4, 8.4, 0.4), V(s * 7, 7.5, -17.2), C.Gold, M.Metal)
		b.part(m, "WindowFrame", V(0.4, 8.4, 0.4), V(s * 16, 7.5, -17.2), C.Gold, M.Metal)
		b.part(m, "WindowBar", V(0.25, 8, 0.2), V(s * 11.5, 7.5, -16.7), C.Gold, M.Metal)
		b.part(m, "WindowSill", V(10, 0.4, 1.2), V(s * 11.5, 3.2, -17.5), C.Marble, M.Marble)

		-- Colored strip along the bottom of the outside walls
		b.part(m, "BaseStrip", V(16, 1.2, 0.3), V(s * 12, 0.8, -17.15), accent)
		b.part(m, "BaseStrip", V(0.3, 1.2, 50), V(s * 20.15, 0.8, 8), accent)
		-- Gold trim along the top of the side walls
		b.part(m, "RoofTrim", V(1.2, 0.4, 50), V(s * 19.6, 18.2, 8), C.Gold, M.Metal)
	end
	b.part(m, "BaseStrip", V(40.6, 1.2, 0.3), V(0, 0.8, 33.15), accent)
	b.part(m, "RoofTrim", V(40, 0.4, 1.2), V(0, 18.2, 32.4), C.Gold, M.Metal)

	b.part(m, "AboveDoor", V(8, 6, 1), V(0, 14, -16.5), C.Cream)
	b.part(m, "Ceiling", V(38, 0.2, 48), V(0, 16.9, 8), C.Cream)
	b.part(m, "Roof", V(40, 1, 50), V(0, 17.5, 8), C.Roof, M.Slate)
end

-- Storefront: sign, awnings, door, pillars, lamps, pawn balls -----------------
local function buildFacade(b, m, shop, accent)
	-- Tall colored wall above the roof line that holds the big sign
	b.part(m, "Parapet", V(40, 5, 1), V(0, 19.5, -16.5), accent)
	b.part(m, "ParapetCap", V(40.6, 0.5, 1.6), V(0, 22.25, -16.5), C.Gold, M.Metal)

	-- The sign is a direct child of the shop so Plots can change its text.
	local sign = b.part(shop, "Sign", V(24, 4, 0.4), V(0, 19.5, -17.2), C.Marble, M.Marble)
	Build.text(sign, Enum.NormalId.Front, "For Sale", accent, { name = "OwnerText", stroke = C.White })
	b.part(m, "SignFrame", V(24.8, 0.4, 0.6), V(0, 21.7, -17.3), C.Gold, M.Metal)
	b.part(m, "SignFrame", V(24.8, 0.4, 0.6), V(0, 17.3, -17.3), C.Gold, M.Metal)
	b.part(m, "SignFrame", V(0.4, 4.8, 0.6), V(-12.2, 19.5, -17.3), C.Gold, M.Metal)
	b.part(m, "SignFrame", V(0.4, 4.8, 0.6), V(12.2, 19.5, -17.3), C.Gold, M.Metal)
	b.part(m, "NeonStrip", V(24, 0.3, 0.3), V(0, 16.6, -17.15), accent, M.Neon)

	-- Striped awnings over the windows, tilted down toward the street
	for _, s in SIDES do
		for i = 1, 10 do
			local color = if i % 2 == 0 then accent else C.White
			b.part(m, "Awning", V(1, 0.25, 4), V(s * 11.5 + (i - 5.5), 11.75, -18.81), color, M.Fabric, { rot = V(-25, 0, 0) })
		end
		b.part(m, "AwningEdge", V(10, 0.8, 0.2), V(s * 11.5, 10.5, -20.63), accent, M.Fabric)
	end

	-- Gold door frame with two glass doors swung open
	b.part(m, "DoorFrame", V(0.6, 10, 1.4), V(-3.7, 6, -16.5), C.Gold, M.Metal)
	b.part(m, "DoorFrame", V(0.6, 10, 1.4), V(3.7, 6, -16.5), C.Gold, M.Metal)
	b.part(m, "DoorFrame", V(8, 0.6, 1.4), V(0, 10.7, -16.5), C.Gold, M.Metal)
	for _, s in SIDES do
		b.part(m, "Door", V(0.3, 9.2, 3.4), V(s * 3.15, 5.7, -14.3), C.Glass, M.Glass, { transparency = 0.5 })
		b.part(m, "DoorEdge", V(0.35, 9.2, 0.3), V(s * 3.15, 5.7, -12.75), C.Gold, M.Metal)
	end
	b.part(m, "Threshold", V(8, 0.3, 1), V(0, 0.85, -17.5), C.Marble, M.Marble)
	b.part(m, "Path", V(6, 0.5, 5), V(0, 0.45, -20.5), C.Marble, M.Marble)

	-- Marble pillars with gold tops
	for _, x in { -19.5, -5.5, 5.5, 19.5 } do
		b.part(m, "PillarBase", V(2.2, 1, 2.2), V(x, 0.7, -17.6), C.Marble, M.Marble)
		b.column(m, "Pillar", 1.6, 15, V(x, 1.2, -17.6), C.Marble, M.Marble)
		b.part(m, "PillarTop", V(2.2, 0.8, 2.2), V(x, 16.6, -17.6), C.Gold, M.Metal)
	end

	-- Lanterns on the pillars next to the door
	for _, s in SIDES do
		if not Props.Place(m, "Lantern", b.cframe(V(s * 5.5, 10.25, -18.4)), { light = { 12, 0.5 }, collide = false }) then
			b.part(m, "LanternArm", V(0.3, 0.3, 0.6), V(s * 5.5, 9.5, -18.7), C.Gold, M.Metal)
			b.part(m, "LanternCap", V(1, 0.2, 1), V(s * 5.5, 10.2, -19.3), C.Gold, M.Metal)
			local bulb = b.part(m, "Lantern", V(0.7, 1, 0.7), V(s * 5.5, 9.6, -19.3), C.WarmLight, M.Neon)
			b.part(m, "LanternCap", V(1, 0.2, 1), V(s * 5.5, 9.0, -19.3), C.Gold, M.Metal)
			Build.light(bulb, 12, 0.5)
		end
	end

	-- The classic pawnbroker symbol: three gold balls hanging from a bracket
	if not Props.Place(m, "PawnBalls", b.cframe(V(16, 16, -17)), { collide = false }) then
		b.part(m, "PawnArm", V(0.4, 0.4, 3), V(16, 16, -18.5), C.Gold, M.Metal)
		b.part(m, "PawnRod", V(0.2, 1, 0.2), V(16, 15.4, -19.7), C.Gold, M.Metal)
		b.part(m, "PawnBar", V(2.2, 0.25, 0.25), V(16, 14.9, -19.7), C.Gold, M.Metal)
		b.ball(m, "PawnBall", 1.3, V(15.35, 14.1, -19.7), C.Gold, M.Metal, { reflectance = 0.25 })
		b.ball(m, "PawnBall", 1.3, V(16.65, 14.1, -19.7), C.Gold, M.Metal, { reflectance = 0.25 })
		b.ball(m, "PawnBall", 1.3, V(16, 13.0, -19.7), C.Gold, M.Metal, { reflectance = 0.25 })
	end

	-- Glowing OPEN sign inside the left window
	local open = b.part(m, "OpenSign", V(3, 1.2, 0.1), V(-9.2, 9.6, -16.25), C.DarkMetal)
	Build.text(open, Enum.NormalId.Front, "OPEN", Color3.fromRGB(255, 90, 90), { glow = true })

	-- Potted bushes on each side of the door
	for _, s in SIDES do
		if not Props.Place(m, "PottedBush", b.cframe(V(s * 8.5, 0.2, -19))) then
			b.column(m, "Pot", 2, 1.6, V(s * 8.5, 0.2, -19), C.Marble, M.Marble)
			b.column(m, "PotRim", 2.2, 0.2, V(s * 8.5, 1.8, -19), C.Gold, M.Metal)
			b.ball(m, "Bush", 2.6, V(s * 8.5, 2.9, -19), C.Leaf)
		end
	end
end

-- Checkout: a closed-in island of counters in the middle of the shop ------------
-- Front counter x -10..10, z 3..6 (register, customers stand in front of it); side counters
-- x +-(7..10), z 6..17; back counters x +-(2..10), z 14..17 with the gate between them.
local function buildCounter(b, shop, accent)
	local m = Build.model(shop, "Counter")
	local function counter(x0, x1, z0, z1)
		local center = V((x0 + x1) / 2, 0, (z0 + z1) / 2)
		local size = V(x1 - x0, 0, z1 - z0)
		b.part(m, "Body", V(size.X, 3.6, size.Z), center + V(0, 2.8, 0), C.Marble, M.Marble)
		b.part(m, "Kick", V(size.X + 0.1, 0.4, size.Z + 0.1), center + V(0, 1.2, 0), C.Gold, M.Metal)
		b.part(m, "Top", V(size.X + 0.3, 0.4, size.Z + 0.3), center + V(0, 4.8, 0), C.DarkMarble, M.Marble)
	end
	counter(-10, 10, 3, 6)
	counter(-10, -7, 6, 17)
	counter(7, 10, 6, 17)
	counter(-10, -2, 14, 17)
	counter(2, 10, 14, 17)
	for _, x in { -6, 0, 6 } do
		b.part(m, "Panel", V(4.6, 2.4, 0.2), V(x, 2.9, 2.9), accent)
	end
	for _, pos in { V(-10, 0, 3), V(10, 0, 3), V(-10, 0, 17), V(10, 0, 17), V(-2, 0, 17), V(2, 0, 17) } do
		b.part(m, "CounterPost", V(0.8, 4.4, 0.8), pos + V(0, 3.2, 0), C.Marble, M.Marble)
	end
	if Props.Place(m, "Checkout", b.cframe(V(0, 0, 0)), { accent = accent, collide = false }) then
		Props.Hide(m, COUNTER_PARTS)
	end

	-- The gate in the back side: a swinging half-door, hinged on its left end, opening inward.
	-- Only the owner opens it (ShopDoors).
	local gate = Build.model(m, "Gate")
	b.part(gate, "GateDoor", V(3.9, 3.2, 0.3), V(0, 2.8, 15.5), accent, nil, { reflectance = 0.05 })
	b.part(gate, "GateRail", V(3.9, 0.3, 0.45), V(0, 4.45, 15.5), C.Gold, M.Metal)
	b.part(gate, "GatePanel", V(3.1, 2.0, 0.34), V(0, 2.8, 15.5), C.Gold, M.Metal)
	b.part(gate, "GatePanelInner", V(2.8, 1.7, 0.38), V(0, 2.8, 15.5), accent)
	gate:SetAttribute("Hinge", b.cframe(V(-1.95, 2.8, 15.5)))

	-- Cash register on the front counter, facing customers
	if not Props.Place(m, "CashRegister", b.cframe(V(5, 5.0, 4.9)), { accent = accent }) then
		b.part(m, "Register", V(2.6, 1, 2), V(5, 5.5, 4.9), accent)
		b.part(m, "RegisterKeys", V(2.2, 0.15, 0.9), V(5, 6.075, 5.4), C.DarkMetal)
		b.part(m, "RegisterScreen", V(1.8, 1, 0.2), V(5, 6.6, 4.5), C.DarkMetal)
		b.part(m, "RegisterDisplay", V(1.5, 0.7, 0.05), V(5, 6.6, 4.38), Color3.fromRGB(110, 255, 170), M.Neon)
	end

	-- Service bell
	if not Props.Place(m, "ServiceBell", b.cframe(V(-5, 5.0, 3.9))) then
		b.column(m, "BellBase", 1, 0.2, V(-5, 5.0, 3.9), C.DarkWood, M.Wood)
		b.ball(m, "Bell", 0.9, V(-5, 5.35, 3.9), C.Gold, M.Metal, { reflectance = 0.2 })
		b.ball(m, "BellButton", 0.25, V(-5, 5.85, 3.9), C.Gold, M.Metal)
	end

	-- Inside the checkout: the safe and a retro TV
	if not Props.Place(m, "Safe", b.cframe(V(4.5, 1, 12.1))) then
		b.part(m, "Safe", V(4, 5, 3.5), V(4.5, 3.5, 12.1), C.DarkMetal, M.Metal)
		b.disc(m, "SafeDial", 1.1, 0.3, V(4.5, 4.3, 10.3), C.Gold, M.Metal)
	end
	if not Props.Place(m, "RetroTV", b.cframe(V(-4.5, 1, 12.4))) then
		b.part(m, "TVCabinet", V(4, 2.5, 2.5), V(-4.5, 2.25, 12.4), C.Wood, M.Wood)
		b.part(m, "TV", V(3.4, 2.6, 2.2), V(-4.5, 4.8, 12.4), Color3.fromRGB(60, 55, 60))
		b.part(m, "TVScreen", V(2.8, 2, 0.1), V(-4.5, 4.9, 11.25), Color3.fromRGB(35, 55, 75), M.Glass)
	end
end

-- One glass display case at (cx, cz), long side running front to back. Items go on DisplaySurface.
local function buildCase(b, parent, name, cx, cz, accent)
	local m = Build.model(parent, name)
	b.part(m, "Base", V(3, 2.6, 8), V(cx, 2.3, cz), C.Marble, M.Marble)
	b.part(m, "Kick", V(3.2, 0.3, 8.2), V(cx, 1.15, cz), C.Gold, M.Metal)
	b.part(m, "DisplaySurface", V(2.8, 0.1, 7.8), V(cx, 3.65, cz), accent, M.Fabric)
	b.part(m, "Glass", V(3, 2.4, 8), V(cx, 4.9, cz), C.Glass, M.Glass, { transparency = 0.75 })
	for _, dx in { -1.4, 1.4 } do
		for _, dz in { -3.9, 3.9 } do
			b.part(m, "Post", V(0.2, 2.4, 0.2), V(cx + dx, 4.9, cz + dz), C.Gold, M.Metal)
		end
		b.part(m, "TopBar", V(0.2, 0.2, 8), V(cx + dx, 6.1, cz), C.Gold, M.Metal)
	end
	for _, dz in { -3.9, 3.9 } do
		b.part(m, "TopBar", V(3, 0.2, 0.2), V(cx, 6.1, cz + dz), C.Gold, M.Metal)
	end
	if Props.Place(m, "DisplayCase", b.cframe(V(cx, 1, cz)), { accent = accent, collide = false }) then
		Props.Hide(m, CASE_PARTS)
	end
end

-- One wall shelf unit, its back against a wall. `cf` = bottom center, facing into the room.
-- Items go on Level1..3.
local function buildShelf(parent, name, cf: CFrame, accent)
	local m = Build.model(parent, name)
	local b = Build.at(cf)
	b.part(m, "Back", V(14, 9.4, 0.4), V(0, 4.7, 1.6), C.White)
	b.part(m, "Side", V(0.4, 9.4, 3.2), V(-7.2, 4.7, 0), C.White)
	b.part(m, "Side", V(0.4, 9.4, 3.2), V(7.2, 4.7, 0), C.White)
	b.part(m, "Top", V(14.8, 0.4, 3.4), V(0, 9.6, 0), C.White)
	b.part(m, "Plinth", V(14.4, 0.6, 3.2), V(0, 0.3, 0), accent)
	for level = 1, 3 do
		local y = level * 2.7
		local plank = b.part(m, `Level{level}`, V(14, 0.3, 2.8), V(0, y, 0), C.White)
		plank:SetAttribute("ShelfLevel", level)
		b.part(m, "Lip", V(14, 0.35, 0.15), V(0, y + 0.1, -1.45), C.Gold, M.Metal)
	end
	if Props.Place(m, "WallShelf", cf, { accent = accent, collide = false }) then
		Props.Hide(m, SHELF_PARTS)
	end
end

-- Glass display cases on the shop floor
local function buildDisplayCases(b, shop, accent)
	local folder = Instance.new("Folder")
	folder.Name = "DisplayCases"
	folder.Parent = shop
	for i, s in SIDES do
		buildCase(b, folder, `Case{i}`, s * 10, -6, accent)
	end
end

-- Wall shelves on the side walls, open fronts facing into the room
local function buildShelves(b, shop, accent)
	local folder = Instance.new("Folder")
	folder.Name = "Shelves"
	folder.Parent = shop
	for i, s in SIDES do
		buildShelf(folder, `Shelf{i}`, b.cframe(V(s * 17.2, 1, -6), s * 90), accent)
	end
end

-- Back area (z 18..32): two glass cases and a wall shelf on the back wall, roped off at the
-- aisles until the owner buys the Bigger shop upgrade (ShopDoors hides the ropes).
local function buildBackArea(b, shop, accent)
	local area = Build.model(shop, "BackArea")
	local cases = Instance.new("Folder")
	cases.Name = "DisplayCases"
	cases.Parent = area
	buildCase(b, cases, "BackCase1", -11, 23.5, accent)
	buildCase(b, cases, "BackCase2", 11, 23.5, accent)
	local shelves = Instance.new("Folder")
	shelves.Name = "Shelves"
	shelves.Parent = area
	buildShelf(shelves, "BackShelf", b.cframe(V(0, 1, 30.3), 0), accent)

	-- Velvet ropes across both aisles, with a sign in the middle of each
	local ropes = Build.model(shop, "BackRopes")
	local velvet = Color3.fromRGB(170, 25, 45)
	for _, s in SIDES do
		local posts = { s * 10.6, s * 14.8, s * 18.8 }
		for _, x in posts do
			b.column(ropes, "RopePost", 0.35, 3.4, V(x, 1, 18.5), C.Gold, M.Metal, { collide = false })
			b.column(ropes, "RopeBase", 1, 0.2, V(x, 1, 18.5), C.Gold, M.Metal, { collide = false })
			b.ball(ropes, "RopeTop", 0.5, V(x, 4.5, 18.5), C.Gold, M.Metal, { collide = false })
		end
		for k = 1, 2 do
			local x0, x1 = posts[k], posts[k + 1]
			-- (a cylinder part lies along its X axis, which runs along the rope here)
			b.part(ropes, "Rope", V(math.abs(x1 - x0), 0.22, 0.22), V((x0 + x1) / 2, 3.9, 18.5), velvet, M.Fabric,
				{ shape = "Cylinder", collide = false })
		end
		local sign = b.part(ropes, "RopeSign", V(3.4, 1.1, 0.1), V(s * 14.8, 3.1, 18.4), C.DarkMarble, nil, { collide = false })
		Build.text(sign, Enum.NormalId.Front, "🔒 Bigger shop", C.Gold)
	end
	for _, part in ropes:GetChildren() do
		part.CanQuery = false
	end
end

-- Inside details: wall panels, rug, lights, back wall, clutter --------------
local function buildInterior(b, m, accent)
	-- Dark wood panels along the lower walls with a gold rail
	b.part(m, "Wainscot", V(38, 4, 0.2), V(0, 3, 31.9), C.DarkWood, M.Wood)
	b.part(m, "Rail", V(38, 0.3, 0.4), V(0, 5.15, 31.8), C.Gold, M.Metal)
	for _, s in SIDES do
		b.part(m, "Wainscot", V(0.2, 4, 48), V(s * 18.9, 3, 8), C.DarkWood, M.Wood)
		b.part(m, "Rail", V(0.4, 0.3, 48), V(s * 18.8, 5.15, 8), C.Gold, M.Metal)
	end

	-- Rug from the door to the checkout
	b.part(m, "RugBorder", V(10.8, 0.08, 14.8), V(0, 1.09, -7), C.Gold, M.Fabric)
	b.part(m, "Rug", V(10, 0.1, 14), V(0, 1.1, -7), accent, M.Fabric)

	-- Gold chandelier hanging from the ceiling
	if not Props.Place(m, "Chandelier", b.cframe(V(0, 16.8, -6)), { light = { 26, 0.6 }, collide = false }) then
		b.part(m, "ChandelierChain", V(0.2, 2, 0.2), V(0, 15.8, -6), C.Gold, M.Metal)
		b.column(m, "ChandelierRing", 4, 0.3, V(0, 14.5, -6), C.Gold, M.Metal)
		local crystal = b.ball(m, "ChandelierCrystal", 1, V(0, 14.2, -6), C.Glass, M.Glass, { transparency = 0.3 })
		Build.light(crystal, 26, 0.6)
		for k = 0, 5 do
			local angle = math.rad(k * 60)
			b.ball(m, "ChandelierBulb", 0.6, V(2 * math.cos(angle), 14.95, -6 + 2 * math.sin(angle)), C.WarmLight)
		end
	end
	local backLight = b.part(m, "CeilingLight", V(4, 0.2, 4), V(0, 16.7, 10), C.WarmLight)
	Build.light(backLight, 20, 0.4)

	-- A second chandelier over the back area
	if not Props.Place(m, "Chandelier", b.cframe(V(0, 16.8, 24)), { light = { 26, 0.6 }, collide = false }) then
		local crystal = b.ball(m, "ChandelierCrystal", 1, V(0, 14.2, 24), C.Glass, M.Glass, { transparency = 0.3 })
		Build.light(crystal, 26, 0.6)
	end

	-- Guitar wall on the back wall (left, seen from the door: x -18..-9)
	b.part(m, "GuitarBoard", V(9, 6, 0.2), V(-13.5, 8, 31.7), C.LightWood, M.WoodPlanks)
	local guitarColors = { Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 120, 230), Color3.fromRGB(240, 160, 50) }
	for i, gx in { -16.3, -13.5, -10.7 } do
		local g = Build.model(m, "Guitar")
		b.part(g, "Body", V(2.4, 2.8, 0.5), V(gx, 6.6, 31.3), guitarColors[i])
		b.part(g, "UpperBody", V(1.9, 1.6, 0.5), V(gx, 8.5, 31.3), guitarColors[i])
		b.disc(g, "SoundHole", 0.8, 0.05, V(gx, 7.3, 31.03), C.DarkMetal)
		b.part(g, "Neck", V(0.4, 3.2, 0.25), V(gx, 10.9, 31.35), C.DarkWood, M.Wood)
		b.part(g, "Head", V(0.7, 1, 0.3), V(gx, 13, 31.35), C.DarkMetal)
	end
	local banner = b.part(m, "Banner", V(10, 1.8, 0.1), V(0, 15.5, 31.85), accent)
	Build.text(banner, Enum.NormalId.Front, "WE BUY GOLD", C.White)

	-- Wall clock on the back wall, above the shelf
	if not Props.Place(m, "WallClock", b.cframe(V(0, 12.6, 32)), { collide = false }) then
		b.disc(m, "ClockRim", 2.6, 0.2, V(0, 12.6, 31.8), C.Gold, M.Metal)
		b.disc(m, "ClockFace", 2.2, 0.1, V(0, 12.6, 31.7), C.White)
	end

	-- Stacked boxes in the back-right corner
	b.part(m, "Box", V(2.6, 2.2, 2.6), V(16.8, 2.1, 30.3), C.Cardboard, M.Cardboard)
	b.part(m, "Box", V(2, 1.6, 2), V(16.6, 4.0, 30.2), C.Cardboard, M.Cardboard, { rot = V(0, 15, 0) })
	b.part(m, "Box", V(2.2, 1.8, 2.2), V(17, 1.9, 27.4), C.Cardboard, M.Cardboard, { rot = V(0, -10, 0) })

	-- Plants in the front corners
	for _, s in SIDES do
		if not Props.Place(m, "PottedPlant", b.cframe(V(s * 17.6, 1, -14.6), s * 30)) then
			b.column(m, "Pot", 1.8, 1.8, V(s * 17.6, 1, -14.6), C.Marble, M.Marble)
			b.ball(m, "Plant", 2.4, V(s * 17.6, 3.6, -14.6), C.Leaf)
			b.ball(m, "Plant", 1.6, V(s * 17.6, 4.7, -14.6), C.DarkLeaf)
		end
	end

	-- Paintings above the shelves
	local skies = { Color3.fromRGB(120, 190, 240), Color3.fromRGB(240, 170, 110) }
	for i, s in SIDES do
		b.part(m, "PaintingFrame", V(0.2, 3.6, 5.2), V(s * 18.8, 13.2, -6), C.Gold, M.Metal)
		b.part(m, "PaintingSky", V(0.1, 3, 4.6), V(s * 18.67, 13.2, -6), skies[i])
		b.part(m, "PaintingHills", V(0.12, 1.2, 4.6), V(s * 18.66, 12.3, -6), C.Leaf)
	end
end

-- Builds a shop centered at `origin`. origin.LookVector points out the front door.
function ShopBuilder.Build(origin: CFrame, name: string, accent: Color3): Model
	local shop = Instance.new("Model")
	shop.Name = name

	local b = Build.at(origin)
	local exterior = Build.model(shop, "Exterior")
	local interior = Build.model(shop, "Interior")

	buildShell(b, exterior, accent)
	buildFacade(b, exterior, shop, accent)
	buildInterior(b, interior, accent)
	-- Detailed building and interior meshes (the sign, OPEN sign, banner and door sign stay parts: they carry text)
	if Props.Place(exterior, "ShopExterior", origin, { accent = accent, collide = false }) then
		Props.Hide(exterior, EXTERIOR_PARTS)
	end
	if Props.Place(interior, "ShopInterior", origin, { accent = accent, collide = false }) then
		Props.Hide(interior, INTERIOR_PARTS)
	end
	buildCounter(b, shop, accent)
	buildDisplayCases(b, shop, accent)
	buildShelves(b, shop, accent)
	buildBackArea(b, shop, accent)

	-- Spots for later steps
	local markers = Instance.new("Folder")
	markers.Name = "Markers"
	markers.Parent = shop
	b.marker(markers, "Origin", V(0, 0.5, 0)) -- the shop's own coordinates (its PrimaryPart)
	b.marker(markers, "OwnerSpawn", V(0, 4, 9)) -- inside the checkout
	b.marker(markers, "CustomerSpot", V(5.5, 1.5, 1.4)) -- in front of the register
	b.marker(markers, "CounterItem", V(8, 5.0, 4.0)) -- where a seller puts their item down
	b.marker(markers, "TestItem", V(-1.5, 5.0, 4.4)) -- admin test items
	b.marker(markers, "Door", V(0, 1.5, -19)) -- just outside the door
	b.marker(markers, "Street", V(0, 1, -27)) -- on the sidewalk, where customers come from

	shop.PrimaryPart = markers.Origin
	return shop
end

return ShopBuilder
