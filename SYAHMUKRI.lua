--[[
    UNIVERSAL SCRIPT HUB (SYAH HUB V3.9 - FULL ENGLISH & NUMERIC INPUT)
    Optimized for Delta Mobile Executor
--]]

local Rayfield = nil
local success = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    pcall(function()
        Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)
end

if not Rayfield then
    warn("[SYAH HUB] Failed to load Rayfield UI Library!")
    return
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Camera = workspace.CurrentCamera

-- Get Game Title
local gameName = "Universal Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then
        gameName = info.Name
    end
end)

local Window = Rayfield:CreateWindow({
   Name = "SYAH HUB V3.9 | " .. gameName,
   LoadingTitle = "SYAH HUB V3.9 Loading...",
   LoadingSubtitle = "Game: " .. gameName .. " | by Syah",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local MainTab = Window:CreateTab("Player Movement", 4483345998)
local CombatTab = Window:CreateTab("Combat & Aim", 4483345998)
local VisualsTab = Window:CreateTab("ESP & Visuals", 4483345998)
local TeleportTab = Window:CreateTab("Teleport", 4483345998)
local MiscTab = Window:CreateTab("Misc & Automations", 4483345998)

-- Global States
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local HitboxEnabled = false
local HitboxSize = 10
local HitboxPart = "HumanoidRootPart"
local InvisibleEnabled = false

-- Fly States
local ShiftFlyEnabled = false
local ShiftFlySpeed = 50
local FlyBG, FlyBV

-- ESP States
local HighlightESPEnabled = false
local BoxESPEnabled = false
local NameESPEnabled = false

-- Combat States
local AimbotEnabled = false
local AimbotFOV = 150
local WallCheckEnabled = false
local TeamCheckEnabled = false
local AimbotMode = "Closest"
local LockedTargetPlayer = ""
local AimPart = "Head"

-- Anti-Aim & Clicker States
local SpinbotEnabled = false
local SpinSpeed = 50
local AutoClickerEnabled = false
local AutoClickerCPS = 10

-- Teleport Variables
local SavedCFrame = nil
local SelectedPlayerName = ""
local ClickTPEnabled = false

----------------------------------------------------------------
-- SAFE FOV CIRCLE (SCREEN GUI)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SYAH_FOVScreen"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
end)

local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Size = UDim2.new(0, AimbotFOV * 2, 0, AimbotFOV * 2)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FOVFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 50)
UIStroke.Thickness = 1.5
UIStroke.Parent = FOVFrame

----------------------------------------------------------------
-- PLAYER MOVEMENT TAB
----------------------------------------------------------------
MainTab:CreateSection("Custom Speed & Jump")

MainTab:CreateInput({
   Name = "WalkSpeed",
   PlaceholderText = "Default: 16",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
          LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = num
      end
   end,
})

MainTab:CreateInput({
   Name = "JumpPower",
   PlaceholderText = "Default: 50",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
          local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
          hum.UseJumpPower = true
          hum.JumpPower = num
      end
   end,
})

MainTab:CreateSection("Stealth & Invisibility")

MainTab:CreateToggle({
   Name = "Invisible Mode",
   CurrentValue = false,
   Flag = "InvisibleToggle",
   Callback = function(Value)
      InvisibleEnabled = Value
      local char = LocalPlayer.Character
      if not char then return end

      pcall(function()
          local hrp = char:FindFirstChild("HumanoidRootPart")
          if InvisibleEnabled and hrp then
              local oldCF = hrp.CFrame
              char:MoveTo(Vector3.new(0, -1000, 0))
              task.wait(0.1)
              hrp.CFrame = oldCF
              Rayfield:Notify({ Title = "Invisibility", Content = "Invisible Active!", Duration = 2 })
          else
              Rayfield:Notify({ Title = "Invisibility", Content = "Invisible Disabled!", Duration = 2 })
          end
      end)
   end,
})

