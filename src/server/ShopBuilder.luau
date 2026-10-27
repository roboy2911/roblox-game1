-- Builds one pawn shop out of parts.
-- Directions are relative to the shop: the door faces "front" (toward the street),
-- the owner stands behind the counter (back), customers come in the door.

local ShopBuilder = {}

local WIDTH = 32 -- side to side
local DEPTH = 26 -- front to back
local WALL_HEIGHT = 14
local DOOR_WIDTH = 8
local DOOR_HEIGHT = 9
local FLOOR_TOP = 1 -- the floor is 1 stud thick, sitting on the ground

local COLORS = {
	Floor = Color3.fromRGB(120, 85, 55),
	Wall = Color3.fromRGB(150, 70, 55),
	Roof = Color3.fromRGB(60, 60, 65),
	Counter = Color3.fromRGB(90, 60, 40),
	CounterTop = Color3.fromRGB(200, 200, 205),
	Shelf = Color3.fromRGB(110, 75, 45),
	Sign = Color3.fromRGB(110, 20, 20),
	SignText = Color3.fromRGB(255, 200, 60),
	Path = Color3.fromRGB(170, 170, 170),
}

-- Makes an anchored part at a position relative to the shop's center.
local function addPart(parent, origin: CFrame, name, size: Vector3, offset: Vector3, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = origin * CFrame.new(offset)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- Invisible spots that scripts use later (where to spawn, where customers stand, etc.)
local function addMarker(parent, origin: CFrame, name, offset: Vector3)
	local marker = addPart(parent, origin, name, Vector3.new(1, 1, 1), offset, Color3.new(1, 1, 1))
	marker.Transparency = 1
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	return marker
end

local function buildShelf(parent, origin: CFrame, name, side: number, z: number)
	local shelf = Instance.new("Model")
	shelf.Name = name
	-- side is -1 for the left wall, 1 for the right wall
	local wallX = side * (WIDTH / 2 - 1)
	addPart(shelf, origin, "Back", Vector3.new(0.5, 8, 10), Vector3.new(wallX - side * 0.25, FLOOR_TOP + 4, z), COLORS.Shelf, Enum.Material.Wood)
	for level = 1, 3 do
		local plank = addPart(
			shelf,
			origin,
			`Level{level}`,
			Vector3.new(2.5, 0.3, 10),
			Vector3.new(wallX - side * 1.5, FLOOR_TOP + level * 2.4, z),
			COLORS.Shelf,
			Enum.Material.Wood
		)
		plank:SetAttribute("ShelfLevel", level)
	end
	shelf.Parent = parent
	return shelf
end

local function buildSign(parent, origin: CFrame)
	local sign = addPart(
		parent,
		origin,
		"Sign",
		Vector3.new(18, 3, 0.5),
		Vector3.new(0, FLOOR_TOP + WALL_HEIGHT - 2, -DEPTH / 2 - 0.3),
		COLORS.Sign
	)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front -- faces the street
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Name = "OwnerText"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = COLORS.SignText
	label.Text = "For Sale"
	label.Parent = gui
	return sign
end

-- Builds a shop centered at `origin`. origin.LookVector points out the front door.
function ShopBuilder.Build(origin: CFrame, name: string): Model
	local shop = Instance.new("Model")
	shop.Name = name

	local building = Instance.new("Model")
	building.Name = "Building"
	building.Parent = shop

	local frontZ = -DEPTH / 2 + 0.5
	local wallY = FLOOR_TOP + WALL_HEIGHT / 2

	-- Floor, walls, roof
	addPart(building, origin, "Floor", Vector3.new(WIDTH, 1, DEPTH), Vector3.new(0, 0.5, 0), COLORS.Floor, Enum.Material.WoodPlanks)
	addPart(building, origin, "BackWall", Vector3.new(WIDTH, WALL_HEIGHT, 1), Vector3.new(0, wallY, DEPTH / 2 - 0.5), COLORS.Wall, Enum.Material.Brick)
	addPart(building, origin, "LeftWall", Vector3.new(1, WALL_HEIGHT, DEPTH), Vector3.new(-WIDTH / 2 + 0.5, wallY, 0), COLORS.Wall, Enum.Material.Brick)
	addPart(building, origin, "RightWall", Vector3.new(1, WALL_HEIGHT, DEPTH), Vector3.new(WIDTH / 2 - 0.5, wallY, 0), COLORS.Wall, Enum.Material.Brick)

	-- Front wall has a doorway in the middle
	local sideWidth = (WIDTH - DOOR_WIDTH) / 2
	local sideX = DOOR_WIDTH / 2 + sideWidth / 2
	addPart(building, origin, "FrontWallLeft", Vector3.new(sideWidth, WALL_HEIGHT, 1), Vector3.new(-sideX, wallY, frontZ), COLORS.Wall, Enum.Material.Brick)
	addPart(building, origin, "FrontWallRight", Vector3.new(sideWidth, WALL_HEIGHT, 1), Vector3.new(sideX, wallY, frontZ), COLORS.Wall, Enum.Material.Brick)
	local aboveDoor = WALL_HEIGHT - DOOR_HEIGHT
	addPart(
		building,
		origin,
		"AboveDoor",
		Vector3.new(DOOR_WIDTH, aboveDoor, 1),
		Vector3.new(0, FLOOR_TOP + DOOR_HEIGHT + aboveDoor / 2, frontZ),
		COLORS.Wall,
		Enum.Material.Brick
	)

	addPart(building, origin, "Roof", Vector3.new(WIDTH + 2, 1, DEPTH + 2), Vector3.new(0, FLOOR_TOP + WALL_HEIGHT + 0.5, 0), COLORS.Roof, Enum.Material.Slate)

	-- Ceiling light
	local lamp = addPart(building, origin, "Lamp", Vector3.new(4, 0.4, 4), Vector3.new(0, FLOOR_TOP + WALL_HEIGHT - 0.2, 0), Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Range = 30
	light.Brightness = 1.5
	light.Parent = lamp

	-- Walkway from the street to the door
	addPart(building, origin, "Path", Vector3.new(DOOR_WIDTH, 0.2, 14), Vector3.new(0, 0.1, -DEPTH / 2 - 7), COLORS.Path, Enum.Material.Concrete)

	buildSign(shop, origin)

	-- Counter: a wooden base with a glass-like top, across the middle of the shop
	local counter = Instance.new("Model")
	counter.Name = "Counter"
	addPart(counter, origin, "Base", Vector3.new(14, 3.5, 3), Vector3.new(0, FLOOR_TOP + 1.75, 2), COLORS.Counter, Enum.Material.Wood)
	addPart(counter, origin, "Top", Vector3.new(14.4, 0.3, 3.4), Vector3.new(0, FLOOR_TOP + 3.65, 2), COLORS.CounterTop, Enum.Material.Glass)
	counter.Parent = shop

	-- Display shelves along the side walls
	local shelves = Instance.new("Folder")
	shelves.Name = "Shelves"
	shelves.Parent = shop
	buildShelf(shelves, origin, "Shelf1", -1, -4)
	buildShelf(shelves, origin, "Shelf2", 1, -4)

	-- Spots for later steps
	local markers = Instance.new("Folder")
	markers.Name = "Markers"
	markers.Parent = shop
	addMarker(markers, origin, "OwnerSpawn", Vector3.new(0, FLOOR_TOP + 3, 6)) -- behind the counter
	addMarker(markers, origin, "CustomerSpot", Vector3.new(0, FLOOR_TOP + 0.5, -1.5)) -- in front of the counter
	addMarker(markers, origin, "Door", Vector3.new(0, FLOOR_TOP + 0.5, -DEPTH / 2 - 1)) -- just outside the door
	addMarker(markers, origin, "Street", Vector3.new(0, 0.5, -DEPTH / 2 - 14)) -- where customers come from

	shop.PrimaryPart = building.Floor
	return shop
end

return ShopBuilder
