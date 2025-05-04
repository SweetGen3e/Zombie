-- Config
local validKeys = {
    "AX-LoYXVbXIIZU-YO8",
    "AX-LoYXVbXIIZU-XUR",
    "AX-LoYXVbXIIZU-Zjf"
}
local keyDuration = 24 * 60 * 60 -- 24 hours in seconds
local keyValidated = false
local enteredKey = ""
local isUIEnabled = false
local greenColor = Color3.fromRGB(0, 255, 0)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Simple UI (Text-based fallback if Detlax doesn't support ScreenGui)
local function notify(message)
    print("[CustomUI]: " .. message)
    -- If Detlax supports in-game text, you can replace print with a TextLabel
end

-- Key System
local function validateKey(key)
    if #key == 17 and table.find(validKeys, key) then
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
end

-- UI (ScreenGui, fallback to console if fails)
local ScreenGui = nil
local MainFrame = nil
local ContentFrame = nil
local UIListLayout = nil
local currentTab = "Home"
local HomeContent = {}
local TeleportContent = {}

local function createUI()
    if not pcall(function()
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CustomGreenUI"
        ScreenGui.Parent = game.CoreGui
        ScreenGui.Enabled = false

        MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        MainFrame.BackgroundColor3 = greenColor
        MainFrame.BackgroundTransparency = 0.75
        MainFrame.Parent = ScreenGui

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 10)
        UICorner.Parent = MainFrame

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundTransparency = 1
        Title.Text = "Custom Green UI"
        Title.TextColor3 = greenColor
        Title.TextScaled = true
        Title.Font = Enum.Font.SourceSansBold
        Title.Parent = MainFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(1, -10, 0, 30)
        ToggleButton.Position = UDim2.new(0, 5, 0, 50)
        ToggleButton.BackgroundColor3 = greenColor
        ToggleButton.BackgroundTransparency = 0.5
        ToggleButton.Text = "Toggle UI: ✘"
        ToggleButton.TextColor3 = greenColor
        ToggleButton.TextScaled = true
        ToggleButton.Parent = MainFrame

        ToggleButton.MouseButton1Click:Connect(function()
            isUIEnabled = not isUIEnabled
            ScreenGui.Enabled = isUIEnabled
            ToggleButton.Text = "Toggle UI: " .. (isUIEnabled and "✔" or "✘")
        end)

        local KeyInput = Instance.new("TextBox")
        KeyInput.Size = UDim2.new(1, -60, 0, 30)
        KeyInput.Position = UDim2.new(0, 5, 0, 90)
        KeyInput.BackgroundColor3 = greenColor
        KeyInput.BackgroundTransparency = 0.5
        KeyInput.PlaceholderText = "Enter 17-char key"
        KeyInput.Text = ""
        KeyInput.TextColor3 = greenColor
        KeyInput.TextScaled = true
        KeyInput.Parent = MainFrame

        local ValidateButton = Instance.new("TextButton")
        ValidateButton.Size = UDim2.new(0, 50, 0, 30)
        ValidateButton.Position = UDim2.new(1, -55, 0, 90)
        ValidateButton.BackgroundColor3 = greenColor
        ValidateButton.BackgroundTransparency = 0.5
        ValidateButton.Text = "OK"
        ValidateButton.TextColor3 = greenColor
        ValidateButton.TextScaled = true
        ValidateButton.Parent = MainFrame

        ValidateButton.MouseButton1Click:Connect(function()
            enteredKey = KeyInput.Text
            validateKey(enteredKey)
        end)

        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1, -10, 0, 30)
        TabFrame.Position = UDim2.new(0, 5, 0, 130)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Parent = MainFrame

        local HomeTabButton = Instance.new("TextButton")
        HomeTabButton.Size = UDim2.new(0, 100, 0, 30)
        HomeTabButton.BackgroundColor3 = greenColor
        HomeTabButton.BackgroundTransparency = 0.5
        HomeTabButton.Text = "Home"
        HomeTabButton.TextColor3 = greenColor
        HomeTabButton.TextScaled = true
        HomeTabButton.Parent = TabFrame

        local TeleportTabButton = Instance.new("TextButton")
        TeleportTabButton.Size = UDim2.new(0, 100, 0, 30)
        TeleportTabButton.Position = UDim2.new(0, 110, 0, 0)
        TeleportTabButton.BackgroundColor3 = greenColor
        TeleportTabButton.BackgroundTransparency = 0.5
        TeleportTabButton.Text = "Teleport"
        TeleportTabButton.TextColor3 = greenColor
        TeleportTabButton.TextScaled = true
        TeleportTabButton.Parent = TabFrame

        ContentFrame = Instance.new("ScrollingFrame")
        ContentFrame.Size = UDim2.new(1, -10, 0, 200)
        ContentFrame.Position = UDim2.new(0, 5, 0, 170)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.ScrollBarThickness = 5
        ContentFrame.Parent = MainFrame

        UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.Parent = ContentFrame

        HomeTabButton.MouseButton1Click:Connect(function()
            currentTab = "Home"
            showTab(HomeContent)
        end)

        TeleportTabButton.MouseButton1Click:Connect(function()
            currentTab = "Teleport"
            showTab(TeleportContent)
        end)
    end) then
        notify("ScreenGui not supported! Using console mode.")
        ScreenGui = nil
    end
