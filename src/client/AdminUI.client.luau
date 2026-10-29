-- Admin menu (testing tools). Only shows up for admins (the server marks them with
-- the IsAdmin attribute), and the server checks every button press again.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local actionRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AdminAction")

local DARK = Color3.fromRGB(45, 45, 60)
local FONT = Enum.Font.FredokaOne

-- Wait until the server says we're an admin (it never will for anyone else)
while not player:GetAttribute("IsAdmin") do
	player:GetAttributeChangedSignal("IsAdmin"):Wait()
end

local gui = Instance.new("ScreenGui")
gui.Name = "AdminGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function styled(button, color)
	button.BackgroundColor3 = color
	button.Font = FONT
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 18
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke", button)
	stroke.Thickness = 2
	stroke.Color = DARK
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

-- Toggle button, under the inventory button
local toggle = Instance.new("TextButton")
toggle.AnchorPoint = Vector2.new(0, 0.5)
toggle.Position = UDim2.new(0, 12, 0.5, 58)
toggle.Size = UDim2.fromOffset(150, 44)
toggle.Text = "🛠 Admin"
toggle.Parent = gui
styled(toggle, Color3.fromRGB(110, 90, 200))

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 172, 0.5, 58)
panel.Size = UDim2.fromOffset(240, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Thickness = 3
panelStroke.Color = DARK
local padding = Instance.new("UIPadding", panel)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
local layout = Instance.new("UIListLayout", panel)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local order = 0
local function heading(text)
	order += 1
	local label = Instance.new("TextLabel")
	label.LayoutOrder = order
	label.Size = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.TextSize = 18
	label.TextColor3 = DARK
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = panel
end
local function action(text, color, ...)
	local args = { ... }
	order += 1
	local button = Instance.new("TextButton")
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 38)
	button.Text = text
	button.Parent = panel
	styled(button, color)
	button.Activated:Connect(function()
		actionRemote:FireServer(table.unpack(args))
	end)
end

local GREEN = Color3.fromRGB(60, 180, 100)
local BLUE = Color3.fromRGB(60, 120, 230)
local GREY = Color3.fromRGB(130, 130, 145)

heading("Cash")
for _, amount in { 50, 500, 5000, 50000 } do
	action(`+ ${amount}`, GREEN, "Cash", amount)
end
heading("Items")
action("Spawn item on counter", BLUE, "SpawnItem")
action("Clear counter item", GREY, "ClearItem")
action("Give random item", BLUE, "GiveItem")
heading("Appraisal level")
action("Appraisal +1", GREEN, "Appraisal", 1)
action("Appraisal -1", GREY, "Appraisal", -1)

toggle.Activated:Connect(function()
	panel.Visible = not panel.Visible
end)
