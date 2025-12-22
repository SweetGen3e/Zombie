-- ตรวจสอบว่าโค้ดรันใน Roblox หรือไม่
if not game:IsLoaded() then
    game.Loaded:Wait()
    warn("เกมโหลดสำเร็จ")
end

-- ตัวแปรเก็บสถานะ
local player = game.Players.LocalPlayer
local isFlying = false
local isNoClip = false
local walkSpeed = 36 -- run speeds
local flySpeed = 400 -- fly
local verticalFlySpeed = 400 -- fly up
local noClipConnection = nil
local preventDeathConnection = nil
local vehicleBodyVelocityConnection = nil
local highlightConnections = {} -- เก็บการเชื่อมต่อ Highlight
local selectionBoxes = {} -- เก็บกรอบสี่เหลี่ยม
local nameGuis = {} -- เก็บ BillboardGui สำหรับชื่อ
local bodyVelocity = nil -- เก็บ BodyVelocity สำหรับการบิน

-- รอ PlayerGui
local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then
    warn("ไม่สามารถเข้าถึง PlayerGui ได้ กรุณาตรวจสอบว่าเกมอนุญาตให้ใช้ UI หรือ Executor รองรับการรัน UI")
    return
end

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FuturisticUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
warn("ScreenGui ถูกสร้างสำเร็จ")

-- สร้างปุ่มเปิด/ปิด UI
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
toggleButton.Text = "💗"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.BorderSizePixel = 0
toggleButton.Parent = screenGui

-- เพิ่ม UIStroke สำหรับปุ่มเปิด/ปิด (เรืองแสง)
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(128, 0, 255)
toggleStroke.Thickness = 2
toggleStroke.Transparency = 0.5
toggleStroke.Parent = toggleButton
warn("ปุ่มเปิด/ปิด UI ถูกสร้างสำเร็จ")

-- สร้าง Frame หลักของ UI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundTransparency = 0.75
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- เพิ่ม UIGradient สำหรับ Frame (ไล่สี)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
})
uiGradient.Rotation = 45
uiGradient.Parent = mainFrame

-- เพิ่ม UIStroke สำหรับ Frame (เรืองแสง)
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(128, 0, 255)
frameStroke.Thickness = 3
frameStroke.Transparency = 0.3
frameStroke.Parent = mainFrame
warn("Frame หลักของ UI ถูกสร้างสำเร็จ")

-- เพิ่ม Label ชื่อเมนู
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "เมนูหลัก"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SciFi
titleLabel.Parent = mainFrame
warn("Label ชื่อเมนูถูกสร้างสำเร็จ")
-- สร้าง Frame สำหรับช่องตั้งค่าความเร็ว
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -20, 0, 60)
speedFrame.Position = UDim2.new(0, 10, 0, 40)
speedFrame.BackgroundTransparency = 0.9
speedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
speedFrame.Parent = mainFrame

-- เพิ่ม UIGradient สำหรับ speedFrame
local speedGradient = Instance.new("UIGradient")
speedGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
})
speedGradient.Rotation = 45
speedGradient.Parent = speedFrame

-- เพิ่ม UIStroke สำหรับ speedFrame
local speedStroke = Instance.new("UIStroke")
speedStroke.Color = Color3.fromRGB(128, 0, 255)
speedStroke.Thickness = 2
speedStroke.Transparency = 0.5
speedStroke.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 40)
speedLabel.Position = UDim2.new(0, 10, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "ความเร็วเดิน:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Parent = speedFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.55, 0, 0, 40)
speedBox.Position = UDim2.new(0.45, 0, 0, 10)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedBox.Text = tostring(walkSpeed) -- ค่าเริ่มต้น 36
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextScaled = true
speedBox.Parent = speedFrame

-- เพิ่ม ScrollingFrame สำหรับตัวเลื่อน (สำหรับปุ่มฟังก์ชัน)
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -110)
scrollingFrame.Position = UDim2.new(0, 10, 0, 110)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = mainFrame
warn("ScrollingFrame ถูกสร้างสำเร็จ")

-- เพิ่ม UIListLayout เพื่อจัดเรียงปุ่ม
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollingFrame
warn("UIListLayout ถูกสร้างสำเร็จ")
-- สร้าง TextBox และปุ่มส่งสำหรับกล่องข้อความ
local messageFrame = Instance.new("Frame")
messageFrame.Size = UDim2.new(1, -20, 0, 60)
messageFrame.Position = UDim2.new(0, 10, 1, -70)
messageFrame.BackgroundTransparency = 0.9
messageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
messageFrame.Visible = false
messageFrame.Parent = mainFrame

-- เพิ่ม UIGradient สำหรับ messageFrame
local messageGradient = Instance.new("UIGradient")
messageGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
})
messageGradient.Rotation = 45
messageGradient.Parent = messageFrame

