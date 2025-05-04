-- ตรวจสอบการโหลดเกม
if not game:IsLoaded() then
    game.Loaded:Wait()
    print("เกมโหลดสำเร็จ")
end

-- Config
local validKeys = {
    "AX-LoYXVbXIIZU-YO8",
    "AX-LoYXVbXIIZU-XUR",
    "AX-LoYXVbXIIZU-Zjf"
}
local keyDuration = 24 * 60 * 60 -- 24 ชั่วโมง
local keyValidated = false
local enteredKey = ""
local greenColor = Color3.fromRGB(0, 255, 0)

-- ตัวแปรสถานะ
local player = game.Players.LocalPlayer
local isFlying = false
local isNoClip = false
local isSpeedBoost = false
local isESP = false
local flyConnection = nil
local noClipConnection = nil
local selectionBoxes = {}

-- รอ PlayerGui
local success, playerGui = pcall(function()
    return player:WaitForChild("PlayerGui", 15)
end)
if not success or not playerGui then
    warn("ไม่สามารถเข้าถึง PlayerGui ได้")
    print("สลับไปใช้โหมด console")
    local consoleMode = true
else
    print("PlayerGui เข้าถึงสำเร็จ")
end

-- สร้าง UI (ถ้าไม่ใช้ console mode)
local screenGui = nil
local mainFrame = nil
local scrollingFrame = nil
local HomeContent = {}
local TeleportContent = {}
local currentTab = "Home"

if not consoleMode then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomGreenUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    print("ScreenGui ถูกสร้างสำเร็จ")

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 60)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.BackgroundColor3 = greenColor
    toggleButton.BackgroundTransparency = 0.5
    toggleButton.Text = "✅"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = screenGui
    print("ปุ่มเปิด/ปิด UI ถูกสร้างสำเร็จ")

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundTransparency = 0.75
    mainFrame.BackgroundColor3 = greenColor
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    print("Frame หลักของ UI ถูกสร้างสำเร็จ")

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame

    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(1, -20, 0, 70)
    keyFrame.Position = UDim2.new(0, 10, 0, 10)
    keyFrame.BackgroundTransparency = 1
    keyFrame.Parent = mainFrame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, -60, 0, 30)
    keyInput.Position = UDim2.new(0, 0, 0, 0)
    keyInput.BackgroundColor3 = greenColor
    keyInput.BackgroundTransparency = 0.5
    keyInput.PlaceholderText = "Enter 17-char key"
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextScaled = true
    keyInput.Parent = keyFrame

    local validateButton = Instance.new("TextButton")
    validateButton.Size = UDim2.new(0, 50, 0, 30)
    validateButton.Position = UDim2.new(1, -50, 0, 0)
    validateButton.BackgroundColor3 = greenColor
    validateButton.BackgroundTransparency = 0.5
    validateButton.Text = "OK"
    validateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    validateButton.TextScaled = true
    validateButton.Parent = keyFrame

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 30)
    tabFrame.Position = UDim2.new(0, 10, 0, 90)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local homeTabButton = Instance.new("TextButton")
    homeTabButton.Size = UDim2.new(0, 100, 0, 30)
    homeTabButton.BackgroundColor3 = greenColor
    homeTabButton.BackgroundTransparency = 0.5
    homeTabButton.Text = "Home"
    homeTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    homeTabButton.TextScaled = true
    homeTabButton.Parent = tabFrame

    local teleportTabButton = Instance.new("TextButton")
    teleportTabButton.Size = UDim2.new(0, 100, 0, 30)
    teleportTabButton.Position = UDim2.new(0, 110, 0, 0)
    teleportTabButton.BackgroundColor3 = greenColor
    teleportTabButton.BackgroundTransparency = 0.5
    teleportTabButton.Text = "Teleport"
    teleportTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportTabButton.TextScaled = true
    teleportTabButton.Parent = tabFrame

    scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -20, 0, 250)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 130)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 5
    scrollingFrame.ScrollBarImageColor3 = greenColor
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.Parent = mainFrame
    print("ScrollingFrame ถูกสร้างสำเร็จ")

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = scrollingFrame
    print("UIListLayout ถูกสร้างสำเร็จ")

    -- ฟังก์ชัน UI
    validateButton.MouseButton1Click:Connect(function()
        enteredKey = keyInput.Text
        if #enteredKey == 17 and table.find(validKeys, enteredKey) then
            keyValidated = true
            notify("Key validated! Access granted for 24 hours.")
            spawn(function()
                wait(keyDuration)
                keyValidated = false
                notify("Key expired! Please enter a new key.")
            end)
        else
            notify("Invalid key! Please use a valid key.")
        end
    end)

    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        toggleButton.Text = mainFrame.Visible and "❌" or "✅"
        toggleButton.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(0, 200, 0) or greenColor
        notify(mainFrame.Visible and "UI: เปิด" or "UI: ปิด")
    end)

    homeTabButton.MouseButton1Click:Connect(function()
        showTab("Home")
    end)

    teleportTabButton.MouseButton1Click:Connect(function()
        showTab("Teleport")
    end)
