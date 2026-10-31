-- God Mode + Fly + Draggable UI Button

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

local FLY_SPEED = 32
local isMobile = UserInputService.TouchEnabled

-- ==================== UI (Draggable Fly Button) ====================
local function createUI()
	local old = player.PlayerGui:FindFirstChild("GodFlyUI")
	if old then old:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GodFlyUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local flyButton = Instance.new("TextButton")
	flyButton.Name = "FlyButton"
	flyButton.Size = UDim2.new(0, 170, 0, 44)
	flyButton.Position = UDim2.new(0.5, -85, 0.84, 0)
	flyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	flyButton.Font = Enum.Font.GothamBold
	flyButton.TextSize = 16
	flyButton.Text = "Fly + God: OFF"
	flyButton.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = flyButton

	-- ==================== DRAGGABLE LOGIC ====================
	local dragging = false
	local dragInput, dragStart, startPos

	flyButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = flyButton.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	flyButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			flyButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	-- ==========================================================

	return flyButton
end

local flyButton = createUI()

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
	pcall(function()
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end)
end

local function startFly()
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
		flyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	else
		startFly()
		enableGodMode()
		flyButton.Text = "Fly + God: ON"
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
	end
end

-- ==================== CONNECTIONS ====================
flyButton.MouseButton1Click:Connect(toggleFly)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	task.wait(0.6)
	flyButton = createUI()
	flyButton.MouseButton1Click:Connect(toggleFly)

	if flying then
		stopFly()
		task.wait(0.2)
		startFly()
	end
	if godMode then
		enableGodMode()
	end
end)

-- Keep UI alive
task.spawn(function()
	while true do
		task.wait(4)
		if not player.PlayerGui:FindFirstChild("GodFlyUI") then
			flyButton = createUI()
			flyButton.MouseButton1Click:Connect(toggleFly)
		end
	end
end)

print("[GodFly] Draggable + God Mode version loaded")
