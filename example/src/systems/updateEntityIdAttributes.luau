local Root = script:FindFirstAncestor("Example")

local MatterReplication = require(Root.Parent.Packages.MatterReplication)
local Model = require(Root.components.Model)

local ServerEntity = MatterReplication.ServerEntity

local function updateEntityIdAttributes(world)
	for _, model, serverEntity in world:query(Model, ServerEntity) do
		if not model.instance:GetAttribute("ServerEntityId") then
			print(`assigning attribute ServerEntityId={serverEntity.id} to {model.instance}`)
			model.instance:SetAttribute("ServerEntityId", serverEntity.id)
		end
	end
end

return updateEntityIdAttributes
