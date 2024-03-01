# MatterReplication

This package exposes the components and system building blocks necessary to create replicated entities in [Matter](https://eryn.io/matter/).

## What it does

1. Allows you to specify the components you want to replicate to all clients when changes occur on the server
2. Attaches a `ServerEntity` component to all entities that get replicated to make it easy to query on the client for any server-owned entities

## API

**`ServerEntity`**

This is a Matter component that gets automatically assigned to any entity that gets replicated.

The following example is a client-side system that uses the `ServerEntity` component to apply a `ServerEntityId` Attribute to the common `Model` component paradigm.

```lua
local MatterReplication = require(Path.To.MatterReplication)
local Model = require(Path.To.Components.Model)

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

```lua
-- src/systems/replication.lua
local MatterReplication = require(Path.To.MatterReplication)

local REPLICATED_COMPONENTS = {
	Path.To.Components.Foo,
	Path.To.Components.Bar,
	Path.To.Components.Baz,
}

local replicatedComponents = {}
for _, component in REPLICATED_COMPONENTS do
	replicatedComponents[component.name] = require(component)
end

return MatterReplication.createReplicationSystem(replicatedComponents)
```
