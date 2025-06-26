-- delta_cheat_full_combined.lua
-- รวมฟังก์ชันโกงทั้งหมด พร้อม Delta UI
-- โดย: ผู้ร่วงรู้ทุกอย่างบนโลก

-- 🟩 Setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 🟩 State
local flying = false
local lockTarget = nil
local flySpeed = 2

-- 🟥 Admin Fly (กด F)
function startFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local bodyGyro = Instance.new("BodyGyro", root)
    bodyGyro.P = 9e4
    bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.cframe = root.CFrame

    local bodyVelocity = Instance.new("BodyVelocity", root)
    bodyVelocity.velocity = Vector3.zero
    bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

    flying = true

    RunService.RenderStepped:Connect(function()
        if flying then
            bodyGyro.cframe = Camera.CFrame
            local moveVec = UIS:IsKeyDown(Enum.KeyCode.W) and Camera.CFrame.LookVector or Vector3.zero
            bodyVelocity.velocity = moveVec * flySpeed * 10
        end
    end)
end

function stopFly()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end
    end
    flying = false
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then startFly() else stopFly() end
    end
end)

-- 🟧 WalkSpeed 30
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 30
end)

-- 🟨 Expand Hitbox
function expandHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            hrp.Size = Vector3.new(1000, 1000, 1000)
            hrp.Transparency = 0.7
            hrp.Material = Enum.Material.Neon
            hrp.Color = Color3.fromRGB(255, 0, 0)
            hrp.CanCollide = false
        end
    end
end

-- 🟦 Remove Effects (Bypass)
function bypassEffects()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = math.huge
    Lighting.Brightness = 0
    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
            v:Destroy()
        end
    end
end

-- 🟪 Lock Target (กด T เพื่อเลือก, เพิ่ม range skill)
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        local closest = nil
        local closestDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closest = plr
                    closestDist = dist
                end
            end
        end
        lockTarget = closest
    end
end)

-- 🟥 TP ไปยังเป้าหมาย (กด Y)
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Y and lockTarget and lockTarget.Character then
        LocalPlayer.Character:MoveTo(lockTarget.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
    end
end)

-- 🟩 ESP (กรอบ + ชื่อ + ระยะ)
function showESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local adornee = player.Character
            local box = Instance.new("SelectionBox")
            box.Adornee = adornee
            box.LineThickness = 0.05
            box.Color3 = Color3.new(0, 1, 1)
            box.SurfaceTransparency = 0.5
            box.Parent = adornee

            local bill = Instance.new("BillboardGui", adornee)
            bill.Size = UDim2.new(4, 0, 1, 0)
            bill.StudsOffset = Vector3.new(0, 4, 0)
            bill.AlwaysOnTop = true

            local label = Instance.new("TextLabel", bill)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(0, 255, 255)
            label.TextScaled = true
            label.Font = Enum.Font.GothamSemibold
            label.Text = player.Name
        end
    end
end

-- 🟦 FPS HUD
local fpsGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
fpsGui.Name = "FPSGui"
local fpsLabel = Instance.new("TextLabel", fpsGui)
fpsLabel.Size = UDim2.new(0, 200, 0, 30)
fpsLabel.Position = UDim2.new(0, 10, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.SourceSansBold

local lastTime = tick()
local frames = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastTime >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        lastTime = tick()
    end

    -- Loop functions
    expandHitbox()
    bypassEffects()
end)

-- เรียกใช้ ESP ครั้งเดียว
showESP()

print("🔥 Cheat Script Loaded: Fly, TP, Lock, Hitbox, Bypass, FPS, ESP, Speed")
