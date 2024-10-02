--!strict
--!native
-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
-- Types
export type ActorModule = () -> (actor: Actor) -> ()

return function(actorScript: ModuleScript): Actor
	local actor = Instance.new("Actor")
	local bootScript: BaseScript
	if RunService:IsServer() then
		actor.Parent = game:GetService("ServerScriptService")

		bootScript = script:WaitForChild("Server"):Clone() :: Script
	else
		local player = assert(Players.LocalPlayer)
		if player then
			actor.Parent = player:WaitForChild("PlayerScripts")
		else
			assert(RunService:IsStudio())
			actor.Parent = game:GetService("CoreGui")
		end

		bootScript = script:WaitForChild("Client"):Clone() :: LocalScript
	end

	bootScript.Enabled = true
	bootScript.Parent = actor

	local initialize = actor:WaitForChild("Initialize", 30) :: BindableFunction
	assert(initialize, `initialization took too long`)

	assert(initialize:Invoke(actorScript), `initialization of actor failed for {actorScript:GetFullName()}`)

	return actor
end
