-- Builds one pawn shop out of parts: bright cartoony colors with fancy marble + gold.
--
-- Layout (relative to the shop's center, in studs):
--   X: -20 (left) .. 20 (right)    Z: -17 (front, door side) .. 17 (back)    Y: floor top is 1
-- The owner stands behind the counter (back half). Customers come in the front door.

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
	"Neck", "Head", "OfficeDoorFrame", "PaintingFrame", "PaintingSky",
	"PaintingHills", "Box",
})
local COUNTER_PARTS = names({ "Body", "Panel", "Kick", "Top", "TopEdge" })
local CASE_PARTS = names({ "Base", "Kick", "DisplaySurface", "Glass", "Post", "TopBar" })
local SHELF_PARTS = names({ "Back", "Side", "Top", "Plinth", "Level1", "Level2", "Level3", "Lip" })
local BACKROOM_PARTS = names({
	"BackRoomFloor", "BackRoomWall", "BackRoomCeiling", "BackRoomRoof", "BackRoomLight",
})

-- Floor, walls, windows, roof ------------------------------------------------
local function buildShell(b, m, accent)
	b.part(m, "Floor", V(40, 1, 34), V(0, 0.5, 0), C.Marble, M.Marble)

	-- Checkered marble tiles
	for ix = 0, 9 do
		for iz = 0, 7 do
			if (ix + iz) % 2 == 0 then
				b.part(m, "Tile", V(4, 0.05, 4), V(-18 + ix * 4, 1.025, -14 + iz * 4), C.DarkMarble, M.Marble)
			end
		end
	end

	-- Back wall, with a doorway (x 1..5) into the back room
	b.part(m, "BackWall", V(21, 16, 1), V(-9.5, 9, 16.5), C.Cream)
	b.part(m, "BackWall", V(15, 16, 1), V(12.5, 9, 16.5), C.Cream)
	b.part(m, "BackWall", V(4, 7.5, 1), V(3, 13.25, 16.5), C.Cream)
	b.part(m, "LeftWall", V(1, 16, 34), V(-19.5, 9, 0), C.Cream)
	b.part(m, "RightWall", V(1, 16, 34), V(19.5, 9, 0), C.Cream)

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
		b.part(m, "BaseStrip", V(0.3, 1.2, 34), V(s * 20.15, 0.8, 0), accent)
		-- Gold trim along the top of the side walls
		b.part(m, "RoofTrim", V(1.2, 0.4, 34), V(s * 19.6, 18.2, 0), C.Gold, M.Metal)
	end
	b.part(m, "BaseStrip", V(40.6, 1.2, 0.3), V(0, 0.8, 17.15), accent)
	b.part(m, "RoofTrim", V(40, 0.4, 1.2), V(0, 18.2, 16.4), C.Gold, M.Metal)

	b.part(m, "AboveDoor", V(8, 6, 1), V(0, 14, -16.5), C.Cream)
	b.part(m, "Ceiling", V(38, 0.2, 32), V(0, 16.9, 0), C.Cream)
	b.part(m, "Roof", V(40, 1, 34), V(0, 17.5, 0), C.Roof, M.Slate)
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