-- เพิ่ม UIStroke สำหรับ messageFrame
local messageStroke = Instance.new("UIStroke")
messageStroke.Color = Color3.fromRGB(128, 0, 255)
messageStroke.Thickness = 2
messageStroke.Transparency = 0.5
messageStroke.Parent = messageFrame

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0.25, 0, 0, 40)
sendButton.Position = UDim2.new(0.75, 0, 0, 10)
sendButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
sendButton.Text = "ส่ง"
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.TextScaled = true
sendButton.Parent = messageFrame

-- สีสำหรับปุ่ม
local buttonOnColor = Color3.fromRGB(128, 0, 255) -- สีเมื่อเปิด
local buttonOffColor = Color3.fromRGB(50, 0, 100) -- สีเมื่อปิด

-- ฟังก์ชันสร้างปุ่มสำหรับฟังก์ชัน
local function createToggleButton(label, callback)
    local toggleState = false
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.BackgroundColor3 = buttonOffColor
    button.Text = label .. " (ปิด)"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.SciFi
    button.BorderSizePixel = 0
    button.Parent = scrollingFrame

    -- เพิ่ม UIGradient สำหรับปุ่ม
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, buttonOffColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 150))
    })
    buttonGradient.Rotation = 45
    buttonGradient.Parent = button

    -- เพิ่ม UIStroke สำหรับปุ่ม (เรืองแสง)
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(128, 0, 255)
    buttonStroke.Thickness = 2
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button

    button.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        button.Text = label .. (toggleState and " (เปิด)" or " (ปิด)")
        button.BackgroundColor3 = toggleState and buttonOnColor or buttonOffColor
        buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, toggleState and buttonOnColor or buttonOffColor),
            ColorSequenceKeypoint.new(1, toggleState and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(80, 0, 150))
        })
        callback(toggleState)
    end)

    -- อัปเดต CanvasSize ของ ScrollingFrame
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    warn("ปุ่ม " .. label .. " ถูกสร้างสำเร็จ")

    return button -- คืนค่า button เพื่อใช้ในการจัดตำแหน่ง
end
-- ตัวแปรเก็บสถานะปุ่มบิน
local flyButton = nil

