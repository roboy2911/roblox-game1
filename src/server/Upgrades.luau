-- Step 9: buying upgrades (see Config.Upgrades). The effects live where they matter:
-- Appraisal in Appraisal/Customers, Shelves in Inventory, Speed and Haggling in Customers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(script.Parent.Remotes)

local Upgrades = {}

local updateRemote = Remotes.Event("UpgradesUpdate") -- server -> screen: levels and cash
local actionRemote = Remotes.Event("UpgradesAction") -- screen -> server: "Buy" (id) or "Refresh"

local PlayerData -- set in Start

local function find(id)
	for _, upgrade in Config.Upgrades do
		if upgrade.Id == id then
			return upgrade
		end
	end
	return nil
end

-- Index into Costs for the next purchase (Appraisal starts at level 1, others at 0).
local function nextIndex(player, upgrade): number
	local level = PlayerData.GetUpgrade(player, upgrade.Id)
	return if upgrade.Id == "Appraisal" then level else level + 1
end

local function sendUpdate(player)
	if not player.Parent or not PlayerData.IsLoaded(player) then
		return
	end
	local levels = {}
	for _, upgrade in Config.Upgrades do
		levels[upgrade.Id] = PlayerData.GetUpgrade(player, upgrade.Id)
	end
	updateRemote:FireClient(player, { Levels = levels, Cash = PlayerData.GetCash(player) })
end

local function buy(player, id)
	local upgrade = find(id)
	if not upgrade then
		return
	end
	local index = nextIndex(player, upgrade)
	local cost = upgrade.Costs[index]
	if not cost then
		return -- maxed out
	end
	if not PlayerData.AddCash(player, -cost) then
		return -- can't afford
	end
	local level = PlayerData.GetUpgrade(player, id) + 1
	PlayerData.SetUpgrade(player, id, level)
	print(`[Upgrades] {player.Name} bought {upgrade.Name} level {level} for ${cost}`)
	sendUpdate(player)
end

function Upgrades.Start(playerData)
	PlayerData = playerData
	actionRemote.OnServerEvent:Connect(function(player, action, id)
		if action == "Buy" and type(id) == "string" then
			buy(player, id)
		elseif action == "Refresh" then
			sendUpdate(player)
		end
	end)
	-- Keep the menu's cash and levels fresh when anything changes (selling, admin tools...)
	PlayerData.InventoryChanged.Event:Connect(sendUpdate)
end

return Upgrades
