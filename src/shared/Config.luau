-- Game-wide settings shared by the server and the client.
local Config = {}

Config.GameName = "Pawn Shop Simulator"
Config.Version = "0.11.0"

-- Shop plots
Config.PlotCount = 6 -- one per player, so set Max Players to this
Config.PlotSpacing = 56 -- distance between shops along the street
Config.StreetToShop = 43 -- distance from the street's middle to each shop's center

-- Customers (sellers walking into your shop)
Config.CustomerDelay = { Min = 4, Max = 9 } -- seconds between one seller leaving and the next arriving
Config.CustomerPatience = 60 -- seconds a seller waits at the counter before leaving
Config.CustomerWalkSpeed = 12
-- Sellers ask between these multiples of the item's secret true value (below 1 = a bargain)
Config.AskMultiplier = { Min = 0.7, Max = 1.6 }

-- Buyers (people who come to buy what you have on display)
Config.BuyerChance = 0.5 -- chance the next customer is a buyer, when something is on display
Config.BuyerOffer = { Min = 0.6, Max = 1.0 } -- first offer, as a multiple of the item's true value
Config.BuyerCeiling = { Min = 1.1, Max = 1.7 } -- the most they'll secretly pay, same way
Config.BrowseSeconds = 3 -- how long they look at an item before going to the counter

-- Appraisal: guessing what an item is really worth
-- How wide your estimate is at each appraisal level (0.6 = the range spans about +-60% of the value)
Config.AppraisalWidth = { 0.6, 0.4, 0.25, 0.15, 0.08, 0.04, 0.015 }
-- Chance to spot a fake / hidden treasure at each level
Config.AppraisalSpot = { 0.15, 0.3, 0.45, 0.6, 0.72, 0.85, 0.95 }
Config.FakeChance = 0.12 -- chance a Rare, Epic or Legendary item is a fake
Config.FakeValue = { Min = 0.05, Max = 0.15 } -- a fake is worth this much of what it looks like
Config.TreasureChance = 0.05 -- chance a Junk or Common item is a hidden treasure
Config.TreasureValue = { Min = 8, Max = 20 } -- a treasure is worth this many times what it looks like

-- Haggling (buying from sellers, and selling to buyers)
-- Each seller secretly won't go below this fraction of their first asking price
Config.SellerFloor = { Min = 0.55, Max = 0.85 }
Config.SellerMood = { Min = 55, Max = 90 } -- starting mood of sellers and buyers (0-100); at 0 they storm off
Config.MoodLoss = {
	Round = 6, -- every offer, a little
	Lowball = 14, -- offer past their secret limit (below a seller's lowest / above a buyer's highest)
	Insult = 30, -- way past it (below half a seller's lowest / over double a buyer's highest)
	Backwards = 20, -- going back on your last bid (offering less, or asking more)
}

-- Admins: Roblox user IDs that get the 🛠 Admin menu (testing tools). Anyone else never sees it.
Config.AdminUserIds = { 394075114 } -- roboy2911

-- Upgrades (bought in the ⬆ Upgrades menu). Costs[n] = price of level n.
-- Appraisal's levels are the appraisal level itself (you start at 1, so its first cost is for level 2).
Config.Upgrades = {
	{
		Id = "Appraisal",
		Name = "Appraisal",
		Description = "Tighter value estimates, and you spot more fakes and treasures.",
		Costs = { 150, 400, 1000, 2500, 6000, 15000 },
	},
	{
		Id = "Shelves",
		Name = "More shelves",
		Description = "+5 display spots for items.",
		Costs = { 200, 600, 1500, 4000 },
	},
	{
		Id = "Speed",
		Name = "Faster customers",
		Description = "Customers come in sooner.",
		Costs = { 150, 500, 1500, 4000 },
	},
	{
		Id = "Haggling",
		Name = "Silver tongue",
		Description = "Sellers go lower, buyers pay more, and moods drop slower.",
		Costs = { 300, 900, 2500, 6000, 15000 },
	},
	{
		Id = "BiggerShop",
		Name = "Bigger shop",
		Description = "Opens the roped-off back area behind the checkout: 18 more display spots, and buyers browse there too.",
		Costs = { 10000 },
	},
}
Config.DisplaySpots = { 10, 15, 20, 25, 30 } -- by More shelves level (0, 1, 2...)
Config.CustomerDelayScale = { 1, 0.8, 0.6, 0.45, 0.3 } -- by Faster customers level
Config.HagglingBonus = 0.05 -- per Silver tongue level: sellers' lowest -5%, buyers' highest +5%
Config.HagglingMoodSave = 0.1 -- per Silver tongue level: mood drops 10% less

-- Money
Config.StartingCash = 100

-- Saving
-- Changing this name starts everyone with fresh data, so only change it on purpose.
Config.DataStoreName = "PlayerData_v1"
Config.AutoSaveSeconds = 60

return Config