-- ฟังก์ชันบินอัตโนมัติ (ปรับให้วัตถุที่นั่งบินได้ และเพิ่มตัวเลื่อน)
flyButton = createToggleButton("บินอัตโนมัติ", function(isActive)
    isFlying = isActive
    if isFlying then
        coroutine.wrap(function()
            -- รอตัวละคร
            if not player.Character then
                player.CharacterAdded:Wait()
                warn("ตัวละครโหลดสำเร็จสำหรับฟังก์ชันบินอัตโนมัติ")
            end
            local character = player.Character
            local humanoid = character:WaitForChild("Humanoid", 5)
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            if not (humanoid and rootPart) then
                warn("ไม่พบ Humanoid หรือ HumanoidRootPart สำหรับฟังก์ชันบินอัตโนมัติ")
                return
            end

            -- ตรวจสอบว่าตัวละครนั่งอยู่บนวัตถุหรือไม่
            local vehiclePart = nil
            if humanoid.SeatPart then
                vehiclePart = humanoid.SeatPart.Parent
                warn("ตรวจพบวัตถุที่นั่ง: " .. vehiclePart.Name)
            else
                for _, constraint in pairs(rootPart:GetJoints()) do
                    if constraint:IsA("Weld") or constraint:IsA("Motor") then
                        vehiclePart = constraint.Part1 == rootPart and constraint.Part0 or constraint.Part1
                        if vehiclePart then
                            warn("ตรวจพบวัตถุที่นั่งผ่าน Weld/Motor: " .. vehiclePart.Name)
                            break
                        end
                    end
                end
            end

            -- ปลดล็อกข้อจำกัด
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            rootPart.Anchored = false
            for _, constraint in pairs(rootPart:GetJoints()) do
                if constraint:IsA("Weld") or constraint:IsA("WeldConstraint") then
                    constraint:Destroy()
                    warn("พบและลบ Weld/WeldConstraint ที่ยึดตัวละคร")
                end
            end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Anchored = false
                end
            end
            humanoid.PlatformStand = true
            humanoid.Sit = false

            -- ถ้ามีวัตถุที่นั่ง ปลดล็อกวัตถุด้วย
            if vehiclePart then
                for _, part in pairs(vehiclePart:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Anchored = false
                    end
                end
            end

            -- สร้าง BodyVelocity
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = vehiclePart or rootPart -- ถ้ามีวัตถุที่นั่ง ใช้ BodyVelocity กับวัตถุ

            -- ยกตัวละครหรือวัตถุขึ้นเมื่อเริ่มบิน
            local targetPart = vehiclePart or rootPart
            targetPart.CFrame = targetPart.CFrame + Vector3.new(0, 10, 0)
            warn("ยก" .. (vehiclePart and "วัตถุ" or "ตัวละคร") .. "ขึ้น 10 หน่วย")
        end)()
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                humanoid.PlatformStand = false
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.Anchored = false
                    end
                end
            end
            if vehiclePart then
                for _, part in pairs(vehiclePart:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.Anchored = false
                    end
                end
            end
        end
    end

    -- สร้าง Frame สำหรับตัวเลื่อนและช่องปรับความสูง (เมื่อเปิดปุ่มบิน)
    local flySettingsFrame = Instance.new("Frame")
    flySettingsFrame.Size = UDim2.new(1, -10, 0, 120)
    flySettingsFrame.BackgroundTransparency = 0.9
    flySettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    flySettingsFrame.Visible = isActive
    flySettingsFrame.LayoutOrder = flyButton.LayoutOrder + 1 -- ให้อยู่ด้านล่างของปุ่มบิน
    flySettingsFrame.Parent = scrollingFrame

    -- เพิ่ม UIGradient สำหรับ flySettingsFrame
    local flySettingsGradient = Instance.new("UIGradient")
    flySettingsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
    })
    flySettingsGradient.Rotation = 45
    flySettingsGradient.Parent = flySettingsFrame

    -- เพิ่ม UIStroke สำหรับ flySettingsFrame
    local flySettingsStroke = Instance.new("UIStroke")
    flySettingsStroke.Color = Color3.fromRGB(128, 0, 255)
    flySettingsStroke.Thickness = 2
    flySettingsStroke.Transparency = 0.5
    flySettingsStroke.Parent = flySettingsFrame

    -- สร้างปุ่มเลื่อนขึ้น
    local flyUpButton = Instance.new("TextButton")
    flyUpButton.Size = UDim2.new(0.45, 0, 0, 40)
    flyUpButton.Position = UDim2.new(0, 10, 0, 10)
    flyUpButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
    flyUpButton.Text = "บินขึ้น"
    flyUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyUpButton.TextScaled = true
    flyUpButton.Parent = flySettingsFrame

    -- เพิ่ม UIStroke สำหรับปุ่มบินขึ้น
    local flyUpStroke = Instance.new("UIStroke")
    flyUpStroke.Color = Color3.fromRGB(128, 0, 255)
    flyUpStroke.Thickness = 2
    flyUpStroke.Transparency = 0.5
    flyUpStroke.Parent = flyUpButton

    -- สร้างปุ่มเลื่อนลง
    local flyDownButton = Instance.new("TextButton")
    flyDownButton.Size = UDim2.new(0.45, 0, 0, 40)
    flyDownButton.Position = UDim2.new(0.55, 0, 0, 10)
    flyDownButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
    flyDownButton.Text = "บินลง"
    flyDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyDownButton.TextScaled = true
    flyDownButton.Parent = flySettingsFrame

    -- เพิ่ม UIStroke สำหรับปุ่มบินลง
    local flyDownStroke = Instance.new("UIStroke")
    flyDownStroke.Color = Color3.fromRGB(128, 0, 255)
    flyDownStroke.Thickness = 2
    flyDownStroke.Transparency = 0.5
    flyDownStroke.Parent = flyDownButton

    -- สร้างช่องตั้งค่าความเร็วการบินแนวตั้ง
    local verticalSpeedLabel = Instance.new("TextLabel")
    verticalSpeedLabel.Size = UDim2.new(0.4, 0, 0, 40)
    verticalSpeedLabel.Position = UDim2.new(0, 10, 0, 60)
    verticalSpeedLabel.BackgroundTransparency = 1
    verticalSpeedLabel.Text = "ความเร็วสูง:"
    verticalSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    verticalSpeedLabel.TextScaled = true
    verticalSpeedLabel.Parent = flySettingsFrame

    local verticalSpeedBox = Instance.new("TextBox")
    verticalSpeedBox.Size = UDim2.new(0.55, 0, 0, 40)
    verticalSpeedBox.Position = UDim2.new(0.45, 0, 0, 60)
    verticalSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    verticalSpeedBox.Text = tostring(verticalFlySpeed)
    verticalSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    verticalSpeedBox.TextScaled = true
    verticalSpeedBox.Parent = flySettingsFrame

    -- อัปเดตความเร็วการบินแนวตั้ง
    verticalSpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
        local newSpeed = tonumber(verticalSpeedBox.Text)
        if newSpeed then
            if newSpeed < 0 then
                newSpeed = 0
                verticalSpeedBox.Text = "0"
            end
            verticalFlySpeed = newSpeed
            warn("ตั้งค่าความเร็วการบินแนวตั้งเป็น: " .. verticalFlySpeed)
        else
            verticalSpeedBox.Text = tostring(verticalFlySpeed)
            warn("กรุณาใส่ตัวเลขที่ถูกต้องสำหรับความเร็วการบินแนวตั้ง")
        end
    end)

    -- ฟังก์ชันเมื่อกดปุ่มบินขึ้น
    flyUpButton.MouseButton1Down:Connect(function()
        if isFlying and bodyVelocity then
            bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, verticalFlySpeed, 0)
            warn("บินขึ้น (ความเร็วแนวตั้ง: " .. verticalFlySpeed .. ")")
        end
    end)

    flyUpButton.MouseButton1Up:Connect(function()
        if isFlying and bodyVelocity then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    bodyVelocity.Velocity = Vector3.new(humanoid.MoveDirection.X * flySpeed, 0, humanoid.MoveDirection.Z * flySpeed)
                end
            end
        end
    end)

    -- ฟังก์ชันเมื่อกดปุ่มบินลง
    flyDownButton.MouseButton1Down:Connect(function()
        if isFlying and bodyVelocity then
            bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, -verticalFlySpeed, 0)
            warn("บินลง (ความเร็วแนวตั้ง: " .. verticalFlySpeed .. ")")
        end
    end)

    flyDownButton.MouseButton1Up:Connect(function()
        if isFlying and bodyVelocity then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    bodyVelocity.Velocity = Vector3.new(humanoid.MoveDirection.X * flySpeed, 0, humanoid.MoveDirection.Z * flySpeed)
                end
            end
        end
    end)

    -- อัปเดตการเคลื่อนที่ในแนวราบ
    if isActive then
        coroutine.wrap(function()
            while isFlying do
                if bodyVelocity then
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local moveDirection = humanoid.MoveDirection * flySpeed
                            bodyVelocity.Velocity = Vector3.new(moveDirection.X, bodyVelocity.Velocity.Y, moveDirection.Z)
                        end
                    end
                end
                wait()
            end
        end)()
    end

    -- ลบ Frame เมื่อปิดการบิน
    if not isActive then
        flySettingsFrame:Destroy()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end
