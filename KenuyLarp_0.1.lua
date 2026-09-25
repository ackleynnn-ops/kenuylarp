local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local KORB_MESH, KORB_TEX = 101851696, 101851254
local HEAD_MESH = "rbxassetid://15093053680"
local korbloxOn, headlessOn = true, true
local oHM, oHT, oF = {}, {}, {}
local function rigs()
	local t = {}
	local function push(m) if m and typeof(m) == "Instance" and m:IsA("Model") then table.insert(t, m) end end
	if LP.Character and (LP.Character:FindFirstChild("Right Leg") or LP.Character:FindFirstChild("RightLeg")) then push(LP.Character) end
	pcall(function() local r = workspace:FindFirstChild("Rigs") if r and r:FindFirstChild(LP.Name) then push(r[LP.Name]) end end)
	pcall(function() local pc = workspace:FindFirstChild("PlayerCache") if pc and pc:FindFirstChild(LP.Name) then local r6 = pc[LP.Name]:FindFirstChild("R6") if r6 then push(r6) end end end)
	pcall(function() for _, d in ipairs(LP.PlayerGui:GetDescendants()) do if d:IsA("Model") and d.Name == "VisualRigClassic" and d:FindFirstChild("Right Leg") then table.insert(t, d) end end end)
	return t
end
local function natural(m)
	pcall(function()
		local r = m:FindFirstChild("Right Leg") or m:FindFirstChild("RightLeg")
		local l = m:FindFirstChild("Left Leg") or m:FindFirstChild("LeftLeg")
		if r and l and r:IsA("BasePart") and l:IsA("BasePart") then r.Color = l.Color r.Material = l.Material r.Reflectance = 0 end
	end)
end
local function kApply(m)
	natural(m)
	for _, c in ipairs(m:GetChildren()) do if c:IsA("CharacterMesh") and c.BodyPart == Enum.BodyPart.RightLeg and c.MeshId == KORB_MESH then return end end
	local cm = Instance.new("CharacterMesh")
	cm.Name = "Korblox Deathspeaker Right Leg"
	cm.BodyPart = Enum.BodyPart.RightLeg
	cm.MeshId = KORB_MESH
	cm.OverlayTextureId = KORB_TEX
	cm.Parent = m
end
local function kRemove(m)
	for _, c in ipairs(m:GetChildren()) do if c:IsA("CharacterMesh") and c.BodyPart == Enum.BodyPart.RightLeg and (c.MeshId == KORB_MESH or c.Name:lower():find("korblox")) then c:Destroy() end end
end
local function hApply(m)
	local h = m:FindFirstChild("Head")
	if not h or not h:IsA("BasePart") or h:IsA("MeshPart") then return end
	local sm = h:FindFirstChildOfClass("SpecialMesh")
	if sm then if oHM[sm] == nil then oHM[sm] = sm.MeshId end sm.MeshId = HEAD_MESH end
	if oHT[h] == nil then oHT[h] = h.Transparency end
	h.Transparency = 1
	for _, d in ipairs(h:GetChildren()) do if d:IsA("Decal") then if oF[d] == nil then oF[d] = d.Transparency end d.Transparency = 1 end end
end
local function hRemove(m)
	local h = m:FindFirstChild("Head")
	if not h then return end
	if oHT[h] ~= nil then pcall(function() h.Transparency = oHT[h] end) end
	local sm = h:FindFirstChildOfClass("SpecialMesh")
	if sm and oHM[sm] ~= nil then pcall(function() sm.MeshId = oHM[sm] end) end
	for _, d in ipairs(h:GetChildren()) do if d:IsA("Decal") and oF[d] ~= nil then pcall(function() d.Transparency = oF[d] end) end end
end
local function applyAll()
	for _, m in ipairs(rigs()) do pcall(function()
		if korbloxOn then kApply(m) end
		if headlessOn then hApply(m) end
	end) end
