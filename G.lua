-- [1] นำเข้า Services ที่จำเป็น
local UserInputService = game:GetService("UserInputService") -- รับ input เช่น การกดคีย์ P หรือ G
local Players = game:GetService("Players") -- เข้าถึงข้อมูลผู้เล่น
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- สำหรับการสื่อสาร client-server
local TeleportService = game:GetService("TeleportService") -- สำหรับ Rejoin
local PathfindingService = game:GetService("PathfindingService") -- สำหรับการเคลื่อนที่แบบสมจริง
local TweenService = game:GetService("TweenService") -- สำหรับอนิเมชัน UI
local RunService = game:GetService("RunService") -- สำหรับ NoClip (ตรวจสอบทุก frame)

-- [2] กำหนดตัวแปรผู้เล่น
local player = Players.LocalPlayer -- ดึงข้อมูลผู้เล่นปัจจุบัน
local playerGui = player:WaitForChild("PlayerGui") -- รอ PlayerGui โหลด
print("[DEBUG] PlayerGui loaded: ", playerGui) -- แสดงว่า PlayerGui โหลดสำเร็จ

-- [3] สร้าง ScreenGui (หน้าจอ UI หลัก)
local screenGui = Instance.new("ScreenGui") -- สร้าง ScreenGui สำหรับ UI
screenGui.Name = "ProUI" -- ตั้งชื่อเพื่อระบุ
screenGui.IgnoreGuiInset = true -- ไม่ให้แถบด้านบน Roblox บัง UI
screenGui.Parent = playerGui -- วางใน PlayerGui
print("[DEBUG] ScreenGui created: ", screenGui.Parent) -- ตรวจสอบการสร้าง

-- [4] สร้าง MainFrame (UI หลัก)
local mainFrame = Instance.new("Frame") -- สร้าง Frame สำหรับ UI
mainFrame.Size = UDim2.new(0.25, 0, 0.25, 0) -- ขนาด 1/4 หน้าจอ
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- อยู่ตรงกลาง
mainFrame.BackgroundTransparency = 0.75 -- โปร่งใส 75%
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 255) -- สีน้ำเงิน
mainFrame.Visible = false -- ซ่อน UI เริ่มต้น
mainFrame.Parent = screenGui -- วางใน ScreenGui
print("[DEBUG] MainFrame created: ", mainFrame.Visible) -- ตรวจสอบการสร้าง

-- [5] เพิ่ม UICorner สำหรับมุมโค้ง
local uiCorner = Instance.new("UICorner") -- สร้าง UICorner
uiCorner.CornerRadius = UDim.new(0, 10) -- รัศมี 10 พิกเซล
uiCorner.Parent = mainFrame -- วางใน MainFrame

-- [6] สร้างปุ่ม Toggle UI
local toggleButton = Instance.new("TextButton") -- สร้างปุ่มสำหรับเปิด/ปิด UI
toggleButton.Size = UDim2.new(0.1, 0, 0.05, 0) -- ขนาด 10% ความกว้าง, 5% ความสูง
toggleButton.Position = UDim2.new(0, 10, 0, 10) -- มุมซ้ายบน
toggleButton.Text = "Toggle UI" -- ข้อความบนปุ่ม
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีข้อความขาว
toggleButton.Parent = screenGui -- วางใน ScreenGui
print("[DEBUG] ToggleButton created") -- ตรวจสอบการสร้าง

-- [7] ตัวแปรสถานะ UI
local isUIVisible = false -- เก็บสถานะ UI (แสดง/ซ่อน)

-- [8] ฟังก์ชันสลับ UI
local function toggleUI()
    isUIVisible = not isUIVisible -- สลับสถานะ
    mainFrame.Visible = isUIVisible -- อัพเดทการแสดงผล
    print("[DEBUG] UI Visible: ", isUIVisible) -- แสดงสถานะ
end

