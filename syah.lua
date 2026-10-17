--[[
    UNIVERSAL SCRIPT HUB (SYAH HUB - RAYFIELD + SHIFT LOCK FLY)
    Optimized for Delta & Mobile Executors
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SYAH HUB | Universal",
   LoadingTitle = "SYAH HUB",
   LoadingSubtitle = "by Syah",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "SyahHub"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = false
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Global States
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local AimbotEnabled = false
local AimbotFOV = 150
local FOVCircleVisible = false

-- ESP States
local HighlightESPEnabled = false
local BoxESPEnabled = false
local NameESPEnabled = false

-- Shift Lock Fly Variables
local Flying = false
local FlySpeed = 50
local BodyVel, BodyGyro

-- Teleport Variables
local SavedCFrame = nil
local SelectedPlayerName = ""

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local MainTab = Window:CreateTab("Player", 4483345998)
local TeleportTab = Window:CreateTab("Teleport", 4483345998)
local VisualsTab = Window:CreateTab("ESP / Visuals", 4483345998)
local CombatTab = Window:CreateTab("Combat / Aim", 4483345998)
local MiscTab = Window:CreateTab("Misc / Utility", 4483345998)

----------------------------------------------------------------
-- PLAYER TAB (SHIFT LOCK FLY)
----------------------------------------------------------------
MainTab:CreateSection("Movement Custom Values")

MainTab:CreateInput({
   Name = "WalkSpeed (Type Number)",
   PlaceholderText = "16",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.WalkSpeed = num
      end
   end,
})

MainTab:CreateInput({
   Name = "JumpPower (Type Number)",
   PlaceholderText = "50",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.UseJumpPower = true
          LocalPlayer.Character.Humanoid.JumpPower = num
      end
   end,
})

MainTab:CreateSection("Shift Lock Fly System")

MainTab:CreateInput({
   Name = "Fly Speed (Type Number)",
   PlaceholderText = "50",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then FlySpeed = num end
   end,
})

MainTab:CreateToggle({
   Name = "Enable Shift Lock Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      Flying = Value
      local char = LocalPlayer.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end
      local hrp = char.HumanoidRootPart
      local hum = char:FindFirstChildOfClass("Humanoid")

      if Flying then
          if BodyVel then BodyVel:Destroy() end
          if BodyGyro then BodyGyro:Destroy() end

          -- Shift Lock Body Gyro (Kunci sudut watak ke kamera)
          BodyGyro = Instance.new("BodyGyro")
          BodyGyro.Name = "SYAH_ShiftGyro"
          BodyGyro.P = 9e5
          BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
          BodyGyro.cframe = Camera.CFrame
          BodyGyro.Parent = hrp

          -- Body Velocity
          BodyVel = Instance.new("BodyVelocity")
          BodyVel.Name = "SYAH_ShiftVel"
          BodyVel.velocity = Vector3.new(0, 0, 0)
          BodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
          BodyVel.Parent = hrp

          if hum then
              hum.AutoRotate = false -- Lock pergerakan badan (Shiftlock feel)
          end
      else
          if BodyVel then BodyVel:Destroy() end
          if BodyGyro then BodyGyro:Destroy() end
          if hum then
              hum.AutoRotate = true -- Pulihkan pusingan asal
          end
      end
   end,
})

-- Shift Lock Movement Loop
RunService.RenderStepped:Connect(function()
    if Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")

        if BodyGyro and BodyVel then
            -- Paksa pandangan watak sentiasa ikut tepat sudut Kamera (Shift Lock)
            BodyGyro.cframe = Camera.CFrame
            
            local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
            if moveDir.Magnitude > 0 then
                -- Vektor pergerakan dikunci secara mutlak ke pusingan kamera
                local targetVel = Camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z)) * FlySpeed
                BodyVel.velocity = targetVel
            else
                BodyVel.velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

MainTab:CreateSection("Toggles")

MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) NoclipEnabled = Value end,
})

MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value) InfiniteJumpEnabled = Value end,
})

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
TeleportTab:CreateSection("Set & TP Position")

TeleportTab:CreateButton({
   Name = "Set Position (Save Pos)",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
          SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
          Rayfield:Notify({ Title = "Teleport", Content = "Position saved!", Duration = 2 })
      end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Saved Position",
   Callback = function()
      if SavedCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.HumanoidRootPart.CFrame = SavedCFrame
          Rayfield:Notify({ Title = "Teleport", Content = "Teleported successfully!", Duration = 2 })
      else
          Rayfield:Notify({ Title = "Error", Content = "Save position first!", Duration = 2 })
      end
   end,
})

