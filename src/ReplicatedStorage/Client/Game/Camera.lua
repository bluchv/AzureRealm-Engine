local TweenService = game:GetService("TweenService")

local CameraObject = workspace.CurrentCamera
local CurrentTweenGoal = 70

local Camera = {}

function Camera:TweenFieldOfView(fov: number, timeInSeconds: number): ()
    if CurrentTweenGoal ~= fov then
        CurrentTweenGoal = fov
        TweenService:Create(CameraObject, TweenInfo.new(timeInSeconds), { FieldOfView = fov }):Play()
    end
end

function Camera:SetFieldOfView(fov: number)
    CurrentTweenGoal = fov
    CameraObject.FieldOfView = fov
end

return Camera
