-- ═══════════════════════════════════════════════════
-- МОБИЛЬНЫЙ AIM ASSIST (БЕЗ ИСПОЛЬЗОВАНИЯ DRAWING API)
-- ═══════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ожидаем загрузки игрока
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Настройки
local Settings = {
    Enabled = false,
    TeamCheck = false,
    FOV_Radius = 150,
    ShowFOV = true,
    Smoothness = 5,
    AimPart = "Head", -- Head, HumanoidRootPart
    MaxDistance = 500,
}

-- Определяем место для GUI (CoreGui приоритетнее, чтобы не удалялось при смерти)
local ParentGui = nil
pcall(function()
    ParentGui = game:GetService("CoreGui")
end)
if not ParentGui then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Удаляем старую версию, если она была
if ParentGui:FindFirstChild("MobileAimGui") then
    ParentGui:FindFirstChild("MobileAimGui"):Destroy()
end

-- Создаем ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

-- ═══ КРУГ FOV НА ОБЫЧНОМ GUI ═══
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVFrame"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Size = UDim2.new(0, Settings.FOV_Radius * 2, 0, Settings.FOV_Radius * 2)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = Settings.ShowFOV
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.5
FOVStroke.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0) -- Делает квадрат круглым
FOVCorner.Parent = FOVFrame

-- ═══ КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ (ДЛЯ ТЕЛЕФОНА) ═══
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Text = "🎯"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
ToggleButton.ZIndex = 100

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Перетаскивание кнопки открытия
local dragToggleActive = false
local dragToggleStart = nil
local startTogglePos = nil

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggleActive = true
        dragToggleStart = input.Position
        startTogglePos = ToggleButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggleActive and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragToggleStart
        ToggleButton.Position = UDim2.new(
            startTogglePos.X.Scale, startTogglePos.X.Offset + delta.X,
            startTogglePos.Y.Scale, startTogglePos.Y.Offset + delta.Y
        )
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggleActive = false
    end
end)

-- ═══ ГЛАВНОЕ МЕНЮ ═══
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 60, 60)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Заголовок меню
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(1, -50, 1, 0)
HeaderText.Position = UDim2.new(0, 15, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Text = "Aim Assist Menu"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.TextSize = 18
HeaderText.Font = Enum.Font.GothamBold
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.ZIndex = 12
HeaderText.Parent = Header

-- Кнопка закрыть внутри меню
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 13
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Перетаскивание меню
local dragMenuActive = false
local dragMenuStart = nil
local startMenuPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMenuActive = true
        dragMenuStart = input.Position
        startMenuPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragMenuActive and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragMenuStart
        MainFrame.Position = UDim2.new(
            startMenuPos.X.Scale, startMenuPos.X.Offset + delta.X,
            startMenuPos.Y.Scale, startMenuPos.Y.Offset + delta.Y
        )
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMenuActive = false
    end
end)

-- Контент скролл
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -65)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 400)
Content.ZIndex = 12
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- ═══ ФУНКЦИИ ДЛЯ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА ═══

local function CreateToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Frame.ZIndex = 13
    Frame.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 14
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 45, 0, 24)
    Btn.Position = UDim2.new(1, -55, 0.5, -12)
    Btn.BackgroundColor3 = default and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(70, 70, 90)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.ZIndex = 14
    Btn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Btn
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(70, 70, 90)
        Btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Frame.ZIndex = 13
    Frame.Parent = Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 14
    Label.Parent = Frame
    
    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValLabel.Position = UDim2.new(0.7, -10, 0, 5)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    ValLabel.TextSize = 13
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.ZIndex = 14
    ValLabel.Parent = Frame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 6)
    SliderBG.Position = UDim2.new(0, 10, 0, 35)
    SliderBG.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    SliderBG.ZIndex = 14
    SliderBG.Parent = Frame
    
    local SBGCorner = Instance.new("UICorner")
    SBGCorner.CornerRadius = UDim.new(1, 0)
    SBGCorner.Parent = SliderBG
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    SliderFill.ZIndex = 15
    SliderFill.Parent = SliderBG
    
    local SFCorn = Instance.new("UICorner")
    SFCorn.CornerRadius = UDim.new(1, 0)
    SFCorn.Parent = SliderFill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 0)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.ZIndex = 16
    SliderBtn.Parent = SliderBG
    
    local function updateSlider(input)
        local relative = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
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

-- Создаем контролы в меню
CreateToggle("Аим Ассист", Settings.Enabled, function(val)
    Settings.Enabled = val
end)

CreateToggle("Проверка команды", Settings.TeamCheck, function(val)
    Settings.TeamCheck = val
end)

CreateToggle("Показать Круг FOV", Settings.ShowFOV, function(val)
    Settings.ShowFOV = val
    FOVFrame.Visible = val
end)

CreateSlider("Радиус FOV", 30, 300, Settings.FOV_Radius, function(val)
    Settings.FOV_Radius = val
    FOVFrame.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

CreateSlider("Плавность аима", 1, 25, Settings.Smoothness, function(val)
    Settings.Smoothness = val
end)

-- Переключатель Части тела
local BodyBtn = Instance.new("TextButton")
BodyBtn.Size = UDim2.new(1, 0, 0, 40)
BodyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
BodyBtn.Text = "Цель: " .. Settings.AimPart
BodyBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
BodyBtn.TextSize = 14
BodyBtn.Font = Enum.Font.Gotham
BodyBtn.ZIndex = 13
BodyBtn.Parent = Content

local BBCorner = Instance.new("UICorner")
BBCorner.CornerRadius = UDim.new(0, 6)
BBCorner.Parent = BodyBtn

BodyBtn.MouseButton1Click:Connect(function()
    if Settings.AimPart == "Head" then
        Settings.AimPart = "HumanoidRootPart"
    else
        Settings.AimPart = "Head"
    end
    BodyBtn.Text = "Цель: " .. Settings.AimPart
end)


-- Открытие/Закрытие меню по нажатию на кнопку-иконку
local menuOpen = false
local function toggle()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
    if menuOpen then
        ToggleButton.Text = "✕"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    else
        ToggleButton.Text = "🎯"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end
end

ToggleButton.MouseButton1Click:Connect(toggle)
CloseBtn.MouseButton1Click:Connect(function()
    if menuOpen then toggle() end
end)

-- ═══ ЛОГИКА АИМА ═══

local function isAlive(player)
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function isTeammate(player)
    if not Settings.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and not isTeammate(player) then
            local character = player.Character
            local aimPart = character:FindFirstChild(Settings.AimPart)
            
            if aimPart then
                local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
                
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    local distanceToPlayer = (aimPart.Position - Camera.CFrame.Position).Magnitude
                    
                    if distanceToMouse <= Settings.FOV_Radius and distanceToPlayer <= Settings.MaxDistance then
                        if distanceToMouse < shortestDistance then
                            shortestDistance = distanceToMouse
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Основной цикл работы
RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart)
            if aimPart then
                -- Плавное ведение
                local lookAt = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 / Settings.Smoothness)
                FOVStroke.Color = Color3.fromRGB(255, 60, 60) -- Меняем цвет FOV при наведении
                return
            end
        end
    end
    FOVStroke.Color = Color3.fromRGB(255, 255, 255)
end)

print("🎯 Скрипт запущен! Нажмите на иконку мишени слева на экране")
