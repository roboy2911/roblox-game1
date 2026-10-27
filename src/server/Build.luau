-- Small helpers for building things out of parts.
-- Positions are relative to an origin CFrame, so the same shop design works on every plot.

local Build = {}

-- Shared color palette: bright and cartoony, with marble + gold for the fancy touch.
Build.Colors = {
	White = Color3.fromRGB(255, 255, 255),
	Cream = Color3.fromRGB(250, 240, 220),
	Marble = Color3.fromRGB(240, 240, 245),
	DarkMarble = Color3.fromRGB(45, 45, 60),
	Gold = Color3.fromRGB(255, 196, 54),
	Roof = Color3.fromRGB(70, 65, 90),
	Glass = Color3.fromRGB(190, 230, 255),
	Wood = Color3.fromRGB(150, 100, 60),
	DarkWood = Color3.fromRGB(85, 55, 40),
	LightWood = Color3.fromRGB(205, 165, 115),
	Cardboard = Color3.fromRGB(196, 152, 100),
	Leaf = Color3.fromRGB(95, 195, 85),
	DarkLeaf = Color3.fromRGB(60, 150, 65),
	Trunk = Color3.fromRGB(115, 80, 55),
	Concrete = Color3.fromRGB(205, 205, 212),
	Asphalt = Color3.fromRGB(60, 60, 72),
	Grass = Color3.fromRGB(115, 195, 95),
	Plaza = Color3.fromRGB(235, 228, 215),
	Water = Color3.fromRGB(80, 180, 255),
	DarkMetal = Color3.fromRGB(45, 45, 55),
	Steel = Color3.fromRGB(170, 175, 185),
	WarmLight = Color3.fromRGB(255, 225, 160),
	Yellow = Color3.fromRGB(255, 210, 60),
}

local M = Enum.Material

-- Returns a set of builder functions that place parts relative to `origin`.
function Build.at(origin: CFrame)
	local b = {}

	-- extra (optional): rot (degrees), transparency, reflectance, collide, shape ("Ball"/"Cylinder"/"Wedge")
	function b.part(parent, name, size: Vector3, pos: Vector3, color: Color3?, material: Enum.Material?, extra)
		extra = extra or {}
		local part = Instance.new(if extra.shape == "Wedge" then "WedgePart" else "Part")
		if extra.shape == "Ball" then
			part.Shape = Enum.PartType.Ball
		elseif extra.shape == "Cylinder" then
			part.Shape = Enum.PartType.Cylinder
		end
		part.Name = name
		part.Anchored = true
		part.Size = size
		local cf = origin * CFrame.new(pos)
		if extra.rot then
			cf *= CFrame.Angles(math.rad(extra.rot.X), math.rad(extra.rot.Y), math.rad(extra.rot.Z))
		end
		part.CFrame = cf
		part.Color = color or Build.Colors.White
		part.Material = material or M.SmoothPlastic
		part.Transparency = extra.transparency or 0
		part.Reflectance = extra.reflectance or 0
		if extra.collide == false then
			part.CanCollide = false
		end
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = parent
		return part
	end

	-- Standing cylinder. `base` is the center of its bottom.
	function b.column(parent, name, diameter: number, height: number, base: Vector3, color, material, extra)
		extra = table.clone(extra or {})
		extra.shape = "Cylinder"
		extra.rot = Vector3.new(0, 0, 90)
		return b.part(parent, name, Vector3.new(height, diameter, diameter), base + Vector3.new(0, height / 2, 0), color, material, extra)
	end

	-- Flat cylinder facing front/back (like a clock face or a safe dial).
	function b.disc(parent, name, diameter: number, thickness: number, pos: Vector3, color, material, extra)
		extra = table.clone(extra or {})
		extra.shape = "Cylinder"
		extra.rot = Vector3.new(0, 90, 0)
		return b.part(parent, name, Vector3.new(thickness, diameter, diameter), pos, color, material, extra)
	end

	function b.ball(parent, name, diameter: number, pos: Vector3, color, material, extra)
		extra = table.clone(extra or {})
		extra.shape = "Ball"
		return b.part(parent, name, Vector3.new(diameter, diameter, diameter), pos, color, material, extra)
	end

	-- Invisible spot that scripts use later (spawn points, where customers stand...).
	function b.marker(parent, name, pos: Vector3)
		local marker = b.part(parent, name, Vector3.new(1, 1, 1), pos, nil, nil, { transparency = 1, collide = false })
		marker.CanQuery = false
		marker.CanTouch = false
		return marker
	end

	return b
end

function Build.model(parent, name)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	return model
end

-- Adds a light to a part.
function Build.light(part, range: number, brightness: number, color: Color3?)
	local light = Instance.new("PointLight")
	light.Range = range
	light.Brightness = brightness
	light.Color = color or Build.Colors.WarmLight
	light.Shadows = false
	light.Parent = part
	return light
end

-- Puts text on one face of a part. opts: name, font, glow, stroke (Color3)
function Build.text(part, face: Enum.NormalId, text: string, color: Color3, opts)
	opts = opts or {}
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	if opts.glow then
		gui.LightInfluence = 0
		gui.Brightness = 2
	end
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = opts.name or "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = opts.font or Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color
	label.Text = text
	label.Parent = gui

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0.04, 0)
	padding.PaddingRight = UDim.new(0.04, 0)
	padding.PaddingTop = UDim.new(0.08, 0)
	padding.PaddingBottom = UDim.new(0.08, 0)
	padding.Parent = label

	if opts.stroke then
		local stroke = Instance.new("UIStroke")
		stroke.Color = opts.stroke
		stroke.Thickness = 3
		stroke.Parent = label
	end
	return label
end

return Build
