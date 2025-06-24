-- 🌐 Delta-Style Auto Load Cheat Panel (LocalScript)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- 🪟 Create draggable main GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "DeltaCheatUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 50, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.Text = "🛠️ Delta UI Panel"
header.TextColor3 = Color3.new(0, 1, 0)
header.TextScaled = true

-- 🔘 Toggle open/close
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "🔼 Open UI"
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.TextColor3 = Color3.new(1, 1, 1)

local opened = true
toggleButton.MouseButton1Click:Connect(function()
	opened = not opened
	frame.Visible = opened
	toggleButton.Text = opened and "🔼 Close UI" or "🔽 Open UI"
end)

-- 📦 ESP Function
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESP_Boxes"
local function toggleESP(state)
	if not state then
		espFolder:ClearAllChildren()
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local part = p.Character.HumanoidRootPart
				local box = Instance.new("BoxHandleAdornment", espFolder)
				box.Adornee = part
				box.Size = Vector3.new(4, 6, 1)
				box.Color3 = Color3.new(0, 1, 0)
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Transparency = 0.2
			end
		end
	end
end

-- ✈️ Fly Function
local flyConnection
local function toggleFly(state)
	local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	if state then
		local bg = Instance.new("BodyGyro", root)
		local bv = Instance.new("BodyVelocity", root)
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		flyConnection = RunService.RenderStepped:Connect(function()
			bg.CFrame = Camera.CFrame
			bv.Velocity = Camera.CFrame.LookVector * 70
		end)
	else
		for _, v in ipairs(root:GetChildren()) do
			if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
		end
		if flyConnection then flyConnection:Disconnect() end
	end
end

-- 🧬 HP / Ghost Mode
local function toggleHP(state)
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not state
		end
	end
end

-- ⚡ Cooldown Override
local function toggleCooldown(state)
	if state then
		for _, obj in ipairs(game:GetDescendants()) do
			if obj:IsA("NumberValue") and obj.Name:lower():find("cooldown") then
				obj.Value = 1
			end
		end
	end
end

-- 📡 DNS Boost
local function toggleDNS(state)
	if setfpscap then
		setfpscap(state and 1000 or 60)
	end
end

-- 🎯 Lock Target System
local lockedPlayer = nil
local function lockTarget(name)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower() == name:lower() then
			lockedPlayer = p
			break
		end
	end
end

-- 🌀 TP Follow
local tpTarget = nil
local tpFollowConn
local function followTarget(name)
	tpTarget = Players:FindFirstChild(name)
	if tpTarget then
		if tpFollowConn then tpFollowConn:Disconnect() end
		tpFollowConn = RunService.RenderStepped:Connect(function()
			if tpTarget.Character and tpTarget.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character:MoveTo(tpTarget.Character.HumanoidRootPart.Position)
			end
		end)
	end
end

-- 🎮 FPS Lock
local function setFPS(input)
	local f = tonumber(input)
	if f and setfpscap then
		setfpscap(f)
	end
end

-- 🧰 Toggle Buttons Generator
local y = 40
local function addToggle(text, func)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = "❌ " .. text
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	local state = false
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = (state and "✅ " or "❌ ") .. text
		func(state)
	end)
	y = y + 35
end

-- 🔣 Input Fields
local function addInput(labelText, callback)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -20, 0, 20)
	lbl.Position = UDim2.new(0, 10, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(1, -20, 0, 25)
	box.Position = UDim2.new(0, 10, 0, y + 20)
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.PlaceholderText = "..."
	box.FocusLost:Connect(function() callback(box.Text) end)
	y = y + 55
end

-- 🔃 Build UI Logic
addToggle("ESP", toggleESP)
addToggle("Fly", toggleFly)
addToggle("HP Ghost", toggleHP)
addToggle("Cooldown 1วิ", toggleCooldown)
addToggle("DNS Boost", toggleDNS)

addInput("🎯 Lock Target (ชื่อ):", lockTarget)
addInput("🌀 TP Follow (ชื่อ):", followTarget)
addInput("🎮 FPS Lock (1-1240):", setFPS)