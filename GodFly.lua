
-- GodFly V2 | Mobile + PC
-- Flight, Speed Boost, Auto Tool Activation
-- Client-side movement; server may override it.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local env = getgenv and getgenv() or _G

if env.GodFlyV2 then
    pcall(env.GodFlyV2.cleanup)
end

local old = pg:FindFirstChild("GodFlyV2")
if old then old:Destroy() end

local S = {
    alive = true,
    flying = false,
    speed = false,
    attacking = false,
    up = false,
    down = false,
    flySpeed = 55,
    walkSpeed = 40,
    connections = {},
    originalSpeed = nil,
    attachment = nil,
    velocity = nil
}

env.GodFlyV2 = S

local function track(c)
    table.insert(S.connections, c)
    return c
end

local function characterParts()
    local char = player.Character
    if not char then return end
    return char,
        char:FindFirstChildOfClass("Humanoid"),
        char:FindFirstChild("HumanoidRootPart")
end

local function stopFly()
    S.flying = false
    S.up = false
    S.down = false

    if S.velocity then
        S.velocity:Destroy()
        S.velocity = nil
    end

    if S.attachment then
        S.attachment:Destroy()
        S.attachment = nil
    end

    local _, hum = characterParts()
    if hum then
        hum.PlatformStand = false
    end
end

local function startFly()
    local _, hum, root = characterParts()
    if not hum or not root then
        return false
    end

    stopFly()

    local attachment = Instance.new("Attachment")
    attachment.Name = "GodFlyAttachment"
    attachment.Parent = root

    local velocity = Instance.new("LinearVelocity")
    velocity.Name = "GodFlyVelocity"
    velocity.Attachment0 = attachment
    velocity.MaxForce = math.huge
    velocity.VectorVelocity = Vector3.zero
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.Parent = root

    S.attachment = attachment
    S.velocity = velocity
    S.flying = true

    return true
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local purple = Color3.fromRGB(155, 83, 255)
local panel = Color3.fromRGB(38, 27, 58)
local white = Color3.fromRGB(245, 240, 255)

local function round(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 9)
    }, obj)
end

local gui = make("ScreenGui", {
    Name = "GodFlyV2",
    ResetOnSpawn = false,
    DisplayOrder = 999
}, pg)