TeleportTab:CreateSection("Teleport to Player")

local PlayerDropdown = TeleportTab:CreateDropdown({
   Name = "Select Player",
   Options = {},
   CurrentOption = "",
   Flag = "PlayerDropdown",
   Callback = function(Option)
      SelectedPlayerName = type(Option) == "table" and Option[1] or Option
   end,
})

local function UpdatePlayerDropdown()
    local playerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerList, p.Name) end
    end
    PlayerDropdown:Refresh(playerList)
end

UpdatePlayerDropdown()
Players.PlayerAdded:Connect(UpdatePlayerDropdown)
Players.PlayerRemoving:Connect(UpdatePlayerDropdown)

TeleportTab:CreateButton({
   Name = "TP to Selected Player",
   Callback = function()
      if SelectedPlayerName ~= "" then
          local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
          if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
              LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
          end
      end
   end,
})

----------------------------------------------------------------
-- VISUALS TAB (MULTI-ESP SYSTEM)
----------------------------------------------------------------
VisualsTab:CreateSection("ESP Options")

VisualsTab:CreateToggle({
   Name = "Highlight ESP",
   CurrentValue = false,
   Flag = "HighlightESPToggle",
   Callback = function(Value) HighlightESPEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = false,
   Flag = "BoxESPToggle",
   Callback = function(Value) BoxESPEnabled = Value end,
})

VisualsTab:CreateToggle({
   Name = "Name & Distance ESP",
   CurrentValue = false,
   Flag = "NameESPToggle",
   Callback = function(Value) NameESPEnabled = Value end,
})

task.spawn(function()
    while task.wait(0.3) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")

                if HighlightESPEnabled then
                    if not char:FindFirstChild("SYAH_Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "SYAH_Highlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 50)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = char
                    end
                else
                    if char:FindFirstChild("SYAH_Highlight") then
                        char.SYAH_Highlight:Destroy()
                    end
                end

                if BoxESPEnabled then
                    if not char:FindFirstChild("SYAH_Box") then
                        local box = Instance.new("SelectionBox")
                        box.Name = "SYAH_Box"
                        box.Adornee = char
                        box.Color3 = Color3.fromRGB(0, 255, 255)
                        box.LineThickness = 0.03
                        box.SurfaceTransparency = 1
                        box.Parent = char
                    end
                else
                    if char:FindFirstChild("SYAH_Box") then
                        char.SYAH_Box:Destroy()
                    end
                end

                if NameESPEnabled then
                    if head and not head:FindFirstChild("SYAH_NameTag") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "SYAH_NameTag"
                        billboard.Size = UDim2.new(0, 120, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = head

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "Text"
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextSize = 13
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.Parent = billboard
                    end
                    if head and head:FindFirstChild("SYAH_NameTag") and hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                        head.SYAH_NameTag.Text.Text = player.Name .. "\n[" .. dist .. "m]"
                    end
                else
                    if head and head:FindFirstChild("SYAH_NameTag") then
                        head.SYAH_NameTag:Destroy()
                    end
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- COMBAT TAB
----------------------------------------------------------------
CombatTab:CreateToggle({
   Name = "Camera Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value) AimbotEnabled = Value end,
})

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

CombatTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Flag = "FOVToggle",
   Callback = function(Value)
      FOVCircleVisible = Value
      FOVCircle.Visible = Value
   end,
})

CombatTab:CreateInput({
   Name = "FOV Radius (Type Number)",
   PlaceholderText = "150",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then
          AimbotFOV = num
          FOVCircle.Radius = num
      end
   end,
})

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = AimbotFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

----------------------------------------------------------------
-- MISC TAB
----------------------------------------------------------------
MiscTab:CreateButton({
   Name = "Anti-AFK",
   Callback = function()
      local VirtualUser = game:GetService("VirtualUser")
      LocalPlayer.Idled:Connect(function()
          VirtualUser:CaptureController()
          VirtualUser:ClickButton2(Vector2.new())
      end)
      Rayfield:Notify({ Title = "Anti-AFK", Content = "Anti-AFK Activated!", Duration = 2 })
   end,
})

MiscTab:CreateButton({
   Name = "Rejoin Game",
   Callback = function()
      game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end,
})