end
pcall(function() local o = LP.PlayerGui:FindFirstChild("KenuyLarp") if o then o:Destroy() end end)
pcall(function() local o = LP.PlayerGui:FindFirstChild("VisualLocalGui") if o then o:Destroy() end end)
local BG = Color3.fromRGB(17, 17, 19)
local SURFACE = Color3.fromRGB(24, 24, 28)
local SURFACE_ALT = Color3.fromRGB(34, 34, 40)
local BORDER = Color3.fromRGB(46, 46, 54)
local TEXT = Color3.fromRGB(240, 240, 245)
local MUTED = Color3.fromRGB(160, 162, 170)
local ON_GREEN = Color3.fromRGB(22, 163, 74)
local gui = Instance.new("ScreenGui")
gui.Name = "KenuyLarp"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP.PlayerGui
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 240, 0, 216)
f.Position = UDim2.new(0, 20, 0.5, -108)
f.BackgroundColor3 = BG
f.BorderSizePixel = 0
f.Active = true
f.Draggable = true
f.Parent = gui
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 10) fc.Parent = f
local fs = Instance.new("UIStroke") fs.Color = BORDER fs.Thickness = 1 fs.Parent = f
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 34)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kenuy Larp 0.1"
title.TextColor3 = TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = f
local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 24, 0, 24)
x.Position = UDim2.new(1, -30, 0, 6)
x.Text = "X"
x.Font = Enum.Font.GothamBold
x.TextSize = 13
x.BackgroundColor3 = SURFACE_ALT
x.TextColor3 = TEXT
x.Parent = f
local xc = Instance.new("UICorner") xc.CornerRadius = UDim.new(0, 6) xc.Parent = x
local xs = Instance.new("UIStroke") xs.Color = BORDER xs.Thickness = 1 xs.Parent = x
local function styleBtn(b)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = b
	local s = Instance.new("UIStroke") s.Color = BORDER s.Thickness = 1 s.Parent = b
end
local bK = Instance.new("TextButton")
bK.Size = UDim2.new(1, -24, 0, 40)
bK.Position = UDim2.new(0, 12, 0, 40)
bK.Font = Enum.Font.GothamBold
bK.TextSize = 14
bK.TextColor3 = TEXT
bK.BackgroundColor3 = SURFACE
bK.Parent = f
styleBtn(bK)
local bH = Instance.new("TextButton")
bH.Size = UDim2.new(1, -24, 0, 40)
bH.Position = UDim2.new(0, 12, 0, 86)
bH.Font = Enum.Font.GothamBold
bH.TextSize = 14
bH.TextColor3 = TEXT
bH.BackgroundColor3 = SURFACE
bH.Parent = f
styleBtn(bH)
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -24, 0, 18)
hint.Position = UDim2.new(0, 12, 0, 132)
hint.BackgroundTransparency = 1
hint.Text = "Press K to toggle"
hint.TextColor3 = MUTED
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.Parent = f
local foot = Instance.new("TextLabel")
foot.Size = UDim2.new(1, -24, 0, 18)
foot.Position = UDim2.new(0, 12, 0, 152)
foot.BackgroundTransparency = 1
foot.Text = "made by @ackleyn"
foot.TextColor3 = MUTED
foot.Font = Enum.Font.Gotham
foot.TextSize = 12
foot.Parent = f
local function setVisible(v)
	f.Visible = v
end
local function ref()
	if korbloxOn then bK.Text = "Korblox : ON" bK.BackgroundColor3 = ON_GREEN
	else bK.Text = "Korblox : OFF" bK.BackgroundColor3 = SURFACE end
	if headlessOn then bH.Text = "Headless : ON" bH.BackgroundColor3 = ON_GREEN
	else bH.Text = "Headless : OFF" bH.BackgroundColor3 = SURFACE end
end
bK.MouseButton1Click:Connect(function()
	korbloxOn = not korbloxOn
	if korbloxOn then applyAll() else for _, m in ipairs(rigs()) do pcall(kRemove, m) end end
	ref()
end)
bH.MouseButton1Click:Connect(function()
	headlessOn = not headlessOn
	if headlessOn then applyAll() else for _, m in ipairs(rigs()) do pcall(hRemove, m) end end
	ref()
end)
x.MouseButton1Click:Connect(function() setVisible(false) end)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.K then
		setVisible(not f.Visible)
	end
end)
ref()
applyAll()
task.spawn(function() while gui.Parent do task.wait(1.5) if korbloxOn or headlessOn then pcall(applyAll) end end end)
LP.CharacterAdded:Connect(function() task.wait(1) pcall(applyAll) end)
