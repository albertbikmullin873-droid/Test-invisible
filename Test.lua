-- Alliver Hub | Invisibility + Debug System
-- Fully English version

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart

-- ====================== STATE ======================
local Invisible = false
local OriginalTransparencies = {}
local Logs = {}
local MaxLogs = 12

-- ====================== LOG FUNCTIONS ======================
local function AddLog(text, color)
	color = color or Color3.fromRGB(200, 200, 220)
	table.insert(Logs, 1, {Text = text, Color = color})
	
	if #Logs > MaxLogs then
		table.remove(Logs)
	end
	
	if _G.AlliverUpdateLogs then
		_G.AlliverUpdateLogs()
	end
end

local function ClearLogs()
	Logs = {}
	if _G.AlliverUpdateLogs then
		_G.AlliverUpdateLogs()
	end
end

-- ====================== GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlliverHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90, 90, 255)
Stroke.Thickness = 1.6
Stroke.Transparency = 0.25
Stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 36)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Alliver Hub"
Title.TextColor3 = Color3.fromRGB(170, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -20, 0, 18)
SubTitle.Position = UDim2.new(0, 10, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Invisibility + Debug"
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 160)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 62)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
ToggleBtn.Text = "Enable Invisibility"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(90, 90, 200)
BtnStroke.Thickness = 1
BtnStroke.Parent = ToggleBtn

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 108)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Off"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Clear Logs Button
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.42, 0, 0, 28)
ClearBtn.Position = UDim2.new(0.05, 0, 0, 136)
ClearBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 45)
ClearBtn.Text = "Clear Logs"
ClearBtn.TextColor3 = Color3.fromRGB(200, 180, 220)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
ClearBtn.Parent = MainFrame

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

-- Check Button
local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(0.42, 0, 0, 28)
CheckBtn.Position = UDim2.new(0.53, 0, 0, 136)
CheckBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
CheckBtn.Text = "Check"
CheckBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
CheckBtn.Font = Enum.Font.Gotham
CheckBtn.TextSize = 12
CheckBtn.Parent = MainFrame

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 6)
CheckCorner.Parent = CheckBtn

-- Logs Title
local LogTitle = Instance.new("TextLabel")
LogTitle.Size = UDim2.new(1, -20, 0, 20)
LogTitle.Position = UDim2.new(0, 10, 0, 172)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "Logs / Errors:"
LogTitle.TextColor3 = Color3.fromRGB(150, 150, 190)
LogTitle.Font = Enum.Font.GothamSemibold
LogTitle.TextSize = 13
LogTitle.TextXAlignment = Enum.TextXAlignment.Left
LogTitle.Parent = MainFrame

-- Log Frame
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(0.9, 0, 0, 170)
LogFrame.Position = UDim2.new(0.05, 0, 0, 195)
LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 140)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.Parent = MainFrame

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogFrame

local LogList = Instance.new("UIListLayout")
LogList.SortOrder = Enum.SortOrder.LayoutOrder
LogList.Padding = UDim.new(0, 3)
LogList.Parent = LogFrame

-- Update Logs Function
_G.AlliverUpdateLogs = function()
	for _, child in pairs(LogFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	for i, log in ipairs(Logs) do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -10, 0, 16)
		label.BackgroundTransparency = 1
		label.Text = log.Text
		label.TextColor3 = log.Color
		label.Font = Enum.Font.Code
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.LayoutOrder = i
		label.Parent = LogFrame
	end
	
	LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y + 10)
end

-- ====================== MAIN FUNCTIONS ======================
local function GetCharacter()
	local success, result = pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid", 5)
		RootPart = Character:WaitForChild("HumanoidRootPart", 5)
		
		if not Humanoid then
			error("Humanoid not found")
		end
		if not RootPart then
			error("HumanoidRootPart not found")
		end
		
		return true
	end)
	
	if not success then
		AddLog("[ERROR] " .. tostring(result), Color3.fromRGB(255, 90, 90))
		return false
	end
	
	AddLog("[OK] Character obtained", Color3.fromRGB(100, 255, 140))
	return true
end

local function SaveOriginalTransparency(char)
	OriginalTransparencies = {}
	local count = 0
	
	local success, err = pcall(function()
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
				OriginalTransparencies[v] = v.Transparency
				count = count + 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
				OriginalTransparencies[v] = v.Enabled
			end
		end
	end)
	
	if success then
		AddLog("[OK] Saved transparencies: " .. count, Color3.fromRGB(100, 220, 255))
	else
		AddLog("[ERROR] Save failed: " .. tostring(err), Color3.fromRGB(255, 90, 90))
	end
