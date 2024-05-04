local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer

local Trove = require(ReplicatedStorage.Packages.Trove).new()
local SprintMechanic = require(script.Sprint)
local Camera = require(script.Parent.Camera)

local CharacterModule = {}

function CharacterModule:CharacterAdded(character)
	local humanoid = character.Humanoid :: Humanoid

	Trove:Connect(RunService.RenderStepped, function()
		local isMoving = if humanoid.MoveDirection == Vector3.zero then false else true
		local isSprinting = SprintMechanic:IsSprinting()

		if isMoving and isSprinting then
			Camera:TweenFieldOfView(80, 0.3)
		elseif not isMoving and isSprinting then
			Camera:TweenFieldOfView(70, 0.7)
		end
		task.wait()
	end)
end

function CharacterModule:CharacterRemoved()
	Trove:Clean()
end

function CharacterModule:InputBegan(input: InputObject, gp: boolean)
	if gp then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		SprintMechanic:Toggle(true, CharacterModule:GetHumanoid()):andThen(function(isSprinting: boolean)
			if isSprinting and CharacterModule:IsMoving() then
				Camera:TweenFieldOfView(80, 0.3)
			end
		end)
	end
end

function CharacterModule:InputEnded(input: InputObject)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		SprintMechanic:Toggle(false, CharacterModule:GetHumanoid()):andThen(function(isSprinting: boolean)
			if not isSprinting then
				Camera:TweenFieldOfView(70, 1)
			end
		end)
	end
end

function CharacterModule:CharacterDied()
	SprintMechanic:Toggle(false)
end

function CharacterModule:GetCharacter(): Model?
	return Player.Character
end

function CharacterModule:GetHumanoid(): Humanoid?
	local character = CharacterModule:GetCharacter()
	if not character then
		return nil
	end
	return character:WaitForChild("Humanoid", 10)
end

function CharacterModule:IsSpawned(): boolean
	return if CharacterModule:GetCharacter() then true else false
end

function CharacterModule:IsMoving(): boolean
	local humanoid = CharacterModule:GetHumanoid()
	if not humanoid then
		return false
	end
	return if humanoid.MoveDirection == Vector3.zero then false else true
end

return CharacterModule
