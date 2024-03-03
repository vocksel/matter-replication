local Root = script:FindFirstAncestor("Example")

local RunService = game:GetService("RunService")

local Matter = require(Root.Parent.Packages.Matter)

local systems = {
	require(Root.systems.replication),
	require(Root.systems.updateEntityIdAttributes),
}

local world = Matter.World.new()
local loop = Matter.Loop.new(world)

loop:scheduleSystems(systems)

loop:begin({
	default = RunService.Heartbeat,
})
