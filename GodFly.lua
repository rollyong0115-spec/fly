-- God Mode + Fly + Attack Button (Mobile Friendly)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local FLY_SPEED = 65
local isMobile = UserInputService.TouchEnabled

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodFlyUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0.5, -100, 0.78, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

-- Fly + God Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 42)
flyButton.Position = UDim2.new(0.05, 0, 0.08, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 16
flyButton.Text = "Fly + God: OFF"
flyButton.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 10)
flyCorner.Parent = flyButton

-- Attack Button
local attackButton = Instance.new("TextButton")
attackButton.Size = UDim2.new(0.9, 0, 0, 42)
attackButton.Position = UDim2.new(0.05, 0, 0.52, 0)
attackButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
attackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
attackButton.Font = Enum.Font.GothamBold
attackButton.TextSize = 16
attackButton.Text = "ATTACK"
attackButton.Parent = mainFrame

local attackCorner = Instance.new("UICorner")
attackCorner.CornerRadius = UDim.new(0, 10)
attackCorner.Parent = attackButton

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
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 9e4
	bodyGyro.Parent = root

	humanoid.PlatformStand = true

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flying or not root or not root.Parent then return end

		local cam = workspace.CurrentCamera
		local move = humanoid.MoveDirection
		local velocity = Vector3.zero

		if move.Magnitude > 0.05 then
			velocity = move * FLY_SPEED
		end

		-- Mobile: Hold Jump to go up
		if isMobile and humanoid.Jump then
			velocity = velocity + Vector3.new(0, FLY_SPEED * 0.85, 0)
		end

		-- PC
		if not isMobile then
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				velocity = velocity + Vector3.new(0, FLY_SPEED, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				velocity = velocity + Vector3.new(0, -FLY_SPEED, 0)
			end
		end

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
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
		flyButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	end
end

-- Attack function (basic version)
local function doAttack()
	-- This tries to force an attack.
	-- Later we can improve it once we find the correct remote.

	local slime = nil
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name:lower():find("slime") and v:FindFirstChild("HumanoidRootPart") then
			-- simple check if it's near the player
			if (v.HumanoidRootPart.Position - root.Position).Magnitude < 40 then
				slime = v
				break
			end
		end
	end

	-- Visual feedback
	attackButton.Text = "ATTACKING..."
	task.wait(0.15)
	attackButton.Text = "ATTACK"
end

-- ==================== CONNECTIONS ====================
flyButton.MouseButton1Click:Connect(toggleFly)
attackButton.MouseButton1Click:Connect(doAttack)

-- Support character respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	if flying then
		stopFly()
		task.wait(0.1)
		startFly()
	end
	if godMode then
		enableGodMode()
	end
end)

print("[GodFly] Loaded with Attack button")
