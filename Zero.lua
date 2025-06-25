
-- ✨ Delta UI Pro – ESP Box + Player Picker + Lock Target Enhanced
-- Includes fly system, ESP with name, player picker for TP, and directional skill redirect

-- Assume all services and GUI from previous scripts are defined above

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function createESPBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local head = player.Character:FindFirstChild("Head")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end

    local box = Instance.new("BoxHandleAdornment", workspace)
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 6, 2)
    box.Transparency = 0.1
    box.Color3 = Color3.new(0,1,0)
    box.Name = "ESP_Box"

    local billboard = Instance.new("BillboardGui", head)
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "ESP_Name"

    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(0,1,0)
    textLabel.TextScaled = true
    textLabel.Text = player.Name
end

-- ESP Toggle
function toggleESP(state)
    if state then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                createESPBox(p)
            end
        end
    else
        for _, box in pairs(workspace:GetChildren()) do
            if box:IsA("BoxHandleAdornment") and box.Name == "ESP_Box" then
                box:Destroy()
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                local gui = char.Head:FindFirstChild("ESP_Name")
                if gui then gui:Destroy() end
            end
        end
    end
end

-- TP System
local selectedPlayer
function setTPPlayer(name)
    selectedPlayer = Players:FindFirstChild(name)
end

function toggleTPFollow(state)
    if state and selectedPlayer then
        _G.TPConnection = RunService.RenderStepped:Connect(function()
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:MoveTo(selectedPlayer.Character.HumanoidRootPart.Position + Vector3.new(1,0,0))
            end
        end)
    else
        if _G.TPConnection then _G.TPConnection:Disconnect() end
    end
end

-- Lock Target Redirection
local lockTarget
function setLockTarget(name)
    lockTarget = Players:FindFirstChild(name)
end

function toggleLockAim(state)
    if state and lockTarget then
        _G.LockAimConn = RunService.RenderStepped:Connect(function()
            if not lockTarget.Character or not lockTarget.Character:FindFirstChild("HumanoidRootPart") then return end
            local dist = (Camera.CFrame.Position - lockTarget.Character.HumanoidRootPart.Position).Magnitude
            if dist <= 15 then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockTarget.Character.HumanoidRootPart.Position)
            end
        end)
    else
        if _G.LockAimConn then _G.LockAimConn:Disconnect() end
    end
end


-- 🩻 Ghost HP (ทะลุสิ่งของ + regen)
function toggleGhostHP(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and state then
            hum.Health = math.clamp(hum.Health + 20, 0, hum.MaxHealth)
        end
    end
end

-- 🌐 DNS Boost + Lock FPS
function toggleDNS(state)
    if setfpscap then setfpscap(state and 1000 or 60) end
    settings().Network.IncomingReplicationLag = state and 0 or 0.1
end

-- ⏱️ ลดคูลดาวน์ทั้งหมด
function toggleCooldown(state)
    if state then
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("NumberValue") and obj.Name:lower():find("cooldown") then
                obj.Value = 1
            end
        end
    end
end

-- 🎮 ตั้งค่า FPS ด้วยค่า input
function setFPS(value)
    local n = tonumber(value)
    if n and setfpscap then setfpscap(n) end
end
