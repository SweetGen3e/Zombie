-- [1] นำเข้า Services
local UserInputService = game:GetService("UserInputService") -- รับ input
local Players = game:GetService("Players") -- ข้อมูลผู้เล่น
local RunService = game:GetService("RunService") -- อัพเดททุกเฟรม
local TweenService = game:GetService("TweenService") -- อนิเมชัน UI
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- RemoteEvent
local LogService = game:GetService("LogService") -- ตรวจจับ anti-cheat
local Camera = workspace.CurrentCamera -- กล้อง

-- [2] กำหนดตัวแปรผู้เล่น
local player = Players.LocalPlayer -- ผู้เล่นปัจจุบัน
local playerGui = player:WaitForChild("PlayerGui", 10) -- รอ PlayerGui
if not playerGui then warn("[ERROR] PlayerGui not found!") return end
print("[DEBUG] PlayerGui loaded: ", playerGui)

-- [3] สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotUI"
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui
print("[DEBUG] ScreenGui created: ", screenGui.Parent)

-- [4] สร้าง MainFrame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.35, 0, 0.45, 0) -- ขนาดเล็กลงเล็กน้อย
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- ตรงกลาง
mainFrame.BackgroundTransparency = 0.7 -- โปร่งใส
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 80) -- น้ำเงินเข้ม
mainFrame.Visible = false
mainFrame.Parent = screenGui
print("[DEBUG] MainFrame created: ", mainFrame.Visible)

-- [5] เพิ่ม UICorner
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- [6] เพิ่ม UIGradient
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
}
uiGradient.Rotation = 45
uiGradient.Parent = mainFrame

-- [7] เพิ่ม UIStroke
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(200, 200, 255)
uiStroke.Transparency = 0.3
uiStroke.Parent = mainFrame

-- [8] สร้างปุ่ม Toggle UI
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.08, 0, 0.04, 0)
toggleButton.Position = UDim2.new(0.02, 0, 0.02, 0) -- มุมบนซ้าย
toggleButton.Text = "🟢"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Parent = screenGui
print("[DEBUG] ToggleButton created")

-- [9] ตัวแปรสถานะ
local isUIVisible = false
local aimbotEnabled = false
local aimlockEnabled = false
local rapidSwitchEnabled = false
local espBoxes = {}
local lastAntiCheatCheck = tick()
local isSafe = true -- สถานะความปลอดภัยจาก anti-cheat

-- [10] ฟังก์ชันป้องกันแบน
local function checkAntiCheat()
    local currentTime = tick()
    if currentTime - lastAntiCheatCheck < 5 then return end -- ตรวจทุก 5 วินาที
    lastAntiCheatCheck = currentTime

    -- ตรวจจับ LogService
    for _, message in pairs(LogService:GetLogHistory()) do
        if message.message:lower():find("cheat") or message.message:find("exploit") then
            isSafe = false
            warn("[WARNING] Possible anti-cheat detection! Pausing functions...")
            return
        end
    end

    -- ตรวจจับ RemoteEvent ที่น่าสงสัย
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name:lower():find("report") then
            isSafe = false
            warn("[WARNING] Suspicious RemoteEvent detected: ", child.Name)
            return
        end
    end
    isSafe = true
    print("[DEBUG] Anti-cheat check passed")
end

-- [11] ฟังก์ชันสลับ UI
local function toggleUI()
    isUIVisible = not isUIVisible
    mainFrame.Visible = isUIVisible
    toggleButton.Text = isUIVisible and "🔴" or "🟢"
    print("[DEBUG] UI Visible: ", isUIVisible)
end

-- [12] ตรวจจับการกด Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleUI()
    end
end)

-- [13] สร้าง Home Frame
local homeFrame = Instance.new("Frame")
homeFrame.Size = UDim2.new(1, 0, 0.8, 0)
homeFrame.Position = UDim2.new(0, 0, 0.2, 0)
homeFrame.BackgroundTransparency = 1
homeFrame.Parent = mainFrame
homeFrame.Visible = true
print("[DEBUG] HomeFrame created")

-- [14] สร้างปุ่ม Aimbot
local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0.85, 0, 0.2, 0)
aimbotButton.Position = UDim2.new(0.075, 0, 0.1, 0)
aimbotButton.Text = "Aimbot: OFF"
aimbotButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.TextScaled = true
aimbotButton.Parent = homeFrame
print("[DEBUG] AimbotButton created")

local aimbotButtonStroke = Instance.new("UIStroke")
aimbotButtonStroke.Thickness = 1.5
aimbotButtonStroke.Color = Color3.fromRGB(255, 255, 255)
aimbotButtonStroke.Transparency = 0.5
aimbotButtonStroke.Parent = aimbotButton

