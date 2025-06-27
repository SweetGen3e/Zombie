-- 🌟 Delta UI Pro – รวมทุกฟังก์ชันแบบปลอดภัย ไม่ใช้ loadstring

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ✅ ลบเอฟเฟกต์ในเกมเพื่อลดกระตุก
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
        v:Destroy()
    elseif v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
        v.Enabled = false
    end
end

-- ✅ ขยาย Hitbox ศัตรู
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = p.Character.HumanoidRootPart
        hrp.Size = Vector3.new(100,100,100)
        hrp.Transparency = 0.5
        hrp.Material = Enum.Material.ForceField
    end
end

-- ✅ เพิ่มความเร็วเดิน 30 studs/s
local function setSpeed()
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = 30 end
end
setSpeed()
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    setSpeed()
end)

-- ✅ Fly แบบอิสระ
local flying = false
local flyConn
function toggleFly(state)
    flying = state
    if flyConn then flyConn:Disconnect() end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if flying and root then
        local bg = Instance.new("BodyGyro", root)
        local bv = Instance.new("BodyVelocity", root)
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyConn = RunService.RenderStepped:Connect(function()
            bg.CFrame = Camera.CFrame
            bv.Velocity = Camera.CFrame.LookVector * 80
        end)
    elseif root then
        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

-- ✅ ESP แสดงกล่องพร้อมชื่อ
function createESP(player)
    if player == LocalPlayer then return end
    local Billboard = Instance.new("BillboardGui", player.Character:WaitForChild("Head"))
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.AlwaysOnTop = true
    Billboard.Name = "ESP"
    Billboard.MaxDistance = 1000000
    local Name = Instance.new("TextLabel", Billboard)
    Name.Size = UDim2.new(1, 0, 1, 0)
    Name.Text = player.Name
    Name.TextColor3 = Color3.fromRGB(0, 255, 0)
    Name.BackgroundTransparency = 1
    Name.TextScaled = true
end
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        createESP(plr)
    end
end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(1)
        createESP(plr)
    end)
end)

-- ✅ UI (โปร่งใส 85% ขยับ/ย่อได้)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DeltaUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundTransparency = 0.15
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true

local ToggleFly = Instance.new("TextButton", Frame)
ToggleFly.Text = "Toggle Fly"
ToggleFly.Size = UDim2.new(1, 0, 0, 40)
ToggleFly.Position = UDim2.new(0, 0, 0, 0)
ToggleFly.MouseButton1Click:Connect(function()
    toggleFly(not flying)
end)

-- ✅ ปุ่มย่อ/ขยาย
local isMinimized = false
local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Size = UDim2.new(0, 40, 0, 20)
MinBtn.Position = UDim2.new(1, -45, 0, 5)
MinBtn.Text = "-"
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    for _, child in pairs(Frame:GetChildren()) do
        if child:IsA("TextButton") and child ~= MinBtn then
            child.Visible = not isMinimized
        end
    end
    MinBtn.Text = isMinimized and "+" or "-"
end)

-- ✅ เพิ่มเติม Lock Target, TP, Cooldown, FPS, DNS, Regen (ใส่ต่อด้านล่างตามต้องการ)
-- หากต้องการให้ผมเขียนต่อให้จนจบครบทั้งหมด บอกได้เลยครับ เช่น “ใส่ TP และ Cooldown ด้วย”