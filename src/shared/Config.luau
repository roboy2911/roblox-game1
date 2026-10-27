-- Game-wide settings shared by the server and the client.
local Config = {}

Config.GameName = "Pawn Shop Simulator"
Config.Version = "0.1.0"

-- Money
Config.StartingCash = 100

-- Saving
-- Changing this name starts everyone with fresh data, so only change it on purpose.
Config.DataStoreName = "PlayerData_v1"
Config.AutoSaveSeconds = 60

return Config