-- [9] เชื่อมต่อปุ่ม Toggle
toggleButton.MouseButton1Click:Connect(toggleUI) -- กดปุ่มเรียก toggleUI

-- [10] ตรวจจับการกด P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ข้ามถ้ากำลังพิมพ์
    if input.KeyCode == Enum.KeyCode.P then -- ถ้ากด P
        toggleUI() -- สลับ UI
    end
end)

-- [11] ฟังก์ชัน NoClip (เดินทะลุทุกสิ่ง)
local isNoClip = false -- ตัวแปรเก็บสถานะ NoClip
local noClipConnection -- ตัวแปรเก็บการเชื่อมต่อ RunService
local function enableNoClip()
    if not player.Character then return end -- ถ้าไม่มี Character ให้ข้าม
    isNoClip = true -- เปิดสถานะ NoClip
    print("[DEBUG] NoClip enabled")
    noClipConnection = RunService.Stepped:Connect(function()
        if not isNoClip or not player.Character then return end -- ถ้าปิด NoClip หรือไม่มี Character
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false -- ปิดการ collision ของทุกส่วน
            end
        end
    end)
end

local function disableNoClip()
    if noClipConnection then
        noClipConnection:Disconnect() -- ยกเลิกการเชื่อมต่อ RunService
        noClipConnection = nil
    end
    isNoClip = false -- ปิดสถานะ NoClip
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true -- เปิดการ collision กลับ
            end
        end
    end
    print("[DEBUG] NoClip disabled")
end

-- [12] สร้างหมวด Home
local homeFrame = Instance.new("Frame") -- Frame สำหรับหมวด Home
homeFrame.Size = UDim2.new(1, 0, 1, 0) -- ขนาดเต็ม MainFrame
homeFrame.BackgroundTransparency = 1 -- โปร่งใส
homeFrame.Parent = mainFrame -- วางใน MainFrame
homeFrame.Visible = true -- แสดงเริ่มต้น
print("[DEBUG] HomeFrame created")

-- [13] เพิ่มลิงก์ Discord
local discordLabel = Instance.new("TextLabel") -- TextLabel สำหรับ Discord
discordLabel.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด 90% ความกว้าง, 20% ความสูง
discordLabel.Position = UDim2.new(0.05, 0, 0.1, 0) -- ห่างจากขอบ
discordLabel.Text = "Discord: https://discord.gg/YmjS2Kh9" -- ลิงก์ Discord
discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
discordLabel.BackgroundTransparency = 1 -- โปร่งใส
discordLabel.TextScaled = true -- ปรับขนาดข้อความ
discordLabel.Parent = homeFrame -- วางใน HomeFrame
print("[DEBUG] DiscordLabel created")

-- [14] สร้างปุ่ม Sell All Fruits
local sellFruitButton = Instance.new("TextButton") -- ปุ่มสำหรับขายผลไม้
sellFruitButton.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด 90% ความกว้าง, 20% ความสูง
sellFruitButton.Position = UDim2.new(0.05, 0, 0.3, 0) -- ห่างจากขอบ
sellFruitButton.Text = "Sell All Fruits" -- ข้อความบนปุ่ม
sellFruitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
sellFruitButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
sellFruitButton.Parent = homeFrame -- วางใน HomeFrame
print("[DEBUG] SellFruitButton created")

