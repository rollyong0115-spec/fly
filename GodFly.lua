-- God Mode + Fly Script

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

local FLY_SPEED = 80
local BOOST_SPEED = 140

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodFlyUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 170, 0, 46)
button.Position = UDim2.new(0.5, -85, 0.86, 0)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.Text = "Fly + God: OFF"
button.AutoButtonColor = false
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 80)
stroke.Thickness = 1.4
stroke.Parent = button

-- Functions
local function enableGodMode()
	godMode = true
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge

	if healthConnection then
		healthConnection:Disconnect()
	end

	healthConnection = humanoid.HealthChanged:Connect(function()
		if godMode and humanoid.Health < humanoid.MaxHealth then
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

	RunService:BindToRenderStep("GodFly", Enum.RenderPriority.Character.Value, function()
		if not flying or not root or not root.Parent then return end

		local cam = workspace.CurrentCamera
		local dir = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			dir += cam.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			dir -= cam.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			dir -= cam.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			dir += cam.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			dir += Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
			dir -= Vector3.new(0, 1, 0)
		end

		local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and BOOST_SPEED or FLY_SPEED
		bodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
		bodyGyro.CFrame = cam.CFrame
	end)
end

local function stopFly()
	flying = false
	RunService:UnbindFromRenderStep("GodFly")

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	if humanoid then
		humanoid.PlatformStand = false
	end
end

local function toggle()
	if flying then
		stopFly()
		disableGodMode()
		button.Text = "Fly + God: OFF"
		button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		stroke.Color = Color3.fromRGB(70, 70, 80)
	else
		startFly()
		enableGodMode()
		button.Text = "Fly + God: ON"
		button.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
		stroke.Color = Color3.fromRGB(100, 180, 255)
	end
end

button.MouseButton1Click:Connect(toggle)

-- Character respawn support
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

print("[GodFly] Loaded successfully")
