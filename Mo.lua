-- 🔰 Delta-Style Roblox Cheat UI (ภาษาไทย + ใช้งานจริง) -- ✅ ฟังก์ชัน: ESP, Fly, HP Ghost, Lock Target, TP Follow, FPS Lock, DNS Boost, Cooldown -- ✅ ใช้ได้ทั้ง Roblox Studio และ Executor เช่น Delta, Hydrogen (ถ้าเกมไม่บล็อก)

local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local Camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui")) gui.Name = "DeltaUI" gui.ResetOnSpawn = false

-- ✅ ปุ่มเปิด UI local openBtn = Instance.new("TextButton", gui) openBtn.Size = UDim2.new(0, 100, 0, 30) openBtn.Position = UDim2.new(0, 10, 0, 10) openBtn.Text = "🔽 เปิด UI" openBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0) openBtn.TextColor3 = Color3.new(1,1,1) openBtn.Visible = false

-- ✅ หน้าต่างหลัก local main = Instance.new("Frame", gui) main.Size = UDim2.new(0, 320, 0, 420) main.Position = UDim2.new(0, 20, 0.5, -200) main.BackgroundColor3 = Color3.fromRGB(25, 25, 25) main.Active = true main.Draggable = true

local title = Instance.new("TextLabel", main) title.Size = UDim2.new(1, 0, 0, 30) title.BackgroundColor3 = Color3.fromRGB(45, 45, 45) title.Text = "💻 Delta UI ภาษาไทย" title.TextColor3 = Color3.new(0, 1, 0) title.TextScaled = true

-- ✅ ปุ่มย่อ UI local hideBtn = Instance.new("TextButton", main) hideBtn.Size = UDim2.new(0, 60, 0, 30) hideBtn.Position = UDim2.new(1, -70, 0, 0) hideBtn.Text = "ย่อ" hideBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0) hideBtn.TextColor3 = Color3.new(1,1,1)

hideBtn.MouseButton1Click:Connect(function() main.Visible = false openBtn.Visible = true end) openBtn.MouseButton1Click:Connect(function() main.Visible = true openBtn.Visible = false end)

-- 🧠 ฟังก์ชันหลัก local espOn, flyOn, hpOn, dnsOn, coOn, tpTarget, lockedPlayer = false, false, false, false, false, nil, nil

-- ESP local espFolder = Instance.new("Folder", workspace) espFolder.Name = "ESP_Boxes" local function toggleESP(state) espFolder:ClearAllChildren() if state then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local box = Instance.new("BoxHandleAdornment", espFolder) box.Adornee = p.Character.HumanoidRootPart box.Size = Vector3.new(4,6,1) box.Color3 = Color3.new(0,1,0) box.AlwaysOnTop = true box.ZIndex = 10 box.Transparency = 0.3 end end end end

-- Fly local flyConn local function toggleFly(state) local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not root then return end if state then local bg = Instance.new("BodyGyro", root) local bv = Instance.new("BodyVelocity", root) bg.MaxTorque = Vector3.new(9e9,9e9,9e9) bv.MaxForce = Vector3.new(9e9,9e9,9e9) flyConn = RunService.RenderStepped:Connect(function() bg.CFrame = Camera.CFrame bv.Velocity = Camera.CFrame.LookVector * 80 end) else if flyConn then flyConn:Disconnect() end for _, v in ipairs(root:GetChildren()) do if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end end end end

-- HP Ghost local function toggleHP(state) for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = not state end end end

-- DNS local function toggleDNS(state) if setfpscap then setfpscap(state and 1000 or 60) end end

-- Cooldown Override local function toggleCO(state) if state then for _, v in ipairs(game:GetDescendants()) do if v:IsA("NumberValue") and v.Name:lower():find("cooldown") then v.Value = 1 end end end end

-- FPS Lock local function setFPS(val) local n = tonumber(val) if n and setfpscap then setfpscap(n) end end

-- Lock Target local function lockTarget(name) lockedPlayer = Players:FindFirstChild(name) end

-- TP Follow local tpConn local function tpTo(name) tpTarget = Players:FindFirstChild(name) if tpTarget and tpTarget.Character then if tpConn then tpConn:Disconnect() end tpConn = RunService.RenderStepped:Connect(function() local h = tpTarget.Character:FindFirstChild("HumanoidRootPart") if h then LocalPlayer.Character:MoveTo(h.Position) end end) end end

-- UI Generator local y = 40 local function addToggle(txt, func) local btn = Instance.new("TextButton", main) btn.Size = UDim2.new(0, 280, 0, 30) btn.Position = UDim2.new(0, 20, 0, y) btn.BackgroundColor3 = Color3.fromRGB(40,40,40) btn.TextColor3 = Color3.new(1,1,1) btn.Text = "❌ "..txt local state = false btn.MouseButton1Click:Connect(function() state = not state btn.Text = (state and "✅ " or "❌ ") .. txt func(state) end) y = y + 35 end

local function addInput(txt, callback) local label = Instance.new("TextLabel", main) label.Size = UDim2.new(0, 280, 0, 20) label.Position = UDim2.new(0, 20, 0, y) label.BackgroundTransparency = 1 label.Text = txt label.TextColor3 = Color3.new(1,1,1) label.TextXAlignment = Enum.TextXAlignment.Left

local box = Instance.new("TextBox", main)
box.Size = UDim2.new(0, 280, 0, 25)
box.Position = UDim2.new(0, 20, 0, y+20)
box.BackgroundColor3 = Color3.fromRGB(30,30,30)
box.TextColor3 = Color3.new(1,1,1)
box.PlaceholderText = "พิมพ์ที่นี่..."
box.FocusLost:Connect(function()
	callback(box.Text)
end)
y = y + 55

end

-- 🎛️ UI Controls addToggle("ESP (F1)", toggleESP) addToggle("บิน (F2)", toggleFly) addToggle("Ghost HP (F3)", toggleHP) addToggle("DNS Boost (F4)", toggleDNS) addToggle("ลดคูลดาวน์ (F5)", toggleCO) addInput("🔒 ล็อกเป้าหมาย (ชื่อ)", lockTarget) addInput("🚀 วาร์ปตาม (ชื่อ)", tpTo) addInput("🎮 FPS Lock (1-1240)", setFPS)

-- 🎹 Keyboard Bind UserInputService.InputBegan:Connect(function(input, g) if g then return end local key = input.KeyCode if key == Enum.KeyCode.F1 then espOn = not espOn toggleESP(espOn) elseif key == Enum.KeyCode.F2 then flyOn = not flyOn toggleFly(flyOn) elseif key == Enum.KeyCode.F3 then hpOn = not hpOn toggleHP(hpOn) elseif key == Enum.KeyCode.F4 then dnsOn = not dnsOn toggleDNS(dnsOn) elseif key == Enum.KeyCode.F5 then coOn = not coOn toggleCO(coOn) end end)

