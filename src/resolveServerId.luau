local MatterTypes = require(script.Parent.MatterTypes)
local ServerEntity = require(script.Parent.ServerEntity)

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
