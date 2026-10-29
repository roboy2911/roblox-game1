-- Admin menu (testing tools) for the user IDs in Config.AdminUserIds only.
-- The server checks every request, so nobody else can use these even with a hacked client.
-- Replaces the old Studio-only cash pad and counter item spawner.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local ItemModels = require(script.Parent.ItemModels)
local Remotes = require(script.Parent.Remotes)

local Admin = {}

local actionRemote = Remotes.Event("AdminAction")
local CASH_AMOUNTS = { [50] = true, [500] = true, [5000] = true, [50000] = true }

local PlayerData, Plots -- set in Start

function Admin.IsAdmin(player): boolean
	return table.find(Config.AdminUserIds, player.UserId) ~= nil
end

-- Floating label over a test item: name, rarity, condition and its secret value.
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
		{ `True value: {Items.FormatMoney(rolled.TrueValue)} (admin)`, Color3.new(1, 1, 1), 22 },
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

-- Puts a random item (with its true value showing) in the middle of the admin's counter.
local function spawnTestItem(player)
	local shop = Plots.GetShop(player)
	if not shop then
		return
	end
	local old = shop:FindFirstChild("TestItem")
	if old then
		old:Destroy()
	end
	local rolled = Items.Roll()
	local top = shop.Counter.Top
	local cf = top.CFrame * CFrame.new(0, top.Size.Y / 2, 0.2) * CFrame.Angles(0, math.pi, 0)
	local model = ItemModels.Build(rolled.Id, cf)
	model.Name = "TestItem"
	addLabel(model, rolled)
	model.Parent = shop
	print(`[Admin] {player.Name} spawned: {rolled.Name} ({rolled.Rarity}, {rolled.Condition}) worth {Items.FormatMoney(rolled.TrueValue)}`)
end

local function clearTestItem(player)
	local shop = Plots.GetShop(player)
	local item = shop and shop:FindFirstChild("TestItem")
	if item then
		item:Destroy()
	end
end

-- Adds a random item straight into the admin's inventory (free), to test displaying and selling.
local function giveItem(player)
	local rolled = Items.Roll()
	rolled.Paid = 0
	PlayerData.AddItem(player, rolled)
	print(`[Admin] {player.Name} got {rolled.Name} in their inventory (worth {Items.FormatMoney(rolled.TrueValue)})`)
end

function Admin.Start(playerData, plots)
	PlayerData, Plots = playerData, plots

	local function mark(player)
		if Admin.IsAdmin(player) then
			player:SetAttribute("IsAdmin", true) -- the menu button only appears for admins
		end
	end
	Players.PlayerAdded:Connect(mark)
	for _, player in Players:GetPlayers() do
		mark(player)
	end

	actionRemote.OnServerEvent:Connect(function(player, action, value)
		if not Admin.IsAdmin(player) then
			return
		end
		if action == "Cash" and CASH_AMOUNTS[value] then
			PlayerData.AddCash(player, value)
		elseif action == "SpawnItem" then
			spawnTestItem(player)
		elseif action == "ClearItem" then
			clearTestItem(player)
		elseif action == "GiveItem" then
			giveItem(player)
		end
	end)
end

return Admin
