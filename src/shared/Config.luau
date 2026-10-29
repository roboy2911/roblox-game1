-- Game-wide settings shared by the server and the client.
local Config = {}

Config.GameName = "Pawn Shop Simulator"
Config.Version = "0.5.0"

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

-- Haggling (buying from sellers)
-- Each seller secretly won't go below this fraction of their first asking price
Config.SellerFloor = { Min = 0.55, Max = 0.85 }
Config.SellerMood = { Min = 55, Max = 90 } -- starting mood (0-100); at 0 they storm off
Config.MoodLoss = {
	Round = 6, -- every offer, a little
	Lowball = 14, -- offer below their secret lowest price
	Insult = 30, -- offer below half their secret lowest price
	Backwards = 20, -- offering less than you already offered
}

-- Money
Config.StartingCash = 100

-- Saving
-- Changing this name starts everyone with fresh data, so only change it on purpose.
Config.DataStoreName = "PlayerData_v1"
Config.AutoSaveSeconds = 60

return Config
