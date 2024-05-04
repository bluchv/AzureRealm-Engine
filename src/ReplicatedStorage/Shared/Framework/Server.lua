local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ReplicatedModulesDirectory = ReplicatedStorage
local SharedModulesDirectory = ReplicatedModulesDirectory.Shared
local ServerModulesDirectory = ServerScriptService
local Packages = ReplicatedStorage.Packages
local ReplicatedUIDirectory = ReplicatedStorage.UI

local RuntimeLogger = require(SharedModulesDirectory.RuntimeLogger)

local ModuleCache = {}

local Initialized = false
local StartedModules = false
local GuiLoaded = false
local Server = {}

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
		warn(`Failed to load module "{instance.Name}" ({instance:GetFullName()}).\n{LoadResult}`)
		return
	end

	if LoadResult["Init"] then
		local InitSuccess, InitError = pcall(function()
			LoadResult:Init()
		end)

		if not InitSuccess then
			warn(`Init function failure on "{instance.Name}" ({instance:GetFullName()}). \n{InitError}`)
			return
		end
	end

	ModuleCache[instance.Name] = LoadResult
	LoadTimeLogger:PrintTime(`[Initialized] {instance.Name}, took %s seconds.`)
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

function Server:Start()
	if Initialized then
		error(`Already started FrameworkServer!`)
	end
	Initialized = true
	print(`[Initializing] server-framework.`)

	Server.Packages = ReplicatedStorage.Packages

	Server:LoadGUI()

	local InitializeLogger = RuntimeLogger.new()
	require(Packages.Network)
	LoadChildrenModules(ServerModulesDirectory.Game)
	StartAllModules()
	InitializeLogger:PrintTime(`[Initializing] Finished initializing server-framework, took %s seconds.`)
end

function Server:LoadGUI()
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

return Server
