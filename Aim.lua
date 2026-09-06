-- ════════════════════════════
-- РАБОЧИЙ AIM SCRIPT ДЛЯ DELTA MOBILE
-- ════════════════════════════

-- ✅ ОЖИДАЕМ ПОЛНОЙ ЗАГРУЗКИ ИГРЫ
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character
repeat task.wait() until workspace.CurrentCamera

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ═══ НАСТРОЙКИ ═══
local Settings = {
    Enabled = false,
    TeamCheck = false,
    FOV_Radius = 150,
    ShowFOV = true,
    Smoothness = 5,
    AimPart = "Head",
    MaxDistance = 500,
}

-- ═══ СОЗДАЕМ GUI В PLAYERGUI (РАБОТАЕТ В DELTA) ═══
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimAssistGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ═══ КНОПКА ОТКРЫТИЯ МЕНЮ ═══
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleMenu"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "🎯"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- ═══ FOV КРУГ (БЕЗ DRAWING API) ═══
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVFrame"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Size = UDim2.new(0, Settings.FOV_Radius * 2, 0, Settings.FOV_Radius * 2)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = Settings.ShowFOV
FOVFrame.Parent = ScreenGui

local FOVCircle = Instance.new("UIStroke")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

-- ═══ ГЛАВНОЕ МЕНЮ ═══
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- ═══ ЗАГОЛОВОК ═══
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "AIM ASSIST"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

-- ═══ СКРОЛЛ КОНТЕНТ ═══
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "Content"
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
ScrollFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = ScrollFrame

-- ═══ ФУНКЦИИ ДЛЯ ЭЛЕМЕНТОВ ═══
local function CreateToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScrollFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(60, 60, 80)
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn

    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(60, 60, 80)
        ToggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScrollFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValLabel.Position = UDim2.new(0.7, -10, 0, 5)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    ValLabel.TextSize = 13
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = Frame

    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 8)
    SliderBG.Position = UDim2.new(0, 10, 0, 35)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Frame

    local SBGCorner = Instance.new("UICorner")
    SBGCorner.CornerRadius = UDim.new(1, 0)
    SBGCorner.Parent = SliderBG

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG

    local SFCorner = Instance.new("UICorner")
    SFCorner.CornerRadius = UDim.new(1, 0)
    SFCorner.Parent = SliderFill

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 0)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBG

    local function updateSlider(input)
        if not SliderBG or not SliderBG.Parent then return end
        local absPos = SliderBG.AbsolutePosition.X
        local absSize = SliderBG.AbsoluteSize.X
        local relative = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
        local value = math.floor(min + (max - min) * relative)
        SliderFill.Size = UDim2.new(relative, 0, 1, 0)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    local isDragging = false
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateSlider(input)
        end
    end)

    SliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end

-- ═══ СОЗДАЕМ ЭЛЕМЕНТЫ МЕНЮ ═══
CreateToggle("Аим Ассист", Settings.Enabled, function(val)
    Settings.Enabled = val
end)

CreateToggle("Проверка команды", Settings.TeamCheck, function(val)
    Settings.TeamCheck = val
end)

CreateToggle("Показать FOV", Settings.ShowFOV, function(val)
    Settings.ShowFOV = val
    FOVFrame.Visible = val
end)

CreateSlider("Радиус FOV", 30, 300, Settings.FOV_Radius, function(val)
    Settings.FOV_Radius = val
    FOVFrame.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

CreateSlider("Плавность", 1, 20, Settings.Smoothness, function(val)
    Settings.Smoothness = val
end)

CreateSlider("Макс. дистанция", 50, 2000, Settings.MaxDistance, function(val)
    Settings.MaxDistance = val
end)

-- ═══ ПЕРЕТАСКИВАНИЕ МЕНЮ ═══
local draggingMenu = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ═══ ОТКРЫТИЕ/ЗАКРЫТИЕ МЕНЮ ═══
local menuOpen = false
local function toggleMenu()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
    ToggleButton.Text = menuOpen and "✕" or "🎯"
    ToggleButton.BackgroundColor3 = menuOpen and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(255, 50, 50)
end

ToggleButton.MouseButton1Click:Connect(toggleMenu)
CloseButton.MouseButton1Click:Connect(toggleMenu)

-- ═══ ЛОГИКА АИМА ═══
local function isAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function isTeammate(player)
    if not Settings.TeamCheck then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function getClosestPlayer()
    if not Camera then return nil end

    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and not isTeammate(player) then
            local character = player.Character
            if character then
                local aimPart = character:FindFirstChild(Settings.AimPart) or character:FindFirstChild("HumanoidRootPart")
                if aimPart then
                    local screenPos, onScreen = pcall(function()
                        return Camera:WorldToScreenPoint(aimPart.Position)
                    end)

                    if onScreen and screenPos then
                        local distance2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local distance3D = (aimPart.Position - Camera.CFrame.Position).Magnitude

                        if distance2D <= Settings.FOV_Radius and distance3D <= Settings.MaxDistance then
                            if distance2D < shortestDistance then
                                shortestDistance = distance2D
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- ═══ ГЛАВНЫЙ ЦИКЛ ═══
RunService.RenderStepped:Connect(function()
    -- Обновляем FOV
    if FOVFrame then
        FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        FOVFrame.Size = UDim2.new(0, Settings.FOV_Radius * 2, 0, Settings.FOV_Radius * 2)
        FOVFrame.Visible = Settings.ShowFOV
    end

    if Settings.Enabled and Camera then
        local target = getClosestPlayer()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Settings.Smoothness)
                if FOVCircle then
                    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
                end
                return
            end
        end
    end

    if FOVCircle then
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    end
end)

-- ═══ СООБЩЕНИЕ О ЗАПУСКЕ ═══
print("✅ AIM SCRIPT ЗАПУЩЕН!")
print("📱 Нажмите на красную кнопку 🎯 для открытия меню")
