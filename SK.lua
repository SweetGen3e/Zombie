-- [1] นำเข้า Services
local UserInputService = game:GetService("UserInputService") -- รับ input
local Players = game:GetService("Players") -- ข้อมูลผู้เล่น
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- client-server
local TeleportService = game:GetService("TeleportService") -- Rejoin
local RunService = game:GetService("RunService") -- NoClip
local TweenService = game:GetService("TweenService") -- อนิเมชัน

-- [2] กำหนดตัวแปรผู้เล่น
local player = Players.LocalPlayer -- ผู้เล่นปัจจุบัน
local playerGui = player:WaitForChild("PlayerGui") -- รอ PlayerGui
print("[DEBUG] PlayerGui loaded: ", playerGui)

-- [3] สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui") -- UI หลัก
screenGui.Name = "ProUI" -- ชื่อ
screenGui.IgnoreGuiInset = true -- ไม่ให้แถบด้านบนบัง
screenGui.Parent = playerGui -- วางใน PlayerGui
print("[DEBUG] ScreenGui created: ", screenGui.Parent)

-- [4] สร้าง MainFrame
local mainFrame = Instance.new("Frame") -- Frame หลัก
mainFrame.Size = UDim2.new(0.4, 0, 0.4, 0) -- 40% ของหน้าจอ
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- ตรงกลาง
mainFrame.BackgroundTransparency = 0.75 -- โปร่งใส 75%
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 255) -- น้ำเงิน
mainFrame.Visible = false -- ซ่อนเริ่มต้น
mainFrame.Parent = screenGui -- วางใน ScreenGui
print("[DEBUG] MainFrame created: ", mainFrame.Visible)

-- [5] เพิ่ม UICorner
local uiCorner = Instance.new("UICorner") -- มุมโค้ง
uiCorner.CornerRadius = UDim.new(0, 15) -- รัศมี 15
uiCorner.Parent = mainFrame

-- [6] เพิ่ม UIGradient
local uiGradient = Instance.new("UIGradient") -- การไล่สี
uiGradient.Color = ColorSequence.new{ -- น้ำเงินเข้มถึงฟ้าอ่อน
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}
uiGradient.Rotation = 45 -- หมุน 45 องศา
uiGradient.Parent = mainFrame

-- [7] เพิ่ม UIStroke
local uiStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
uiStroke.Thickness = 2 -- ความหนา
uiStroke.Color = Color3.fromRGB(255, 255, 255) -- ขาว
uiStroke.Transparency = 0.5 -- โปร่งใสเล็กน้อย
uiStroke.Parent = mainFrame

-- [8] สร้างปุ่ม Toggle UI
local toggleButton = Instance.new("TextButton") -- ปุ่ม Toggle
toggleButton.Size = UDim2.new(0.1, 0, 0.05, 0) -- ขนาด
toggleButton.Position = UDim2.new(0, 10, 0, 50) -- ลงมา 50 พิกเซล
toggleButton.Text = "🟢" -- Emoji วงกลมเขียว
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- เขียว
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
toggleButton.TextScaled = true -- ปรับขนาด Emoji
toggleButton.Parent = screenGui -- วางใน ScreenGui
print("[DEBUG] ToggleButton created")

-- [9] ตัวแปรสถานะ UI
local isUIVisible = false -- สถานะ UI

-- [10] ฟังก์ชันสลับ UI
local function toggleUI()
    isUIVisible = not isUIVisible -- สลับสถานะ
    mainFrame.Visible = isUIVisible -- อัพเดทการแสดง
    toggleButton.Text = isUIVisible and "🔴" or "🟢" -- เปลี่ยน Emoji
    print("[DEBUG] UI Visible: ", isUIVisible)
end

-- [11] เชื่อมต่อปุ่ม Toggle
toggleButton.MouseButton1Click:Connect(toggleUI)

-- [12] ตรวจจับการกด P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ข้ามถ้าพิมพ์
    if input.KeyCode == Enum.KeyCode.P then -- ถ้ากด P
        toggleUI()
    end
end)

-- [13] ฟังก์ชัน NoClip
local isNoClip = false -- สถานะ NoClip
local noClipConnection -- เก็บการเชื่อมต่อ
local function enableNoClip()
    if not player.Character then return end
    isNoClip = true
    print("[DEBUG] NoClip enabled")
    noClipConnection = RunService.Stepped:Connect(function()
        if not isNoClip or not player.Character then return end
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false -- ปิด collision
                print("[DEBUG] Setting CanCollide to false for: ", part.Name)
            end
        end
    end)
