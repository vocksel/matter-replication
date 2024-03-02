# MatterReplication

[![CI](https://github.com/vocksel/matter-replication/actions/workflows/ci.yml/badge.svg)](https://github.com/vocksel/matter-replication/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-website-brightgreen)](https://vocksel.github.io/matter-replication)

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

```lua
local MatterReplication = require(ReplicatedStorage.Packages.MatterReplication)

local Foo = require(ReplicatedStorage.Components.Foo)
local Bar = require(ReplicatedStorage.Components.Bar)
local Baz = require(ReplicatedStorage.Components.Baz)

return MatterReplication.createReplicationSystem({
	Foo,
	Bar,
	Baz
})
```

## API

**`ServerEntity`**

This is a Matter component that gets automatically assigned to any entity that gets replicated.

The following example is a client-side system that uses the `ServerEntity` component to apply a `ServerEntityId` Attribute to the common `Model` component paradigm.

```lua
local MatterReplication = require(ReplicatedStorage.Packages.MatterReplication)
local Model = require(ReplicatedStorage.Components.Model)

local ServerEntity = MatterReplication.ServerEntity

local function updateEntityIdAttributes(world)
	for id, model, serverEntity in world:query(Model, ServerEntity) do
		if not model.instance:GetAttribute("ServerEntityId") then
			model.instance:SetAttribute("ServerEntityId", serverEntity.id)
		end
	end
end

return updateEntityIdAttributes
```

**`createReplicationSystem(replicatedComponents: { [string]: Component })`**

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

```lua
local MatterReplication = require(ReplicatedStorage.Packages.MatterReplication)

-- TODO
```
