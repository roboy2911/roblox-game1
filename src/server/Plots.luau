-- Builds the shop plots, gives each joining player a free one,
-- and frees it again when they leave.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ShopBuilder = require(script.Parent.ShopBuilder)
local TownBuilder = require(script.Parent.TownBuilder)

local Plots = {}

local plots = {} -- list of shop models
local plotOf = {} -- plotOf[player] = shop model

-- Each shop gets its own accent color (awnings, sign text, rug, counter panels...)
local ACCENTS = {
	Color3.fromRGB(140, 80, 220), -- purple
	Color3.fromRGB(30, 185, 175), -- teal
	Color3.fromRGB(255, 110, 100), -- coral
	Color3.fromRGB(60, 110, 230), -- royal blue
	Color3.fromRGB(40, 175, 100), -- emerald
	Color3.fromRGB(235, 85, 165), -- pink
}

-- Plots sit on both sides of a street that runs north-south through the middle.
-- Returns the CFrame of each plot and the z position of each row.
local function layout()
	local origins, rowZs = {}, {}
	local perSide = math.ceil(Config.PlotCount / 2)
	local startZ = -(perSide - 1) * Config.PlotSpacing / 2
	for row = 0, perSide - 1 do
		table.insert(rowZs, startZ + row * Config.PlotSpacing)
	end
	for i = 1, Config.PlotCount do
		local side = if i % 2 == 1 then -1 else 1 -- left, right, left, right...
		local z = rowZs[math.ceil(i / 2)]
		local position = Vector3.new(side * Config.StreetToShop, 0, z)
		-- Face the street (the door points toward x = 0)
		table.insert(origins, CFrame.lookAt(position, position - Vector3.new(side, 0, 0)))
	end
	return origins, rowZs
end

local function setSign(shop, text)
	shop.Sign.SurfaceGui.OwnerText.Text = text
end

local function sendHome(player, character)
	local shop = plotOf[player]
	if not shop then
		return
	end
	character:WaitForChild("HumanoidRootPart")
	task.wait() -- let Roblox finish its own spawning first
	character:PivotTo(shop.Markers.OwnerSpawn.CFrame)
end

local function assign(player)
	for _, shop in plots do
		if shop:GetAttribute("OwnerUserId") == nil then
			shop:SetAttribute("OwnerUserId", player.UserId)
			plotOf[player] = shop
			setSign(shop, `{player.DisplayName}'s Pawn Shop`)

			player.CharacterAdded:Connect(function(character)
				sendHome(player, character)
			end)
			if player.Character then
				task.spawn(sendHome, player, player.Character)
			end
			return
		end
	end
	warn(`[Plots] No free shop for {player.Name}. Set Max Players to {Config.PlotCount} in Game Settings.`)
end

local function release(player)
	local shop = plotOf[player]
	if not shop then
		return
	end
	plotOf[player] = nil
	shop:SetAttribute("OwnerUserId", nil)
	setSign(shop, "For Sale")
end

-- Public functions ---------------------------------------------------------

-- Returns the player's shop model, or nil.
function Plots.GetShop(player)
	return plotOf[player]
end

function Plots.Start()
	local folder = Instance.new("Folder")
	folder.Name = "Plots"

	local origins, rowZs = layout()
	TownBuilder.Build(folder, rowZs)
	for i, origin in origins do
		local accent = ACCENTS[(i - 1) % #ACCENTS + 1]
		local shop = ShopBuilder.Build(origin, `Plot{i}`, accent)
		shop.Parent = folder
		table.insert(plots, shop)
	end
	folder.Parent = workspace

	Players.PlayerAdded:Connect(assign)
	for _, player in Players:GetPlayers() do
		assign(player)
	end
	Players.PlayerRemoving:Connect(release)
end

return Plots
