-- Testing helpers that only exist when you press Play in Studio.
-- Real players never see these.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Items)
local ItemModels = require(script.Parent.ItemModels)

local DebugTools = {}

local function makePrompt(parent, actionText)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = "Debug"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

-- Green pad on the street that gives $50.
local function cashPad(PlayerData)
	local pad = Instance.new("Part")
	pad.Name = "DebugCashPad"
	pad.Size = Vector3.new(4, 1, 4)
	pad.Position = Vector3.new(0, 0.5, -12)
	pad.Anchored = true
	pad.Color = Color3.fromRGB(80, 255, 80)
	pad.Material = Enum.Material.Neon
	makePrompt(pad, "Get $50").Triggered:Connect(function(player)
		PlayerData.AddCash(player, 50)
	end)
	pad.Parent = workspace
end

-- Floating label above an item: name, rarity, condition and its secret value.
local function addLabel(model, rolled)
	local boxCFrame, boxSize = model:GetBoundingBox()
	local anchor = Instance.new("Part")
	anchor.Name = "LabelAnchor"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.Position = boxCFrame.Position + Vector3.new(0, boxSize.Y / 2 + 1.2, 0)
	anchor.Parent = model

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(240, 84)
	gui.MaxDistance = 60
	gui.Parent = anchor

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = gui

	local rarityColor = Items.Rarities[rolled.Rarity].Color
	local lines = {
		{ rolled.Name, rarityColor, 32 },
		{ `{rolled.Rarity} • {rolled.Condition}`, rarityColor, 22 },
		{ `True value: {Items.FormatMoney(rolled.TrueValue)} (debug)`, Color3.new(1, 1, 1), 22 },
	}
	for i, line in lines do
		local label = Instance.new("TextLabel")
		label.LayoutOrder = i
		label.Size = UDim2.new(1, 0, 0, line[3] + 4)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextSize = line[3]
		label.TextColor3 = line[2]
		label.Text = line[1]
		label.TextStrokeTransparency = 0.3
		label.Parent = gui
	end
end

-- Button on each shop's counter that spawns a random item on it.
local function itemSpawners(Plots)
	for _, shop in Plots.GetAllShops() do
		local top = shop.Counter.Top
		local prompt = makePrompt(top, "Spawn random item")
		prompt.UIOffset = Vector2.new(0, 40)

		prompt.Triggered:Connect(function(player)
			if Plots.GetShop(player) ~= shop then
				return -- only the owner can use their counter
			end
			local old = shop:FindFirstChild("DebugItem")
			if old then
				old:Destroy()
			end

			local rolled = Items.Roll()
			-- On the counter, turned so its front faces the owner
			local cf = top.CFrame * CFrame.new(0, top.Size.Y / 2, 0.2) * CFrame.Angles(0, math.pi, 0)
			local model = ItemModels.Build(rolled.Id, cf)
			model.Name = "DebugItem"
			addLabel(model, rolled)
			model.Parent = shop

			print(`[Debug] {player.Name} got: {rolled.Name} ({rolled.Rarity}, {rolled.Condition}) worth {Items.FormatMoney(rolled.TrueValue)}`)
		end)
	end
end

function DebugTools.Start(PlayerData, Plots)
	cashPad(PlayerData)
	itemSpawners(Plots)
end

return DebugTools
