-- Swings the shops' doors:
--   the counter gate opens when the owner or a customer comes near (other players can't open it),
--   the back room door opens for owners who bought the Bigger shop upgrade, and stays locked otherwise.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ShopDoors = {}

local GATE_ANGLE = -95 -- degrees; negative swings toward the back (the owner's side)
local DOOR_ANGLE = -100
local GATE_REACH = 7 -- studs from the gate's middle

local PlayerData, Plots, Customers -- set in Start
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

	-- Back room door: open only with the upgrade
	local backDoor = shop:FindFirstChild("BackDoor")
	if backDoor then
		local unlocked = owner ~= nil and PlayerData.GetUpgrade(owner, "BiggerShop") >= 1
		swing(backDoor, unlocked, DOOR_ANGLE)
		local sign = backDoor:FindFirstChild("LockSign")
		local gui = sign and sign:FindFirstChildOfClass("SurfaceGui")
		if gui then
			gui.Enabled = not unlocked
		end
	end

	-- Gate: open while the owner or a customer is close
	local gate = shop.Counter:FindFirstChild("Gate")
	if gate then
		local middle = (doorFor(gate).Hinge * CFrame.new(1.95, 0, 0)).Position
		local character = owner and owner.Character
		local customer = Customers.Get(shop)
		local open = near(middle, character and character:FindFirstChild("HumanoidRootPart"))
			or (customer ~= nil and customer.Npc ~= nil and near(middle, customer.Root))
		swing(gate, open, GATE_ANGLE)
	end
end

function ShopDoors.Start(playerData, plots, customers)
	PlayerData, Plots, Customers = playerData, plots, customers
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
