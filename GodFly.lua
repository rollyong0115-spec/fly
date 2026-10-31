-- Boss Fight Pro Script: Fly, God Mode, Speed, Weapon Tool Spawner & Hit Injector
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Feature States
local flying = false
local godMode = false
local speedEnabled = false
local weaponSpawnerEnabled = false
local autoHitEnabled = false

local FLY_SPEED = 32
local CUSTOM_WALK_SPEED = 24
local isMobile = UserInputService.TouchEnabled

local bodyVelocity = nil
local bodyGyro = nil
local healthConnection = nil
local flyConnection = nil

-- ==================== UI SETUP ====================
local function createUI()
	local old = player.PlayerGui:FindFirstChild("BossProMenu")
	if old then old:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BossProMenu"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	screenGui.Parent = player:WaitForChild("PlayerGui")

	-- Main Menu Frame (Draggable)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 200, 0, 310)
	mainFrame.Position = UDim2.new(0.65, -100, 0.25, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 35)
	title.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Text = "Boss Fight Pro"
	title.Parent = mainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title

	-- Minimize / Open Floating Circle Button
	local minButton = Instance.new("TextButton")
	minButton.Name = "MinButton"
	minButton.Size = UDim2.new(0, 45, 0, 45)
	minButton.Position = UDim2.new(0.9, -45, 0.15, 0)
	minButton.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
	minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minButton.Font = Enum.Font.GothamBold
	minButton.TextSize = 18
	minButton.Text = "⚙️"
	minButton.Parent = screenGui

	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(1, 0)
	minCorner.Parent = minButton

	local menuVisible = true
	minButton.MouseButton1Click:Connect(function()
		menuVisible = not menuVisible
		mainFrame.Visible = menuVisible
	end)

	-- Toggle Button Helper
	local function createToggle(name, yPos, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 180, 0, 32)
		btn.Position = UDim2.new(0.5, -90, 0, yPos)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 12
		btn.Text = name .. ": OFF"
		btn.Parent = mainFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = btn

		local active = false
		btn.MouseButton1Click:Connect(function()
			active = not active
			if active then
				btn.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
				btn.Text = name .. ": ON"
			else
				btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
				btn.Text = name .. ": OFF"
			end
			callback(active)
		end)
	end

	createToggle("Fly + God Mode", 42, function(state) 
		if state then
			startFly()
			enableGodMode()
		else
			stopFly()
			disableGodMode()
		end
	end)

	createToggle("Speed Boost", 78, function(state) speedEnabled = state end)
	createToggle("Auto Boss Hit / Gun", 114, function(state) autoHitEnabled = state end)

	-- Custom Weapon/Tool Spawner Button
	local spawnBtn = Instance.new("TextButton")
	spawnBtn.Size = UDim2.new(0, 180, 0, 32)
	spawnBtn.Position = UDim2.new(0.5, -90, 0, 150)
	spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 80)
	spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	spawnBtn.Font = Enum.Font.GothamBold
	spawnBtn.TextSize = 12
	spawnBtn.Text = "Spawn Test Pistol/Sword"
	spawnBtn.Parent = mainFrame

	local spawnCorner = Instance.new("UICorner")
	spawnCorner.CornerRadius = UDim.new(0, 8)
	spawnCorner.Parent = spawnBtn

	spawnBtn.MouseButton1Click:Connect(function()
		pcall(function()
			-- Creates a custom tool in backpack for visual/testing use
			local tool = Instance.new("Tool")
			tool.Name = "Pro Blaster / Sword"
			local handle = Instance.new("Part")
			handle.Name = "Handle"
			handle.Size = Vector3.new(1, 1, 3)
			handle.BrickColor = BrickColor.new("Bright blue")
			handle.Parent = tool
			tool.Parent = player.Backpack
		end)
	end)

	-- Minimize button inside menu
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 180, 0, 28)
	closeBtn.Position = UDim2.new(0.5, -90, 0, 260)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.Text = "Hide Menu"
	closeBtn.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
	end)

	-- Draggable Window Logic for Main Frame
	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return screenGui
end

createUI()

-- ==================== FUNCTIONS ====================
enableGodMode = function()
	godMode = true
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge

	if healthConnection then healthConnection:Disconnect() end
	healthConnection = humanoid.HealthChanged:Connect(function()
		if godMode then
			humanoid.Health = humanoid.MaxHealth
		end
	end)
end

disableGodMode = function()
	godMode = false
	if healthConnection then
		healthConnection:Disconnect()
		healthConnection = nil
	end
	pcall(function()
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end)
end

startFly = function()
	if flying then return end
	flying = true

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(30000, 30000, 30000)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(30000, 30000, 30000)
	bodyGyro.P = 2500
	bodyGyro.Parent = root

	humanoid.PlatformStand = true

	flyConnection = RunService.Heartbeat:Connect(function()
		if not flying or not root or not root.Parent then return end

		local move = humanoid.MoveDirection
		local velocity = Vector3.zero

		if move.Magnitude > 0.05 then
			velocity = move * FLY_SPEED
		end

		if isMobile and humanoid.Jump then
			velocity = velocity + Vector3.new(0, FLY_SPEED * 0.65, 0)
		end

		if not isMobile then
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				velocity = velocity + Vector3.new(0, FLY_SPEED, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				velocity = velocity + Vector3.new(0, -FLY_SPEED, 0)
			end
		end

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	end)
end

stopFly = function()
	flying = false
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	if humanoid then humanoid.PlatformStand = false end
end

-- ==================== RUNTIME LOOP ====================
RunService.Heartbeat:Connect(function()
	if not character or not humanoid or not root then return end

	-- Speed Boost Loop
	if speedEnabled then
		humanoid.WalkSpeed = CUSTOM_WALK_SPEED
	end

	-- Auto Boss Hit Injector (Scans workspace for boss models and simulates touch/hit interactions)
	if autoHitEnabled then
		pcall(function()
			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and (obj.Name:find("Boss") or obj.Name:find("Treant") or obj.Name:find("Thornhart")) then
					local bossRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
					if bossRoot and (bossRoot.Position - root.Position).Magnitude < 40 then
						-- Teleports tool handle or character close to register hit events if server allows client proximity
						root.CFrame = CFrame.new(bossRoot.Position + Vector3.new(0, 0, 3))
					end
				end
			end
		end)
	end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	task.wait(0.6)
	createUI()

	if flying then
		stopFly()
		task.wait(0.2)
		startFly()
	end
	if godMode then
		enableGodMode()
	end
end)

print("[Boss Pro] Script loaded with Menu, Fly, God Mode, and Weapon Spawner!")
