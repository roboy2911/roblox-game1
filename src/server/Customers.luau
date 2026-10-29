-- Customers walking into each owned shop, one at a time:
--   Sellers (step 4/5) bring an item, put it on the counter and ask a price. You haggle down.
--   Buyers (step 7) browse your displayed items, pick one, and offer a price. You haggle up.
-- They wait (patience), then leave, and the next one comes.
--
-- Haggling: each customer has a secret limit (a seller's lowest price, a buyer's highest)
-- and a mood. Bids past the limit get a counter-offer (or a yes); bids way off, and going
-- backwards, hurt their mood; at 0 they storm off.

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local ItemModels = require(script.Parent.ItemModels)
local Appraisal = require(script.Parent.Appraisal)

local Customers = {}

local rng = Random.new()
local PlayerData, Inventory -- set in Start

-- One RemoteEvent for the haggle panel: the server sends the deal's state to the owner,
-- the owner's screen sends back "Offer" (with an amount), "Accept", "WalkAway" or "Close".
local haggleRemote = require(script.Parent.Remotes).Event("Haggle")

-- What customers say. {price} is replaced with a money amount.
local LINES = {
	Seller = {
		Counter = { "How about {price}?", "I could do {price}.", "Meet me at {price}?", "{price}, and that's a good price!" },
		Far = { "Too low! I'll go {price}.", "Come on... {price}.", "No way. {price}?" },
		Insult = { "Are you kidding me?!", "That's an insult!", "Ha! Nice try." },
		Backwards = { "You offered more than that before!", "Hey, you're going backwards!" },
		Deal = { "Deal!", "You got it!", "Pleasure doing business!", "Sold!" },
		Angry = { "Forget it, I'm out!", "I'm taking this somewhere else!", "Unbelievable. Bye!" },
		WalkAway = { "Fine, I'll go somewhere else!", "Your loss!", "Okay... bye then." },
		Broke = { "You can't afford that!", "Come back when you have the cash." },
	},
	Buyer = {
		Counter = { "I can do {price}.", "How about {price}?", "{price}, final offer... maybe.", "Let's say {price}?" },
		Far = { "Way too much! {price}?", "Pfft. I'll pay {price}.", "Too pricey. {price}?" },
		Insult = { "Are you serious?!", "For THAT? No way!", "Ha! In your dreams." },
		Backwards = { "You asked for less than that before!", "Hey, your price went up!" },
		Deal = { "Deal!", "It's mine!", "Sold! Thanks!", "Great, I'll take it!" },
		Angry = { "Forget it, I'm out!", "I'll shop somewhere else!", "Unbelievable. Bye!" },
		WalkAway = { "Oh... okay then.", "Your loss!", "Fine, keep it!" },
		Gone = { "Hey, where did it go?", "Huh? It's gone..." },
	},
}

local FIRST_NAMES = {
	"Bob", "Linda", "Gary", "Maya", "Rex", "Tina", "Otis", "Priya", "Sal", "Greta",
	"Dex", "Nina", "Hank", "Lola", "Milo", "Rosa", "Earl", "Zoe", "Vince", "Ivy",
}
local SKIN = {
	Color3.fromRGB(255, 220, 185), Color3.fromRGB(234, 190, 150), Color3.fromRGB(198, 145, 105),
	Color3.fromRGB(160, 110, 75), Color3.fromRGB(110, 75, 50),
}
local SHIRTS = {
	Color3.fromRGB(220, 60, 60), Color3.fromRGB(60, 120, 230), Color3.fromRGB(60, 180, 100),
	Color3.fromRGB(250, 200, 60), Color3.fromRGB(150, 80, 210), Color3.fromRGB(240, 130, 50),
	Color3.fromRGB(240, 240, 240), Color3.fromRGB(50, 50, 60),
}
local PANTS = {
	Color3.fromRGB(40, 60, 110), Color3.fromRGB(45, 45, 55), Color3.fromRGB(120, 90, 60),
	Color3.fromRGB(90, 90, 100), Color3.fromRGB(60, 80, 50),
}
-- Roblox's default R15 animations
local WALK_ANIMATION = "rbxassetid://507777826"
local IDLE_ANIMATION = "rbxassetid://507766388"

