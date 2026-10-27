-- Server entry point. Runs once when the server starts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

print(`{Config.GameName} v{Config.Version} – Pawn Shop loaded!`)
