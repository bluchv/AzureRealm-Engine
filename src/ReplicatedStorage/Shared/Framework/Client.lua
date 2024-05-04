local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local SharedModulesDirectory = ReplicatedStorage:WaitForChild("Shared")
local ClientModulesDirectory = ReplicatedStorage:WaitForChild("Client")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ReplicatedUIDirectory = ReplicatedStorage:WaitForChild("UI")
local GuiDirectory = Player.PlayerGui

local RuntimeLogger = require(SharedModulesDirectory:WaitForChild("RuntimeLogger"))

local ModuleCache = {}
local EventKeyMapping = {
	CharacterAdded = {},
	CharacterRemoved = {},
	CharacterDied = {},

	InputBegan = {},
	InputEnded = {},
}

local Initialized = false
local StartedModules = false
local GuiLoaded = false
local Client = {
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

	for index, _ in EventKeyMapping do
		if LoadResult[index] then
			table.insert(EventKeyMapping[index], LoadResult)
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

local function LoadUIScreen(screen: Instance)
	if screen:IsA("ScreenGui") then
		repeat
			screen.Parent = GuiDirectory
			task.wait()
		until screen.Parent == GuiDirectory
	end
end

local function HandleCharacter()
	local character = Player.Character
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid
	local _humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
	local _animator = humanoid:WaitForChild("Animator", 10)

	humanoid.Died:Once(function()
		for _, module in EventKeyMapping.CharacterDied do
			task.spawn(module.CharacterDied, module)
		end
	end)

	for _, module in EventKeyMapping.CharacterAdded do
		task.spawn(module.CharacterAdded, module, character)
	end
end

function Client:Start()
	if Initialized then
		error(`Already started FrameworkClient!`)
	end
	Initialized = true
	print(`[Initializing] client-framework.`)

	while not game:IsLoaded() do
		RunService.RenderStepped:Wait()
	end

	Client.Model = require(ClientModulesDirectory.Gui.Model.Model)
	Client.View = require(ClientModulesDirectory.Gui.View.View)
	Client.Controller = require(ClientModulesDirectory.Gui.Controller.Controller)

	InputService.InputBegan:Connect(function(...)
		for _, module in EventKeyMapping.InputBegan do
			task.spawn(module.InputBegan, module, ...)
		end
	end)

	InputService.InputEnded:Connect(function(...)
		for _, module in EventKeyMapping.InputEnded do
			task.spawn(module.InputEnded, module, ...)
		end
	end)

	Player.CharacterAdded:Connect(HandleCharacter)

	Player.CharacterRemoving:Connect(function()
		for _, module in EventKeyMapping.CharacterRemoved do
			task.spawn(module.CharacterRemoved, module)
		end
	end)

	local InitializeLogger = RuntimeLogger.new()
	require(Packages.Network)
	LoadChildrenModules(ClientModulesDirectory.Game)
	LoadChildrenModules(ClientModulesDirectory.Gui)
	StartAllModules()

	if Player.Character then
		HandleCharacter()
	end
	InitializeLogger:PrintTime(`[Initializing] Finished initializing client-framework, took %s seconds.`)
end

function Client:LoadGUI()
	if GuiLoaded then
		error(`Already loaded GUI!`)
	end
	GuiLoaded = true

	ReplicatedUIDirectory.ChildAdded:Connect(LoadUIScreen)

	for _, gui: Instance in ReplicatedUIDirectory:GetChildren() do
		LoadUIScreen(gui)
	end
end

function Client:Test()
	print("Test method from framework-core")
end

return Client