end

local function disableNoClip()
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    isNoClip = false
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true -- เปิด collision
            end
        end
    end
    print("[DEBUG] NoClip disabled")
end

-- [14] สร้างหมวด Home
local homeFrame = Instance.new("Frame") -- Frame สำหรับ Home
homeFrame.Size = UDim2.new(1, 0, 0.8, 0) -- ขนาด 80% ความสูง
homeFrame.Position = UDim2.new(0, 0, 0.2, 0) -- ลงมา 20%
homeFrame.BackgroundTransparency = 1 -- โปร่งใส
homeFrame.Parent = mainFrame -- วางใน MainFrame
homeFrame.Visible = true -- แสดงเริ่มต้น
print("[DEBUG] HomeFrame created")

-- [15] เพิ่มลิงก์ Discord
local discordLabel = Instance.new("TextLabel") -- TextLabel สำหรับ Discord
discordLabel.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด
discordLabel.Position = UDim2.new(0.05, 0, 0.1, 0) -- ห่างจากขอบ
discordLabel.Text = "Discord: https://discord.gg/YmjS2Kh9" -- ลิงก์
discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
discordLabel.BackgroundTransparency = 1 -- โปร่งใส
discordLabel.TextScaled = true -- ปรับขนาดข้อความ
discordLabel.Parent = homeFrame -- วางใน HomeFrame
print("[DEBUG] DiscordLabel created")

-- [16] สร้างปุ่ม Sell All Fruits
local sellFruitButton = Instance.new("TextButton") -- ปุ่มขายผลไม้
sellFruitButton.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด
sellFruitButton.Position = UDim2.new(0.05, 0, 0.3, 0) -- ห่างจากขอบ
sellFruitButton.Text = "Sell All Fruits" -- ข้อความ
sellFruitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- เขียว
sellFruitButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
sellFruitButton.TextScaled = true -- ปรับขนาดข้อความ
sellFruitButton.Parent = homeFrame -- วางใน HomeFrame
print("[DEBUG] SellFruitButton created")

-- [17] เพิ่ม UIStroke ให้ปุ่ม Sell All Fruits
local sellButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
sellButtonStroke.Thickness = 1.5
sellButtonStroke.Color = Color3.fromRGB(255, 255, 255)
sellButtonStroke.Transparency = 0.5
sellButtonStroke.Parent = sellFruitButton

