local Matter = require(script.Parent.Parent.Matter)

export type Data = {
	id: number,
}

return Matter.component(script.Name, {} :: Data)