-- [15] ฟังก์ชัน Sell All Fruits (เพิ่ม NoClip)
sellFruitButton.MouseButton1Click:Connect(function()
    -- [15.1] ตรวจสอบ Character และ Humanoid
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then
        print("[ERROR] Player character or Humanoid not loaded!")
        return
    end
    local humanoid = player.Character:FindFirstChild("Humanoid") -- ดึง Humanoid
    print("[DEBUG] Starting fruit collection...")

    -- [15.2] เปิด NoClip
    enableNoClip()

    -- [15.3] วนลูปหาต้นไม้ที่มีปุ่ม Collect
    for _, tree in pairs(workspace:GetDescendants()) do
        if tree:IsA("Model") then
            local collectButton = tree:FindFirstChild("Collect", true)
            if collectButton then
                print("[DEBUG] Found Collect button in: ", tree:GetFullName())
                -- [15.4] เดินไปหาต้นไม้
                local rootPart = tree:FindFirstChild("HumanoidRootPart") or tree:FindFirstChildWhichIsA("BasePart")
                if rootPart and humanoid then
                    humanoid:MoveTo(rootPart.Position) -- เดินไปหาต้นไม้
                    humanoid.MoveToFinished:Wait(2) -- รอ 2 วินาที
                end
                -- [15.5] ตรวจสอบ ClickDetector หรือ ProximityPrompt
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

    -- [15.6] ค้นหา NPC Steven
    print("[DEBUG] Looking for Steven...")
    local steven
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name == "Steven" then
            steven = npc
            print("[DEBUG] Found Steven at: ", npc:GetFullName())
            break
        end
    end

    -- [15.7] ถ้าเจอ Steven
    if steven and steven:FindFirstChild("HumanoidRootPart") then
        -- [15.8] เดินไปหา Steven ด้วย NoClip
        humanoid:MoveTo(steven.HumanoidRootPart.Position) -- เดินตรงไป (ทะลุทุกอย่าง)
        humanoid.MoveToFinished:Wait(2)
        print("[DEBUG] Moved to Steven")

        -- [15.9] ค้นหาปุ่ม Talk
        local talkButton = steven:FindFirstChild("Talk", true)
        if talkButton then
            print("[DEBUG] Found Talk button: ", talkButton:GetFullName())
            local clickDetector = talkButton:FindFirstChildOfClass("ClickDetector")
            local prompt = talkButton:FindFirstChildOfClass("ProximityPrompt")
            if clickDetector then
                fireclickdetector(clickDetector)
                print("[DEBUG] Fired ClickDetector for Talk")
                wait(0.5)
            elseif prompt then
                fireproximityprompt(prompt)
                print("[DEBUG] Fired ProximityPrompt for Talk")
                wait(0.5)
            else
                print("[WARNING] No ClickDetector or ProximityPrompt for Talk!")
            end

            -- [15.10] ค้นหา DialogueGui และตัวเลือก #1
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
                    end
                else
                    print("[WARNING] Option #1 not found!")
                end
            else
                print("[WARNING] DialogueGui not found!")
            end
        else
            print("[WARNING] Talk button not found!")
        end
    else
        print("[ERROR] Steven or HumanoidRootPart not found!")
    end

    -- [15.11] ปิด NoClip หลังทำงานเสร็จ
    disableNoClip()
end)

-- [16] สร้างหมวด Teleport
local teleportFrame = Instance.new("Frame") -- Frame สำหรับ Teleport
teleportFrame.Size = UDim2.new(1, 0, 1, 0) -- ขนาดเต็ม MainFrame
teleportFrame.BackgroundTransparency = 1 -- โปร่งใส
teleportFrame.Parent = mainFrame -- วางใน MainFrame
teleportFrame.Visible = false -- ซ่อนเริ่มต้น
print("[DEBUG] TeleportFrame created")

-- [17] เพิ่มข้อความ Teleport
local teleportLabel = Instance.new("TextLabel") -- TextLabel สำหรับ Teleport
teleportLabel.Size = UDim2.new(0.9, 0, 0.5, 0) -- ขนาด 90% ความกว้าง, 50% ความสูง
teleportLabel.Position = UDim2.new(0.05, 0, 0.25, 0) -- ห่างจากขอบ
teleportLabel.Text = "ผู้พัฒนากำลังทำฟังก์ชันนี้ โปรดรอ" -- ข้อความตามที่ขอ
teleportLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
teleportLabel.BackgroundTransparency = 1 -- โปร่งใส
teleportLabel.TextScaled = true -- ปรับขนาดข้อความ
teleportLabel.Parent = teleportFrame -- วางใน TeleportFrame
print("[DEBUG] TeleportLabel created")