-- [18] ฟังก์ชัน Sell All Fruits (ปรับปรุงการคุยกับ NPC)
sellFruitButton.MouseButton1Click:Connect(function()
    -- [18.1] ตรวจสอบ Character และ Humanoid
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        print("[ERROR] Player character or Humanoid not loaded!")
        return
    end
    local humanoid = player.Character:FindFirstChild("Humanoid") -- ดึง Humanoid
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart") -- ดึง RootPart
    if not rootPart then
        print("[ERROR] HumanoidRootPart not found!")
        return
    end
    print("[DEBUG] Starting fruit collection...")

    -- [18.2] เปิด NoClip
    enableNoClip()

    -- [18.3] วนลูปหาต้นไม้ที่มีปุ่ม Collect
    for _, tree in pairs(workspace:GetDescendants()) do
        if tree:IsA("Model") then
            local collectButton = tree:FindFirstChild("Collect", true)
            if collectButton then
                print("[DEBUG] Found Collect button in: ", tree:GetFullName())
                -- [18.4] เดินไปหาต้นไม้
                local treePart = tree:FindFirstChild("HumanoidRootPart") or tree:FindFirstChildWhichIsA("BasePart")
                if treePart and humanoid then
                    humanoid:MoveTo(treePart.Position) -- เดินไป
                    humanoid.MoveToFinished:Wait(2) -- รอ 2 วินาที
                end
                -- [18.5] ตรวจสอบ ClickDetector หรือ ProximityPrompt
                local clickDetector = collectButton:FindFirstChildOfClass("ClickDetector")
                local prompt = collectButton:FindFirstChildOfClass("ProximityPrompt")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    print("[DEBUG] Fired ClickDetector for Collect")
                    wait(0.2)
                elseif prompt then
                    fireproximityprompt(prompt)
                    print("[DEBUG] Fired ProximityPrompt for Collect")
                    wait(0.2)
                else
                    print("[WARNING] No ClickDetector or ProximityPrompt in: ", collectButton:GetFullName())
                end
            end
        end
    end

    -- [18.6] ค้นหา NPC Steven
    print("[DEBUG] Looking for Steven...")
    local steven
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and (npc.Name == "Steven" or npc.Name:find("Dealer") or npc.Name:find("Shop")) then
            steven = npc
            print("[DEBUG] Found NPC at: ", npc:GetFullName())
            break
        end
    end

    -- [18.7] ถ้าเจอ Steven
    if steven and steven:FindFirstChild("HumanoidRootPart") then
        -- [18.8] เดินเข้าใกล้ Steven (ระยะ 3  Rutherford)
        local npcPos = steven.HumanoidRootPart.Position
        local approachPos = npcPos - Vector3.new(0, 0, 3) -- เข้าใกล้ 3 หน่วย
        humanoid:MoveTo(approachPos)
        humanoid.MoveToFinished:Wait(2)
        print("[DEBUG] Moved to Steven, distance: ", (rootPart.Position - npcPos).Magnitude)

        -- [18.9] ฟังก์ชันคุยกับ NPC
        local function interactWithNPC()
            -- ตรวจสอบปุ่ม Talk, Interact, หรือ Speak
            local talkButton
            for _, name in pairs({"Talk", "Interact", "Speak"}) do
                talkButton = steven:FindFirstChild(name, true)
                if talkButton then
                    print("[DEBUG] Found interaction button: ", talkButton:GetFullName())
                    break
                end
            end

            if talkButton then
                -- ลอง ClickDetector
                local clickDetector = talkButton:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    print("[DEBUG] Fired ClickDetector for interaction")
                end

                -- ลอง ProximityPrompt (กด E)
                local prompt = talkButton:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local promptFired = false
                    for i = 1, 3 do -- ลองกด E 3 ครั้ง
                        fireproximityprompt(prompt)
                        print("[DEBUG] Fired ProximityPrompt for interaction, attempt ", i)
                        wait(0.3)
                        if player.PlayerGui:FindFirstChild("DialogueGui", true) then
                            promptFired = true
                            break
                        end
                    end
                    if not promptFired then
                        print("[WARNING] ProximityPrompt did not trigger DialogueGui")
                    end
                end

                -- ลอง RemoteEvent (ถ้ามี)
                local talkEvent = ReplicatedStorage:FindFirstChild("TalkEvent") or
                                  ReplicatedStorage:FindFirstChild("InteractEvent") or
                                  ReplicatedStorage:FindFirstChild("DialogueEvent")
                if talkEvent then
                    talkEvent:FireServer()
                    print("[DEBUG] Fired RemoteEvent for interaction")
                end

                if not clickDetector and not prompt and not talkEvent then
                    print("[WARNING] No ClickDetector, ProximityPrompt, or RemoteEvent found!")
                    return false
                end

                -- [18.10] รอ DialogueGui
                local dialogueGui
                local waitTime = 0
                local maxWait = 7 -- รอ 7 วินาที
                while waitTime < maxWait and not dialogueGui do
                    dialogueGui = player.PlayerGui:FindFirstChildWhichIsA("ScreenGui", true)
                    for _, gui in pairs(player.PlayerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and (gui.Name:find("Dialogue") or gui.Name:find("Trade") or gui.Name:find("NPC")) then
                            dialogueGui = gui
                            break
                        end
                    end
                    wait(0.5)
                    waitTime = waitTime + 0.5
                    print("[DEBUG] Waiting for DialogueGui, elapsed: ", waitTime, "s")
                end

                if dialogueGui then
                    print("[DEBUG] Found DialogueGui: ", dialogueGui:GetFullName())
                    -- [18.11] ค้นหาตัวเลือกที่ตรงกับ "sell.*inventory" หรือชื่ออื่น
                    local optionButton
                    for _, child in pairs(dialogueGui:GetDescendants()) do
                        if child:IsA("TextButton") or child:IsA("TextLabel") then
                            local text = string.lower(child.Text)
                            if text:find("sell.*inventory") or text:find("sellall") or text:find("trade") or child.Name == "#1" then
                                optionButton = child
                                print("[DEBUG] Found sell option: ", optionButton:GetFullName(), " Text: ", child.Text)
                                break
                            end
                        end
                    end

                    if optionButton then
                        local clickDetector = optionButton:FindFirstChildOfClass("ClickDetector")
                        local prompt = optionButton:FindFirstChildOfClass("ProximityPrompt")
                        if clickDetector then
                            fireclickdetector(clickDetector)
                            print("[DEBUG] Fired ClickDetector for sell option")
                        elseif prompt then
                            fireproximityprompt(prompt)
                            print("[DEBUG] Fired ProximityPrompt for sell option")
                        else
                            -- ลองกดผ่าน RemoteEvent
                            local sellEvent = ReplicatedStorage:FindFirstChild("SellEvent") or
                                              ReplicatedStorage:FindFirstChild("TradeEvent")
                            if sellEvent then
                                sellEvent:FireServer()
                                print("[DEBUG] Fired RemoteEvent for sell option")
                            else
                                print("[WARNING] No ClickDetector, ProximityPrompt, or RemoteEvent for sell option!")
                                return false
                            end
                        end
                    else
                        print("[WARNING] Sell option not found in DialogueGui!")
                        return false
                    end
                else
                    print("[WARNING] DialogueGui not found after ", maxWait, " seconds!")
                    return false
                end
                return true
            else
                print("[WARNING] Interaction button (Talk/Interact/Speak) not found!")
                return false
            end
        end

        -- [18.12] ลองคุยซ้ำจนสำเร็จ
        local maxAttempts = 7 -- ลอง 7 ครั้ง
        local attempt = 1
        while attempt <= maxAttempts do
            print("[DEBUG] Attempting NPC interaction, attempt ", attempt)
            if interactWithNPC() then
                break -- สำเร็จ
            end
            -- เข้าใกล้ NPC อีกครั้งก่อนลองใหม่
            local approachPos = steven.HumanoidRootPart.Position - Vector3.new(0, 0, 3)
            humanoid:MoveTo(approachPos)
            humanoid.MoveToFinished:Wait(2)
            print("[DEBUG] Retried moving to Steven, attempt ", attempt)
            wait(1) -- รอ 1 วินาที
            attempt = attempt + 1
        end
        if attempt > maxAttempts then
            print("[ERROR] Failed to interact with NPC after ", maxAttempts, " attempts")
        end
    else
        print("[ERROR] Steven or similar NPC or HumanoidRootPart not found!")
    end

    -- [18.13] ปิด NoClip
    disableNoClip()
end)

-- [19] สร้างหมวด Teleport
local teleportFrame = Instance.new("Frame") -- Frame สำหรับ Teleport
teleportFrame.Size = UDim2.new(1, 0, 0.8, 0) -- ขนาด
teleportFrame.Position = UDim2.new(0, 0, 0.2, 0) -- ลงมา 20%
teleportFrame.BackgroundTransparency = 1 -- โปร่งใส
teleportFrame.Parent = mainFrame -- วางใน MainFrame
teleportFrame.Visible = false -- ซ่อน
print("[DEBUG] TeleportFrame created")

-- [20] เพิ่มข้อความ Teleport
local teleportLabel = Instance.new("TextLabel") -- TextLabel สำหรับ Teleport
teleportLabel.Size = UDim2.new(0.9, 0, 0.5, 0) -- ขนาด
teleportLabel.Position = UDim2.new(0.05, 0, 0.25, 0) -- ห่างจากขอบ
teleportLabel.Text = "ผู้พัฒนากำลังทำฟังก์ชันนี้ โปรดรอ" -- ข้อความ
teleportLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
teleportLabel.BackgroundTransparency = 1 -- โปร่งใส
teleportLabel.TextScaled = true -- ปรับขนาดข้อความ
teleportLabel.Parent = teleportFrame -- วางใน TeleportFrame
print("[DEBUG] TeleportLabel created")

-- [21] สร้างหมวด Settings
local settingsFrame = Instance.new("Frame") -- Frame สำหรับ Settings
settingsFrame.Size = UDim2.new(1, 0, 0.8, 0) -- ขนาด
settingsFrame.Position = UDim2.new(0, 0, 0.2, 0) -- ลงมา 20%
settingsFrame.BackgroundTransparency = 1 -- โปร่งใส
settingsFrame.Parent = mainFrame -- วางใน MainFrame
settingsFrame.Visible = false -- ซ่อน
print("[DEBUG] SettingsFrame created")

-- [22] สร้างปุ่ม Rejoin
local rejoinButton = Instance.new("TextButton") -- ปุ่ม Rejoin
rejoinButton.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด
rejoinButton.Position = UDim2.new(0.05, 0, 0.1, 0) -- ห่างจากขอบ
rejoinButton.Text = "Rejoin" -- ข้อความ
rejoinButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- เขียว
rejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
rejoinButton.TextScaled = true -- ปรับขนาดข้อความ
rejoinButton.Parent = settingsFrame -- วางใน SettingsFrame
print("[DEBUG] RejoinButton created")

-- [23] เพิ่ม UIStroke ให้ปุ่ม Rejoin
local rejoinButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
rejoinButtonStroke.Thickness = 1.5
rejoinButtonStroke.Color = Color3.fromRGB(255, 255, 255)
rejoinButtonStroke.Transparency = 0.5
rejoinButtonStroke.Parent = rejoinButton

-- [24] ฟังก์ชัน Rejoin
rejoinButton.MouseButton1Click:Connect(function()
    print("[DEBUG] Attempting to rejoin...")
    TeleportService:Teleport(game.PlaceId, player) -- รีเกม
end)

-- [25] ตรวจจับการกด G
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        print("[DEBUG] Rejoining via G key...")
        TeleportService:Teleport(game.PlaceId, player)
    end
end)

