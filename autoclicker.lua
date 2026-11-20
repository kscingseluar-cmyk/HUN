local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function getCurrentGameName()
	local gameName = "Roblox Game"
	pcall(function()
		local info = MarketplaceService:GetProductInfo(game.PlaceId)
		if info and type(info.Name) == "string" and info.Name ~= "" then
			gameName = info.Name
		end
	end)
	return gameName
end

local currentGameName = getCurrentGameName()

local function getSafeGuiParent()
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and coreGui then
		local testOk = pcall(function()
			local f = Instance.new("Folder")
			f.Name = "__GuiParentTest"
			f.Parent = coreGui
			f:Destroy()
		end)
		if testOk then
			return coreGui
		end
	end
	return playerGui
end

local guiParent = getSafeGuiParent()

for _, parent in ipairs({ guiParent, playerGui }) do
	local existingGui = parent and parent:FindFirstChild("CustomTeleportHub")
	if existingGui then
		pcall(function() existingGui:Destroy() end)
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomTeleportHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

-- Main Hub Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 264)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -132)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 65, 80)
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

-- Fungsi Drag Frame (Mouse + Touch)
local function makeFrameDraggable(dragHandle, targetFrame)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position
		end
	end)

	dragHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Floating Restore Bar ("TP Hub") yang Boleh Move
local restoreHolder = Instance.new("Frame")
restoreHolder.Name = "RestoreHolder"
restoreHolder.Size = UDim2.new(0, 96, 0, 26)
restoreHolder.Position = UDim2.new(0, 14, 0.5, -13)
restoreHolder.BackgroundColor3 = Color3.fromRGB(35, 130, 246)
restoreHolder.BorderSizePixel = 0
restoreHolder.Visible = false
restoreHolder.Active = true
restoreHolder.Parent = screenGui

local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(0, 6)
restoreCorner.Parent = restoreHolder

local restoreDrag = Instance.new("TextButton")
restoreDrag.Name = "RestoreDrag"
restoreDrag.Size = UDim2.new(0, 20, 1, 0)
restoreDrag.Position = UDim2.new(0, 0, 0, 0)
restoreDrag.BackgroundColor3 = Color3.fromRGB(29, 78, 216)
restoreDrag.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreDrag.Text = "::"
restoreDrag.Font = Enum.Font.GothamBold
restoreDrag.TextSize = 10
restoreDrag.Parent = restoreHolder

local restoreDragCorner = Instance.new("UICorner")
restoreDragCorner.CornerRadius = UDim.new(0, 6)
restoreDragCorner.Parent = restoreDrag

local restoreBtn = Instance.new("TextButton")
restoreBtn.Name = "RestoreButton"
restoreBtn.Size = UDim2.new(1, -22, 1, 0)
restoreBtn.Position = UDim2.new(0, 21, 0, 0)
restoreBtn.BackgroundTransparency = 1
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.Text = "TP Hub"
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 10
restoreBtn.Parent = restoreHolder

makeFrameDraggable(restoreDrag, restoreHolder)

-- ==========================================
-- TOP BAR (HUB + NAMA GAME DI TEPI)
-- ==========================================
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 28)
topBar.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topBar

local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 8)
topCover.Position = UDim2.new(0, 0, 1, -8)
topCover.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
topCover.BorderSizePixel = 0
topCover.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -185, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HUB"
titleLabel.TextColor3 = Color3.fromRGB(240, 244, 248)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
titleLabel.Parent = topBar

local gameNameEdgeLabel = Instance.new("TextLabel")
gameNameEdgeLabel.Name = "GameNameEdgeLabel"
gameNameEdgeLabel.Size = UDim2.new(0, 118, 1, 0)
gameNameEdgeLabel.Position = UDim2.new(1, -172, 0, 0)
gameNameEdgeLabel.BackgroundTransparency = 1
gameNameEdgeLabel.Text = currentGameName
gameNameEdgeLabel.TextColor3 = Color3.fromRGB(147, 197, 253)
gameNameEdgeLabel.Font = Enum.Font.GothamSemibold
gameNameEdgeLabel.TextSize = 9
gameNameEdgeLabel.TextXAlignment = Enum.TextXAlignment.Right
gameNameEdgeLabel.TextTruncate = Enum.TextTruncate.AtEnd
gameNameEdgeLabel.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 22, 0, 20)
minBtn.Position = UDim2.new(1, -50, 0.5, -10)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 68)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 22, 0, 20)
closeBtn.Position = UDim2.new(1, -26, 0.5, -10)
closeBtn.BackgroundColor3 = Color3.fromRGB(210, 60, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

makeFrameDraggable(topBar, mainFrame)

minBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	restoreHolder.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	restoreHolder.Visible = false
	mainFrame.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	pcall(function()
		screenGui:Destroy()
	end)
end)

