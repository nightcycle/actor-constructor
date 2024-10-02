--!nocheck
--!native
local actor = script:GetActor()

type ActorModule = () -> () -> ()

local cleanUp: (() -> ())?

local initialize = Instance.new("BindableFunction")
initialize.Name = "Initialize"
initialize.OnInvoke = function(moduleScript: ModuleScript): boolean
	local success, msg = pcall(function()
		local module = require(moduleScript)
		assert(
			type(module) == "function",
			`actor module must return function, currently returns {typeof(module)}`
		)

		cleanUp = module(actor)
		assert(
			type(cleanUp) == "function",
			`actor module function, must return a clean-up function, currently returns {typeof(cleanUp)}`
		)
	end)
	if not success then
		task.spawn(function()
			error(msg)
		end)
	end
	return success
end
initialize.Parent = actor

local destroyConnection: RBXScriptConnection
destroyConnection = actor.Destroying:Connect(function()
	task.synchronize()
	initialize:Destroy()
	destroyConnection:Disconnect()
	if cleanUp then
		cleanUp()
	end
end)