-- [26] สร้างปุ่มสลับหมวดหมู่
local homeButton = Instance.new("TextButton") -- ปุ่ม Home
homeButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด
homeButton.Position = UDim2.new(0, 0, 0, 0) -- มุมซ้ายบน
homeButton.Text = "Home" -- ข้อความ
homeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- เขียว
homeButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
homeButton.TextScaled = true -- ปรับขนาดข้อความ
homeButton.Parent = mainFrame -- วางใน MainFrame
print("[DEBUG] HomeButton created")

local homeButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
homeButtonStroke.Thickness = 1.5
homeButtonStroke.Color = Color3.fromRGB(255, 255, 255)
homeButtonStroke.Transparency = 0.5
homeButtonStroke.Parent = homeButton

local teleportButton = Instance.new("TextButton") -- ปุ่ม Teleport
teleportButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด
teleportButton.Position = UDim2.new(0.3, 0, 0, 0) -- ตรงกลางด้านบน
teleportButton.Text = "Teleport" -- ข้อความ
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- เขียว
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
teleportButton.TextScaled = true -- ปรับขนาดข้อความ
teleportButton.Parent = mainFrame -- วางใน MainFrame
print("[DEBUG] TeleportButton created")

local teleportButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
teleportButtonStroke.Thickness = 1.5
teleportButtonStroke.Color = Color3.fromRGB(255, 255, 255)
teleportButtonStroke.Transparency = 0.5
teleportButtonStroke.Parent = teleportButton

