local Root = script:FindFirstAncestor("Example")

local Matter = require(Root.Parent.Packages.Matter)

return Matter.component(script.Name)
