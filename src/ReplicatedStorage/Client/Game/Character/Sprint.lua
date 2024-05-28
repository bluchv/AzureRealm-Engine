local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Promise = require(Packages.Promise)

local IsSprinting = false
local Sprint = {}

function Sprint:Toggle(toggled: boolean, humanoid: Humanoid?)
	return Promise.new(function(resolve)
		local targetSpeed = if toggled then 32 else 16
		if toggled == IsSprinting or toggled and humanoid and humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return resolve(false)
		end

		IsSprinting = toggled
		if humanoid then
			humanoid.WalkSpeed = targetSpeed
		end
		return resolve(toggled)
	end)
end

function Sprint:IsSprinting()
	return IsSprinting
end

return Sprint
