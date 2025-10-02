local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local Char = LocalPlayer.Character
local Humanoid = Char.Humanoid
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

equipitem = function(v)
if LocalPlayer.Backpack:FindFirstChild(v) then
    local a = LocalPlayer.Backpack:FindFirstChild(v)
        Humanoid:EquipTool(a)
    end
end


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fisch", "DarkTheme")
local Tab = Window:NewTab("MAIN")
local Section = Tab:NewSection("MAIN")

-- AutoCast
Section:NewToggle("AutoCast", "", function(v)
_G.AutoCast = v
     pcall(function()
while _G.AutoCast do wait()
    local Rod = Char:FindFirstChildOfClass("Tool")
                task.wait(.1)
                    Rod.events.cast:FireServer(100,1)
        end
    end)
end)

Section:NewToggle("AutoShake", "", function(v)
    _G.AutoShake = v
pcall(function()
while _G.AutoShake do wait()
              task.wait(0.01)
                local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
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
end)
-- AutoReel
Section:NewToggle("AutoReel", "", function(v)
     _G.AutoReel = v
pcall(function()
    while _G.AutoReel do wait()
            for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if v:IsA "ScreenGui" and v.Name == "reel"then
                    if v:FindFirstChild "bar" then
                        wait(0.05)
                            ReplicatedStorage.events.reelfinished:FireServer(100,true)
                    end
                end
            end
        end
    end)
end)

Section:NewToggle("Freeze Character", "", function(v)
    Char.HumanoidRootPart.Anchored = v
end)

-- equipitem
spawn(function()
    while wait() do
        if _G.AutoCast then
            pcall(function()
                for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA ("Tool") and v.Name:lower():find("rod") then
                    equipitem(v.Name)
                    end
                end
            end)
        end
    end
end)