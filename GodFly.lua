-- Safer version (lower speed + stronger UI)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local godMode = false
local bodyVelocity = nil
local bodyGyro = nil
local healthConnection = nil
local flyConnection = nil

local FLY_SPEED = 35          -- Much lower speed (harder to detect)
local isMobile = UserInputService.TouchEnabled

-- ==================== CREATE UI ====================
local function createUI()
	-- Remove old one if it exists
	local old = player.PlayerGui:FindFirstChild("GodFlyUI")
	if old then old:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GodFlyUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "Main"
	mainFrame.Size = UDim2.new(0, 190, 0, 110)
	mainFrame.Position = UDim2.new(0.5, -95, 0.79, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Fly Button
	local flyButton = Instance.new("TextButton")
	flyButton.Name = "FlyButton"
	flyButton.Size = UDim2.new(0.9, 0, 0, 40)
	flyButton.Position = UDim2.new(0.05, 0, 0.08, 0)
	flyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	flyButton.Font = Enum.Font.GothamBold
	flyButton.TextSize = 15
	flyButton.Text = "Fly + God: OFF"
	flyButton.Parent = mainFrame

	local flyCorner = Instance.new("UICorner")
	flyCorner.CornerRadius = UDim.new(0, 9)
	flyCorner.Parent = flyButton

	-- Attack Button
	local attackButton = Instance.new("TextButton")
	attackButton.Name = "AttackButton"
	attackButton.Size = UDim2.new(0.9, 0, 0, 40)
	attackButton.Position = UDim2.new(0.05, 0, 0.52, 0)
	attackButton.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
	attackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	attackButton.Font = Enum.Font.GothamBold
	attackButton.TextSize = 15
	attackButton.Text = "ATTACK"
	attackButton.Parent = mainFrame

	local attackCorner = Instance.new("UICorner")
	attackCorner.CornerRadius = UDim.new(0, 9)
	attackCorner.Parent = attackButton

	return flyButton, attackButton
end

local flyButton, attackButton = createUI()

-- ==================== FUNCTIONS ====================
local function enableGodMode()
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

local function disableGodMode()
	godMode = false
	if healthConnection then
		healthConnection:Disconnect()
		healthConnection = nil
	end
	humanoid.MaxHealth = 100
	humanoid.Health = 100
end

local function startFly()
	if flying then return end
	flying = true

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000) -- Lower force
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
	bodyGyro.P = 3000
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
			velocity = velocity + Vector3.new(0, FLY_SPEED * 0.7, 0)
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

local function stopFly()
	flying = false
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	if humanoid then humanoid.PlatformStand = false end
end

local function toggleFly()
	if flying then
		stopFly()
		disableGodMode()
		flyButton.Text = "Fly + God: OFF"
		flyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	else
		startFly()
		enableGodMode()
		flyButton.Text = "Fly + God: ON"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
	end
end

local function doAttack()
	attackButton.Text = "..."
	task.wait(0.12)
	attackButton.Text = "ATTACK"
end

-- ==================== CONNECTIONS ====================
flyButton.MouseButton1Click:Connect(toggleFly)
attackButton.MouseButton1Click:Connect(doAttack)

-- Keep UI alive + support respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	-- Recreate UI just in case the game deleted it
	task.wait(0.5)
	flyButton, attackButton = createUI()
	flyButton.MouseButton1Click:Connect(toggleFly)
	attackButton.MouseButton1Click:Connect(doAttack)

	if flying then
		stopFly()
		task.wait(0.2)
		startFly()
	end
	if godMode then
		enableGodMode()
	end
end)

-- Also recreate UI every few seconds if it gets deleted
task.spawn(function()
	while true do
		task.wait(3)
		if not player.PlayerGui:FindFirstChild("GodFlyUI") then
			flyButton, attackButton = createUI()
			flyButton.MouseButton1Click:Connect(toggleFly)
			attackButton.MouseButton1Click:Connect(doAttack)
		end
	end
end)

print("[GodFly] Safer version loaded")
