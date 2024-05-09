local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Player = game:GetService("Players").LocalPlayer

local AzureEngine = ReplicatedStorage.Shared["AzureRealm-Engine"]
local _logger = require(AzureEngine.AzureLogger)

local View = {}

function View:UpdateSprintingLabel(_isSprinting: boolean)
	-- if isSprinting then
	-- 	-- Player.PlayerGui.ScreenGui.TextLabel.Text = "Sprinting"
	-- else
	-- 	-- Player.PlayerGui.ScreenGui.TextLabel.Text = "Walking"
	-- end
end

return View
