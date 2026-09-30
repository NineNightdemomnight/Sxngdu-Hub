--[[
	Sxngdu UI Library
	Dashboard Style + Cyberpunk Blue
	+ Scrollable Tabs + Edge Resize
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LOGO_ID  = "rbxassetid://116342011761764"
local CLOSE_ID = "rbxassetid://76173586881356"

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

local Library = {}
Library.__index = Library

function Library.new(config)
	local self = setmetatable({}, Library)
	self.Name = config.Name or "Sxngdu Hub"
	self.Tabs = {}
	self.CurrentTab = nil
	self.Minimized = false
	self.Width = config.Width or 760
	self.Height = config.Height or 480
	self.MinWidth = config.MinWidth or 560
	self.MinHeight = config.MinHeight or 360
	self.MaxWidth = config.MaxWidth or 1200
	self.MaxHeight = config.MaxHeight or 800

	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "SxngduLib_" .. tostring(math.random(10000, 99999))
	self.Gui.ResetOnSpawn = false
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui.Parent = PlayerGui

	-- ========== Main Window ==========
	self.Window = Instance.new("Frame")
	self.Window.Size = UDim2.new(0, self.Width, 0, self.Height)
	self.Window.Position = UDim2.new(0.5, -self.Width/2, 0.5, -self.Height/2)
	self.Window.BackgroundColor3 = Theme.Bg
	self.Window.BorderSizePixel = 0
	self.Window.Active = true
	self.Window.Draggable = true
	self.Window.ClipsDescendants = true
	self.Window.Parent = self.Gui
	addCorner(self.Window, 16)
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

	-- ========== LEFT SIDEBAR ==========
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 200, 1, -2)
	sidebar.Position = UDim2.new(0, 0, 0, 2)
	sidebar.BackgroundColor3 = Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = self.Window

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
		avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
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
	infoRow(170, "💻", "Executor", executorName)
	infoRow(194, "🖥", "Device", UserInputService.TouchEnabled and "Mobile" or "PC")
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

	-- ========== RIGHT AREA ==========
	local right = Instance.new("Frame")
	right.Name = "Right"
	right.Size = UDim2.new(1, -210, 1, -2)
	right.Position = UDim2.new(0, 205, 0, 2)
	right.BackgroundTransparency = 1
	right.Parent = self.Window

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 44)
	titleBar.BackgroundTransparency = 1
	titleBar.Parent = right

	local logoSmall = Instance.new("ImageLabel")
	logoSmall.Size = UDim2.new(0, 26, 0, 26)
	logoSmall.Position = UDim2.new(0, 8, 0.5, -13)
	logoSmall.BackgroundTransparency = 1
	logoSmall.Image = LOGO_ID
	logoSmall.ScaleType = Enum.ScaleType.Fit
	logoSmall.Parent = titleBar
	makeLabel(titleBar, self.Name, UDim2.new(0.55, 0, 1, 0), UDim2.new(0, 40, 0, 0), Theme.Text, Enum.Font.GothamBold, 15)

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 30, 0, 30)
	minBtn.Position = UDim2.new(1, -72, 0.5, -15)
	minBtn.BackgroundColor3 = Theme.BgCard
	minBtn.Text = "–"
	minBtn.TextColor3 = Theme.Accent
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 18
	minBtn.AutoButtonColor = false
	minBtn.Parent = titleBar
	addCorner(minBtn, 8)
	addStroke(minBtn, Theme.Accent, 1, 0.5)
	minBtn.MouseEnter:Connect(function() tween(minBtn, {BackgroundColor3 = Theme.BgHover}) end)
	minBtn.MouseLeave:Connect(function() tween(minBtn, {BackgroundColor3 = Theme.BgCard}) end)

	local close = Instance.new("ImageButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -36, 0.5, -15)
	close.BackgroundColor3 = Theme.BgCard
	close.Image = CLOSE_ID
	close.ScaleType = Enum.ScaleType.Fit
	close.AutoButtonColor = false
	close.Parent = titleBar
	addCorner(close, 8)
	addStroke(close, Color3.fromRGB(255, 80, 100), 1, 0.5)
	addPadding(close, 5, 5, 5, 5)
	close.MouseEnter:Connect(function() tween(close, {BackgroundColor3 = Color3.fromRGB(50, 20, 30)}) end)
	close.MouseLeave:Connect(function() tween(close, {BackgroundColor3 = Theme.BgCard}) end)
	close.MouseButton1Click:Connect(function()
		self.Gui.Enabled = false
	end)

	-- Tab bar (ScrollingFrame เพื่อแท็บเยอะไม่ล้น)
	self.TabBar = Instance.new("ScrollingFrame")
	self.TabBar.Name = "TabBar"
	self.TabBar.Size = UDim2.new(1, -16, 0, 34)
	self.TabBar.Position = UDim2.new(0, 8, 0, 48)
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
	self.Content.Size = UDim2.new(1, -16, 1, -96)
	self.Content.Position = UDim2.new(0, 8, 0, 86)
	self.Content.BackgroundTransparency = 1
	self.Content.Parent = right

	-- ========== Resize Handles ==========
	local function makeResizeHandle(size, pos, cursor, edges)
		local h = Instance.new("TextButton")
		h.Size = size
		h.Position = pos
		h.BackgroundTransparency = 1
		h.Text = ""
		h.ZIndex = 50
		h.Parent = self.Window

		local resizing = false
		local startMouse, startSize, startPos

		h.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				self.Window.Draggable = false
				startMouse = UserInputService:GetMouseLocation()
				startSize = self.Window.AbsoluteSize
				startPos = self.Window.AbsolutePosition
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and resizing then
				resizing = false
				self.Window.Draggable = true
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local mouse = UserInputService:GetMouseLocation()
			local dx = mouse.X - startMouse.X
			local dy = mouse.Y - startMouse.Y

			local newW = startSize.X
			local newH = startSize.Y
			local newX = startPos.X
			local newY = startPos.Y

			if edges.Right then
				newW = math.clamp(startSize.X + dx, self.MinWidth, self.MaxWidth)
			end
			if edges.Bottom then
				newH = math.clamp(startSize.Y + dy, self.MinHeight, self.MaxHeight)
			end
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
			self.Width = newW
			self.Height = newH
		end)

		return h
	end

	-- ขอบขวา / ล่าง / มุมขวาล่าง (ใช้บ่อยสุด)
	makeResizeHandle(UDim2.new(0, 8, 1, -16), UDim2.new(1, -8, 0, 8), "Right", {Right = true})
	makeResizeHandle(UDim2.new(1, -16, 0, 8), UDim2.new(0, 8, 1, -8), "Bottom", {Bottom = true})
	makeResizeHandle(UDim2.new(0, 14, 0, 14), UDim2.new(1, -14, 1, -14), "Corner", {Right = true, Bottom = true})
	makeResizeHandle(UDim2.new(0, 8, 1, -16), UDim2.new(0, 0, 0, 8), "Left", {Left = true})
	makeResizeHandle(UDim2.new(1, -16, 0, 8), UDim2.new(0, 8, 0, 0), "Top", {Top = true})

	-- จุดมุมขวาล่าง (มองเห็นเล็กน้อย)
	local cornerDot = Instance.new("Frame")
	cornerDot.Size = UDim2.new(0, 10, 0, 10)
	cornerDot.Position = UDim2.new(1, -12, 1, -12)
	cornerDot.BackgroundColor3 = Theme.Accent
	cornerDot.BackgroundTransparency = 0.4
	cornerDot.BorderSizePixel = 0
	cornerDot.ZIndex = 51
	cornerDot.Parent = self.Window
	addCorner(cornerDot, 2)

	-- ========== Floating Logo ==========
	self.FloatIcon = Instance.new("ImageButton")
	self.FloatIcon.Size = UDim2.new(0, 56, 0, 56)
	self.FloatIcon.Position = UDim2.new(0, 20, 0.5, -28)
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
	self.FloatIcon.MouseEnter:Connect(function() tween(self.FloatIcon, {Size = UDim2.new(0, 62, 0, 62)}, 0.15) end)
	self.FloatIcon.MouseLeave:Connect(function() tween(self.FloatIcon, {Size = UDim2.new(0, 56, 0, 56)}, 0.15) end)

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

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			if self.Minimized then self:Restore()
			elseif self.Window.Visible then self:Minimize()
			else self.Gui.Enabled = true self:Restore() end
		end
	end)

	-- Home + Credits
	local homeTab = self:CreateTab("Home")
	local creditsTab = self:CreateTab("Credits")

	local homeCard = Instance.new("Frame")
	homeCard.Size = UDim2.new(1, -4, 0, 120)
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
	makeLabel(homeCard, "Secure script loader  •  Ready", UDim2.new(1, -80, 0, 18), UDim2.new(0, 76, 0, 54), Theme.TextDim, Enum.Font.Gotham, 12)
	makeLabel(homeCard, "ACTIVE", UDim2.new(0, 60, 0, 18), UDim2.new(1, -76, 0, 14), Theme.Green, Enum.Font.GothamBold, 11, Enum.TextXAlignment.Right)

	self:CreateLabel(homeTab, "")
	self:CreateLabel(homeTab, "QUICK ACTIONS")
	self:CreateButton(homeTab, "🚀  เริ่มใช้งาน", function()
		self:Notify("Sxngdu", "พร้อมใช้งานแล้ว", 2)
	end)
	self:CreateButton(homeTab, "📋  คัดลอก HWID", function()
		local hwid = "N/A"
		pcall(function()
			if gethwid then hwid = gethwid() end
		end)
		if setclipboard then setclipboard(tostring(hwid)) end
		self:Notify("HWID", "คัดลอกแล้ว", 2)
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
	self:CreateLabel(creditsTab, "Sxngdu Hub — Cyberpunk Blue Edition")
	self:CreateLabel(creditsTab, "Made for Ride A Pet & more")
	self:CreateButton(creditsTab, "💬  Discord (soon)", function()
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
	tab.Frame.Parent = self.Content
	addPadding(tab.Frame, 2, 4, 0, 4)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 7)
	layout.Parent = tab.Frame
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tab.Frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 0, 0, 28)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = Theme.BgCard
	btn.Text = "  " .. name .. "  "
	btn.TextColor3 = Theme.TextDim
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = self.TabBar
	addCorner(btn, 8)
	local btnStroke = addStroke(btn, Theme.Stroke, 1, 0.7)

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
			if t.Stroke then t.Stroke.Transparency = 0.7 end
		end
		tab.Frame.Visible = true
		tween(btn, {BackgroundColor3 = Theme.AccentDim, TextColor3 = Theme.Text})
		btnStroke.Transparency = 0.2
		self.CurrentTab = tab
	end)

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
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 38)
	frame.BackgroundColor3 = Theme.BgCard
	frame.BorderSizePixel = 0
	frame.Parent = tab.Frame
	addCorner(frame, 9)
	addStroke(frame, Theme.Stroke, 1, 0.75)
	makeLabel(frame, text, UDim2.new(0.72, 0, 1, 0), UDim2.new(0, 12, 0, 0), Theme.Text, Enum.Font.Gotham, 13)

	local state = default == true
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 46, 0, 24)
	sw.Position = UDim2.new(1, -56, 0.5, -12)
	sw.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
	sw.Text = ""
	sw.AutoButtonColor = false
	sw.Parent = frame
	addCorner(sw, 12)
	addStroke(sw, state and Theme.AccentGlow or Theme.Stroke, 1, state and 0.3 or 0.6)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 18, 0, 18)
	circle.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
	circle.Parent = sw
	addCorner(circle, 9)

	sw.MouseButton1Click:Connect(function()
		state = not state
		tween(sw, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff})
		tween(circle, {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
		if callback then callback(state) end
	end)

	return {
		Get = function() return state end,
		Set = function(v)
			state = v == true
			sw.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
			circle.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		end,
	}
end

function Library:CreateButton(tab, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 36)
	btn.BackgroundColor3 = Theme.AccentDim
	btn.Text = text
	btn.TextColor3 = Theme.Text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = tab.Frame
	addCorner(btn, 9)
	addStroke(btn, Theme.Accent, 1, 0.4)
	btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.Accent}) end)
	btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.AccentDim}) end)
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
	return btn
