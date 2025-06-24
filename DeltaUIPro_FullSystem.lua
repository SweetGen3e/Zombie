
-- 💎 Delta UI Pro – รวมฟังก์ชันครบ (บิน, ESP, HP, DNS, Cooldown, TP, FPS)
-- UI สวยทันสมัย บินแบบกล้อง ควบคุมได้จริง

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if not LocalPlayer then return end

-- 🛠 ฟังก์ชันบินแบบกล้อง
local flyOn = false
local flyConn
local function toggleFly(state)
  flyOn = state
  if flyConn then flyConn:Disconnect() end
  local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
  if state and root then
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

-- 🧩 UI เริ่ม
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "DeltaUIPro"
gui.ResetOnSpawn = false

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0,10,0,10)
openBtn.Text = "🔽 เปิด UI"
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openBtn.BackgroundTransparency = 0.15
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Visible = false
Instance.new("UICorner", openBtn)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 340, 0, 550)
main.Position = UDim2.new(0, 20, 0.5, -275)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
local uistroke1 = Instance.new("UIStroke", main)
uistroke1.Color = Color3.fromRGB(80, 255, 100)
uistroke1.Thickness = 1.5

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BackgroundTransparency = 0.2
title.Text = "🌟 Delta UI Pro – Full System"
title.TextColor3 = Color3.fromRGB(80,255,100)
title.TextScaled = true
Instance.new("UICorner", title)

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0, 60, 0, 30)
hideBtn.Position = UDim2.new(1, -70, 0, 2)
hideBtn.Text = "ย่อ"
hideBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
hideBtn.BackgroundTransparency = 0.2
hideBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", hideBtn)

hideBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    openBtn.Visible = false
end)

local y = 40
local function addToggle(txt, emoji, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 300, 0, 30)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.Text = "❌ "..emoji.." "..txt
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "✅ " or "❌ ")..emoji.." "..txt
        callback(state)
    end)
    y = y + 35
end

local function addInput(txt, emoji, callback)
    local label = Instance.new("TextLabel", main)
    label.Size = UDim2.new(0,300,0,20)
    label.Position = UDim2.new(0,20,0,y)
    label.Text = emoji.." "..txt
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local box = Instance.new("TextBox", main)
    box.Size = UDim2.new(0,300,0,25)
    box.Position = UDim2.new(0,20,0,y+20)
    box.PlaceholderText = "พิมพ์ที่นี่..."
    box.TextColor3 = Color3.new(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
    y = y + 55
end

-- ✅ ใส่ทุกฟังก์ชัน
addToggle("บิน (Fly)", "🚀", function(on)
  toggleFly(on)
end)

addToggle("ESP", "🧿", function(on)
    if on then
        local espFolder = Instance.new("Folder", workspace)
        espFolder.Name = "ESP_Boxes"
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local box = Instance.new("BoxHandleAdornment", espFolder)
                box.Adornee = p.Character.HumanoidRootPart
                box.Size = Vector3.new(4,6,1)
                box.Color3 = Color3.new(0,1,0)
                box.AlwaysOnTop = true
                box.Transparency = 0.15
            end
        end
    else
        local f = workspace:FindFirstChild("ESP_Boxes")
        if f then f:Destroy() end
    end
end)

addToggle("Ghost HP", "👻", function(on)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not on
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and on then
            hum.Health = math.clamp(hum.Health + 20, 0, hum.MaxHealth)
        end
    end
end)

addToggle("DNS Boost", "🌐", function(on)
    if setfpscap then setfpscap(on and 1000 or 60) end
    settings().Network.IncomingReplicationLag = on and 0 or 0.1
end)

addToggle("ลดคูลดาวน์", "⏱️", function(on)
    if on then
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("NumberValue") and obj.Name:lower():find("cooldown") then
                obj.Value = 1
            end
        end
    end
end)

addInput("ล็อกเป้าหมาย", "🎯", function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        RunService.RenderStepped:Connect(function()
            local hrp = target.Character.HumanoidRootPart
            if hrp then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
            end
        end)
    end
end)

addInput("ติดตามผู้เล่น", "🛰️", function(name)
    local followTarget = Players:FindFirstChild(name)
    if followTarget and followTarget.Character and followTarget.Character:FindFirstChild("HumanoidRootPart") then
        if _G.TPConnection then _G.TPConnection:Disconnect() end
        _G.TPConnection = RunService.RenderStepped:Connect(function()
            local root = followTarget.Character:FindFirstChild("HumanoidRootPart")
            if root and LocalPlayer.Character then
                LocalPlayer.Character:MoveTo(root.Position + Vector3.new(1,0,0))
            end
        end)
    end
end)

addInput("กำหนด FPS", "🎮", function(fps)
    local n = tonumber(fps)
    if n and setfpscap then setfpscap(n) end
end)
