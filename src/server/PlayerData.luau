-- Loads, holds and saves each player's data (cash, and more in later steps).
-- Other server scripts change data through this module, e.g. PlayerData.AddCash(player, 50).

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local PlayerData = {}

-- New players start with this. When we add new fields later, old saves get them automatically.
local function defaultData()
	return {
		Cash = Config.StartingCash,
		-- Items bought from sellers: { Id, Name, Rarity, Condition, TrueValue, Paid }
		Inventory = {},
	}
end

local store = nil
local storeOk, storeErr = pcall(function()
	store = DataStoreService:GetDataStore(Config.DataStoreName)
end)
if not storeOk then
	warn(`[PlayerData] Saving is off: {storeErr}`)
end

-- profiles[player] = { data = {...}, canSave = bool }
local profiles = {}

local function keyFor(player)
	return `player_{player.UserId}`
end

-- Runs fn up to 3 times, waiting a bit between tries. Returns ok, result.
local function withRetries(label, fn)
	for attempt = 1, 3 do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		warn(`[PlayerData] {label} failed (try {attempt}/3): {result}`)
		if attempt < 3 then
			task.wait(attempt * 2)
		end
	end
	return false, nil
end

local function makeLeaderstats(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = data.Cash
	cash.Parent = leaderstats

	leaderstats.Parent = player
end

local function load(player)
	local data = defaultData()
	local canSave = false

	if store then
		local ok, saved = withRetries(`Load {player.Name}`, function()
			return store:GetAsync(keyFor(player))
		end)
		if ok then
			canSave = true
			if type(saved) == "table" then
				for field, value in saved do
					data[field] = value
				end
			end
		else
			-- Don't save over their real data with a fresh copy.
			warn(`[PlayerData] Couldn't load {player.Name}. They can play, but progress won't save this session.`)
		end
	end

	if not player.Parent then
		return -- left while loading
	end

	profiles[player] = { data = data, canSave = canSave }
	makeLeaderstats(player, data)
end

local function save(player)
	local profile = profiles[player]
	if not profile or not profile.canSave then
		return
	end
	withRetries(`Save {player.Name}`, function()
		store:UpdateAsync(keyFor(player), function()
			return profile.data
		end)
	end)
end

-- Public functions ---------------------------------------------------------

function PlayerData.GetCash(player): number
	local profile = profiles[player]
	return if profile then profile.data.Cash else 0
end

-- Adds (or with a negative number, removes) cash. Returns false if they can't afford it.
function PlayerData.AddCash(player, amount: number): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	local newCash = profile.data.Cash + amount
	if newCash < 0 then
		return false
	end
	profile.data.Cash = newCash
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Cash.Value = newCash
	end
	return true
end

-- Adds an item the player bought to their inventory (saved).
function PlayerData.AddItem(player, item): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	table.insert(profile.data.Inventory, item)
	return true
end

-- The player's inventory list (don't change it directly; use the functions above).
function PlayerData.GetInventory(player)
	local profile = profiles[player]
	return if profile then profile.data.Inventory else {}
end

function PlayerData.Start()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		save(player)
		profiles[player] = nil
	end)

	-- Autosave in case the server crashes.
	task.spawn(function()
		while true do
			task.wait(Config.AutoSaveSeconds)
			for player in profiles do
				task.spawn(save, player)
			end
		end
	end)

	-- When the server shuts down, save everyone before it closes.
	game:BindToClose(function()
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				save(player)
				pending -= 1
			end)
		end
		while pending > 0 do
			task.wait()
		end
	end)
end

return PlayerData
