-- The upgrades shop: a ⬆ button that opens a list of upgrades with their level and price.
-- The server checks the price and applies the upgrade; this only shows and sends.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateRemote = remotes:WaitForChild("UpgradesUpdate")
local actionRemote = remotes:WaitForChild("UpgradesAction")

local player = Players.LocalPlayer
local DARK = Color3.fromRGB(45, 45, 60)
local FONT = Enum.Font.FredokaOne
local GREEN = Color3.fromRGB(60, 180, 100)
local GREY = Color3.fromRGB(150, 150, 160)

local gui = Instance.new("ScreenGui")
gui.Name = "UpgradesGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function round(obj, radius)
	Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius)
end
local function outline(obj, thickness)
	local stroke = Instance.new("UIStroke", obj)
	stroke.Thickness = thickness
	stroke.Color = DARK
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end
local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = FONT
	l.TextColor3 = DARK
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.RichText = true
	for k, v in props do
		l[k] = v
	end
	l.Parent = parent
	return l
end

-- Toggle button, above the inventory button
local toggle = Instance.new("TextButton")
toggle.AnchorPoint = Vector2.new(0, 0.5)
toggle.Position = UDim2.new(0, 12, 0.5, -58)
toggle.Size = UDim2.fromOffset(150, 48)
toggle.BackgroundColor3 = Color3.fromRGB(90, 200, 230)
toggle.Font = FONT
toggle.TextSize = 20
toggle.TextColor3 = DARK
toggle.Text = "⬆ Upgrades"
toggle.Parent = gui
round(toggle, 14)
outline(toggle, 3)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.9, 0, 0.75, 0)
panel.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
panel.Visible = false
panel.Parent = gui
round(panel, 18)
outline(panel, 3)
Instance.new("UISizeConstraint", panel).MaxSize = Vector2.new(520, 470)

label(panel, {
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -80, 0, 34),
	TextSize = 26,
	Text = "Upgrades",
})
local cashLabel = label(panel, {
	Position = UDim2.fromOffset(18, 42),
	Size = UDim2.new(1, -80, 0, 22),
	TextSize = 16,
	TextColor3 = Color3.fromRGB(110, 110, 125),
	Text = "",
})
local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -12, 0, 10)
close.Size = UDim2.fromOffset(40, 40)
close.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
close.Font = FONT
close.TextSize = 22
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "X"
close.Parent = panel
round(close, 12)
outline(close, 2)

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(12, 72)
list.Size = UDim2.new(1, -24, 1, -84)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 8
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- One row per upgrade, made once and updated as levels change
local rows = {}
for i, upgrade in Config.Upgrades do
	local frame = Instance.new("Frame")
	frame.LayoutOrder = i
	frame.Size = UDim2.new(1, -12, 0, 78)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.Parent = list
	round(frame, 12)
	outline(frame, 2)
	local title = label(frame, {
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -150, 0, 26),
		TextSize = 20,
		Text = upgrade.Name,
	})
	label(frame, {
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -150, 0, 40),
		TextSize = 14,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = Color3.fromRGB(110, 110, 125),
		Text = upgrade.Description,
	})
	local buy = Instance.new("TextButton")
	buy.AnchorPoint = Vector2.new(1, 0.5)
	buy.Position = UDim2.new(1, -10, 0.5, 0)
	buy.Size = UDim2.fromOffset(126, 44)
	buy.Font = FONT
	buy.TextSize = 17
	buy.TextColor3 = Color3.new(1, 1, 1)
	buy.Parent = frame
	round(buy, 10)
	outline(buy, 2)
	buy.Activated:Connect(function()
		actionRemote:FireServer("Buy", upgrade.Id)
	end)
	rows[upgrade.Id] = { Title = title, Buy = buy, Upgrade = upgrade }
end

local levels = {}

local function cash(): number
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Cash")
	return if value then value.Value else 0
end

local function refresh()
	local money = cash()
	cashLabel.Text = `You have {Items.FormatMoney(money)}`
	for id, row in rows do
		local upgrade = row.Upgrade
		local level = levels[id] or (if id == "Appraisal" then 1 else 0)
		local maxLevel = #upgrade.Costs + (if id == "Appraisal" then 1 else 0)
		local cost = upgrade.Costs[if id == "Appraisal" then level else level + 1]
		row.Title.Text = `{upgrade.Name}  <font color="#6e6e7d" size="15">lv {level}/{maxLevel}</font>`
		if not cost then
			row.Buy.Text = "MAX"
			row.Buy.BackgroundColor3 = GREY
			row.Buy.AutoButtonColor = false
		else
			row.Buy.Text = `Buy {Items.FormatMoney(cost)}`
			row.Buy.BackgroundColor3 = if money >= cost then GREEN else GREY
			row.Buy.AutoButtonColor = money >= cost
		end
	end
end

updateRemote.OnClientEvent:Connect(function(data)
	levels = data.Levels
	refresh()
end)

-- Update the buttons when cash changes (green = you can afford it)
task.spawn(function()
	local stats = player:WaitForChild("leaderstats", 60)
	local value = stats and stats:WaitForChild("Cash", 10)
	if value then
		value.Changed:Connect(refresh)
	end
end)

toggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then
		actionRemote:FireServer("Refresh")
	end
end)
close.Activated:Connect(function()
	panel.Visible = false
end)

refresh()
actionRemote:FireServer("Refresh")
