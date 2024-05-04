local RunTime = game:GetService("RunService")

local AzureRealmEngine = {}

if RunTime:IsClient() then
	script.AzureRealmServer:Destroy()
	AzureRealmEngine.Client = require(script.AzureRealmClient)
else
	AzureRealmEngine.Server = require(script.AzureRealmServer)
end

return AzureRealmEngine
