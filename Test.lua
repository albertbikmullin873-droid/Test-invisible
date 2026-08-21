-- Alliver Hub | True Invisibility (others can't see you)
-- English version + Debug

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character, Humanoid, RootPart
local Invisible = false
local OriginalParent = nil
local Connection = nil
local BodyVelocity = nil

local Logs = {}
local MaxLogs = 14

-- ====================== LOG SYSTEM ======================
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
MainFrame.Size = UDim2.new(0, 330, 0, 400)
MainFrame.Position = UDim2.new(0.5, -165, 0.35, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(100, 90, 255)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.3

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -20, 0, 34)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Alliver Hub"
Title.TextColor3 = Color3.fromRGB(170, 170, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", MainFrame)
SubTitle.Size = UDim2.new(1, -20, 0, 18)
SubTitle.Position = UDim2.new(0, 10, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "True Invisibility (Server Hidden)"
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 165)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 42)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 62)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
ToggleBtn.Text = "Enable Invisibility"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 15
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 112)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Off"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ClearBtn = Instance.new("TextButton", MainFrame)
ClearBtn.Size = UDim2.new(0.42, 0, 0, 28)
ClearBtn.Position = UDim2.new(0.05, 0, 0, 142)
ClearBtn.BackgroundColor3 = Color3.fromRGB(40, 28, 48)
ClearBtn.Text = "Clear Logs"
ClearBtn.TextColor3 = Color3.fromRGB(200, 180, 220)
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.TextSize = 12
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

local CheckBtn = Instance.new("TextButton", MainFrame)
CheckBtn.Size = UDim2.new(0.42, 0, 0, 28)
CheckBtn.Position = UDim2.new(0.53, 0, 0, 142)
CheckBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 52)
CheckBtn.Text = "Check"
CheckBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
CheckBtn.Font = Enum.Font.Gotham
CheckBtn.TextSize = 12
Instance.new("UICorner", CheckBtn).CornerRadius = UDim.new(0, 6)

local LogTitle = Instance.new("TextLabel", MainFrame)
LogTitle.Size = UDim2.new(1, -20, 0, 20)
LogTitle.Position = UDim2.new(0, 10, 0, 180)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "Logs / Errors:"
LogTitle.TextColor3 = Color3.fromRGB(150, 150, 190)
LogTitle.Font = Enum.Font.GothamSemibold
LogTitle.TextSize = 13
LogTitle.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Size = UDim2.new(0.9, 0, 0, 185)
LogFrame.Position = UDim2.new(0.05, 0, 0, 202)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 150)
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

-- ====================== CORE FUNCTIONS ======================
local function GetCharacter()
	local success, err = pcall(function()
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid", 4)
		RootPart = Character:WaitForChild("HumanoidRootPart", 4)
		if not Humanoid or not RootPart then
			error("Humanoid or RootPart missing")
		end
	end)
	if not success then
		AddLog("[ERROR] " .. tostring(err), Color3.fromRGB(255, 90, 90))
		return false
	end
	AddLog("[OK] Character ready", Color3.fromRGB(100, 255, 140))
	return true
end

local function EnableInvisibility()
	if not GetCharacter() then return false end

	local success, err = pcall(function()
		OriginalParent = Character.Parent

		-- Remove character from Workspace → stops replication to other players
		Character.Parent = nil

		-- Create BodyVelocity so we can still move
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.Parent = RootPart

		-- Movement loop
		Connection = RunService.Heartbeat:Connect(function()
			if not RootPart or not RootPart.Parent then return end

			local moveDir = Humanoid.MoveDirection
			local speed = Humanoid.WalkSpeed

			if moveDir.Magnitude > 0 then
				BodyVelocity.Velocity = moveDir * speed
			else
				BodyVelocity.Velocity = Vector3.zero
			end

			-- Keep upright
			RootPart.CFrame = CFrame.new(RootPart.Position, RootPart.Position + Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
		end)

		-- Hide all visual parts just in case
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
				v.CanCollide = false
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			end
		end
	end)

	if not success then
		AddLog("[ERROR] Enable failed: " .. tostring(err), Color3.fromRGB(255, 80, 80))
		return false
	end

	AddLog("[SUCCESS] Character removed from Workspace", Color3.fromRGB(100, 255, 160))
	AddLog("Other players should no longer see you", Color3.fromRGB(180, 140, 255))
	return true
end

local function DisableInvisibility()
	local success, err = pcall(function()
		if Connection then
			Connection:Disconnect()
			Connection = nil
		end
		if BodyVelocity then
			BodyVelocity:Destroy()
			BodyVelocity = nil
		end

		if Character and OriginalParent then
			Character.Parent = OriginalParent
		end

		-- Restore visuals
		if Character then
			for _, v in pairs(Character:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
					v.Transparency = 0
					v.CanCollide = true
				elseif v:IsA("Decal") or v:IsA("Texture") then
					v.Transparency = 0
				end
			end
		end
	end)

	if not success then
		AddLog("[ERROR] Disable failed: " .. tostring(err), Color3.fromRGB(255, 80, 80))
		return false
	end

	AddLog("[SUCCESS] Character restored", Color3.fromRGB(160, 200, 255))
	return true
end

local function ToggleInvisibility()
	AddLog("——— Toggling ———", Color3.fromRGB(140, 140, 180))

	if not Invisible then
		if EnableInvisibility() then
			Invisible = true
			ToggleBtn.Text = "Disable Invisibility"
			ToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 28, 70)
			StatusLabel.Text = "Status: On (Hidden from others)"
			StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 160)
		end
	else
		if DisableInvisibility() then
			Invisible = false
			ToggleBtn.Text = "Enable Invisibility"
			ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
			StatusLabel.Text = "Status: Off"
			StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
		end
	end
end

local function CheckEverything()
	AddLog("——— Diagnostics ———", Color3.fromRGB(140, 140, 180))
	if not GetCharacter() then return end

	AddLog("Character Parent: " .. tostring(Character.Parent), Color3.fromRGB(200, 200, 220))
	AddLog("Invisible flag: " .. tostring(Invisible), Color3.fromRGB(200, 200, 220))

	if Invisible and Character.Parent == nil then
		AddLog("[OK] Character is removed → others should not see you", Color3.fromRGB(100, 255, 160))
	elseif Invisible and Character.Parent ~= nil then
		AddLog("[WARNING] Invisible flag is true but character is still in Workspace!", Color3.fromRGB(255, 140, 60))
	else
		AddLog("[OK] Normal state", Color3.fromRGB(100, 255, 160))
	end
end

-- ====================== EVENTS ======================
ToggleBtn.MouseButton1Click:Connect(function()
	local ok, err = pcall(ToggleInvisibility)
	if not ok then AddLog("[CRITICAL] " .. tostring(err), Color3.fromRGB(255, 50, 50)) end
end)

ClearBtn.MouseButton1Click:Connect(function()
	ClearLogs()
	AddLog("Logs cleared", Color3.fromRGB(160, 160, 180))
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
	AddLog("[INFO] Character respawned", Color3.fromRGB(180, 180, 100))
	Invisible = false
	if Connection then Connection:Disconnect() Connection = nil end
	if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
	ToggleBtn.Text = "Enable Invisibility"
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
	StatusLabel.Text = "Status: Off"
	StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
end)

-- Start
AddLog("Alliver Hub loaded", Color3.fromRGB(140, 140, 255))
AddLog("Keybind: G", Color3.fromRGB(140, 140, 180))
AddLog("This version removes character from Workspace", Color3.fromRGB(180, 140, 255))
GetCharacter()
