-- LocalScript (Letakkan di dalam StarterPlayerGui)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local savedPosition = nil
local isMinimized = false
local espEnabled = false
local espItems = {}

-- Variables untuk Fly & WalkSpeed
local flying = false
local flySpeed = 50
local walkSpeedValue = 16
local bv, bg, flyConn

-- 1. ScreenGui Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiniHubMobile"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Toggle Button Utama (HUB Kecil)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 24)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 10
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "HUB"
toggleButton.Parent = screenGui

local cornerToggle = Instance.new("UICorner")
cornerToggle.CornerRadius = UDim.new(0, 5)
cornerToggle.Parent = toggleButton

-- 3. Floating Shortcut Button (Butang Bulat TP Tepi Skrin - Boleh Gerak)
local tpShortcutBtn = Instance.new("TextButton")
tpShortcutBtn.Size = UDim2.new(0, 45, 0, 45)
tpShortcutBtn.Position = UDim2.new(0, 15, 0, 55)
tpShortcutBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
tpShortcutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpShortcutBtn.TextSize = 10
tpShortcutBtn.Font = Enum.Font.GothamBold
tpShortcutBtn.Text = "TP"
tpShortcutBtn.Parent = screenGui

local cornerTpShort = Instance.new("UICorner")
cornerTpShort.CornerRadius = UDim.new(0, 25)
cornerTpShort.Parent = tpShortcutBtn

-- 4. Main Frame (Hub Utama - Ditinggikan muat semua fitur)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 160, 0, 315)
mainFrame.Position = UDim2.new(0, 85, 0, 55)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerFrame = Instance.new("UICorner")
cornerFrame.CornerRadius = UDim.new(0, 6)
cornerFrame.Parent = mainFrame

-- Top Bar (Tempat Drag / Heret Hub)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 24)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local cornerTop = Instance.new("UICorner")
cornerTop.CornerRadius = UDim.new(0, 6)
cornerTop.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -45, 1, 0)
titleLabel.Position = UDim2.new(0, 6, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MOBILE HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 10
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Butang Minimize (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 18, 0, 18)
minBtn.Position = UDim2.new(1, -42, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 10
minBtn.Font = Enum.Font.GothamBold
minBtn.Text = "-"
minBtn.Parent = topBar

local cornerMin = Instance.new("UICorner")
cornerMin.CornerRadius = UDim.new(0, 3)
cornerMin.Parent = minBtn

-- Butang Close (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -21, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 9
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.Parent = topBar

local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(0, 3)
cornerClose.Parent = closeBtn

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -12, 0, 20)
statusLabel.Position = UDim2.new(0, 6, 0, 30)
statusLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextSize = 9
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: Sedia"
statusLabel.Parent = mainFrame

local cornerStatus = Instance.new("UICorner")
cornerStatus.CornerRadius = UDim.new(0, 3)
cornerStatus.Parent = statusLabel

-- Butang 1: Set Posisi
local setBtn = Instance.new("TextButton")
setBtn.Size = UDim2.new(1, -12, 0, 24)
setBtn.Position = UDim2.new(0, 6, 0, 55)
setBtn.BackgroundColor3 = Color3.fromRGB(210, 110, 0)
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.TextSize = 10
setBtn.Font = Enum.Font.GothamBold
setBtn.Text = "SET POSISI"
setBtn.Parent = mainFrame

local cornerSet = Instance.new("UICorner")
cornerSet.CornerRadius = UDim.new(0, 3)
cornerSet.Parent = setBtn

-- Butang 2: Teleport
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, -12, 0, 24)
tpBtn.Position = UDim2.new(0, 6, 0, 83)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.TextSize = 10
tpBtn.Font = Enum.Font.GothamBold
tpBtn.Text = "TELEPORT"
tpBtn.Parent = mainFrame

local cornerTp = Instance.new("UICorner")
cornerTp.CornerRadius = UDim.new(0, 3)
cornerTp.Parent = tpBtn

-- Butang 3: Insta E (KEMBALI!)
local instaEBtn = Instance.new("TextButton")
instaEBtn.Size = UDim2.new(1, -12, 0, 24)
instaEBtn.Position = UDim2.new(0, 6, 0, 111)
instaEBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
instaEBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
instaEBtn.TextSize = 10
instaEBtn.Font = Enum.Font.GothamBold
instaEBtn.Text = "INSTA E"
instaEBtn.Parent = mainFrame

local cornerInstaE = Instance.new("UICorner")
cornerInstaE.CornerRadius = UDim.new(0, 3)
cornerInstaE.Parent = instaEBtn

-- Butang 4: ESP Box
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, -12, 0, 24)
espBtn.Position = UDim2.new(0, 6, 0, 139)
espBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 10
espBtn.Font = Enum.Font.GothamBold
espBtn.Text = "ESP BOX: OFF"
espBtn.Parent = mainFrame

