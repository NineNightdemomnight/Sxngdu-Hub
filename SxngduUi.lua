--[[
	Sxngdu UI Library v3
	Modern Glass + Cyberpunk Cyan
	+ Topmost GUI + Custom Drag + Mouse Unlock + Mobile
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LOGO_ID  = "rbxassetid://116342011761764"
local CLOSE_ID = "rbxassetid://76173586881356"
local HAS_TOUCH = UserInputService.TouchEnabled

-- ==================== Theme ====================
local Theme = {
	Bg          = Color3.fromRGB(9, 12, 20),
	BgPanel     = Color3.fromRGB(14, 18, 30),
	BgCard      = Color3.fromRGB(18, 24, 40),
	BgHover     = Color3.fromRGB(28, 38, 62),
	Sidebar     = Color3.fromRGB(11, 15, 26),
	Accent      = Color3.fromRGB(0, 210, 255),
	AccentDim   = Color3.fromRGB(0, 130, 190),
	AccentGlow  = Color3.fromRGB(100, 230, 255),
	AccentSoft  = Color3.fromRGB(0, 90, 140),
	Text        = Color3.fromRGB(240, 246, 255),
	TextDim     = Color3.fromRGB(120, 145, 175),
	Stroke      = Color3.fromRGB(40, 70, 110),
	ToggleOn    = Color3.fromRGB(0, 200, 255),
	ToggleOff   = Color3.fromRGB(32, 40, 58),
	Green       = Color3.fromRGB(50, 230, 160),
	Red         = Color3.fromRGB(255, 75, 100),
	Slider      = Color3.fromRGB(0, 200, 255),
	Glass       = Color3.fromRGB(16, 22, 38),
}

local function tween(obj, props, t, style)
	TweenService:Create(
		obj,
		TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		props
	):Play()
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.45
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = parent
	return c
end

local function addPadding(parent, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.Parent = parent
	return p
end

local function addGradient(parent, c1, c2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2),
	})
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

local function makeLabel(parent, text, size, pos, color, font, textSize, align)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = pos or UDim2.new(0, 0, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or Theme.Text
	l.Font = font or Enum.Font.Gotham
	l.TextSize = textSize or 12
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	return l
end

local function parentGui(gui)
	local ok = false
	pcall(function()
		if gethui then
			gui.Parent = gethui()
			ok = true
		end
	end)
	if not ok then
		pcall(function()
			if syn and syn.protect_gui then syn.protect_gui(gui)
			elseif protect_gui then protect_gui(gui) end
			gui.Parent = game:GetService("CoreGui")
			ok = true
		end)
	end
	if not ok then
		gui.Parent = PlayerGui
	end
end

-- ==================== Library ====================
local Library = {}
Library.__index = Library

function Library.new(config)
	local self = setmetatable({}, Library)
	self.Name = config.Name or "Sxngdu Hub"
	self.Tabs = {}
	self.CurrentTab = nil
	self.Minimized = false
	self.MouseUnlocked = true
	self.Width = config.Width or 780
	self.Height = config.Height or 500
	self.MinWidth = config.MinWidth or 560
	self.MinHeight = config.MinHeight or 360
	self.MaxWidth = config.MaxWidth or 1200
	self.MaxHeight = config.MaxHeight or 820

	-- ScreenGui (topmost)
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "SxngduLib_" .. tostring(math.random(10000, 99999))
	self.Gui.ResetOnSpawn = false
	self.Gui.IgnoreGuiInset = true
	self.Gui.DisplayOrder = 2147483647
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui.Enabled = true
	parentGui(self.Gui)

	-- Main window
	self.Window = Instance.new("Frame")
	self.Window.Size = UDim2.new(0, self.Width, 0, self.Height)
	self.Window.Position = UDim2.new(0.5, -self.Width / 2, 0.5, -self.Height / 2)
	self.Window.BackgroundColor3 = Theme.Bg
	self.Window.BorderSizePixel = 0
	self.Window.Active = true
	self.Window.Draggable = false -- custom drag only
	self.Window.ClipsDescendants = true
	self.Window.ZIndex = 10
	self.Window.Parent = self.Gui
	addCorner(self.Window, 18)
	local winStroke = addStroke(self.Window, Theme.Accent, 1.4, 0.35)

	-- soft outer glow line
	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 0, 0, 3)
	glow.BackgroundColor3 = Theme.Accent
	glow.BorderSizePixel = 0
	glow.ZIndex = 20
	glow.Parent = self.Window
	addGradient(glow,
		Color3.fromRGB(0, 60, 120),
		Theme.Accent,
		0
	)
	local glow2 = Instance.new("UIGradient")
	glow2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 100)),
		ColorSequenceKeypoint.new(0.5, Theme.AccentGlow),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 100)),
	})
	glow2.Parent = glow

	-- ========== SIDEBAR ==========
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 210, 1, -3)
	sidebar.Position = UDim2.new(0, 0, 0, 3)
	sidebar.BackgroundColor3 = Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = self.Window

	local sideLine = Instance.new("Frame")
	sideLine.Size = UDim2.new(0, 1, 1, 0)
	sideLine.Position = UDim2.new(1, -1, 0, 0)
	sideLine.BackgroundColor3 = Theme.Stroke
	sideLine.BackgroundTransparency = 0.55
	sideLine.BorderSizePixel = 0
	sideLine.Parent = sidebar

	-- brand
	local brand = Instance.new("Frame")
	brand.Size = UDim2.new(1, -20, 0, 42)
	brand.Position = UDim2.new(0, 10, 0, 14)
	brand.BackgroundTransparency = 1
	brand.Parent = sidebar

	local brandLogo = Instance.new("ImageLabel")
	brandLogo.Size = UDim2.new(0, 32, 0, 32)
	brandLogo.Position = UDim2.new(0, 0, 0.5, -16)
	brandLogo.BackgroundTransparency = 1
	brandLogo.Image = LOGO_ID
	brandLogo.ScaleType = Enum.ScaleType.Fit
	brandLogo.Parent = brand

	makeLabel(brand, "SXNGDU", UDim2.new(1, -40, 0, 18), UDim2.new(0, 40, 0, 4), Theme.Accent, Enum.Font.GothamBold, 14)
	makeLabel(brand, "HUB  ·  v3", UDim2.new(1, -40, 0, 14), UDim2.new(0, 40, 0, 22), Theme.TextDim, Enum.Font.Gotham, 10)

	-- avatar card
	local avatarCard = Instance.new("Frame")
	avatarCard.Size = UDim2.new(1, -20, 0, 88)
	avatarCard.Position = UDim2.new(0, 10, 0, 64)
	avatarCard.BackgroundColor3 = Theme.BgCard
	avatarCard.BorderSizePixel = 0
	avatarCard.Parent = sidebar
	addCorner(avatarCard, 14)
	addStroke(avatarCard, Theme.Stroke, 1, 0.55)

	local avatarFrame = Instance.new("Frame")
	avatarFrame.Size = UDim2.new(0, 52, 0, 52)
	avatarFrame.Position = UDim2.new(0, 12, 0.5, -26)
	avatarFrame.BackgroundColor3 = Theme.BgPanel
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = avatarCard
	addCorner(avatarFrame, 26)
	addStroke(avatarFrame, Theme.Accent, 1.5, 0.25)

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(1, -4, 1, -4)
	avatar.Position = UDim2.new(0, 2, 0, 2)
	avatar.BackgroundTransparency = 1
	pcall(function()
		avatar.Image = Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)
	avatar.Parent = avatarFrame
	addCorner(avatar, 24)

	local online = Instance.new("Frame")
	online.Size = UDim2.new(0, 11, 0, 11)
	online.Position = UDim2.new(1, -12, 1, -12)
	online.BackgroundColor3 = Theme.Green
	online.BorderSizePixel = 0
	online.Parent = avatarFrame
	addCorner(online, 6)
	addStroke(online, Theme.BgCard, 2, 0)

	makeLabel(avatarCard, LocalPlayer.DisplayName, UDim2.new(1, -78, 0, 18), UDim2.new(0, 72, 0, 24), Theme.Text, Enum.Font.GothamBold, 13)
	makeLabel(avatarCard, "@" .. LocalPlayer.Name, UDim2.new(1, -78, 0, 14), UDim2.new(0, 72, 0, 46), Theme.TextDim, Enum.Font.Gotham, 11)

	-- info rows
	local function infoRow(y, label, value)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -20, 0, 20)
		row.Position = UDim2.new(0, 10, 0, y)
		row.BackgroundTransparency = 1
		row.Parent = sidebar
		makeLabel(row, label, UDim2.new(0.42, 0, 1, 0), nil, Theme.TextDim, Enum.Font.Gotham, 11)
		return makeLabel(row, value, UDim2.new(0.58, 0, 1, 0), UDim2.new(0.42, 0, 0, 0), Theme.Text, Enum.Font.GothamMedium, 11, Enum.TextXAlignment.Right)
	end

	local executorName = "Unknown"
	pcall(function()
		if identifyexecutor then executorName = identifyexecutor() end
	end)
	infoRow(168, "Executor", string.sub(tostring(executorName), 1, 14))
	infoRow(190, "Device", HAS_TOUCH and "Mobile" or "PC")
	infoRow(212, "Game", (function()
		local ok, name = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
		end)
		return ok and string.sub(name, 1, 12) or tostring(game.PlaceId)
	end)())

	local pingLabel = infoRow(234, "Ping", "- ms")
	local sessionLabel = infoRow(256, "Session", "00:00")
	local sessionStart = os.clock()

	task.spawn(function()
		while self.Gui and self.Gui.Parent do
			local sec = math.floor(os.clock() - sessionStart)
			sessionLabel.Text = string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
			local ping = 0
			pcall(function()
				ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			pingLabel.Text = ping .. " ms"
			pingLabel.TextColor3 = ping < 80 and Theme.Green or (ping < 150 and Theme.Accent or Theme.Red)
			task.wait(1)
		end
	end)

	-- status pill
	local statusFrame = Instance.new("Frame")
	statusFrame.Size = UDim2.new(1, -20, 0, 34)
	statusFrame.Position = UDim2.new(0, 10, 1, -48)
	statusFrame.BackgroundColor3 = Theme.BgCard
	statusFrame.BorderSizePixel = 0
	statusFrame.Parent = sidebar
	addCorner(statusFrame, 10)
	addStroke(statusFrame, Theme.Green, 1, 0.45)

	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.new(0, 7, 0, 7)
	statusDot.Position = UDim2.new(0, 12, 0.5, -3.5)
	statusDot.BackgroundColor3 = Theme.Green
	statusDot.BorderSizePixel = 0
	statusDot.Parent = statusFrame
	addCorner(statusDot, 4)

	makeLabel(statusFrame, "Connected", UDim2.new(1, -28, 1, 0), UDim2.new(0, 26, 0, 0), Theme.Green, Enum.Font.GothamMedium, 12)

	-- pulse online dot
	task.spawn(function()
		while self.Gui and self.Gui.Parent do
			tween(statusDot, {BackgroundTransparency = 0.4}, 0.6)
			task.wait(0.6)
			tween(statusDot, {BackgroundTransparency = 0}, 0.6)
			task.wait(0.6)
		end
	end)

	-- ========== RIGHT ==========
	local right = Instance.new("Frame")
	right.Name = "Right"
	right.Size = UDim2.new(1, -218, 1, -3)
	right.Position = UDim2.new(0, 214, 0, 3)
	right.BackgroundTransparency = 1
	right.Parent = self.Window

	-- title bar (drag zone)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 48)
	titleBar.BackgroundTransparency = 1
	titleBar.Parent = right

	local logoSmall = Instance.new("ImageLabel")
	logoSmall.Size = UDim2.new(0, 24, 0, 24)
	logoSmall.Position = UDim2.new(0, 10, 0.5, -12)
	logoSmall.BackgroundTransparency = 1
	logoSmall.Image = LOGO_ID
	logoSmall.ScaleType = Enum.ScaleType.Fit
	logoSmall.Parent = titleBar

	makeLabel(titleBar, self.Name, UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 42, 0, 0), Theme.Text, Enum.Font.GothamBold, 15)

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 32, 0, 32)
	minBtn.Position = UDim2.new(1, -76, 0.5, -16)
	minBtn.BackgroundColor3 = Theme.BgCard
	minBtn.Text = "–"
	minBtn.TextColor3 = Theme.Accent
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 18
	minBtn.AutoButtonColor = false
	minBtn.Parent = titleBar
	addCorner(minBtn, 10)
	addStroke(minBtn, Theme.Stroke, 1, 0.4)
	minBtn.MouseEnter:Connect(function() tween(minBtn, {BackgroundColor3 = Theme.BgHover}) end)
	minBtn.MouseLeave:Connect(function() tween(minBtn, {BackgroundColor3 = Theme.BgCard}) end)

	local close = Instance.new("ImageButton")
	close.Size = UDim2.new(0, 32, 0, 32)
	close.Position = UDim2.new(1, -38, 0.5, -16)
	close.BackgroundColor3 = Theme.BgCard
	close.Image = CLOSE_ID
	close.ScaleType = Enum.ScaleType.Fit
	close.AutoButtonColor = false
	close.Parent = titleBar
	addCorner(close, 10)
	addStroke(close, Theme.Red, 1, 0.45)
	addPadding(close, 6, 6, 6, 6)
	close.MouseEnter:Connect(function() tween(close, {BackgroundColor3 = Color3.fromRGB(55, 18, 28)}) end)
	close.MouseLeave:Connect(function() tween(close, {BackgroundColor3 = Theme.BgCard}) end)
	close.MouseButton1Click:Connect(function()
		self.Gui.Enabled = false
		self:LockMouse()
	end)

	-- custom window drag (title bar only)
	do
		local dragging, dragStart, startPos = false, nil, nil
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = self.Window.Position
			end
		end)
		titleBar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				local d = input.Position - dragStart
				self.Window.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y
				)
			end
		end)
	end

	-- tab bar
	self.TabBar = Instance.new("ScrollingFrame")
	self.TabBar.Name = "TabBar"
	self.TabBar.Size = UDim2.new(1, -16, 0, 36)
	self.TabBar.Position = UDim2.new(0, 8, 0, 50)
	self.TabBar.BackgroundTransparency = 1
	self.TabBar.BorderSizePixel = 0
	self.TabBar.ScrollBarThickness = 2
	self.TabBar.ScrollBarImageColor3 = Theme.Accent
	self.TabBar.ScrollingDirection = Enum.ScrollingDirection.X
	self.TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.TabBar.Parent = right

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = self.TabBar
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabBar.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 8, 0, 0)
	end)

	self.Content = Instance.new("Frame")
	self.Content.Name = "Content"
	self.Content.Size = UDim2.new(1, -16, 1, -100)
	self.Content.Position = UDim2.new(0, 8, 0, 92)
	self.Content.BackgroundTransparency = 1
	self.Content.Parent = right

	-- resize handles
	local function makeResizeHandle(size, pos, edges)
		local h = Instance.new("TextButton")
		h.Size = size
		h.Position = pos
		h.BackgroundTransparency = 1
		h.Text = ""
		h.ZIndex = 50
		h.Parent = self.Window
		local resizing, startMouse, startSize, startPos = false, nil, nil, nil
		h.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startMouse = UserInputService:GetMouseLocation()
				startSize = self.Window.AbsoluteSize
				startPos = self.Window.AbsolutePosition
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not resizing then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local mouse = UserInputService:GetMouseLocation()
			local dx = mouse.X - startMouse.X
			local dy = mouse.Y - startMouse.Y
			local newW, newH, newX, newY = startSize.X, startSize.Y, startPos.X, startPos.Y
			if edges.Right then newW = math.clamp(startSize.X + dx, self.MinWidth, self.MaxWidth) end
			if edges.Bottom then newH = math.clamp(startSize.Y + dy, self.MinHeight, self.MaxHeight) end
			if edges.Left then
				newW = math.clamp(startSize.X - dx, self.MinWidth, self.MaxWidth)
				newX = startPos.X + (startSize.X - newW)
			end
			if edges.Top then
				newH = math.clamp(startSize.Y - dy, self.MinHeight, self.MaxHeight)
				newY = startPos.Y + (startSize.Y - newH)
			end
			self.Window.Size = UDim2.new(0, newW, 0, newH)
			self.Window.Position = UDim2.new(0, newX, 0, newY)
			self.Width, self.Height = newW, newH
		end)
	end

	makeResizeHandle(UDim2.new(0, 8, 1, -16), UDim2.new(1, -8, 0, 8), {Right = true})
	makeResizeHandle(UDim2.new(1, -16, 0, 8), UDim2.new(0, 8, 1, -8), {Bottom = true})
	makeResizeHandle(UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 1, -14), {Right = true, Bottom = true})
	makeResizeHandle(UDim2.new(0, 8, 1, -16), UDim2.new(0, 0, 0, 8), {Left = true})
	makeResizeHandle(UDim2.new(1, -16, 0, 8), UDim2.new(0, 8, 0, 0), {Top = true})

	local cornerDot = Instance.new("Frame")
	cornerDot.Size = UDim2.new(0, 10, 0, 10)
	cornerDot.Position = UDim2.new(1, -12, 1, -12)
	cornerDot.BackgroundColor3 = Theme.Accent
	cornerDot.BackgroundTransparency = 0.35
	cornerDot.BorderSizePixel = 0
	cornerDot.ZIndex = 51
	cornerDot.Parent = self.Window
	addCorner(cornerDot, 3)

	-- float icon
	self.FloatIcon = Instance.new("ImageButton")
	self.FloatIcon.Size = UDim2.new(0, 58, 0, 58)
	self.FloatIcon.Position = UDim2.new(0, 18, 0.5, -29)
	self.FloatIcon.BackgroundColor3 = Theme.BgPanel
	self.FloatIcon.Image = LOGO_ID
	self.FloatIcon.ScaleType = Enum.ScaleType.Fit
	self.FloatIcon.AutoButtonColor = false
	self.FloatIcon.Visible = false
	self.FloatIcon.ZIndex = 100
	self.FloatIcon.Parent = self.Gui
	addCorner(self.FloatIcon, 16)
	addStroke(self.FloatIcon, Theme.Accent, 1.6, 0.2)
	addPadding(self.FloatIcon, 5, 5, 5, 5)

	local fDragging, fStart, fPos, fMoved = false, nil, nil, false
	self.FloatIcon.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			fDragging = true
			fMoved = false
			fStart = input.Position
			fPos = self.FloatIcon.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if fDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - fStart
			if delta.Magnitude > 4 then fMoved = true end
			self.FloatIcon.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if fDragging and not fMoved then self:Restore() end
			fDragging = false
		end
	end)
	self.FloatIcon.MouseEnter:Connect(function()
		tween(self.FloatIcon, {Size = UDim2.new(0, 64, 0, 64)}, 0.15)
	end)
	self.FloatIcon.MouseLeave:Connect(function()
		tween(self.FloatIcon, {Size = UDim2.new(0, 58, 0, 58)}, 0.15)
	end)

	-- mouse helpers
	function self:UnlockMouse()
		self.MouseUnlocked = true
		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	end
	function self:LockMouse()
		self.MouseUnlocked = false
		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end)
	end

	function self:Minimize()
		self.Minimized = true
		self.Window.Visible = false
		self.FloatIcon.Visible = true
		self:LockMouse()
	end
	function self:Restore()
		self.Minimized = false
		self.FloatIcon.Visible = false
		self.Window.Visible = true
		self.Gui.Enabled = true
		self:UnlockMouse()
	end

	minBtn.MouseButton1Click:Connect(function() self:Minimize() end)

	-- keep mouse free while UI open
	self._mouseConn = RunService.RenderStepped:Connect(function()
		if not self.Gui or not self.Gui.Parent then return end
		if self.Gui.Enabled and self.Window.Visible and not self.Minimized then
			pcall(function()
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			if self.MouseUnlocked then self:LockMouse() else self:UnlockMouse() end
			return
		end
		if gp then return end
		if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			if self.Minimized then
				self:Restore()
			elseif self.Window.Visible then
				self:Minimize()
			else
				self.Gui.Enabled = true
				self:Restore()
			end
		end
	end)

	self:UnlockMouse()

	-- Home + Credits
	local homeTab = self:CreateTab("Home")
	local creditsTab = self:CreateTab("Credits")

	local homeCard = Instance.new("Frame")
	homeCard.Size = UDim2.new(1, -4, 0, 118)
	homeCard.BackgroundColor3 = Theme.BgCard
	homeCard.BorderSizePixel = 0
	homeCard.Parent = homeTab.Frame
	addCorner(homeCard, 14)
	addStroke(homeCard, Theme.Accent, 1.1, 0.4)
	addGradient(homeCard, Theme.BgCard, Color3.fromRGB(12, 28, 48), 45)

	local homeLogo = Instance.new("ImageLabel")
	homeLogo.Size = UDim2.new(0, 52, 0, 52)
	homeLogo.Position = UDim2.new(0, 18, 0.5, -26)
	homeLogo.BackgroundTransparency = 1
	homeLogo.Image = LOGO_ID
	homeLogo.ScaleType = Enum.ScaleType.Fit
	homeLogo.Parent = homeCard

	makeLabel(homeCard, "SXNGDU HUB", UDim2.new(1, -90, 0, 24), UDim2.new(0, 82, 0, 28), Theme.Accent, Enum.Font.GothamBold, 18)
	makeLabel(homeCard, "Modern loader  ·  Scripts ready", UDim2.new(1, -90, 0, 18), UDim2.new(0, 82, 0, 56), Theme.TextDim, Enum.Font.Gotham, 12)

	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 64, 0, 22)
	badge.Position = UDim2.new(1, -78, 0, 14)
	badge.BackgroundColor3 = Color3.fromRGB(20, 50, 40)
	badge.BorderSizePixel = 0
	badge.Parent = homeCard
	addCorner(badge, 8)
	addStroke(badge, Theme.Green, 1, 0.4)
	makeLabel(badge, "ACTIVE", UDim2.new(1, 0, 1, 0), nil, Theme.Green, Enum.Font.GothamBold, 11, Enum.TextXAlignment.Center)

	self:CreateLabel(homeTab, "")
	self:CreateLabel(homeTab, "QUICK ACTIONS")
	self:CreateButton(homeTab, "  เริ่มใช้งาน", function()
		self:Notify("Sxngdu", "พร้อมใช้งานแล้ว", 2)
	end)
	self:CreateButton(homeTab, "  คัดลอก HWID", function()
		local hwid = "N/A"
		pcall(function() if gethwid then hwid = gethwid() end end)
		if setclipboard then setclipboard(tostring(hwid)) end
		self:Notify("HWID", "คัดลอกแล้ว", 2)
	end)

	self:CreateLabel(creditsTab, "DEVELOPER")
	local credCard = Instance.new("Frame")
	credCard.Size = UDim2.new(1, -4, 0, 92)
	credCard.BackgroundColor3 = Theme.BgCard
	credCard.BorderSizePixel = 0
	credCard.Parent = creditsTab.Frame
	addCorner(credCard, 14)
	addStroke(credCard, Theme.Accent, 1, 0.5)

	local credLogo = Instance.new("ImageLabel")
	credLogo.Size = UDim2.new(0, 48, 0, 48)
	credLogo.Position = UDim2.new(0, 16, 0.5, -24)
	credLogo.BackgroundTransparency = 1
	credLogo.Image = LOGO_ID
	credLogo.ScaleType = Enum.ScaleType.Fit
	credLogo.Parent = credCard

	makeLabel(credCard, "sxngdu", UDim2.new(1, -80, 0, 22), UDim2.new(0, 76, 0, 24), Theme.Text, Enum.Font.GothamBold, 16)
	makeLabel(credCard, "Main Developer  ·  UI & Scripts", UDim2.new(1, -80, 0, 18), UDim2.new(0, 76, 0, 48), Theme.TextDim, Enum.Font.Gotham, 12)

	self:CreateLabel(creditsTab, "")
	self:CreateLabel(creditsTab, "ABOUT")
	self:CreateLabel(creditsTab, "Sxngdu Hub — Glass Cyan Edition")
	self:CreateLabel(creditsTab, "RightShift toggle  ·  LeftAlt mouse unlock")
	self:CreateButton(creditsTab, "  Discord (soon)", function()
		self:Notify("Discord", "กำลังเปิดเร็ว ๆ นี้", 2)
	end)

	return self
