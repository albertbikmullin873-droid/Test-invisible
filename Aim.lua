-- ============================================
-- AIM SCRIPT С МОБИЛЬНЫМ МЕНЮ
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- НАСТРОЙКИ
-- ============================================
local Settings = {
    AimEnabled = false,
    TeamCheck = false,
    FOV_Radius = 150,
    ShowFOV = true,
    Smoothness = 5,
    AimPart = "Head", -- Head, HumanoidRootPart, UpperTorso
    FOV_Color = Color3.fromRGB(255, 255, 255),
    AimColor = Color3.fromRGB(255, 0, 0),
}

local AimTarget = nil
local MenuOpen = true

-- ============================================
-- СОЗДАНИЕ GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Пытаемся поместить в CoreGui, если не удаётся — в PlayerGui
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================
-- FOV CIRCLE (Drawing API)
-- ============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = Settings.FOV_Radius
FOVCircle.Color = Settings.FOV_Color
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Transparency = 0.8

-- ============================================
-- КНОПКА ОТКРЫТИЯ МЕНЮ (всегда видна)
-- ============================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleMenu"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "⚙"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
ToggleButton.ZIndex = 100
ToggleButton.BackgroundTransparency = 0.2

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 25)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(100, 100, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Перетаскивание кнопки
local draggingToggle = false
local toggleDragStart, toggleStartPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleButton.Position
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingToggle and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - toggleDragStart
        ToggleButton.Position = UDim2.new(
            toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- ГЛАВНОЕ МЕНЮ (ФРЕЙМ)
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = MenuOpen
MainFrame.Parent = ScreenGui
MainFrame.ZIndex = 50
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 200)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Перетаскивание меню
local draggingMenu = false
local menuDragStart, menuStartPos

-- ============================================
-- ЗАГОЛОВОК
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
TitleBar.ZIndex = 51
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

-- Убираем закругление снизу заголовка
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 15)
TitleBarFix.Position = UDim2.new(0, 0, 1, -15)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 51
TitleBarFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "🎯 AIM ASSIST"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 52
TitleLabel.Parent = TitleBar

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "✕"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 52
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Перетаскивание через TitleBar
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = true
        menuDragStart = input.Position
        menuStartPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - menuDragStart
        MainFrame.Position = UDim2.new(
            menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- КОНТЕНТ (СКРОЛЛИНГ)
-- ============================================
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "Content"
ScrollFrame.Size = UDim2.new(1, -10, 1, -55)
ScrollFrame.Position = UDim2.new(0, 5, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.ZIndex = 51
ScrollFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ScrollFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 5)
ContentPadding.PaddingLeft = UDim.new(0, 5)
ContentPadding.PaddingRight = UDim.new(0, 5)
ContentPadding.Parent = ScrollFrame

-- ============================================
-- ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ UI
-- ============================================

-- Создание Toggle (переключатель)
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ToggleFrame.ZIndex = 52
    ToggleFrame.Parent = parent

    local ToggleFrameCorner = Instance.new("UICorner")
    ToggleFrameCorner.CornerRadius = UDim.new(0, 8)
    ToggleFrameCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 53
    Label.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -13)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(80, 80, 80)
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.ZIndex = 53
    ToggleBtn.Parent = ToggleFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 13)
    BtnCorner.Parent = ToggleBtn

    local state = default

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.Text = state and "ON" or "OFF"
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(80, 80, 80)
        if callback then callback(state) end
    end)

    return ToggleFrame
end

-- Создание Slider
local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SliderFrame.ZIndex = 52
    SliderFrame.Parent = parent

    local SliderFrameCorner = Instance.new("UICorner")
    SliderFrameCorner.CornerRadius = UDim.new(0, 8)
    SliderFrameCorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Text = text .. ": " .. tostring(default)
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.Position = UDim2.new(0, 12, 0, 2)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 53
    Label.Parent = SliderFrame

    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -24, 0, 14)
    SliderBG.Position = UDim2.new(0, 12, 0, 34)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SliderBG.ZIndex = 53
    SliderBG.Parent = SliderFrame

    local SliderBGCorner = Instance.new("UICorner")
    SliderBGCorner.CornerRadius = UDim.new(0, 7)
    SliderBGCorner.Parent = SliderBG

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    SliderFill.ZIndex = 54
    SliderFill.Parent = SliderBG

    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 7)
    SliderFillCorner.Parent = SliderFill

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.ZIndex = 55
    SliderButton.Parent = SliderBG

    local sliding = false

    local function updateSlider(inputPos)
        local relativeX = math.clamp((inputPos.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativeX)
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(value)
        if callback then callback(value) end
    end

    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(input.Position)
        end
    end)

    SliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateSlider(input.Position)
        end
    end)

    return SliderFrame
end