end

local function SetInvisible(char, state)
	local success, err = pcall(function()
		local changed = 0
		
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				if v.Name ~= "HumanoidRootPart" then
					v.Transparency = state and 1 or (OriginalTransparencies[v] or 0)
					changed = changed + 1
				end
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = state and 1 or (OriginalTransparencies[v] or 0)
				changed = changed + 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
				v.Enabled = not state and (OriginalTransparencies[v] ~= false)
			end
		end
		
		-- Face
		local head = char:FindFirstChild("Head")
		if head then
			for _, face in pairs(head:GetChildren()) do
				if face:IsA("Decal") then
					face.Transparency = state and 1 or 0
				end
			end
		end
		
		AddLog(state and ("[OK] Hidden objects: " .. changed) or ("[OK] Restored objects: " .. changed), 
			state and Color3.fromRGB(180, 140, 255) or Color3.fromRGB(100, 255, 160))
	end)
	
	if not success then
		AddLog("[ERROR] SetInvisible: " .. tostring(err), Color3.fromRGB(255, 90, 90))
	end
end

local function ToggleInvisibility()
	AddLog("——— Toggling ———", Color3.fromRGB(140, 140, 180))
	
	if not GetCharacter() then
		AddLog("[FAIL] Could not get character", Color3.fromRGB(255, 80, 80))
		return
	end
	
	Invisible = not Invisible
	
	if Invisible then
		SaveOriginalTransparency(Character)
		SetInvisible(Character, true)
		
		ToggleBtn.Text = "Disable Invisibility"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 30, 70)
		StatusLabel.Text = "Status: On"
		StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 160)
		
		AddLog("[SUCCESS] Invisibility enabled", Color3.fromRGB(100, 255, 160))
	else
		SetInvisible(Character, false)
		
		ToggleBtn.Text = "Enable Invisibility"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
		StatusLabel.Text = "Status: Off"
		StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
		
		AddLog("[SUCCESS] Invisibility disabled", Color3.fromRGB(160, 200, 255))
	end
end

local function CheckEverything()
	AddLog("——— Diagnostics ———", Color3.fromRGB(140, 140, 180))
	
	local ok = GetCharacter()
	if not ok then return end
	
	local parts = 0
	local visibleParts = 0
	
	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			parts = parts + 1
			if v.Transparency < 1 then
				visibleParts = visibleParts + 1
			end
		end
	end
	
	AddLog("Total BaseParts: " .. parts, Color3.fromRGB(200, 200, 220))
	AddLog("Visible parts: " .. visibleParts, visibleParts > 0 and Color3.fromRGB(255, 180, 80) or Color3.fromRGB(100, 255, 140))
	
	if Invisible and visibleParts > 0 then
		AddLog("[WARNING] Visible parts while invisibility is ON!", Color3.fromRGB(255, 140, 60))
	elseif not Invisible and visibleParts == 0 then
		AddLog("[WARNING] All parts hidden while invisibility is OFF", Color3.fromRGB(255, 140, 60))
	else
		AddLog("[OK] State is correct", Color3.fromRGB(100, 255, 160))
	end
end

-- ====================== EVENTS ======================
ToggleBtn.MouseButton1Click:Connect(function()
	local success, err = pcall(ToggleInvisibility)
	if not success then
		AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 60, 60))
	end
end)

ClearBtn.MouseButton1Click:Connect(function()
	ClearLogs()
	AddLog("Logs cleared", Color3.fromRGB(160, 160, 180))
end)

CheckBtn.MouseButton1Click:Connect(function()
	local success, err = pcall(CheckEverything)
	if not success then
		AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 60, 60))
	end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G then
		local success, err = pcall(ToggleInvisibility)
		if not success then
			AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 60, 60))
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
	AddLog("[INFO] Character respawned", Color3.fromRGB(180, 180, 100))
	task.wait(0.8)
	
	if Invisible then
		AddLog("[INFO] Restoring invisibility...", Color3.fromRGB(180, 140, 255))
		GetCharacter()
		SaveOriginalTransparency(Character)
		SetInvisible(Character, true)
	end
end)

-- Start
AddLog("Alliver Hub loaded", Color3.fromRGB(140, 140, 255))
AddLog("Keybind: G | Check button = diagnostics", Color3.fromRGB(140, 140, 180))
GetCharacter()