-- Counter: wall to wall, with a gate in the middle (the checkout area is behind it) ----
-- Sections run x -19..-2 and 2..19; the gate fills x -2..2.
local function buildCounter(b, shop, accent)
	local m = Build.model(shop, "Counter")
	for _, s in SIDES do
		local cx = s * 10.5
		b.part(m, "Body", V(17, 3.6, 3), V(cx, 2.8, 4), C.Marble, M.Marble)
		for _, dx in { -5.6, 0, 5.6 } do
			b.part(m, "Panel", V(4.6, 2.4, 0.2), V(cx + dx, 2.9, 2.45), accent)
		end
		b.part(m, "Kick", V(17, 0.4, 3.2), V(cx, 1.2, 4), C.Gold, M.Metal)
		b.part(m, "Top", V(17, 0.4, 3.6), V(cx, 4.8, 4), C.DarkMarble, M.Marble)
		b.part(m, "TopEdge", V(17, 0.2, 0.2), V(cx, 4.55, 2.15), C.Gold, M.Metal)
		if Props.Place(m, "CounterSection", b.cframe(V(cx, 1, 4)), { accent = accent, collide = false }) then
			Props.Hide(m, COUNTER_PARTS)
		end
	end

	-- The gate: a swinging half-door, hinged on its left end (ShopDoors opens it)
	local gate = Build.model(m, "Gate")
	b.part(gate, "GateDoor", V(3.9, 3.2, 0.3), V(0, 2.8, 4), accent, nil, { reflectance = 0.05 })
	b.part(gate, "GateRail", V(3.9, 0.3, 0.45), V(0, 4.45, 4), C.Gold, M.Metal)
	b.part(gate, "GatePanel", V(3.1, 2.0, 0.34), V(0, 2.8, 4), C.Gold, M.Metal)
	b.part(gate, "GatePanelInner", V(2.8, 1.7, 0.38), V(0, 2.8, 4), accent)
	gate:SetAttribute("Hinge", b.cframe(V(-1.95, 2.8, 4)))
	for _, part in gate:GetChildren() do
		-- Customers' pathfinding may walk through: the gate swings open for them
		local modifier = Instance.new("PathfindingModifier")
		modifier.PassThrough = true
		modifier.Parent = part
	end

	-- Cash register
	if not Props.Place(m, "CashRegister", b.cframe(V(5, 5.0, 4.4)), { accent = accent }) then
		b.part(m, "Register", V(2.6, 1, 2), V(5, 5.5, 4.4), accent)
		b.part(m, "RegisterKeys", V(2.2, 0.15, 0.9), V(5, 6.075, 4.9), C.DarkMetal)
		b.part(m, "RegisterScreen", V(1.8, 1, 0.2), V(5, 6.6, 4.0), C.DarkMetal)
		b.part(m, "RegisterDisplay", V(1.5, 0.7, 0.05), V(5, 6.6, 3.88), Color3.fromRGB(110, 255, 170), M.Neon)
	end

	-- Service bell
	if not Props.Place(m, "ServiceBell", b.cframe(V(-6, 5.0, 3.4))) then
		b.column(m, "BellBase", 1, 0.2, V(-6, 5.0, 3.4), C.DarkWood, M.Wood)
		b.ball(m, "Bell", 0.9, V(-6, 5.35, 3.4), C.Gold, M.Metal, { reflectance = 0.2 })
		b.ball(m, "BellButton", 0.25, V(-6, 5.85, 3.4), C.Gold, M.Metal)
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

-- Back room (Bigger shop upgrade), behind the STAFF ONLY door: x -8..14, z 17..33.
-- Two glass cases and a wall shelf; the door stays shut until the owner unlocks it.
local function buildBackRoom(b, shop, accent)
	local room = Build.model(shop, "BackRoom")
	b.part(room, "BackRoomFloor", V(22, 1, 16), V(3, 0.5, 25), C.Marble, M.Marble)
	b.part(room, "BackRoomWall", V(1, 16, 16), V(-7.5, 9, 25), C.Cream)
	b.part(room, "BackRoomWall", V(1, 16, 16), V(13.5, 9, 25), C.Cream)
	b.part(room, "BackRoomWall", V(22, 16, 1), V(3, 9, 32.5), C.Cream)
	b.part(room, "BackRoomCeiling", V(20, 0.2, 15), V(3, 16.9, 24.5), C.Cream)
	b.part(room, "BackRoomRoof", V(22.4, 1, 16.6), V(3, 17.5, 25.1), C.Roof, M.Slate)
	local light = b.part(room, "BackRoomLight", V(4, 0.2, 4), V(3, 16.7, 24.5), C.WarmLight)
	Build.light(light, 20, 0.5)
	if Props.Place(room, "BackRoom", b.cframe(V(0, 0, 0)), { accent = accent, collide = false }) then
		Props.Hide(room, BACKROOM_PARTS)
	end

	local cases = Instance.new("Folder")
	cases.Name = "DisplayCases"
	cases.Parent = room
	buildCase(b, cases, "BackCase1", -3, 21.5, accent)
	buildCase(b, cases, "BackCase2", 9, 21.5, accent)
	local shelves = Instance.new("Folder")
	shelves.Name = "Shelves"
	shelves.Parent = room
	buildShelf(shelves, "BackShelf", b.cframe(V(3, 1, 30.3), 0), accent)

	-- The door between the shop and the back room, hinged on its left side (ShopDoors opens it)
	local door = Build.model(shop, "BackDoor")
	b.part(door, "DoorSlab", V(4, 8.2, 0.3), V(3, 5.1, 15.5), C.DarkWood, M.Wood)
	for _, y in { 3.0, 7.0 } do
		for _, x in { 2.05, 3.95 } do
			b.part(door, "DoorPanel", V(1.4, if y == 3.0 then 3.0 else 2.4, 0.12), V(x, y, 15.32), Color3.fromRGB(110, 72, 50), M.Wood)
		end
	end
	b.ball(door, "DoorKnob", 0.4, V(4.5, 5, 15.3), C.Gold, M.Metal)
	b.part(door, "KickPlate", V(3.6, 0.6, 0.06), V(3, 1.4, 15.33), C.Gold, M.Metal)
	local lock = b.part(door, "LockSign", V(3, 1, 0.05), V(3, 5.9, 15.31), C.DarkMarble)
	Build.text(lock, Enum.NormalId.Front, "🔒 Bigger shop upgrade", C.Gold)
	door:SetAttribute("Hinge", b.cframe(V(1.05, 5.1, 15.5)))