-- [18] สร้างหมวด Settings
local settingsFrame = Instance.new("Frame") -- Frame สำหรับ Settings
settingsFrame.Size = UDim2.new(1, 0, 1, 0) -- ขนาดเต็ม MainFrame
settingsFrame.BackgroundTransparency = 1 -- โปร่งใส
settingsFrame.Parent = mainFrame -- วางใน MainFrame
settingsFrame.Visible = false -- ซ่อนเริ่มต้น
print("[DEBUG] SettingsFrame created")

-- [19] สร้างปุ่ม Rejoin
local rejoinButton = Instance.new("TextButton") -- ปุ่มสำหรับ Rejoin
rejoinButton.Size = UDim2.new(0.9, 0, 0.2, 0) -- ขนาด 90% ความกว้าง, 20% ความสูง
rejoinButton.Position = UDim2.new(0.05, 0, 0.1, 0) -- ห่างจากขอบ
rejoinButton.Text = "Rejoin" -- ข้อความบนปุ่ม
rejoinButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
rejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
rejoinButton.Parent = settingsFrame -- วางใน SettingsFrame
print("[DEBUG] RejoinButton created")

-- [20] ฟังก์ชัน Rejoin
rejoinButton.MouseButton1Click:Connect(function()
    print("[DEBUG] Attempting to rejoin...")
    TeleportService:Teleport(game.PlaceId, player) -- รีเกม
end)

-- [21] ตรวจจับการกด G สำหรับ Rejoin
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ข้ามถ้ากำลังพิมพ์
    if input.KeyCode == Enum.KeyCode.G then
        print("[DEBUG] Rejoining via G key...")
        TeleportService:Teleport(game.PlaceId, player) -- รีเกม
    end
end)

-- [22] สร้างปุ่มสลับหมวดหมู่
local homeButton = Instance.new("TextButton") -- ปุ่มสำหรับ Home
homeButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด 30% ความกว้าง, 10% ความสูง
homeButton.Position = UDim2.new(0, 0, 0, 0) -- มุมซ้ายบน
homeButton.Text = "Home" -- ข้อความ
homeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
homeButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
homeButton.Parent = mainFrame -- วางใน MainFrame
print("[DEBUG] HomeButton created")

local teleportButton = Instance.new("TextButton") -- ปุ่มสำหรับ Teleport
teleportButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด 30% ความกว้าง, 10% ความสูง
teleportButton.Position = UDim2.new(0.3, 0, 0, 0) -- ตรงกลางด้านบน
teleportButton.Text = "Teleport" -- ข้อความ
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
teleportButton.Parent = mainFrame -- วางใน MainFrame
print("[DEBUG] TeleportButton created")

local settingsButton = Instance.new("TextButton") -- ปุ่มสำหรับ Settings
settingsButton.Size = UDim2.new(0.3, 0, 0.1, 0) -- ขนาด 30% ความกว้าง, 10% ความสูง
settingsButton.Position = UDim2.new(0.6, 0, 0, 0) -- มุมขวาบน
settingsButton.Text = "Settings" -- ข้อความ
settingsButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- สีเขียว
settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- สีขาว
settingsButton.Parent = mainFrame -- วางใน MainFrame
print("[DEBUG] SettingsButton created")

-- [23] ฟังก์ชันสลับหมวดหมู่
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

-- [24] เพิ่มอนิเมชัน UI
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) -- อนิเมชัน 0.5 วินาที
local tweenShow = TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 0.75}) -- แสดง UI
local tweenHide = TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 1}) -- ซ่อน UI
mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if mainFrame.Visible then
        tweenShow:Play() -- เล่นอนิเมชันแสดง
    else
        tweenHide:Play() -- เล่นอนิเมชันซ่อน
    end
end)