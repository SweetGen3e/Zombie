-- โหลด OrionLib UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

OrionLib:MakeNotification({
    Name = "SummonX",
    Content = "UI Loaded Successfully!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- สร้างหน้าต่าง
local Window = OrionLib:MakeWindow({Name = "SummonX", HidePremium = false, SaveConfig = false, IntroText = "ยินดีต้อนรับสู่ SummonX"})

-- Tab Main
local MainTab = Window:MakeTab({
    Name = "🎮 เมนู",
    Icon = "rbxassetid://6022668888",
    PremiumOnly = false
})

-- Section Main
MainTab:AddToggle({
    Name = "AutoCast",
    Default = false,
    Callback = function(v)
        _G.AutoCast = v
        pcall(function()
            while _G.AutoCast do task.wait(0.1)
                local Rod = Char:FindFirstChildOfClass("Tool")
                if Rod and Rod:FindFirstChild("events") then
                    Rod.events.cast:FireServer(100,1)
                end
            end
        end)
    end
})

MainTab:AddToggle({
    Name = "AutoShake",
    Default = false,
    Callback = function(v)
        _G.AutoShake = v
        pcall(function()
            while _G.AutoShake do task.wait(0.01)
                local PlayerGUI = LocalPlayer:WaitForChild("PlayerGui")
                local shakeUI = PlayerGUI:FindFirstChild("shakeui")
                if shakeUI and shakeUI.Enabled then
                    local safezone = shakeUI:FindFirstChild("safezone")
                    if safezone then
                        local button = safezone:FindFirstChild("button")
                        if button and button:IsA("ImageButton") and button.Visible then
                            GuiService.SelectedObject = button
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    end
                end
            end
        end)
    end
})

MainTab:AddToggle({
    Name = "AutoReel",
    Default = false,
    Callback = function(v)
        _G.AutoReel = v
        pcall(function()
            while _G.AutoReel do task.wait()
                for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if v:IsA "ScreenGui" and v.Name == "reel" then
                        if v:FindFirstChild "bar" then
                            task.wait(0.05)
                            ReplicatedStorage.events.reelfinished:FireServer(100,true)
                        end
                    end
                end
            end
        end)
    end
})

MainTab:AddToggle({
    Name = "Freeze Character",
    Default = false,
    Callback = function(v)
        Char.HumanoidRootPart.Anchored = v
    end
})

-- UI Loader
OrionLib:Init()