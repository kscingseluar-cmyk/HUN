-- =======================================================
-- CUSTOM AUTO CLICKER HUB (MADE FROM SCRATCH)
-- =======================================================

-- Load UI Library (Fluent UI - Tampilan Modern & Cantik)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Buat Window Utama
local Window = Fluent:CreateWindow({
    Title = "⚡ Multi Clicker Hub",
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true, -- Efek Blur Cantik
    Theme = "Dark", -- Pilihan: Dark, Light, Vivid, Midnight, Aqua
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- =======================================================
-- VARIABEL & UTILITY
-- =======================================================
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- States Toggle
local AutoClickerEnabled = false
local FastClickerEnabled = false
local ToolClickerEnabled = false

-- Settings
local ClickDelay = 0.1
local FastClickDelay = 0.01

-- =======================================================
-- TABS UI
-- =======================================================
local Tabs = {
    Main = Window:AddTab({ Title = "Main Clicker", Icon = "mouse-pointer" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- =======================================================
-- TAB 1: MAIN CLICKER
-- =======================================================

-- 1. Standard Auto Clicker (Virtual Mouse Click)
local Toggle1 = Tabs.Main:AddToggle("AutoClicker", {Title = "Standard Auto Clicker", Default = false})
Toggle1:OnChanged(function(Value)
    AutoClickerEnabled = Value
    if AutoClickerEnabled then
        task.spawn(function()
            while AutoClickerEnabled do
                -- Simulasi Klik Kiri Mouse di Tengah Layar
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(ClickDelay)
            end
        end)
    end
end)

-- 2. Fast / Ultra Clicker
local Toggle2 = Tabs.Main:AddToggle("FastClicker", {Title = "⚡ Ultra Fast Clicker", Default = false})
Toggle2:OnChanged(function(Value)
    FastClickerEnabled = Value
    if FastClickerEnabled then
        task.spawn(function()
            while FastClickerEnabled do
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(FastClickDelay)
            end
        end)
    end
end)

-- 3. Tool / Equip Clicker (Aktivasi Item di Hand)
local Toggle3 = Tabs.Main:AddToggle("ToolClicker", {Title = "Equipped Tool Clicker", Default = false})
Toggle3:OnChanged(function(Value)
    ToolClickerEnabled = Value
    if ToolClickerEnabled then
        task.spawn(function()
            while ToolClickerEnabled do
                local Character = LocalPlayer.Character
                if Character then
                    local Tool = Character:FindFirstChildOfClass("Tool")
                    if Tool then
                        Tool:Activate()
                    end
                end
                task.wait(ClickDelay)
            end
        end)
    end
end)

-- =======================================================
-- TAB 2: SETTINGS (Pengaturan Kecepatan)
-- =======================================================

-- Slider Kecepatan Clicker Biasa
local Slider1 = Tabs.Settings:AddSlider("ClickDelaySlider", {
    Title = "Standard Click Delay (Detik)",
    Description = "Semakin kecil angka, semakin cepat kliknya",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        ClickDelay = Value
    end
})

-- Slider Kecepatan Ultra Clicker
local Slider2 = Tabs.Settings:AddSlider("FastClickDelaySlider", {
    Title = "Ultra Click Delay (Detik)",
    Description = "Rekomendasi 0.001 - 0.01",
    Default = 0.01,
    Min = 0.001,
    Max = 0.1,
    Rounding = 3,
    Callback = function(Value)
        FastClickDelay = Value
    end
})

-- Pilihan Tema UI (Biarkan Tampilan Tetap Cantik Sesuai Selera)
local DropdownTheme = Tabs.Settings:AddDropdown("ThemeDropdown", {
    Title = "Ubah Warna / Tema Hub",
    Values = {"Dark", "Light", "Vivid", "Midnight", "Aqua", "Rose"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

-- Notifikasi saat script berhasil di-load
Fluent:Notify({
    Title = "Multi Clicker Loaded!",
    Content = "Tekan CTRL Kiri untuk menyembunyikan/membuka Hub.",
    Duration = 5
})

Window:SelectTab(1)
