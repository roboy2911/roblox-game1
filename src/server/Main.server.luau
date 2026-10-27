-- Server entry point. Runs once when the server starts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local Plots = require(script.Parent.Plots)
local LightingSetup = require(script.Parent.LightingSetup)

LightingSetup.Start()
Plots.Start()
PlayerData.Start()

-- Testing helpers (cash pad, item spawner), only when playing in Studio.
if RunService:IsStudio() then
	require(script.Parent.DebugTools).Start(PlayerData, Plots)
end

print(`{Config.GameName} v{Config.Version} – Pawn Shop loaded!`)
