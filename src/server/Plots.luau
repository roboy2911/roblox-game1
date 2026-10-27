-- Builds the shop plots, gives each joining player a free one,
-- and frees it again when they leave.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ShopBuilder = require(script.Parent.ShopBuilder)

local Plots = {}

local plots = {} -- list of shop models
local plotOf = {} -- plotOf[player] = shop model

-- Plots sit on both sides of a street that runs north-south through the middle.
local function plotOrigins()
	local origins = {}
	local perSide = math.ceil(Config.PlotCount / 2)
	local startZ = -(perSide - 1) * Config.PlotSpacing / 2
	for i = 1, Config.PlotCount do
		local side = if i % 2 == 1 then -1 else 1 -- left, right, left, right...
		local row = math.ceil(i / 2) - 1
		local position = Vector3.new(side * Config.StreetToShop, 0, startZ + row * Config.PlotSpacing)
		-- Face the street (the door points toward x = 0)
		table.insert(origins, CFrame.lookAt(position, position - Vector3.new(side, 0, 0)))
	end
	return origins
end

local function buildStreet(folder)
	local perSide = math.ceil(Config.PlotCount / 2)
	local street = Instance.new("Part")
	street.Name = "Street"
	street.Anchored = true
	street.Size = Vector3.new(24, 0.2, perSide * Config.PlotSpacing + 40)
	street.Position = Vector3.new(0, 0.1, 0)
	street.Color = Color3.fromRGB(45, 45, 50)
	street.Material = Enum.Material.Asphalt
	street.Parent = folder
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

	buildStreet(folder)
	for i, origin in plotOrigins() do
		local shop = ShopBuilder.Build(origin, `Plot{i}`)
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
