local Root = script:FindFirstAncestor("MatterReplication")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Freeze = require(Root.Parent.Freeze)
local Matter = require(Root.Parent.Matter)
local MatterTypes = require(Root.MatterTypes)
local ServerEntity = require(Root.ServerEntity)

local componentReplicated = Root.componentReplicated

type World = MatterTypes.World
type Component = MatterTypes.Component<any>

type ComponentChanges = {
	[string]: {
		data: MatterTypes.ComponentInstance<any>,
	},
}

type EntityChanges = {
	[string]: ComponentChanges,
}

local function createReplicationSystem(replicatedComponents: { Component })
	-- This table is used by the client to map server-side entity IDs to
	-- client-side ones.
	local clientEntityIdMap: { [string]: string } = {}

	replicatedComponents = table.clone(replicatedComponents)
	table.insert(replicatedComponents, ServerEntity)

	local function assignServerOwnership(world: World)
		for _, component in replicatedComponents do
			for id in world:query(component) do
				if world:get(id, ServerEntity) then
					continue
				else
					world:insert(
						id,
						ServerEntity({
							id = id,
						})
					)
				end
			end
		end
	end

	local function sendComponentChanges(world: World)
		local entityChanges: EntityChanges = {}

		for _, component in replicatedComponents do
			for entityId, record in world:queryChanged(component) do
				local key = tostring(entityId)

				if entityChanges[key] == nil then
					entityChanges[key] = {}
				end

				if world:contains(entityId) then
					entityChanges[key][tostring(component)] = {
						data = record.new,
					}
				end
			end
		end

		if next(entityChanges) then
			componentReplicated:FireAllClients(entityChanges)
		end
	end

	local function sendChangesToNewPlayers(world: World)
		for _, player in Matter.useEvent(Players, "PlayerAdded") do
			local payload = {}

			for entityId, entityData in world do
				local entityPayload = {}

				for component, componentData in entityData do
					local componentName = tostring(component)

					if replicatedComponents[componentName] then
						entityPayload[componentName] = {
							data = componentData,
						}
					end
				end

				payload[tostring(entityId)] = entityPayload
			end

			componentReplicated:FireClient(player, payload)
		end
	end

	local function receiveComponentChanges(world: World)
		for _, payload: EntityChanges in Matter.useEvent(componentReplicated, "OnClientEvent") do
			for serverEntityId, componentMap in payload do
				local clientEntityId = clientEntityIdMap[serverEntityId]

				if clientEntityId and next(componentMap) == nil then
					world:despawn(clientEntityId)
					clientEntityIdMap[serverEntityId] = nil
					continue
				end

				local componentsToInsert: { any } = {}
				local componentsToRemove: { any } = {}

				for name, container in componentMap do
					local component = Freeze.List.find(replicatedComponents, function(other)
						return tostring(other) == name
					end)

					if container.data then
						table.insert(componentsToInsert, component(container.data))
					else
						table.insert(componentsToRemove, component)
					end
				end

				if clientEntityId == nil then
					clientEntityId = world:spawn(table.unpack(componentsToInsert))
					clientEntityIdMap[serverEntityId] = clientEntityId
				else
					if #componentsToInsert > 0 then
						world:insert(clientEntityId, table.unpack(componentsToInsert))
					end

					if #componentsToRemove > 0 then
						world:remove(clientEntityId, table.unpack(componentsToRemove))
					end
				end
			end
		end
	end

	local function replication(world: World)
		if RunService:IsServer() then
			assignServerOwnership(world)
			sendChangesToNewPlayers(world)
			sendComponentChanges(world)
		else
			receiveComponentChanges(world)
		end
	end

	return {
		system = replication,
		priority = math.huge,
	}
end

return createReplicationSystem
