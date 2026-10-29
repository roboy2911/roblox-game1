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

-- Puts the prop `name` (catalog id "Prop<name>") with its attachment point at `cf`.
-- opts (all optional):
--   accent   Color3 for the parts named "Accent"
--   light    { range, brightness } adds a light to the glowing part
--   collide  false to let players walk through it (default: solid)
function Props.Place(parent: Instance, name: string, cf: CFrame, opts): Model?
	opts = opts or {}
	local model = MeshLoader.Clone("Prop" .. name, cf, opts.accent)
	if not model then
		return nil
	end
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

return Props
