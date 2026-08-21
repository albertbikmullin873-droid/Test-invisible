-- Alliver Hub | Maximum Invisibility (Hitbox Preserved)
-- You stay in the same place with real hitboxes, only visuals are destroyed

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart
local Invisible = false
local EnforceConnection = nil
local OriginalData = {}

local Logs = {}
local MaxLogs = 14

-- ====================== LOGS ======================
local function AddLog(text, color)
	color = color or Color3.fromRGB(200, 200, 220)
	table.insert(Logs, 1, {Text = text, Color = color})
	if #Logs > MaxLogs then table.remove(Logs) end
	if _G.AlliverUpdateLogs then _G.AlliverUpdateLogs() end
end

local function ClearLogs()
	Logs = {}
	if _G.AlliverUpdateLogs then _G.AlliverUpdateLogs() end
end

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlliverHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 410)
MainFrame.Position = UDim2.new(0.5, -170, 0.32, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 19)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(110, 95, 255)
Stroke.Thickness = 1.6
Stroke.Transparency = 0.25

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -20, 0, 34)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Alliver Hub"
Title.TextColor3 = Color3.fromRGB(175, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.Size = UDim2.new(1, -20, 0, 18)
SubTitle.Position = UDim2.new(0, 10, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Max Invisibility | Hitboxes Kept"
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 170)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 44)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 62)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 46)
ToggleBtn.Text = "Enable Invisibility"
ToggleBtn.TextColor3 = Color3.fromRGB(225, 225, 255)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 15
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 114)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Off"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 185)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ClearBtn = Instance.new("TextButton", MainFrame)
ClearBtn.Size = UDim2.new(0.42, 0, 0, 28)
ClearBtn.Position = UDim2.new(0.05, 0, 0, 145)
ClearBtn.BackgroundColor3 = Color3.fromRGB(42, 28, 50)
ClearBtn.Text = "Clear Logs"
ClearBtn.TextColor3 = Color3.fromRGB(205, 185, 225)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

local CheckBtn = Instance.new("TextButton", MainFrame)
CheckBtn.Size = UDim2.new(0.42, 0, 0, 28)
CheckBtn.Position = UDim2.new(0.53, 0, 0, 145)
CheckBtn.BackgroundColor3 = Color3.fromRGB(26, 38, 54)
CheckBtn.Text = "Check"
CheckBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
CheckBtn.Font = Enum.Font.Gotham
CheckBtn.TextSize = 12
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 6)

local LogTitle = Instance.new("TextLabel", MainFrame)
LogTitle.Size = UDim2.new(1, -20, 0, 20)
LogTitle.Position = UDim2.new(0, 10, 0, 184)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "Logs / Errors:"
LogTitle.TextColor3 = Color3.fromRGB(150, 150, 195)
LogTitle.Font = Enum.Font.GothamSemibold
LogTitle.TextSize = 13
LogTitle.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Size = UDim2.new(0.9, 0, 0, 190)
LogFrame.Position = UDim2.new(0.05, 0, 0, 206)
LogFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 13)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(85, 80, 160)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 8)

local LogList = Instance.new("UIListLayout", LogFrame)
LogList.SortOrder = Enum.SortOrder.LayoutOrder
LogList.Padding = UDim.new(0, 3)

_G.AlliverUpdateLogs = function()
	for _, child in pairs(LogFrame:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	for i, log in ipairs(Logs) do
		local label = Instance.new("TextLabel", LogFrame)
		label.Size = UDim2.new(1, -8, 0, 15)
		label.BackgroundTransparency = 1
		label.Text = log.Text
		label.TextColor3 = log.Color
		label.Font = Enum.Font.Code
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.LayoutOrder = i
	end
	LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y + 8)
end

-- ====================== CORE LOGIC ======================
local function GetCharacter()
	local success, err = pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid", 5)
		RootPart = Character:WaitForChild("HumanoidRootPart", 5)
		if not Humanoid or not RootPart then
			error("Humanoid or RootPart missing")
		end
	end)
	if not success then
		AddLog("[ERROR] " .. tostring(err), Color3.fromRGB(255, 85, 85))
		return false
	end
	AddLog("[OK] Character ready", Color3.fromRGB(100, 255, 145))
	return true
end

local function SaveOriginalState()
	OriginalData = {}
	local count = 0

	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			OriginalData[v] = {
				Transparency = v.Transparency,
				CanCollide = v.CanCollide,
				Size = v.Size,
				LocalTransparencyModifier = v.LocalTransparencyModifier
			}
			count += 1
		elseif v:IsA("Decal") or v:IsA("Texture") then
			OriginalData[v] = {Transparency = v.Transparency}
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
			OriginalData[v] = {Enabled = v.Enabled}
		end
	end

	-- Save clothing references
	OriginalData.Shirt = Character:FindFirstChildOfClass("Shirt")
	OriginalData.Pants = Character:FindFirstChildOfClass("Pants")
	OriginalData.TShirt = Character:FindFirstChildOfClass("ShirtGraphic")

	AddLog("[OK] Saved state of " .. count .. " objects", Color3.fromRGB(100, 220, 255))
end