RunService.RenderStepped:Connect(function()
    if InvisibleEnabled and LocalPlayer.Character then
        pcall(function()
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.LocalTransparencyModifier = 1
                end
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    InvisibleEnabled = false
end)

MainTab:CreateSection("Camera FOV Changer")

MainTab:CreateInput({
   Name = "Camera FOV",
   PlaceholderText = "70 - 120 (Default: 70)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then Camera.FieldOfView = num end
   end,
})

MainTab:CreateSection("Fly Engine")

MainTab:CreateInput({
   Name = "Fly Speed",
   PlaceholderText = "Enter speed (Default: 50)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then ShiftFlySpeed = num end
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
   Name = "Enable Fly",
   CurrentValue = false,
   Flag = "ShiftFlyToggle",
   Callback = function(Value)
      ShiftFlyEnabled = Value
      if ShiftFlyEnabled then SetupFlyPhysics() else ClearFlyPhysics() end
   end,
})

RunService.RenderStepped:Connect(function()
    if ShiftFlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        local hrp = char.HumanoidRootPart
        local hum = char:FindFirstChildOfClass("Humanoid")

        if not FlyBG or not FlyBV or FlyBG.Parent ~= hrp then SetupFlyPhysics() end

        if FlyBG and FlyBV then
            local _, yaw, _ = Camera.CFrame:ToOrientation()
            FlyBG.cframe = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
            
            local moveDir = hum and hum.MoveDirection or Vector3.zero
            if moveDir.Magnitude > 0 then
                local camCF = Camera.CFrame
                local flatCam = CFrame.new(Vector3.zero, camCF.LookVector * Vector3.new(1,0,1))
                local localMove = flatCam:VectorToObjectSpace(moveDir)
                local flyDirection = (camCF.LookVector * -localMove.Z) + (camCF.RightVector * localMove.X)
                FlyBV.velocity = flyDirection.Magnitude > 0 and (flyDirection.Unit * ShiftFlySpeed) or Vector3.zero
            else
                FlyBV.velocity = Vector3.zero
            end
        end
    end
end)

MainTab:CreateSection("Physics Modifications")

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
CombatTab:CreateSection("Aimbot Engine")

CombatTab:CreateToggle({
   Name = "Camera Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Flag = "ShowFOVToggle",
   Callback = function(Value) FOVFrame.Visible = Value end,
})

CombatTab:CreateToggle({
   Name = "Team Check (Ignore Teammates)",
   CurrentValue = false,
   Flag = "TeamCheckToggle",
   Callback = function(Value) TeamCheckEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Wall Check (Ignore Behind Walls)",
   CurrentValue = false,
   Flag = "WallCheckToggle",
   Callback = function(Value) WallCheckEnabled = Value end,
})

CombatTab:CreateDropdown({
   Name = "Aim Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Flag = "AimPartDropdown",
   Callback = function(Option)
      AimPart = type(Option) == "table" and Option[1] or tostring(Option)
   end,
})

CombatTab:CreateDropdown({
   Name = "Aimbot Target Mode",
   Options = {"Closest to Crosshair", "Lock Specific Player"},
   CurrentOption = "Closest to Crosshair",
   Flag = "AimbotModeDropdown",
   Callback = function(Option)
      local choice = type(Option) == "table" and Option[1] or tostring(Option)
      if string.find(choice, "Lock Specific Player") or string.find(choice, "Specific") then
          AimbotMode = "Specific"
      else
          AimbotMode = "Closest"
      end
   end,
})

local AimbotPlayerDropdown = CombatTab:CreateDropdown({
   Name = "Select Target Player",
   Options = {"None"},
   CurrentOption = "None",
   Flag = "AimbotPlayerDropdown",
   Callback = function(Option)
      local rawVal = type(Option) == "table" and Option[1] or Option
      if rawVal and rawVal ~= "None" then LockedTargetPlayer = tostring(rawVal) else LockedTargetPlayer = "" end
   end,
})

local function UpdateAimbotPlayerDropdown()
    pcall(function()
        local playerList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(playerList, p.Name) end
        end
        if #playerList == 0 then table.insert(playerList, "None") end
        AimbotPlayerDropdown:Refresh(playerList)
    end)
end

UpdateAimbotPlayerDropdown()
Players.PlayerAdded:Connect(UpdateAimbotPlayerDropdown)
Players.PlayerRemoving:Connect(UpdateAimbotPlayerDropdown)

CombatTab:CreateInput({
   Name = "FOV Radius (Pixels)",
   PlaceholderText = "50 - 500 (Default: 150)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then
          AimbotFOV = num
          FOVFrame.Size = UDim2.new(0, num * 2, 0, num * 2)
      end
   end,
})

CombatTab:CreateSection("Hitbox Extender")

CombatTab:CreateToggle({
   Name = "Expand Enemy Hitbox",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value) HitboxEnabled = Value end,
})