local cornerEsp = Instance.new("UICorner")
cornerEsp.CornerRadius = UDim.new(0, 3)
cornerEsp.Parent = espBtn

-- Butang 5: FLY Toggle
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -12, 0, 24)
flyBtn.Position = UDim2.new(0, 6, 0, 167)
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 10
flyBtn.Font = Enum.Font.GothamBold
flyBtn.Text = "FLY: OFF"
flyBtn.Parent = mainFrame

local cornerFly = Instance.new("UICorner")
cornerFly.CornerRadius = UDim.new(0, 3)
cornerFly.Parent = flyBtn

-- --- WIDGET / KOTAK KELAJUAN FLY (0 - 500) ---
local flySpeedBox = Instance.new("TextBox")
flySpeedBox.Size = UDim2.new(1, -12, 0, 22)
flySpeedBox.Position = UDim2.new(0, 6, 0, 195)
flySpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
flySpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedBox.TextSize = 10
flySpeedBox.Font = Enum.Font.Gotham
flySpeedBox.PlaceholderText = "Fly Speed (0-500)"
flySpeedBox.Text = "50"
flySpeedBox.Parent = mainFrame

local cornerFlyBox = Instance.new("UICorner")
cornerFlyBox.CornerRadius = UDim.new(0, 3)
cornerFlyBox.Parent = flySpeedBox

-- --- WIDGET / KOTAK WALKSPEED (0 - 500) ---
local walkSpeedBox = Instance.new("TextBox")
walkSpeedBox.Size = UDim2.new(1, -12, 0, 22)
walkSpeedBox.Position = UDim2.new(0, 6, 0, 222)
walkSpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
walkSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
walkSpeedBox.TextSize = 10
walkSpeedBox.Font = Enum.Font.Gotham
walkSpeedBox.PlaceholderText = "WalkSpeed (0-500)"
walkSpeedBox.Text = "16"
walkSpeedBox.Parent = mainFrame

local cornerWalkBox = Instance.new("UICorner")
cornerWalkBox.CornerRadius = UDim.new(0, 3)
cornerWalkBox.Parent = walkSpeedBox

-- Butang Apply Speed
local applySpeedBtn = Instance.new("TextButton")
applySpeedBtn.Size = UDim2.new(1, -12, 0, 24)
applySpeedBtn.Position = UDim2.new(0, 6, 0, 249)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
applySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedBtn.TextSize = 10
applySpeedBtn.Font = Enum.Font.GothamBold
applySpeedBtn.Text = "SET KELAJUAN"
applySpeedBtn.Parent = mainFrame

local cornerApply = Instance.new("UICorner")
cornerApply.CornerRadius = UDim.new(0, 3)
cornerApply.Parent = applySpeedBtn


-- --- SISTEM DRAG UNTUK HUB ---
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)


-- --- SISTEM DRAG UNTUK BUTANG BULAT TP ---
local draggingTP = false
local tpDragStart, tpStartPos

tpShortcutBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTP = true
        tpDragStart = input.Position
        tpStartPos = tpShortcutBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingTP = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingTP and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tpDragStart
        tpShortcutBtn.Position = UDim2.new(
            tpStartPos.X.Scale, 
            tpStartPos.X.Offset + delta.X, 
            tpStartPos.Y.Scale, 
            tpStartPos.Y.Offset + delta.Y
        )
    end
end)


-- --- FUNGSI TELEPORT ---
local function executeTeleport()
    if savedPosition then
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = savedPosition
            statusLabel.Text = "Berjaya TP!"
        end
    else
        statusLabel.Text = "Set posisi dulu!"
    end
end


-- --- FUNGSI FLY (TERBANG) ---
local function toggleFly()
    flying = not flying
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    if flying then
        flyBtn.Text = "FLY: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        statusLabel.Text = "Fly: ON"
        
        hum.PlatformStand = true
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        
        flyConn = RunService.RenderStepped:Connect(function()
            if not flying or not hrp or not hum then 
                if flyConn then flyConn:Disconnect() end
                return 
            end
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                bv.Velocity = cam.CFrame.LookVector * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = cam.CFrame
        end)
    else
        flyBtn.Text = "FLY: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
        statusLabel.Text = "Fly: OFF"
        
        hum.PlatformStand = false
        if flyConn then flyConn:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end


