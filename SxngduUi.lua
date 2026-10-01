--[[
	Sxngdu UI Library
	Dashboard Style + Cyberpunk Blue
	+ Scrollable Tabs + Edge Resize + Mobile Support
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LOGO_ID  = "rbxassetid://116342011761764"
local CLOSE_ID = "rbxassetid://76173586881356"

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	or (UserInputService.TouchEnabled and UserInputService.GyroscopeEnabled)

-- ถ้ามีทั้งทัชและคีย์บอร์ด (แท็บเล็ต/โน้ตบุ๊ก) ถือว่า hybrid
local HAS_TOUCH = UserInputService.TouchEnabled

local Theme = {
	Bg          = Color3.fromRGB(8, 12, 22),
	BgPanel     = Color3.fromRGB(12, 18, 32),
	BgCard      = Color3.fromRGB(16, 24, 42),
	BgHover     = Color3.fromRGB(22, 34, 58),
	Sidebar     = Color3.fromRGB(10, 16, 28),
	Accent      = Color3.fromRGB(0, 180, 255),
	AccentDim   = Color3.fromRGB(0, 110, 170),
	AccentGlow  = Color3.fromRGB(80, 210, 255),
	Text        = Color3.fromRGB(235, 242, 255),
	TextDim     = Color3.fromRGB(130, 150, 180),
	Stroke      = Color3.fromRGB(0, 140, 200),
	ToggleOn    = Color3.fromRGB(0, 190, 255),
	ToggleOff   = Color3.fromRGB(35, 45, 65),
	Green       = Color3.fromRGB(60, 220, 140),
	Slider      = Color3.fromRGB(0, 180, 255),
}

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function addStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.5
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
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
	l.Parent = parent
	return l
end

local function isPrimaryInput(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMoveInput(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function getCamSize()
	local cam = workspace.CurrentCamera
	if cam then return cam.ViewportSize end
	return Vector2.new(1280, 720)
end

local function clampWindowSize(w, h, minW, minH, maxW, maxH)
	local vp = getCamSize()
	local margin = HAS_TOUCH and 16 or 40
	maxW = math.min(maxW, math.max(minW, vp.X - margin))
	maxH = math.min(maxH, math.max(minH, vp.Y - margin))
	w = math.clamp(w, minW, maxW)
	h = math.clamp(h, minH, maxH)
	return w, h, maxW, maxH
end

local Library = {}
Library.__index = Library

function Library.new(config)
	local self = setmetatable({}, Library)
	self.Name = config.Name or "Sxngdu Hub"
	self.Tabs = {}
	self.CurrentTab = nil
	self.Minimized = false

	local vp = getCamSize()
	local defaultW = config.Width or 760
	local defaultH = config.Height or 480

	-- มือถือ: ใช้เกือบเต็มจอ
	if HAS_TOUCH and vp.X < 900 then
		defaultW = math.floor(vp.X * 0.96)
		defaultH = math.floor(vp.Y * 0.78)
	end

	self.MinWidth = config.MinWidth or (HAS_TOUCH and 280 or 560)
	self.MinHeight = config.MinHeight or (HAS_TOUCH and 220 or 360)
	self.MaxWidth = config.MaxWidth or 1200
	self.MaxHeight = config.MaxHeight or 800

	self.Width, self.Height, self.MaxWidth, self.MaxHeight =
		clampWindowSize(defaultW, defaultH, self.MinWidth, self.MinHeight, self.MaxWidth, self.MaxHeight)

	local sidebarW = (HAS_TOUCH and vp.X < 700) and 0 or 200 -- มือถือจอแคบซ่อน sidebar
	self._SidebarWidth = sidebarW
	self._Compact = sidebarW == 0

	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "SxngduLib_" .. tostring(math.random(10000, 99999))
	self.Gui.ResetOnSpawn = false
	self.Gui.IgnoreGuiInset = true
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui.DisplayOrder = 100
	self.Gui.Parent = PlayerGui

	-- ========== Main Window ==========
	self.Window = Instance.new("Frame")
	self.Window.Size = UDim2.new(0, self.Width, 0, self.Height)
	self.Window.Position = UDim2.new(0.5, -self.Width / 2, 0.5, -self.Height / 2)
	self.Window.BackgroundColor3 = Theme.Bg
	self.Window.BorderSizePixel = 0
	self.Window.Active = true
	self.Window.Draggable = false -- ใช้ custom drag รองรับทัช
	self.Window.ClipsDescendants = true
	self.Window.Parent = self.Gui
	addCorner(self.Window, HAS_TOUCH and 12 or 16)
	addStroke(self.Window, Theme.Accent, 1.2, 0.4)

	local topLine = Instance.new("Frame")
	topLine.Size = UDim2.new(1, 0, 0, 2)
	topLine.BackgroundColor3 = Theme.Accent
	topLine.BorderSizePixel = 0
	topLine.Parent = self.Window
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 140)),
		ColorSequenceKeypoint.new(0.5, Theme.Accent),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 140)),
	})
	g.Parent = topLine

	-- ========== LEFT SIDEBAR (ซ่อนบนจอแคบ) ==========
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, sidebarW, 1, -2)
	sidebar.Position = UDim2.new(0, 0, 0, 2)
	sidebar.BackgroundColor3 = Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Visible = sidebarW > 0
	sidebar.ClipsDescendants = true
	sidebar.Parent = self.Window

	if sidebarW > 0 then
		local userHeader = Instance.new("Frame")
		userHeader.Size = UDim2.new(1, -16, 0, 28)
		userHeader.Position = UDim2.new(0, 8, 0, 12)
		userHeader.BackgroundTransparency = 1
		userHeader.Parent = sidebar
		makeLabel(userHeader, "👤  User Info", UDim2.new(1, 0, 1, 0), nil, Theme.TextDim, Enum.Font.GothamMedium, 12)

		local avatarFrame = Instance.new("Frame")
		avatarFrame.Size = UDim2.new(0, 64, 0, 64)
		avatarFrame.Position = UDim2.new(0.5, -32, 0, 48)
		avatarFrame.BackgroundColor3 = Theme.BgCard
		avatarFrame.BorderSizePixel = 0
		avatarFrame.Parent = sidebar
		addCorner(avatarFrame, 32)
		addStroke(avatarFrame, Theme.Accent, 2, 0.3)

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
		addCorner(avatar, 30)

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 12, 0, 12)
		dot.Position = UDim2.new(1, -14, 1, -14)
		dot.BackgroundColor3 = Theme.Green
		dot.BorderSizePixel = 0
		dot.Parent = avatarFrame
		addCorner(dot, 6)
		addStroke(dot, Theme.Bg, 2, 0)

		makeLabel(sidebar, LocalPlayer.DisplayName, UDim2.new(1, -16, 0, 20), UDim2.new(0, 8, 0, 120), Theme.Text, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Center)
		makeLabel(sidebar, "@" .. LocalPlayer.Name, UDim2.new(1, -16, 0, 16), UDim2.new(0, 8, 0, 140), Theme.TextDim, Enum.Font.Gotham, 11, Enum.TextXAlignment.Center)

		local function infoRow(y, icon, label, value)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -20, 0, 22)
			row.Position = UDim2.new(0, 10, 0, y)
			row.BackgroundTransparency = 1
			row.Parent = sidebar
			makeLabel(row, icon .. "  " .. label, UDim2.new(0.45, 0, 1, 0), nil, Theme.TextDim, Enum.Font.Gotham, 11)
			local v = makeLabel(row, value, UDim2.new(0.55, 0, 1, 0), UDim2.new(0.45, 0, 0, 0), Theme.Text, Enum.Font.GothamMedium, 11, Enum.TextXAlignment.Right)
			return v
		end

		local executorName = "Unknown"
		pcall(function()
			if identifyexecutor then executorName = identifyexecutor() end
		end)
		infoRow(170, "💻", "Executor", string.sub(executorName, 1, 10))
		infoRow(194, "🖥", "Device", HAS_TOUCH and "Mobile" or "PC")
		infoRow(218, "🎮", "Game", (function()
			local ok2, name = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
			end)
			return ok2 and string.sub(name, 1, 12) or tostring(game.PlaceId)
		end)())

		local pingLabel = infoRow(242, "📶", "Ping", "- ms")
		local sessionLabel = infoRow(266, "⏱", "Session", "00:00")
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
				pingLabel.TextColor3 = ping < 80 and Theme.Green or (ping < 150 and Theme.Accent or Color3.fromRGB(255, 100, 100))
				task.wait(1)
			end
		end)

		local statusFrame = Instance.new("Frame")
		statusFrame.Size = UDim2.new(1, -20, 0, 36)
		statusFrame.Position = UDim2.new(0, 10, 1, -50)
		statusFrame.BackgroundColor3 = Theme.BgCard
		statusFrame.BorderSizePixel = 0
		statusFrame.Parent = sidebar
		addCorner(statusFrame, 8)
		addStroke(statusFrame, Theme.Green, 1, 0.5)
		local statusDot = Instance.new("Frame")
		statusDot.Size = UDim2.new(0, 8, 0, 8)
		statusDot.Position = UDim2.new(0, 10, 0.5, -4)
		statusDot.BackgroundColor3 = Theme.Green
		statusDot.BorderSizePixel = 0
		statusDot.Parent = statusFrame
		addCorner(statusDot, 4)
		makeLabel(statusFrame, "Connected to Sxngdu", UDim2.new(1, -28, 1, 0), UDim2.new(0, 24, 0, 0), Theme.Green, Enum.Font.GothamMedium, 11)
	end

	-- ========== RIGHT AREA ==========
	local rightPad = sidebarW > 0 and (sidebarW + 5) or 0
	local right = Instance.new("Frame")
	right.Name = "Right"
	right.Size = UDim2.new(1, -rightPad, 1, -2)
	right.Position = UDim2.new(0, rightPad, 0, 2)
	right.BackgroundTransparency = 1
	right.Parent = self.Window

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, HAS_TOUCH and 48 or 44)
	titleBar.BackgroundTransparency = 1
	titleBar.Active = true
	titleBar.Parent = right

	local logoSmall = Instance.new("ImageLabel")
	logoSmall.Size = UDim2.new(0, 26, 0, 26)
	logoSmall.Position = UDim2.new(0, 8, 0.5, -13)
	logoSmall.BackgroundTransparency = 1
	logoSmall.Image = LOGO_ID
	logoSmall.ScaleType = Enum.ScaleType.Fit
	logoSmall.Parent = titleBar

	makeLabel(
		titleBar,
		self.Name,
		UDim2.new(0.55, 0, 1, 0),
		UDim2.new(0, 40, 0, 0),
		Theme.Text,
		Enum.Font.GothamBold,
		HAS_TOUCH and 14 or 15
	)

	-- Custom window drag (PC + Mobile)
	do
		local dragging = false
		local dragStart, startPos

		titleBar.InputBegan:Connect(function(input)
			if isPrimaryInput(input) then
				dragging = true
				dragStart = input.Position
				startPos = self.Window.Position
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and isMoveInput(input) then
				local delta = input.Position - dragStart
				self.Window.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if isPrimaryInput(input) then
				dragging = false
			end
		end)
	end

	local btnSize = HAS_TOUCH and 36 or 30
	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
	minBtn.Position = UDim2.new(1, -(btnSize * 2 + 12), 0.5, -btnSize / 2)
	minBtn.BackgroundColor3 = Theme.BgCard
	minBtn.Text = "–"
	minBtn.TextColor3 = Theme.Accent
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 18
	minBtn.AutoButtonColor = false
	minBtn.Parent = titleBar
	addCorner(minBtn, 8)
	addStroke(minBtn, Theme.Accent, 1, 0.5)

	local close = Instance.new("ImageButton")
	close.Size = UDim2.new(0, btnSize, 0, btnSize)
	close.Position = UDim2.new(1, -(btnSize + 6), 0.5, -btnSize / 2)
	close.BackgroundColor3 = Theme.BgCard
	close.Image = CLOSE_ID
	close.ScaleType = Enum.ScaleType.Fit
	close.AutoButtonColor = false
	close.Parent = titleBar
	addCorner(close, 8)
	addStroke(close, Color3.fromRGB(255, 80, 100), 1, 0.5)
	addPadding(close, 5, 5, 5, 5)
	close.MouseButton1Click:Connect(function()
		self.Gui.Enabled = false
	end)
	-- มือถือ: ImageButton ใช้ Activated ได้ดี
	close.Activated:Connect(function()
		self.Gui.Enabled = false
	end)

	-- Tab bar
	local tabBarY = HAS_TOUCH and 52 or 48
	self.TabBar = Instance.new("ScrollingFrame")
	self.TabBar.Name = "TabBar"
	self.TabBar.Size = UDim2.new(1, -16, 0, HAS_TOUCH and 38 or 34)
	self.TabBar.Position = UDim2.new(0, 8, 0, tabBarY)
	self.TabBar.BackgroundTransparency = 1
	self.TabBar.BorderSizePixel = 0
	self.TabBar.ScrollBarThickness = HAS_TOUCH and 4 or 2
	self.TabBar.ScrollBarImageColor3 = Theme.Accent
	self.TabBar.ScrollingDirection = Enum.ScrollingDirection.X
	self.TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.TabBar.ScrollingEnabled = true
	self.TabBar.Parent = right

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = self.TabBar
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabBar.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 8, 0, 0)
	end)

	local contentTop = tabBarY + (HAS_TOUCH and 44 or 38)
	self.Content = Instance.new("Frame")
	self.Content.Name = "Content"
	self.Content.Size = UDim2.new(1, -16, 1, -(contentTop + 10))
	self.Content.Position = UDim2.new(0, 8, 0, contentTop)
	self.Content.BackgroundTransparency = 1
	self.Content.Parent = right

	-- ========== Resize Handles (PC + Touch) ==========
	local function makeResizeHandle(size, pos, edges)
		local h = Instance.new("TextButton")
		h.Size = size
		h.Position = pos
		h.BackgroundTransparency = 1
		h.Text = ""
		h.ZIndex = 50
		h.Parent = self.Window

		local resizing = false
		local startInputPos, startSize, startPos

		h.InputBegan:Connect(function(input)
			if isPrimaryInput(input) then
				resizing = true
				startInputPos = input.Position
				startSize = self.Window.AbsoluteSize
				startPos = self.Window.AbsolutePosition
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if isPrimaryInput(input) and resizing then
				resizing = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not resizing or not isMoveInput(input) then return end
			local dx = input.Position.X - startInputPos.X
			local dy = input.Position.Y - startInputPos.Y
			local newW, newH = startSize.X, startSize.Y
			local newX, newY = startPos.X, startPos.Y

			if edges.Right then
				newW = startSize.X + dx
			end
			if edges.Bottom then
				newH = startSize.Y + dy
			end
			if edges.Left then
				newW = startSize.X - dx
				newX = startPos.X + (startSize.X - math.clamp(newW, self.MinWidth, self.MaxWidth))
			end
			if edges.Top then
				newH = startSize.Y - dy
				newY = startPos.Y + (startSize.Y - math.clamp(newH, self.MinHeight, self.MaxHeight))
			end

			newW, newH = clampWindowSize(newW, newH, self.MinWidth, self.MinHeight, self.MaxWidth, self.MaxHeight)
			self.Window.Size = UDim2.new(0, newW, 0, newH)
			if edges.Left or edges.Top then
				self.Window.Position = UDim2.new(0, newX, 0, newY)
			end
			self.Width = newW
			self.Height = newH
		end)
		return h
	end

	local edge = HAS_TOUCH and 18 or 8
	makeResizeHandle(UDim2.new(0, edge, 1, -edge * 2), UDim2.new(1, -edge, 0, edge), { Right = true })
	makeResizeHandle(UDim2.new(1, -edge * 2, 0, edge), UDim2.new(0, edge, 1, -edge), { Bottom = true })
	makeResizeHandle(UDim2.new(0, edge + 6, 0, edge + 6), UDim2.new(1, -(edge + 6), 1, -(edge + 6)), { Right = true, Bottom = true })
	makeResizeHandle(UDim2.new(0, edge, 1, -edge * 2), UDim2.new(0, 0, 0, edge), { Left = true })
	makeResizeHandle(UDim2.new(1, -edge * 2, 0, edge), UDim2.new(0, edge, 0, 0), { Top = true })

	local cornerDot = Instance.new("Frame")
	cornerDot.Size = UDim2.new(0, HAS_TOUCH and 14 or 10, 0, HAS_TOUCH and 14 or 10)
	cornerDot.Position = UDim2.new(1, HAS_TOUCH and -16 or -12, 1, HAS_TOUCH and -16 or -12)
	cornerDot.BackgroundColor3 = Theme.Accent
	cornerDot.BackgroundTransparency = 0.35
	cornerDot.BorderSizePixel = 0
	cornerDot.ZIndex = 51
	cornerDot.Parent = self.Window
	addCorner(cornerDot, 2)

	-- ========== Floating Logo ==========
	local floatSize = HAS_TOUCH and 64 or 56
	self.FloatIcon = Instance.new("ImageButton")
	self.FloatIcon.Size = UDim2.new(0, floatSize, 0, floatSize)
	self.FloatIcon.Position = UDim2.new(0, 16, 0.55, 0)
	self.FloatIcon.BackgroundColor3 = Theme.BgPanel
	self.FloatIcon.Image = LOGO_ID
	self.FloatIcon.ScaleType = Enum.ScaleType.Fit
	self.FloatIcon.AutoButtonColor = false
	self.FloatIcon.Visible = false
	self.FloatIcon.Parent = self.Gui
	addCorner(self.FloatIcon, 14)
	addStroke(self.FloatIcon, Theme.Accent, 1.5, 0.25)
	addPadding(self.FloatIcon, 4, 4, 4, 4)

	local fDragging, fStart, fPos, fMoved = false, nil, nil, false
	self.FloatIcon.InputBegan:Connect(function(input)
		if isPrimaryInput(input) then
			fDragging = true
			fMoved = false
			fStart = input.Position
			fPos = self.FloatIcon.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if fDragging and isMoveInput(input) then
			local delta = input.Position - fStart
			if delta.Magnitude > 6 then fMoved = true end
			self.FloatIcon.Position = UDim2.new(
				fPos.X.Scale, fPos.X.Offset + delta.X,
				fPos.Y.Scale, fPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if isPrimaryInput(input) then
			if fDragging and not fMoved then self:Restore() end
			fDragging = false
		end
	end)

	function self:Minimize()
		self.Minimized = true
		self.Window.Visible = false
		self.FloatIcon.Visible = true
	end
	function self:Restore()
		self.Minimized = false
		self.FloatIcon.Visible = false
		self.Window.Visible = true
	end

	minBtn.MouseButton1Click:Connect(function() self:Minimize() end)
	minBtn.Activated:Connect(function() self:Minimize() end)

	UserInputService.InputBegan:Connect(function(input, gp)
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

	-- Home + Credits
	local homeTab = self:CreateTab("Home")
	local creditsTab = self:CreateTab("Credits")

	local homeCard = Instance.new("Frame")
	homeCard.Size = UDim2.new(1, -4, 0, HAS_TOUCH and 100 or 120)
	homeCard.BackgroundColor3 = Theme.BgCard
	homeCard.BorderSizePixel = 0
	homeCard.Parent = homeTab.Frame
	addCorner(homeCard, 12)
	addStroke(homeCard, Theme.Accent, 1, 0.5)

	local homeLogo = Instance.new("ImageLabel")
	homeLogo.Size = UDim2.new(0, 48, 0, 48)
	homeLogo.Position = UDim2.new(0, 16, 0.5, -24)
	homeLogo.BackgroundTransparency = 1
	homeLogo.Image = LOGO_ID
	homeLogo.ScaleType = Enum.ScaleType.Fit
	homeLogo.Parent = homeCard
	makeLabel(homeCard, "SXNGDU HUB", UDim2.new(1, -80, 0, 24), UDim2.new(0, 76, 0, 28), Theme.Accent, Enum.Font.GothamBold, 18)
	makeLabel(homeCard, "Mobile + PC  •  Ready", UDim2.new(1, -80, 0, 18), UDim2.new(0, 76, 0, 54), Theme.TextDim, Enum.Font.Gotham, 12)

	self:CreateLabel(homeTab, "")
	self:CreateLabel(homeTab, "QUICK ACTIONS")
	self:CreateButton(homeTab, "🚀  เริ่มใช้งาน", function()
		self:Notify("Sxngdu", "พร้อมใช้งานแล้ว", 2)
	end)
	self:CreateButton(homeTab, HAS_TOUCH and "📱  Device: Mobile" or "💻  Device: PC", function()
		self:Notify("Device", HAS_TOUCH and "โหมดมือถือ" or "โหมด PC", 2)
	end)

	self:CreateLabel(creditsTab, "DEVELOPER")
	local credCard = Instance.new("Frame")
	credCard.Size = UDim2.new(1, -4, 0, 90)
	credCard.BackgroundColor3 = Theme.BgCard
	credCard.BorderSizePixel = 0
	credCard.Parent = creditsTab.Frame
	addCorner(credCard, 12)
	addStroke(credCard, Theme.Accent, 1, 0.55)
	local credLogo = Instance.new("ImageLabel")
	credLogo.Size = UDim2.new(0, 50, 0, 50)
	credLogo.Position = UDim2.new(0, 14, 0.5, -25)
	credLogo.BackgroundTransparency = 1
	credLogo.Image = LOGO_ID
	credLogo.ScaleType = Enum.ScaleType.Fit
	credLogo.Parent = credCard
	makeLabel(credCard, "sxngdu", UDim2.new(1, -80, 0, 22), UDim2.new(0, 74, 0, 22), Theme.Text, Enum.Font.GothamBold, 16)
	makeLabel(credCard, "Main Developer  •  UI & Scripts", UDim2.new(1, -80, 0, 18), UDim2.new(0, 74, 0, 46), Theme.TextDim, Enum.Font.Gotham, 12)
	self:CreateLabel(creditsTab, "")
	self:CreateLabel(creditsTab, "ABOUT")
	self:CreateLabel(creditsTab, "Sxngdu Hub — Mobile Supported")
	self:CreateButton(creditsTab, "💬  Discord (soon)", function()
		self:Notify("Discord", "กำลังเปิดเร็ว ๆ นี้", 2)
	end)

	return self
end

function Library:CreateTab(name)
	local tab = { Name = name, Frame = Instance.new("ScrollingFrame") }
	tab.Frame.Size = UDim2.new(1, 0, 1, 0)
	tab.Frame.BackgroundTransparency = 1
	tab.Frame.ScrollBarThickness = HAS_TOUCH and 5 or 3
	tab.Frame.ScrollBarImageColor3 = Theme.Accent
	tab.Frame.BorderSizePixel = 0
	tab.Frame.Visible = false
	tab.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tab.Frame.ScrollingEnabled = true
	tab.Frame.Parent = self.Content
	addPadding(tab.Frame, 2, 8, 0, 4)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, HAS_TOUCH and 9 or 7)
	layout.Parent = tab.Frame
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tab.Frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
	end)

	local tabH = HAS_TOUCH and 34 or 28
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 0, 0, tabH)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = Theme.BgCard
	btn.Text = "  " .. name .. "  "
	btn.TextColor3 = Theme.TextDim
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = HAS_TOUCH and 13 or 12
	btn.AutoButtonColor = false
	btn.Parent = self.TabBar
	addCorner(btn, 8)
	local btnStroke = addStroke(btn, Theme.Stroke, 1, 0.7)

	local function selectTab()
		for _, t in pairs(self.Tabs) do
			t.Frame.Visible = false
			tween(t.Btn, { BackgroundColor3 = Theme.BgCard, TextColor3 = Theme.TextDim })
			if t.Stroke then t.Stroke.Transparency = 0.7 end
		end
		tab.Frame.Visible = true
		tween(btn, { BackgroundColor3 = Theme.AccentDim, TextColor3 = Theme.Text })
		btnStroke.Transparency = 0.2
		self.CurrentTab = tab
	end

	btn.MouseButton1Click:Connect(selectTab)
	btn.Activated:Connect(selectTab)

	tab.Btn = btn
	tab.Stroke = btnStroke
	self.Tabs[name] = tab
	if not self.CurrentTab then
		tab.Frame.Visible = true
		btn.BackgroundColor3 = Theme.AccentDim
		btn.TextColor3 = Theme.Text
		btnStroke.Transparency = 0.2
		self.CurrentTab = tab
	end
	return tab
