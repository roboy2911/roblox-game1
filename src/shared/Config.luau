-- Game-wide settings shared by the server and the client.
local Config = {}

Config.GameName = "Pawn Shop Simulator"
Config.Version = "0.4.0"

-- Shop plots
Config.PlotCount = 6 -- one per player, so set Max Players to this
Config.PlotSpacing = 56 -- distance between shops along the street
Config.StreetToShop = 43 -- distance from the street's middle to each shop's center

-- Customers (sellers walking into your shop)
Config.CustomerDelay = { Min = 4, Max = 9 } -- seconds between one seller leaving and the next arriving
Config.CustomerPatience = 40 -- seconds a seller waits at the counter before leaving
Config.CustomerWalkSpeed = 12
-- Sellers ask between these multiples of the item's secret true value (below 1 = a bargain)
Config.AskMultiplier = { Min = 0.7, Max = 1.6 }

-- Money
Config.StartingCash = 100

-- Saving
-- Changing this name starts everyone with fresh data, so only change it on purpose.
Config.DataStoreName = "PlayerData_v1"
Config.AutoSaveSeconds = 60

return Config