end

function Library:CreateTab(name)
	local tab = { Name = name, Frame = Instance.new("ScrollingFrame") }
	tab.Frame.Size = UDim2.new(1, 0, 1, 0)
	tab.Frame.BackgroundTransparency = 1
	tab.Frame.ScrollBarThickness = 3
	tab.Frame.ScrollBarImageColor3 = Theme.Accent
	tab.Frame.BorderSizePixel = 0
	tab.Frame.Visible = false
	tab.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tab.Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tab.Frame.Parent = self.Content
	addPadding(tab.Frame, 4, 8, 2, 6)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = tab.Frame
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tab.Frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
	end)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 0, 0, 30)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = Theme.BgCard
	btn.Text = "  " .. name .. "  "
	btn.TextColor3 = Theme.TextDim
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = self.TabBar
	addCorner(btn, 9)
	local btnStroke = addStroke(btn, Theme.Stroke, 1, 0.65)

	btn.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then tween(btn, {BackgroundColor3 = Theme.BgHover}) end
	end)
	btn.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then tween(btn, {BackgroundColor3 = Theme.BgCard}) end
	end)
	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.Tabs) do
			t.Frame.Visible = false
			tween(t.Btn, {BackgroundColor3 = Theme.BgCard, TextColor3 = Theme.TextDim})
			if t.Stroke then t.Stroke.Transparency = 0.65 end
		end
		tab.Frame.Visible = true
		tween(btn, {BackgroundColor3 = Theme.AccentDim, TextColor3 = Theme.Text})
		btnStroke.Color = Theme.Accent
		btnStroke.Transparency = 0.15
		self.CurrentTab = tab
	end)

	tab.Btn = btn
	tab.Stroke = btnStroke
	self.Tabs[name] = tab

	if not self.CurrentTab then
		tab.Frame.Visible = true
		btn.BackgroundColor3 = Theme.AccentDim
		btn.TextColor3 = Theme.Text
		btnStroke.Color = Theme.Accent
		btnStroke.Transparency = 0.15
		self.CurrentTab = tab
	end
	return tab
