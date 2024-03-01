local Root = script:FindFirstAncestor("MatterReplication")

local MatterTypes = require(Root.MatterTypes)
local ServerEntity = require(Root.ServerEntity)

type World = MatterTypes.World

local function resolveServerId(world: World, serverId: number): number?
	for clientId, serverEntity in world:query(ServerEntity) do
		if serverEntity.id == serverId then
			return clientId
		end
	end
	return nil
end

return resolveServerId
