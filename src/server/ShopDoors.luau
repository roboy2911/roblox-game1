-- Shop gates and ropes:
--   the checkout gate (back side of the counter island) swings open when the owner comes near,
--   the velvet ropes across the aisles to the back area disappear once the owner has Bigger shop.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ShopDoors = {}

local GATE_ANGLE = 95 -- degrees; positive swings toward the front (into the checkout)
local GATE_REACH = 7 -- studs from the gate's middle

local PlayerData, Plots -- set in Start
local doors = {} -- [model] = { Hinge, Parts, Open }

-- Remembers where each part sits relative to the hinge, so it can swing around it.
local function doorFor(model: Model)
	if doors[model] then
		return doors[model]
	end
	local hinge = model:GetAttribute("Hinge")
	local parts = {}
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, { Part = part, Offset = hinge:ToObjectSpace(part.CFrame) })
		end
	end
	doors[model] = { Hinge = hinge, Parts = parts, Open = false }
	return doors[model]
end

local function swing(model: Model, open: boolean, angle: number)
	local door = doorFor(model)
	if door.Open == open then
		return
	end
	door.Open = open
	local hinge = if open then door.Hinge * CFrame.Angles(0, math.rad(angle), 0) else door.Hinge
	for _, entry in door.Parts do
		TweenService:Create(entry.Part, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { CFrame = hinge * entry.Offset }):Play()
	end
end

local function near(position: Vector3, root: BasePart?): boolean
	return root ~= nil and (root.Position - position).Magnitude <= GATE_REACH
end

local function update(shop)
	local userId = shop:GetAttribute("OwnerUserId")
	local owner = userId and Players:GetPlayerByUserId(userId)

	-- Ropes to the back area: gone once the owner has the Bigger shop upgrade
	local ropes = shop:FindFirstChild("BackRopes")
	if ropes then
		local unlocked = owner ~= nil and PlayerData.GetUpgrade(owner, "BiggerShop") >= 1
		if ropes:GetAttribute("Hidden") ~= unlocked then
			ropes:SetAttribute("Hidden", unlocked)
			for _, part in ropes:GetDescendants() do
				if part:IsA("BasePart") then
					part.Transparency = if unlocked then 1 else 0
				elseif part:IsA("SurfaceGui") then
					part.Enabled = not unlocked
				end
			end
		end
	end

	-- Checkout gate: open while the owner is close (only the owner goes in)
	local gate = shop.Counter:FindFirstChild("Gate")
	if gate then
		local middle = (doorFor(gate).Hinge * CFrame.new(1.95, 0, 0)).Position
		local character = owner and owner.Character
		swing(gate, near(middle, character and character:FindFirstChild("HumanoidRootPart")), GATE_ANGLE)
	end
end

function ShopDoors.Start(playerData, plots)
	PlayerData, Plots = playerData, plots
	task.spawn(function()
		while true do
			for _, shop in Plots.GetAllShops() do
				update(shop)
			end
			task.wait(0.2)
		end
	end)
end

return ShopDoors
