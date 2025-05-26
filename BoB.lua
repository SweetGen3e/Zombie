-- [ส่วนที่ 1: นำเข้า Services และตรวจสอบ PlayerGui]
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then warn("[ERROR] PlayerGui not found!") return end
print("[DEBUG] PlayerGui loaded")
-- [ส่วนที่ 2: ฟังก์ชันเข้ารหัส String]
local function decrypt(str)
    local key = 42
    local result = ""
    for i = 1, #str do
        result = result .. string.char(bit32.bxor(str:byte(i), key))
    end
    return result
end
local headName = decrypt("\22\5\0\4") -- "Head"
local sniperName = decrypt("\28\14\9\15\5\18") -- "Sniper"
-- [ส่วนที่ 3: สร้าง UI (TextLabel)]
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusHUD_" .. math.random(1000, 9999)
statusLabel.Size = UDim2.new(0.3, 0, 0.15, 0)
statusLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
statusLabel.BackgroundTransparency = 0.7
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 50)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Text = "Aimbot: OFF\nAimlock: OFF\nRapid: OFF"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = playerGui
print("[DEBUG] StatusLabel created at PlayerGui")
-- [ส่วนที่ 4: ตัวแปรสถานะ]
local aimbotEnabled = false
local aimlockEnabled = false
local rapidSwitchEnabled = false
local espBoxes = {}
local isSafe = true
local lastAntiCheatCheck = tick()
local lastAimTime = 0
local lastSwitchTime = 0
local currentTargetIndex = 1
local sortedPlayers = {}
-- [ส่วนที่ 5: ฟังก์ชันป้องกันแบน]
local function checkAntiCheat()
    if tick() - lastAntiCheatCheck < 5 then return end
    lastAntiCheatCheck = tick()
    pcall(function()
        for _, message in pairs(LogService:GetLogHistory()) do
            if message.message:lower():find("cheat") or message.message:find("exploit") then
                isSafe = false
                warn("[WARNING] Anti-cheat detected!")
                return
            end
        end
        for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if child:IsA("RemoteEvent") and child.Name:lower():find("report") then
                isSafe = false
                warn("[WARNING] Suspicious RemoteEvent: ", child.Name)
                return
            end
        end
        isSafe = true
        print("[DEBUG] Anti-cheat check passed")
    end)
end
-- [ส่วนที่ 6: ฟังก์ชันอัพเดท UI]
local function updateUI()
    pcall(function()
        statusLabel.Text = string.format(
            "Aimbot: %s\nAimlock: %s\nRapid: %s",
            aimbotEnabled and "ON" or "OFF",
            aimlockEnabled and "ON" or "OFF",
            rapidSwitchEnabled and "ON" or "OFF"
        )
        print("[DEBUG] UI updated: ", statusLabel.Text)
    end)
end
-- [ส่วนที่ 7: ฟังก์ชัน Aimbot (ESP) ส่วนที่ 1]
local function updateESP()
    for _, box in pairs(espBoxes) do
        if box.Box then box.Box:Remove() end
        if box.Name then box.Name:Remove() end
    end
    espBoxes = {}

    if not aimbotEnabled or not isSafe then return end

    pcall(function()
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") and
               target.Character:FindFirstChild("HumanoidRootPart") then
                local head = target.Character:FindFirstChild(headName)
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
                    -- [ส่วนที่ 8: ฟังก์ชัน Aimbot (ESP) ส่วนที่ 2]
                    local connection
                    connection = RunService.RenderStepped:Connect(function()
                        if not aimbotEnabled or not isSafe or not target.Character or
                           not target.Character:FindFirstChild("HumanoidRootPart") or
                           not target.Character:FindFirstChild(headName) then
                            box.Visible = false
                            nameLabel.Visible = false
                            if connection then connection:Disconnect() end
                            return
                        end

                        local hrpPos, onScreen = Camera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
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
    end)
    print("[DEBUG] ESP updated")
end
-- [ส่วนที่ 9: ฟังก์ชัน Aimlock (สับปืนตาย)]
local function aimlock()
    if not aimlockEnabled or not isSafe or not player.Character or
       not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    if tick() - lastAimTime < 0.1 + math.random(0, 0.05) then return end
    lastAimTime = tick()

    pcall(function()
        local closestPlayer = nil
        local closestDistance = math.huge
        local playerPos = player.Character.HumanoidRootPart.Position

        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild(headName) and
               target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
                local headPos = target.Character[headName].Position
                local distance = (playerPos - headPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = target
                end
            end
        end

        if closestPlayer then
            local head = closestPlayer.Character:FindFirstChild(headName)
            if head then
                local headPos = head.Position + Vector3.new(
                    math.random(-0.2, 0.2),
                    math.random(-0.1, 0.1),
                    math.random(-0.2, 0.2)
                )
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), 0.3)
                print("[DEBUG] Locked aim at: ", closestPlayer.Name)

                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name:lower():find(sniperName:lower()) then
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
    end)
