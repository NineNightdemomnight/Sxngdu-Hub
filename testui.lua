local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NineNightdemomnight/Sxngdu-Hub/refs/heads/main/SxngduUi.lua"))()

local Window = Library.new({
	Name = "SXNGDU Test Hub",
	Width = 760,
	Height = 480,
	ToggleKey = Enum.KeyCode.RightShift
})

-- สร้างแท็บใหม่
local MainTab = Window:CreateTab("Main")
local PlayerTab = Window:CreateTab("Player")
local MiscTab = Window:CreateTab("Misc")

-- ===== Main Tab =====
Window:CreateLabel(MainTab, "GENERAL")

Window:CreateButton(MainTab, "🚀  ทดสอบปุ่ม", function()
	Window:Notify("สำเร็จ", "ปุ่มทำงานปกติ!", 3)
	print("Button clicked!")
end)

Window:CreateToggle(MainTab, "เปิดระบบทดสอบ", false, function(Value)
	print("Toggle:", Value)
	Window:Notify("Toggle", Value and "เปิดแล้ว" or "ปิดแล้ว", 2)
end)

Window:CreateSlider(MainTab, "ความเร็ว", 16, 200, 16, function(Value)
	print("Speed:", Value)
end)

-- ===== Player Tab =====
Window:CreateLabel(PlayerTab, "PLAYER OPTIONS")

Window:CreateToggle(PlayerTab, "WalkSpeed", false, function(Value)
	local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = Value and 50 or 16
	end
end)

Window:CreateToggle(PlayerTab, "JumpPower", false, function(Value)
	local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	if hum then
		hum.JumpPower = Value and 100 or 50
	end
end)

Window:CreateSlider(PlayerTab, "WalkSpeed Value", 16, 150, 16, function(Value)
	local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = Value
	end
end)

-- ===== Misc Tab =====
Window:CreateLabel(MiscTab, "MISCELLANEOUS")

Window:CreateButton(MiscTab, "📢  แจ้งเตือน", function()
	Window:Notify("Sxngdu", "ระบบแจ้งเตือนทำงานปกติ", 3)
end)

Window:CreateButton(MiscTab, "❌  ปิด UI", function()
	Window.Gui.Enabled = false
end)

print("SXNGDU UI Library โหลดและทดสอบสำเร็จ!")
