-- The haggle panel: shows the customer's item, price and mood.
-- Buying from a seller: Offer / Accept / Walk away. Selling to a buyer: Ask / Sell / Refuse.
-- The server decides everything; this only shows and sends.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Items)
local haggleRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Haggle")

local player = Players.LocalPlayer

local DARK = Color3.fromRGB(45, 45, 60)
local FONT = Enum.Font.FredokaOne

-- Building the panel -----------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "HaggleGui"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -20)
panel.Size = UDim2.fromOffset(440, 270)
panel.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Thickness = 3
panelStroke.Color = DARK
local sizeLimit = Instance.new("UISizeConstraint", panel)
sizeLimit.MaxSize = Vector2.new(440, 270)
local scale = Instance.new("UIScale", panel)

local function label(name, text, size, pos, textSize, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Font = FONT
	l.TextSize = textSize
	l.TextColor3 = color or DARK
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.RichText = true
	l.Text = text
	l.Parent = panel
	return l
end

local function button(text, color, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = color
	b.Font = FONT
	b.TextSize = 20
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = text
	b.AutoButtonColor = true
	b.Parent = panel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke", b)
	stroke.Thickness = 2
	stroke.Color = DARK
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return b
end

local title = label("Title", "", UDim2.new(1, -90, 0, 30), UDim2.fromOffset(18, 12), 26)
local subtitle = label("Subtitle", "", UDim2.new(1, -90, 0, 20), UDim2.fromOffset(18, 42), 17)
local mood = label("Mood", "", UDim2.fromOffset(70, 56), UDim2.new(1, -84, 0, 10), 44)
mood.TextXAlignment = Enum.TextXAlignment.Center
local message = label("Message", "", UDim2.new(1, -36, 0, 44), UDim2.fromOffset(18, 68), 19)
local asking = label("Asking", "", UDim2.new(0.5, -18, 0, 26), UDim2.fromOffset(18, 114), 22)
local cash = label("Cash", "", UDim2.new(0.5, -18, 0, 26), UDim2.new(0.5, 0, 0, 114), 18)
cash.TextXAlignment = Enum.TextXAlignment.Right
local debugLabel = label("Debug", "", UDim2.new(1, -36, 0, 18), UDim2.fromOffset(18, 140), 14,
	Color3.fromRGB(150, 150, 160))

local input = Instance.new("TextBox")
input.Size = UDim2.fromOffset(150, 42)
input.Position = UDim2.fromOffset(18, 164)
input.BackgroundColor3 = Color3.new(1, 1, 1)
input.Font = FONT
input.TextSize = 22
input.TextColor3 = DARK
input.PlaceholderText = "$ your offer"
input.ClearTextOnFocus = false
input.Text = ""
input.Parent = panel
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", input).Color = DARK

local offerButton = button("Offer", Color3.fromRGB(60, 120, 230), UDim2.fromOffset(110, 42), UDim2.fromOffset(176, 164))
local acceptButton = button("Accept", Color3.fromRGB(60, 180, 100), UDim2.fromOffset(120, 42), UDim2.fromOffset(294, 164))
local walkButton = button("Walk away", Color3.fromRGB(220, 70, 70), UDim2.fromOffset(150, 40), UDim2.fromOffset(18, 216))
local closeButton = button("Close", Color3.fromRGB(130, 130, 145), UDim2.fromOffset(110, 40), UDim2.new(1, -128, 0, 216))
local hint = label("Hint", "", UDim2.fromOffset(130, 40), UDim2.fromOffset(176, 216), 13, Color3.fromRGB(130, 130, 145))
hint.TextXAlignment = Enum.TextXAlignment.Center
hint.Text = "Close keeps the deal open; talk to them again to reopen."

-- Shrink the panel on small (phone) screens
local function fit()
	local camera = workspace.CurrentCamera
	local width = camera and camera.ViewportSize.X or 1000
	scale.Scale = math.min(1, (width - 32) / 440)
end
fit()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

-- Showing the deal -------------------------------------------------------------

local current = nil -- last state from the server

local function moodFace(value: number): string
	if value >= 70 then
		return "😀"
	elseif value >= 45 then
		return "🙂"
	elseif value >= 20 then
		return "😐"
	end
	return "😠"
end

local function parseOffer(): number?
	local digits = input.Text:gsub("[^%d]", "")
	return tonumber(digits)
end

local function show(state)
	if not current or current.Customer ~= state.Customer or current.ItemName ~= state.ItemName then
		input.Text = "" -- a new customer: start a fresh bid
	end
	current = state
	local selling = state.Mode == "Buyer"
	local color = Items.Rarities[state.Rarity].Color:ToHex()
	title.Text = `<font color="#{color}">{state.ItemName}</font>`
	subtitle.Text = `{state.Rarity} • {state.Condition} • {if selling then "buyer" else "seller"}: {state.Customer}`
	mood.Text = moodFace(state.Mood)
	message.Text = `<b>{state.Customer}:</b> "{state.Message or ""}"`
	cash.Text = `You have {Items.FormatMoney(state.Cash)}`
	local extra = {}
	if selling then
		asking.Text = `Offering: <b>{Items.FormatMoney(state.Price)}</b>`
		acceptButton.Text = `Sell {Items.FormatMoney(state.Price)}`
		offerButton.Text = "Ask"
		walkButton.Text = "Refuse"
		input.PlaceholderText = "$ your price"
		table.insert(extra, `You paid {Items.FormatMoney(state.Paid or 0)}`)
	else
		asking.Text = `Asking: <b>{Items.FormatMoney(state.Price)}</b>`
		acceptButton.Text = `Accept {Items.FormatMoney(state.Price)}`
		offerButton.Text = "Offer"
		walkButton.Text = "Walk away"
		input.PlaceholderText = "$ your offer"
	end
	if state.DebugValue then
		table.insert(extra, `(Studio only) true value: {Items.FormatMoney(state.DebugValue)}`)
	end
	debugLabel.Text = table.concat(extra, "   •   ")
	if input.Text == "" or not parseOffer() then
		-- Start with a cheeky bid: 60% of their price when buying, 160% when selling
		local start = if selling then state.Price * 1.6 else state.Price * 0.6
		input.Text = tostring(math.max(1, math.floor(start)))
	end
	gui.Enabled = true
end

haggleRemote.OnClientEvent:Connect(function(state)
	if state.Open then
		show(state)
	else
		current = nil
		if gui.Enabled and state.Message then
			message.Text = `"{state.Message}"`
			task.delay(1.5, function()
				if not current then
					gui.Enabled = false
					input.Text = ""
				end
			end)
		else
			gui.Enabled = false
			input.Text = ""
		end
	end
end)

offerButton.Activated:Connect(function()
	local amount = parseOffer()
	if current and amount and amount >= 1 then
		haggleRemote:FireServer("Offer", amount)
	end
end)
input.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local amount = parseOffer()
		if current and amount and amount >= 1 then
			haggleRemote:FireServer("Offer", amount)
		end
	end
end)
acceptButton.Activated:Connect(function()
	if current then
		haggleRemote:FireServer("Accept")
	end
end)
walkButton.Activated:Connect(function()
	if current then
		haggleRemote:FireServer("WalkAway")
	end
end)
closeButton.Activated:Connect(function()
	gui.Enabled = false
	current = nil
	haggleRemote:FireServer("Close")
end)