-- Bar Tab di Bahagian Kiri
local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(0, 92, 1, -34)
tabBar.Position = UDim2.new(0, 6, 0, 31)
tabBar.BackgroundColor3 = Color3.fromRGB(28, 31, 38)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 6)
tabBarCorner.Parent = tabBar

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Padding = UDim.new(0, 4)
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 5)
tabPadding.PaddingBottom = UDim.new(0, 5)
tabPadding.PaddingLeft = UDim.new(0, 5)
tabPadding.PaddingRight = UDim.new(0, 5)
tabPadding.Parent = tabBar

-- Kawasan Kandungan Tab di Bahagian Kanan
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -108, 1, -34)
contentArea.Position = UDim2.new(0, 102, 0, 31)
contentArea.BackgroundColor3 = Color3.fromRGB(28, 31, 38)
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 6)
contentCorner.Parent = contentArea

-- Helper Karakter & Teleport
local function getHumanoidAndRoot()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	return char, hum, hrp
end

local function teleportToCFrame(targetCFrame)
	local _, _, hrp = getHumanoidAndRoot()
	if hrp then
		pcall(function()
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
		end)
	end
end

local function copyToClipboardSafe(text)
	if not text or text == "" then return false end
	local ok = false
	pcall(function()
		if setclipboard then
			setclipboard(text)
			ok = true
		elseif toclipboard then
			toclipboard(text)
			ok = true
		end
	end)
	return ok
end

local function runScriptCodeSafe(code)
	if not code or code == "" then return end
	pcall(function()
		local fn = loadstring(code)
		if fn then
			fn()
		end
	end)
end

-- Sistem Pengurusan Tab & Floating Shortcut
local tabs = {}
local activeTabName = nil
local tabCounter = 0
local savedPosCounter = 0
local floatingOffsetIndex = 0

local function selectTab(tabName)
	activeTabName = tabName
	for name, data in pairs(tabs) do
		local isSelected = (name == tabName)
		data.page.Visible = isSelected
		data.button.BackgroundColor3 = isSelected and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(40, 44, 54)
		data.button.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 196, 210)
	end
end

local function createFloatingAction(shortLabel, defaultColor, onClickAction)
	floatingOffsetIndex += 1
	local yOffset = -90 + ((floatingOffsetIndex - 1) * 32)

	local floatHolder = Instance.new("Frame")
	floatHolder.Name = "Hub_FloatingAction"
	floatHolder.Size = UDim2.new(0, 108, 0, 26)
	floatHolder.Position = UDim2.new(1, -122, 0.5, yOffset)
	floatHolder.BackgroundColor3 = defaultColor or Color3.fromRGB(35, 130, 246)
	floatHolder.BorderSizePixel = 0
	floatHolder.Active = true
	floatHolder.Parent = screenGui

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = floatHolder

	local fStroke = Instance.new("UIStroke")
	fStroke.Color = Color3.fromRGB(147, 197, 253)
	fStroke.Thickness = 1
	fStroke.Parent = floatHolder

	local dragGrip = Instance.new("TextButton")
	dragGrip.Size = UDim2.new(0, 22, 1, 0)
	dragGrip.Position = UDim2.new(0, 0, 0, 0)
	dragGrip.BackgroundColor3 = Color3.fromRGB(29, 78, 216)
	dragGrip.TextColor3 = Color3.fromRGB(255, 255, 255)
	dragGrip.Text = "::"
	dragGrip.Font = Enum.Font.GothamBold
	dragGrip.TextSize = 10
	dragGrip.Parent = floatHolder

	local gripCorner = Instance.new("UICorner")
	gripCorner.CornerRadius = UDim.new(0, 6)
	gripCorner.Parent = dragGrip

	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(1, -24, 1, 0)
	actionBtn.Position = UDim2.new(0, 23, 0, 0)
	actionBtn.BackgroundTransparency = 1
	actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionBtn.Text = shortLabel
	actionBtn.Font = Enum.Font.GothamBold
	actionBtn.TextSize = 10
	actionBtn.TextTruncate = Enum.TextTruncate.AtEnd
	actionBtn.Parent = floatHolder

	makeFrameDraggable(dragGrip, floatHolder)

	actionBtn.MouseButton1Click:Connect(function()
		if onClickAction then
			onClickAction(actionBtn, floatHolder)
		end
	end)

	return floatHolder, actionBtn
end

