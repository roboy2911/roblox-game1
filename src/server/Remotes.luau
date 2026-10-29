-- One place that creates the RemoteEvents players' screens use to talk to the server.
-- They live in ReplicatedStorage.Remotes; clients wait for them by name.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local Remotes = {}

-- Returns the RemoteEvent with this name, creating it the first time.
function Remotes.Event(name: string): RemoteEvent
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

return Remotes
