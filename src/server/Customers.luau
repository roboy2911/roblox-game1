-- Sellers walk into each owned shop, put an item on the counter and ask a price (step 4),
-- and the owner haggles with them (step 5). One seller at a time per shop. They wait
-- (patience), then leave, and the next one comes.
--
-- Haggling: each seller has a secret lowest price (Floor) and a mood. Offers above the floor
-- get a counter-offer (or a yes); lowballs and going backwards hurt their mood; at 0 they leave.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Items = require(ReplicatedStorage.Shared.Items)
local ItemModels = require(script.Parent.ItemModels)

local Customers = {}

local rng = Random.new()
local PlayerData -- set in Start

-- One RemoteEvent for the haggle panel: the server sends the deal's state to the owner,
-- the owner's screen sends back "Offer" (with an amount), "Accept", "WalkAway" or "Close".
local haggleRemote = require(script.Parent.Remotes).Event("Haggle")

local LINES = {
	Counter = { "How about {ask}?", "I could do {ask}.", "Meet me at {ask}?", "{ask}, and that's a good price!" },
	Lowball = { "Too low! I'll go {ask}.", "Come on... {ask}.", "No way. {ask}?" },
	Insult = { "Are you kidding me?!", "That's an insult!", "Ha! Nice try." },
	Backwards = { "You offered more than that before!", "Hey, you're going backwards!" },
	Deal = { "Deal!", "You got it!", "Pleasure doing business!", "Sold!" },
	Angry = { "Forget it, I'm out!", "I'm taking this somewhere else!", "Unbelievable. Bye!" },
	WalkAway = { "Fine, I'll go somewhere else!", "Your loss!", "Okay... bye then." },
	Broke = { "You can't afford that!", "Come back when you have the cash." },
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

-- Walks toward `target`; gives up after a while and hops there, so a customer never gets stuck.
-- On the way in (`arriving`), it stops as soon as the customer is told to leave.
local function walkTo(state, target: Vector3, arriving: boolean?)
	local humanoid, root = state.Humanoid, state.Root
	local deadline = os.clock() + 12
	local lastOrder = 0
	while state.Npc.Parent and not (arriving and state.Leaving) do
		local offset = (target - root.Position) * Vector3.new(1, 0, 1)
		if offset.Magnitude < 1.5 then
			return
		end
		if os.clock() > deadline then
			state.Npc:PivotTo(CFrame.new(target + Vector3.new(0, 3, 0)) * root.CFrame.Rotation)
			return
		end
		if os.clock() - lastOrder > 3 then
			humanoid:MoveTo(target)
			lastOrder = os.clock()
		end
		task.wait(0.2)
	end
end

local function say(state, message: string)
	state.Text.Text = message
	state.LastLine = message
end

local function line(kind: string, ask: number?): string
	local text = pick(LINES[kind])
	return (text:gsub("{ask}", if ask then Items.FormatMoney(ask) else ""))
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
	haggleRemote:FireClient(player, {
		Open = true,
		Seller = state.Name,
		ItemName = item.Name,
		Rarity = item.Rarity,
		Condition = item.Condition,
		Ask = state.Ask,
		LastOffer = state.LastOffer,
		Mood = state.Mood,
		Message = state.LastLine,
		Cash = PlayerData.GetCash(player),
		-- Only while testing in Studio: the secret value, so you can tell a good deal
		DebugValue = if RunService:IsStudio() then item.TrueValue else nil,
	})
end

-- Gets the customer out of the shop and removes them.
local function leave(state, message: string)
	if state.Leaving then
		return
	end
	state.Leaving = true
	if not state.Npc then
		return -- still being created; visit() cleans up
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
	walkTo(state, markers.Door.Position)
	walkTo(state, markers.Street.Position)
	walkTo(state, state.ExitPosition)
	state.Npc:Destroy()
	active[state.Shop] = nil
	nextArrival[state.Shop] = os.clock() + rng:NextNumber(Config.CustomerDelay.Min, Config.CustomerDelay.Max)
end

local function visit(shop)
	local markers = shop.Markers
	local side = if rng:NextNumber() < 0.5 then -1 else 1
	local street = markers.Street.CFrame
	local spawnCf = street * CFrame.new(side * 20, 3, 0)

	local rolled = Items.Roll(rng)
	local ask = math.max(1, math.round(rolled.TrueValue * rng:NextNumber(Config.AskMultiplier.Min, Config.AskMultiplier.Max)))
	local name = pick(FIRST_NAMES)

	local state = {
		Shop = shop,
		Item = rolled, -- includes the secret TrueValue (server only)
		AskingPrice = ask, -- first price they asked
		Ask = ask, -- current price (goes down while haggling)
		Floor = math.max(1, math.round(ask * rng:NextNumber(Config.SellerFloor.Min, Config.SellerFloor.Max))),
		Mood = rng:NextInteger(Config.SellerMood.Min, Config.SellerMood.Max),
		LastOffer = nil,
		Haggler = nil, -- the owner, once they open the haggle panel
		Name = name,
		Patience = Config.CustomerPatience,
		ExitPosition = (street * CFrame.new(-side * 30, 0, 0)).Position,
	}
	active[shop] = state

	local npc = makeNpc(name, spawnCf)
	if not npc or state.Leaving then
		if npc then
			npc:Destroy()
		end
		active[shop] = nil
		nextArrival[shop] = os.clock() + 10
		return
	end
	state.Npc = npc
	state.Humanoid = npc:FindFirstChildOfClass("Humanoid")
	state.Root = npc:FindFirstChild("HumanoidRootPart")
	state.Text, state.BarBack, state.Bar = makeBubble(npc)

	-- Owner opens the haggle panel
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Haggle"
	prompt.ObjectText = name
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
	walkTo(state, markers.Street.Position, true)
	walkTo(state, markers.Door.Position, true)
	walkTo(state, markers.CustomerSpot.Position, true)
	if state.Leaving or not npc.Parent then
		return
	end

	-- Face the owner behind the counter and put the item down
	local counterTop = shop.Counter.Top
	npc:PivotTo(CFrame.lookAt(state.Root.Position, Vector3.new(counterTop.Position.X, state.Root.Position.Y, counterTop.Position.Z)))
	local itemCf = counterTop.CFrame * CFrame.new(-2.5, counterTop.Size.Y / 2, -0.6) * CFrame.Angles(0, math.pi, 0)
	local model = ItemModels.Build(rolled.Id, itemCf)
	if state.Leaving then
		model:Destroy() -- sent away while the item was loading
		return
	end
	model.Name = "CustomerItem"
	model.Parent = shop
	state.ItemModel = model

	local color = Items.Rarities[rolled.Rarity].Color:ToHex()
	say(state, `I'm selling this <font color="#{color}"><b>{rolled.Name}</b></font> ({rolled.Condition}).\nI want <b>{Items.FormatMoney(ask)}</b>!`)
	state.BarBack.Visible = true
	prompt.Enabled = true
	print(`[Customers] {name} brought {rolled.Name} ({rolled.Rarity}, {rolled.Condition}), true value {Items.FormatMoney(rolled.TrueValue)}, asking {Items.FormatMoney(ask)}`)

	-- Wait at the counter until patience runs out (or they're sent away / the owner leaves)
	local waited = 0
	while not state.Leaving and waited < state.Patience do
		task.wait(0.25)
		waited += 0.25
		local left = 1 - waited / state.Patience
		state.Bar.Size = UDim2.fromScale(left, 1)
		state.Bar.BackgroundColor3 = Color3.fromRGB(240, 70, 70):Lerp(Color3.fromRGB(90, 220, 110), left)
		if not ownerOf(shop) then
			break
		end
	end
	leave(state, "I don't have all day... bye!")
end

-- Haggling -------------------------------------------------------------------

-- Buys the item at `price`: takes the cash, saves the item, and the seller leaves happy.
local function deal(state, player, price: number)
	if not PlayerData.AddCash(player, -price) then
		say(state, line("Broke"))
		sendPanel(state, true)
		return
	end
	local item = state.Item
	PlayerData.AddItem(player, {
		Id = item.Id,
		Name = item.Name,
		Rarity = item.Rarity,
		Condition = item.Condition,
		TrueValue = item.TrueValue,
		Paid = price,
	})
	print(`[Customers] {player.Name} bought {item.Name} for {Items.FormatMoney(price)} (true value {Items.FormatMoney(item.TrueValue)})`)
	leave(state, `{line("Deal")} {Items.FormatMoney(price)} it is.`)
end

local function offer(state, player, amount: number)
	if amount >= state.Ask then
		deal(state, player, state.Ask)
		return
	end
	local loss = Config.MoodLoss
	if state.LastOffer and amount < state.LastOffer then
		state.Mood -= loss.Backwards
		say(state, line("Backwards"))
	else
		state.LastOffer = amount
		state.Mood -= loss.Round
		local happy = math.clamp(state.Mood / 100, 0, 1)
		if amount >= state.Floor then
			-- Willing: sometimes they just take it, otherwise they meet you part of the way
			if rng:NextNumber() < 0.15 + 0.35 * happy then
				deal(state, player, amount)
				return
			end
			local newAsk = state.Ask - (state.Ask - amount) * (0.4 + 0.5 * happy)
			newAsk = math.max(state.Floor, math.round(newAsk))
			if newAsk - amount <= math.max(1, state.AskingPrice * 0.03) then
				deal(state, player, amount) -- close enough
				return
			end
			state.Ask = newAsk
			say(state, line("Counter", state.Ask))
		elseif amount < state.Floor * 0.5 then
			state.Mood -= loss.Insult
			say(state, line("Insult"))
		else
			state.Mood -= loss.Lowball
			local newAsk = state.Ask - (state.Ask - state.Floor) * (0.15 + 0.3 * happy)
			state.Ask = math.max(state.Floor, math.round(newAsk))
			say(state, line("Lowball", state.Ask))
		end
	end
	if state.Mood <= 0 then
		state.Mood = 0
		task.spawn(leave, state, line("Angry"))
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

	-- Find the seller this player is haggling with
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
		if amount > PlayerData.GetCash(player) then
			say(state, line("Broke"))
			sendPanel(state, true)
			return
		end
		offer(state, player, amount)
	elseif action == "Accept" then
		deal(state, player, state.Ask)
	elseif action == "WalkAway" then
		task.spawn(leave, state, line("WalkAway"))
	elseif action == "Close" then
		state.Haggler = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastAction[player] = nil
end)

-- Returns the seller currently in this shop (or nil). Used by later steps (haggling).
function Customers.Get(shop)
	return active[shop]
end

function Customers.Start(Plots, playerData)
	PlayerData = playerData
	task.spawn(function()
		while true do
			for _, shop in Plots.GetAllShops() do
				local state = active[shop]
				if state and not ownerOf(shop) then
					task.spawn(leave, state, "Huh, nobody's here.")
				elseif not state and ownerOf(shop) then
					nextArrival[shop] = nextArrival[shop] or os.clock() + 3
					if os.clock() >= nextArrival[shop] then
						nextArrival[shop] = nil
						task.spawn(visit, shop)
					end
				end
			end
			task.wait(1)
		end
	end)
end

return Customers