local function addTeleportButton(tabName, labelText, cframe)
	local tabData = tabs[tabName]
	if not tabData then return end

	local activeFloatingBtn = nil

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 26)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = tabData.listContainer

	local tpBtn = Instance.new("TextButton")
	tpBtn.Size = UDim2.new(1, -48, 1, 0)
	tpBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 62)
	tpBtn.TextColor3 = Color3.fromRGB(240, 244, 248)
	tpBtn.Text = labelText
	tpBtn.Font = Enum.Font.GothamSemibold
	tpBtn.TextSize = 10
	tpBtn.TextTruncate = Enum.TextTruncate.AtEnd
	tpBtn.Parent = rowFrame

	local tpCorner = Instance.new("UICorner")
	tpCorner.CornerRadius = UDim.new(0, 5)
	tpCorner.Parent = tpBtn

	local pinBtn = Instance.new("TextButton")
	pinBtn.Size = UDim2.new(0, 22, 1, 0)
	pinBtn.Position = UDim2.new(1, -44, 0, 0)
	pinBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
	pinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	pinBtn.Text = "★"
	pinBtn.Font = Enum.Font.GothamBold
	pinBtn.TextSize = 10
	pinBtn.Parent = rowFrame

	local pinCorner = Instance.new("UICorner")
	pinCorner.CornerRadius = UDim.new(0, 5)
	pinCorner.Parent = pinBtn

	local delBtn = Instance.new("TextButton")
	delBtn.Size = UDim2.new(0, 20, 1, 0)
	delBtn.Position = UDim2.new(1, -20, 0, 0)
	delBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 45)
	delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	delBtn.Text = "x"
	delBtn.Font = Enum.Font.GothamBold
	delBtn.TextSize = 10
	delBtn.Parent = rowFrame

	local delCorner = Instance.new("UICorner")
	delCorner.CornerRadius = UDim.new(0, 5)
	delCorner.Parent = delBtn

	tpBtn.MouseButton1Click:Connect(function()
		teleportToCFrame(cframe)
	end)

	pinBtn.MouseButton1Click:Connect(function()
		if activeFloatingBtn then
			activeFloatingBtn:Destroy()
			activeFloatingBtn = nil
			pinBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
		else
			local cleanShort = string.gsub(labelText, "%s*%b()$", "")
			if cleanShort == "" then cleanShort = labelText end
			activeFloatingBtn = createFloatingAction(cleanShort, Color3.fromRGB(35, 130, 246), function()
				teleportToCFrame(cframe)
			end)
			pinBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		end
	end)

	delBtn.MouseButton1Click:Connect(function()
		if activeFloatingBtn then
			activeFloatingBtn:Destroy()
			activeFloatingBtn = nil
		end
		rowFrame:Destroy()
	end)
end

local function addToggleButton(tabName, titleText, initialState, onToggled, withFloatingShortcut)
	local tabData = tabs[tabName]
	if not tabData then return end

	local state = initialState or false
	local listeners = {}
	local activeFloatingHolder = nil
	local activeFloatingActionBtn = nil

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 26)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = tabData.listContainer

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, withFloatingShortcut and -26 or 0, 1, 0)
	toggleBtn.Font = Enum.Font.GothamSemibold
	toggleBtn.TextSize = 10
	toggleBtn.TextTruncate = Enum.TextTruncate.AtEnd
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Parent = rowFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = toggleBtn

	local function refreshVisual()
		toggleBtn.Text = titleText .. ": " .. (state and "ON" or "OFF")
		toggleBtn.BackgroundColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 50, 62)

		if activeFloatingHolder and activeFloatingActionBtn then
			activeFloatingActionBtn.Text = titleText .. ": " .. (state and "ON" or "OFF")
			activeFloatingHolder.BackgroundColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(35, 130, 246)
		end
	end

	local function setState(newState)
		state = newState and true or false
		refreshVisual()
		if onToggled then
			onToggled(state)
		end
		for _, fn in ipairs(listeners) do
			fn(state)
		end
	end

	refreshVisual()

	toggleBtn.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	if withFloatingShortcut then
		local pinBtn = Instance.new("TextButton")
		pinBtn.Size = UDim2.new(0, 22, 1, 0)
		pinBtn.Position = UDim2.new(1, -22, 0, 0)
		pinBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
		pinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		pinBtn.Text = "★"
		pinBtn.Font = Enum.Font.GothamBold
		pinBtn.TextSize = 10
		pinBtn.Parent = rowFrame

		local pinCorner = Instance.new("UICorner")
		pinCorner.CornerRadius = UDim.new(0, 5)
		pinCorner.Parent = pinBtn

		pinBtn.MouseButton1Click:Connect(function()
			if activeFloatingHolder then
				activeFloatingHolder:Destroy()
				activeFloatingHolder = nil
				activeFloatingActionBtn = nil
				pinBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
			else
				activeFloatingHolder, activeFloatingActionBtn = createFloatingAction(
					titleText .. ": " .. (state and "ON" or "OFF"),
					state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(35, 130, 246),
					function()
						setState(not state)
					end
				)
				pinBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
			end
		end)
	end

	return {
		isEnabled = function() return state end,
		setState = setState,
		onChanged = function(fn) table.insert(listeners, fn) end,
	}
