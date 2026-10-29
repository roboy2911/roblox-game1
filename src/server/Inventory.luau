-- Step 6: the player's inventory (items bought from sellers) and putting them on display.
-- Each shop has spots on its glass display cases and wall shelves. Displayed items are
-- saved (item.Slot) and put back when the player rejoins.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemModels = require(script.Parent.ItemModels)
local Remotes = require(script.Parent.Remotes)

local Inventory = {}

local updateRemote = Remotes.Event("InventoryUpdate") -- server -> screen: the item list
local actionRemote = Remotes.Event("InventoryAction") -- screen -> server: "Display", "TakeBack", "DisplayAll", "Refresh"

local PlayerData, Plots -- set in Start
local shown = {} -- shown[player][uid] = Model on display

-- Shop spots ---------------------------------------------------------------------

-- How big an item may be in each kind of spot (width, height, depth, in studs).
local CASE_FIT = Vector3.new(2.4, 2.2, 2.4)
local SHELF_FIT = Vector3.new(3.2, 2.1, 2.4)

local spotsCache = {} -- [shop] = list of spots

-- Spots spread along the long side of a flat surface part, facing into the room.
local function addSpots(list, shop, part: BasePart, prefix: string, count: number, spacing: number, fit: Vector3)
	local top = part.CFrame * CFrame.new(0, part.Size.Y / 2, 0)
	local toCenter = shop.PrimaryPart.Position - part.Position
	local side = part.CFrame.XVector
	local front = if toCenter:Dot(side) >= 0 then side else -side
	for i = 1, count do
		local position = (top * CFrame.new(0, 0, (i - (count + 1) / 2) * spacing)).Position
		table.insert(list, { Id = `{prefix}-{i}`, CFrame = CFrame.lookAt(position, position + front), Fit = fit })
	end
end

-- Every display spot in a shop, in the order they fill up (glass cases first).
local function spotsFor(shop)
	if spotsCache[shop] then
		return spotsCache[shop]
	end
	local list = {}
	for _, case in shop.DisplayCases:GetChildren() do
		addSpots(list, shop, case.DisplaySurface, case.Name, 3, 2.6, CASE_FIT)
	end
	for _, shelf in shop.Shelves:GetChildren() do
		for level = 1, 3 do
			addSpots(list, shop, shelf[`Level{level}`], `{shelf.Name}-L{level}`, 4, 3.5, SHELF_FIT)
		end
	end
	table.sort(list, function(a, b)
		return a.Id < b.Id -- "Case..." before "Shelf...", stable order
	end)
	spotsCache[shop] = list
	return list
end

local function spotById(shop, id)
	for _, spot in spotsFor(shop) do
		if spot.Id == id then
			return spot
		end
	end
	return nil
end

local function usedSpots(player)
	local used = {}
	for _, item in PlayerData.GetInventory(player) do
		if item.Slot then
			used[item.Slot] = true
		end
	end
	return used
end

local function freeSpot(player, shop)
	local used = usedSpots(player)
	for _, spot in spotsFor(shop) do
		if not used[spot.Id] then
			return spot
		end
	end
	return nil
end

-- Showing items ------------------------------------------------------------------

-- Builds the item's model, shrinks it to fit the spot if needed, and stands it there.
local function placeModel(player, shop, item, spot)
	local model = ItemModels.Build(item.Id, CFrame.identity) -- may wait while a mesh downloads
	if item.Slot ~= spot.Id or not player.Parent then
		model:Destroy() -- taken back (or left) while it was loading
		return
	end
	model.WorldPivot = CFrame.identity
	local box, size = model:GetBoundingBox()
	model.WorldPivot = CFrame.new(box.Position - Vector3.new(0, size.Y / 2, 0)) -- bottom center
	local fit = spot.Fit
	local scale = math.min(1, fit.X / size.X, fit.Y / size.Y, fit.Z / size.Z)
	if scale < 1 then
		model:ScaleTo(model:GetScale() * scale)
	end
	model:PivotTo(spot.CFrame)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end
	model.Name = item.Name
	model:SetAttribute("Uid", item.Uid)
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("Spot", spot.Id)

	local folder = shop:FindFirstChild("DisplayedItems")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "DisplayedItems"
		folder.Parent = shop
	end
	model.Parent = folder
	shown[player] = shown[player] or {}
	shown[player][item.Uid] = model
