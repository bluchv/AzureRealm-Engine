local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local ReplicatedModulesDirectory = ReplicatedStorage
local SharedModulesDirectory = ReplicatedModulesDirectory.Shared
local ServerModulesDirectory = ServerScriptService
local _packages = ReplicatedStorage.Packages
local ReplicatedUIDirectory = ReplicatedStorage.UI

local AzureLogger = require(script.Parent.AzureLogger)
local RuntimeLogger = require(SharedModulesDirectory.RuntimeLogger)

local ModuleCache = {}
local EventKeyMapping = {
	PlayerAdded = {},
	PlayerRemoving = {},
}

local Initialized = false
local StartedModules = false
local GuiLoaded = false

local AzureRealmEngineServer = {
	Packages = ReplicatedStorage.Packages,
}

local function LoadModule(instance)
	if not instance:IsA("ModuleScript") then
		return
	end

	if ModuleCache[instance.Name] then
		return
	end

	local LoadTimeLogger = RuntimeLogger.new()
	local LoadSucess, LoadResult = pcall(function()
		return require(instance)
	end)

	if not LoadSucess then
		AzureLogger:Warn(`Failed to load module "{instance.Name}" ({instance:GetFullName()}).\n{LoadResult}`)
		return
	end

	if LoadResult["Init"] then
		local InitSuccess, InitError = pcall(function()
			LoadResult:Init()
		end)

		if not InitSuccess then
			AzureLogger:Warn(`Init function failure on "{instance.Name}" ({instance:GetFullName()}). \n{InitError}`)
			return
		end
	end

	for index, _ in EventKeyMapping do
		if LoadResult[index] then
			table.insert(EventKeyMapping[index], LoadResult)
		end
	end

	ModuleCache[instance.Name] = LoadResult
	LoadTimeLogger:PrintTime(`[AzureRealm-Engine] Initialized {instance.Name} in %s seconds`)
end

local function LoadChildrenModules(parent)
	if type(parent) ~= "table" then
		if typeof(parent) == "Instance" then
			parent = parent:GetChildren()
		else
			warn(`Can't load due to input not being a table or instance!`)
			return
		end
	end

	for _, instance: Instance in parent do
		LoadModule(instance)
	end
end

local function StartAllModules()
	if StartedModules then
		error(`Already started client modules!`)
	end
	StartedModules = true

	for moduleName, moduleContents in ModuleCache do
		if moduleContents["Start"] then
			coroutine.wrap(function()
				local success, output = pcall(function()
					return moduleContents:Start()
				end)

				if not success then
					warn(("Error starting module %q. \n%s"):format(moduleName, output))
				end
			end)()
		end
	end
end

function AzureRealmEngineServer:Start()
	if Initialized then
		error(`Already started FrameworkClient!`)
	end
	Initialized = true
	AzureLogger:Log("Initializing")
	print(string.rep("-", 30))

	Players.PlayerAdded:Connect(function(...)
		for _, module in EventKeyMapping.PlayerAdded do
			task.spawn(module.PlayerAdded, module, ...)
		end
	end)

	Players.PlayerRemoving:Connect(function(...)
		for _, module in EventKeyMapping.PlayerRemoving do
			task.spawn(module.PlayerRemoving, module, ...)
		end
	end)

	AzureRealmEngineServer.Packets = require(script.Parent.AzurePackets)
	AzureRealmEngineServer:LoadGUI()

	local InitializeLogger = RuntimeLogger.new()
	LoadChildrenModules(ServerModulesDirectory.Game)
	StartAllModules()

	for _, player in Players:GetPlayers() do
		for _, module in EventKeyMapping.PlayerAdded do
			task.spawn(module.PlayerAdded, module, player)
		end
	end

	print(string.rep("-", 30))
	InitializeLogger:PrintTime(`[AzureRealm-Engine] Initialized in %s seconds`)
end

function AzureRealmEngineServer:LoadGUI()
	if GuiLoaded then
		error(`Already loaded GUI!`)
	end
	GuiLoaded = true

	for _, gui: Instance in StarterGui:GetChildren() do
		if gui:IsA("ScreenGui") then
			gui.Parent = ReplicatedUIDirectory
		end
	end
end

return AzureRealmEngineServer