-- --- FUNGSI APPLY KELAJUAN ASING (FLY & WALKSPEED) ---
applySpeedBtn.MouseButton1Click:Connect(function()
    local parsedFly = tonumber(flySpeedBox.Text)
    if parsedFly then
        flySpeed = math.clamp(parsedFly, 0, 500)
        flySpeedBox.Text = tostring(flySpeed)
    end
    
    local parsedWalk = tonumber(walkSpeedBox.Text)
    if parsedWalk then
        walkSpeedValue = math.clamp(parsedWalk, 0, 500)
        walkSpeedBox.Text = tostring(walkSpeedValue)
        
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = walkSpeedValue
            end
        end
    end
    statusLabel.Text = "Speed Diset!"
end)

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then
        hum.WalkSpeed = walkSpeedValue
    end
end)


-- --- FUNGSI ESP BOX + NAME + DISTANCE ---
local function setupESP(plr)
    if plr == player then return end
    
    local function removeESP()
        if espItems[plr] then
            if espItems[plr].box then espItems[plr].box:Destroy() end
            if espItems[plr].billboard then espItems[plr].billboard:Destroy() end
            if espItems[plr].conn then espItems[plr].conn:Disconnect() end
            espItems[plr] = nil
        end
    end
    
    local function addESP(char)
        removeESP()
        if not espEnabled then return end
        
        local rootPart = char:WaitForChild("HumanoidRootPart", 3)
        local head = char:WaitForChild("Head", 3)
        if not rootPart or not head then return end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = rootPart
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Size = Vector3.new(3, 5, 3)
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.4
        box.Parent = char
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPInfo"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboard
        
        local conn = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not rootPart then 
                removeESP()
                return 
            end
            local myChar = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myRoot = myChar.HumanoidRootPart
                local distance = math.floor((rootPart.Position - myRoot.Position).Magnitude)
                textLabel.Text = plr.Name .. "\n[" .. distance .. "m]"
            end
        end)
        
        espItems[plr] = {box = box, billboard = billboard, conn = conn}
    end
    
    plr.CharacterAdded:Connect(addESP)
    if plr.Character then
        addESP(plr.Character)
    end
    
    plr.AncestryChanged:Connect(function(_, parent)
        if not parent then removeESP() end
    end)
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP BOX: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(115, 30, 145)
        statusLabel.Text = "ESP Box: ON"
        
        for _, plr in ipairs(Players:GetPlayers()) do
            setupESP(plr)
        end
        Players.PlayerAdded:Connect(setupESP)
    else
        espBtn.Text = "ESP BOX: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
        statusLabel.Text = "ESP Box: OFF"
        
        for plr, _ in pairs(espItems) do
            if espItems[plr] then
                if espItems[plr].box then espItems[plr].box:Destroy() end
                if espItems[plr].billboard then espItems[plr].billboard:Destroy() end
                if espItems[plr].conn then espItems[plr].conn:Disconnect() end
                espItems[plr] = nil
            end
        end
        espItems = {}
    end
end


-- --- EVENT BUTTONS ---
setBtn.MouseButton1Click:Connect(function()
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedPosition = rootPart.CFrame
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLabel.Text = "Posisi Diset!"
    end
end)

tpBtn.MouseButton1Click:Connect(executeTeleport)
tpShortcutBtn.MouseButton1Click:Connect(executeTeleport)

local instaELoaded = false
instaEBtn.MouseButton1Click:Connect(function()
    if not instaELoaded then
        instaELoaded = true
        instaEBtn.Text = "INSTA E: ON"
        pcall(function()
            loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Insta-E-Button-82794"))()
        end)
    end
end)

espBtn.MouseButton1Click:Connect(toggleESP)
flyBtn.MouseButton1Click:Connect(toggleFly)


-- Minimize & Close Button Logic
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    setBtn.Visible = not isMinimized
    tpBtn.Visible = not isMinimized
    instaEBtn.Visible = not isMinimized
    espBtn.Visible = not isMinimized
    flyBtn.Visible = not isMinimized
    flySpeedBox.Visible = not isMinimized
    walkSpeedBox.Visible = not isMinimized
    applySpeedBtn.Visible = not isMinimized
    statusLabel.Visible = not isMinimized
    
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 160, 0, 24)
        minBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 160, 0, 315)
        minBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    if isMinimized then
        isMinimized = false
        setBtn.Visible = true
        tpBtn.Visible = true
        instaEBtn.Visible = true
        espBtn.Visible = true
        flyBtn.Visible = true
        flySpeedBox.Visible = true
        walkSpeedBox.Visible = true
        applySpeedBtn.Visible = true
        statusLabel.Visible = true
        mainFrame.Size = UDim2.new(0, 160, 0, 315)
        minBtn.Text = "-"
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

