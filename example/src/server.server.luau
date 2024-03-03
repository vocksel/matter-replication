local Root = script:FindFirstAncestor("Example")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Matter = require(Root.Parent.Packages.Matter)
local Model = require(Root.components.Model)

local systems = {
	require(Root.systems.replication),
	require(Root.systems.partSpawner),
}

local world = Matter.World.new()
local loop = Matter.Loop.new(world)

loop:scheduleSystems(systems)

loop:begin({
	default = RunService.Heartbeat,
})

Players.PlayerAdded:Connect(function(player)
	world:spawn(Model({
		instance = player,
	}))
end)