-- [15] สร้างปุ่ม Aimlock
local aimlockButton = Instance.new("TextButton")
aimlockButton.Size = UDim2.new(0.85, 0, 0.2, 0)
aimlockButton.Position = UDim2.new(0.075, 0, 0.35, 0)
aimlockButton.Text = "Aimlock: OFF"
aimlockButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
aimlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimlockButton.TextScaled = true
aimlockButton.Parent = homeFrame
print("[DEBUG] AimlockButton created")

local aimlockButtonStroke = Instance.new("UIStroke")
aimlockButtonStroke.Thickness = 1.5
aimlockButtonStroke.Color = Color3.fromRGB(255, 255, 255)
aimlockButtonStroke.Transparency = 0.5
aimlockButtonStroke.Parent = aimlockButton

-- [16] สร้างปุ่ม Rapid Switch
local rapidSwitchButton = Instance.new("TextButton")
rapidSwitchButton.Size = UDim2.new(0.85, 0, 0.2, 0)
rapidSwitchButton.Position = UDim2.new(0.075, 0, 0.6, 0)
rapidSwitchButton.Text = "Rapid Switch: OFF"
rapidSwitchButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
rapidSwitchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rapidSwitchButton.TextScaled = true
rapidSwitchButton.Parent = homeFrame
print("[DEBUG] RapidSwitchButton created")

local rapidSwitchButtonStroke = Instance.new("UIStroke")
rapidSwitchButtonStroke.Thickness = 1.5
rapidSwitchButtonStroke.Color = Color3.fromRGB(255, 255, 255)
rapidSwitchButtonStroke.Transparency = 0.5
rapidSwitchButtonStroke.Parent = rapidSwitchButton

-- [17] ฟังก์ชัน Aimbot (ESP)
local function updateESP()
    for _, box in pairs(espBoxes) do
        if box.Box then box.Box:Remove() end
        if box.Name then box.Name:Remove() end
    end
    espBoxes = {}

    if not aimbotEnabled or not isSafe then return end

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") and
           target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local head = target.Character:FindFirstChild("Head")
            if head then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Color = Color3.fromRGB(255, 255, 0)
                box.Thickness = 1.5
                box.Filled = false

                local nameLabel = Drawing.new("Text")
                nameLabel.Visible = false
                nameLabel.Color = Color3.fromRGB(255, 255, 255)
                nameLabel.Size = 14
                nameLabel.Center = true
                nameLabel.Outline = true

                table.insert(espBoxes, {Box = box, Name = nameLabel, Player = target})

                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if not aimbotEnabled or not isSafe or not target.Character or
                       not target.Character:FindFirstChild("HumanoidRootPart") or
                       not target.Character:FindFirstChild("Head") then
                        box.Visible = false
                        nameLabel.Visible = false
                        if connection then connection:Disconnect() end
                        return
                    end

                    local hrpPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                    if onScreen then
                        local headPos = Camera:WorldToScreenPoint(head.Position)
                        local name = string.sub(target.Name, 1, 16)

                        box.Size = Vector2.new(1800 / hrpPos.Z, 2700 / hrpPos.Z)
                        box.Position = Vector2.new(headPos.X - box.Size.X / 2, headPos.Y - box.Size.Y / 2)
                        box.Visible = true

                        nameLabel.Text = string.format("%s\n100000", name)
                        nameLabel.Position = Vector2.new(headPos.X, headPos.Y - box.Size.Y / 2 - 18)
                        nameLabel.Visible = true
                    else
                        box.Visible = false
                        nameLabel.Visible = false
                    end
                end)
            end
        end
    end
end

-- [18] ฟังก์ชัน Aimlock (สับปืนตาย)
local lastAimTime = 0
local function aimlock()
    if not aimlockEnabled or not isSafe or not player.Character or
       not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local currentTime = tick()
    if currentTime - lastAimTime < 0.1 + math.random(0, 0.05) then return end -- หน่วงเวลาเนียน
    lastAimTime = currentTime

    local closestPlayer = nil
    local closestDistance = math.huge
    local playerPos = player.Character.HumanoidRootPart.Position

    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("Head") and
           target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
            local headPos = target.Character.Head.Position
            local distance = (playerPos - headPos).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = target
            end
        end
    end

    if closestPlayer then
        local head = closestPlayer.Character:FindFirstChild("Head")
        if head then
            local headPos = head.Position + Vector3.new(
                math.random(-0.2, 0.2), -- offset เนียน
                math.random(-0.1, 0.1),
                math.random(-0.2, 0.2)
            )
            local targetCFrame = CFrame.new(Camera.CFrame.Position, headPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.3) -- Smoothing
            print("[DEBUG] Locked aim at: ", closestPlayer.Name)

            -- ปรับระยะสไนเปอร์
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool and tool.Name:lower():find("sniper") then
                pcall(function()
                    if tool:FindFirstChild("MaxDistance") then
                        tool.MaxDistance.Value = math.clamp(
                            tool.MaxDistance.Value * 1000,
                            0,
                            1000000
                        )
                    elseif tool:FindFirstChild("Configuration") then
                        local config = tool.Configuration
                        if config:FindFirstChild("Range") then
                            config.Range.Value = math.clamp(
                                config.Range.Value * 1000,
                                0,
                                1000000
                            )
                        end
                    end
                    print("[DEBUG] Increased sniper range for: ", tool.Name)
                end)
            end
        end
    end