end

local function removeModel(player, uid)
	local models = shown[player]
	if models and models[uid] then
		models[uid]:Destroy()
		models[uid] = nil
	end
end

-- Sends the item list to the player's screen.
local function sendUpdate(player)
	if not player.Parent or not PlayerData.IsLoaded(player) then
		return
	end
	local list = {}
	for _, item in PlayerData.GetInventory(player) do
		table.insert(list, {
			Uid = item.Uid,
			Id = item.Id,
			Name = item.Name,
			Rarity = item.Rarity,
			Condition = item.Condition,
			Paid = item.Paid,
			Displayed = item.Slot ~= nil,
		})
	end
	local shop = Plots.GetShop(player)
	local total = if shop then #spotsFor(shop) else 0
	local used = 0
	for _ in usedSpots(player) do
		used += 1
	end
	updateRemote:FireClient(player, { Items = list, SpotsUsed = used, SpotsTotal = total })
end

local function display(player, uid)
	local shop = Plots.GetShop(player)
	local item = PlayerData.FindItem(player, uid)
	if not shop or not item or item.Slot then
		return false
	end
	local spot = freeSpot(player, shop)
	if not spot then
		return false
	end
	PlayerData.SetItemSlot(player, uid, spot.Id)
	placeModel(player, shop, item, spot)
	return true
end

local function takeBack(player, uid)
	local item = PlayerData.FindItem(player, uid)
	if item and item.Slot then
		removeModel(player, uid)
		PlayerData.SetItemSlot(player, uid, nil)
	end
end

-- When a player joins: wait for their data and shop, then put their displayed items back.
local function restore(player)
	local deadline = os.clock() + 60
	while player.Parent and os.clock() < deadline and not (PlayerData.IsLoaded(player) and Plots.GetShop(player)) do
		task.wait(0.5)
	end
	local shop = Plots.GetShop(player)
	if not player.Parent or not shop or not PlayerData.IsLoaded(player) then
		return
	end
	local taken = {}
	for _, item in PlayerData.GetInventory(player) do
		local spot = item.Slot and spotById(shop, item.Slot)
		if spot and not taken[spot.Id] then
			taken[spot.Id] = true
			placeModel(player, shop, item, spot)
		elseif item.Slot then
			item.Slot = nil -- spot doesn't exist anymore; back in the bag
		end
	end
	sendUpdate(player)
end

-- Public ---------------------------------------------------------------------------

-- The model of a displayed item (used by step 7, when buyers pick items off the shelves).
function Inventory.GetShownModel(player, uid)
	return shown[player] and shown[player][uid]
end

function Inventory.Start(playerData, plots)
	PlayerData, Plots = playerData, plots

	PlayerData.InventoryChanged.Event:Connect(sendUpdate)

	actionRemote.OnServerEvent:Connect(function(player, action, uid)
		if action == "Refresh" then
			sendUpdate(player)
		elseif action == "DisplayAll" then
			for _, item in table.clone(PlayerData.GetInventory(player)) do
				if not item.Slot and not display(player, item.Uid) then
					break -- no more room
				end
			end
		elseif type(uid) == "string" then
			if action == "Display" then
				display(player, uid)
			elseif action == "TakeBack" then
				takeBack(player, uid)
			end
		end
	end)

	Players.PlayerAdded:Connect(restore)
	for _, player in Players:GetPlayers() do
		task.spawn(restore, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		-- Their shop is freed; clear the shelves (the spots stay saved for next time)
		for _, model in shown[player] or {} do
			model:Destroy()
		end
		shown[player] = nil
	end)
end

return Inventory