local main = make("Frame", {
    Size = UDim2.fromOffset(280, 350),
    Position = UDim2.new(0.5, -140, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(20, 15, 32),
    BorderSizePixel = 0,
    Active = true
}, gui)
round(main, 14)

make("UIStroke", {
    Color = purple,
    Thickness = 1.5
}, main)

local title = make("TextLabel", {
    Size = UDim2.new(1, -65, 0, 42),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "GODFLY V2",
    TextColor3 = purple,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Active = true
}, main)

local function button(text, x, y, w, h)
    local b = make("TextButton", {
        Size = UDim2.fromOffset(w, h),
        Position = UDim2.fromOffset(x, y),
        BackgroundColor3 = panel,
        TextColor3 = white,
        Text = text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    }, main)
    round(b)
    return b
end

local hide = button("-", 215, 7, 25, 28)
local close = button("X", 246, 7, 25, 28)

local flyBtn = button("FLY: OFF", 10, 48, 260, 40)
local speedBtn = button("SPEED: OFF", 10, 96, 260, 40)
local attackBtn = button("AUTO ATTACK: OFF", 10, 144, 260, 40)

local flyMinus = button("-", 10, 194, 42, 36)
local flyValue = button("FLY SPEED: 55", 59, 194, 162, 36)
local flyPlus = button("+", 228, 194, 42, 36)

local upBtn = button("UP", 10, 242, 125, 42)
local downBtn = button("DOWN", 145, 242, 125, 42)

local info = make("TextLabel", {
    Position = UDim2.fromOffset(10, 292),
    Size = UDim2.fromOffset(260, 46),
    BackgroundTransparency = 1,
    Text = "Joystick to fly | Hold UP/DOWN\nClient-side features only",
    TextColor3 = white,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextWrapped = true
}, main)

local mini = make("TextButton", {
    Size = UDim2.fromOffset(55, 55),
    Position = UDim2.new(1, -70, 0.5, 0),
    BackgroundColor3 = purple,
    TextColor3 = white,
    Text = "FLY",
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    Visible = false
}, gui)
round(mini, 27)

local function refresh()
    flyBtn.Text = "FLY: " .. (S.flying and "ON" or "OFF")
    speedBtn.Text = "SPEED: " .. (S.speed and "ON" or "OFF")
    attackBtn.Text = "AUTO ATTACK: "
        .. (S.attacking and "ON" or "OFF")

    flyBtn.BackgroundColor3 = S.flying and purple or panel
    speedBtn.BackgroundColor3 = S.speed and purple or panel
    attackBtn.BackgroundColor3 = S.attacking and purple or panel
    flyValue.Text = "FLY SPEED: " .. S.flySpeed
end

track(flyBtn.MouseButton1Click:Connect(function()
    if S.flying then
        stopFly()
    else
        startFly()
    end
    refresh()
end))

track(speedBtn.MouseButton1Click:Connect(function()
    local _, hum = characterParts()
    S.speed = not S.speed

    if hum then
        if S.speed then
            S.originalSpeed = hum.WalkSpeed
            hum.WalkSpeed = S.walkSpeed
        else
            hum.WalkSpeed = S.originalSpeed or 16
        end
    end

    refresh()
end))

track(attackBtn.MouseButton1Click:Connect(function()
    S.attacking = not S.attacking
    refresh()
end))

track(flyMinus.MouseButton1Click:Connect(function()
    S.flySpeed = math.max(10, S.flySpeed - 10)
    refresh()
end))

track(flyPlus.MouseButton1Click:Connect(function()
    S.flySpeed = math.min(200, S.flySpeed + 10)
    refresh()
end))

local function holdButton(btn, key)
    track(btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            S[key] = true
        end
    end))

    track(btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            S[key] = false
        end
    end))
end

holdButton(upBtn, "up")
holdButton(downBtn, "down")

track(UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Space then
        S.up = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        S.down = true
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        S.up = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        S.down = false
    end
end))

-- Mobile-friendly dragging
local dragging = false
local dragStart, startPos, dragInput

track(title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        dragInput = input
    end
end))

track(UIS.InputChanged:Connect(function(input)
    if dragging and (
        input == dragInput
        or (
            dragInput
            and dragInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        )
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if input == dragInput
        or (
            dragInput
            and dragInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseButton1
        ) then
        dragging = false
    end
end))

track(hide.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
    S.up = false
    S.down = false
end))

track(mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end))

local attackTimer = 0

track(RunService.Heartbeat:Connect(function(dt)
    if not S.alive then return end

    local char, hum, root = characterParts()
    if not char or not hum or not root then return end

    if S.flying and S.velocity then
        local direction = hum.MoveDirection

        local vertical = 0
        if S.up then vertical += 1 end
        if S.down then vertical -= 1 end

        local move = direction + Vector3.new(0, vertical, 0)

        if move.Magnitude > 1 then
            move = move.Unit
        end

        S.velocity.VectorVelocity = move * S.flySpeed
    end

    if S.speed and not S.flying then
        hum.WalkSpeed = S.walkSpeed
    end

    attackTimer += dt

    if S.attacking and attackTimer >= 0.2 then
        attackTimer = 0

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                tool:Activate()
            end)
        end
    end
end))

track(player.CharacterAdded:Connect(function()
    stopFly()
    S.speed = false
    S.attacking = false
    S.originalSpeed = nil
    refresh()
end))

function S.cleanup()
    if not S.alive then return end

    S.alive = false
    stopFly()

    local _, hum = characterParts()
    if hum and S.originalSpeed then
        hum.WalkSpeed = S.originalSpeed
    end

    for _, c in ipairs(S.connections) do
        pcall(function() c:Disconnect() end)
    end

    if gui.Parent then gui:Destroy() end
end

track(close.MouseButton1Click:Connect(function()
    S.cleanup()
end))

refresh()
print("[GodFly V2] Loaded")
