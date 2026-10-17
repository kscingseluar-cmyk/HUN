--[[
    UNIVERSAL SCRIPT HUB (SYAH HUB V2 - FIXED WALL CHECK)
    Optimized for Delta & Mobile Executors
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SYAH HUB V2 | Universal",
   LoadingTitle = "SYAH HUB V2 Loading...",
   LoadingSubtitle = "by Syah (Delta Mobile Optimized)",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "SyahHubV2"
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
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- Global Movement States
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local HitboxEnabled = false
local HitboxSize = 10

-- Fly States
local ShiftFlyEnabled = false
local ShiftFlySpeed = 50
local FlyBG, FlyBV

-- ESP States
local HighlightESPEnabled = false
local BoxESPEnabled = false
local NameESPEnabled = false
local TracerESPEnabled = false

-- Combat States
local AimbotEnabled = false
local AimbotFOV = 150
local WallCheckEnabled = false
local FOVCircleVisible = false

-- Teleport Variables
local SavedCFrame = nil
local SelectedPlayerName = ""

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local MainTab = Window:CreateTab("Player Movement", 4483345998)
local CombatTab = Window:CreateTab("Combat & Aim", 4483345998)
local VisualsTab = Window:CreateTab("ESP & Visuals", 4483345998)
local TeleportTab = Window:CreateTab("Teleport", 4483345998)
local MiscTab = Window:CreateTab("Misc & Booster", 4483345998)

----------------------------------------------------------------
-- PLAYER MOVEMENT TAB
----------------------------------------------------------------
MainTab:CreateSection("Custom WalkSpeed & JumpPower")

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

MainTab:CreateSection("Shift Lock Fly Engine")

MainTab:CreateInput({
   Name = "Fly Speed (Type Number)",
   PlaceholderText = "50",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then
          ShiftFlySpeed = num
      end
   end,
})

local function SetupFlyPhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if FlyBG then FlyBG:Destroy() end
    if FlyBV then FlyBV:Destroy() end

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "SYAH_FlyBG"
    FlyBG.P = 9e4
    FlyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.cframe = hrp.CFrame
    FlyBG.Parent = hrp

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "SYAH_FlyBV"
    FlyBV.velocity = Vector3.zero
    FlyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Parent = hrp

    hum.AutoRotate = false
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
end

local function ClearFlyPhysics()
    if FlyBG then FlyBG:Destroy() FlyBG = nil end
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

MainTab:CreateToggle({
   Name = "Enable Shift Lock Fly",
   CurrentValue = false,
   Flag = "ShiftFlyToggle",
   Callback = function(Value)
      ShiftFlyEnabled = Value
      if ShiftFlyEnabled then
          SetupFlyPhysics()
      else
          ClearFlyPhysics()
      end
   end,
})

RunService.RenderStepped:Connect(function()
    if ShiftFlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")

        if not FlyBG or not FlyBV or FlyBG.Parent ~= hrp then
            SetupFlyPhysics()
        end

        if FlyBG and FlyBV then
            local _, yaw, _ = Camera.CFrame:ToOrientation()
            FlyBG.cframe = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
            
            local moveDir = hum and hum.MoveDirection or Vector3.zero
            if moveDir.Magnitude > 0 then
                local camCF = Camera.CFrame
                local flatCam = CFrame.new(Vector3.zero, camCF.LookVector * Vector3.new(1,0,1))
                local localMove = flatCam:VectorToObjectSpace(moveDir)
                
                local flyDirection = (camCF.LookVector * -localMove.Z) + (camCF.RightVector * localMove.X)
                if flyDirection.Magnitude > 0 then
                    FlyBV.velocity = flyDirection.Unit * ShiftFlySpeed
                else
                    FlyBV.velocity = Vector3.zero
                end
            else
                FlyBV.velocity = Vector3.zero
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if ShiftFlyEnabled then
        task.wait(0.5)
        SetupFlyPhysics()
    end
end)

MainTab:CreateSection("Physics Toggles")

MainTab:CreateToggle({
   Name = "Noclip (Walk Through Walls)",
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
-- COMBAT & AIM TAB
----------------------------------------------------------------
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
   Name = "Camera Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Wall Check (Ignore Behind Walls)",
   CurrentValue = false,
   Flag = "WallCheckToggle",
   Callback = function(Value) WallCheckEnabled = Value end,
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
   Name = "FOV Radius",
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

CombatTab:CreateSection("Hitbox Extender (Big Head/Body)")

CombatTab:CreateToggle({
   Name = "Expand Enemy Hitbox",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value) HitboxEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2, 30},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 10,
   Flag = "HitboxSizeSlider",
   Callback = function(Value) HitboxSize = Value end,
})

RunService.RenderStepped:Connect(function()
    if HitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            end
        end
    end
end)

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Raycast Wall Check Fix Yang Stabil
local function IsVisible(targetPart)
    if not WallCheckEnabled then return true end
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local excludeList = {}
    if LocalPlayer.Character then
        table.insert(excludeList, LocalPlayer.Character)
    end
    if targetPart and targetPart.Parent then
        table.insert(excludeList, targetPart.Parent)
    end
    
    raycastParams.FilterDescendantsInstances = excludeList
    raycastParams.IgnoreWater = true

    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    return result == nil
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = AimbotFOV
    local centerPos = GetScreenCenter()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
                if distance < shortestDistance then
                    if IsVisible(head) then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = GetScreenCenter()
    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

----------------------------------------------------------------
-- VISUALS & ESP TAB
----------------------------------------------------------------
VisualsTab:CreateSection("ESP Modes")

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

VisualsTab:CreateToggle({
   Name = "Tracers ESP (Lines to Enemy)",
   CurrentValue = false,
   Flag = "TracerESPToggle",
   Callback = function(Value) TracerESPEnabled = Value end,
})

local Tracers = {}

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
                    if char:FindFirstChild("SYAH_Highlight") then char.SYAH_Highlight:Destroy() end
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
                    if char:FindFirstChild("SYAH_Box") then char.SYAH_Box:Destroy() end
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
                    if head and head:FindFirstChild("SYAH_NameTag") then head.SYAH_NameTag:Destroy() end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if TracerESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    if not Tracers[player] then
                        local line = Drawing.new("Line")
                        line.Color = Color3.fromRGB(255, 0, 80)
                        line.Thickness = 1.5
                        line.Transparency = 1
                        Tracers[player] = line
                    end
                    Tracers[player].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracers[player].To = Vector2.new(pos.X, pos.Y)
                    Tracers[player].Visible = true
                else
                    if Tracers[player] then Tracers[player].Visible = false end
                end
            else
                if Tracers[player] then Tracers[player].Visible = false end
            end
        end
    else
        for _, line in pairs(Tracers) do line.Visible = false end
    end
end)

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
TeleportTab:CreateSection("Set & TP Position")

TeleportTab:CreateButton({
   Name = "Set Position (Save Pos)",
   Callback = function()
      local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
          SavedCFrame = hrp.CFrame
          Rayfield:Notify({ Title = "Teleport", Content = "Position saved!", Duration = 2 })
      end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Saved Position",
   Callback = function()
      local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if SavedCFrame and hrp then
          hrp.CFrame = SavedCFrame
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
   Callback = function`()
      if SelectedPlayerName ~= "" then
          local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
          local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
          if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp then
              hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
          end
      end
   end,
})

----------------------------------------------------------------
-- MISC & FPS BOOSTER TAB
----------------------------------------------------------------
MiscTab:CreateSection("Performance Booster (Mobile Anti-Lag)")

MiscTab:CreateButton({
   Name = "FPS Booster (Remove Shadows & Textures)",
   Callback = function()
      Lighting.GlobalShadows = false
      Lighting.FogEnd = 9e9
      for _, v in pairs(game:GetDescendants()) do
          if v:IsA("BasePart") then
              v.Material = Enum.Material.SmoothPlastic
          elseif v:IsA("Decal") or v:IsA("Texture") then
              v:Destroy()
          end
      end
      Rayfield:Notify({ Title = "Booster Activated", Content = "FPS boosted successfully!", Duration = 3 })
   end,
})

MiscTab:CreateSection("Server Utilities")

MiscTab:CreateButton({
   Name = "Server Hop (Find New Server)",
   Callback = function()
      local HttpService = game:GetService("HttpService")
      local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
      local success, result = pcall(function()
          return HttpService:JSONDecode(game:HttpGet(Api))
      end)
      if success and result and result.data then
          for _, server in pairs(result.data) do
              if server.playing < server.maxPlayers and server.id ~= game.JobId then
                  TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                  break
              end
          end
      end
   end,
})

MiscTab:CreateButton({
   Name = "Rejoin Current Server",
   Callback = function()
      TeleportService:Teleport(game.PlaceId, LocalPlayer)
   end,
})

MiscTab:CreateButton({
   Name = "Anti-AFK (Prevent Kick)",
   Callback = function()
      local VirtualUser = game:GetService("VirtualUser")
      LocalPlayer.Idled:Connect(function()
          VirtualUser:CaptureController()
          VirtualUser:ClickButton2(Vector2.new())
      end)
      Rayfield:Notify({ Title = "Anti-AFK", Content = "Anti-AFK Activated!", Duration = 2 })
   end,
})