end

local function addCustomNumberControl(tabName, labelPrefix, defaultValue, autoEnableOnInput, onStateChange)
	local tabData = tabs[tabName]
	if not tabData then return end

	local value = defaultValue
	local active = false

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 26)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = tabData.listContainer

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, -56, 1, 0)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 62)
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Font = Enum.Font.GothamSemibold
	toggleBtn.TextSize = 10
	toggleBtn.TextTruncate = Enum.TextTruncate.AtEnd
	toggleBtn.Parent = rowFrame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 5)
	toggleCorner.Parent = toggleBtn

	local numBox = Instance.new("TextBox")
	numBox.Size = UDim2.new(0, 52, 1, 0)
	numBox.Position = UDim2.new(1, -52, 0, 0)
	numBox.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
	numBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	numBox.PlaceholderText = "Nilai"
	numBox.PlaceholderColor3 = Color3.fromRGB(130, 138, 155)
	numBox.Text = tostring(value)
	numBox.Font = Enum.Font.GothamBold
	numBox.TextSize = 10
	numBox.ClearTextOnFocus = false
	numBox.Parent = rowFrame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 5)
	boxCorner.Parent = numBox

	local function refreshUI()
		toggleBtn.Text = labelPrefix .. " (" .. tostring(value) .. "): " .. (active and "ON" or "OFF")
		toggleBtn.BackgroundColor3 = active and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 50, 62)
		if onStateChange then
			onStateChange(active, value)
		end
	end

	local function applyInput()
		local parsed = tonumber(numBox.Text)
		if parsed and parsed >= 0 then
			value = parsed
			numBox.Text = tostring(value)
			if autoEnableOnInput then
				active = true
			end
			refreshUI()
		else
			numBox.Text = tostring(value)
		end
	end

	toggleBtn.MouseButton1Click:Connect(function()
		active = not active
		refreshUI()
	end)

	numBox.FocusLost:Connect(function()
		applyInput()
	end)

	refreshUI()

	return {
		isEnabled = function() return active end,
		getValue = function() return value end,
	}
end