end)

-- ฟังก์ชันตั้งค่าความเร็วในการเดิน (ปรับทันทีเมื่อพิมพ์)
speedBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newSpeed = tonumber(speedBox.Text)
    if newSpeed then
        if newSpeed < 0 then
            newSpeed = 0
            speedBox.Text = "0"
            warn("ความเร็วต้องไม่ต่ำกว่า 0")
        elseif newSpeed > 1000000 then
            newSpeed = 1000000
            speedBox.Text = "1000000"
            warn("ความเร็วสูงสุดคือ 1000000")
        end
        walkSpeed = newSpeed
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkSpeed
                warn("ตั้งค่าความเร็วในการเดินเป็น: " .. walkSpeed)

                -- ถ้ากำลังนั่งบนวัตถุ อัปเดตความเร็วของวัตถุ
                local vehiclePart = nil
                if humanoid.SeatPart then
                    vehiclePart = humanoid.SeatPart.Parent
                    warn("ตรวจพบวัตถุที่นั่ง: " .. vehiclePart.Name)
                end
                if vehiclePart then
                    local bodyVelocity = vehiclePart:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
                    bodyVelocity.Velocity = humanoid.MoveDirection * walkSpeed
                    bodyVelocity.Parent = vehiclePart
                    warn("ตั้งค่าความเร็วของวัตถุที่นั่งเป็น: " .. walkSpeed)
                end
            end
        end
    else
        speedBox.Text = tostring(walkSpeed)
        warn("กรุณาใส่ตัวเลขที่ถูกต้อง")
    end
end)

-- ฟังก์ชันเดินเร็วขึ้น (รองรับวัตถุที่นั่ง)
createToggleButton("เดินเร็วขึ้น", function(state)
    if not player.Character then
        player.CharacterAdded:Wait()
        warn("ตัวละครโหลดสำเร็จสำหรับฟังก์ชันเดินเร็วขึ้น")
    end
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and rootPart) then
        warn("ไม่พบ Humanoid หรือ HumanoidRootPart สำหรับฟังก์ชันเดินเร็วขึ้น")
        return
    end

    if state then
        humanoid.WalkSpeed = walkSpeed
        warn("เดินเร็วขึ้น: เปิด (ความเร็ว: " .. walkSpeed .. ")")

        -- ถ้ากำลังนั่งบนวัตถุ ใช้ BodyVelocity เพื่อควบคุมความเร็ว
        local vehiclePart = nil
        if humanoid.SeatPart then
            vehiclePart = humanoid.SeatPart.Parent
            warn("ตรวจพบวัตถุที่นั่ง: " .. vehiclePart.Name)
        end
        if vehiclePart then
            for _, part in pairs(vehiclePart:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = vehiclePart
            vehicleBodyVelocityConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not state or not vehiclePart then return end
                bodyVelocity.Velocity = humanoid.MoveDirection * walkSpeed
            end)
        end
    else
        humanoid.WalkSpeed = 16
        warn("เดินเร็วขึ้น: ปิด")
        if vehicleBodyVelocityConnection then
            vehicleBodyVelocityConnection:Disconnect()
            vehicleBodyVelocityConnection = nil
        end
    end