end

function Library:CreateToggle(tab, text, default, callback)
	local rowH = HAS_TOUCH and 46 or 38
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, rowH)
	frame.BackgroundColor3 = Theme.BgCard
	frame.BorderSizePixel = 0
	frame.Parent = tab.Frame
	addCorner(frame, 9)
	addStroke(frame, Theme.Stroke, 1, 0.75)

	makeLabel(frame, text, UDim2.new(0.68, 0, 1, 0), UDim2.new(0, 12, 0, 0), Theme.Text, Enum.Font.Gotham, HAS_TOUCH and 14 or 13)

	local state = default == true
	local swW, swH = HAS_TOUCH and 52 or 46, HAS_TOUCH and 28 or 24
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, swW, 0, swH)
	sw.Position = UDim2.new(1, -(swW + 10), 0.5, -swH / 2)
	sw.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
	sw.Text = ""
	sw.AutoButtonColor = false
	sw.Parent = frame
	addCorner(sw, 14)
	addStroke(sw, state and Theme.AccentGlow or Theme.Stroke, 1, state and 0.3 or 0.6)

	local circleSize = HAS_TOUCH and 22 or 18
	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, circleSize, 0, circleSize)
	circle.Position = state and UDim2.new(1, -(circleSize + 3), 0.5, -circleSize / 2) or UDim2.new(0, 3, 0.5, -circleSize / 2)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = sw
	addCorner(circle, circleSize / 2)

	local function toggle()
		state = not state
		tween(sw, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
		tween(circle, {
			Position = state and UDim2.new(1, -(circleSize + 3), 0.5, -circleSize / 2)
				or UDim2.new(0, 3, 0.5, -circleSize / 2),
		})
		if callback then callback(state) end
	end

	sw.MouseButton1Click:Connect(toggle)
	sw.Activated:Connect(toggle)

	return {
		Get = function() return state end,
		Set = function(v)
			state = v == true
			sw.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
			circle.Position = state and UDim2.new(1, -(circleSize + 3), 0.5, -circleSize / 2)
				or UDim2.new(0, 3, 0.5, -circleSize / 2)
		end,
	}
end

function Library:CreateButton(tab, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, HAS_TOUCH and 44 or 36)
	btn.BackgroundColor3 = Theme.AccentDim
	btn.Text = text
	btn.TextColor3 = Theme.Text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = HAS_TOUCH and 14 or 13
	btn.AutoButtonColor = false
	btn.Parent = tab.Frame
	addCorner(btn, 9)
	addStroke(btn, Theme.Accent, 1, 0.4)

	local function fire()
		if callback then callback() end
	end
	btn.MouseButton1Click:Connect(fire)
	btn.Activated:Connect(fire)
	return btn
end

function Library:CreateLabel(tab, text)
	return makeLabel(tab.Frame, text, UDim2.new(1, -4, 0, HAS_TOUCH and 22 or 20), nil, Theme.TextDim, Enum.Font.GothamMedium, HAS_TOUCH and 12 or 11)
end

function Library:CreateSlider(tab, text, minV, maxV, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, HAS_TOUCH and 64 or 54)
	frame.BackgroundColor3 = Theme.BgCard
	frame.BorderSizePixel = 0
	frame.Parent = tab.Frame
	addCorner(frame, 9)
	addStroke(frame, Theme.Stroke, 1, 0.75)

	local value = default or minV
	local lbl = makeLabel(frame, text .. "  •  " .. value, UDim2.new(1, -16, 0, 20), UDim2.new(0, 12, 0, 6), Theme.Text, Enum.Font.Gotham, HAS_TOUCH and 13 or 12)

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -24, 0, HAS_TOUCH and 10 or 6)
	bg.Position = UDim2.new(0, 12, 0, HAS_TOUCH and 40 or 34)
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

	local knobSize = HAS_TOUCH and 20 or 14
	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, knobSize, 0, knobSize)
	knob.Position = UDim2.new((value - minV) / math.max(maxV - minV, 1), -knobSize / 2, 0.5, -knobSize / 2)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = bg
	addCorner(knob, knobSize / 2)
	addStroke(knob, Theme.Accent, 1.5, 0.2)

	local drag = false

	local function updateFromX(x)
		local rel = math.clamp((x - bg.AbsolutePosition.X) / math.max(bg.AbsoluteSize.X, 1), 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -knobSize / 2, 0.5, -knobSize / 2)
		value = math.floor(minV + rel * (maxV - minV) + 0.5)
		lbl.Text = text .. "  •  " .. value
		if callback then callback(value) end
	end

	knob.InputBegan:Connect(function(input)
		if isPrimaryInput(input) then drag = true end
	end)
	bg.InputBegan:Connect(function(input)
		if isPrimaryInput(input) then
			drag = true
			updateFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if isPrimaryInput(input) then drag = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if drag and isMoveInput(input) then
			updateFromX(input.Position.X)
		end
	end)

	return {
		Get = function() return value end,
		Set = function(v)
			value = math.clamp(v, minV, maxV)
			local rel = (value - minV) / math.max(maxV - minV, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -knobSize / 2, 0.5, -knobSize / 2)
			lbl.Text = text .. "  •  " .. value
		end,
	}