local function createTab(tabName, mode)
	if tabs[tabName] then
		selectTab(tabName)
		return tabs[tabName]
	end

	tabCounter += 1

	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = "TabBtn_" .. tabName
	tabBtn.Size = UDim2.new(1, 0, 0, 26)
	tabBtn.LayoutOrder = tabCounter
	tabBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 54)
	tabBtn.TextColor3 = Color3.fromRGB(190, 196, 210)
	tabBtn.Text = tabName
	tabBtn.Font = Enum.Font.GothamSemibold
	tabBtn.TextSize = 10
	tabBtn.TextTruncate = Enum.TextTruncate.AtEnd
	tabBtn.Parent = tabBar

	local tabBtnCorner = Instance.new("UICorner")
	tabBtnCorner.CornerRadius = UDim.new(0, 5)
	tabBtnCorner.Parent = tabBtn

	local page = Instance.new("Frame")
	page.Name = "Page_" .. tabName
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentArea

	local topOffset = 0

	if mode == "teleport" then
		topOffset = 34

		local setPosBar = Instance.new("Frame")
		setPosBar.Size = UDim2.new(1, -12, 0, 24)
		setPosBar.Position = UDim2.new(0, 6, 0, 6)
		setPosBar.BackgroundTransparency = 1
		setPosBar.Parent = page

		local posNameInput = Instance.new("TextBox")
		posNameInput.Size = UDim2.new(1, -64, 1, 0)
		posNameInput.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
		posNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		posNameInput.PlaceholderText = "Nama pos..."
		posNameInput.PlaceholderColor3 = Color3.fromRGB(130, 138, 155)
		posNameInput.Text = ""
		posNameInput.Font = Enum.Font.Gotham
		posNameInput.TextSize = 10
		posNameInput.ClearTextOnFocus = false
		posNameInput.Parent = setPosBar

		local posInputCorner = Instance.new("UICorner")
		posInputCorner.CornerRadius = UDim.new(0, 5)
		posInputCorner.Parent = posNameInput

		local setPosBtn = Instance.new("TextButton")
		setPosBtn.Size = UDim2.new(0, 60, 1, 0)
		setPosBtn.Position = UDim2.new(1, -60, 0, 0)
		setPosBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		setPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setPosBtn.Text = "Set Pos"
		setPosBtn.Font = Enum.Font.GothamBold
		setPosBtn.TextSize = 10
		setPosBtn.Parent = setPosBar

		local setPosCorner = Instance.new("UICorner")
		setPosCorner.CornerRadius = UDim.new(0, 5)
		setPosCorner.Parent = setPosBtn

		local function saveCurrentPosition()
			local _, _, hrp = getHumanoidAndRoot()
			if not hrp then return end

			savedPosCounter += 1
			local customName = string.match(posNameInput.Text, "^%s*(.-)%s*$")
			local pos = hrp.Position
			local coordText = string.format("(%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z)
			local label = (customName and customName ~= "") and (customName .. " " .. coordText) or ("Pos #" .. savedPosCounter .. " " .. coordText)

			addTeleportButton(tabName, label, hrp.CFrame)
			posNameInput.Text = ""
		end

		setPosBtn.MouseButton1Click:Connect(saveCurrentPosition)
		posNameInput.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				saveCurrentPosition()
			end
		end)
	elseif mode == "scriptblox" then
		topOffset = 46
		local MAX_SCRIPTBLOX_RESULTS = 30

		local searchBar = Instance.new("Frame")
		searchBar.Size = UDim2.new(1, -12, 0, 38)
		searchBar.Position = UDim2.new(0, 6, 0, 5)
		searchBar.BackgroundTransparency = 1
		searchBar.Parent = page

		-- Kotak carian + Shortcut simbol ★ di tepi carian + Butang Cari
		local searchBox = Instance.new("TextBox")
		searchBox.Size = UDim2.new(1, -78, 0, 19)
		searchBox.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
		searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		searchBox.PlaceholderText = "Cari di ScriptBlox (max 30)..."
		searchBox.PlaceholderColor3 = Color3.fromRGB(130, 138, 155)
		searchBox.Text = ""
		searchBox.Font = Enum.Font.Gotham
		searchBox.TextSize = 9
		searchBox.ClearTextOnFocus = false
		searchBox.Parent = searchBar

		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

		local starShortcutBtn = Instance.new("TextButton")
		starShortcutBtn.Size = UDim2.new(0, 20, 0, 19)
		starShortcutBtn.Position = UDim2.new(1, -75, 0, 0)
		starShortcutBtn.BackgroundColor3 = Color3.fromRGB(217, 119, 6)
		starShortcutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		starShortcutBtn.Text = "★"
		starShortcutBtn.Font = Enum.Font.GothamBold
		starShortcutBtn.TextSize = 10
		starShortcutBtn.Parent = searchBar

		Instance.new("UICorner", starShortcutBtn).CornerRadius = UDim.new(0, 4)

		local searchBtn = Instance.new("TextButton")
		searchBtn.Size = UDim2.new(0, 52, 0, 19)
		searchBtn.Position = UDim2.new(1, -52, 0, 0)
		searchBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
		searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		searchBtn.Text = "Cari"
		searchBtn.Font = Enum.Font.GothamBold
		searchBtn.TextSize = 9
		searchBtn.Parent = searchBar

		Instance.new("UICorner", searchBtn).CornerRadius = UDim.new(0, 4)

		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.new(1, 0, 0, 16)
		statusLabel.Position = UDim2.new(0, 0, 0, 21)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "Limit 30 script • Klik ★ untuk shortcut"
		statusLabel.TextColor3 = Color3.fromRGB(165, 175, 195)
		statusLabel.Font = Enum.Font.Gotham
		statusLabel.TextSize = 8
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Parent = searchBar

		-- Bar shortcut pantas bila klik ★ di tepi carian
		local quickPresetBar = Instance.new("Frame")
		quickPresetBar.Size = UDim2.new(1, -12, 0, 22)
		quickPresetBar.Position = UDim2.new(0, 6, 0, 44)
		quickPresetBar.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
		quickPresetBar.BorderSizePixel = 0
		quickPresetBar.Visible = false
		quickPresetBar.Parent = page

		Instance.new("UICorner", quickPresetBar).CornerRadius = UDim.new(0, 5)

		local presets = { "Universal", "Blox Fruits", "Auto Farm", "ESP" }
		for idx, presetWord in ipairs(presets) do
			local pBtn = Instance.new("TextButton")
			pBtn.Size = UDim2.new(0.25, -3, 1, -4)
			pBtn.Position = UDim2.new((idx - 1) * 0.25, 2, 0, 2)
			pBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 64)
			pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			pBtn.Text = presetWord
			pBtn.Font = Enum.Font.GothamBold
			pBtn.TextSize = 8
			pBtn.TextTruncate = Enum.TextTruncate.AtEnd
			pBtn.Parent = quickPresetBar

			Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

			pBtn.MouseButton1Click:Connect(function()
				searchBox.Text = presetWord
				starShortcutBtn.BackgroundColor3 = Color3.fromRGB(217, 119, 6)
				quickPresetBar.Visible = false
				topOffset = 46
				if tabs[tabName] and tabs[tabName].listContainer then
					tabs[tabName].listContainer.Size = UDim2.new(1, 0, 1, -topOffset)
					tabs[tabName].listContainer.Position = UDim2.new(0, 0, 0, topOffset)
				end
				searchBtn:Activate()
			end)
		end

		local function clearResults()
			for _, child in ipairs(tabs[tabName].listContainer:GetChildren()) do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
		end

		local function addScriptBloxCard(item)
			local titleText = tostring(item.title or "Untitled Script")
			local rawScript = tostring(item.script or "")
			local requiresKey = (item.key == true) or (item.hasKey == true)

			local card = Instance.new("Frame")
			card.Size = UDim2.new(1, 0, 0, 42)
			card.BackgroundColor3 = Color3.fromRGB(35, 39, 50)
			card.BorderSizePixel = 0
			card.Parent = tabs[tabName].listContainer

			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

			local titleLbl = Instance.new("TextLabel")
			titleLbl.Size = UDim2.new(1, -8, 0, 16)
			titleLbl.Position = UDim2.new(0, 4, 0, 2)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text = titleText
			titleLbl.TextColor3 = Color3.fromRGB(245, 248, 255)
			titleLbl.Font = Enum.Font.GothamBold
			titleLbl.TextSize = 9
			titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.Parent = card

			local copyBtn = Instance.new("TextButton")
			copyBtn.Size = UDim2.new(0.32, -2, 0, 18)
			copyBtn.Position = UDim2.new(0, 4, 0, 21)
			copyBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 85)
			copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			copyBtn.Text = "Copy"
			copyBtn.Font = Enum.Font.GothamBold
			copyBtn.TextSize = 8
			copyBtn.Parent = card

			Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)

			local keyBadge = Instance.new("TextLabel")
			keyBadge.Size = UDim2.new(0.34, -2, 0, 18)
			keyBadge.Position = UDim2.new(0.33, 1, 0, 21)
			keyBadge.BackgroundColor3 = requiresKey and Color3.fromRGB(217, 119, 6) or Color3.fromRGB(22, 163, 74)
			keyBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
			keyBadge.Text = requiresKey and "KEY" or "NO KEY"
			keyBadge.Font = Enum.Font.GothamBold
			keyBadge.TextSize = 8
			keyBadge.Parent = card

			Instance.new("UICorner", keyBadge).CornerRadius = UDim.new(0, 4)

			local runBtn = Instance.new("TextButton")
			runBtn.Size = UDim2.new(0.31, -4, 0, 18)
			runBtn.Position = UDim2.new(0.68, 0, 0, 21)
			runBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
			runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			runBtn.Text = "Run"
			runBtn.Font = Enum.Font.GothamBold
			runBtn.TextSize = 8
			runBtn.Parent = card

			Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 4)

			copyBtn.MouseButton1Click:Connect(function()
				local copied = copyToClipboardSafe(rawScript)
				copyBtn.Text = copied and "Copied!" or "No Clip"
				task.delay(1.2, function()
					if copyBtn and copyBtn.Parent then
						copyBtn.Text = "Copy"
					end
				end)
			end)

			runBtn.MouseButton1Click:Connect(function()
				runScriptCodeSafe(rawScript)
			end)
		end

		local function performScriptBloxSearch()
			local query = string.match(searchBox.Text or "", "^%s*(.-)%s*$") or ""
			clearResults()
			statusLabel.Text = "Mencari di ScriptBlox (max 30)..."

			task.spawn(function()
				local endpoint = "https://scriptblox.com/api/script/fetch?page=1&max=" .. tostring(MAX_SCRIPTBLOX_RESULTS)
				if query ~= "" then
					endpoint = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query) .. "&page=1&max=" .. tostring(MAX_SCRIPTBLOX_RESULTS)
				end

				local ok, response = pcall(function()
					return game:HttpGet(endpoint)
				end)

				if not ok or not response then
					statusLabel.Text = "HTTP gagal / disekat executor"
					return
				end

				local decodeOk, data = pcall(function()
					return HttpService:JSONDecode(response)
				end)

				if not decodeOk or type(data) ~= "table" or not data.result or type(data.result.scripts) ~= "table" then
					statusLabel.Text = "Tiada hasil dijumpai"
					return
				end

				local listScripts = data.result.scripts
				if #listScripts == 0 then
					statusLabel.Text = "Tiada script untuk '" .. query .. "'"
					return
				end

				local totalShown = math.min(#listScripts, MAX_SCRIPTBLOX_RESULTS)
				statusLabel.Text = "Dijumpai: " .. tostring(totalShown) .. " / 30 script"

				for i = 1, totalShown do
					addScriptBloxCard(listScripts[i])
				end
			end)
		end

		starShortcutBtn.MouseButton1Click:Connect(function()
			local nextVis = not quickPresetBar.Visible
			quickPresetBar.Visible = nextVis
			starShortcutBtn.BackgroundColor3 = nextVis and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(217, 119, 6)
			topOffset = nextVis and 70 or 46
			if tabs[tabName] and tabs[tabName].listContainer then
				tabs[tabName].listContainer.Size = UDim2.new(1, 0, 1, -topOffset)
				tabs[tabName].listContainer.Position = UDim2.new(0, 0, 0, topOffset)
			end
		end)

		searchBtn.MouseButton1Click:Connect(performScriptBloxSearch)
		searchBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				performScriptBloxSearch()
			end
		end)
	end

	local scrollList = Instance.new("ScrollingFrame")
	scrollList.Size = UDim2.new(1, 0, 1, -topOffset)
	scrollList.Position = UDim2.new(0, 0, 0, topOffset)
	scrollList.BackgroundTransparency = 1
	scrollList.BorderSizePixel = 0
	scrollList.ScrollBarThickness = 3
	scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollList.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scrollList

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.Parent = scrollList

	tabs[tabName] = {
		button = tabBtn,
		page = page,
		listContainer = scrollList,
	}

	tabBtn.MouseButton1Click:Connect(function()
		selectTab(tabName)
	end)

	if not activeTabName then
		selectTab(tabName)
	end

	return tabs[tabName]