end

-- Inside details: wall panels, rug, lights, back wall, clutter --------------
local function buildInterior(b, m, accent)
	-- Dark wood panels along the lower walls with a gold rail
	b.part(m, "Wainscot", V(38, 4, 0.2), V(0, 3, 15.9), C.DarkWood, M.Wood)
	b.part(m, "Rail", V(38, 0.3, 0.4), V(0, 5.15, 15.8), C.Gold, M.Metal)
	for _, s in SIDES do
		b.part(m, "Wainscot", V(0.2, 4, 32), V(s * 18.9, 3, 0), C.DarkWood, M.Wood)
		b.part(m, "Rail", V(0.4, 0.3, 32), V(s * 18.8, 5.15, 0), C.Gold, M.Metal)
	end

	-- Rug from the door to the counter
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

	-- Guitar wall behind the counter
	b.part(m, "GuitarBoard", V(10, 6, 0.2), V(-10, 8, 15.7), C.LightWood, M.WoodPlanks)
	local guitarColors = { Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 120, 230), Color3.fromRGB(240, 160, 50) }
	for i, gx in { -13, -10, -7 } do
		local g = Build.model(m, "Guitar")
		b.part(g, "Body", V(2.4, 2.8, 0.5), V(gx, 6.6, 15.3), guitarColors[i])
		b.part(g, "UpperBody", V(1.9, 1.6, 0.5), V(gx, 8.5, 15.3), guitarColors[i])
		b.disc(g, "SoundHole", 0.8, 0.05, V(gx, 7.3, 15.03), C.DarkMetal)
		b.part(g, "Neck", V(0.4, 3.2, 0.25), V(gx, 10.9, 15.35), C.DarkWood, M.Wood)
		b.part(g, "Head", V(0.7, 1, 0.3), V(gx, 13, 15.35), C.DarkMetal)
	end
	local banner = b.part(m, "Banner", V(10, 1.8, 0.1), V(-10, 15, 15.85), accent)
	Build.text(banner, Enum.NormalId.Front, "WE BUY GOLD", C.White)

	-- Staff-only office door
	-- Frame around the back room doorway (posts and a top bar, so the doorway stays open)
	b.part(m, "OfficeDoorFrame", V(0.35, 8.8, 0.35), V(0.85, 5.4, 15.75), C.Gold, M.Metal)
	b.part(m, "OfficeDoorFrame", V(0.35, 8.8, 0.35), V(5.15, 5.4, 15.75), C.Gold, M.Metal)
	b.part(m, "OfficeDoorFrame", V(4.65, 0.4, 0.35), V(3, 9.7, 15.75), C.Gold, M.Metal)
	local plate = b.part(m, "DoorSign", V(2.4, 0.7, 0.05), V(3, 11.1, 15.93), C.Marble)
	Build.text(plate, Enum.NormalId.Front, "STAFF ONLY", C.DarkMarble)

	-- Wall clock above the office door
	if not Props.Place(m, "WallClock", b.cframe(V(3, 12.5, 16)), { collide = false }) then
		b.disc(m, "ClockRim", 2.6, 0.2, V(3, 12.5, 15.8), C.Gold, M.Metal)
		b.disc(m, "ClockFace", 2.2, 0.1, V(3, 12.5, 15.7), C.White)
		b.part(m, "HourHand", V(0.2, 0.7, 0.05), V(3, 12.8, 15.63), C.DarkMetal)
		b.part(m, "MinuteHand", V(0.15, 1, 0.05), V(3.43, 12.75, 15.62), C.DarkMetal, nil, { rot = V(0, 0, -60) })
	end

	-- Big safe in the back corner, with gold bars on top
	if not Props.Place(m, "Safe", b.cframe(V(14.5, 1, 13.8))) then
		b.part(m, "Safe", V(4, 5, 3.5), V(14.5, 3.5, 13.8), C.DarkMetal, M.Metal)
		b.part(m, "SafeDoor", V(3.3, 4.2, 0.15), V(14.5, 3.5, 12.0), Color3.fromRGB(75, 75, 90), M.Metal)
		b.disc(m, "SafeDial", 1.1, 0.3, V(14.5, 4.3, 11.85), C.Gold, M.Metal)
		b.part(m, "SafeHandle", V(0.25, 1.2, 0.25), V(13.3, 3.3, 11.8), C.Steel, M.Metal)
		b.part(m, "GoldBar", V(1.2, 0.5, 0.6), V(14, 6.25, 13.5), C.Gold, M.Metal, { reflectance = 0.2 })
		b.part(m, "GoldBar", V(1.2, 0.5, 0.6), V(15.2, 6.25, 13.5), C.Gold, M.Metal, { reflectance = 0.2 })
		b.part(m, "GoldBar", V(1.2, 0.5, 0.6), V(14.6, 6.75, 13.5), C.Gold, M.Metal, { reflectance = 0.2 })
	end

	-- Retro TV on a cabinet
	if not Props.Place(m, "RetroTV", b.cframe(V(15.5, 1, 8))) then
		b.part(m, "TVCabinet", V(4, 2.5, 2.5), V(15.5, 2.25, 8), C.Wood, M.Wood)
		b.part(m, "TV", V(3.4, 2.6, 2.2), V(15.5, 4.8, 8), Color3.fromRGB(60, 55, 60))
		b.part(m, "TVScreen", V(2.8, 2, 0.1), V(15.5, 4.9, 6.85), Color3.fromRGB(35, 55, 75), M.Glass)
		b.part(m, "Antenna", V(0.1, 1.6, 0.1), V(15.1, 6.8, 8), C.Steel, M.Metal, { rot = V(0, 0, 25) })
		b.part(m, "Antenna", V(0.1, 1.6, 0.1), V(15.9, 6.8, 8), C.Steel, M.Metal, { rot = V(0, 0, -25) })
	end

	-- Stacked boxes in the back-left corner
	b.part(m, "Box", V(2.6, 2.2, 2.6), V(-16.8, 2.1, 14.3), C.Cardboard, M.Cardboard)
	b.part(m, "Box", V(2, 1.6, 2), V(-16.6, 4.0, 14.2), C.Cardboard, M.Cardboard, { rot = V(0, 15, 0) })
	b.part(m, "Box", V(2.2, 1.8, 2.2), V(-17, 1.9, 11.4), C.Cardboard, M.Cardboard, { rot = V(0, -10, 0) })

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
	buildBackRoom(b, shop, accent)

	-- Spots for later steps
	local markers = Instance.new("Folder")
	markers.Name = "Markers"
	markers.Parent = shop
	b.marker(markers, "OwnerSpawn", V(0, 4, 8.5)) -- behind the counter
	b.marker(markers, "CustomerSpot", V(6, 1.5, 0.5)) -- in front of the counter, at the register
	b.marker(markers, "CounterItem", V(8.6, 5.0, 3.1)) -- where a seller puts their item down
	b.marker(markers, "TestItem", V(12.5, 5.0, 3.4)) -- admin test items
	b.marker(markers, "Door", V(0, 1.5, -19)) -- just outside the door
	b.marker(markers, "Street", V(0, 1, -27)) -- on the sidewalk, where customers come from

	shop.PrimaryPart = exterior.Floor
	return shop
end

return ShopBuilder