end)
-- ฟังก์ชันกันแบน (เดินทะลุ + ป้องกันตาย)
createToggleButton("กันแบน (เดินทะลุ)", function(state)
    isNoClip = state
    if not player.Character then
        player.CharacterAdded:Wait()
        warn("ตัวละครโหลดสำเร็จสำหรับฟังก์ชันกันแบน")
    end
    local character = player.Character
    if not character then
        warn("ไม่พบตัวละครสำหรับฟังก์ชันกันแบน")
        return
    end

    if state then
        warn("กันแบน (เดินทะลุ): เปิด")
        warn("คำเตือน: การใช้ฟังก์ชันนี้อาจถูกตรวจจับโดยระบบป้องกันการโกงของเกม!")
        noClipConnection = game:GetService("RunService").Stepped:Connect(function()
            if not isNoClip then return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)

        -- ป้องกันตัวละครตาย
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            preventDeathConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if humanoid.Health <= 0 then
                    humanoid.Health = 100
                    warn("ป้องกันตัวละครตาย: คืนค่า Health เป็น 100")
                end
            end)
        end
    else
        warn("กันแบน (เดินทะลุ): ปิด")
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        if preventDeathConnection then
            preventDeathConnection:Disconnect()
            preventDeathConnection = nil
        end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- ตัวแปรเก็บสถานะปุ่มส่งข้อความ
local messageButton = nil

-- ฟังก์ชันกล่องข้อความ (เลือกผู้เล่นได้)
messageButton = createToggleButton("กล่องข้อความ", function(state)
    messageFrame.Visible = state
    -- สร้าง Frame สำหรับเลือกผู้เล่น (เมื่อเปิดปุ่มส่งข้อความ)
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(1, -10, 0, 150)
    playerListFrame.BackgroundTransparency = 0.9
    playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    playerListFrame.Visible = state
    playerListFrame.LayoutOrder = messageButton.LayoutOrder + 1 -- ให้อยู่ด้านล่างของปุ่มกล่องข้อความ
    playerListFrame.Parent = scrollingFrame

    -- เพิ่ม UIGradient สำหรับ playerListFrame
    local playerListGradient = Instance.new("UIGradient")
    playerListGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
    })
    playerListGradient.Rotation = 45
    playerListGradient.Parent = playerListFrame

    -- เพิ่ม UIStroke สำหรับ playerListFrame
    local playerListStroke = Instance.new("UIStroke")
    playerListStroke.Color = Color3.fromRGB(128, 0, 255)
    playerListStroke.Thickness = 2
    playerListStroke.Transparency = 0.5
    playerListStroke.Parent = playerListFrame

    local playerListScrollingFrame = Instance.new("ScrollingFrame")
    playerListScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    playerListScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    playerListScrollingFrame.BackgroundTransparency = 1
    playerListScrollingFrame.ScrollBarThickness = 5
    playerListScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
    playerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerListScrollingFrame.Parent = playerListFrame

    local playerListLayout = Instance.new("UIListLayout")
    playerListLayout.Padding = UDim.new(0, 5)
    playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerListLayout.Parent = playerListScrollingFrame

    -- ฟังก์ชันอัปเดตผู้เล่นในเซิร์ฟเวอร์
    local function updatePlayerList()
        for _, child in pairs(playerListScrollingFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            if targetPlayer ~= player then
                local playerButton = Instance.new("TextButton")
                playerButton.Size = UDim2.new(1, -10, 0, 30)
                playerButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
                playerButton.Text = targetPlayer.Name
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.TextScaled = true
                playerButton.Font = Enum.Font.SciFi
                playerButton.BorderSizePixel = 0
                playerButton.Parent = playerListScrollingFrame

                -- เพิ่ม UIStroke สำหรับปุ่มผู้เล่น
                local buttonStroke = Instance.new("UIStroke")
                buttonStroke.Color = Color3.fromRGB(128, 0, 255)
                buttonStroke.Thickness = 2
                buttonStroke.Transparency = 0.5
                buttonStroke.Parent = playerButton

                playerButton.MouseButton1Click:Connect(function()
                    local message = messageBox.Text
                    if message and message ~= "" and message ~= "พิมพ์ข้อความที่นี่..." then
                        local targetCharacter = targetPlayer.Character
                        if targetCharacter then
                            -- สร้าง BillboardGui เพื่อแสดงข้อความบนหน้าจอของผู้เล่นคนนั้น
                            local messageGui = Instance.new("BillboardGui")
                            messageGui.Size = UDim2.new(4, 0, 1, 0)
                            messageGui.StudsOffset = Vector3.new(0, 5, 0) -- ด้านบนของตัวละคร
                            messageGui.AlwaysOnTop = true
                            messageGui.Parent = targetCharacter

                            local messageLabel = Instance.new("TextLabel")
                            messageLabel.Size = UDim2.new(1, 0, 1, 0)
                            messageLabel.BackgroundTransparency = 1
                            messageLabel.Text = message
                            messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            messageLabel.TextScaled = true
                            messageLabel.Font = Enum.Font.SciFi
                            messageLabel.Parent = messageGui

                            -- ลบข้อความหลังจาก 5 วินาที
                            delay(5, function()
                                messageGui:Destroy()
                            end)

                            warn("ส่งข้อความไปยัง " .. targetPlayer.Name .. ": " .. message)
                            messageBox.Text = "พิมพ์ข้อความที่นี่..."
                        else
                            warn("ไม่พบตัวละครของ " .. targetPlayer.Name)
                        end
                    end
                end)
            end
        end

        playerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end

    -- อัปเดตผู้เล่นเมื่อมีผู้เล่นเข้ามา/ออกจากเซิร์ฟเวอร์
    local playerAddedConnection
    local playerRemovingConnection

    if state then
        updatePlayerList()
        playerAddedConnection = game.Players.PlayerAdded:Connect(updatePlayerList)
        playerRemovingConnection = game.Players.PlayerRemoving:Connect(updatePlayerList)
        warn("กล่องข้อความ: เปิด")
    else
        if playerAddedConnection then playerAddedConnection:Disconnect() end
        if playerRemovingConnection then playerRemovingConnection:Disconnect() end
        playerListFrame:Destroy()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
        warn("กล่องข้อความ: ปิด")
    end
end)
-- ตัวแปรเก็บสถานะปุ่มวาร์ป
local teleportButton = nil