end

-- ฟังก์ชันแจ้งเตือน
local function notify(message)
    print("[CustomGreenUI]: " .. message)
end

-- ฟังก์ชันสลับ Tab
local function showTab(tab)
    currentTab = tab
    if scrollingFrame then
        for _, item in pairs(scrollingFrame:GetChildren()) do
            if item:IsA("Frame") or item:IsA("TextButton") then
                item.Visible = false
            end
        end
        if tab == "Home" then
            for _, item in pairs(HomeContent) do
                item.Visible = true
            end
        elseif tab == "Teleport" then
            for _, item in pairs(TeleportContent) do
                item.Visible = true
            end
        end
    end
end

-- ฟังก์ชันสร้างปุ่ม
local function createButton(name, callback)
    local button = nil
    if scrollingFrame then
        button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.BackgroundColor3 = greenColor
        button.BackgroundTransparency = 0.5
        button.Text = name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Visible = (currentTab == "Home")
        button.Parent = scrollingFrame
        button.MouseButton1Click:Connect(function()
            if keyValidated then
                callback()
            else
                notify("Please validate a key first!")
            end
        end)
        table.insert(HomeContent, button)
    end
    return { UI = button, Name = name, Callback = callback }
end

-- ฟังก์ชันสร้าง Toggle
local function createToggle(name, callback)
    local toggleFrame = nil
    local toggleButton = nil
    local isToggled = false
    if scrollingFrame then
        toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -10, 0, 30)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Visible = (currentTab == "Home")
        toggleFrame.Parent = scrollingFrame

        toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 30, 0, 30)
        toggleButton.BackgroundColor3 = greenColor
        toggleButton.BackgroundTransparency = 0.5
        toggleButton.Text = "✘"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextScaled = true
        toggleButton.Parent = toggleFrame

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -40, 1, 0)
        toggleLabel.Position = UDim2.new(0, 40, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = name
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.TextScaled = true
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame

        toggleButton.MouseButton1Click:Connect(function()
            if keyValidated then
                isToggled = not isToggled
                toggleButton.Text = isToggled and "✔" or "✘"
                callback(isToggled)
            else
                notify("Please validate a key first!")
            end)
        end)
        table.insert(HomeContent, toggleFrame)
    end
    return { UI = toggleFrame, Name = name, Callback = callback, Toggle = toggleButton }
end

-- Home Tab ฟังก์ชัน
createButton("Spawn Point", function()
    if player.Character and player.Character.HumanoidRootPart then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-26.07, 17.27, 14.73)
        notify("Teleported to Spawn Point!")
    else
        notify("Character not found!")
    end
end)

createButton("Parachute", function()
    if player.Character and player.Character.HumanoidRootPart then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-661.15, 248.87, 751.71)
        notify("Teleported to Parachute!")
    else
        notify("Character not found!")
    end
end)

createButton("Hospital", function()
    if player.Character and player.Character.HumanoidRootPart then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-305.79, 2.05, -0.52)
        notify("Teleported to Hospital!")
    else
        notify("Character not found!")
    end
end)

createToggle("Fly", function(value)
    isFlying = value
    if isFlying then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = player.Character.HumanoidRootPart
            flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if isFlying and humanoid then
                    bodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.lookVector * 50
                else
                    bodyVelocity:Destroy()
                    if flyConnection then flyConnection:Disconnect() end
                end
            end)
        end
    elseif flyConnection then
        flyConnection:Disconnect()
    end
end)

createToggle("Anti-Ban", function(value)
    isNoClip = value
    if isNoClip then
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.Health = math.huge
            noClipConnection = game:GetService("RunService").Stepped:Connect(function()
                if isNoClip and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 100
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
        if noClipConnection then
            noClipConnection:Disconnect()
        end
    end
end)

createToggle("Speed Boost", function(value)
    isSpeedBoost = value
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = isSpeedBoost and 210 or 16
    end
end)

createToggle("ESP (Player Positions)", function(value)
    isESP = value
    if isESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = greenColor
                highlight.OutlineColor = greenColor
                highlight.FillTransparency = 0.5
                highlight.Parent = p.Character
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.Adornee = p.Character.HumanoidRootPart
                billboard.AlwaysOnTop = true
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Text = p.Name
                textLabel.TextColor3 = greenColor
                textLabel.TextScaled = true
                textLabel.BackgroundTransparency = 1
                textLabel.TextSize = 16
                textLabel.Parent = billboard
                billboard.Parent = p.Character.HumanoidRootPart
                selectionBoxes[p] = { Highlight = highlight, Billboard = billboard }
            end
        end
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if selectionBoxes[p] then
                selectionBoxes[p].Highlight:Destroy()
                selectionBoxes[p].Billboard:Destroy()
                selectionBoxes[p] = nil
            end
        end
    end
end)

-- Teleport Tab
local dropdownFrame = nil
local dropdownButton = nil
local dropdownList = nil
if scrollingFrame then
    dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -10, 0, 30)
    dropdownFrame.BackgroundColor3 = greenColor
    dropdownFrame.BackgroundTransparency = 0.5
    dropdownFrame.Visible = (currentTab == "Teleport")
    dropdownFrame.Parent = scrollingFrame

    dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = "Select Player"
    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.TextScaled = true
    dropdownButton.Parent = dropdownFrame

    dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, 100)
    dropdownList.Position = UDim2.new(0, 0, 0, 30)
    dropdownList.BackgroundColor3 = greenColor
    dropdownList.BackgroundTransparency = 0.5
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame

    local dropdownListLayout = Instance.new("UIListLayout")
    dropdownListLayout.Parent = dropdownList

    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
