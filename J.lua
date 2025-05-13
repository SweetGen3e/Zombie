-- [1] นำเข้า Services ที่จำเป็น
local UserInputService = game:GetService("UserInputService") -- รับ input เช่น กด P หรือ G
local Players = game:GetService("Players") -- เข้าถึงข้อมูลผู้เล่น
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- สำหรับ client-server
local TeleportService = game:GetService("TeleportService") -- สำหรับ Rejoin
local PathfindingService = game:GetService("PathfindingService") -- สำหรับการเคลื่อนที่
local TweenService = game:GetService("TweenService") -- สำหรับอนิเมชัน
local RunService = game:GetService("RunService") -- สำหรับ NoClip

-- [2] กำหนดตัวแปรผู้เล่น
local player = Players.LocalPlayer -- ดึงผู้เล่นปัจจุบัน
local playerGui = player:WaitForChild("PlayerGui") -- รอ PlayerGui โหลด
print("[DEBUG] PlayerGui loaded: ", playerGui) -- ตรวจสอบการโหลด

-- [3] สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui") -- สร้าง ScreenGui สำหรับ UI
screenGui.Name = "ProUI" -- ตั้งชื่อ
screenGui.IgnoreGuiInset = true -- ไม่ให้แถบด้านบนบัง
screenGui.Parent = playerGui -- วางใน PlayerGui
print("[DEBUG] ScreenGui created: ", screenGui.Parent)

-- [4] สร้าง MainFrame (UI หลัก)
local mainFrame = Instance.new("Frame") -- สร้าง Frame หลัก
mainFrame.Size = UDim2.new(0.4, 0, 0.4, 0) -- ขนาด 40% ของหน้าจอ (ใหญ่ขึ้น)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- อยู่ตรงกลาง
mainFrame.BackgroundTransparency = 0.75 -- โปร่งใส 75%
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 255) -- สีน้ำเงิน
mainFrame.Visible = false -- ซ่อนเริ่มต้น
mainFrame.Parent = screenGui -- วางใน ScreenGui
print("[DEBUG] MainFrame created: ", mainFrame.Visible)

-- [5] เพิ่ม UICorner สำหรับมุมโค้ง
local uiCorner = Instance.new("UICorner") -- สร้าง UICorner
uiCorner.CornerRadius = UDim.new(0, 15) -- รัศมี 15 พิกเซล (ดูทันสมัย)
uiCorner.Parent = mainFrame

-- [6] เพิ่ม UIGradient สำหรับการไล่สี
local uiGradient = Instance.new("UIGradient") -- สร้างการไล่สี
uiGradient.Color = ColorSequence.new{ -- ไล่สีจากน้ำเงินเข้มถึงฟ้าอ่อน
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}
uiGradient.Rotation = 45 -- หมุนการไล่สี 45 องศา
uiGradient.Parent = mainFrame

-- [7] เพิ่ม UIStroke สำหรับขอบเรืองแสง
local uiStroke = Instance.new("UIStroke") -- สร้างขอบ
uiStroke.Thickness = 2 -- ความหนา 2 พิกเซล
uiStroke.Color = Color3.fromRGB(255, 255, 255) -- สีขาว (เรืองแสง)
uiStroke.Transparency = 0.5 -- โปร่งใสเล็กน้อย
uiStroke.Parent = mainFrame

-- [8] สร้างปุ่ม Toggle UI (ใช้ Emoji)
local toggleButton = Instance.new("TextButton") -- สร้างปุ่ม
toggleButton.Size = UDim2.new(0.1, 0, 0.05, 0) -- ขนาด 10% ความกว้าง, 5% ความสูง
toggleButton.Position = UDim2.new(0, 10, 0, 50) -- ลงมา 50 พิกเซลเพื่อกดง่าย
toggleButton.Text = "🟢" -- Emoji วงกลมเขียว (ปิด UI)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีพื้นหลังเขียว
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
toggleButton.TextScaled = true -- ปรับขนาด Emoji
toggleButton.Parent = screenGui -- วางใน ScreenGui
print("[DEBUG] ToggleButton created")

-- [9] ตัวแปรสถานะ UI
local isUIVisible = false -- เก็บสถานะ UI

