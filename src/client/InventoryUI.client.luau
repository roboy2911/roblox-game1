-- The inventory screen: a 🎒 button that opens a list of the items you've bought,
-- with Display / Take back buttons. The server does the work; this only shows and sends.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Items)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateRemote = remotes:WaitForChild("InventoryUpdate")
local actionRemote = remotes:WaitForChild("InventoryAction")

local player = Players.LocalPlayer
local DARK = Color3.fromRGB(45, 45, 60)
local CREAM = Color3.fromRGB(255, 250, 240)
local FONT = Enum.Font.FredokaOne

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	Instance.new("UICorner", parent).CornerRadius = UDim.new(0, radius)
end
local function outline(parent, thickness)
	local stroke = Instance.new("UIStroke", parent)
	stroke.Thickness = thickness
	stroke.Color = DARK
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return stroke
end
local function text(class, props)
	local t = Instance.new(class)
	t.BackgroundTransparency = 1
	t.Font = FONT
	t.TextColor3 = DARK
	t.RichText = true
	for k, v in props do
		t[k] = v
	end
	return t
end

-- Toggle button (left side, above the chat/leaderboard area)
local toggle = text("TextButton", {
	Name = "Toggle",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, 0),
	Size = UDim2.fromOffset(150, 48),
	BackgroundTransparency = 0,
	BackgroundColor3 = Color3.fromRGB(250, 200, 60),
	TextSize = 20,
	Text = "🎒 Inventory",
	Parent = gui,
})
corner(toggle, 14)
outline(toggle, 3)

-- Panel
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.9, 0, 0.75, 0)
panel.BackgroundColor3 = CREAM
panel.Visible = false
panel.Parent = gui
corner(panel, 18)
outline(panel, 3)
local limit = Instance.new("UISizeConstraint", panel)
limit.MaxSize = Vector2.new(520, 560)

local header = text("TextLabel", {
	Position = UDim2.fromOffset(18, 10),
	Size = UDim2.new(1, -80, 0, 34),
	TextSize = 26,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "Inventory",
	Parent = panel,
})
local spotsLabel = text("TextLabel", {
	Position = UDim2.fromOffset(18, 42),
	Size = UDim2.new(1, -170, 0, 22),
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.fromRGB(110, 110, 125),
	Text = "",
	Parent = panel,
})
local close = text("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, 10),
	Size = UDim2.fromOffset(40, 40),
	BackgroundTransparency = 0,
	BackgroundColor3 = Color3.fromRGB(220, 70, 70),
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 22,
	Text = "X",
	Parent = panel,
})
corner(close, 12)
outline(close, 2)
local displayAll = text("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -60, 0, 14),
	Size = UDim2.fromOffset(110, 34),
	BackgroundTransparency = 0,
	BackgroundColor3 = Color3.fromRGB(60, 120, 230),
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 16,
	Text = "Display all",
	Parent = panel,
})
corner(displayAll, 10)
outline(displayAll, 2)

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

local empty = text("TextLabel", {
	Size = UDim2.new(1, -12, 0, 60),
	TextSize = 18,
	TextColor3 = Color3.fromRGB(130, 130, 145),
	TextWrapped = true,
	Text = "Nothing yet! Haggle with sellers at your counter to buy items.",
})

-- One row per item
local function row(item, order)
	local frame = Instance.new("Frame")
	frame.LayoutOrder = order
	frame.Size = UDim2.new(1, -12, 0, 62)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	corner(frame, 12)
	local stroke = outline(frame, 2)
	stroke.Color = Items.Rarities[item.Rarity].Color:Lerp(DARK, 0.25)

	local color = Items.Rarities[item.Rarity].Color:Lerp(DARK, 0.15):ToHex()
	text("TextLabel", {
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -140, 0, 26),
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = `<font color="#{color}">{item.Name}</font>`,
		Parent = frame,
	})
	text("TextLabel", {
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -140, 0, 22),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(110, 110, 125),
		Text = `{item.Rarity} • {item.Condition} • paid {Items.FormatMoney(item.Paid or 0)}`
			.. (if item.Displayed then " • <b>on display</b>" else ""),
		Parent = frame,
	})
	local button = text("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(116, 40),
		BackgroundTransparency = 0,
		BackgroundColor3 = if item.Displayed then Color3.fromRGB(130, 130, 145) else Color3.fromRGB(60, 180, 100),
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 17,
		Text = if item.Displayed then "Take back" else "Display",
		Parent = frame,
	})
	corner(button, 10)
	outline(button, 2)
	button.Activated:Connect(function()
		actionRemote:FireServer(if item.Displayed then "TakeBack" else "Display", item.Uid)
	end)
	frame.Parent = list
end

local function render(data)
	for _, child in list:GetChildren() do
		if child == empty then
			child.Parent = nil
		elseif child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	local itemsList = table.clone(data.Items)
	-- Rarest first, then by name
	table.sort(itemsList, function(a, b)
		local ra, rb = Items.Rarities[a.Rarity].Order, Items.Rarities[b.Rarity].Order
		if ra ~= rb then
			return ra > rb
		end
		return a.Name < b.Name
	end)
	header.Text = `Inventory ({#itemsList})`
	toggle.Text = `🎒 Inventory ({#itemsList})`
	spotsLabel.Text = `Shop display spots: {data.SpotsUsed}/{data.SpotsTotal} used`
	if #itemsList == 0 then
		empty.Parent = list
	end
	for i, item in itemsList do
		row(item, i)
	end
end

updateRemote.OnClientEvent:Connect(render)
toggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
	if panel.Visible then
		actionRemote:FireServer("Refresh")
	end
end)
close.Activated:Connect(function()
	panel.Visible = false
end)
displayAll.Activated:Connect(function()
	actionRemote:FireServer("DisplayAll")
end)

actionRemote:FireServer("Refresh")
