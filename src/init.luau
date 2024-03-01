local ServerEntity = require(script.ServerEntity)

export type ServerEntityData = ServerEntity.Data

return {
	ServerEntity = ServerEntity,
	createReplicationSystem = require(script.createReplicationSystem),
	resolveServerId = require(script.resolveServerId),
}
