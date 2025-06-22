-- ใช้ใน LocalScript บน Executor (Synapse, Delta ฯลฯ)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ESP_Enabled = false
local Aimbot_Target = nil
local Fly_Enabled = false
local HP_Enabled = false
local FPS_Limit = 60

-- [[ ESP ]]
local function createESP(player)
    local box = Drawing.new("Square")
    box.Color = Color3.new(0, 1, 0)
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Color = Color3.new(0, 1, 0)
    nameTag.Center = true
    nameTag.Outline = true

    RunService.RenderStepped:Connect(function()
        if ESP_Enabled and player.Character and player ~= localPlayer then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen and (head.Position - camera.CFrame.Position).Magnitude <= 1000 then
                    local size = 50 / (head.Position - camera.CFrame.Position).Magnitude * 100
                    box.Size = Vector2.new(size, size * 1.5)
                    box.Position = Vector2.new(pos.X - size / 2, pos.Y - size)
                    box.Visible = true
                    nameTag.Position = Vector2.new(pos.X, pos.Y - size * 1.2)
                    nameTag.Text = player.Name
                    nameTag.Visible = true
                else
                    box.Visible = false
                    nameTag.Visible = false
                end
            end
        else
            box.Visible = false
            nameTag.Visible = false
        end
    end)
end

-- สร้าง ESP ให้ทุกคน
for _, p in pairs(Players:GetPlayers()) do
    if p ~= localPlayer then
        createESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= localPlayer then
        createESP(p)
    end
end)

-- [[ Aimbot ]]
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.L and not processed then
        print("เลือกล็อกเป้าผู้เล่น:")
        for i, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                print(i .. ": " .. player.Name)
            end
        end
        local selection = tonumber(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Chat"):WaitForChild("Frame"):WaitForChild("BoxFrame"):WaitForChild("ChatBar"):GetPropertyChangedSignal("Text"))
        Aimbot_Target = Players:GetPlayers()[selection]
    end
end)

-- ใช้ Aimbot ในสกิล
RunService.RenderStepped:Connect(function()
    if Aimbot_Target and Aimbot_Target.Character and Aimbot_Target.Character:FindFirstChild("Head") then
        local targetPos = Aimbot_Target.Character.Head.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end)

-- [[ Fly ]]
local flying = false
local flySpeed = 100

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        Fly_Enabled = flying
    end
end)

RunService.RenderStepped:Connect(function()
    if Fly_Enabled then
        local cf = camera.CFrame
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += cf.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= cf.UpVector end

        local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Anchored = true
            root.CFrame = root.CFrame + move.Unit * flySpeed * RunService.RenderStepped:Wait()
        end
    else
        local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
    end
end)

-- [[ HP & Noclip & God Mode ]]
RunService.RenderStepped:Connect(function()
    if HP_Enabled and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = math.min(humanoid.Health + (0.05 * humanoid.MaxHealth), humanoid.MaxHealth)
        end
    end
end)

-- [[ FPS Limit ]]
setfpscap = setfpscap or function() end -- รองรับ executor บางตัว
RunService.RenderStepped:Connect(function()
    setfpscap(FPS_Limit)
end)

-- [[ ปุ่มกดเปิด/ปิดฟังก์ชัน ]]
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then ESP_Enabled = not ESP_Enabled end
    if input.KeyCode == Enum.KeyCode.H then HP_Enabled = not HP_Enabled end
    if input.KeyCode == Enum.KeyCode.K then FPS_Limit = 240 end -- ตั้งเป็น 240 FPS
end)