local active = {} -- [shop] = state of the seller currently visiting
local nextArrival = {} -- [shop] = time (os.clock) when the next seller may come

local function pick(list)
	return list[rng:NextInteger(1, #list)]
end

local function ownerOf(shop)
	local userId = shop:GetAttribute("OwnerUserId")
	return userId and Players:GetPlayerByUserId(userId)
end

-- A simple R15 character with random skin and clothes colors, walk/idle animations and a name tag.
local function makeNpc(name: string, cf: CFrame): Model?
	local description = Instance.new("HumanoidDescription")
	local skin = pick(SKIN)
	description.HeadColor = skin
	description.LeftArmColor = skin
	description.RightArmColor = skin
	description.TorsoColor = pick(SHIRTS)
	local pants = pick(PANTS)
	description.LeftLegColor = pants
	description.RightLegColor = pants

	local ok, npc = pcall(function()
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if not ok then
		warn(`[Customers] Couldn't make a customer: {npc}`)
		return nil
	end
	npc.Name = name
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	humanoid.WalkSpeed = Config.CustomerWalkSpeed
	humanoid.DisplayName = name
	humanoid.NameDisplayDistance = 0 -- we show our own speech bubble instead
	npc:PivotTo(cf)
	npc.Parent = workspace

	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then
		root:SetNetworkOwner(nil) -- the server moves customers, not a player's device
	end

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local function load(id)
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		return animator:LoadAnimation(animation)
	end
	local walk, idle = load(WALK_ANIMATION), load(IDLE_ANIMATION)
	idle.Looped = true
	walk.Looped = true
	idle:Play()
	humanoid.Running:Connect(function(speed)
		if speed > 0.5 then
			if not walk.IsPlaying then
				walk:Play(0.15)
				idle:Stop(0.15)
			end
		elseif not idle.IsPlaying then
			idle:Play(0.15)
			walk:Stop(0.15)
		end
	end)
	return npc
end

-- Speech bubble over the head, with a patience bar under it.
local function makeBubble(npc: Model)
	local head = npc:FindFirstChild("Head")
	local gui = Instance.new("BillboardGui")
	gui.Name = "Bubble"
	gui.Size = UDim2.fromOffset(250, 96)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.MaxDistance = 70
	gui.Parent = head

	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 74)
	box.BackgroundColor3 = Color3.new(1, 1, 1)
	box.Parent = gui
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
	local stroke = Instance.new("UIStroke", box)
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(45, 45, 60)

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.new(1, -16, 1, -8)
	text.Position = UDim2.fromOffset(8, 4)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.RichText = true
	text.TextColor3 = Color3.fromRGB(45, 45, 60)
	text.Text = ""
	text.Parent = box

	local barBack = Instance.new("Frame")
	barBack.Name = "Patience"
	barBack.Size = UDim2.new(0.7, 0, 0, 10)
	barBack.Position = UDim2.new(0.15, 0, 0, 82)
	barBack.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	barBack.Visible = false
	barBack.Parent = gui
	Instance.new("UICorner", barBack).CornerRadius = UDim.new(1, 0)
	local bar = Instance.new("Frame")
	bar.Name = "Fill"
	bar.Size = UDim2.fromScale(1, 1)
	bar.BackgroundColor3 = Color3.fromRGB(90, 220, 110)
	bar.Parent = barBack
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	return text, barBack, bar
end

-- Walks straight toward `target` until close (or `deadline`). Returns true if it got there.
local function walkStraight(state, target: Vector3, deadline: number, arriving: boolean?): boolean
	local humanoid, root = state.Humanoid, state.Root
	local lastOrder = 0
	while state.Npc.Parent and not (arriving and state.Leaving) do
		if ((target - root.Position) * Vector3.new(1, 0, 1)).Magnitude < 1.5 then
			return true
		end
		if os.clock() > deadline then
			return false
		end
		if os.clock() - lastOrder > 2 then
			humanoid:MoveTo(target)
			lastOrder = os.clock()
		end
		task.wait(0.1)
	end
	return false
end

-- Walks to `target`, finding a way around counters, cases, doors and walls (Roblox pathfinding).
-- If no path is found it walks straight, and if it's still stuck it hops there, so a customer
-- never gets stuck for good. On the way in (`arriving`), it stops as soon as they're told to leave.
local function walkTo(state, target: Vector3, arriving: boolean?)
	local root = state.Root
	local deadline = os.clock() + 15
	local path = PathfindingService:CreatePath({ AgentRadius = 1.6, AgentHeight = 5, AgentCanJump = false })
	local ok = pcall(function()
		path:ComputeAsync(root.Position, target)
	end)
	if ok and path.Status == Enum.PathStatus.Success then
		for _, waypoint in path:GetWaypoints() do
			if not state.Npc.Parent or (arriving and state.Leaving) then
				return
			end
			if not walkStraight(state, waypoint.Position, math.min(deadline, os.clock() + 4), arriving) then
				break -- blocked (a player in the way?); finish below
			end
		end
	end
	if state.Npc.Parent and not (arriving and state.Leaving) then
		if not walkStraight(state, target, deadline, arriving) and state.Npc.Parent then
			state.Npc:PivotTo(CFrame.new(target + Vector3.new(0, 3, 0)) * root.CFrame.Rotation)
		end
	end
end

local function say(state, message: string)
	state.Text.Text = message
	state.LastLine = message
end

local function line(state, kind: string, price: number?): string
	local text = pick(LINES[state.Kind][kind])
	return (text:gsub("{price}", if price then Items.FormatMoney(price) else ""))
end

local function rarityText(item)
	local color = Items.Rarities[item.Rarity].Color:ToHex()
	return `<font color="#{color}"><b>{item.Name}</b></font>`
end

-- Sends the deal's current state to the owner's haggle panel (or closes it).
local function sendPanel(state, open: boolean)
	local player = state.Haggler
	if not player or not player.Parent then
		return
	end
	if not open then
		haggleRemote:FireClient(player, { Open = false, Message = state.LastLine })
		return
	end
	local item = state.Item
	-- Your guess of its value (made once per customer; items you own keep theirs)
	state.Estimate = state.Estimate or item.Estimate or Appraisal.Estimate(item, PlayerData.GetAppraisal(player))
	haggleRemote:FireClient(player, {
		Open = true,
		Mode = state.Kind, -- "Seller" (you buy) or "Buyer" (you sell)
		Customer = state.Name,
		ItemName = item.Name,
		Rarity = item.Rarity,
		Condition = item.Condition,
		Price = state.Price,
		Paid = item.Paid, -- what you paid, when selling
		Estimate = state.Estimate,
		AppraisalLevel = PlayerData.GetAppraisal(player),
		Mood = state.Mood,
		Message = state.LastLine,
		Cash = PlayerData.GetCash(player),
		-- Admins only (testing): the secret value, so you can tell a good deal
		DebugValue = if table.find(Config.AdminUserIds, player.UserId) then item.TrueValue else nil,
	})
end

-- Gets the customer out of the shop and removes them.
local function leave(state, message: string)
	if state.Leaving then
		return
	end
	state.Leaving = true
	if not state.Npc then
		return -- still being created; the visit cleans up
	end
	state.LastLine = message
	sendPanel(state, false)
	state.Prompt:Destroy()
	state.BarBack.Visible = false
	if state.ItemModel then
		state.ItemModel:Destroy()
	end
	say(state, message)
	local markers = state.Shop.Markers
	for _, point in state.ExitPath or {} do
		walkTo(state, point) -- out of the aisle by the shelves/cases, then to just inside the door
	end
	walkTo(state, markers.Door.Position)
	walkTo(state, markers.Street.Position)
	walkTo(state, state.ExitPosition)
	state.Npc:Destroy()
	active[state.Shop] = nil
	-- Faster customers upgrade shortens the wait for the next one
	local owner = ownerOf(state.Shop)
	local speed = if owner then PlayerData.GetUpgrade(owner, "Speed") else 0
	local scale = Config.CustomerDelayScale[math.min(speed + 1, #Config.CustomerDelayScale)]
	nextArrival[state.Shop] = os.clock() + rng:NextNumber(Config.CustomerDelay.Min, Config.CustomerDelay.Max) * scale
end

-- Makes the customer's character on the sidewalk, with a bubble and a Haggle prompt.
-- Returns false if it didn't work (or they were told to leave meanwhile).
local function spawnCustomer(state): boolean
	local shop = state.Shop
	local street = shop.Markers.Street.CFrame
	local side = if rng:NextNumber() < 0.5 then -1 else 1
	state.ExitPosition = (street * CFrame.new(-side * 30, 0, 0)).Position
	active[shop] = state

	local npc = makeNpc(state.Name, street * CFrame.new(side * 20, 3, 0))
	if not npc or state.Leaving then
		if npc then
			npc:Destroy()
		end
		active[shop] = nil
		nextArrival[shop] = os.clock() + 10
		return false
	end
	state.Npc = npc
	state.Humanoid = npc:FindFirstChildOfClass("Humanoid")
	state.Root = npc:FindFirstChild("HumanoidRootPart")
	state.Text, state.BarBack, state.Bar = makeBubble(npc)

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Haggle"
	prompt.ObjectText = state.Name
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false
	prompt.Parent = state.Root
	state.Prompt = prompt
	prompt.Triggered:Connect(function(player)
		if ownerOf(shop) == player and not state.Leaving then
			state.Haggler = player
			sendPanel(state, true)
		end
	end)
	say(state, "...")
	return true
end

-- Turns to face the counter.
local function faceCounter(state)
	local top = state.Shop.Counter.Top
	local here = state.Root.Position
	state.Npc:PivotTo(CFrame.lookAt(here, Vector3.new(top.Position.X, here.Y, top.Position.Z)))
end

-- Waits at the counter until patience runs out (or they're sent away / the owner leaves).
local function waitAtCounter(state)
	state.BarBack.Visible = true
	state.Prompt.Enabled = true
	local waited = 0
	while not state.Leaving and waited < state.Patience do
		task.wait(0.25)
		waited += 0.25
		local left = 1 - waited / state.Patience
		state.Bar.Size = UDim2.fromScale(left, 1)
		state.Bar.BackgroundColor3 = Color3.fromRGB(240, 70, 70):Lerp(Color3.fromRGB(90, 220, 110), left)
		if not ownerOf(state.Shop) then
			break
		end
	end
	leave(state, "I don't have all day... bye!")
end

-- Silver tongue upgrade level of the shop's owner.
local function hagglingLevel(shop): number
	local owner = ownerOf(shop)
	return if owner then PlayerData.GetUpgrade(owner, "Haggling") else 0
end

local function newState(shop, kind: string)
	return {
		Kind = kind,
		Shop = shop,
		Name = pick(FIRST_NAMES),
		Mood = rng:NextInteger(Config.SellerMood.Min, Config.SellerMood.Max),
		Patience = Config.CustomerPatience,
		LastBid = nil, -- your last offer (buying) or asking price (selling)
		Haggler = nil, -- the owner, once they open the haggle panel
	}
end

-- Sellers --------------------------------------------------------------------------

local function visitSeller(shop)
	local rolled = Items.Roll(rng)
	-- Sellers price by how it looks (a fake's seller asks a lot; a treasure's seller doesn't know)
	local looks = rolled.ApparentValue or rolled.TrueValue
	local ask = math.max(1, math.round(looks * rng:NextNumber(Config.AskMultiplier.Min, Config.AskMultiplier.Max)))
	local state = newState(shop, "Seller")
	state.Item = rolled -- includes the secret TrueValue (server only)
	state.FirstPrice = ask
	state.Price = ask -- their current asking price (goes down while haggling)
	local floor = rng:NextNumber(Config.SellerFloor.Min, Config.SellerFloor.Max) - Config.HagglingBonus * hagglingLevel(shop)
	state.Limit = math.max(1, math.round(ask * math.max(0.3, floor)))
	if not spawnCustomer(state) then
		return
	end

	local markers = shop.Markers
	walkTo(state, markers.Street.Position, true)
	walkTo(state, markers.Door.Position, true)
	walkTo(state, markers.CustomerSpot.Position, true)
	if state.Leaving or not state.Npc.Parent then
		return
	end

	-- Put the item down on the counter
	faceCounter(state)
	local top = shop.Counter.Top
	local itemCf = top.CFrame * CFrame.new(-2.5, top.Size.Y / 2, -0.6) * CFrame.Angles(0, math.pi, 0)
	local model = ItemModels.Build(rolled.Id, itemCf)
	if state.Leaving then
		model:Destroy() -- sent away while the item was loading
		return
	end
	model.Name = "CustomerItem"
	model.Parent = shop
	state.ItemModel = model

	say(state, `I'm selling this {rarityText(rolled)} ({rolled.Condition}).\nI want <b>{Items.FormatMoney(ask)}</b>!`)
	local special = if rolled.Fake then " FAKE" elseif rolled.Treasure then " TREASURE" else ""
	print(`[Customers] {state.Name} brought {rolled.Name} ({rolled.Rarity}, {rolled.Condition}){special}, true value {Items.FormatMoney(rolled.TrueValue)}, asking {Items.FormatMoney(ask)}`)
	waitAtCounter(state)
end

-- Buyers ---------------------------------------------------------------------------

-- A point inside the shop, from shop coordinates (x right, z toward the back).
local function shopPoint(shop, x: number, z: number): Vector3
	return (shop.PrimaryPart.CFrame * CFrame.new(x, 1, z)).Position
end

-- Displayed items of the shop's owner: list of { Item, Model }.
local function displayedItems(owner)
	local list = {}
	for _, item in PlayerData.GetInventory(owner) do
		local model = item.Slot and Inventory.GetShownModel(owner, item.Uid)
		if model then
			table.insert(list, { Item = item, Model = model })
		end
	end
	return list
end

-- Walks from the door to stand in front of a displayed item, going around the glass cases.
local function walkToItem(state, model: Model)
	local shop = state.Shop
	local floor = shop.PrimaryPart.CFrame
	local look = model:GetPivot()
	local localStand = floor:PointToObjectSpace(look.Position + look.LookVector * 2.5)
	local s = if localStand.X >= 0 then 1 else -1
	-- Glass cases sit at x = +-10 (z -10 .. -2); the aisle toward the wall shelves is at x = +-13
	local onShelf = math.abs(localStand.X) > 12
	local laneX = if onShelf then s * 13 else localStand.X
	local inside = shopPoint(shop, 0, -11) -- inside, past the open glass doors
	local lane = shopPoint(shop, laneX, -12)
	state.ExitPath = { lane, inside }
	walkTo(state, inside, true)
	walkTo(state, lane, true)
	walkTo(state, shopPoint(shop, localStand.X, localStand.Z), true)
	if state.Leaving then
		return
	end
	state.Npc:PivotTo(CFrame.lookAt(state.Root.Position, Vector3.new(look.Position.X, state.Root.Position.Y, look.Position.Z)))
	-- On the way to the counter, step out of the gap first so they don't walk through a case
	state.BackToCounter = if onShelf then shopPoint(shop, s * 13, 0.5) else nil
end

local function visitBuyer(shop, owner)
	local choices = displayedItems(owner)
	if #choices == 0 then
		return
	end
	local choice = choices[rng:NextInteger(1, #choices)]
	local item = choice.Item
	local offer = math.max(1, math.round(item.TrueValue * rng:NextNumber(Config.BuyerOffer.Min, Config.BuyerOffer.Max)))
	local state = newState(shop, "Buyer")
	state.Item = item
	state.Owner = owner
	state.FirstPrice = offer
	state.Price = offer -- their current offer (goes up while haggling)
	local ceiling = rng:NextNumber(Config.BuyerCeiling.Min, Config.BuyerCeiling.Max) + Config.HagglingBonus * hagglingLevel(shop)
	state.Limit = math.max(offer, math.round(item.TrueValue * ceiling))
	if not spawnCustomer(state) then
		return
	end

	local markers = shop.Markers
	walkTo(state, markers.Street.Position, true)
	walkTo(state, markers.Door.Position, true)
	if state.Leaving then
		return
	end
	-- Browse: look at the item for a moment
	walkToItem(state, choice.Model)
	if state.Leaving then
		return
	end
	say(state, "Ooh, nice...")
	task.wait(Config.BrowseSeconds)
	if state.BackToCounter then
		walkTo(state, state.BackToCounter, true)
	end
	walkTo(state, markers.CustomerSpot.Position, true)
	state.ExitPath = nil -- back in the middle of the shop: straight out works
	if state.Leaving or not state.Npc.Parent then
		return
	end
	if not PlayerData.FindItem(owner, item.Uid) or not item.Slot then
		leave(state, line(state, "Gone"))
		return
	end
	faceCounter(state)
	say(state, `I'd like to buy your {rarityText(item)} ({item.Condition}).\nI'll give you <b>{Items.FormatMoney(offer)}</b>!`)
	print(`[Customers] {state.Name} wants {item.Name} (true value {Items.FormatMoney(item.TrueValue)}, paid {Items.FormatMoney(item.Paid or 0)}), offering {Items.FormatMoney(offer)}`)
	waitAtCounter(state)
end

-- Haggling -------------------------------------------------------------------------

-- Gives the buyer the item: welds a copy into their hands so they carry it out.
local function carryOut(state)
	local model = ItemModels.Build(state.Item.Id, CFrame.identity)
	model.WorldPivot = CFrame.identity
	local box, size = model:GetBoundingBox()
	model.WorldPivot = CFrame.new(box.Position)
	local biggest = math.max(size.X, size.Y, size.Z)
	if biggest > 1.8 then
		model:ScaleTo(model:GetScale() * 1.8 / biggest)
	end
	if not state.Npc.Parent then
		model:Destroy()
		return
	end
	model:PivotTo(state.Root.CFrame * CFrame.new(0, 0.2, -1.3))
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = state.Root
			weld.Part1 = part
			weld.Parent = part
		end
	end
	model.Parent = state.Npc
end

-- Closes the deal at `price`.
local function deal(state, player, price: number)
	local item = state.Item
	if state.Kind == "Seller" then
		if not PlayerData.AddCash(player, -price) then
			say(state, line(state, "Broke"))
			sendPanel(state, true)
			return
		end
		PlayerData.AddItem(player, {
			Id = item.Id,
			Name = item.Name,
			Rarity = item.Rarity,
			Condition = item.Condition,
			TrueValue = item.TrueValue,
			ApparentValue = item.ApparentValue,
			Fake = item.Fake,
			Treasure = item.Treasure,
			Estimate = state.Estimate or Appraisal.Estimate(item, PlayerData.GetAppraisal(player)),
			Paid = price,
		})
		print(`[Customers] {player.Name} bought {item.Name} for {Items.FormatMoney(price)} (true value {Items.FormatMoney(item.TrueValue)})`)
		leave(state, `{line(state, "Deal")} {Items.FormatMoney(price)} it is.`)
	else
		if not Inventory.RemoveItem(player, item.Uid) then
			leave(state, line(state, "Gone"))
			return
		end
		PlayerData.AddCash(player, price)
		local profit = price - (item.Paid or 0)
		print(`[Customers] {player.Name} sold {item.Name} for {Items.FormatMoney(price)} (paid {Items.FormatMoney(item.Paid or 0)}, profit {profit})`)
		task.spawn(carryOut, state)
		leave(state, `{line(state, "Deal")} {Items.FormatMoney(price)} it is.`)
	end
end

-- The owner bids `amount`: an offer to a seller, or an asking price to a buyer.
-- "toward" is the direction the customer moves: down for sellers, up for buyers.
local function bid(state, player, amount: number)
	local selling = state.Kind == "Buyer"
	-- Already acceptable? (seller asking <= your offer, or buyer offering >= your price)
	if (not selling and amount >= state.Price) or (selling and amount <= state.Price) then
		deal(state, player, state.Price)
		return
	end
	-- Mood losses, softened by the owner's Silver tongue upgrade
	local save = math.max(0, 1 - Config.HagglingMoodSave * hagglingLevel(state.Shop))
	local loss = {}
	for kind, amount in Config.MoodLoss do
		loss[kind] = amount * save
	end
	-- "past the limit" = within what the customer would accept
	local withinLimit = if selling then amount <= state.Limit else amount >= state.Limit
	local wayOff = if selling then amount > state.Limit * 2 else amount < state.Limit * 0.5
	local backwards = state.LastBid and (if selling then amount > state.LastBid else amount < state.LastBid)

	if backwards then
		state.Mood -= loss.Backwards
		say(state, line(state, "Backwards"))
	else
		state.LastBid = amount
		state.Mood -= loss.Round
		local happy = math.clamp(state.Mood / 100, 0, 1)
		if withinLimit then
			-- Willing: sometimes they just take it, otherwise they meet you part of the way
			if rng:NextNumber() < 0.15 + 0.35 * happy then
				deal(state, player, amount)
				return
			end
			local newPrice = math.round(state.Price + (amount - state.Price) * (0.4 + 0.5 * happy))
			newPrice = if selling then math.min(state.Limit, newPrice) else math.max(state.Limit, newPrice)
			if math.abs(amount - newPrice) <= math.max(1, state.FirstPrice * 0.03) then
				deal(state, player, amount) -- close enough
				return
			end
			state.Price = newPrice
			say(state, line(state, "Counter", state.Price))
		elseif wayOff then
			state.Mood -= loss.Insult
			say(state, line(state, "Insult"))
		else
			state.Mood -= loss.Lowball
			local newPrice = math.round(state.Price + (state.Limit - state.Price) * (0.15 + 0.3 * happy))
			state.Price = newPrice
			say(state, line(state, "Far", state.Price))
		end
	end
	if state.Mood <= 0 then
		state.Mood = 0
		task.spawn(leave, state, line(state, "Angry"))
		return
	end
	sendPanel(state, true)
end

local lastAction = {} -- [player] = time, to ignore button spam

haggleRemote.OnServerEvent:Connect(function(player, action, amount)
	if os.clock() - (lastAction[player] or 0) < 0.25 then
		return
	end
	lastAction[player] = os.clock()

	-- Find the customer this player is haggling with
	local state = nil
	for _, s in active do
		if s.Haggler == player and not s.Leaving and s.Npc then
			state = s
		end
	end
	if not state or ownerOf(state.Shop) ~= player then
		return
	end

	if action == "Offer" then
		if type(amount) ~= "number" or amount ~= amount or amount < 1 or amount > 1e9 then
			return
		end
		amount = math.floor(amount)
		if state.Kind == "Seller" and amount > PlayerData.GetCash(player) then
			say(state, line(state, "Broke"))
			sendPanel(state, true)
			return
		end
		bid(state, player, amount)
	elseif action == "Accept" then
		deal(state, player, state.Price)
	elseif action == "WalkAway" then
		task.spawn(leave, state, line(state, "WalkAway"))
	elseif action == "Close" then
		state.Haggler = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastAction[player] = nil
end)

-- Public -----------------------------------------------------------------------------

-- Returns the customer currently in this shop (or nil).
function Customers.Get(shop)
	return active[shop]
end

function Customers.Start(Plots, playerData, inventory)
	PlayerData = playerData
	Inventory = inventory
	task.spawn(function()
		while true do
			for _, shop in Plots.GetAllShops() do
				local state = active[shop]
				local owner = ownerOf(shop)
				if state and not owner then
					task.spawn(leave, state, "Huh, nobody's here.")
				elseif not state and owner then
					nextArrival[shop] = nextArrival[shop] or os.clock() + 3
					if os.clock() >= nextArrival[shop] then
						nextArrival[shop] = nil
						-- A buyer if there's something on display (sometimes), otherwise a seller
						if rng:NextNumber() < Config.BuyerChance and #displayedItems(owner) > 0 then
							task.spawn(visitBuyer, shop, owner)
						else
							task.spawn(visitSeller, shop)
						end
					end
				end
			end
			task.wait(1)
		end
	end)
end

return Customers