end

function Library:CreateToggle(tab, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 40)
	frame.BackgroundColor3 = Theme.BgCard
	frame.BorderSizePixel = 0
	frame.Parent = tab.Frame
	addCorner(frame, 11)
	addStroke(frame, Theme.Stroke, 1, 0.7)

	makeLabel(frame, text, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 14, 0, 0), Theme.Text, Enum.Font.Gotham, 13)

	local state = default == true
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 48, 0, 26)
	sw.Position = UDim2.new(1, -60, 0.5, -13)
	sw.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
	sw.Text = ""
	sw.AutoButtonColor = false
	sw.Parent = frame
	addCorner(sw, 13)
	local swStroke = addStroke(sw, state and Theme.AccentGlow or Theme.Stroke, 1, state and 0.2 or 0.55)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 20, 0, 20)
	circle.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = sw
	addCorner(circle, 10)

	sw.MouseButton1Click:Connect(function()
		state = not state
		tween(sw, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
		tween(circle, {Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)})
		swStroke.Color = state and Theme.AccentGlow or Theme.Stroke
		swStroke.Transparency = state and 0.2 or 0.55
		if callback then callback(state) end
	end)

	return {
		Get = function() return state end,
		Set = function(v)
			state = v == true
			sw.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
			circle.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
			swStroke.Color = state and Theme.AccentGlow or Theme.Stroke
			swStroke.Transparency = state and 0.2 or 0.55
		end,
	}
