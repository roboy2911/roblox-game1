-- Game-wide settings shared by the server and the client.
local Config = {}

Config.GameName = "Pawn Shop Simulator"
Config.Version = "0.7.0"

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

-- Money
Config.StartingCash = 100

-- Saving
-- Changing this name starts everyone with fresh data, so only change it on purpose.
Config.DataStoreName = "PlayerData_v1"
Config.AutoSaveSeconds = 60

return Config
