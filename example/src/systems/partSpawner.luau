local Root = script:FindFirstAncestor("Example")

local Matter = require(Root.Parent.Packages.Matter)
local Model = require(Root.components.Model)

local function newRandomColor(): Color3
	local rng = Random.new()
	return Color3.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

local function partSpawner(world)
	if Matter.useThrottle(5) then
		local part = Instance.new("Part")
		part.Size = Vector3.new(4, 4, 4)
		part.Position = Vector3.new(0, 15, 0)
		part.Color = newRandomColor()
		part.Shape = Enum.PartType.Ball
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = workspace

		task.defer(function()
			world:spawn(Model({
				instance = part,
			}))
		end)
	end
end

return partSpawner