end

function Library:CreateButton(tab, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 38)
	btn.BackgroundColor3 = Theme.AccentDim
	btn.Text = text
	btn.TextColor3 = Theme.Text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = tab.Frame
	addCorner(btn, 11)
	local st = addStroke(btn, Theme.Accent, 1.1, 0.35)

	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = Theme.Accent})
		st.Transparency = 0.1
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = Theme.AccentDim})
		st.Transparency = 0.35
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
	return btn
end

function Library:CreateLabel(tab, text)
	return makeLabel(tab.Frame, text, UDim2.new(1, -4, 0, 18), nil, Theme.TextDim, Enum.Font.GothamMedium, 11)
end

function Library:CreateSlider(tab, text, minV, maxV, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 56)
	frame.BackgroundColor3 = Theme.BgCard
	frame.BorderSizePixel = 0
	frame.Parent = tab.Frame
	addCorner(frame, 11)
	addStroke(frame, Theme.Stroke, 1, 0.7)

	local value = default or minV
	local lbl = makeLabel(frame, text .. "  ·  " .. value, UDim2.new(1, -16, 0, 20), UDim2.new(0, 14, 0, 8), Theme.Text, Enum.Font.Gotham, 12)

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -28, 0, 7)
	bg.Position = UDim2.new(0, 14, 0, 36)
	bg.BackgroundColor3 = Theme.ToggleOff
	bg.BorderSizePixel = 0
	bg.Parent = frame
	addCorner(bg, 4)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((value - minV) / math.max(maxV - minV, 1), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Slider
	fill.BorderSizePixel = 0
	fill.Parent = bg
	addCorner(fill, 4)
	addGradient(fill, Theme.AccentDim, Theme.AccentGlow, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new((value - minV) / math.max(maxV - minV, 1), -8, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.ZIndex = 2
	knob.Parent = bg
	addCorner(knob, 8)
	addStroke(knob, Theme.Accent, 1.5, 0.15)

	local drag = false
	local function update(rel)
		rel = math.clamp(rel, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -8, 0.5, -8)
		value = math.floor(minV + rel * (maxV - minV) + 0.5)
		lbl.Text = text .. "  ·  " .. value
		if callback then callback(value) end
	end

	knob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
		end
	end)
	bg.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			update((i.Position.X - bg.AbsolutePosition.X) / math.max(bg.AbsoluteSize.X, 1))
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not drag then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			update((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / math.max(bg.AbsoluteSize.X, 1))
		end
	end)

	return {
		Get = function() return value end,
		Set = function(v)
			value = math.clamp(v, minV, maxV)
			local rel = (value - minV) / math.max(maxV - minV, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -8, 0.5, -8)
			lbl.Text = text .. "  ·  " .. value
		end,
	}
end

function Library:Notify(title, text, duration)
	duration = duration or 3
	local n = Instance.new("Frame")
	n.Size = UDim2.new(0, 280, 0, 64)
	n.Position = UDim2.new(1, -300, 1, 30)
	n.BackgroundColor3 = Theme.BgPanel
	n.BorderSizePixel = 0
	n.ZIndex = 200
	n.Parent = self.Gui
	addCorner(n, 12)
	addStroke(n, Theme.Accent, 1.2, 0.25)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, -14)
	bar.Position = UDim2.new(0, 8, 0, 7)
	bar.BackgroundColor3 = Theme.Accent
	bar.BorderSizePixel = 0
	bar.Parent = n
	addCorner(bar, 2)

	makeLabel(n, title, UDim2.new(1, -28, 0, 20), UDim2.new(0, 18, 0, 10), Theme.Accent, Enum.Font.GothamBold, 13)
	makeLabel(n, text, UDim2.new(1, -28, 0, 20), UDim2.new(0, 18, 0, 32), Theme.Text, Enum.Font.Gotham, 12)

	tween(n, {Position = UDim2.new(1, -300, 1, -86)}, 0.35)
	task.delay(duration, function()
		tween(n, {Position = UDim2.new(1, -300, 1, 30)}, 0.28)
		task.wait(0.3)
		n:Destroy()
	end)
end

return Library
