local success, err = pcall(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    local parent = CoreGui
    if not pcall(function() return CoreGui:GetChildren() end) then
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local BASE_WIDTH = 420
    local BASE_HEIGHT = 270 

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomMenuWithHeader"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Active = true
    MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local MenuScale = Instance.new("UIScale", MainFrame)
    
    local currentScalePercent = 30  
    local currentLengthPercent = 25 
    local currentWidthPercent = 35  
    local isMinimized = false
    local currentLanguage = "Русский"
    local currentTab = "Settings" 

    local DEFAULT_SPEED = 16
    local DEFAULT_JUMP = 50
    local DEFAULT_GRAVITY = 196.2
    
    -- Состояния функций
    local antiSitEnabled = false
    local antiAfkEnabled = false
    local infJumpEnabled = false
    local swimModeEnabled = false
    local noclipEnabled = false
    local shiftLockEnabled = false
    local isInvisible = false
    local isSpaceActive = false
    local autoUnbanEnabled = false

    local Camera = Workspace.CurrentCamera

    -------------------------------------------------------
    -- ТАБЛИЦА ЛОКАЛИЗАЦИИ
    -------------------------------------------------------
    local Localization = {
        ["English"] = {
            LangLabel = "Language", Interface = "Interface", Size = "Size", Length = "Length", Width = "Width",
            DevsTitle = "Developers", Settings = "Settings", Support = "Support", GameTab = "Game",
            WalkSpeed = "WalkSpeed", JumpPower = "JumpPower", Gravity = "Gravity", ResetBtn = "Reset",
            InvisibleText = "Invisible", ToolBtn = "Menu UI", AntiSit = "Anti-Sit", AntiAFK = "Anti-AFK",
            InfJump = "Infinite Jump", SwimMode = "Swim Mode", Noclip = "Noclip", GravZero = "Space Gravity", 
            ShiftLock = "Shift Lock", AutoUnban = "Auto Unban", SitBtn = "Sit Menu", FlyBtn = "Fly Menu", 
            SitAction = "Sit Now", FOVText = "Field of View",
            DevsText = "Design: Won4sko\n\nCoding: Won4sko\n\nFeatures: Won4sko, Gemini, DeepSeek.",
            NothingHere = "Nothing here..", SelectGameText = "Select a game..."
        },
        ["Русский"] = {
            LangLabel = "Язык", Interface = "Интерфейс", Size = "Размер", Length = "Длина", Width = "Ширина",
            DevsTitle = "Разработчики", Settings = "Настройки", Support = "Поддержка", GameTab = "Игра",
            WalkSpeed = "Скорость бега", JumpPower = "Сила прыжка", Gravity = "Гравитация", ResetBtn = "Сброс",
            InvisibleText = "Невидимость", ToolBtn = "Менюшка", AntiSit = "Анти-сидеть", AntiAFK = "Анти-АФК",
            InfJump = "Бесконечный прыжок", SwimMode = "Плавать", Noclip = "Ноклип", GravZero = "Космическая Гравитация", 
            ShiftLock = "Блокировка Шифт", AutoUnban = "Авто Разбан (Дома)", SitBtn = "Сидеть", FlyBtn = "Летать", 
            SitAction = "Нажмите, чтобы сесть", FOVText = "Поле зрения (FOV)",
            DevsText = "Дизайн: Won4sko\n\nКодинг: Won4sko\n\nФункции: Won4sko, Gemini, DeepSeek.",
            NothingHere = "Тут ничего нету..", SelectGameText = "Выберите игру..."
        },
        ["العربية"] = {
            LangLabel = "اللغة", Interface = "الواجهة", Size = "الحجم", Length = "الطول", Width = "العرض",
            DevsTitle = "المطورين", Settings = "الإعدادات", Support = "الدعم", GameTab = "لعبة",
            WalkSpeed = "سرعة المشي", JumpPower = "قوة القفز", Gravity = "الجاذبية", ResetBtn = "إعادة",
            InvisibleText = "Оلاقتفاء", ToolBtn = "قائمة", AntiSit = "منع الجلوس", AntiAFK = "ضд الأفلاق",
            InfJump = "قفز لا نهائي", SwimMode = "وضع السباحة", Noclip = "اختراق الجدران", GravZero = "جاذبية الفضاء", 
            ShiftLock = "قفل التحويل", AutoUnban = "إلغاء الحظر التلقائي", SitBtn = "جلوس", FlyBtn = "طيران", 
            SitAction = "اضغط للجلوس", FOVText = "مجال الرؤية",
            DevsText = "Won4sko :التصميم\n\nWon4sko :البرمجة\n\nWon4sko, Gemini, DeepSeek. :الميزات",
            NothingHere = "لا يوجد شيء هنا..", SelectGameText = "اختر لعبة..."
        },
        ["Español"] = {
            LangLabel = "Idioma", Interface = "Interfaz", Size = "Tamaño", Length = "Longitud", Width = "Ancho",
            DevsTitle = "Devs", Settings = "Ajustes", Support = "Soporte", GameTab = "Juego",
            WalkSpeed = "Velocidad", JumpPower = "Fuerza de Salto", Gravity = "Gravedad", ResetBtn = "Reiniciar",
            InvisibleText = "Invisibilidad", ToolBtn = "Menú UI", AntiSit = "Anti-Asiento", AntiAFK = "Anti-AFK",
            InfJump = "Salto Infinito", SwimMode = "Modo Nadar", Noclip = "Noclip", GravZero = "Gravedad Espacial", 
            ShiftLock = "Shift Lock", AutoUnban = "Auto Desbanear", SitBtn = "Sentarse", FlyBtn = "Volar", 
            SitAction = "Haz clic para sentarte", FOVText = "Campo de Visión",
            DevsText = "Diseño: Won4sko\n\nCódigo: Won4sko\n\nFunciones: Won4sko, Gemini, DeepSeek.",
            NothingHere = "No hay nada aquí..", SelectGameText = "Selecciona un juego..."
        }
    }

    -------------------------------------------------------
    -- УПРАВЛЕНИЕ НЕВИДИМОСТЬЮ И ЦИКЛАМИ
    -------------------------------------------------------
    local function UpdateCharacterTransparency(char, value)
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") then
                if obj.Name ~= "HumanoidRootPart" then
                    obj.Transparency = value
                end
            end
        end
    end

    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if antiAfkEnabled then
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end
        end)
    end)

    local MobileShiftLockBtn = Instance.new("TextButton", ScreenGui)
    MobileShiftLockBtn.Name = "MobileShiftLockBtn"
    MobileShiftLockBtn.Size = UDim2.new(0, 55, 0, 55)
    MobileShiftLockBtn.Position = UDim2.new(0.85, 0, 0.7, 0)
    MobileShiftLockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MobileShiftLockBtn.BackgroundTransparency = 0.2
    MobileShiftLockBtn.Text = ""
    MobileShiftLockBtn.Visible = false
    Instance.new("UICorner", MobileShiftLockBtn).CornerRadius = UDim.new(1, 0)
    local SLStroke = Instance.new("UIStroke", MobileShiftLockBtn)
    SLStroke.Color = Color3.fromRGB(255, 255, 255)
    SLStroke.Thickness = 1.5

    local InnerCircle = Instance.new("Frame", MobileShiftLockBtn)
    InnerCircle.Size = UDim2.new(0, 18, 0, 18)
    InnerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", InnerCircle).CornerRadius = UDim.new(1, 0)

    local LeftLine = Instance.new("Frame", MobileShiftLockBtn)
    LeftLine.Size = UDim2.new(0, 8, 0, 3)
    LeftLine.Position = UDim2.new(0.5, -16, 0.5, 0)
    LeftLine.AnchorPoint = Vector2.new(1, 0.5)
    LeftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LeftLine.BorderSizePixel = 0

    local RightLine = Instance.new("Frame", MobileShiftLockBtn)
    RightLine.Size = UDim2.new(0, 8, 0, 3)
    RightLine.Position = UDim2.new(0.5, 16, 0.5, 0)
    RightLine.AnchorPoint = Vector2.new(0, 0.5)
    RightLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RightLine.BorderSizePixel = 0

    MobileShiftLockBtn.Activated:Connect(function()
        shiftLockEnabled = not shiftLockEnabled
        if shiftLockEnabled then
            MobileShiftLockBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            InnerCircle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            LeftLine.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            RightLine.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        else
            MobileShiftLockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            InnerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LeftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            RightLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)

    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if antiSitEnabled then
                    hum.Sit = false
                    if hum:GetStateEnabled(Enum.HumanoidStateType.Seated) then
                        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                    end
                else
                    if not hum:GetStateEnabled(Enum.HumanoidStateType.Seated) then
                        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                    end
                end
            end

            if swimModeEnabled and hum then
                hum:ChangeState(Enum.HumanoidStateType.Swimming)
            end

            if noclipEnabled then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end

            if isSpaceActive and hum then
                if hum.MoveDirection.Magnitude > 0 then
                    Workspace.Gravity = 25 
                else
                    Workspace.Gravity = DEFAULT_GRAVITY 
                end
            end

            if autoUnbanEnabled then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name:lower():find("banlist") or v.Name:lower():find("bannedplayers") then
                        local pInst = v:FindFirstChild(LocalPlayer.Name) or v:FindFirstChild(tostring(LocalPlayer.UserId))
                        if pInst then pInst:Destroy() end
                    end
                end
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if shiftLockEnabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                local lookVector = Camera.CFrame.LookVector
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    local function UpdateGeometry()
        if isMinimized then return end
        local widthModifier = 1 + ((currentWidthPercent - 35) / 100)
        local finalWidth = BASE_WIDTH * math.clamp(widthModifier, 0.8, 2.0)
        local lengthModifier = 1 + ((currentLengthPercent - 25) / 100)
        local finalHeight = BASE_HEIGHT * math.clamp(lengthModifier, 0.8, 2.0)
        
        MainFrame.Size = UDim2.new(0, finalWidth, 0, finalHeight)
        local baseScale = 1.0
        local scaleModifier = (currentScalePercent - 30) / 70 
        MenuScale.Scale = math.clamp(baseScale + (scaleModifier * 0.8), 0.6, 1.8)
    end

    -- ШАПКА
    local Header = Instance.new("Frame", MainFrame)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, -12, 0, 32)
    Header.Position = UDim2.new(0, 6, 0, 6)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Header.ZIndex = 2

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NexusHUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -28, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 12
    CloseBtn.ZIndex = 4
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

    local MinimizeBtn = Instance.new("TextButton", Header)
    MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeBtn.Font = Enum.Font.SourceSansBold
    MinimizeBtn.TextSize = 10
    MinimizeBtn.ZIndex = 4
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)

    -- ЛЕВАЯ ПАНЕЛЬ С СКРОЛЛОМ
    local SideTab = Instance.new("ScrollingFrame", MainFrame)
    SideTab.Name = "SideTab"
    SideTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SideTab.Position = UDim2.new(0, 6, 0, 44)
    SideTab.Size = UDim2.new(0, 110, 1, -50)
    SideTab.ScrollBarThickness = 2
    SideTab.BorderSizePixel = 0
    SideTab.ZIndex = 2
    Instance.new("UICorner", SideTab).CornerRadius = UDim.new(0, 8)
    
    local SideLayout = Instance.new("UIListLayout", SideTab)
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function CreateMenuTabButton(name, layoutOrder)
        local Btn = Instance.new("TextButton", SideTab)
        Btn.Size = UDim2.new(1, -10, 0, 28)
        Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Btn.Text = name
        Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 12
        Btn.LayoutOrder = layoutOrder
        Btn.ZIndex = 3
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        return Btn
    end

    -- ВКЛАДКИ НА ЛЕВОЙ ПАНЕЛИ
    local SettingsButton = CreateMenuTabButton("Settings", 1)
    local SupportButton = CreateMenuTabButton("Support", 2)
    local GameButton = CreateMenuTabButton("Game", 3)

    SettingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- ЦЕНТРАЛЬНЫЕ ОКНА СКРОЛЛА
    local CentralFrames = {}
    local function CreateCentralScroll(name)
        local Scf = Instance.new("ScrollingFrame", MainFrame)
        Scf.Name = name .. "Scroll"
        Scf.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Scf.Position = UDim2.new(0, 122, 0, 44)
        Scf.Size = UDim2.new(1, -128, 1, -50)
        Scf.ScrollBarThickness = 4 
        Scf.BorderSizePixel = 0
        Scf.Visible = false
        Scf.ZIndex = 2
        Instance.new("UICorner", Scf).CornerRadius = UDim.new(0, 8)
        CentralFrames[name] = Scf
        return Scf
    end

    local GreyFrame = CreateCentralScroll("Settings")
    GreyFrame.Visible = true
    local SupportFrame = CreateCentralScroll("Support")
    local GameFrame = CreateCentralScroll("Game")

    local DevelopersBlock = Instance.new("Frame", GreyFrame) 

    -------------------------------------------------------
    -- НАСТРОЙКА ВКЛАДКИ ПОДДЕРЖКА (SupportFrame)
    -------------------------------------------------------
    local SupportTextLabel = Instance.new("TextLabel", SupportFrame)
    SupportTextLabel.Size = UDim2.new(1, 0, 1, 0)
    SupportTextLabel.BackgroundTransparency = 1
    SupportTextLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
    SupportTextLabel.Font = Enum.Font.SourceSansItalic
    SupportTextLabel.TextSize = 15
    SupportTextLabel.TextAlignment = Enum.TextAlignment.Center
    SupportTextLabel.ZIndex = 3

    -------------------------------------------------------
    -- НАСТРОЙКА ВКЛАДКИ ИГРА (GameFrame)
    -------------------------------------------------------
    local GameCenterBlock = Instance.new("Frame", GameFrame)
    GameCenterBlock.Size = UDim2.new(1, -20, 0, 100)
    GameCenterBlock.Position = UDim2.new(0, 10, 0.5, -50)
    GameCenterBlock.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    GameCenterBlock.ZIndex = 3
    Instance.new("UICorner", GameCenterBlock).CornerRadius = UDim.new(0, 14)
    local GameBlockStroke = Instance.new("UIStroke", GameCenterBlock)
    GameBlockStroke.Color = Color3.fromRGB(50, 50, 50)
    GameBlockStroke.Thickness = 1

    local GameIconLabel = Instance.new("TextLabel", GameCenterBlock)
    GameIconLabel.Size = UDim2.new(1, 0, 0, 40)
    GameIconLabel.Position = UDim2.new(0, 0, 0, 15)
    GameIconLabel.BackgroundTransparency = 1
    GameIconLabel.Text = "🎮"
    GameIconLabel.TextSize = 30
    GameIconLabel.ZIndex = 4

    local GameSelectLabel = Instance.new("TextLabel", GameCenterBlock)
    GameSelectLabel.Size = UDim2.new(1, 0, 0, 25)
    GameSelectLabel.Position = UDim2.new(0, 0, 0, 60)
    GameSelectLabel.BackgroundTransparency = 1
    GameSelectLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    GameSelectLabel.Font = Enum.Font.SourceSansBold
    GameSelectLabel.TextSize = 14
    GameSelectLabel.ZIndex = 4

    -------------------------------------------------------
    -- НАСТРОЙКА ВКЛАДКИ НАСТРОЕК (GreyFrame)
    -------------------------------------------------------
    local LanguageLabel = Instance.new("TextLabel", GreyFrame)
    LanguageLabel.Size = UDim2.new(1, 0, 0, 22)
    LanguageLabel.Position = UDim2.new(0, 0, 0, 10)
    LanguageLabel.BackgroundTransparency = 1
    LanguageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    LanguageLabel.Font = Enum.Font.SourceSansBold
    LanguageLabel.TextSize = 16
    LanguageLabel.ZIndex = 3

    local SeparatorLine1 = Instance.new("Frame", GreyFrame)
    SeparatorLine1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine1.Position = UDim2.new(0, 0, 0, 34)
    SeparatorLine1.Size = UDim2.new(1, 0, 0, 2)
    SeparatorLine1.ZIndex = 3

    local DropdownBtn1 = Instance.new("TextButton", GreyFrame)
    DropdownBtn1.Size = UDim2.new(1, -16, 0, 32) 
    DropdownBtn1.Position = UDim2.new(0, 6, 0, 44)
    DropdownBtn1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownBtn1.Text = "" 
    DropdownBtn1.ZIndex = 4
    Instance.new("UICorner", DropdownBtn1).CornerRadius = UDim.new(0, 16)

    local CurrentLangText = Instance.new("TextLabel", DropdownBtn1)
    CurrentLangText.Size = UDim2.new(1, -30, 1, 0)
    CurrentLangText.Position = UDim2.new(0, 14, 0, 0)
    CurrentLangText.BackgroundTransparency = 1
    CurrentLangText.Text = currentLanguage
    CurrentLangText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurrentLangText.Font = Enum.Font.SourceSansBold
    CurrentLangText.TextSize = 13
    CurrentLangText.TextXAlignment = Enum.TextXAlignment.Left
    CurrentLangText.ZIndex = 5

    local ArrowIcon1 = Instance.new("TextLabel", DropdownBtn1)
    ArrowIcon1.Size = UDim2.new(0, 12, 0, 12)
    ArrowIcon1.BackgroundTransparency = 1
    ArrowIcon1.Text = "▼"
    ArrowIcon1.TextColor3 = Color3.fromRGB(200, 200, 200)
    ArrowIcon1.Font = Enum.Font.SourceSansBold
    ArrowIcon1.TextSize = 10
    ArrowIcon1.Position = UDim2.new(1, -16, 0.5, -6)
    ArrowIcon1.ZIndex = 5

    local DropdownContainer1 = Instance.new("Frame", GreyFrame)
    DropdownContainer1.Size = UDim2.new(1, -16, 0, 0) 
    DropdownContainer1.Position = UDim2.new(0, 6, 0, 82)
    DropdownContainer1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownContainer1.Visible = false
    DropdownContainer1.ZIndex = 12
    DropdownContainer1.ClipsDescendants = true
    Instance.new("UICorner", DropdownContainer1).CornerRadius = UDim.new(0, 10)

    local SeparatorLine2Left = Instance.new("Frame", GreyFrame)
    SeparatorLine2Left.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine2Left.Size = UDim2.new(0.5, -45, 0, 2)
    SeparatorLine2Left.ZIndex = 3
    local SeparatorLine2Right = Instance.new("Frame", GreyFrame)
    SeparatorLine2Right.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine2Right.Size = UDim2.new(0.5, -45, 0, 2)
    SeparatorLine2Right.ZIndex = 3

    local GeometryLabel = Instance.new("TextLabel", GreyFrame)
    GeometryLabel.Size = UDim2.new(0, 90, 0, 20)
    GeometryLabel.BackgroundTransparency = 1
    GeometryLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    GeometryLabel.Font = Enum.Font.SourceSansBold
    GeometryLabel.TextSize = 13 
    GeometryLabel.ZIndex = 3

    local sliders = {}
    local activeInputs = {}
    local sliderPercentages = {Size = 30, Length = 25, Width = 35}
    local sliderNames = {Size = "Size", Length = "Length", Width = "Width"}

    local function CreateGeometrySlider(sliderType)
        local SliderContainer = Instance.new("Frame", GreyFrame)
        SliderContainer.Size = UDim2.new(1, -12, 0, 26)
        SliderContainer.BackgroundTransparency = 1 
        SliderContainer.ZIndex = 4

        local Track = Instance.new("TextButton", SliderContainer)
        Track.Size = UDim2.new(1, -100, 0, 10) 
        Track.Position = UDim2.new(0, 4, 0.5, -5)
        Track.BackgroundTransparency = 1 
        Track.Text = ""
        Track.ZIndex = 5

        local VisualLine = Instance.new("Frame", Track)
        VisualLine.Size = UDim2.new(1, 0, 0, 4)
        VisualLine.Position = UDim2.new(0, 0, 0.5, -2)
        VisualLine.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        VisualLine.ZIndex = 5
        Instance.new("UICorner", VisualLine).CornerRadius = UDim.new(0, 2)

        local Progress = Instance.new("Frame", VisualLine)
        Progress.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
        Progress.ZIndex = 6
        Instance.new("UICorner", Progress).CornerRadius = UDim.new(0, 2)

        local Knob = Instance.new("Frame", Track)
        Knob.Size = UDim2.new(0, 12, 0, 12)
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Knob.ZIndex = 7
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local StatusLabel = Instance.new("TextLabel", SliderContainer)
        StatusLabel.Size = UDim2.new(0, 85, 1, 0)
        StatusLabel.Position = UDim2.new(1, -80, 0, 0) 
        StatusLabel.BackgroundTransparency = 1
        StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        StatusLabel.Font = Enum.Font.SourceSansBold
        StatusLabel.TextSize = 12
        StatusLabel.ZIndex = 5

        local function ProcessInput(input)
            local clickX = input.Position.X - Track.AbsolutePosition.X
            local percentage = math.clamp(clickX / Track.AbsoluteSize.X, 0, 1)
            sliderPercentages[sliderType] = math.floor(percentage * 100)
            
            if sliderType == "Size" then currentScalePercent = sliderPercentages.Size
            elseif sliderType == "Length" then currentLengthPercent = sliderPercentages.Length
            elseif sliderType == "Width" then currentWidthPercent = sliderPercentages.Width
            end
            
            UpdateGeometry()
            local ratio = math.clamp(sliderPercentages[sliderType] / 100, 0, 1)
            Progress.Size = UDim2.new(ratio, 0, 1, 0)
            Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            local localizedName = Localization[currentLanguage][sliderType] or sliderNames[sliderType]
            StatusLabel.Text = localizedName .. ": " .. sliderPercentages[sliderType] .. "%"
        end

        Track.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not activeInputs[input] then
                activeInputs[input] = true
                ProcessInput(input)
                local moveCon, endCon
                moveCon = UserInputService.InputChanged:Connect(function(change)
                    if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then ProcessInput(change) end
                end)
                endCon = UserInputService.InputEnded:Connect(function(ended)
                    if ended == input then activeInputs[input] = nil moveCon:Disconnect() endCon:Disconnect() end
                end)
            end
        end)
        table.insert(sliders, {Container = SliderContainer, Refresh = function()
            local ratio = math.clamp(sliderPercentages[sliderType] / 100, 0, 1)
            Progress.Size = UDim2.new(ratio, 0, 1, 0)
            Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            StatusLabel.Text = (Localization[currentLanguage][sliderType] or sliderNames[sliderType]) .. ": " .. sliderPercentages[sliderType] .. "%"
        end})
    end

    CreateGeometrySlider("Size")
    CreateGeometrySlider("Length")
    CreateGeometrySlider("Width")

    UpdateGeometry()

    -------------------------------------------------------
    -- УПРАВЛЕНИЕ ВКЛАДКАМИ (КЛИКИ)
    -------------------------------------------------------
    local allTabs = {
        ["Settings"] = {Btn = SettingsButton, Frame = GreyFrame},
        ["Support"] = {Btn = SupportButton, Frame = SupportFrame},
        ["Game"] = {Btn = GameButton, Frame = GameFrame}
    }

    for tabName, tabData in pairs(allTabs) do
        tabData.Btn.Activated:Connect(function()
            currentTab = tabName
            for _, data in pairs(allTabs) do
                data.Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                data.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                data.Frame.Visible = false
            end
            tabData.Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tabData.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabData.Frame.Visible = true
        end)
    end

    -------------------------------------------------------
    -- АВТО-ОТСТУПЫ СЕКЦИИ НАСТРОЕК
    -------------------------------------------------------
    local DevsLabel = Instance.new("TextLabel", DevelopersBlock)
    local DevsOval = Instance.new("Frame", DevelopersBlock)
    local DevsText = Instance.new("TextLabel", DevsOval)

    local function LayoutUI(animate)
        local langOpen = DropdownContainer1.Visible
        local tTime = animate and 0.25 or 0
        local tInfo = TweenInfo.new(tTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        TweenService:Create(DropdownContainer1, tInfo, {Size = UDim2.new(1, -16, 0, langOpen and 115 or 0)}):Play()

        local interfaceY = langOpen and 205 or 90
        TweenService:Create(SeparatorLine2Left, tInfo, {Position = UDim2.new(0, 0, 0, interfaceY + 10)}):Play()
        TweenService:Create(SeparatorLine2Right, tInfo, {Position = UDim2.new(0.5, 45, 0, interfaceY + 10)}):Play()
        TweenService:Create(GeometryLabel, tInfo, {Position = UDim2.new(0.5, -45, 0, interfaceY)}):Play()
        
        TweenService:Create(sliders[1].Container, tInfo, {Position = UDim2.new(0, 6, 0, interfaceY + 26)}):Play()
        TweenService:Create(sliders[2].Container, tInfo, {Position = UDim2.new(0, 6, 0, interfaceY + 56)}):Play()
        TweenService:Create(sliders[3].Container, tInfo, {Position = UDim2.new(0, 6, 0, interfaceY + 86)}):Play()
        
        local devsY = interfaceY + 120
        TweenService:Create(DevelopersBlock, tInfo, {Position = UDim2.new(0, 0, 0, devsY)}):Play()
        
        GreyFrame.CanvasSize = UDim2.new(0, 0, 0, devsY + 150)
    end

    local function UpdateLocalization()
        local data = Localization[currentLanguage]
        
        SettingsButton.Text = data.Settings
        SupportButton.Text = data.Support
        GameButton.Text = data.GameTab
        
        LanguageLabel.Text = data.LangLabel
        GeometryLabel.Text = data.Interface
        
        SupportTextLabel.Text = data.NothingHere
        GameSelectLabel.Text = data.SelectGameText
        
        DevsLabel.Text = data.DevsTitle
        DevsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        DevsLabel.Font = Enum.Font.SourceSansBold
        DevsLabel.TextSize = 13
        DevsLabel.ZIndex = 3
        DevsText.Text = data.DevsText

        for _, slider in ipairs(sliders) do slider.Refresh() end
    end

    DropdownBtn1.Activated:Connect(function()
        DropdownContainer1.Visible = not DropdownContainer1.Visible
        local open = DropdownContainer1.Visible
        TweenService:Create(ArrowIcon1, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = open and 180 or 0}):Play()
        LayoutUI(true)
    end)

    local Languages = {"English", "Русский", "العربية", "Español"}
    for i, langName in ipairs(Languages) do
        local LangBtn = Instance.new("TextButton", DropdownContainer1)
        LangBtn.Size = UDim2.new(1, -10, 0, 24)
        LangBtn.Position = UDim2.new(0, 5, 0, 4 + (i-1) * 27)
        LangBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        LangBtn.Text = "  " .. langName
        LangBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        LangBtn.Font = Enum.Font.SourceSansBold
        LangBtn.TextSize = 13
        LangBtn.ZIndex = 14
        LangBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", LangBtn).CornerRadius = UDim.new(0, 6)

        LangBtn.Activated:Connect(function()
            currentLanguage = langName
            CurrentLangText.Text = langName
            DropdownContainer1.Visible = false
            TweenService:Create(ArrowIcon1, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
            UpdateLocalization()
            LayoutUI(true)
        end)
    end

    DevelopersBlock.Name = "DevelopersBlock"
    DevelopersBlock.Size = UDim2.new(1, 0, 0, 145) 
    DevelopersBlock.BackgroundTransparency = 1
    DevelopersBlock.ZIndex = 3

    local SeparatorLine4Left = Instance.new("Frame", DevelopersBlock)
    SeparatorLine4Left.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine4Left.Size = UDim2.new(0.5, -55, 0, 2)
    SeparatorLine4Left.Position = UDim2.new(0, 0, 0, 14)
    SeparatorLine4Left.ZIndex = 3

    local SeparatorLine4Right = Instance.new("Frame", DevelopersBlock)
    SeparatorLine4Right.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine4Right.Size = UDim2.new(0.5, -55, 0, 2)
    SeparatorLine4Right.Position = UDim2.new(0.5, 55, 0, 14)
    SeparatorLine4Right.ZIndex = 3

    DevsLabel.Size = UDim2.new(0, 110, 0, 20)
    DevsLabel.Position = UDim2.new(0.5, -55, 0, 4) 
    DevsLabel.BackgroundTransparency = 1

    DevsOval.Size = UDim2.new(1, -16, 0, 100) 
    DevsOval.Position = UDim2.new(0, 6, 0, 36)
    DevsOval.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DevsOval.ZIndex = 4
    Instance.new("UICorner", DevsOval).CornerRadius = UDim.new(0, 12)

    DevsText.Size = UDim2.new(1, -24, 1, -16)
    DevsText.Position = UDim2.new(0, 12, 0, 12)
    DevsText.BackgroundTransparency = 1
    DevsText.TextColor3 = Color3.fromRGB(235, 235, 235)
    DevsText.Font = Enum.Font.SourceSans
    DevsText.TextSize = 12
    DevsText.ZIndex = 5

    -- КНОПКИ ЗАКРЫТИЯ И СВОРЫВАНИЯ
    CloseBtn.Activated:Connect(function() ScreenGui:Destroy() end)
    
    MinimizeBtn.Activated:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame.Size = UDim2.new(0, 160, 0, 44)
            SideTab.Visible = false
            GreyFrame.Visible = false
            SupportFrame.Visible = false
            GameFrame.Visible = false
            
            Title.Text = "NexusHUB —"
            MinimizeBtn.Text = "+"
            MinimizeBtn.Position = UDim2.new(1, -50, 0, 5)
            CloseBtn.Position = UDim2.new(1, -24, 0, 5)
        else
            Title.Text = "NexusHUB"
            MinimizeBtn.Text = "—"
            MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
            CloseBtn.Position = UDim2.new(1, -28, 0, 5)
            
            SideTab.Visible = true
            if currentTab == "Settings" then GreyFrame.Visible = true
            elseif currentTab == "Support" then SupportFrame.Visible = true
            elseif currentTab == "Game" then GameFrame.Visible = true
            end
            
            UpdateGeometry()
            LayoutUI(false)
        end
    end)

    UpdateLocalization()
    LayoutUI(false)

end)
if not success then warn("NexusUI Error: " .. tostring(err)) end
