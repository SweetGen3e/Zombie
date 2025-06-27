
-- 🌟 Delta UI Pro – พร้อม UI ปุ่มเปิดฟังก์ชัน รองรับมือถือ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Functions toggle flags
local speedOn, hitboxOn, effectsCleared, espOn, flyOn = false, false, false, false, false
local lockedTarget = nil
local flyConn

-- Speed Function
local function toggleSpeed()
    speedOn = not speedOn
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = speedOn and 30 or 16 end
end

-- Hitbox Function
local function toggleHitbox()
    hitboxOn = not hitboxOn
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if hitboxOn then
                hrp.Size = Vector3.new(1000,1000,1000)
                hrp.Transparency = 0.5
                hrp.Material = Enum.Material.ForceField
            else
                hrp.Size = Vector3.new(2,2,1)
                hrp.Transparency = 0
                hrp.Material = Enum.Material.Plastic
            end
        end
    end
end

-- Effects Removal
local function clearEffects()
    if effectsCleared then return end
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
            v:Destroy()
        elseif v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
            v.Enabled = false
        end
    end
    effectsCleared = true
end

-- ESP
local function toggleESP()
    espOn = not espOn
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local existing = head:FindFirstChild("ESP")
                if existing then existing:Destroy() end
                if espOn then
                    local Billboard = Instance.new("BillboardGui", head)
                    Billboard.Size = UDim2.new(0, 200, 0, 50)
                    Billboard.AlwaysOnTop = true
                    Billboard.Name = "ESP"
                    Billboard.MaxDistance = 1000000
                    local Name = Instance.new("TextLabel", Billboard)
                    Name.Size = UDim2.new(1, 0, 1, 0)
                    Name.Text = p.Name
                    Name.TextColor3 = Color3.fromRGB(0, 255, 0)
                    Name.BackgroundTransparency = 1
                    Name.TextScaled = true
                end
            end
        end
    end
end

-- Fly Function
local function toggleFly()
    flyOn = not flyOn
    if flyConn then flyConn:Disconnect() end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if flyOn and root then
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

-- Lock Target
local function lockNearestTarget()
    local nearestDist, target = math.huge, nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                target = plr
            end
        end
    end
    lockedTarget = target
end

-- TP to Locked
local function tpToLocked()
    if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = lockedTarget.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end
end

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DeltaUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundTransparency = 0.15
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true

local titles = {"🚶 Speed", "🟥 Hitbox", "🌀 Effects", "👁️ ESP", "🕊️ Fly", "🎯 Lock", "📍 TP"}
local funcs = {toggleSpeed, toggleHitbox, clearEffects, toggleESP, toggleFly, lockNearestTarget, tpToLocked}

for i = 1, #titles do
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, (i - 1) * 35 + 10)
    b.Text = titles[i]
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.MouseButton1Click:Connect(funcs[i])
end
