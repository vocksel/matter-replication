local Root = script:FindFirstAncestor("MatterReplication")

local Matter = require(Root.Parent.Matter)

export type Data = {
	id: number,
}

return Matter.component(script.Name, {} :: Data)