-- [10] ฟังก์ชันสลับ UI
local function toggleUI()
    isUIVisible = not isUIVisible -- สลับสถานะ
    mainFrame.Visible = isUIVisible -- อัพเดทการแสดง
    toggleButton.Text = isUIVisible and "🔴" or "🟢" -- เปลี่ยน Emoji (แดงเมื่อเปิด, เขียวเมื่อปิด)
    print("[DEBUG] UI Visible: ", isUIVisible)
end

-- [11] เชื่อมต่อปุ่ม Toggle
toggleButton.MouseButton1Click:Connect(toggleUI) -- กดปุ่มเรียก toggleUI

-- [12] ตรวจจับการกด P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ข้ามถ้าพิมพ์ในแชท
    if input.KeyCode == Enum.KeyCode.P then -- ถ้ากด P
        toggleUI() -- สลับ UI
    end
end)

-- [13] ฟังก์ชัน NoClip
local isNoClip = false -- สถานะ NoClip
local noClipConnection -- เก็บการเชื่อมต่อ RunService
local function enableNoClip()
    if not player.Character then return end -- ถ้าไม่มี Character
    isNoClip = true -- เปิด NoClip
    print("[DEBUG] NoClip enabled")
    noClipConnection = RunService.Stepped:Connect(function()
        if not isNoClip or not player.Character then return end
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false -- ปิด collision
            end
        end
    end)
end

local function disableNoClip()
    if noClipConnection then
        noClipConnection:Disconnect() -- ยกเลิก RunService
        noClipConnection = nil
    end
    isNoClip = false -- ปิด NoClip
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
homeFrame.Size = UDim2.new(1, 0, 0.8, 0) -- ขนาด 80% ความสูงเพื่อให้มีที่ว่าง
homeFrame.Position = UDim2.new(0, 0, 0.2, 0) -- ลงมา 20% เพื่อให้ปุ่มหมวดหมู่อยู่ด้านบน
homeFrame.BackgroundTransparency = 1 -- โปร่งใส
homeFrame.Parent = mainFrame -- วางใน MainFrame
homeFrame.Visible = true -- แสดงเริ่มต้น
print("[DEBUG] HomeFrame created")

-- [15] เพิ่มลิงก์ Discord
local discordLabel = Instance.new("TextLabel") -- TextLabel สำหรับ Discord
discordLabel.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด
discordLabel.Position = UDim2.new(0.05, 0, 0.1, 0) -- ห่างจากขอบ
discordLabel.Text = "Discord: https://discord.gg/YmjS2Kh9" -- ลิงก์
discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
discordLabel.BackgroundTransparency = 1 -- โปร่งใส
discordLabel.TextScaled = true -- ปรับขนาดข้อความ
discordLabel.Parent = homeFrame -- วางใน HomeFrame
print("[DEBUG] DiscordLabel created")

-- [16] สร้างปุ่ม Sell All Fruits
local sellFruitButton = Instance.new("TextButton") -- ปุ่มสำหรับขายผลไม้
sellFruitButton.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด
sellFruitButton.Position = UDim2.new(0.05, 0, 0.3, 0) -- ห่างจากขอบ
sellFruitButton.Text = "Sell All Fruits" -- ข้อความ
sellFruitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
sellFruitButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
sellFruitButton.TextScaled = true -- ปรับขนาดข้อความ
sellFruitButton.Parent = homeFrame -- วางใน HomeFrame
print("[DEBUG] SellFruitButton created")

-- [17] เพิ่ม UIStroke ให้ปุ่ม Sell All Fruits
local sellButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
sellButtonStroke.Thickness = 1.5 -- ความหนา
sellButtonStroke.Color = Color3.fromRGB(255, 255, 255) -- สีขาว
sellButtonStroke.Transparency = 0.5 -- โปร่งใสเล็กน้อย
sellButtonStroke.Parent = sellFruitButton

