local Root = script:FindFirstAncestor("Example")

local MatterReplication = require(Root.Packages.MatterReplication)

local Model = require(Root.components.Model)

local REPLICATED_COMPONENTS = {
	Model,
}

return MatterReplication.createReplicationSystem(REPLICATED_COMPONENTS)
