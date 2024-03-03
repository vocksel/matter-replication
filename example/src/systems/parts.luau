local Root = script:FindFirstAncestor("Example")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Matter = require(Root.Packages.Matter)
local MatterReplication = require(Root.Packages.MatterReplication)
local Model = require(Root.components.Model)

local ServerEntity = MatterReplication.ServerEntity
local partInteracted = Root.partInteracted

local isServer = RunService:IsServer()

local function newRandomColor(): Color3
	local rng = Random.new()
	return Color3.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

local function parts(world)
	if isServer then
		-- Spawn a new part every 5 seconds
		if Matter.useThrottle(5) then
			local part = Instance.new("Part")
			part.Size = Vector3.new(4, 4, 4)
			part.Position = Vector3.new(0, 15, 0)
			part.Color = newRandomColor()
			part.Shape = Enum.PartType.Ball
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.Parent = workspace

			-- Defer so the server has time to replicate the Part in the first place
			task.defer(function()
				world:spawn(Model({
					instance = part,
				}))
			end)
		end

		-- This handles the server reaction when a client touches one of the
		-- Parts. In this case, the color is changed to show the interaction
		for _, player, id in Matter.useEvent(partInteracted, "OnServerEvent") do
			print(`{player} touched entity {id}`)

			if world:contains(id) then
				local model = world:get(id, Model)

				if model then
					model.instance.Color = newRandomColor()
				end
			end
		end
	else
		local character = Players.LocalPlayer.Character

		if character then
			for _, model, serverEntity in world:query(Model, ServerEntity) do
				-- For illustrative purposes the client is the one listening for
				-- Touched events. It would be easier to do this on the server,
				-- but this is an easy way to show off user interaction causing
				-- server reaction
				for _, other: Part in Matter.useEvent(model.instance, "Touched") do
					if other:IsDescendantOf(Players.LocalPlayer.Character) then
						partInteracted:FireServer(serverEntity.id)
					end
				end
			end
		end
	end
end

return parts