CombatTab:CreateDropdown({
   Name = "Hitbox Target Part",
   Options = {"HumanoidRootPart", "Head"},
   CurrentOption = "HumanoidRootPart",
   Flag = "HitboxPartDropdown",
   Callback = function(Option)
      HitboxPart = type(Option) == "table" and Option[1] or tostring(Option)
   end,
})

CombatTab:CreateInput({
   Name = "Hitbox Size (Studs)",
   PlaceholderText = "2 - 40 (Default: 10)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then HitboxSize = num end
   end,
})

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local part = player.Character:FindFirstChild(HitboxPart)
                    local isTeammate = TeamCheckEnabled and LocalPlayer.Team and player.Team and (LocalPlayer.Team == player.Team) and not player.Neutral
                    
                    if part then
                        if HitboxEnabled and not isTeammate then
                            part.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                            part.Transparency = 0.7
                            part.BrickColor = BrickColor.new("Really red")
                            part.Material = Enum.Material.Neon
                            part.CanCollide = false
                        else
                            if part.Size ~= Vector3.new(2, 2, 1) and part.Size ~= Vector3.new(1.2, 1.2, 1.2) then
                                part.Size = (HitboxPart == "Head") and Vector3.new(1.2, 1.2, 1.2) or Vector3.new(2, 2, 1)
                                part.Transparency = 0
                                part.Material = Enum.Material.SmoothPlastic
                            end
                        end
                    end
                end
            end
        end)
    end
end)

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function IsVisible(targetPart)
    if not WallCheckEnabled then return true end
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local excludeList = {}
    if LocalPlayer.Character then table.insert(excludeList, LocalPlayer.Character) end
    if targetPart and targetPart.Parent then table.insert(excludeList, targetPart.Parent) end
    
    raycastParams.FilterDescendantsInstances = excludeList
    raycastParams.IgnoreWater = true

    local direction = targetPart.Position - origin
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestPlayer()
    if AimbotMode == "Specific" and LockedTargetPlayer ~= "" then
        local target = Players:FindFirstChild(LockedTargetPlayer)
        if not target then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Name == LockedTargetPlayer or p.DisplayName == LockedTargetPlayer then
                    target = p; break
                end
            end
        end
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local part = target.Character[AimPart]
            if IsVisible(part) then return target end
        end
        return nil
    end

    local closest = nil
    local shortestDistance = AimbotFOV
    local centerPos = GetScreenCenter()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isTeammate = TeamCheckEnabled and LocalPlayer.Team and player.Team and (LocalPlayer.Team == player.Team) and not player.Neutral
            if not isTeammate and player.Character and player.Character:FindFirstChild(AimPart) then
                local part = player.Character[AimPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
                    if distance < shortestDistance and IsVisible(part) then
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
    if AimbotEnabled then
        pcall(function()
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(AimPart) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
            end
        end)
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

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
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
        end)
    end
end)

----------------------------------------------------------------
-- TELEPORT TAB
----------------------------------------------------------------
TeleportTab:CreateSection("Click TP Tool")

