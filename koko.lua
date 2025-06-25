-- Delta UI Pro - รวมทุกฟังก์ชันพร้อม UI แบบขยับได้และปุ่มเปิด-ปิด
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ฟังก์ชัน Fly
local flyOn, flyConn
function toggleFly(state)
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

-- ฟังก์ชัน ESP (กรอบ + ชื่อ)
local function createESPBox(player)
  if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
  local head = player.Character:FindFirstChild("Head")
  local hrp = player.Character:FindFirstChild("HumanoidRootPart")
  if not head or not hrp then return end

  -- กรอบล้อมตัว
  local box = Instance.new("BoxHandleAdornment", workspace)
  box.Adornee = hrp
  box.AlwaysOnTop = true
  box.ZIndex = 5
  box.Size = Vector3.new(4, 6, 2)
  box.Transparency = 0.1
  box.Color3 = Color3.new(0,1,0)
  box.Name = "ESP_Box"

  -- ชื่อผู้เล่น
  local billboard = Instance.new("BillboardGui", head)
  billboard.Size = UDim2.new(0, 120, 0, 40)
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

-- ตัวแปรผู้เล่นเลือกสำหรับ TP และ Lock
local selectedTPPlayer
local lockTarget

function setTPPlayer(name)
  selectedTPPlayer = Players:FindFirstChild(name)
end

function setLockTarget(name)
  lockTarget = Players:FindFirstChild(name)
end

-- TP ติดตามผู้เล่นที่เลือก
function toggleTPFollow(state)
  if state and selectedTPPlayer then
    _G.TPConnection = RunService.RenderStepped:Connect(function()
      if selectedTPPlayer and selectedTPPlayer.Character and selectedTPPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:MoveTo(selectedTPPlayer.Character.HumanoidRootPart.Position + Vector3.new(1,0,0))
      end
    end)
  else
    if _G.TPConnection then _G.TPConnection:Disconnect() end
  end
end

-- ล็อกเป้าสกิลให้หันตามเป้าหมาย เพิ่มระยะ 15 studs
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

-- HP ฟังก์ชัน เดินทะลุ + เลือดเด้ง 20 เท่า
local hpConnection
function toggleHP(state)
  if state then
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide = false
      end
    end
    if hpConnection then hpConnection:Disconnect() end
    hpConnection = RunService.Heartbeat:Connect(function()
      local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = math.min(humanoid.Health + (humanoid.MaxHealth/100)*20, humanoid.MaxHealth)
      end
    end)
  else
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide = true
      end
    end
    if hpConnection then hpConnection:Disconnect() end
  end
end

-- FPS ปรับ FPS ตามต้องการ
function setFPS(fps)
  local n = tonumber(fps)
  if n and setfpscap then
    setfpscap(n)
  end
end

-- DNS ลดปิง + ล็อก FPS (ง่ายๆแบบจำลอง)
local dnsConnection
function toggleDNS(state)
  if state then
    if setfpscap then setfpscap(1000) end
    settings().Network.IncomingReplicationLag = 0
  else
    if setfpscap then setfpscap(60) end
    settings().Network.IncomingReplicationLag = 0.1
  end
end

-- ลดคูลดาวน์ในเกม เหลือ 1 วินาที
function toggleCooldown(state)
  if state then
    for _, obj in pairs(game:GetDescendants()) do
      if obj:IsA("NumberValue") and obj.Name:lower():find("cooldown") then
        obj.Value = 1
      end
    end
  end
end

-- UI สวย โปร่งใส 85% ขยับได้เอง + ปุ่มเปิด/ปิด UI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "DeltaUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 340, 0, 580)
main.Position = UDim2.new(0, 30, 0.5, -290)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local toggleUIBtn = Instance.new("TextButton", gui)
toggleUIBtn.Size = UDim2.new(0, 50, 0, 30)
toggleUIBtn.Position = UDim2.new(0, 10, 0.5, -15)
toggleUIBtn.Text = "☰"
toggleUIBtn.TextColor3 = Color3.new(1,1,1)
toggleUIBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", toggleUIBtn)

local uiVisible = true
toggleUIBtn.MouseButton1Click:Connect(function()
  uiVisible = not uiVisible
  main.Visible = uiVisible
end)

local y = 10
local function addToggle(text, emoji, callback)
  local btn = Instance.new("TextButton", main)
  btn.Size = UDim2.new(0, 300, 0, 30)
  btn.Position = UDim2.new(0, 20, 0, y)
  btn.Text = "❌ "..emoji.." "..text
  btn.TextColor3 = Color3.new(1,1,1)
  btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
  Instance.new("UICorner", btn)
  local state = false
  btn.MouseButton1Click:Connect(function()
    state = not state
    btn.Text = (state and "✅ " or "❌ ")..emoji.." "..text
    callback(state)
  end)
  y = y + 40
end

local function addInput(text, emoji, callback)
  local label = Instance.new("TextLabel", main)
  label.Size = UDim2.new(0, 300, 0, 20)
  label.Position = UDim2.new(0, 20, 0, y)
  label.Text = emoji.." "..text
  label.TextColor3 = Color3.new(1,1,1)
  label.BackgroundTransparency = 1

  local box = Instance.new("TextBox", main)
  box.Size = UDim2.new(0, 300, 0, 30)
  box.Position = UDim2.new(0, 20, 0, y + 20)
  box.PlaceholderText = "พิมพ์ชื่อผู้เล่นหรือค่าที่นี่"
  box.TextColor3 = Color3.new(1,1,1)
  box.BackgroundColor3 = Color3.fromRGB(25,25,25)
  Instance.new("UICorner", box)
  box.FocusLost:Connect(function()
    callback(box.Text)
  end)

  y = y + 60
end

-- เพิ่มปุ่ม UI
addToggle("ESP + ชื่อ", "📦", toggleESP)
addToggle("บิน", "🚀", toggleFly)
addInput("เลือกผู้เล่น TP", "🛰️", setTPPlayer)
addToggle("TP ติดผู้เล่น", "🔗", toggleTPFollow)
addInput("เลือกเป้าล็อก", "🎯", setLockTarget)
addToggle("ล็อกเป้าสกิล", "🎯", toggleLockAim)
addToggle("เดินทะลุ+เลือดเด้ง", "👻", toggleHP)
addInput("ตั้งค่า FPS (1-240)", "🎮", setFPS)
addToggle("DNS Boost (ลดปิง)", "🌐", toggleDNS)
addToggle("ลดคูลดาวน์", "⏱️", toggleCooldown)