end

-- [19] ฟังก์ชัน Rapid Switch (สับไว)
local currentTargetIndex = 1
local sortedPlayers = {}
local lastSwitchTime = 0
local function updateSortedPlayers()
    sortedPlayers = {}
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") and
           target.Character:FindFirstChild("Head") and target.Character.Humanoid.Health > 0 then
            table.insert(sortedPlayers, target)
        end
    end
    table.sort(sortedPlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    print("[DEBUG] Sorted players: ", #sortedPlayers)
end

local function rapidSwitch()
    if not rapidSwitchEnabled or not isSafe or not player.Character or
       not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local currentTime = tick()
    if currentTime - lastSwitchTime < 0.5 + math.random(0, 0.2) then return end -- หน่วงเวลาเนียน
    lastSwitchTime = currentTime

    updateSortedPlayers()
    if #sortedPlayers == 0 then
        print("[DEBUG] No valid targets for Rapid Switch")
        return
    end

    if currentTargetIndex > #sortedPlayers then
        currentTargetIndex = 1
    end
    local target = sortedPlayers[currentTargetIndex]
    if target and target.Character and target.Character:FindFirstChild("Head") and
       target.Character:FindFirstChild("HumanoidRootPart") then
        local targetHrp = target.Character.HumanoidRootPart
        local head = target.Character.Head

        -- วาร์ปด้านหลัง
        local behindPos = targetHrp.Position - targetHrp.CFrame.LookVector * (3 + math.random(-0.5, 0.5))
        pcall(function()
            player.Character.HumanoidRootPart.CFrame = CFrame.new(behindPos, head.Position)
        end)
        print("[DEBUG] Warped behind: ", target.Name)

        -- ล็อกเป้าที่หัว
        local headPos = head.Position + Vector3.new(
            math.random(-0.2, 0.2),
            math.random(-0.1, 0.1),
            math.random(-0.2, 0.2)
        )
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), 0.3)
        print("[DEBUG] Locked aim at: ", target.Name)

        currentTargetIndex = currentTargetIndex + 1
    end
end

-- [20] ควบคุม Aimbot
aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    aimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    print("[DEBUG] Aimbot: ", aimbotEnabled)
    if aimbotEnabled then
        updateESP()
    else
        for _, box in pairs(espBoxes) do
            if box.Box then box.Box:Remove() end
            if box.Name then box.Name:Remove() end
        end
        espBoxes = {}
    end
end)

-- [21] ควบคุม Aimlock
aimlockButton.MouseButton1Click:Connect(function()
    aimlockEnabled = not aimlockEnabled
    aimlockButton.Text = "Aimlock: " .. (aimlockEnabled and "ON" or "OFF")
    aimlockButton.BackgroundColor3 = aimlockEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    print("[DEBUG] Aimlock: ", aimlockEnabled)
end)

-- [22] ควบคุม Rapid Switch
rapidSwitchButton.MouseButton1Click:Connect(function()
    rapidSwitchEnabled = not rapidSwitchEnabled
    rapidSwitchButton.Text = "Rapid Switch: " .. (rapidSwitchEnabled and "ON" or "OFF")
    rapidSwitchButton.BackgroundColor3 = rapidSwitchEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    print("[DEBUG] Rapid Switch: ", rapidSwitchEnabled)
    currentTargetIndex = 1
end)

-- [23] ตรวจจับการคลิกสำหรับ Rapid Switch
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and rapidSwitchEnabled then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then
            rapidSwitch()
        else
            print("[WARNING] No tool equipped for Rapid Switch")
        end
    end
end)

-- [24] อัพเดททุกเฟรม
RunService.RenderStepped:Connect(function()
    checkAntiCheat()
    if aimbotEnabled and isSafe then
        updateESP()
    end
    if aimlockEnabled and isSafe then
        aimlock()
    end
end)

-- [25] อนิเมชัน UI
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenShow = TweenService:Create(mainFrame, tweenInfo, {
    BackgroundTransparency = 0.7,
    Position = UDim2.new(0.5, 0, 0.5, 0)
})
local tweenHide = TweenService:Create(mainFrame, tweenInfo, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 1.2, 0)
})
mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if mainFrame.Visible then
        mainFrame.Position = UDim2.new(0.5, 0, 0, 0)
        tweenShow:Play()
    else
        tweenHide:Play()
    end
end)

-- [26] ทำความสะอาดเมื่อออก
player.CharacterRemoving:Connect(function()
    for _, box in pairs(espBoxes) do
        if box.Box then box.Box:Remove() end
        if box.Name then box.Name:Remove() end
    end
    espBoxes = {}
end)