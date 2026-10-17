-- =======================================================
-- ANDROID APP STYLE AUTO CLICKER (ACCURATE POSITION FIX)
-- =======================================================

local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Clean up old instance
if CoreGui:FindFirstChild("AppAutoClickerHub") then
    CoreGui:FindFirstChild("AppAutoClickerHub"):Destroy()
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AppAutoClickerHub"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- States & Variables
local IsRunning = false
local ClickDelay = 0.05
local ClickTargets = {}

-- =======================================================
-- 1. FLOATING CONTROL BAR (BAR TERAPUNG)
-- =======================================================
local BarFrame = Instance.new("Frame")
local BarCorner = Instance.new("UICorner")
local UIListLayout = Instance.new("UIListLayout")

BarFrame.Name = "ControlBar"
BarFrame.Parent = ScreenGui
BarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BarFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
BarFrame.Size = UDim2.new(0, 48, 0, 220)
BarFrame.Active = true
BarFrame.Draggable = true

BarCorner.CornerRadius = UDim.new(0, 12)
BarCorner.Parent = BarFrame

UIListLayout.Parent = BarFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

local function CreateBarButton(name, text, color, textScale)
    local Btn = Instance.new("TextButton")
    local Corner = Instance.new("UICorner")

    Btn.Name = name
    Btn.Parent = BarFrame
    Btn.BackgroundColor3 = color
    Btn.Size = UDim2.new(0, 36, 0, 36)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = textScale or 18

    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn

    return Btn
end

local PlayBtn = CreateBarButton("PlayBtn", "▶", Color3.fromRGB(0, 200, 100), 16)
local AddBtn = CreateBarButton("AddBtn", "+", Color3.fromRGB(0, 150, 255), 22)
local SubBtn = CreateBarButton("SubBtn", "-", Color3.fromRGB(230, 140, 0), 24)
local SettingsBtn = CreateBarButton("SettingsBtn", "⚙", Color3.fromRGB(120, 120, 130), 18)
local CloseBtn = CreateBarButton("CloseBtn", "✕", Color3.fromRGB(220, 50, 50), 16)

-- =======================================================
-- 2. SETTINGS POPUP FRAME
-- =======================================================
local SettingsFrame = Instance.new("Frame")
local SettingsCorner = Instance.new("UICorner")
local SettingsTitle = Instance.new("TextLabel")
local DelayInput = Instance.new("TextBox")
local SaveBtn = Instance.new("TextButton")

SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Parent = ScreenGui
SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SettingsFrame.Position = UDim2.new(0.5, -100, 0.4, -60)
SettingsFrame.Size = UDim2.new(0, 200, 0, 120)
SettingsFrame.Visible = false
SettingsFrame.Active = true
SettingsFrame.Draggable = true

SettingsCorner.CornerRadius = UDim.new(0, 10)
SettingsCorner.Parent = SettingsFrame

SettingsTitle.Parent = SettingsFrame
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Position = UDim2.new(0, 10, 0, 10)
SettingsTitle.Size = UDim2.new(0, 180, 0, 20)
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.Text = "⚙ Click Delay (Saat)"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.TextSize = 13

DelayInput.Parent = SettingsFrame
DelayInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
DelayInput.Position = UDim2.new(0, 15, 0, 38)
DelayInput.Size = UDim2.new(0, 170, 0, 30)
DelayInput.Font = Enum.Font.GothamBold
DelayInput.Text = tostring(ClickDelay)
DelayInput.TextColor3 = Color3.fromRGB(0, 255, 150)
DelayInput.TextSize = 14

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = DelayInput

SaveBtn.Parent = SettingsFrame
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SaveBtn.Position = UDim2.new(0, 15, 0, 75)
SaveBtn.Size = UDim2.new(0, 170, 0, 30)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Text = "Simpan"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize = 13

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 6)
SaveCorner.Parent = SaveBtn

SettingsBtn.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

SaveBtn.MouseButton1Click:Connect(function()
    local val = tonumber(DelayInput.Text)
    if val and val > 0 then
        ClickDelay = val
    else
        DelayInput.Text = tostring(ClickDelay)
    end
    SettingsFrame.Visible = false
end)

-- =======================================================
-- 3. TARGET POINT CREATION (SASARAN KLIK)
-- =======================================================
local function AddTargetPoint()
    local index = #ClickTargets + 1
    
    local TargetBtn = Instance.new("TextButton")
    local TargetCorner = Instance.new("UICorner")
    local TargetStroke = Instance.new("UIStroke")

    TargetBtn.Name = "TargetPoint_" .. index
    TargetBtn.Parent = ScreenGui
    TargetBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    TargetBtn.BackgroundTransparency = 0.4
    TargetBtn.Position = UDim2.new(0.3 + (index * 0.05), 0, 0.4, 0)
    TargetBtn.Size = UDim2.new(0, 42, 0, 42)
    TargetBtn.Font = Enum.Font.GothamBold
    TargetBtn.Text = tostring(index)
    TargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetBtn.TextSize = 16
    TargetBtn.Active = true
    TargetBtn.Draggable = true

    TargetCorner.CornerRadius = UDim.new(1, 0)
    TargetCorner.Parent = TargetBtn

    TargetStroke.Thickness = 2
    TargetStroke.Color = Color3.fromRGB(255, 255, 255)
    TargetStroke.Parent = TargetBtn

    table.insert(ClickTargets, TargetBtn)
end

local function RemoveTargetPoint()
    if #ClickTargets > 0 then
        local lastIndex = #ClickTargets
        ClickTargets[lastIndex]:Destroy()
        table.remove(ClickTargets, lastIndex)
    end
end

AddTargetPoint()

AddBtn.MouseButton1Click:Connect(function()
    AddTargetPoint()
end)

SubBtn.MouseButton1Click:Connect(function()
    RemoveTargetPoint()
end)

CloseBtn.MouseButton1Click:Connect(function()
    IsRunning = false
    ScreenGui:Destroy()
end)

-- =======================================================
-- 4. ACCURATE AUTO CLICK ENGINE (PEMBETULAN POSISI)
-- =======================================================
PlayBtn.MouseButton1Click:Connect(function()
    IsRunning = not IsRunning

    if IsRunning then
        PlayBtn.Text = "⏸"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
        
        task.spawn(function()
            while IsRunning do
                if #ClickTargets > 0 then
                    for _, target in ipairs(ClickTargets) do
                        if not IsRunning then break end
                        
                        -- Dapatkan offset TopBar skrin Roblox
                        local inset = GuiService:GetGuiInset()
                        
                        -- Kira titik tepat di tengah bulatan target
                        local x = target.AbsolutePosition.X + (target.AbsoluteSize.X / 2) + inset.X
                        local y = target.AbsolutePosition.Y + (target.AbsoluteSize.Y / 2) + inset.Y
                        
                        -- Hantar acara klik tepat pada koordinat
                        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
                        
                        task.wait(ClickDelay)
                    end
                end
            end
            
            PlayBtn.Text = "▶"
            PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        end)
    else
        PlayBtn.Text = "▶"
        PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end
end)