-- ฟังก์ชันวาร์ปไปหาผู้เล่น
teleportButton = createToggleButton("วาร์ปไปหาผู้เล่น", function(state)
    -- สร้าง Frame สำหรับรายชื่อผู้เล่น (เมื่อเปิดปุ่มวาร์ป)
    local teleportFrame = Instance.new("Frame")
    teleportFrame.Size = UDim2.new(1, -10, 0, 150)
    teleportFrame.BackgroundTransparency = 0.9
    teleportFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    teleportFrame.Visible = state
    teleportFrame.LayoutOrder = teleportButton.LayoutOrder + 1 -- ให้อยู่ด้านล่างของปุ่มวาร์ป
    teleportFrame.Parent = scrollingFrame

    -- เพิ่ม UIGradient สำหรับ teleportFrame
    local teleportGradient = Instance.new("UIGradient")
    teleportGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
    })
    teleportGradient.Rotation = 45
    teleportGradient.Parent = teleportFrame

    -- เพิ่ม UIStroke สำหรับ teleportFrame
    local teleportStroke = Instance.new("UIStroke")
    teleportStroke.Color = Color3.fromRGB(128, 0, 255)
    teleportStroke.Thickness = 2
    teleportStroke.Transparency = 0.5
    teleportStroke.Parent = teleportFrame

    local teleportScrollingFrame = Instance.new("ScrollingFrame")
    teleportScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    teleportScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    teleportScrollingFrame.BackgroundTransparency = 1
    teleportScrollingFrame.ScrollBarThickness = 5
    teleportScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
    teleportScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    teleportScrollingFrame.Parent = teleportFrame

    local teleportListLayout = Instance.new("UIListLayout")
    teleportListLayout.Padding = UDim.new(0, 5)
    teleportListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    teleportListLayout.Parent = teleportScrollingFrame

    -- ฟังก์ชันอัปเดตผู้เล่นในเซิร์ฟเวอร์
    local function updatePlayerList()
        for _, child in pairs(teleportScrollingFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            if targetPlayer ~= player then
                local playerButton = Instance.new("TextButton")
                playerButton.Size = UDim2.new(1, -10, 0, 30)
                playerButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
                playerButton.Text = targetPlayer.Name
                playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerButton.TextScaled = true
                playerButton.Font = Enum.Font.SciFi
                playerButton.BorderSizePixel = 0
                playerButton.Parent = teleportScrollingFrame

                -- เพิ่ม UIStroke สำหรับปุ่มผู้เล่น
                local buttonStroke = Instance.new("UIStroke")
                buttonStroke.Color = Color3.fromRGB(128, 0, 255)
                buttonStroke.Thickness = 2
                buttonStroke.Transparency = 0.5
                buttonStroke.Parent = playerButton

                playerButton.MouseButton1Click:Connect(function()
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        warn("ไม่พบตัวละครของผู้เล่น")
                        return
                    end
                    local targetCharacter = targetPlayer.Character
                    if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                        local rootPart = player.Character.HumanoidRootPart
                        rootPart.CFrame = targetCharacter.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
                        warn("วาร์ปไปหา: " .. targetPlayer.Name)
                    else
                        warn("ไม่พบตัวละครของ " .. targetPlayer.Name)
                    end
                end)
            end
        end

        teleportScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, teleportListLayout.AbsoluteContentSize.Y)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end

    -- อัปเดตผู้เล่นเมื่อมีผู้เล่นเข้ามา/ออกจากเซิร์ฟเวอร์
    local playerAddedConnection
    local playerRemovingConnection

    if state then
        updatePlayerList()
        playerAddedConnection = game.Players.PlayerAdded:Connect(updatePlayerList)
        playerRemovingConnection = game.Players.PlayerRemoving:Connect(updatePlayerList)
        warn("วาร์ปไปหาผู้เล่น: เปิด")
    else
        if playerAddedConnection then playerAddedConnection:Disconnect() end
        if playerRemovingConnection then playerRemovingConnection:Disconnect() end
        teleportFrame:Destroy()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
        warn("วาร์ปไปหาผู้เล่น: ปิด")
    end