end

-- ==========================================
-- TAB 1: TELEPORT
-- ==========================================
createTab("Teleport", "teleport")
addTeleportButton("Teleport", "Spawn (0, 10, 0)", CFrame.new(0, 10, 0))

-- ==========================================
-- TAB 2: UNIVERSAL
-- ==========================================
createTab("Universal", "normal")

local speedControl = addCustomNumberControl("Universal", "Speed", 28, true, function(enabled, val)
	local _, hum = getHumanoidAndRoot()
	if hum then
		pcall(function()
			hum.WalkSpeed = enabled and val or 16
		end)
	end
end)

local flyBv = nil
local flyControl = nil

local function cleanupFlyObjects()
	if flyBv then
		pcall(function() flyBv:Destroy() end)
		flyBv = nil
	end
	local char = player.Character
	if char then
		for _, obj in ipairs(char:GetDescendants()) do
			if obj.Name == "HubFlyVelocity" then
				pcall(function() obj:Destroy() end)
			end
		end
	end
end

local function stopFly()
	cleanupFlyObjects()
	local _, hum = getHumanoidAndRoot()
	if hum then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end
end

local function ensureFlyVelocity(hrp)
	if not flyBv or flyBv.Parent ~= hrp then
		cleanupFlyObjects()
		local bv = Instance.new("BodyVelocity")
		bv.Name = "HubFlyVelocity"
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.P = 1250
		bv.Velocity = Vector3.zero
		bv.Parent = hrp
		flyBv = bv
	end