TeleportTab:CreateToggle({
   Name = "Click / Tap TP (Equip Tool to Teleport)",
   CurrentValue = false,
   Flag = "ClickTPToggle",
   Callback = function(Value)
      ClickTPEnabled = Value
      local tool = LocalPlayer.Backpack:FindFirstChild("Click TP") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Click TP"))
      if ClickTPEnabled then
          if not tool then
              tool = Instance.new("Tool")
              tool.Name = "Click TP"
              tool.RequiresHandle = false
              tool.Activated:Connect(function()
                  local mouse = LocalPlayer:GetMouse()
                  if mouse and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                  end
              end)
              tool.Parent = LocalPlayer.Backpack
          end
      else
          if tool then tool:Destroy() end
      end
   end,
})

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
   Options = {"None"},
   CurrentOption = "None",
   Flag = "PlayerDropdown",
   Callback = function(Option)
      local rawVal = type(Option) == "table" and Option[1] or Option
      if rawVal and rawVal ~= "None" then SelectedPlayerName = tostring(rawVal) else SelectedPlayerName = "" end
   end,
})

local function UpdatePlayerDropdownTP()
    pcall(function()
        local playerList = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(playerList, p.Name) end
        end
        if #playerList == 0 then table.insert(playerList, "None") end
        PlayerDropdown:Refresh(playerList)
    end)
end

UpdatePlayerDropdownTP()
Players.PlayerAdded:Connect(UpdatePlayerDropdownTP)
Players.PlayerRemoving:Connect(UpdatePlayerDropdownTP)

TeleportTab:CreateButton({
   Name = "TP to Selected Player",
   Callback = function()
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
-- MISC & AUTOMATIONS TAB
----------------------------------------------------------------
MiscTab:CreateSection("Auto Clicker / Fast Tap")

MiscTab:CreateToggle({
   Name = "Enable Auto Clicker",
   CurrentValue = false,
   Flag = "AutoClickerToggle",
   Callback = function(Value) AutoClickerEnabled = Value end,
})

MiscTab:CreateInput({
   Name = "Click Speed (Clicks Per Second)",
   PlaceholderText = "1 - 30 (Default: 10)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then AutoClickerCPS = num end
   end,
})

task.spawn(function()
    while true do
        if AutoClickerEnabled then
            pcall(function()
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                else
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
                end
            end)
            task.wait(1 / math.max(AutoClickerCPS, 1))
        else
            task.wait(0.5)
        end
    end
end)

MiscTab:CreateSection("SpinBot (Anti-Aim)")

MiscTab:CreateToggle({
   Name = "Enable SpinBot",
   CurrentValue = false,
   Flag = "SpinbotToggle",
   Callback = function(Value) SpinbotEnabled = Value end,
})

MiscTab:CreateInput({
   Name = "Spin Speed",
   PlaceholderText = "10 - 200 (Default: 50)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then SpinSpeed = num end
   end,
})

RunService.RenderStepped:Connect(function()
    if SpinbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
        end)
    end
end)

MiscTab:CreateSection("Performance Booster (Mobile Anti-Lag)")

MiscTab:CreateButton({
   Name = "FPS Booster (Ultra Smooth)",
   Callback = function()
      pcall(function()
          Lighting.GlobalShadows = false
          Lighting.FogEnd = 9e9
          for _, v in pairs(game:GetDescendants()) do
              if v:IsA("BasePart") then
                  v.Material = Enum.Material.SmoothPlastic
              elseif v:IsA("Decal") or v:IsA("Texture") then
                  v:Destroy()
              end
          end
      end)
      Rayfield:Notify({ Title = "Booster Activated", Content = "FPS boosted successfully!", Duration = 3 })
   end,
})

MiscTab:CreateSection("Server Utilities")

MiscTab:CreateButton({
   Name = "Server Hop (Join Another Server)",
   Callback = function()
      pcall(function()
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
      end)
   end,
})

MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      pcall(function()
          TeleportService:Teleport(game.PlaceId, LocalPlayer)
      end)
   end,
})

MiscTab:CreateButton({
   Name = "Anti-AFK (Prevent Idle Kick)",
   Callback = function()
      pcall(function()
          local VirtualUser = game:GetService("VirtualUser")
          LocalPlayer.Idled:Connect(function()
              VirtualUser:CaptureController()
              VirtualUser:ClickButton2(Vector2.new())
          end)
      end)
      Rayfield:Notify({ Title = "Anti-AFK", Content = "Anti-AFK Activated!", Duration = 2 })
   end,
})