end

-- Create Button
local function createButton(name, callback)
    local Button = nil
    if ScreenGui then
        Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.BackgroundColor3 = greenColor
        Button.BackgroundTransparency = 0.5
        Button.Text = name
        Button.TextColor3 = greenColor
        Button.TextScaled = true
        Button.Parent = ContentFrame
        Button.Visible = (currentTab == "Home")
        Button.MouseButton1Click:Connect(function()
            if keyValidated then
                callback()
            else
                notify("Please validate a key first!")
            end
        end)
    end
    return { UI = Button, Name = name, Callback = callback }
end

-- Create Toggle
local function createToggle(name, callback)
    local ToggleFrame = nil
    local ToggleButton = nil
    local isToggled = false
    if ScreenGui then
        ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ContentFrame
        ToggleFrame.Visible = (currentTab == "Home")

        ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 30, 0, 30)
        ToggleButton.BackgroundColor3 = greenColor
        ToggleButton.BackgroundTransparency = 0.5
        ToggleButton.Text = "✘"
        ToggleButton.TextColor3 = greenColor
        ToggleButton.TextScaled = true
        ToggleButton.Parent = ToggleFrame

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 40, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = greenColor
        ToggleLabel.TextScaled = true
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame

        ToggleButton.MouseButton1Click:Connect(function()
            if keyValidated then
                isToggled = not isToggled
                ToggleButton.Text = isToggled and "✔" or "✘"
                callback(isToggled)
            else
                notify("Please validate a key first!")
            end
        end)
    end
    return { UI = ToggleFrame, Name = name, Callback = callback, Toggle = ToggleButton }
end

-- Show Tab
local function showTab(content)
    if ScreenGui then
        for _, item in pairs(ContentFrame:GetChildren()) do
            if item:IsA("Frame") or item:IsA("TextButton") then
                item.Visible = false
            end
        end
        for _, item in pairs(content) do
            if item.UI then
                item.UI.Visible = true
            end
        end
    end
end

-- Home Functions
HomeContent[#HomeContent + 1] = createButton("Spawn Point", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-26.07, 17.27, 14.73)
    notify("Teleported to Spawn Point!")
end)

HomeContent[#HomeContent + 1] = createButton("Parachute", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-661.15, 248.87, 751.71)
    notify("Teleported to Parachute!")
end)

HomeContent[#HomeContent + 1] = createButton("Hospital", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-305.79, 2.05, -0.52)
    notify("Teleported to Hospital!")
end)

HomeContent[#HomeContent + 1] = createToggle("Fly", function(Value)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        if Value then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            spawn(function()
                while Value and humanoid do
                    bodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.lookVector * 50
                    wait()
                end
                bodyVelocity:Destroy()
            end)
        end
    end
end)

HomeContent[#HomeContent + 1] = createToggle("Anti-Ban", function(Value)
    if Value then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
        LocalPlayer.Character.Humanoid.Health = math.huge
        spawn(function()
            while Value do
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
                wait()
            end
        end)
    else
        LocalPlayer.Character.Humanoid.Health = 100
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end)