end)
-- ตัวแปรเก็บสถานะปุ่มดูตำแหน่ง
local positionButton = nil

-- ตัวแปรสำหรับการตั้งค่าระยะและขนาดชื่อ
local nameDistance = 100 -- ระยะเริ่มต้นที่มองเห็นชื่อ
local nameSize = 16 -- ขนาดชื่อเริ่มต้น

-- ฟังก์ชันดูตำแหน่งทุกคนในเซิร์ฟเวอร์
positionButton = createToggleButton("ดูตำแหน่งทุกคน", function(state)
    -- ล้าง Highlight และ SelectionBox เก่า
    for _, connection in pairs(highlightConnections) do
        connection:Disconnect()
    end
    highlightConnections = {}
    for _, box in pairs(selectionBoxes) do
        box:Destroy()
    end
    selectionBoxes = {}
    for _, gui in pairs(nameGuis) do
        gui:Destroy()
    end
    nameGuis = {}

    -- สร้าง Frame สำหรับตั้งค่าระยะและขนาดชื่อ
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(1, -10, 0, 120)
    settingsFrame.BackgroundTransparency = 0.9
    settingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    settingsFrame.Visible = state
    settingsFrame.LayoutOrder = positionButton.LayoutOrder + 1 -- ให้อยู่ด้านล่างของปุ่มดูตำแหน่ง
    settingsFrame.Parent = scrollingFrame

    -- เพิ่ม UIGradient สำหรับ settingsFrame
    local settingsGradient = Instance.new("UIGradient")
    settingsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 0, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
    })
    settingsGradient.Rotation = 45
    settingsGradient.Parent = settingsFrame

    -- เพิ่ม UIStroke สำหรับ settingsFrame
    local settingsStroke = Instance.new("UIStroke")
    settingsStroke.Color = Color3.fromRGB(128, 0, 255)
    settingsStroke.Thickness = 2
    settingsStroke.Transparency = 0.5
    settingsStroke.Parent = settingsFrame

    -- สร้างช่องตั้งค่าระยะที่มองเห็นชื่อ
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0.4, 0, 0, 40)
    distanceLabel.Position = UDim2.new(0, 10, 0, 10)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "ระยะชื่อ:"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextScaled = true
    distanceLabel.Parent = settingsFrame

    local distanceBox = Instance.new("TextBox")
    distanceBox.Size = UDim2.new(0.55, 0, 0, 40)
    distanceBox.Position = UDim2.new(0.45, 0, 0, 10)
    distanceBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    distanceBox.Text = tostring(nameDistance)
    distanceBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceBox.TextScaled = true
    distanceBox.Parent = settingsFrame

    -- สร้างช่องตั้งค่าขนาดชื่อ
    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Size = UDim2.new(0.4, 0, 0, 40)
    sizeLabel.Position = UDim2.new(0, 10, 0, 60)
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.Text = "ขนาดชื่อ:"
    sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeLabel.TextScaled = true
    sizeLabel.Parent = settingsFrame

    local sizeBox = Instance.new("TextBox")
    sizeBox.Size = UDim2.new(0.55, 0, 0, 40)
    sizeBox.Position = UDim2.new(0.45, 0, 0, 60)
    sizeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sizeBox.Text = tostring(nameSize)
    sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeBox.TextScaled = true
    sizeBox.Parent = settingsFrame

    -- อัปเดตระยะชื่อ
    distanceBox:GetPropertyChangedSignal("Text"):Connect(function()
        local newDistance = tonumber(distanceBox.Text)
        if newDistance then
            if newDistance < 0 then
                newDistance = 0
                distanceBox.Text = "0"
            end
            nameDistance = newDistance
            warn("ตั้งค่าระยะชื่อเป็น: " .. nameDistance)
        else
            distanceBox.Text = tostring(nameDistance)
            warn("กรุณาใส่ตัวเลขที่ถูกต้องสำหรับระยะชื่อ")
        end
    end)

    -- อัปเดตขนาดชื่อ
    sizeBox:GetPropertyChangedSignal("Text"):Connect(function()
        local newSize = tonumber(sizeBox.Text)
        if newSize then
            if newSize < 16 then
                newSize = 16
                sizeBox.Text = "16"
            elseif newSize > 10000 then
                newSize = 10000
                sizeBox.Text = "10000"
            end
            nameSize = newSize
            warn("ตั้งค่าขนาดชื่อเป็น: " .. nameSize)
        else
            sizeBox.Text = tostring(nameSize)
            warn("กรุณาใส่ตัวเลขที่ถูกต้องสำหรับขนาดชื่อ")
        end
    end)

    if state then
        warn("ดูตำแหน่งทุกคน: เปิด")

        -- ฟังก์ชันเพิ่ม SelectionBox และชื่อ
        local function addHighlightAndName(targetPlayer)
            if targetPlayer == player then return end -- ข้ามตัวเรา

            -- รอตัวละคร
            local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
            if not targetCharacter then return end

            -- สร้าง SelectionBox รอบตัว (สีน้ำเงิน)
            local selectionBox = Instance.new("SelectionBox")
            selectionBox.LineThickness = 0.05
            selectionBox.Color3 = Color3.fromRGB(0, 0, 255)
            selectionBox.Adornee = targetCharacter
            selectionBox.Parent = targetCharacter

            -- สร้าง BillboardGui สำหรับแสดงชื่อและระยะห่าง
            local nameGui = Instance.new("BillboardGui")
            nameGui.Size = UDim2.new(4, 0, 1, 0)
            nameGui.StudsOffset = Vector3.new(0, 4, 0) -- ด้านบนของตัวละคร
            nameGui.AlwaysOnTop = true
            nameGui.Parent = targetCharacter

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = targetPlayer.Name
            nameLabel.TextColor3 = Color3.fromRGB(0, 0, 255)
            nameLabel.TextScaled = false
            nameLabel.TextSize = nameSize
            nameLabel.Font = Enum.Font.SciFi
            nameLabel.Parent = nameGui

            table.insert(selectionBoxes, selectionBox)
            table.insert(nameGuis, nameGui)

            -- อัปเดตตำแหน่งและข้อมูล
            local connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not targetPlayer.Character or not player.Character then
                    selectionBox:Destroy()
                    nameGui:Destroy()
                    return
                end

                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if not targetRoot or not myRoot then
                    selectionBox:Destroy()
                    nameGui:Destroy()
                    return
                end

                -- คำนวณระยะห่าง
                local distance = (targetRoot.Position - myRoot.Position).Magnitude
                if distance <= nameDistance then
                    nameLabel.Text = targetPlayer.Name .. " | ห่าง: " .. math.floor(distance) .. " studs"
                    nameLabel.TextSize = nameSize
                else
                    nameLabel.Text = ""
                end
            end)

            table.insert(highlightConnections, connection)
        end

        -- เพิ่ม SelectionBox และชื่อให้ผู้เล่นทุกคนในเซิร์ฟเวอร์
        for _, targetPlayer in pairs(game.Players:GetPlayers()) do
            addHighlightAndName(targetPlayer)
        end

        -- อัปเดตเมื่อมีผู้เล่นเข้า/ออก
        local playerAddedConnection = game.Players.PlayerAdded:Connect(function(newPlayer)
            addHighlightAndName(newPlayer)
        end)

        local playerRemovingConnection = game.Players.PlayerRemoving:Connect(function(leavingPlayer)
            for i, box in pairs(selectionBoxes) do
                box:Destroy()
                table.remove(selectionBoxes, i)
                break
            end
            for i, gui in pairs(nameGuis) do
                gui:Destroy()
                table.remove(nameGuis, i)
                break
            end
            for i, connection in pairs(highlightConnections) do
                connection:Disconnect()
                table.remove(highlightConnections, i)
                break
            end
        end)

        table.insert(highlightConnections, playerAddedConnection)
        table.insert(highlightConnections, playerRemovingConnection)
    else
        warn("ดูตำแหน่งทุกคน: ปิด")
        settingsFrame:Destroy()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end
end)
-- ฟังก์ชันลาก UI
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ฟังก์ชันเปิด/ปิด UI
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.Text = mainFrame.Visible and "💗" or "💗"
    toggleButton.BackgroundColor3 = mainFrame.Visible and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(50, 0, 100)
    warn(mainFrame.Visible and "UI: เปิด" or "UI: ปิด")
end)