-- [18] ฟังก์ชัน Sell All Fruits (เพิ่มระบบคุยอัตโนมัติ)
sellFruitButton.MouseButton1Click:Connect(function()
    -- [18.1] ตรวจสอบ Character และ Humanoid
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        print("[ERROR] Player character or Humanoid not loaded!")
        return
    end
    local humanoid = player.Character:FindFirstChild("Humanoid") -- ดึง Humanoid
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
                local rootPart = tree:FindFirstChild("HumanoidRootPart") or tree:FindFirstChildWhichIsA("BasePart")
                if rootPart and humanoid then
                    humanoid:MoveTo(rootPart.Position) -- เดินไป (ทะลุด้วย NoClip)
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
        if npc:IsA("Model") and npc.Name == "Steven" then
            steven = npc
            print("[DEBUG] Found Steven at: ", npc:GetFullName())
            break
        end
    end

    -- [18.7] ถ้าเจอ Steven
    if steven and steven:FindFirstChild("HumanoidRootPart") then
        -- [18.8] เดินไปหา Steven ด้วย NoClip
        humanoid:MoveTo(steven.HumanoidRootPart.Position) -- เดินตรงไป
        humanoid.MoveToFinished:Wait(2)
        print("[DEBUG] Moved to Steven")

        -- [18.9] ระบบคุยอัตโนมัติ
        local function interactWithNPC()
            local talkButton = steven:FindFirstChild("Talk", true)
            if talkButton then
                print("[DEBUG] Found Talk button: ", talkButton:GetFullName())
                local clickDetector = talkButton:FindFirstChildOfClass("ClickDetector")
                local prompt = talkButton:FindFirstChildOfClass("ProximityPrompt")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    print("[DEBUG] Fired ClickDetector for Talk")
                elseif prompt then
                    fireproximityprompt(prompt)
                    print("[DEBUG] Fired ProximityPrompt for Talk")
                else
                    print("[WARNING] No ClickDetector or ProximityPrompt for Talk!")
                    return false
                end
                wait(0.5) -- รอ DialogueGui

                -- [18.10] ค้นหา DialogueGui และกด #1
                local dialogueGui = player.PlayerGui:WaitForChild("DialogueGui", 2)
                if dialogueGui then
                    print("[DEBUG] Found DialogueGui: ", dialogueGui:GetFullName())
                    local optionButton = dialogueGui:FindFirstChild("#1", true)
                    if optionButton then
                        print("[DEBUG] Found option #1: ", optionButton:GetFullName())
                        local clickDetector = optionButton:FindFirstChildOfClass("ClickDetector")
                        local prompt = optionButton:FindFirstChildOfClass("ProximityPrompt")
                        if clickDetector then
                            fireclickdetector(clickDetector)
                            print("[DEBUG] Fired ClickDetector for option #1")
                        elseif prompt then
                            fireproximityprompt(prompt)
                            print("[DEBUG] Fired ProximityPrompt for option #1")
                        else
                            print("[WARNING] No ClickDetector or ProximityPrompt for option #1!")
                            return false
                        end
                    else
                        print("[WARNING] Option #1 not found!")
                        return false
                    end
                else
                    print("[WARNING] DialogueGui not found!")
                    return false
                end
                return true
            else
                print("[WARNING] Talk button not found!")
                return false
            end
        end

        -- [18.11] ลองคุยซ้ำจนสำเร็จ (กรณี DialogueGui โหลดช้า)
        local maxAttempts = 3 -- ลองสูงสุด 3 ครั้ง
        local attempt = 1
        while attempt <= maxAttempts do
            print("[DEBUG] Attempting NPC interaction, attempt ", attempt)
            if interactWithNPC() then
                break -- สำเร็จแล้ว ออกจากลูป
            end
            wait(1) -- รอ 1 วินาทีก่อนลองใหม่
            attempt = attempt + 1
        end
        if attempt > maxAttempts then
            print("[ERROR] Failed to interact with NPC after ", maxAttempts, " attempts")
        end
    else
        print("[ERROR] Steven or HumanoidRootPart not found!")
    end

    -- [18.12] ปิด NoClip
    disableNoClip()
end)

-- [19] สร้างหมวด Teleport
local teleportFrame = Instance.new("Frame") -- Frame สำหรับ Teleport
teleportFrame.Size = UDim2.new(1, 0, 0.8, 0) -- ขนาด 80% ความสูง
teleportFrame.Position = UDim2.new(0, 0, 0.2, 0) -- ลงมา 20%
teleportFrame.BackgroundTransparency = 1 -- โปร่งใส
teleportFrame.Parent = mainFrame -- วางใน MainFrame
teleportFrame.Visible = false -- ซ่อนเริ่มต้น
print("[DEBUG] TeleportFrame created")