local settingsButton = Instance.new("TextButton") -- ปุ่ม Settings
settingsButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด
settingsButton.Position = UDim2.new(0.6, 0, 0, 0) -- มุมขวาบน
settingsButton.Text = "Settings" -- ข้อความ
settingsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- เขียว
settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- ขาว
settingsButton.TextScaled = true -- ปรับขนาดข้อความ
settingsButton.Parent = mainFrame -- วางใน MainFrame
print("[DEBUG] SettingsButton created")

local settingsButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
settingsButtonStroke.Thickness = 1.5
settingsButtonStroke.Color = Color3.fromRGB(255, 255, 255)
settingsButtonStroke.Transparency = 0.5
settingsButtonStroke.Parent = settingsButton

-- [27] ฟังก์ชันสลับหมวดหมู่
homeButton.MouseButton1Click:Connect(function()
    homeFrame.Visible = true -- แสดง Home
    teleportFrame.Visible = false -- ซ่อน Teleport
    settingsFrame.Visible = false -- ซ่อน Settings
    print("[DEBUG] Switched to Home")
end)

teleportButton.MouseButton1Click:Connect(function()
    homeFrame.Visible = false -- ซ่อน Home
    teleportFrame.Visible = true -- แสดง Teleport
    settingsFrame.Visible = false -- ซ่อน Settings
    print("[DEBUG] Switched to Teleport")
end)

settingsButton.MouseButton1Click:Connect(function()
    homeFrame.Visible = false -- ซ่อน Home
    teleportFrame.Visible = false -- ซ่อน Teleport
    settingsFrame.Visible = true -- แสดง Settings
    print("[DEBUG] Switched to Settings")
end)

-- [28] เพิ่มอนิเมชัน UI
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local tweenShow = TweenService:Create(mainFrame, tweenInfo, {
    BackgroundTransparency = 0.75,
    Position = UDim2.new(0.5, 0, 0.5, 0)
})
local tweenHide = TweenService:Create(mainFrame, tweenInfo, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 1, 0)
})
mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if mainFrame.Visible then
        mainFrame.Position = UDim2.new(0.5, 0, 0, 0)
        tweenShow:Play()
    else
        tweenHide:Play()
    end
end)