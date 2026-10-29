-- Client entry point. Runs on each player's device when they join.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

print(`Welcome to {Config.GameName}, {Players.LocalPlayer.Name}!`)

-- Download the detailed item meshes early, so items don't pop in late the first time they spawn.
local ContentProvider = game:GetService("ContentProvider")
task.spawn(function()
	local folder = ReplicatedStorage:WaitForChild("MeshTemplates")
	folder.ChildAdded:Connect(function(model)
		ContentProvider:PreloadAsync({ model })
	end)
	ContentProvider:PreloadAsync(folder:GetChildren())
end)
