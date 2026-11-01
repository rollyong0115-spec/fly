    title.Active = true
    title.Parent = frame
    Instance.new("UICorner",title).CornerRadius = UDim.new(0,12)

    local floating = Instance.new("TextButton")
    floating.Size = UDim2.fromOffset(45,45)
    floating.Position = UDim2.new(0.78,0,0.08,0)
    floating.BackgroundColor3 = Color3.fromRGB(0,130,255)
    floating.TextColor3 = Color3.new(1,1,1)
    floating.Font = Enum.Font.GothamBold
    floating.TextSize = 18
    floating.Text = "⚙"
    floating.Parent = gui
    Instance.new("UICorner",floating).CornerRadius = UDim.new(1,0)
    floating.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

    local function toggle(name, y, getState, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-20,0,34)
        btn.Position = UDim2.fromOffset(10,y)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 11
        btn.Parent = frame
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
        local function refresh()
            local state = getState()
            btn.Text = name .. (state and ": ON" or ": OFF")
            btn.BackgroundColor3 = state and Color3.fromRGB(0,130,255) or Color3.fromRGB(45,45,55)
        end
        btn.MouseButton1Click:Connect(function() callback(not getState()); refresh() end)
        refresh()
    end

    toggle("Fly + God Mode",45,function() return flying and godMode end,function(v)
        if v then startFly(); enableGodMode() else stopFly(); disableGodMode() end
    end)
    toggle("Speed Boost",85,function() return speedEnabled end,function(v)
        speedEnabled = v
        if not v and humanoid then humanoid.WalkSpeed = originalWalkSpeed or 16 end
    end)
    toggle("Instant 1-Hit Boss Kill (local)",125,function() return instantKillEnabled end,function(v) instantKillEnabled = v end)
    toggle("Auto Punch / Attack",165,function() return autoPunchEnabled end,function(v) autoPunchEnabled = v end)
    toggle("Cosmic Slime Damage x1000",205,function() return slimeBoostEnabled end,function(v)
        slimeBoostEnabled = v
        previewSlimeDamage()
    end)

    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1,-20,0,30)
    note.Position = UDim2.fromOffset(10,245)
    note.BackgroundTransparency = 1
    note.TextWrapped = true
    note.TextColor3 = Color3.fromRGB(190,190,195)
    note.Font = Enum.Font.Gotham
    note.TextSize = 10
    note.Text = "Slime boost previews damage; server integration required"
    note.Parent = frame

    local hide = Instance.new("TextButton")
    hide.Size = UDim2.new(1,-20,0,32)
    hide.Position = UDim2.fromOffset(10,290)
    hide.BackgroundColor3 = Color3.fromRGB(180,40,40)
    hide.TextColor3 = Color3.new(1,1,1)
    hide.Font = Enum.Font.GothamBold
    hide.TextSize = 12
    hide.Text = "Hide Menu"
    hide.Parent = frame
    Instance.new("UICorner",hide).CornerRadius = UDim.new(0,8)
    hide.MouseButton1Click:Connect(function() frame.Visible = false end)

    local dragging, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

createUI()
local attackAccumulator = 0
runtimeConnection = RunService.Heartbeat:Connect(function(dt)
    if not character or not humanoid or not root then return end
    if speedEnabled then humanoid.WalkSpeed = CUSTOM_WALK_SPEED end
    -- Local-only test. Server-authoritative bosses will ignore client-side health edits.
    if instantKillEnabled then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and (obj.Name:find("Boss") or obj.Name:find("Treant") or obj.Name:find("Thornhart")) then
                local bossHum = obj:FindFirstChildOfClass("Humanoid")
                if bossHum and bossHum.Health > 0 then bossHum.Health = 0 end
            end
        end
    end
    attackAccumulator += dt
    if autoPunchEnabled and attackAccumulator >= 0.15 then
        attackAccumulator = 0
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

player.CharacterAdded:Connect(function(char)
    stopFly()
    if healthConnection then healthConnection:Disconnect(); healthConnection = nil end
    bindCharacter(char)
    if godMode then enableGodMode() end
    if speedEnabled then humanoid.WalkSpeed = CUSTOM_WALK_SPEED end
    if flying then startFly() end
end)
print("[Boss Pro] Loaded. Cosmic Pumpkin King x1000 is preview-only until server integration.")