end

function Library:CreateLabel(tab, text)
	return makeLabel(tab.Frame, text, UDim2.new(1, -4, 0, 20), nil, Theme.TextDim, Enum.Font.GothamMedium, 11)
end

function Library:CreateSlider(tab, text, minV, maxV, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -4, 0, 54)
	frame.BackgroundColor3 = Theme.BgCard
	frame.BorderSizePixel = 0
	frame.Parent = tab.Frame
	addCorner(frame, 9)
	addStroke(frame, Theme.Stroke, 1, 0.75)

	local value = default or minV
	local lbl = makeLabel(frame, text .. "  •  " .. value, UDim2.new(1, -16, 0, 20), UDim2.new(0, 12, 0, 6), Theme.Text, Enum.Font.Gotham, 12)

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -24, 0, 6)
	bg.Position = UDim2.new(0, 12, 0, 34)
	bg.BackgroundColor3 = Theme.ToggleOff
	bg.BorderSizePixel = 0
	bg.Parent = frame
	addCorner(bg, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((value - minV) / math.max(maxV - minV, 1), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Slider
	fill.BorderSizePixel = 0
	fill.Parent = bg
	addCorner(fill, 3)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((value - minV) / math.max(maxV - minV, 1), -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Parent = bg
	addCorner(knob, 7)
	addStroke(knob, Theme.Accent, 1.5, 0.2)

	local drag = false
	knob.MouseButton1Down:Connect(function() drag = true end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local rel = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -7, 0.5, -7)
			value = math.floor(minV + rel * (maxV - minV) + 0.5)
			lbl.Text = text .. "  •  " .. value
			if callback then callback(value) end
		end
	end)

	return {
		Get = function() return value end,
		Set = function(v)
			value = math.clamp(v, minV, maxV)
			local rel = (value - minV) / math.max(maxV - minV, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -7, 0.5, -7)
			lbl.Text = text .. "  •  " .. value
		end,
	}
end

function Library:Notify(title, text, duration)
	duration = duration or 3
	local n = Instance.new("Frame")
	n.Size = UDim2.new(0, 260, 0, 60)
	n.Position = UDim2.new(1, -280, 1, 20)
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

	tween(n, {Position = UDim2.new(1, -280, 1, -80)}, 0.3)
	task.delay(duration, function()
		tween(n, {Position = UDim2.new(1, -280, 1, 20)}, 0.25)
		task.wait(0.3)
		n:Destroy()
	end)
end

return Library