end
-- [ส่วนที่ 10: ฟังก์ชัน Rapid Switch (สับไว) และการควบคุม]
local function updateSortedPlayers()
    sortedPlayers = {}
    pcall(function()
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") and
               target.Character:FindFirstChild(headName) and target.Character.Humanoid.Health > 0 then
                table.insert(sortedPlayers, target)
            end
        end
        table.sort(sortedPlayers, function(a, b)
            return a.Name:lower() < b.Name:lower()
        end)
    end)
    print("[DEBUG] Sorted players: ", #sortedPlayers)
end

local function rapidSwitch()
    if not rapidSwitchEnabled or not isSafe or not player.Character or
       not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    if tick() - lastSwitchTime < 0.5 + math.random(0, 0.2) then return end
    lastSwitchTime = tick()

    pcall(function()
        updateSortedPlayers()
        if #sortedPlayers == 0 then
            print("[DEBUG] No valid targets for Rapid Switch")
            return
        end

        if currentTargetIndex > #sortedPlayers then
            currentTargetIndex = 1
        end
        local target = sortedPlayers[currentTargetIndex]
        if target and target.Character and target.Character:FindFirstChild(headName) and
           target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = target.Character.HumanoidRootPart
            local head = target.Character[headName]

            local behindPos = targetHrp.Position - targetHrp.CFrame.LookVector * (3 + math.random(-0.5, 0.5))
            player.Character.HumanoidRootPart.CFrame = CFrame.new(behindPos, head.Position)
            print("[DEBUG] Warped behind: ", target.Name)

            local headPos = head.Position + Vector3.new(
                math.random(-0.2, 0.2),
                math.random(-0.1, 0.1),
                math.random(-0.2, 0.2)
            )
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), 0.3)
            print("[DEBUG] Locked aim at: ", target.Name)

            currentTargetIndex = currentTargetIndex + 1
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    pcall(function()
        if input.KeyCode == Enum.KeyCode.Q then
            aimbotEnabled = not aimbotEnabled
            updateUI()
            if aimbotEnabled then updateESP() end
            print("[DEBUG] Aimbot toggled: ", aimbotEnabled)
        elseif input.KeyCode == Enum.KeyCode.E then
            aimlockEnabled = not aimlockEnabled
            updateUI()
            print("[DEBUG] Aimlock toggled: ", aimlockEnabled)
        elseif input.KeyCode == Enum.KeyCode.R then
            rapidSwitchEnabled = not rapidSwitchEnabled
            currentTargetIndex = 1
            updateUI()
            print("[DEBUG] Rapid Switch toggled: ", rapidSwitchEnabled)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 and rapidSwitchEnabled then
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                rapidSwitch()
            else
                print("[WARNING] No tool equipped for Rapid Switch")
            end
        end
    end)
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        checkAntiCheat()
        if aimbotEnabled and isSafe then updateESP() end
        if aimlockEnabled and isSafe then aimlock() end
    end)
end)

player.CharacterRemoving:Connect(function()
    pcall(function()
        for _, box in pairs(espBoxes) do
            if box.Box then box.Box:Remove() end
            if box.Name then box.Name:Remove() end
        end
        espBoxes = {}
    end)
end)

updateUI()
print("[DEBUG] Initial UI update")