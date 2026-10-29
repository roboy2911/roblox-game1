-- Loads the detailed mesh models listed in MeshCatalog (uploaded with tools/meshes/upload.py).
-- Each model is downloaded once, cleaned up, then cloned whenever it's needed.
-- If a model isn't in the catalog or fails to load, callers fall back to the part version.

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MeshCatalog = require(script.Parent.MeshCatalog)

local MeshLoader = {}

-- Finished models are kept here so players' devices can download the meshes early
-- (see src/client/Main.client.luau). Otherwise the first spawn of each item appears late.
local templateFolder = Instance.new("Folder")
templateFolder.Name = "MeshTemplates"
templateFolder.Parent = ReplicatedStorage

-- Roblox materials like Wood and Metal add a texture pattern on top of the mesh.
-- Use smooth surfaces instead; metal parts get some shine so gold still looks like gold.
local KEEP_MATERIAL = {
	[Enum.Material.SmoothPlastic] = true,
	[Enum.Material.Glass] = true,
	[Enum.Material.Neon] = true,
	[Enum.Material.ForceField] = true,
}
local SHINY = {
	[Enum.Material.Metal] = true,
	[Enum.Material.Foil] = true,
	[Enum.Material.DiamondPlate] = true,
	[Enum.Material.CorrodedMetal] = true,
}
local METAL_SHINE = 0.25

local templates = {} -- [id] = Model, or false if loading failed
local loading = {} -- [id] = true while downloading

-- World-aligned box around all parts: returns min and max corners.
local function worldExtents(model)
	local lo = Vector3.new(math.huge, math.huge, math.huge)
	local hi = -lo
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			local half = part.Size / 2
			for _, sx in { -1, 1 } do
				for _, sy in { -1, 1 } do
					for _, sz in { -1, 1 } do
						local corner = part.CFrame * Vector3.new(sx * half.X, sy * half.Y, sz * half.Z)
						lo = lo:Min(corner)
						hi = hi:Max(corner)
					end
				end
			end
		end
	end
	return lo, hi
end

-- How well a box's proportions match the expected size (lower = better).
local function shapeError(size: Vector3, expected: Vector3)
	local a = size / math.max(size.X, size.Y, size.Z)
	local b = expected / math.max(expected.X, expected.Y, expected.Z)
	return math.abs(a.X - b.X) + math.abs(a.Y - b.Y) + math.abs(a.Z - b.Z)
end

local function lookFor(entry, partName)
	if entry.Parts[partName] then
		return entry.Parts[partName]
	end
	-- Roblox may add suffixes when importing; match on the start of the name.
	for name, look in entry.Parts do
		if partName:sub(1, #name) == name then
			return look
		end
	end
	return nil
end

local function prepare(id, entry, loaded)
	local model = Instance.new("Model")
	model.Name = id
	for _, part in loaded:GetDescendants() do
		if part:IsA("MeshPart") then
			local look = lookFor(entry, part.Name)
			if look then
				part.Color = look.Color
				part.Transparency = look.Transparency
				if KEEP_MATERIAL[look.Material] then
					part.Material = look.Material
					part.Reflectance = look.Reflectance
				else
					part.Material = Enum.Material.SmoothPlastic
					part.Reflectance = if SHINY[look.Material]
						then math.max(look.Reflectance, METAL_SHINE)
						else look.Reflectance
				end
			end
			part.Anchored = true
			part.CanCollide = false
			part.Parent = model
		end
	end
	if #model:GetChildren() == 0 then
		return nil
	end

	-- Stand it upright: try a few rotations and keep the one whose shape matches best.
	local best, bestError = CFrame.identity, math.huge
	local start = model:GetPivot()
	for _, rotation in { CFrame.identity, CFrame.Angles(-math.pi / 2, 0, 0), CFrame.Angles(math.pi / 2, 0, 0) } do
		model:PivotTo(CFrame.new(start.Position) * rotation)
		local lo, hi = worldExtents(model)
		local err = shapeError(hi - lo, entry.Size)
		if err < bestError then
			best, bestError = rotation, err
		end
	end
	model:PivotTo(CFrame.new(start.Position) * best)

	-- Pivot at the bottom-center, then scale to the intended size.
	local lo, hi = worldExtents(model)
	model.WorldPivot = CFrame.new((lo.X + hi.X) / 2, lo.Y, (lo.Z + hi.Z) / 2)
	local height = hi.Y - lo.Y
	if height > 0 then
		model:ScaleTo(model:GetScale() * entry.Size.Y / height)
	end

	-- Props keep their own attachment point (the bottom of a lamp pole, the back of a wall clock...).
	if entry.Origin then
		lo, hi = worldExtents(model)
		model.WorldPivot = CFrame.new((lo.X + hi.X) / 2, lo.Y, (lo.Z + hi.Z) / 2) + entry.Origin
	end
	return model
end

local function load(id)
	local entry = MeshCatalog[id]
	if not entry then
		return nil
	end
	if templates[id] ~= nil then
		return templates[id] or nil
	end
	if loading[id] then
		while loading[id] do
			task.wait()
		end
		return templates[id] or nil
	end

	loading[id] = true
	local ok, result = pcall(function()
		return InsertService:LoadAsset(entry.AssetId)
	end)
	local template = nil
	if ok then
		template = prepare(id, entry, result)
		result:Destroy()
		if not template then
			warn(`[MeshLoader] Asset {entry.AssetId} for "{id}" has no mesh parts.`)
		end
	else
		warn(`[MeshLoader] Couldn't load "{id}" (asset {entry.AssetId}): {result}`)
	end
	if template then
		template.Parent = templateFolder
	end
	templates[id] = template or false
	loading[id] = nil
	return template
end

-- Returns true if a detailed model exists for this id (it may still need loading).
function MeshLoader.Has(id: string): boolean
	return MeshCatalog[id] ~= nil
end

-- Returns a copy of the detailed model with its pivot at `cf`, or nil.
-- The pivot is the bottom-center, or the model's own attachment point if it has an Origin.
-- `accent` recolors the parts named "Accent" (e.g. a shop's own color).
-- May wait while the model downloads the first time.
function MeshLoader.Clone(id: string, cf: CFrame, accent: Color3?): Model?
	local template = load(id)
	if not template then
		return nil
	end
	local model = template:Clone()
	if accent then
		for _, part in model:GetChildren() do
			if part:IsA("BasePart") and part.Name:sub(1, 6) == "Accent" then
				part.Color = accent
			end
		end
	end
	model:PivotTo(cf)
	return model
end

-- Starts downloading every model in the background so they're ready when needed.
function MeshLoader.Preload()
	for id in MeshCatalog do
		task.spawn(load, id)
	end
end

return MeshLoader
