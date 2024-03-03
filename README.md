# MatterReplication

[![CI](https://github.com/vocksel/matter-replication/actions/workflows/ci.yml/badge.svg)](https://github.com/vocksel/matter-replication/actions/workflows/ci.yml)

This package exposes the building blocks necessary to create replicated entities in [Matter](https://eryn.io/matter/).

## What it does

1. Allows you to specify the components you want to replicate to all clients when changes occur on the server
2. Attaches a `ServerEntity` component to all replicated entities so the client can query for server-owned entities

## Installation

### Wally (Recommended)

MatterReplication can be installed with Wally by including it as a dependency in your `wally.toml` file.

```toml
[dependencies]
MatterReplication = "vocksel/matter-replication@x.x.x"
```

### Roblox Studio

Download a copy of the rbxm from the [latest release](https://github.com/vocksel/matter-replication/releases/latest) under the Assets section, then drag and drop the file into Roblox Studio to add it to your experience.

## Usage

This section walks through how the [example project](example/) uses MatterReplication to spawn server-owned parts that clients can interact with.

First the `createReplicationSystem` function is used to create the Matter system that handles replication from the server to clients.

```lua
-- example/src/systems/replication.luau
local Root = script:FindFirstAncestor("Example")

local MatterReplication = require(Root.Packages.MatterReplication)

local Model = require(Root.components.Model)

local REPLICATED_COMPONENTS = {
	Model,
}

return MatterReplication.createReplicationSystem(REPLICATED_COMPONENTS)
```

Next the server and client need to use the system for replication to work. The script is the same on both the server and client in this example. The differences in handling happens at the system-level. Here's the full script contents:

```lua
local Root = script:FindFirstAncestor("Example")

local RunService = game:GetService("RunService")

local Matter = require(Root.Packages.Matter)

local systems = {
	require(Root.systems.replication),
	require(Root.systems.parts),
}

local world = Matter.World.new()
local loop = Matter.Loop.new(world)

loop:scheduleSystems(systems)

loop:begin({
	default = RunService.Heartbeat,
})
```

Finally we have the `parts` system, which handles...
1. Spawning parts and listening for interactions on the server, and
2. Sending interactions to the server from the client

This is a large example, but has been annotated to make it easier to understand.

```lua
local Root = script:FindFirstAncestor("Example")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Matter = require(Root.Packages.Matter)
local MatterReplication = require(Root.Packages.MatterReplication)
local Model = require(Root.components.Model)

local ServerEntity = MatterReplication.ServerEntity
local partInteracted = Root.partInteracted

local isServer = RunService:IsServer()

local function newRandomColor(): Color3
	local rng = Random.new()
	return Color3.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

local function parts(world)
	if isServer then
		-- Spawn a new part every 5 seconds
		if Matter.useThrottle(5) then
			local part = Instance.new("Part")
			part.Size = Vector3.new(4, 4, 4)
			part.Position = Vector3.new(0, 15, 0)
			part.Color = newRandomColor()
			part.Shape = Enum.PartType.Ball
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.Parent = workspace

			-- Defer so the server has time to replicate the Part in the first place
			task.defer(function()
				world:spawn(Model({
					instance = part,
				}))
			end)
		end

		-- This handles the server reaction when a client touches one of the
		-- Parts. In this case, the color is changed to show the interaction
		for _, player, id in Matter.useEvent(partInteracted, "OnServerEvent") do
			print(`{player} touched entity {id}`)

			if world:contains(id) then
				local model = world:get(id, Model)

				if model then
					model.instance.Color = newRandomColor()
				end
			end
		end
	else
		local character = Players.LocalPlayer.Character

		if character then
			for id, model in world:query(Model, ServerEntity) do
				-- The entity ID on the client can (and likely will) be
				-- different than what's on the server. As such, resolveServerId
				-- will take a client-side ID and map it to the ID the server
				-- uses. Since the server doesn't know what the client's entity
				-- IDs are, this is needed to tell the server _what_ part was
				-- interacted with
				local serverId = MatterReplication.resolveServerId(world, id)

				-- For illustrative purposes the client is the one listening for
				-- Touched events. It would be easier to do this on the server,
				-- but this is an easy way to show off user interaction causing
				-- server reaction
				for _, other: Part in Matter.useEvent(model.instance, "Touched") do
					if other:IsDescendantOf(Players.LocalPlayer.Character) then
						partInteracted:FireServer(serverId)
					end
				end
			end
		end
	end
end

return parts
```

With that, we have a complete setup for replicating server-owned entities to clients, and allowing clients to instruct the server when to make changes to those entities.

You can of course extend this example to make it possible for the client to first change the color of the part, and then instruct the server what color to make it. This can make the interaction snappier, as the client doesn't need to wait for their own interaction to be replicated from the server back to them. But that is outside the scope of this example.

Check out the source for this in the [example](example) folder which can be helpful for seeing how all the files are structured.

## API

**`ServerEntity: Component`**

This is a Matter component that gets automatically assigned to any entity that gets replicated.

The following example is a client-side system that uses the `ServerEntity` component to apply a `ServerEntityId` Attribute to the common `Model` component paradigm.

```lua
local ServerEntity = MatterReplication.ServerEntity

local function updateEntityIdAttributes(world)
	for _, model, serverEntity in world:query(Model, ServerEntity) do
		if not model.instance:GetAttribute("ServerEntityId") then
			print(`assigning attribute ServerEntityId={serverEntity.id} to {model.instance}`)
			model.instance:SetAttribute("ServerEntityId", serverEntity.id)
		end
	end
end
```

**`createReplicationSystem(replicatedComponents: { Component })`**

Creates the replication system for use in your Matter loop.

The system must be included in both the server and client loops for replication to work.

```lua
local MatterReplication = require(ReplicatedStorage.Packages.MatterReplication)

local Foo = require(ReplicatedStorage.Components.Foo)
local Bar = require(ReplicatedStorage.Components.Bar)
local Baz = require(ReplicatedStorage.Components.Baz)

return MatterReplication.createReplicationSystem({
	-- The components you want to replicate go here
	Foo,
	Bar,
	Baz
})
```

**`resolveServerId(world: World, serverId: number): number?`**

Get the client ID associated with a `ServerEntity`.

The entity IDs sent to the client from the server are typically server IDs. As such, this function can be used to resolve a server ID to the client ID for an entity.

For a non-replicated component there will not be a client ID to work with, so in those cases this function returns `nil`.
