-- Server entry point. Runs once when the server starts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local Plots = require(script.Parent.Plots)
local LightingSetup = require(script.Parent.LightingSetup)
local MeshLoader = require(script.Parent.MeshLoader)
local Customers = require(script.Parent.Customers)
local Inventory = require(script.Parent.Inventory)

LightingSetup.Start()
MeshLoader.Preload()
Plots.Start()
PlayerData.Start()
Customers.Start(Plots, PlayerData, Inventory)
Inventory.Start(PlayerData, Plots)

-- Admin menu (testing tools) for the IDs in Config.AdminUserIds
require(script.Parent.Admin).Start(PlayerData, Plots)

print(`{Config.GameName} v{Config.Version} – Pawn Shop loaded!`)
