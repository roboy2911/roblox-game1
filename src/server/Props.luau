-- Detailed mesh versions of shop and town props (made in tools/meshes/models/Prop*.py).
-- Place() returns nil when a prop isn't uploaded yet, so the caller builds the part version instead.

local Build = require(script.Parent.Build)
local MeshLoader = require(script.Parent.MeshLoader)

local Props = {}

local function findGlow(model)
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") and part.Name:sub(1, 4) == "Glow" then
			return part
		end
	end
	return nil
end

-- Stretches a freshly cloned model (still at its template spot, pivot not rotated) by `factor`
-- along its own X, Y and Z, around its pivot. Works because every part is turned in 90° steps.
local function stretch(model: Model, factor: Vector3)
	local pivot = model:GetPivot().Position
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			local cf = part.CFrame
			local function along(axis: Vector3)
				return math.abs(axis.X) * factor.X + math.abs(axis.Y) * factor.Y + math.abs(axis.Z) * factor.Z
			end
			part.Size = part.Size * Vector3.new(along(cf.XVector), along(cf.YVector), along(cf.ZVector))
			part.CFrame = cf.Rotation + pivot + (cf.Position - pivot) * factor
		end
	end
end

-- Puts the prop `name` (catalog id "Prop<name>") with its attachment point at `cf`.
-- opts (all optional):
--   accent   Color3 for the parts named "Accent"
--   light    { range, brightness } adds a light to the glowing part
--   collide  false to let players walk through it (default: solid)
--   stretch  Vector3 to stretch it along its own X, Y, Z (1 = normal)
function Props.Place(parent: Instance, name: string, cf: CFrame, opts): Model?
	opts = opts or {}
	local model = MeshLoader.Clone("Prop" .. name, CFrame.identity, opts.accent)
	if not model then
		return nil
	end
	if opts.stretch then
		stretch(model, opts.stretch)
	end
	model:PivotTo(cf)
	model.Name = name
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			part.CanCollide = opts.collide ~= false
		end
	end
	if opts.light then
		local glow = findGlow(model)
		if glow then
			Build.light(glow, opts.light[1], opts.light[2])
		end
	end
	model.Parent = parent
	return model
end

-- Lines up copies of a prop (each `length` studs long along its own X) from `from` to `to`,
-- facing `facing` (the way the prop's front points), stretched a little so they fit exactly.
-- Returns true if it worked (so the caller can hide the plain parts), false if the prop isn't uploaded.
function Props.Row(parent: Instance, name: string, from: Vector3, to: Vector3, facing: Vector3, length: number, opts)
	local distance = (to - from).Magnitude
	local count = math.max(1, math.round(distance / length))
	local step = (to - from) / count
	local rowOpts = table.clone(opts or {})
	rowOpts.stretch = Vector3.new(distance / count / length, 1, 1)
	for i = 1, count do
		local center = from + step * (i - 0.5)
		-- Local -Z faces `facing`, local X runs along the row (either way: the pieces are symmetric)
		local back = -facing.Unit
		local cf = CFrame.fromMatrix(center, Vector3.yAxis:Cross(back), Vector3.yAxis, back)
		if not Props.Place(parent, name, cf, rowOpts) then
			return false
		end
	end
	return true
end

-- Hides the plain parts that a detailed mesh now covers. They stay solid, so walking and
-- clicking still work the same; only parts whose names are in `names` are hidden, and
-- mesh parts are never touched.
function Props.Hide(model: Instance, names: { [string]: boolean })
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and not part:IsA("MeshPart") and names[part.Name] then
			part.Transparency = 1
			part.CastShadow = false
			for _, child in part:GetChildren() do
				if child:IsA("Decal") or child:IsA("Texture") then
					child.Transparency = 1
				end
			end
		end
	end
end

return Props
