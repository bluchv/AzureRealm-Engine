local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Network = require(Packages.Network)

local AzurePackets = {}

AzurePackets.Main = Network.defineNamespace("Main", function()
	return {
		somePacket = Network.definePacket({
			value = Network.struct({
				teststring = Network.string,
			}),
		}),
	}
end)

return AzurePackets
