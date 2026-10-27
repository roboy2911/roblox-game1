-- Server entry point. Runs once when the server starts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local Plots = require(script.Parent.Plots)

Plots.Start()
PlayerData.Start()

-- Testing helper, only in Studio: a green pad that gives $50.
if RunService:IsStudio() then
	local pad = Instance.new("Part")
	pad.Name = "DebugCashPad"
	pad.Size = Vector3.new(4, 1, 4)
	pad.Position = Vector3.new(0, 0.5, -12)
	pad.Anchored = true
	pad.BrickColor = BrickColor.new("Lime green")
	pad.Material = Enum.Material.Neon

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Get $50"
	prompt.ObjectText = "Debug"
	prompt.HoldDuration = 0
	prompt.Parent = pad

	prompt.Triggered:Connect(function(player)
		PlayerData.AddCash(player, 50)
	end)

	pad.Parent = workspace
end

print(`{Config.GameName} v{Config.Version} – Pawn Shop loaded!`)