end

function Library:Notify(title, text, duration)
	duration = duration or 3
	local width = HAS_TOUCH and math.min(300, getCamSize().X - 24) or 260
	local n = Instance.new("Frame")
	n.Size = UDim2.new(0, width, 0, 60)
	n.Position = UDim2.new(1, -(width + 16), 1, 20)
	n.BackgroundColor3 = Theme.BgPanel
	n.BorderSizePixel = 0
	n.Parent = self.Gui
	addCorner(n, 10)
	addStroke(n, Theme.Accent, 1.2, 0.3)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, -12)
	bar.Position = UDim2.new(0, 6, 0, 6)
	bar.BackgroundColor3 = Theme.Accent
	bar.BorderSizePixel = 0
	bar.Parent = n
	addCorner(bar, 2)

	makeLabel(n, title, UDim2.new(1, -24, 0, 20), UDim2.new(0, 16, 0, 8), Theme.Accent, Enum.Font.GothamBold, 13)
	makeLabel(n, text, UDim2.new(1, -24, 0, 20), UDim2.new(0, 16, 0, 30), Theme.Text, Enum.Font.Gotham, 12)

	tween(n, { Position = UDim2.new(1, -(width + 16), 1, -80) }, 0.3)
	task.delay(duration, function()
		tween(n, { Position = UDim2.new(1, -(width + 16), 1, 20) }, 0.25)
		task.wait(0.3)
		n:Destroy()
	end)
end

return Library