-- [20] เพิ่มข้อความ Teleport
local teleportLabel = Instance.new("TextLabel") -- TextLabel สำหรับ Teleport
teleportLabel.Size = UDim2.new(0.9, 0, 0.5, 0) -- ขนาด
teleportLabel.Position = UDim2.new(0.05, 0, 0.25, 0) -- ห่างจากขอบ
teleportLabel.Text = "ผู้พัฒนากำลังทำฟังก์ชันนี้ โปรดรอ" -- ข้อความ
teleportLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
teleportLabel.BackgroundTransparency = 1 -- โปร่งใส
teleportLabel.TextScaled = true -- ปรับขนาดข้อความ
teleportLabel.Parent = teleportFrame -- วางใน TeleportFrame
print("[DEBUG] TeleportLabel created")

-- [21] สร้างหมวด Settings
local settingsFrame = Instance.new("Frame") -- Frame สำหรับ Settings
settingsFrame.Size = UDim2.new(1, 0, 0.8, 0) -- ขนาด 80% ความสูง
settingsFrame.Position = UDim2.new(0, 0, 0.2, 0) -- ลงมา 20%
settingsFrame.BackgroundTransparency = 1 -- โปร่งใส
settingsFrame.Parent = mainFrame -- วางใน MainFrame
settingsFrame.Visible = false -- ซ่อนเริ่มต้น
print("[DEBUG] SettingsFrame created")

-- [22] สร้างปุ่ม Rejoin
local rejoinButton = Instance.new("TextButton") -- ปุ่ม Rejoin
rejoinButton.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด
rejoinButton.Position = UDim2.new(0.05, 0, 0.1, 0) -- ห่างจากขอบ
rejoinButton.Text = "Rejoin" -- ข้อความ
rejoinButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
rejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
rejoinButton.TextScaled = true -- ปรับขนาดข้อความ
rejoinButton.Parent = settingsFrame -- วางใน SettingsFrame
print("[DEBUG] RejoinButton created")

-- [23] เพิ่ม UIStroke ให้ปุ่ม Rejoin
local rejoinButtonStroke = Instance.new("UIStroke") -- ขอบเรืองแสง
rejoinButtonStroke.Thickness = 1.5 -- ความหนา
rejoinButtonStroke.Color = Color3.fromRGB(255, 255, 255) -- สีขาว
rejoinButtonStroke.Transparency = 0.5 -- โปร่งใส
rejoinButtonStroke.Parent = rejoinButton

-- [24] ฟังก์ชัน Rejoin
rejoinButton.MouseButton1Click:Connect(function()
    print("[DEBUG] Attempting to rejoin...")
    TeleportService:Teleport(game.PlaceId, player) -- รีเกม
end)

-- [25] ตรวจจับการกด G สำหรับ Rejoin
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ข้ามถ้าพิมพ์
    if input.KeyCode == Enum.KeyCode.G then
        print("[DEBUG] Rejoining via G key...")
        TeleportService:Teleport(game.PlaceId, player) -- รีเกม
    end
end)

-- [26] สร้างปุ่มสลับหมวดหมู่
local homeButton = Instance.new("TextButton") -- ปุ่ม Home
homeButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด
homeButton.Position = UDim2.new(0, 0, 0, 0) -- มุมซ้ายบน
homeButton.Text = "Home" -- ข้อความ
homeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
homeButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
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
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
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
settingsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
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

-- [28] เพิ่มอนิเมชัน UI (Slide และ Fade)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) -- อนิเมชัน 0.5 วินาที
local tweenShow = TweenService:Create(mainFrame, tweenInfo, {
    BackgroundTransparency = 0.75, -- โปร่งใส 75%
    Position = UDim2.new(0.5, 0, 0.5, 0) -- ตำแหน่งปกติ
})
local tweenHide = TweenService:Create(mainFrame, tweenInfo, {
    BackgroundTransparency = 1, -- ซ่อน
    Position = UDim2.new(0.5, 0, 1, 0) -- เลื่อนลง
})
mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if mainFrame.Visible then
        mainFrame.Position = UDim2.new(0.5, 0, 0, 0) -- เริ่มจากด้านบน
        tweenShow:Play() -- เล่นอนิเมชันแสดง
    else
        tweenHide:Play() -- เล่นอนิเมชันซ่อน
    end
end)