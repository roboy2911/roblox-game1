-- Game-wide settings shared by the server and the client.
local Config = {}

Config.GameName = "Pawn Shop Simulator"
Config.Version = "0.3.0"

-- Shop plots
Config.PlotCount = 6 -- one per player, so set Max Players to this
Config.PlotSpacing = 56 -- distance between shops along the street
Config.StreetToShop = 43 -- distance from the street's middle to each shop's center

-- Money
Config.StartingCash = 100

-- Saving
-- Changing this name starts everyone with fresh data, so only change it on purpose.
Config.DataStoreName = "PlayerData_v1"
Config.AutoSaveSeconds = 60

return Config