end

local function getFlyDirection(hum, cam)
	local moveDir = Vector3.zero

	local forward = 0
	local right = 0
	local focusedBox = nil
	pcall(function()
		focusedBox = UserInputService:GetFocusedTextBox()
	end)

	if not focusedBox then
		if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
			forward += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
			forward -= 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
			right += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
			right -= 1
		end
	end

	if forward ~= 0 or right ~= 0 then
		local camLook = cam.CFrame.LookVector
		local camRight = cam.CFrame.RightVector
		moveDir = (camLook * forward) + (camRight * right)
	elseif hum and hum.MoveDirection.Magnitude > 0.05 then
		local camLook = cam.CFrame.LookVector
		local horizLook = Vector3.new(camLook.X, 0, camLook.Z)
		if horizLook.Magnitude > 0.01 then
			horizLook = horizLook.Unit
			local horizRight = Vector3.new(-horizLook.Z, 0, horizLook.X)
			local relForward = hum.MoveDirection:Dot(horizLook)
			local relRight = hum.MoveDirection:Dot(horizRight)
			moveDir = (camLook * relForward) + (cam.CFrame.RightVector * relRight)
		else
			moveDir = hum.MoveDirection
		end
	end

	local vertical = 0
	if not focusedBox then
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
			vertical += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			vertical -= 1
		end
	end

	local finalDir = moveDir + Vector3.new(0, vertical, 0)
	if finalDir.Magnitude > 0 then
		finalDir = finalDir.Unit
	end

	return finalDir
end

flyControl = addCustomNumberControl("Universal", "Fly", 50, true, function(enabled)
	if enabled then
		local _, hum, hrp = getHumanoidAndRoot()
		if hum and hrp then
			ensureFlyVelocity(hrp)
		end
	else
		stopFly()
	end
end)