-- Создание Dropdown (выбор)
local function CreateDropdown(parent, text, options, default, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, -10, 0, 40)
    DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    DropFrame.ZIndex = 52
    DropFrame.ClipsDescendants = false
    DropFrame.Parent = parent

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 8)
    DropCorner.Parent = DropFrame

    local Label = Instance.new("TextLabel")
    Label.Text = text .. ":"
    Label.Size = UDim2.new(0.5, -5, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 53
    Label.Parent = DropFrame

    local SelectedBtn = Instance.new("TextButton")
    SelectedBtn.Size = UDim2.new(0.45, 0, 0, 28)
    SelectedBtn.Position = UDim2.new(0.52, 0, 0.5, -14)
    SelectedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    SelectedBtn.Text = default .. " ▼"
    SelectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectedBtn.TextSize = 12
    SelectedBtn.Font = Enum.Font.GothamBold
    SelectedBtn.ZIndex = 53
    SelectedBtn.Parent = DropFrame

    local SelCorner = Instance.new("UICorner")
    SelCorner.CornerRadius = UDim.new(0, 6)
    SelCorner.Parent = SelectedBtn

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.new(0.45, 0, 0, #options * 30)
    OptionsFrame.Position = UDim2.new(0.52, 0, 1, 2)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    OptionsFrame.Visible = false
    OptionsFrame.ZIndex = 60
    OptionsFrame.Parent = DropFrame

    local OptCorner = Instance.new("UICorner")
    OptCorner.CornerRadius = UDim.new(0, 6)
    OptCorner.Parent = OptionsFrame

    for i, option in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        OptBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        OptBtn.BackgroundTransparency = 0.3
        OptBtn.Text = option
        OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptBtn.TextSize = 12
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.ZIndex = 61
        OptBtn.Parent = OptionsFrame

        OptBtn.MouseButton1Click:Connect(function()
            SelectedBtn.Text = option .. " ▼"
            OptionsFrame.Visible = false
            if callback then callback(option) end
        end)
    end

    SelectedBtn.MouseButton1Click:Connect(function()
        OptionsFrame.Visible = not OptionsFrame.Visible
    end)

    return DropFrame
end

-- Разделитель
local function CreateSeparator(parent, text)
    local SepFrame = Instance.new("Frame")
    SepFrame.Size = UDim2.new(1, -10, 0, 25)
    SepFrame.BackgroundTransparency = 1
    SepFrame.ZIndex = 52
    SepFrame.Parent = parent

    local SepLabel = Instance.new("TextLabel")
    SepLabel.Text = "━━ " .. text .. " ━━"
    SepLabel.Size = UDim2.new(1, 0, 1, 0)
    SepLabel.BackgroundTransparency = 1
    SepLabel.TextColor3 = Color3.fromRGB(120, 120, 255)
    SepLabel.TextSize = 12
    SepLabel.Font = Enum.Font.GothamBold
    SepLabel.ZIndex = 53
    SepLabel.Parent = SepFrame

    return SepFrame
end

-- ============================================
-- СОЗДАНИЕ ЭЛЕМЕНТОВ МЕНЮ
-- ============================================
CreateSeparator(ScrollFrame, "ОСНОВНЫЕ")

CreateToggle(ScrollFrame, "Aim Assist", Settings.AimEnabled, function(state)
    Settings.AimEnabled = state
end)

CreateToggle(ScrollFrame, "Team Check", Settings.TeamCheck, function(state)
    Settings.TeamCheck = state
end)

CreateToggle(ScrollFrame, "Показать FOV", Settings.ShowFOV, function(state)
    Settings.ShowFOV = state
    FOVCircle.Visible = state
end)

CreateSeparator(ScrollFrame, "НАСТРОЙКИ")

CreateSlider(ScrollFrame, "FOV Радиус", 50, 400, Settings.FOV_Radius, function(value)
    Settings.FOV_Radius = value
    FOVCircle.Radius = value
end)

CreateSlider(ScrollFrame, "Плавность", 1, 20, Settings.Smoothness, function(value)
    Settings.Smoothness = value
end)

CreateDropdown(ScrollFrame, "Aim Part", {"Head", "HumanoidRootPart", "UpperTorso"}, Settings.AimPart, function(option)
    Settings.AimPart = option
end)

CreateSeparator(ScrollFrame, "УПРАВЛЕНИЕ")

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 30)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
StatusLabel.Text = "Статус: Выключен"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.ZIndex = 53
StatusLabel.Parent = ScrollFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

-- Кнопка уничтожения скрипта
local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(1, -10, 0, 35)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
DestroyBtn.Text = "🗑 Удалить скрипт"
DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyBtn.TextSize = 14
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.ZIndex = 53
DestroyBtn.Parent = ScrollFrame

local DestroyCorner = Instance.new("UICorner")
DestroyCorner.CornerRadius = UDim.new(0, 8)
DestroyCorner.Parent = DestroyBtn

-- Обновляем CanvasSize
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)

-- ============================================
-- ЛОГИКА ПЕРЕКЛЮЧЕНИЯ МЕНЮ
-- ============================================
local function ToggleMenu()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
    ToggleButton.Text = MenuOpen and "✕" or "⚙"
    ToggleButton.BackgroundColor3 = MenuOpen and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(30, 30, 30)
end

ToggleButton.MouseButton1Click:Connect(ToggleMenu)
CloseButton.MouseButton1Click:Connect(ToggleMenu)

-- ============================================
-- AIM ЛОГИКА
-- ============================================
local function IsAlive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    if LocalPlayer.Team and player.Team and 