end

local function updateDropdown()
    if dropdownList then
        for _, child in pairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player then
                local option = Instance.new("TextButton")
                option.Size = UDim2.new(1, 0, 0, 30)
                option.BackgroundTransparency = 0.5
                option.BackgroundColor3 = greenColor
                option.Text = p.Name
                option.TextColor3 = Color3.fromRGB(255, 255, 255)
                option.TextScaled = true
                option.Parent = dropdownList
                option.MouseButton1Click:Connect(function()
                    if keyValidated then
                        local targetPlayer = game.Players:FindFirstChild(p.Name)
                        if targetPlayer and targetPlayer.Character then
                            player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                            notify("Teleported to " .. p.Name .. "!")
                        end
                        dropdownList.Visible = false
                    else
                        notify("Please validate a key first!")
                    end)
                end)
            end
        end
    end
end

if dropdownFrame then
    table.insert(TeleportContent, dropdownFrame)
end

spawn(function()
    while true do
        updateDropdown()
        wait(5)
    end
end)

-- อัปเดต CanvasSize
if scrollingFrame then
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end)
end

-- Console Mode
local function consoleMode()
    notify("ScreenGui not supported! Using console mode.")
    notify("Enter a 17-character key (e.g., AX-LoYXVbXIIZU-YO8):")
    -- สมมติ input (ต้องปรับตาม Detlax API)
    enteredKey = "AX-LoYXVbXIIZU-YO8" -- แทนด้วย input จริง
    if #enteredKey == 17 and table.find(validKeys, enteredKey) then
        keyValidated = true
        notify("Key validated! Access granted for 24 hours.")
        spawn(function()
            wait(keyDuration)
            keyValidated = false
            notify("Key expired! Please enter a new key.")
        end)
    else
        notify("Invalid key! Please use a valid key.")
        return
    end

    while true do
        if keyValidated then
            notify("Select option: 1-Spawn, 2-Parachute, 3-Hospital, 4-Fly, 5-AntiBan, 6-Speed, 7-ESP, 8-Teleport")
            -- สมมติ input (ต้องปรับตาม Detlax)
            local input = "1" -- แทนด้วย input จริง
            if input == "1" then
                if player.Character and player.Character.HumanoidRootPart then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-26.07, 17.27, 14.73)
                    notify("Teleported to Spawn Point!")
                end
            elseif input == "2" then
                if player.Character and player.Character.HumanoidRootPart then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-661.15, 248.87, 751.71)
                    notify("Teleported to Parachute!")
                end
            elseif input == "3" then
                if player.Character and player.Character.HumanoidRootPart then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-305.79, 2.05, -0.52)
                    notify("Teleported to Hospital!")
                end
            elseif input == "4" then
                isFlying = not isFlying
                HomeContent[4].Callback(isFlying)
                notify(isFlying and "Fly: ON" or "Fly: OFF")
            elseif input == "5" then
                isNoClip = not isNoClip
                HomeContent[5].Callback(isNoClip)
                notify(isNoClip and "Anti-Ban: ON" or "Anti-Ban: OFF")
            elseif input == "6" then
                isSpeedBoost = not isSpeedBoost
                HomeContent[6].Callback(isSpeedBoost)
                notify(isSpeedBoost and "Speed Boost: ON" or "Speed Boost: OFF")
            elseif input == "7" then
                isESP = not isESP
                HomeContent[7].Callback(isESP)
                notify(isESP and "ESP: ON" or "ESP: OFF")
            elseif input == "8" then
                notify("Enter player name to teleport:")
                local playerName = "SomePlayer" -- แทนด้วย input จริง
                local targetPlayer = game.Players:FindFirstChild(playerName)
                if targetPlayer and targetPlayer.Character then
                    player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    notify("Teleported to " .. playerName .. "!")
                else
                    notify("Player not found!")
                end
            end
        end
        wait(1)
    end
end

-- เริ่มต้น
if consoleMode then
    consoleMode()
else
    showTab("Home")
    notify("โค้ดโหลดสำเร็จ! คลิกปุ่ม ✅ เพื่อเปิด UI")
end