--[[
    UNIVERSAL SCRIPT HUB (SYAH HUB V6.7 - SEARCH ONLY & 50 LIMIT)
    Optimized for All Roblox Executors (Mobile & PC)
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
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
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
   Name = "SYAH HUB V6.7",
   LoadingTitle = "SYAH HUB Loading...",
   LoadingSubtitle = "Game: " .. gameName .. " | ScriptBlox Integrated",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

pcall(function()
    Window:Subtitle("Current Game: " .. gameName)
end)

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local MenuTab = Window:CreateTab("Main Menu", 4483345998)          -- TAB 1
local ScriptBloxTab = Window:CreateTab("ScriptBlox Search", 4483345998) -- TAB 2
local MainTab = Window:CreateTab("Player Movement", 4483345998)     -- TAB 3
local CombatTab = Window:CreateTab("Combat & Aim", 4483345998)       -- TAB 4
local VisualsTab = Window:CreateTab("ESP & Visuals", 4483345998)     -- TAB 5
local TeleportTab = Window:CreateTab("Teleport", 4483345998)         -- TAB 6
local MiscTab = Window:CreateTab("Misc & Automations", 4483345998)   -- TAB 7

----------------------------------------------------------------
-- TAB 1: MAIN MENU (GAME INFO & LIVE PERFORMANCE)
----------------------------------------------------------------
MenuTab:CreateSection("🎮 Game Information")

MenuTab:CreateParagraph({
    Title = "Current Game",
    Content = "Name: " .. gameName .. "\nPlace ID: " .. tostring(game.PlaceId)
})

MenuTab:CreateSection("📊 Live Performance Stats")

local FPSParagraph = MenuTab:CreateParagraph({
    Title = "⚡ Frame Rate (FPS)",
    Content = "Calculating FPS..."
})

local PingParagraph = MenuTab:CreateParagraph({
    Title = "📶 Network Latency (Ping)",
    Content = "Calculating Ping..."
})

task.spawn(function()
    local lastUpdate = os.clock()
    local frames = 0
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - lastUpdate >= 0.5 then
            local fps = math.floor(frames / (now - lastUpdate))
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            
            pcall(function()
                FPSParagraph:Set({
                    Title = "⚡ Frame Rate (FPS)",
                    Content = tostring(fps) .. " FPS"
                })
                PingParagraph:Set({
                    Title = "📶 Network Latency (Ping)",
                    Content = tostring(ping) .. " ms"
                })
            end)
            
            frames = 0
            lastUpdate = now
        end
    end)
end)

MenuTab:CreateSection("👤 User Details")

MenuTab:CreateParagraph({
    Title = "Account Info",
    Content = "Username: " .. LocalPlayer.Name .. "\nDisplay Name: " .. LocalPlayer.DisplayName
})

-- Global States
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local HitboxEnabled = false
local HitboxSize = 10
local HitboxPart = "HumanoidRootPart"
local InvisibleEnabled = false
local AntiRagdollEnabled = false
local FloatingWalkEnabled = false
local AirPlatform = nil

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

-- Anti-Aim States
local SpinbotEnabled = false
local SpinSpeed = 50

-- Teleport & Attach Variables
local SavedCFrame = nil
local SelectedPlayerName = ""
local ClickTPEnabled = false
local AttachPlayerEnabled = false

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
UIStroke.Parent = ScreenGui

----------------------------------------------------------------
-- TAB 2: SCRIPTBLOX SEARCH (NO CLEAR BUTTON - DIRECT 50 REBUILD)
----------------------------------------------------------------
local SearchQuery = ""

local function BuildScriptBloxUI(scriptsList)
    pcall(function()
        ScriptBloxTab:Empty()
    end)

    ScriptBloxTab:CreateSection("ScriptBlox Live Search Engine")

    ScriptBloxTab:CreateInput({
       Name = "Search Query",
       PlaceholderText = "Type game name or script (e.g. Rivals, Fly)",
       RemoveTextAfterFocusLost = false,
       Callback = function(Text)
          SearchQuery = Text
       end,
    })

    ScriptBloxTab:CreateButton({
       Name = "🔍 Search ScriptBlox Database",
       Callback = function()
          if SearchQuery == "" then
              Rayfield:Notify({ Title = "ScriptBlox", Content = "Please enter a search term first!", Duration = 3 })
              return
          end

          Rayfield:Notify({Title = "ScriptBlox API", Content = "Searching for: " .. SearchQuery .. "...", Duration = 2})

          task.spawn(function()
              -- Tetapkan had maksimum 50 skrip
              local apiUrl = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(SearchQuery) .. "&max=50"
              local success, response = pcall(function()
                  return game:HttpGet(apiUrl)
              end)

              if success and response then
                  local decodeSuccess, data = pcall(function()
                      return HttpService:JSONDecode(response)
                  end)

                  if decodeSuccess and data and data.result and data.result.scripts then
                      local list = data.result.scripts
                      if #list == 0 then
                          Rayfield:Notify({ Title = "ScriptBlox", Content = "No scripts found for: " .. SearchQuery, Duration = 3 })
                          return
                      end
                      BuildScriptBloxUI(list)
                      Rayfield:Notify({ Title = "Success", Content = "Loaded " .. math.min(#list, 50) .. " scripts!", Duration = 3 })
                  else
                      Rayfield:Notify({ Title = "ScriptBlox Error", Content = "Failed to parse ScriptBlox response.", Duration = 3 })
                  end
              else
                  Rayfield:Notify({ Title = "ScriptBlox Error", Content = "HTTP Request failed.", Duration = 3 })
              end
          end)
       end,
    })

    if scriptsList and #scriptsList > 0 then
        local count = math.min(#scriptsList, 50)
        ScriptBloxTab:CreateSection("Search Results (" .. count .. " Found - Max 50)")

        for i = 1, count do
            local scriptData = scriptsList[i]
            local title = scriptData.title or "Unknown Script"
            local scriptCode = scriptData.script or ""
            local isKeyRequired = scriptData.key and " [KEY REQUIRED]" or " [NO KEY]"

            ScriptBloxTab:CreateButton({
               Name = i .. ". Run: " .. title .. isKeyRequired,
               Callback = function()
                  if scriptCode ~= "" then
                      Rayfield:Notify({ Title = "Executing Script", Content = "Running " .. title, Duration = 2 })
                      pcall(function()
                          loadstring(scriptCode)()
                      end)
                  else
                      Rayfield:Notify({ Title = "Error", Content = "Script code is empty!", Duration = 2 })
                  end
               end,
            })

            ScriptBloxTab:CreateButton({
               Name = "📋 Copy Script Code #" .. i,
               Callback = function()
                  if scriptCode ~= "" and setclipboard then
                      setclipboard(scriptCode)
                      Rayfield:Notify({ Title = "Copied!", Content = "Script code copied to clipboard!", Duration = 2 })
                  else
                      Rayfield:Notify({ Title = "Error", Content = "Clipboard function not supported or empty!", Duration = 2 })
                  end
               end,
            })
        end
    end
end

-- Initialize default UI
BuildScriptBloxUI(nil)

----------------------------------------------------------------
-- TAB 3: PLAYER MOVEMENT
----------------------------------------------------------------
MainTab:CreateSection("Custom Speed & Jump (Unlimited)")

MainTab:CreateInput({
   Name = "WalkSpeed",
   PlaceholderText = "Type any speed...",
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
   PlaceholderText = "Type any jump power...",
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

MainTab:CreateSection("Gravity, Height & Floating Walk")

MainTab:CreateToggle({
   Name = "Floating Walk (Walk on Air)",
   CurrentValue = false,
   Flag = "FloatingWalkToggle",
   Callback = function(Value)
      FloatingWalkEnabled = Value
      if not FloatingWalkEnabled and AirPlatform then
          AirPlatform:Destroy()
          AirPlatform = nil
          Rayfield:Notify({ Title = "Floating Walk", Content = "Disabled!", Duration = 2 })
      else
          Rayfield:Notify({ Title = "Floating Walk", Content = "Enabled! Walk on Air Active.", Duration = 2 })
      end
   end,
})

RunService.RenderStepped:Connect(function()
    if FloatingWalkEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if not AirPlatform or not AirPlatform.Parent then
                AirPlatform = Instance.new("Part")
                AirPlatform.Name = "SYAH_AirPlatform"
                AirPlatform.Size = Vector3.new(6, 1, 6)
                AirPlatform.Transparency = 1
                AirPlatform.Anchored = true
                AirPlatform.CanCollide = true
                AirPlatform.Parent = workspace
            end
            AirPlatform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
        end)
    end
end)

MainTab:CreateInput({
   Name = "World Gravity",
   PlaceholderText = "Default: 196.2",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then workspace.Gravity = num end
   end,
})

MainTab:CreateInput({
   Name = "HipHeight / Float Level",
   PlaceholderText = "Default: 2 (Type higher to float)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
          LocalPlayer.Character:FindFirstChildOfClass("Humanoid").HipHeight = num
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
              Rayfield:Notify({ Title = "Invisibility", Content = "Invisibility Active!", Duration = 2 })
          else
              Rayfield:Notify({ Title = "Invisibility", Content = "Invisibility Disabled!", Duration = 2 })
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

MainTab:CreateSection("Camera FOV Changer (Unlimited)")

MainTab:CreateInput({
   Name = "Camera FOV",
   PlaceholderText = "Type any FOV...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then Camera.FieldOfView = num end
   end,
})

MainTab:CreateSection("Fly Engine (Unlimited Speed)")

MainTab:CreateInput({
   Name = "Fly Speed",
   PlaceholderText = "Type any fly speed...",
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

MainTab:CreateSection("Physics Modifications & Stability")

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

MainTab:CreateToggle({
   Name = "Anti-Ragdoll (Never Fall Down)",
   CurrentValue = false,
   Flag = "AntiRagdollToggle",
   Callback = function(Value)
      AntiRagdollEnabled = Value
      if AntiRagdollEnabled then
          Rayfield:Notify({ Title = "Anti-Ragdoll", Content = "Anti-Ragdoll Enabled!", Duration = 2 })
      else
          Rayfield:Notify({ Title = "Anti-Ragdoll", Content = "Anti-Ragdoll Disabled!", Duration = 2 })
      end
   end,
})

RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if AntiRagdollEnabled then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end

        if NoclipEnabled then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
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
-- TAB 4: COMBAT & AIM
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
   Name = "FOV Radius (Pixels - Unlimited)",
   PlaceholderText = "Type any radius...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local num = tonumber(Text)
      if num then
          AimbotFOV = num
          FOVFrame.Size = UDim2.new(0, num * 2, 0, num * 2)
      end
   end,
})

CombatTab:CreateSection("Hitbox Extender (Unlimited)")

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
   Name = "Hitbox Size (Studs - Unlimited)",
   PlaceholderText = "Type any size...",
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

-- Camera Aimbot Hook
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
-- TAB 5: ESP & VISUALS
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

VisualsTab:CreateSection("Map Optimization & FPS Boost")

VisualsTab:CreateButton({
   Name = "🗑️ Remove Textures & Effects (Ultra FPS Boost)",
   Callback = function()
      pcall(function()
          for _, v in pairs(workspace:GetDescendants()) do
              if v:IsA("BasePart") and not v:IsA("MeshPart") then
                  v.Material = Enum.Material.SmoothPlastic
              elseif v:IsA("Decal") or v:IsA("Texture") then
                  v:Destroy()
              elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                  v.Enabled = false
              end
          end

          Lighting.GlobalShadows = false
          Lighting.FogEnd = 9e9
          for _, v in pairs(Lighting:GetDescendants()) do
              if v:IsA("Atmosphere") or v:IsA("DepthOfFieldEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                  v:Destroy()
              end
          end
      end)
      Rayfield:Notify({ Title = "FPS Ultra Boost", Content = "Textures and Effects completely removed!", Duration = 3 })
   end,
})

VisualsTab:CreateSection("Universal Map Lighting")

VisualsTab:CreateButton({
   Name = "☀️ Enable Fullbright (No Shadows / Darkness)",
   Callback = function()
      pcall(function()
          Lighting.Ambient = Color3.fromRGB(255, 255, 255)
          Lighting.Brightness = 2
          Lighting.GlobalShadows = false
          Lighting.ClockTime = 14
      end)
      Rayfield:Notify({ Title = "Fullbright", Content = "Map Lighting Maxed!", Duration = 2 })
   end,
})

VisualsTab:CreateButton({
   Name = "🌫️ Remove Fog & Atmosphere Blur",
   Callback = function()
      pcall(function()
          Lighting.FogEnd = 9e9
          for _, v in pairs(Lighting:GetDescendants()) do
              if v:IsA("Atmosphere") or v:IsA("DepthOfFieldEffect") or v:IsA("BlurEffect") then
                  v:Destroy()
              end
          end
      end)
      Rayfield:Notify({ Title = "Fog Removed", Content = "Map view cleared!", Duration = 2 })
   end,
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
-- TAB 6: TELEPORT
----------------------------------------------------------------
TeleportTab:CreateSection("Click / Tap TP (Direct Screen Touch)")

TeleportTab:CreateToggle({
   Name = "Enable Click / Tap TP",
   CurrentValue = false,
   Flag = "ClickTPToggle",
   Callback = function(Value)
      ClickTPEnabled = Value
      if ClickTPEnabled then
          Rayfield:Notify({ Title = "Click TP", Content = "Enabled! Tap anywhere on screen to teleport.", Duration = 3 })
      else
          Rayfield:Notify({ Title = "Click TP", Content = "Disabled!", Duration = 2 })
      end
   end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if ClickTPEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        pcall(function()
            local mouse = LocalPlayer:GetMouse()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if mouse and hrp then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end
end)

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
   Name = "TP to Saved Position (Instant)",
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

TeleportTab:CreateButton({
   Name = "Tween TP to Saved Position (Smooth Anti-Cheat)",
   Callback = function()
      local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if SavedCFrame and hrp then
          local dist = (hrp.Position - SavedCFrame.Position).Magnitude
          local time = math.clamp(dist / 60, 0.5, 10)
          local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = SavedCFrame})
          tween:Play()
          Rayfield:Notify({ Title = "Tween Teleporting...", Content = "Moving safely!", Duration = math.ceil(time) })
      else
          Rayfield:Notify({ Title = "Error", Content = "Save position first!", Duration = 2 })
      end
   end,
})

TeleportTab:CreateSection("Teleport & Attach to Player")

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

TeleportTab:CreateToggle({
   Name = "Attach / Follow Player (Attach Behind)",
   CurrentValue = false,
   Flag = "AttachPlayerToggle",
   Callback = function(Value)
      AttachPlayerEnabled = Value
      if AttachPlayerEnabled then
          Rayfield:Notify({ Title = "Attach Mode", Content = "Attached to target player!", Duration = 2 })
      else
          Rayfield:Notify({ Title = "Attach Mode", Content = "Detached!", Duration = 2 })
      end
   end,
})

RunService.RenderStepped:Connect(function()
    if AttachPlayerEnabled and SelectedPlayerName ~= "" then
        pcall(function()
            local targetPlayer = Players:FindFirstChild(SelectedPlayerName)
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end)
    end
end)

----------------------------------------------------------------
-- TAB 7: MISC & AUTOMATIONS
----------------------------------------------------------------
MiscTab:CreateSection("Android App Style Auto Clicker")

MiscTab:CreateButton({
   Name = "📱 Open Auto Clicker Hub (Floating Bar)",
   Callback = function()
      pcall(function()
          local VirtualInputManager = game:GetService("VirtualInputManager")
          local GuiService = game:GetService("GuiService")
          local Players = game:GetService("Players")
          local CoreGui = game:GetService("CoreGui")
          local LocalPlayer = Players.LocalPlayer

          if CoreGui:FindFirstChild("AppAutoClickerHub") then
              CoreGui:FindFirstChild("AppAutoClickerHub"):Destroy()
          end

          local ScreenGui = Instance.new("ScreenGui")
          ScreenGui.Name = "AppAutoClickerHub"
          ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
          ScreenGui.ResetOnSpawn = false

          local IsRunning = false
          local ClickDelay = 0.05
          local ClickTargets = {}

          local BarFrame = Instance.new("Frame")
          local BarCorner = Instance.new("UICorner")
          local UIListLayout = Instance.new("UIListLayout")
          local BarStroke = Instance.new("UIStroke")

          BarFrame.Name = "ControlBar"
          BarFrame.Parent = ScreenGui
          BarFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
          BarFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
          BarFrame.Size = UDim2.new(0, 52, 0, 235)
          BarFrame.Active = true
          BarFrame.Draggable = true

          BarCorner.CornerRadius = UDim.new(0, 14)
          BarCorner.Parent = BarFrame

          BarStroke.Thickness = 1.5
          BarStroke.Color = Color3.fromRGB(50, 50, 65)
          BarStroke.Parent = BarFrame

          UIListLayout.Parent = BarFrame
          UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
          UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
          UIListLayout.Padding = UDim.new(0, 10)

          local function CreateBarButton(name, text, color, textScale)
              local Btn = Instance.new("TextButton")
              local Corner = Instance.new("UICorner")

              Btn.Name = name
              Btn.Parent = BarFrame
              Btn.BackgroundColor3 = color
              Btn.Size = UDim2.new(0, 38, 0, 38)
              Btn.Font = Enum.Font.GothamBold
              Btn.Text = text
              Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
              Btn.TextSize = textScale or 16

              Corner.CornerRadius = UDim.new(0, 10)
              Corner.Parent = Btn

              return Btn
          end

          local PlayBtn = CreateBarButton("PlayBtn", "▶", Color3.fromRGB(0, 200, 100), 16)
          local AddBtn = CreateBarButton("AddBtn", "+", Color3.fromRGB(0, 150, 255), 22)
          local SubBtn = CreateBarButton("SubBtn", "-", Color3.fromRGB(240, 140, 0), 24)
          local SettingsBtn = CreateBarButton("SettingsBtn", "⚙", Color3.fromRGB(80, 80, 95), 18)
          local CloseBtn = CreateBarButton("CloseBtn", "✕", Color3.fromRGB(220, 50, 50), 16)

          local SettingsFrame = Instance.new("Frame")
          local SettingsCorner = Instance.new("UICorner")
          local SettingsStroke = Instance.new("UIStroke")
          local SettingsTitle = Instance.new("TextLabel")
          local DelayInput = Instance.new("TextBox")
          local SaveBtn = Instance.new("TextButton")

          SettingsFrame.Name = "SettingsFrame"
          SettingsFrame.Parent = ScreenGui
          SettingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
          SettingsFrame.Position = UDim2.new(0.5, -110, 0.4, -65)
          SettingsFrame.Size = UDim2.new(0, 220, 0, 130)
          SettingsFrame.Visible = false
          SettingsFrame.Active = true
          SettingsFrame.Draggable = true

          SettingsCorner.CornerRadius = UDim.new(0, 12)
          SettingsCorner.Parent = SettingsFrame

          SettingsStroke.Thickness = 1.5
          SettingsStroke.Color = Color3.fromRGB(60, 60, 75)
          SettingsStroke.Parent = SettingsFrame

          SettingsTitle.Parent = SettingsFrame
          SettingsTitle.BackgroundTransparency = 1
          SettingsTitle.Position = UDim2.new(0, 15, 0, 12)
          SettingsTitle.Size = UDim2.new(0, 190, 0, 20)
          SettingsTitle.Font = Enum.Font.GothamBold
          SettingsTitle.Text = "⚙ Click Interval (Seconds)"
          SettingsTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
          SettingsTitle.TextSize = 13

          DelayInput.Parent = SettingsFrame
          DelayInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
          DelayInput.Position = UDim2.new(0, 15, 0, 42)
          DelayInput.Size = UDim2.new(0, 190, 0, 32)
          DelayInput.Font = Enum.Font.GothamBold
          DelayInput.Text = tostring(ClickDelay)
          DelayInput.TextColor3 = Color3.fromRGB(0, 255, 150)
          DelayInput.TextSize = 14
          DelayInput.ClearTextOnFocus = false

          local InputCorner = Instance.new("UICorner")
          InputCorner.CornerRadius = UDim.new(0, 8)
          InputCorner.Parent = DelayInput

          SaveBtn.Parent = SettingsFrame
          SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
          SaveBtn.Position = UDim2.new(0, 15, 0, 82)
          SaveBtn.Size = UDim2.new(0, 190, 0, 32)
          SaveBtn.Font = Enum.Font.GothamBold
          SaveBtn.Text = "Save Settings"
          SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
          SaveBtn.TextSize = 13

          local SaveCorner = Instance.new("UICorner")
          SaveCorner.CornerRadius = UDim.new(0, 8)
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

          local function AddTargetPoint()
              local index = #ClickTargets + 1
              
              local TargetBtn = Instance.new("TextButton")
              local TargetCorner = Instance.new("UICorner")
              local TargetStroke = Instance.new("UIStroke")

              TargetBtn.Name = "TargetPoint_" .. index
              TargetBtn.Parent = ScreenGui
              TargetBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
              TargetBtn.BackgroundTransparency = 0.3
              
              TargetBtn.Position = UDim2.new(0.35, 0, 0.4, 0)
              TargetBtn.Size = UDim2.new(0, 44, 0, 44)
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
                                  
                                  local inset = GuiService:GetGuiInset()
                                  local x = target.AbsolutePosition.X + (target.AbsoluteSize.X / 2) + inset.X
                                  local y = target.AbsolutePosition.Y + (target.AbsoluteSize.Y / 2) + inset.Y
                                  
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

          Rayfield:Notify({ Title = "Auto Clicker Hub", Content = "Auto Clicker Hub Opened!", Duration = 3 })
      end)
   end,
})

MiscTab:CreateSection("SpinBot (Anti-Aim - Unlimited Speed)")

MiscTab:CreateToggle({
   Name = "Enable SpinBot",
   CurrentValue = false,
   Flag = "SpinbotToggle",
   Callback = function(Value) SpinbotEnabled = Value end,
})

MiscTab:CreateInput({
   Name = "Spin Speed",
   PlaceholderText = "Type any spin speed...",
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

MiscTab:CreateSection("Performance Booster & Memory Cleaner")

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

MiscTab:CreateButton({
   Name = "🧹 Clean Executor RAM Memory (Anti-Crash)",
   Callback = function()
      pcall(function()
          collectgarbage("collect")
      end)
      Rayfield:Notify({ Title = "Memory Cleaned", Content = "Garbage collected! Executor RAM freed.", Duration = 2 })
   end,
})

MiscTab:CreateSection("Server Utilities")

MiscTab:CreateButton({
   Name = "Server Hop (Random Public Server)",
   Callback = function()
      pcall(function()
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
   Name = "Smallest Server Hop (Low Player Count)",
   Callback = function()
      pcall(function()
          local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
          local success, result = pcall(function()
              return HttpService:JSONDecode(game:HttpGet(Api))
          end)
          if success and result and result.data then
              local smallestServer = nil
              local minPlayers = 999
              for _, server in pairs(result.data) do
                  if server.playing < minPlayers and server.playing > 0 and server.id ~= game.JobId then
                      minPlayers = server.playing
                      smallestServer = server.id
                  end
              end
              if smallestServer then
                  TeleportService:TeleportToPlaceInstance(game.PlaceId, smallestServer, LocalPlayer)
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