HomeContent[#HomeContent + 1] = createToggle("Speed Boost", function(Value)
    if Value then
        LocalPlayer.Character.Humanoid.WalkSpeed = 210
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

HomeContent[#HomeContent + 1] = createToggle("ESP (Player Positions)", function(Value)
    if Value then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = greenColor
                highlight.OutlineColor = greenColor
                highlight.FillTransparency = 0.5
                highlight.Parent = player.Character
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.Adornee = player.Character.HumanoidRootPart
                billboard.AlwaysOnTop = true
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.Text = player.Name
                textLabel.TextColor3 = greenColor
                textLabel.TextScaled = true
                textLabel.BackgroundTransparency = 1
                textLabel.Parent = billboard
                billboard.Parent = player.Character.HumanoidRootPart
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, obj in pairs(player.Character:GetDescendants()) do
                    if obj:IsA("Highlight") or obj:IsA("BillboardGui") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)

-- Teleport Tab
local DropdownFrame = nil
local DropdownButton = nil
local DropdownList = nil
if ScreenGui then
    DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 30)
    DropdownFrame.BackgroundColor3 = greenColor
    DropdownFrame.BackgroundTransparency = 0.5
    DropdownFrame.Visible = false
    DropdownFrame.Parent = ContentFrame

    DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = "Select Player"
    DropdownButton.TextColor3 = greenColor
    DropdownButton.TextScaled = true
    DropdownButton.Parent = DropdownFrame

    DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 100)
    DropdownList.Position = UDim2.new(0, 0, 0, 30)
    DropdownList.BackgroundColor3 = greenColor
    DropdownList.BackgroundTransparency = 0.5
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame

    local DropdownListLayout = Instance.new("UIListLayout")
    DropdownListLayout.Parent = DropdownList

    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
    end)
end

local function updateDropdown()
    if DropdownList then
        for _, child in pairs(DropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local Option = Instance.new("TextButton")
                Option.Size = UDim2.new(1, 0, 0, 30)
                Option.BackgroundTransparency = 0.5
                Option.BackgroundColor3 = greenColor
                Option.Text = player.Name
                Option.TextColor3 = greenColor
                Option.TextScaled = true
                Option.Parent = DropdownList
                Option.MouseButton1Click:Connect(function()
                    if keyValidated then
                        local targetPlayer = Players:FindFirstChild(player.Name)
                        if targetPlayer and targetPlayer.Character then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                            notify("Teleported to " .. player.Name .. "!")
                        end
                        DropdownList.Visible = false
                    else
                        notify("Please validate a key first!")
                    end
                end)
            end
        end
    end
end

TeleportContent[#TeleportContent + 1] = { UI = DropdownFrame, Name = "Teleport Dropdown" }
spawn(function()
    while true do
        updateDropdown()
        wait(5)
    end
end)

-- Console-based fallback
local function consoleMode()
    notify("Running in console mode. Enter a 17-character key:")
    -- Simulate input (replace with Detlax's input method if available)
    -- For testing, assume key is set manually
    enteredKey = "AX-LoYXVbXIIZU-YO8" -- Replace with actual input
    validateKey(enteredKey)

    while true do
        if keyValidated then
            notify("Select option: 1-Spawn, 2-Parachute, 3-Hospital, 4-Fly, 5-AntiBan, 6-Speed, 7-ESP, 8-Teleport")
            -- Simulate input (replace with Detlax's input method)
            local input = "1" -- Replace with actual input
            if input == "1" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-26.07, 17.27, 14.73)
                notify("Teleported to Spawn Point!")
            elseif input == "2" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-661.15, 248.87, 751.71)
                notify("Teleported to Parachute!")
            elseif input == "3" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-305.79, 2.05, -0.52)
                notify("Teleported to Hospital!")
            elseif input == "4" then
                HomeContent[4].Callback(not HomeContent[4].Toggle)
            elseif input == "5" then
                HomeContent[5].Callback(not HomeContent[5].Toggle)
            elseif input == "6" then
                HomeContent[6].Callback(not HomeContent[6].Toggle)
            elseif input == "7" then
                HomeContent[7].Callback(not HomeContent[7].Toggle)
            elseif input == "8" then
                notify("Enter player name to teleport:")
                local playerName = "SomePlayer" -- Replace with actual input
                local targetPlayer = Players:FindFirstChild(playerName)
                if targetPlayer and targetPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    notify("Teleported to " .. playerName .. "!")
                else
                    notify("Player not found!")
                end
            end
        end
        wait(1)
    end
end

-- Initialize
createUI()
if not ScreenGui then
    consoleMode()
else
    showTab(HomeContent)
end