local jumpControl = addCustomNumberControl("Universal", "Jump", 75, true, function(enabled, val)
	local _, hum = getHumanoidAndRoot()
	if hum then
		pcall(function()
			hum.UseJumpPower = true
			hum.JumpPower = enabled and val or 50
		end)
	end
end)

local infJumpEnabled = false
local noclipEnabled = false
local antiAfkEnabled = false
local shiftLockEnabled = false
local SHIFT_LOCK_OFFSET = Vector3.new(1.75, 0, 0)

local function applyShiftLockState(enabled, hum)
	if not hum then return end
	pcall(function()
		hum.AutoRotate = not enabled
		if not enabled then
			hum.CameraOffset = Vector3.zero
		end
	end)
end

addToggleButton("Universal", "Inf Jump", false, function(enabled)
	infJumpEnabled = enabled
end)

addToggleButton("Universal", "Shift Lock", false, function(enabled)
	shiftLockEnabled = enabled
	local _, hum = getHumanoidAndRoot()
	applyShiftLockState(enabled, hum)
end, true)

addToggleButton("Universal", "Noclip", false, function(enabled)
	noclipEnabled = enabled
	if not enabled and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				pcall(function() part.CanCollide = true end)
			end
		end
	end
end)

addToggleButton("Universal", "Anti-AFK", false, function(enabled)
	antiAfkEnabled = enabled
end)

-- ==========================================
-- TAB 3: SCRIPTBLOX (LIMIT 30 SCRIPT + ★ SHORTCUT)
-- ==========================================
createTab("ScriptBlox", "scriptblox")

UserInputService.JumpRequest:Connect(function()
	if not infJumpEnabled then return end
	local _, hum, hrp = getHumanoidAndRoot()
	if hum and hrp then
		pcall(function()
			if jumpControl and jumpControl.isEnabled() then
				hum.UseJumpPower = true
				hum.JumpPower = jumpControl.getValue()
			end
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	end
end)

player.CharacterAdded:Connect(function()
	cleanupFlyObjects()
	local _, hum = getHumanoidAndRoot()
	if hum then
		applyShiftLockState(shiftLockEnabled, hum)
	end
end)

RunService.RenderStepped:Connect(function(dt)
	pcall(function()
		local _, hum, hrp = getHumanoidAndRoot()
		local cam = workspace.CurrentCamera
		local alpha = math.clamp((dt or 0.016) * 18, 0, 1)

		if hum and hrp and cam then
			if shiftLockEnabled then
				if hum.AutoRotate then
					hum.AutoRotate = false
				end
				hum.CameraOffset = hum.CameraOffset:Lerp(SHIFT_LOCK_OFFSET, alpha)

				local look = cam.CFrame.LookVector
				local flatLook = Vector3.new(look.X, 0, look.Z)
				if flatLook.Magnitude > 0.001 then
					local currentPos = hrp.Position
					local targetLookCF = CFrame.lookAt(currentPos, currentPos + flatLook.Unit)
					local targetRot = CFrame.new(currentPos) * targetLookCF.Rotation
					hrp.CFrame = hrp.CFrame:Lerp(targetRot, math.clamp((dt or 0.016) * 24, 0, 1))
				end
			elseif hum.CameraOffset.Magnitude > 0.001 then
				hum.CameraOffset = hum.CameraOffset:Lerp(Vector3.zero, alpha)
				if hum.CameraOffset.Magnitude <= 0.02 then
					hum.CameraOffset = Vector3.zero
				end
			end
		end

		if flyControl and flyControl.isEnabled() then
			if hrp and hum and cam then
				ensureFlyVelocity(hrp)
				local dir = getFlyDirection(hum, cam)
				local spd = flyControl.getValue()
				if flyBv then
					flyBv.Velocity = dir * spd
				end
			end
		else
			if flyBv then
				stopFly()
			end
		end
	end)
end)

RunService.Stepped:Connect(function()
	pcall(function()
		local char, hum = getHumanoidAndRoot()
		if hum then
			if speedControl.isEnabled() then
				local targetSpd = speedControl.getValue()
				if hum.WalkSpeed ~= targetSpd then
					hum.WalkSpeed = targetSpd
				end
			end
			if jumpControl and jumpControl.isEnabled() then
				local targetJump = jumpControl.getValue()
				if not hum.UseJumpPower then
					hum.UseJumpPower = true
				end
				if hum.JumpPower ~= targetJump then
					hum.JumpPower = targetJump
				end
			end
		end

		if noclipEnabled and char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end)

player.Idled:Connect(function()
	if antiAfkEnabled then
		pcall(function()
			local vu = game:GetService("VirtualUser")
			if vu and vu.CaptureController and vu.ClickButton2 then
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end
		end)
	end
end)
