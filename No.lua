-- 🔐 Ultimate DeltaUI – ภาษาไทย | ESP • Fly • HP • Lock • TP • DNS • CD • FPS
-- วิธีใช้: วางใน StarterPlayerScripts หรือเรียกด้วย loadstring (Executor)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ตรวจว่าโหลดฝั่ง Client หรือไม่
if not LocalPlayer then return end

-- สร้าง UI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "DeltaUltimateUI"
gui.ResetOnSpawn = false

-- ปุ่มเปิด/ย่อ UI
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0,10,0,10)
openBtn.Text = "🔽 เปิด UI"
openBtn.BackgroundColor3 = Color3.new(0,0.4,0)
openBtn.Visible = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,480)
main.Position = UDim2.new(0,20,0.5,-240)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true

-- หัว UI และปุ่มย่อ
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Text = "⚙️ Delta UI ภาษาไทย"
title.TextColor3 = Color3.new(0,1,0)
title.TextScaled = true

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0,60,0,30)
hideBtn.Position = UDim2.new(1,-70,0,0)
hideBtn.Text = "ย่อ"
hideBtn.BackgroundColor3 = Color3.fromRGB(0.3,0,0)
hideBtn.TextColor3 = Color3.new(1,1,1)

hideBtn.MouseButton1Click:Connect(function()
  main.Visible = false
  openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
  main.Visible = true
  openBtn.Visible = false
end)

-- ฟังก์ชันหลัก
local espOn, flyOn, hpOn, dnsOn, coOn = false, false, false, false, false
local lockedPlayer, tpConn, flyConn

local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESP_Boxes"

local function toggleESP(state)
  espFolder:ClearAllChildren()
  if state then
    for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local box = Instance.new("BoxHandleAdornment", espFolder)
        box.Adornee = p.Character.HumanoidRootPart
        box.Size = Vector3.new(4,6,1)
        box.Color3 = Color3.new(0,1,0)
        box.AlwaysOnTop = true
        box.Transparency = 0.3
      end
    end
  end
end

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

local function toggleHP(state)
  hpOn = state
  local char = LocalPlayer.Character
  if char then
    for _, part in ipairs(char:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide = not state
      end
    end
  end
end

local function toggleDNS(state)
  dnsOn = state
  if setfpscap then setfpscap(state and 1000 or 60) end
end

local function toggleCO(state)
  coOn = state
  if state then
    for _, v in ipairs(game:GetDescendants()) do
      if v:IsA("NumberValue") and v.Name:lower():find("cooldown") then
        v.Value = 1
      end
    end
  end
end

local function lockTarget(name)
  lockedPlayer = Players:FindFirstChild(name)
end

local function tpTo(name)
  if tpConn then tpConn:Disconnect() end
  local p = Players:FindFirstChild(name)
  if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
    tpConn = RunService.RenderStepped:Connect(function()
      LocalPlayer.Character:MoveTo(p.Character.HumanoidRootPart.Position)
    end)
  end
end

local function setFPS(val)
  local n = tonumber(val)
  if n and setfpscap then setfpscap(n) end
end

-- UI สร้างปุ่ม
local y = 40
local function addToggle(txt, func)
  local btn = Instance.new("TextButton", main)
  btn.Size = UDim2.new(0,280,0,30)
  btn.Position = UDim2.new(0,20,0,y)
  btn.Text = "❌ "..txt
  btn.TextColor3 = Color3.new(1,1,1)
  btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
  local st = false
  btn.MouseButton1Click:Connect(function()
    st = not st
    btn.Text = (st and "✅ " or "❌ ")..txt
    func(st)
  end)
  y = y + 35
end

local function addInput(txt, callback)
  local label = Instance.new("TextLabel", main)
  label.Size = UDim2.new(0,280,0,20)
  label.Position = UDim2.new(0,20,0,y)
  label.Text = txt
  label.TextColor3 = Color3.fromRGB(255,255,255)
  label.BackgroundTransparency = 1

  local box = Instance.new("TextBox", main)
  box.Size = UDim2.new(0,280,0,25)
  box.Position = UDim2.new(0,20,0,y+20)
  box.Text = ""
  box.PlaceholderText = "พิมพ์ที่นี่..."
  box.BackgroundColor3 = Color3.fromRGB(30,30,30)
  box.TextColor3 = Color3.new(1,1,1)
  box.FocusLost:Connect(function()
    callback(box.Text)
  end)
  y = y + 55
end

-- ปุ่มและช่องใส่ข้อมูล
addToggle("ESP (F1)", toggleESP)
addToggle("บิน (F2)", toggleFly)
addToggle("Ghost HP (F3)", toggleHP)
addToggle("DNS Boost (F4)", toggleDNS)
addToggle("ลด CD (F5)", toggleCO)
addInput("🔒 ล็อกเป้าหมาย:", lockTarget)
addInput("🚀 TP ตาม:", tpTo)
addInput("🎮 FPS Lock:", setFPS)

-- Keyboard Key binds
UserInputService.InputBegan:Connect(function(input, gameProc)
  if gameProc then return end
  local k = input.KeyCode
  if k == Enum.KeyCode.F1 then toggleESP(not espOn); espOn = not espOn
  elseif k == Enum.KeyCode.F2 then toggleFly(not flyOn); flyOn = not flyOn
  elseif k == Enum.KeyCode.F3 then toggleHP(not hpOn); hpOn = not hpOn
  elseif k == Enum.KeyCode.F4 then toggleDNS(not dnsOn); dnsOn = not dnsOn
  elseif k == Enum.KeyCode.F5 then toggleCO(not coOn); coOn = not coOn
  end
end)

print("🟢 Delta UI โหลดสำเร็จ!")