local function ForceHide()
	if not Character or not Character.Parent then return end

	-- Destroy accessories every time (games re-add them)
	for _, child in pairs(Character:GetChildren()) do
		if child:IsA("Accessory") or child:IsA("Hat") then
			child:Destroy()
		end
	end

	-- Destroy clothing
	local shirt = Character:FindFirstChildOfClass("Shirt")
	local pants = Character:FindFirstChildOfClass("Pants")
	local tshirt = Character:FindFirstChildOfClass("ShirtGraphic")
	if shirt then shirt:Destroy() end
	if pants then pants:Destroy() end
	if tshirt then tshirt:Destroy() end

	-- Force every part
	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			v.LocalTransparencyModifier = 1
			if v.Name ~= "HumanoidRootPart" then
				v.CanCollide = false
			end
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
			v.Enabled = false
		end
	end

	-- Hide name & health
	pcall(function()
		Humanoid.NameDisplayDistance = 0
		Humanoid.HealthDisplayDistance = 0
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end)
end

local function Restore()
	if not Character then return end

	for obj, data in pairs(OriginalData) do
		if typeof(obj) == "Instance" and obj.Parent then
			pcall(function()
				if obj:IsA("BasePart") then
					obj.Transparency = data.Transparency or 0
					obj.LocalTransparencyModifier = data.LocalTransparencyModifier or 0
					obj.CanCollide = data.CanCollide
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = data.Transparency or 0
				elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
					obj.Enabled = data.Enabled
				end
			end)
		end
	end

	pcall(function()
		Humanoid.NameDisplayDistance = 100
		Humanoid.HealthDisplayDistance = 100
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	end)
end

local function StartEnforcement()
	if EnforceConnection then EnforceConnection:Disconnect() end

	EnforceConnection = RunService.Heartbeat:Connect(function()
		if Invisible and Character and Character.Parent then
			ForceHide()
		end
	end)
end

local function StopEnforcement()
	if EnforceConnection then
		EnforceConnection:Disconnect()
		EnforceConnection = nil
	end
end

local function ToggleInvisibility()
	AddLog("——— Toggling ———", Color3.fromRGB(145, 145, 185))

	if not GetCharacter() then return end

	Invisible = not Invisible

	if Invisible then
		SaveOriginalState()
		ForceHide()
		StartEnforcement()

		ToggleBtn.Text = "Disable Invisibility"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(58, 28, 72)
		StatusLabel.Text = "Status: On | Hitboxes Active"
		StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 160)

		AddLog("[SUCCESS] Invisibility enabled", Color3.fromRGB(100, 255, 160))
		AddLog("Hitboxes & death logic fully preserved", Color3.fromRGB(180, 150, 255))
	else
		StopEnforcement()
		Restore()

		ToggleBtn.Text = "Enable Invisibility"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 46)
		StatusLabel.Text = "Status: Off"
		StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 185)

		AddLog("[SUCCESS] Invisibility disabled + restored", Color3.fromRGB(160, 205, 255))
	end
end

local function CheckEverything()
	AddLog("——— Diagnostics ———", Color3.fromRGB(145, 145, 185))
	if not GetCharacter() then return end

	local total, visible = 0, 0
	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			total += 1
			if v.Transparency < 1 or v.LocalTransparencyModifier < 1 then
				visible += 1
			end
		end
	end

	AddLog("Body parts: " .. total, Color3.fromRGB(200, 200, 220))
	AddLog("Still visible: " .. visible, visible > 0 and Color3.fromRGB(255, 160, 60) or Color3.fromRGB(100, 255, 145))
	AddLog("RootPart CanCollide: " .. tostring(RootPart.CanCollide), Color3.fromRGB(200, 200, 220))
	AddLog("Enforcement active: " .. tostring(EnforceConnection ~= nil), Color3.fromRGB(200, 200, 220))

	if Invisible and visible == 0 then
		AddLog("[OK] Fully hidden on your client", Color3.fromRGB(100, 255, 145))
	end
end

-- ====================== EVENTS ======================
ToggleBtn.MouseButton1Click:Connect(function()
	local ok, err = pcall(ToggleInvisibility)
	if not ok then AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 50, 50)) end
end)

ClearBtn.MouseButton1Click:Connect(function()
	ClearLogs()
	AddLog("Logs cleared", Color3.fromRGB(160, 160, 185))
end)

CheckBtn.MouseButton1Click:Connect(function()
	local ok, err = pcall(CheckEverything)
	if not ok then AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 50, 50)) end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G then
		local ok, err = pcall(ToggleInvisibility)
		if not ok then AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 50, 50)) end
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	AddLog("[INFO] Character respawned", Color3.fromRGB(185, 185, 110))
	Invisible = false
	StopEnforcement()
	ToggleBtn.Text = "Enable Invisibility"
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 46)
	StatusLabel.Text = "Status: Off"
	StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 185)
	task.wait(1.2)
	GetCharacter()
end)

-- Start
AddLog("Alliver Hub loaded", Color3.fromRGB(145, 145, 255))
AddLog("Keybind: G", Color3.fromRGB(145, 145, 185))
AddLog("Hitboxes + death logic fully preserved", Color3.fromRGB(180, 150, 255))
GetCharacter()
