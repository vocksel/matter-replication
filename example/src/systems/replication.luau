local Root = script:FindFirstAncestor("Example")

local MatterReplication = require(Root.Parent.Packages.MatterReplication)

local Model = require(Root.components.Model)

local REPLICATED_COMPONENTS = {
	Model = Model,
}

return MatterReplication.createReplicationSystem(REPLICATED_COMPONENTS)
