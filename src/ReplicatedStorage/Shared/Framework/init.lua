local RunTime = game:GetService("RunService")

local Framework = {}

if RunTime:IsClient() then
	script.Server:Destroy()
	Framework.Client = require(script.Client)
else
	Framework.Server = require(script.Server)
end

return Framework
