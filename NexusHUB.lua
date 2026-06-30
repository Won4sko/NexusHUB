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
    local DEFAULT_FOV = 70
    
    -- Состояния функций
    local antiSitEnabled = false
    local infJumpEnabled = false
    local swimModeEnabled = false
    local noclipEnabled = false
    local shiftLockEnabled = false
    local isInvisible = false
    local isSpaceActive = false
    local autoUnbanEnabled = false
    
    -- Состояния вкладки игроков
    local selectedTargetPlayer = nil
    local spectateEnabled = false
    local followEnabled = false
    local singleEspEnabled = false
    local allEspEnabled = false

    local Camera = Workspace.CurrentCamera

    -------------------------------------------------------
    -- ТАБЛИЦА ЛОКАЛИЗАЦИИ
    -------------------------------------------------------
    local Localization = {
        ["English"] = {
            LangLabel = "Language", SelectGame = "Select a game...", 
            Interface = "Interface", Size = "Size", Length = "Length", Width = "Width",
            GamesTitle = "Games", DevsTitle = "Developers", Settings = "Settings",
            WalkSpeed = "WalkSpeed", JumpPower = "JumpPower", Gravity = "Gravity", ResetBtn = "Reset",
            InvisibleText = "Invisible", ToolBtn = "Menu UI", AntiSit = "Anti-Sit",
            PlayerTab = "Player", InfJump = "Infinite Jump", SwimMode = "Swim Mode",
            Noclip = "Noclip", GravZero = "Space Gravity", ShiftLock = "Shift Lock",
            AutoUnban = "Auto Unban", SitBtn = "Sit Menu", FlyBtn = "Fly Menu", SitAction = "Sit Now",
            DevsText = "Design: Won4sko\n\nCoding: Won4sko\n\nFeatures: Won4sko, Gemini, DeepSeek.",
            T_Players = "Players", T_Kill = "Kill", T_Teleport = "Teleport", T_Items = "Items",
            T_Skin = "Skin", T_Car = "Car", T_House = "House", T_Music = "Music",
            T_Emotes = "Emotes", T_Troll = "Troll", T_Defense = "Defense", T_Server = "Server",
            FOVText = "Field of View", SelectPlrTitle = "Select Player", TeleportTo = "Teleport to Player",
            SpectatePlr = "Spectate Player", FollowPlr = "Follow Player", EspPlr = "ESP Player", EspAll = "ESP All Players",
            SignPlaceholder = "Sign text...", WriteBtn = "Write", GetTool = "Select (Tool)", SelectPlrHolder = "Select player..."
        },
        ["Русский"] = {
            LangLabel = "Язык", SelectGame = "Выбрать игру...", 
            Interface = "Интерфейс", Size = "Размер", Length = "Длина", Width = "Ширина",
            GamesTitle = "Игры", DevsTitle = "Разработчики", Settings = "Настройки",
            WalkSpeed = "Скорость бега", JumpPower = "Сила прыжка", Gravity = "Гравитация", ResetBtn = "Сброс",
            InvisibleText = "Невидимость", ToolBtn = "Менюшка", AntiSit = "Анти-сидеть",
            PlayerTab = "Игрок", InfJump = "Бесконечный прыжок", SwimMode = "Плавать",
            Noclip = "Ноклип", GravZero = "Космическая Гравитация", ShiftLock = "Блокировка Шифт",
            AutoUnban = "Авто Разбан (Дома)", SitBtn = "Сидеть", FlyBtn = "Летать", SitAction = "Нажмите, чтобы сесть",
            DevsText = "Дизайн: Won4sko\n\nКодинг: Won4sko\n\nФункции: Won4sko, Gemini, DeepSeek.",
            T_Players = "Игроки", T_Kill = "Килл", T_Teleport = "Телепорт", T_Items = "Предметы",
            T_Skin = "Скин", T_Car = "Машина", T_House = "Дом", T_Music = "Музыка",
            T_Emotes = "Эмоции", T_Troll = "Тролл", T_Defense = "Защита", T_Server = "Сервер",
            FOVText = "Поле зрения (FOV)", SelectPlrTitle = "Выбор игрока", TeleportTo = "Телепорт к игроку",
            SpectatePlr = "Наблюдать за игроком", FollowPlr = "Следовать за игроком", EspPlr = "Подсветить игрока", EspAll = "Подсветить всех",
            SignPlaceholder = "Текст таблички...", WriteBtn = "Написать", GetTool = "Выбрать (Tool)", SelectPlrHolder = "Выберите игрока..."
        },
        ["العربية"] = {
            LangLabel = "اللغة", SelectGame = "اختر لعبة...", 
            Interface = "الواجهة", Size = "الحجم", Length = "الطول", Width = "العرض",
            GamesTitle = "الألعاب", DevsTitle = "المطورين", Settings = "الإعدادات",
            WalkSpeed = "سرعة المشي", JumpPower = "قوة القفز", Gravity = "الجاذبية", ResetBtn = "إعادة",
            InvisibleText = "الاقتفاء", ToolBtn = "قائمة", AntiSit = "منع الجلوس",
            PlayerTab = "لاعب", InfJump = "قفز لا نهائي", SwimMode = "وضع السباحة",
            Noclip = "اختراق الجدران", GravZero = "جاذبية الفضاء", ShiftLock = "قفل التحويل",
            AutoUnban = "إلغاء الحظر التلقائي", SitBtn = "جلوس", FlyBtn = "طيران", SitAction = "اضغط للجلوس",
            DevsText = "Won4sko :التصميم\n\nWon4sko :البرمجة\n\nWon4sko, Gemini, DeepSeek. :الميزات",
            T_Players = "اللاعبين", T_Kill = "قتل", T_Teleport = "انتقال", T_Items = "العناصر",
            T_Skin = "المظهر", T_Car = "سيارة", T_House = "منزل", T_Music = "موسيقى",
            T_Emotes = "تعبيرات", T_Troll = "مقلب", T_Defense = "حماية", T_Server = "خادم",
            FOVText = "مجال الرؤية", SelectPlrTitle = "اختر لاعب", TeleportTo = "انتقال للاعب",
            SpectatePlr = "مراقبة اللاعب", FollowPlr = "اتبع اللاعب", EspPlr = "تحديد اللاعب", EspAll = "تحديد الكل",
            SignPlaceholder = "نص اللوحة...", WriteBtn = "كتابة", GetTool = "اختر أداة", SelectPlrHolder = "اختر لاعب..."
        },
        ["Español"] = {
            LangLabel = "Idioma", SelectGame = "Seleccionar juego...", 
            Interface = "Interfaz", Size = "Tamaño", Length = "Longitud", Width = "Ancho",
            GamesTitle = "Juegos", DevsTitle = "Devs", Settings = "Ajustes",
            WalkSpeed = "Velocidad", JumpPower = "Fuerza de Salto", Gravity = "Gravedad", ResetBtn = "Reiniciar",
            InvisibleText = "Invisibilidad", ToolBtn = "Menú UI", AntiSit = "Anti-Asiento",
            PlayerTab = "Jugador", InfJump = "Salto Infinito", SwimMode = "Modo Nadar",
            Noclip = "Noclip", GravedadEspacial = "Gravedad Espacial", ShiftLock = "Shift Lock",
            AutoUnban = "Auto Desbanear", SitBtn = "Sentarse", FlyBtn = "Volar", SitAction = "Haz clic para sentarte",
            DevsText = "Diseño: Won4sko\n\nCódigo: Won4sko\n\nFunciones: Won4sko, Gemini, DeepSeek.",
            T_Players = "Jugadores", T_Kill = "Kill", T_Teleport = "Teleport", T_Items = "Objetos",
            T_Skin = "Skin", T_Car = "Coche", T_House = "Casa", T_Music = "Música",
            T_Emotes = "Emociones", T_Troll = "Troll", T_Defense = "Defensa", T_Server = "Servidor",
            FOVText = "Campo de Visión", SelectPlrTitle = "Seleccionar Jugador", TeleportTo = "Teletransportarse al jugador",
            SpectatePlr = "Espectar jugador", FollowPlr = "Seguir jugador", EspPlr = "Resaltar jugador", EspAll = "Resaltar a todos",
            SignPlaceholder = "Texto del cartel...", WriteBtn = "Escribir", GetTool = "Obtener herramienta", SelectPlrHolder = "Seleccionar jugador..."
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

    local function ToggleInvisible()
        isInvisible = not isInvisible
        if isInvisible then
            pcall(function()
                loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
            end)
        else
            local char = LocalPlayer.Character
            if char then UpdateCharacterTransparency(char, 0) end
        end
    end

    -- Наземный кастомный СТИЛЬНЫЙ КРУГЛЫЙ Shift-Lock с линиями по бокам
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

    -- Внутренний кружок
    local InnerCircle = Instance.new("Frame", MobileShiftLockBtn)
    InnerCircle.Size = UDim2.new(0, 18, 0, 18)
    InnerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", InnerCircle).CornerRadius = UDim.new(1, 0)

    -- Левая и правая полоски
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

    -- Рендер циклов
    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
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

            -- Логика постоянного следования (Фоллоу)
            if followEnabled and selectedTargetPlayer and selectedTargetPlayer.Character then
                local tHrp = selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and hrp then
                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end
    end)

    -- Обновление меток ESP на дистанцию в реальном времени
    local function UpdateEspTags()
        if singleEspEnabled and selectedTargetPlayer and selectedTargetPlayer.Character then
            local root = selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local bGui = selectedTargetPlayer.Character:FindFirstChild("NexusEspBillboard")
            if root and bGui and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                local txtLabel = bGui:FindFirstChildOfClass("TextLabel")
                if txtLabel then
                    txtLabel.Text = selectedTargetPlayer.Name .. " [" .. dist .. "m]"
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        -- Логика Shift Lock
        if shiftLockEnabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                local lookVector = Camera.CFrame.LookVector
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            end
        end
        -- Логика Наблюдения (Spectate)
        if spectateEnabled and selectedTargetPlayer and selectedTargetPlayer.Character and selectedTargetPlayer.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = selectedTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and Camera.CameraSubject ~= LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and not spectateEnabled then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
        end
        UpdateEspTags()
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

    UpdateGeometry()

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

    local SettingsButton = CreateMenuTabButton("Settings", 1)
    SettingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    local PlayerButton = CreateMenuTabButton("Player", 2)
    PlayerButton.Visible = false

    -- Кнопка кастомной вкладки целевых игроков
    local TargetPlayersButton = CreateMenuTabButton("Players", 3)
    TargetPlayersButton.Visible = false

    local bhButtons = {}
    local bhTabsList = {"Kill", "Teleport", "Items", "Skin", "Car", "House", "Music", "Emotes", "Troll", "Defense", "Server"}
    for idx, tKey in ipairs(bhTabsList) do
        local b = CreateMenuTabButton(tKey, 3 + idx)
        b.Visible = false
        bhButtons[tKey] = b
    end

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
    local PlayerFrame = CreateCentralScroll("Player")
    local TargetPlayersFrame = CreateCentralScroll("Players") 
    
    local pListLayout = Instance.new("UIListLayout", PlayerFrame)
    pListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pListLayout.Padding = UDim.new(0, 0) 

    local tpListLayout = Instance.new("UIListLayout", TargetPlayersFrame)
    tpListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tpListLayout.Padding = UDim.new(0, 10)
    tpListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    for _, tKey in ipairs(bhTabsList) do
        CreateCentralScroll(tKey)
    end

    local DevelopersBlock = Instance.new("Frame", GreyFrame) 

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

    local SeparatorLine3Left = Instance.new("Frame", GreyFrame)
    SeparatorLine3Left.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine3Left.Size = UDim2.new(0.5, -45, 0, 2)
    SeparatorLine3Left.ZIndex = 3
    local SeparatorLine3Right = Instance.new("Frame", GreyFrame)
    SeparatorLine3Right.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SeparatorLine3Right.Size = UDim2.new(0.5, -45, 0, 2)
    SeparatorLine3Right.ZIndex = 3

    local GamesLabel = Instance.new("TextLabel", GreyFrame)
    GamesLabel.Size = UDim2.new(0, 90, 0, 20)
    GamesLabel.BackgroundTransparency = 1
    GamesLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    GamesLabel.Font = Enum.Font.SourceSansBold
    GamesLabel.TextSize = 13 
    GamesLabel.ZIndex = 3

    local BigBottomOval = Instance.new("TextButton", GreyFrame)
    BigBottomOval.Size = UDim2.new(1, -16, 0, 32) 
    BigBottomOval.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BigBottomOval.Text = ""
    BigBottomOval.ZIndex = 4
    Instance.new("UICorner", BigBottomOval).CornerRadius = UDim.new(0, 16)

    local BigOvalText = Instance.new("TextLabel", BigBottomOval)
    BigOvalText.Size = UDim2.new(1, -30, 1, 0)
    BigOvalText.Position = UDim2.new(0, 14, 0, 0)
    BigOvalText.BackgroundTransparency = 1
    BigOvalText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BigOvalText.Font = Enum.Font.SourceSansBold
    BigOvalText.TextSize = 13
    BigOvalText.TextXAlignment = Enum.TextXAlignment.Left
    BigOvalText.ZIndex = 5

    local ArrowIcon2 = Instance.new("TextLabel", BigBottomOval)
    ArrowIcon2.Size = UDim2.new(0, 12, 0, 12)
    ArrowIcon2.BackgroundTransparency = 1
    ArrowIcon2.Text = "▼"
    ArrowIcon2.TextColor3 = Color3.fromRGB(200, 200, 200)
    ArrowIcon2.Font = Enum.Font.SourceSansBold
    ArrowIcon2.TextSize = 10
    ArrowIcon2.Position = UDim2.new(1, -16, 0.5, -6)
    ArrowIcon2.ZIndex = 5

    local GamesDropdownContainer = Instance.new("ScrollingFrame", GreyFrame)
    GamesDropdownContainer.Size = UDim2.new(1, -16, 0, 0) 
    GamesDropdownContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    GamesDropdownContainer.Visible = false
    GamesDropdownContainer.ZIndex = 15
    GamesDropdownContainer.ScrollBarThickness = 3
    GamesDropdownContainer.CanvasSize = UDim2.new(0, 0, 0, 165) 
    Instance.new("UICorner", GamesDropdownContainer).CornerRadius = UDim.new(0, 10)

    local GamesList = {"Brookhaven", "BABFT", "Evade", "Murder Mystery 2", "Blox Fruits"}
    local selectedGame = nil

    -------------------------------------------------------
    -- НАСТРОЙКА ВКЛАДКИ ИГРОК (Слайдеры, FOV, Отступы)
    -------------------------------------------------------
    local playerUIElements = {}
    local function CreatePlayerFeature(parentScroll, textKey, defaultValue, layoutOrder, callback)
        local MainContainer = Instance.new("Frame", parentScroll)
        MainContainer.Size = UDim2.new(1, -12, 0, 42)
        MainContainer.BackgroundTransparency = 1
        MainContainer.LayoutOrder = layoutOrder
        MainContainer.ZIndex = 3

        local ControlContainer = Instance.new("Frame", MainContainer)
        ControlContainer.Size = UDim2.new(1, 0, 1, 0)
        ControlContainer.BackgroundTransparency = 1
        ControlContainer.ZIndex = 4

        local Lbl = Instance.new("TextLabel", ControlContainer)
        local widthMod = (textKey == "Gravity" or textKey == "FOV") and 0.45 or 0.6
        Lbl.Size = UDim2.new(widthMod, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 12, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        Lbl.Font = Enum.Font.SourceSansBold
        Lbl.TextSize = 14
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 5

        local Box = Instance.new("TextBox", ControlContainer)
        Box.Size = UDim2.new(0.28, 0, 0, 24)
        Box.Position = UDim2.new(0.72, -10, 0.5, -12)
        Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Box.Text = tostring(defaultValue)
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.Font = Enum.Font.SourceSansBold
        Box.TextSize = 13
        Box.ZIndex = 5
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

        local ResetSubMenu = Instance.new("Frame", parentScroll)
        ResetSubMenu.Size = UDim2.new(1, -12, 0, 0) 
        ResetSubMenu.BackgroundTransparency = 1
        ResetSubMenu.ClipsDescendants = true
        ResetSubMenu.LayoutOrder = layoutOrder + 1
        ResetSubMenu.ZIndex = 4

        local ResetBtn = Instance.new("TextButton", ResetSubMenu)
        ResetBtn.Size = UDim2.new(1, -24, 0, 24)
        ResetBtn.Position = UDim2.new(0, 12, 0, 2)
        ResetBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
        ResetBtn.Font = Enum.Font.SourceSansBold
        ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ResetBtn.TextSize = 12
        ResetBtn.ZIndex = 5
        Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

        local longLine = Instance.new("Frame", ResetSubMenu)
        longLine.Size = UDim2.new(1, -10, 0, 1)
        longLine.Position = UDim2.new(0, 5, 0, 31)
        longLine.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        longLine.BorderSizePixel = 0
        longLine.ZIndex = 5

        local function toggleResetLayout(show)
            local targetHeight = show and 34 or 0
            TweenService:Create(ResetSubMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -12, 0, targetHeight)}):Play()
        end

        Box.FocusLost:Connect(function()
            local val = tonumber(Box.Text)
            if val then 
                callback(val)
                toggleResetLayout(val ~= defaultValue)
            else
                Box.Text = tostring(defaultValue)
                toggleResetLayout(false)
            end
        end)

        ResetBtn.Activated:Connect(function()
            Box.Text = tostring(defaultValue)
            callback(defaultValue)
            toggleResetLayout(false)
        end)

        playerUIElements[textKey] = {Label = Lbl, Reset = ResetBtn, Box = Box, ToggleReset = toggleResetLayout}
    end

    CreatePlayerFeature(PlayerFrame, "WalkSpeed", DEFAULT_SPEED, 10, function(val)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end)

    CreatePlayerFeature(PlayerFrame, "JumpPower", DEFAULT_JUMP, 20, function(val)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true hum.JumpPower = val end
    end)

    CreatePlayerFeature(PlayerFrame, "Gravity", DEFAULT_GRAVITY, 30, function(val)
        Workspace.Gravity = val
    end)

    CreatePlayerFeature(PlayerFrame, "FOV", 0, 32, function(val)
        Camera.FieldOfView = (val == 0) and DEFAULT_FOV or math.clamp(val, 1, 120)
    end)

    local StaticGravLine = Instance.new("Frame")
    StaticGravLine.Name = "StaticGravLine"
    StaticGravLine.Size = UDim2.new(0.9, 0, 0, 1)
    StaticGravLine.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    StaticGravLine.BorderSizePixel = 0
    StaticGravLine.LayoutOrder = 35
    StaticGravLine.ZIndex = 5
    StaticGravLine.Parent = PlayerFrame

    local function CreateToggleSwitch(parent, textKey, layoutOrder, stateRef, onToggle)
        local TContainer = Instance.new("Frame", parent)
        TContainer.Size = UDim2.new(1, -16, 0, 36)
        TContainer.BackgroundTransparency = 1
        TContainer.LayoutOrder = layoutOrder
        TContainer.ZIndex = 4

        local TLbl = Instance.new("TextLabel", TContainer)
        TLbl.Size = UDim2.new(0.6, 0, 1, 0)
        TLbl.Position = UDim2.new(0, 8, 0, 0)
        TLbl.BackgroundTransparency = 1
        TLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        TLbl.Font = Enum.Font.SourceSansBold
        TLbl.TextSize = 13
        TLbl.TextXAlignment = Enum.TextXAlignment.Left
        TLbl.ZIndex = 5

        local TFrame = Instance.new("TextButton", TContainer)
        TFrame.Size = UDim2.new(0, 42, 0, 22)
        TFrame.Position = UDim2.new(1, -44, 0.5, -11)
        TFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
        TFrame.Text = ""
        TFrame.ZIndex = 5
        Instance.new("UICorner", TFrame).CornerRadius = UDim.new(1, 0)
        
        local TStroke = Instance.new("UIStroke", TFrame)
        TStroke.Color = Color3.fromRGB(255, 255, 255)
        TStroke.Thickness = 1

        local TCircle = Instance.new("Frame", TFrame)
        TCircle.Size = UDim2.new(0, 16, 0, 16)
        TCircle.Position = UDim2.new(0, 3, 0.5, -8)
        TCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
        TCircle.ZIndex = 6
        Instance.new("UICorner", TCircle).CornerRadius = UDim.new(1, 0)

        local function updateVisuals(enabled)
            local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if enabled then
                TweenService:Create(TFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(TCircle, tInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            else
                TweenService:Create(TFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                TweenService:Create(TCircle, tInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end

        TFrame.Activated:Connect(function()
            onToggle()
            updateVisuals(stateRef())
        end)

        playerUIElements[textKey] = {Label = TLbl, UpdateVisuals = function() updateVisuals(stateRef()) end}
    end

    CreateToggleSwitch(PlayerFrame, "AntiSit", 40, function() return antiSitEnabled end, function() antiSitEnabled = not antiSitEnabled end)
    CreateToggleSwitch(PlayerFrame, "InfJump", 50, function() return infJumpEnabled end, function() infJumpEnabled = not infJumpEnabled end)
    CreateToggleSwitch(PlayerFrame, "SwimMode", 60, function() return swimModeEnabled end, function() swimModeEnabled = not swimModeEnabled end)
    CreateToggleSwitch(PlayerFrame, "Noclip", 70, function() return noclipEnabled end, function() noclipEnabled = not noclipEnabled end)
    CreateToggleSwitch(PlayerFrame, "ShiftLock", 80, function() return MobileShiftLockBtn.Visible end, function() 
        MobileShiftLockBtn.Visible = not MobileShiftLockBtn.Visible
        if not MobileShiftLockBtn.Visible then 
            shiftLockEnabled = false 
            MobileShiftLockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            InnerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LeftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            RightLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default 
        end
    end)
    CreateToggleSwitch(PlayerFrame, "AutoUnban", 85, function() return autoUnbanEnabled end, function() autoUnbanEnabled = not autoUnbanEnabled end)

    local SpacerBeforeSpaceGrav = Instance.new("Frame", PlayerFrame)
    SpacerBeforeSpaceGrav.Size = UDim2.new(1, 0, 0, 8)
    SpacerBeforeSpaceGrav.BackgroundTransparency = 1
    SpacerBeforeSpaceGrav.LayoutOrder = 88

    local GravZeroBtn = Instance.new("TextButton", PlayerFrame)
    GravZeroBtn.Size = UDim2.new(1, -16, 0, 32)
    GravZeroBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    GravZeroBtn.Font = Enum.Font.SourceSansBold
    GravZeroBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GravZeroBtn.TextSize = 13
    GravZeroBtn.LayoutOrder = 90
    GravZeroBtn.ZIndex = 5
    Instance.new("UICorner", GravZeroBtn).CornerRadius = UDim.new(0, 8)
    
    GravZeroBtn.Activated:Connect(function()
        isSpaceActive = not isSpaceActive
        if isSpaceActive then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = hrp.Velocity + Vector3.new(0, 25, 0) end
            if playerUIElements["Gravity"] then playerUIElements["Gravity"].Box.Text = "25" playerUIElements["Gravity"].ToggleReset(true) end
        else
            Workspace.Gravity = DEFAULT_GRAVITY
            if playerUIElements["Gravity"] then playerUIElements["Gravity"].Box.Text = tostring(DEFAULT_GRAVITY) playerUIElements["Gravity"].ToggleReset(false) end
        end
    end)

    local SpacerBeforeInvisible = Instance.new("Frame", PlayerFrame)
    SpacerBeforeInvisible.Size = UDim2.new(1, 0, 0, 10)
    SpacerBeforeInvisible.BackgroundTransparency = 1
    SpacerBeforeInvisible.LayoutOrder = 95

    local InvisiblePlaceMain = Instance.new("Frame", PlayerFrame)
    InvisiblePlaceMain.Size = UDim2.new(1, -12, 0, 58)
    InvisiblePlaceMain.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    InvisiblePlaceMain.LayoutOrder = 100
    InvisiblePlaceMain.ZIndex = 4
    Instance.new("UICorner", InvisiblePlaceMain).CornerRadius = UDim.new(0, 12)

    local InvisiblePlaceTitle = Instance.new("TextLabel", InvisiblePlaceMain)
    InvisiblePlaceTitle.Size = UDim2.new(1, 0, 0, 18)
    InvisiblePlaceTitle.Position = UDim2.new(0, 0, 0, 4)
    InvisiblePlaceTitle.BackgroundTransparency = 1
    InvisiblePlaceTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    InvisiblePlaceTitle.Font = Enum.Font.SourceSansBold
    InvisiblePlaceTitle.TextSize = 12
    InvisiblePlaceTitle.ZIndex = 5

    local LeftGreyOvalBtn = Instance.new("TextButton", InvisiblePlaceMain)
    LeftGreyOvalBtn.Size = UDim2.new(0.46, 0, 0, 26)
    LeftGreyOvalBtn.Position = UDim2.new(0, 8, 0, 24)
    LeftGreyOvalBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    LeftGreyOvalBtn.Font = Enum.Font.SourceSansBold
    LeftGreyOvalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LeftGreyOvalBtn.TextSize = 12
    LeftGreyOvalBtn.ZIndex = 6
    Instance.new("UICorner", LeftGreyOvalBtn).CornerRadius = UDim.new(0, 13)

    local RightGreyOvalBtn = Instance.new("TextButton", InvisiblePlaceMain)
    RightGreyOvalBtn.Size = UDim2.new(0.46, 0, 0, 26)
    RightGreyOvalBtn.Position = UDim2.new(1, -8, 0, 24)
    RightGreyOvalBtn.AnchorPoint = Vector2.new(1, 0)
    RightGreyOvalBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    RightGreyOvalBtn.Font = Enum.Font.SourceSansBold
    RightGreyOvalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RightGreyOvalBtn.TextSize = 12
    RightGreyOvalBtn.ZIndex = 6
    Instance.new("UICorner", RightGreyOvalBtn).CornerRadius = UDim.new(0, 13)

    local SpacerBeforeModals = Instance.new("Frame", PlayerFrame)
    SpacerBeforeModals.Size = UDim2.new(1, 0, 0, 12)
    SpacerBeforeModals.BackgroundTransparency = 1
    SpacerBeforeModals.LayoutOrder = 105

    local ModalsContainer = Instance.new("Frame", PlayerFrame)
    ModalsContainer.Size = UDim2.new(1, -12, 0, 35)
    ModalsContainer.BackgroundTransparency = 1
    ModalsContainer.LayoutOrder = 110
    ModalsContainer.ZIndex = 4

    local SitModalOpenBtn = Instance.new("TextButton", ModalsContainer)
    SitModalOpenBtn.Size = UDim2.new(0.46, 0, 1, 0)
    SitModalOpenBtn.Position = UDim2.new(0, 6, 0, 0)
    SitModalOpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SitModalOpenBtn.Font = Enum.Font.SourceSansBold
    SitModalOpenBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    SitModalOpenBtn.TextSize = 13
    SitModalOpenBtn.ZIndex = 5
    Instance.new("UICorner", SitModalOpenBtn).CornerRadius = UDim.new(0, 16)

    local FlyModalOpenBtn = Instance.new("TextButton", ModalsContainer)
    FlyModalOpenBtn.Size = UDim2.new(0.46, 0, 1, 0)
    FlyModalOpenBtn.Position = UDim2.new(1, -6, 0, 0)
    FlyModalOpenBtn.AnchorPoint = Vector2.new(1, 0)
    FlyModalOpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FlyModalOpenBtn.Font = Enum.Font.SourceSansBold
    FlyModalOpenBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    FlyModalOpenBtn.TextSize = 13
    FlyModalOpenBtn.ZIndex = 5
    Instance.new("UICorner", FlyModalOpenBtn).CornerRadius = UDim.new(0, 16)

    -- Небольшой отступ в самом низу вкладки Игрок
    local FinalSpacerPlayer = Instance.new("Frame", PlayerFrame)
    FinalSpacerPlayer.Size = UDim2.new(1, 0, 0, 15)
    FinalSpacerPlayer.BackgroundTransparency = 1
    FinalSpacerPlayer.LayoutOrder = 120

    PlayerFrame.CanvasSize = UDim2.new(0, 0, 0, 560)

    -------------------------------------------------------
    -- ОКНА "СИДЕТЬ" И "ЛЕТАТЬ"
    -------------------------------------------------------
    SitModalOpenBtn.Activated:Connect(function()
        if ScreenGui:FindFirstChild("SitOverlayMenu") then return end
        local SitGui = Instance.new("Frame", ScreenGui)
        SitGui.Name = "SitOverlayMenu"
        SitGui.Size = UDim2.new(0, 150, 0, 75)
        SitGui.Position = UDim2.new(0.4, 0, 0.4, 0)
        SitGui.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        SitGui.Active = true; SitGui.Draggable = true; SitGui.ZIndex = 60
        Instance.new("UICorner", SitGui).CornerRadius = UDim.new(0, 12)

        local sHeader = Instance.new("Frame", SitGui)
        sHeader.Size = UDim2.new(1, -8, 0, 20)
        sHeader.Position = UDim2.new(0, 4, 0, 4)
        sHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 30); sHeader.ZIndex = 61
        Instance.new("UICorner", sHeader).CornerRadius = UDim.new(0, 8)

        local sClose = Instance.new("TextButton", sHeader)
        sClose.Size = UDim2.new(0, 14, 0, 14); sClose.Position = UDim2.new(1, -17, 0, 3)
        sClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30); sClose.Text = "X"
        sClose.TextColor3 = Color3.fromRGB(255, 100, 100); sClose.Font = Enum.Font.SourceSansBold; sClose.TextSize = 8; sClose.ZIndex = 62
        Instance.new("UICorner", sClose).CornerRadius = UDim.new(1, 0)
        sClose.Activated:Connect(function() SitGui:Destroy() end)

        local BigSitOval = Instance.new("TextButton", SitGui)
        BigSitOval.Size = UDim2.new(1, -16, 0, 38); BigSitOval.Position = UDim2.new(0, 8, 0, 28)
        BigSitOval.BackgroundColor3 = Color3.fromRGB(0, 120, 255); BigSitOval.Text = Localization[currentLanguage].SitAction
        BigSitOval.TextColor3 = Color3.fromRGB(255, 255, 255); BigSitOval.Font = Enum.Font.SourceSansBold; BigSitOval.TextSize = 13; BigSitOval.ZIndex = 61
        Instance.new("UICorner", BigSitOval).CornerRadius = UDim.new(0, 8)

        BigSitOval.Activated:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = not hum.Sit end
        end)
    end)

    FlyModalOpenBtn.Activated:Connect(function()
        if ScreenGui:FindFirstChild("FlyNexusMenu") then return end
        local FlyGui = Instance.new("Frame", ScreenGui)
        FlyGui.Name = "FlyNexusMenu"
        FlyGui.Size = UDim2.new(0, 180, 0, 130)
        FlyGui.Position = UDim2.new(0.45, 0, 0.45, 0)
        FlyGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        FlyGui.Active = true; FlyGui.Draggable = true; FlyGui.ZIndex = 60
        Instance.new("UICorner", FlyGui).CornerRadius = UDim.new(0, 14)

        local fHeader = Instance.new("Frame", FlyGui)
        fHeader.Size = UDim2.new(1, -8, 0, 24); fHeader.Position = UDim2.new(0, 4, 0, 4)
        fHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 25); fHeader.ZIndex = 61
        Instance.new("UICorner", fHeader).CornerRadius = UDim.new(0, 12)

        local fTitle = Instance.new("TextLabel", fHeader)
        fTitle.Size = UDim2.new(0.6, 0, 1, 0); fTitle.Position = UDim2.new(0, 10, 0, 0); fTitle.BackgroundTransparency = 1
        fTitle.Text = "Nexus Fly"; fTitle.TextColor3 = Color3.fromRGB(255, 255, 255); fTitle.Font = Enum.Font.SourceSansBold; fTitle.TextSize = 11; fTitle.ZIndex = 62

        local fClose = Instance.new("TextButton", fHeader)
        fClose.Size = UDim2.new(0, 16, 0, 16); fClose.Position = UDim2.new(1, -20, 0, 4)
        fClose.BackgroundColor3 = Color3.fromRGB(50, 30, 30); fClose.Text = "X"
        fClose.TextColor3 = Color3.fromRGB(255, 100, 100); fClose.Font = Enum.Font.SourceSansBold; fClose.TextSize = 9; fClose.ZIndex = 62
        Instance.new("UICorner", fClose).CornerRadius = UDim.new(1, 0)
        fClose.Activated:Connect(function() FlyGui:Destroy() end)

        local FlyBtn = Instance.new("TextButton", FlyGui)
        FlyBtn.Size = UDim2.new(1, -20, 0, 32); FlyBtn.Position = UDim2.new(0, 10, 0, 38)
        FlyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); FlyBtn.Text = "Toggle Fly"; FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FlyBtn.ZIndex = 61
        Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 16)

        local SpeedBox = Instance.new("TextBox", FlyGui)
        SpeedBox.Size = UDim2.new(1, -20, 0, 32); SpeedBox.Position = UDim2.new(0, 10, 0, 78)
        SpeedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25); SpeedBox.Text = "Fly Speed: 1"; SpeedBox.TextColor3 = Color3.fromRGB(200, 200, 200); SpeedBox.ZIndex = 61
        Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 16)
        
        local flying = false
        local speed = 1
        FlyBtn.Activated:Connect(function()
            flying = not flying
            if flying then
                FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); FlyBtn.TextColor3 = Color3.fromRGB(0,0,0)
                task.spawn(function()
                    local bg = Instance.new("BodyGyro", LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                    local bv = Instance.new("BodyVelocity", LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                    bg.maxTorque = Vector3.new(4e4, 4e4, 4e4); bg.cframe = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame
                    bv.maxForce = Vector3.new(4e4, 4e4, 4e4); bv.velocity = Vector3.new(0,0.1,0)
                    while flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
                        bv.velocity = Camera.CFrame.LookVector * (speed * 50)
                        bg.cframe = Camera.CFrame
                        task.wait()
                    end
                    bg:Destroy(); bv:Destroy()
                end)
            else
                FlyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); FlyBtn.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end)
        SpeedBox.FocusLost:Connect(function()
            speed = tonumber(SpeedBox.Text:match("%d+")) or 1
            SpeedBox.Text = "Fly Speed: " .. speed
        end)
    end)

    LeftGreyOvalBtn.Activated:Connect(ToggleInvisible)

    -------------------------------------------------------
    -- ВЫДЕЛЕННАЯ КОМПЛЕКСНАЯ ВКЛАДКА "PLAYERS" (ИГРОКИ)
    -------------------------------------------------------
    -- Пространство сверху вкладки Игроки (чтобы овал не утыкался вверх)
    local TopSpacerPlayers = Instance.new("Frame", TargetPlayersFrame)
    TopSpacerPlayers.Size = UDim2.new(1, 0, 0, 10)
    TopSpacerPlayers.BackgroundTransparency = 1
    TopSpacerPlayers.ZIndex = 3

    local PlrSelectMainFrame = Instance.new("Frame", TargetPlayersFrame)
    PlrSelectMainFrame.Size = UDim2.new(1, -12, 0, 36)
    PlrSelectMainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    PlrSelectMainFrame.ZIndex = 4
    Instance.new("UICorner", PlrSelectMainFrame).CornerRadius = UDim.new(0, 18)

    local PlrSelectLeftTitle = Instance.new("TextLabel", PlrSelectMainFrame)
    PlrSelectLeftTitle.Size = UDim2.new(0.35, 0, 1, 0)
    PlrSelectLeftTitle.Position = UDim2.new(0, 14, 0, 0)
    PlrSelectLeftTitle.BackgroundTransparency = 1
    PlrSelectLeftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlrSelectLeftTitle.Font = Enum.Font.SourceSansBold
    PlrSelectLeftTitle.TextSize = 13
    PlrSelectLeftTitle.TextXAlignment = Enum.TextXAlignment.Left
    PlrSelectLeftTitle.ZIndex = 5

    local PlrSelectRightOval = Instance.new("TextButton", PlrSelectMainFrame)
    PlrSelectRightOval.Size = UDim2.new(0.6, 0, 0, 26)
    PlrSelectRightOval.Position = UDim2.new(1, -6, 0.5, -13)
    PlrSelectRightOval.AnchorPoint = Vector2.new(1, 0)
    PlrSelectRightOval.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    PlrSelectRightOval.Text = ""
    PlrSelectRightOval.ZIndex = 5
    Instance.new("UICorner", PlrSelectRightOval).CornerRadius = UDim.new(0, 13)

    local PlrSelectNickText = Instance.new("TextLabel", PlrSelectRightOval)
    PlrSelectNickText.Size = UDim2.new(1, -22, 1, 0)
    PlrSelectNickText.Position = UDim2.new(0, 10, 0, 0)
    PlrSelectNickText.BackgroundTransparency = 1
    PlrSelectNickText.Text = ""
    PlrSelectNickText.TextColor3 = Color3.fromRGB(170, 170, 170) -- Темно-светло-серый оттенок
    PlrSelectNickText.Font = Enum.Font.SourceSansBold
    PlrSelectNickText.TextSize = 11
    PlrSelectNickText.TextXAlignment = Enum.TextXAlignment.Left
    PlrSelectNickText.ZIndex = 6

    local PlrSelectArrow = Instance.new("TextLabel", PlrSelectRightOval)
    PlrSelectArrow.Size = UDim2.new(0, 12, 0, 12)
    PlrSelectArrow.Position = UDim2.new(1, -16, 0.5, -6)
    PlrSelectArrow.BackgroundTransparency = 1
    PlrSelectArrow.Text = "▼"
    PlrSelectArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlrSelectArrow.Font = Enum.Font.SourceSansBold
    PlrSelectArrow.TextSize = 9
    PlrSelectArrow.ZIndex = 6

    local PlrDropdownListFrame = Instance.new("ScrollingFrame", TargetPlayersFrame)
    PlrDropdownListFrame.Size = UDim2.new(1, -12, 0, 0)
    PlrDropdownListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    PlrDropdownListFrame.Visible = false
    PlrDropdownListFrame.ZIndex = 10
    PlrDropdownListFrame.ScrollBarThickness = 3
    Instance.new("UICorner", PlrDropdownListFrame).CornerRadius = UDim.new(0, 10)
    local pdlLayout = Instance.new("UIListLayout", PlrDropdownListFrame)
    pdlLayout.Padding = UDim.new(0, 4)

    local function RefreshPlayersDropdown()
        for _, c in ipairs(PlrDropdownListFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local index = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                index = index + 1
                local pBtn = Instance.new("TextButton", PlrDropdownListFrame)
                pBtn.Size = UDim2.new(1, -8, 0, 24)
                pBtn.Position = UDim2.new(0, 4, 0, 0)
                pBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
                pBtn.Text = "  " .. player.Name -- Полное имя игрока
                pBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                pBtn.Font = Enum.Font.SourceSansBold
                pBtn.TextSize = 12
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.ZIndex = 11
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)

                pBtn.Activated:Connect(function()
                    selectedTargetPlayer = player
                    PlrSelectNickText.Text = player.Name -- Полное отображение ника
                    PlrSelectNickText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    PlrDropdownListFrame.Visible = false
                    TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 460)
                end)
            end
        end
        PlrDropdownListFrame.CanvasSize = UDim2.new(0, 0, 0, index * 28 + 10)
    end

    PlrSelectRightOval.Activated:Connect(function()
        PlrDropdownListFrame.Visible = not PlrDropdownListFrame.Visible
        if PlrDropdownListFrame.Visible then
            RefreshPlayersDropdown()
            PlrDropdownListFrame.Size = UDim2.new(1, -12, 0, 90)
            TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
        else
            PlrDropdownListFrame.Size = UDim2.new(1, -12, 0, 0)
            TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 460)
        end
    end)

    local GetToolButton = Instance.new("TextButton", TargetPlayersFrame)
    GetToolButton.Size = UDim2.new(1, -16, 0, 30)
    GetToolButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    GetToolButton.Font = Enum.Font.SourceSansBold
    GetToolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetToolButton.TextSize = 13
    GetToolButton.ZIndex = 5
    Instance.new("UICorner", GetToolButton).CornerRadius = UDim.new(0, 8)

    GetToolButton.Activated:Connect(function()
        local character = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if not backpack or not character then return end
        
        local targetTool = Instance.new("Tool")
        targetTool.Name = "Player Target Tool"
        targetTool.RequiresHandle = false
        
        targetTool.Equipped:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local connection
            connection = mouse.Button1Down:Connect(function()
                if targetTool.Parent == character then
                    local target = mouse.Target
                    if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
                        local clickedPlr = Players:GetPlayerFromCharacter(target.Parent)
                        if clickedPlr and clickedPlr ~= LocalPlayer then
                            selectedTargetPlayer = clickedPlr
                            PlrSelectNickText.Text = clickedPlr.Name
                            PlrSelectNickText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end
                    end
                else
                    connection:Disconnect()
                end
            end)
        end)
        targetTool.Parent = backpack
    end)

    local PlrSeparatorLine1 = Instance.new("Frame", TargetPlayersFrame)
    PlrSeparatorLine1.Size = UDim2.new(1, -10, 0, 2)
    PlrSeparatorLine1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    PlrSeparatorLine1.ZIndex = 4

    local TeleportToPlayerBtn = Instance.new("TextButton", TargetPlayersFrame)
    TeleportToPlayerBtn.Size = UDim2.new(1, -16, 0, 32)
    TeleportToPlayerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TeleportToPlayerBtn.Font = Enum.Font.SourceSansBold
    TeleportToPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportToPlayerBtn.TextSize = 13
    TeleportToPlayerBtn.ZIndex = 5
    Instance.new("UICorner", TeleportToPlayerBtn).CornerRadius = UDim.new(0, 10)

    TeleportToPlayerBtn.Activated:Connect(function()
        if selectedTargetPlayer and selectedTargetPlayer.Character and selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = selectedTargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end)

    -- Кнопка Spectate Player
    local SpectateContainer = Instance.new("Frame", TargetPlayersFrame)
    SpectateContainer.Size = UDim2.new(1, -16, 0, 36)
    SpectateContainer.BackgroundTransparency = 1; SpectateContainer.ZIndex = 4

    local SpectateLbl = Instance.new("TextLabel", SpectateContainer)
    SpectateLbl.Size = UDim2.new(0.6, 0, 1, 0); SpectateLbl.Position = UDim2.new(0, 8, 0, 0); SpectateLbl.BackgroundTransparency = 1
    SpectateLbl.TextColor3 = Color3.fromRGB(230, 230, 230); SpectateLbl.Font = Enum.Font.SourceSansBold; SpectateLbl.TextSize = 13; SpectateLbl.TextXAlignment = Enum.TextXAlignment.Left; SpectateLbl.ZIndex = 5

    local SpectateTFrame = Instance.new("TextButton", SpectateContainer)
    SpectateTFrame.Size = UDim2.new(0, 42, 0, 22); SpectateTFrame.Position = UDim2.new(1, -44, 0.5, -11); SpectateTFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SpectateTFrame.Text = ""; SpectateTFrame.ZIndex = 5
    Instance.new("UICorner", SpectateTFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", SpectateTFrame).Color = Color3.fromRGB(255,255,255)

    local SpectateTCircle = Instance.new("Frame", SpectateTFrame)
    SpectateTCircle.Size = UDim2.new(0, 16, 0, 16); SpectateTCircle.Position = UDim2.new(0, 3, 0.5, -8); SpectateTCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SpectateTCircle.ZIndex = 6
    Instance.new("UICorner", SpectateTCircle).CornerRadius = UDim.new(1, 0)

    SpectateTFrame.Activated:Connect(function()
        spectateEnabled = not spectateEnabled
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if spectateEnabled then
            TweenService:Create(SpectateTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(SpectateTCircle, tInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        else
            TweenService:Create(SpectateTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            TweenService:Create(SpectateTCircle, tInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
    end)

    -- НОВАЯ ФУНКЦИЯ: Следовать за игроком (Loop-Телепорт)
    local FollowContainer = Instance.new("Frame", TargetPlayersFrame)
    FollowContainer.Size = UDim2.new(1, -16, 0, 36)
    FollowContainer.BackgroundTransparency = 1; FollowContainer.ZIndex = 4

    local FollowLbl = Instance.new("TextLabel", FollowContainer)
    FollowLbl.Size = UDim2.new(0.6, 0, 1, 0); FollowLbl.Position = UDim2.new(0, 8, 0, 0); FollowLbl.BackgroundTransparency = 1
    FollowLbl.TextColor3 = Color3.fromRGB(230, 230, 230); FollowLbl.Font = Enum.Font.SourceSansBold; FollowLbl.TextSize = 13; FollowLbl.TextXAlignment = Enum.TextXAlignment.Left; FollowLbl.ZIndex = 5

    local FollowTFrame = Instance.new("TextButton", FollowContainer)
    FollowTFrame.Size = UDim2.new(0, 42, 0, 22); FollowTFrame.Position = UDim2.new(1, -44, 0.5, -11); FollowTFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); FollowTFrame.Text = ""; FollowTFrame.ZIndex = 5
    Instance.new("UICorner", FollowTFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", FollowTFrame).Color = Color3.fromRGB(255,255,255)

    local FollowTCircle = Instance.new("Frame", FollowTFrame)
    FollowTCircle.Size = UDim2.new(0, 16, 0, 16); FollowTCircle.Position = UDim2.new(0, 3, 0.5, -8); FollowTCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); FollowTCircle.ZIndex = 6
    Instance.new("UICorner", FollowTCircle).CornerRadius = UDim.new(1, 0)

    FollowTFrame.Activated:Connect(function()
        followEnabled = not followEnabled
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if followEnabled then
            TweenService:Create(FollowTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(FollowTCircle, tInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        else
            TweenService:Create(FollowTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            TweenService:Create(FollowTCircle, tInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
    end)

    -- Кнопка Подсветить игрока (Синее ESP + Название + Дистанция)
    local SingleEspContainer = Instance.new("Frame", TargetPlayersFrame)
    SingleEspContainer.Size = UDim2.new(1, -16, 0, 36)
    SingleEspContainer.BackgroundTransparency = 1; SingleEspContainer.ZIndex = 4

    local SingleEspLbl = Instance.new("TextLabel", SingleEspContainer)
    SingleEspLbl.Size = UDim2.new(0.6, 0, 1, 0); SingleEspLbl.Position = UDim2.new(0, 8, 0, 0); SingleEspLbl.BackgroundTransparency = 1
    SingleEspLbl.TextColor3 = Color3.fromRGB(230, 230, 230); SingleEspLbl.Font = Enum.Font.SourceSansBold; SingleEspLbl.TextSize = 13; SingleEspLbl.TextXAlignment = Enum.TextXAlignment.Left; SingleEspLbl.ZIndex = 5

    local SEspTFrame = Instance.new("TextButton", SingleEspContainer)
    SEspTFrame.Size = UDim2.new(0, 42, 0, 22); SEspTFrame.Position = UDim2.new(1, -44, 0.5, -11); SEspTFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SEspTFrame.Text = ""; SEspTFrame.ZIndex = 5
    Instance.new("UICorner", SEspTFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", SEspTFrame).Color = Color3.fromRGB(255,255,255)

    local SEspTCircle = Instance.new("Frame", SEspTFrame)
    SEspTCircle.Size = UDim2.new(0, 16, 0, 16); SEspTCircle.Position = UDim2.new(0, 3, 0.5, -8); SEspTCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SEspTCircle.ZIndex = 6
    Instance.new("UICorner", SEspTCircle).CornerRadius = UDim.new(1, 0)

    SEspTFrame.Activated:Connect(function()
        singleEspEnabled = not singleEspEnabled
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if singleEspEnabled then
            TweenService:Create(SEspTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(SEspTCircle, tInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            if selectedTargetPlayer and selectedTargetPlayer.Character then
                -- Подсветка СИНИМ цветом
                local hl = selectedTargetPlayer.Character:FindFirstChild("NexusPlrESP") or Instance.new("Highlight")
                hl.Name = "NexusPlrESP"
                hl.FillColor = Color3.fromRGB(0, 120, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = selectedTargetPlayer.Character

                -- Создание 3D текста над головой для отображения имени и дистанции
                local head = selectedTargetPlayer.Character:FindFirstChild("Head")
                if head then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "NexusEspBillboard"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.Parent = selectedTargetPlayer.Character
                    
                    local tl = Instance.new("TextLabel", bb)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(0, 230, 255)
                    tl.Font = Enum.Font.SourceSansBold
                    tl.TextSize = 14
                    tl.TextStrokeTransparency = 0.2
                    tl.Text = selectedTargetPlayer.Name .. " [0m]"
                end
            end
        else
            TweenService:Create(SEspTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            TweenService:Create(SEspTCircle, tInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            if selectedTargetPlayer and selectedTargetPlayer.Character then
                if selectedTargetPlayer.Character:FindFirstChild("NexusPlrESP") then
                    selectedTargetPlayer.Character.NexusPlrESP:Destroy()
                end
                if selectedTargetPlayer.Character:FindFirstChild("NexusEspBillboard") then
                    selectedTargetPlayer.Character.NexusEspBillboard:Destroy()
                end
            end
        end
    end)

    -- Кнопка Подсветить всех (Перенесена под Подсветить Игрока)
    local AllEspContainer = Instance.new("Frame", TargetPlayersFrame)
    AllEspContainer.Size = UDim2.new(1, -16, 0, 36)
    AllEspContainer.BackgroundTransparency = 1; AllEspContainer.ZIndex = 4

    local AllEspLbl = Instance.new("TextLabel", AllEspContainer)
    AllEspLbl.Size = UDim2.new(0.6, 0, 1, 0); AllEspLbl.Position = UDim2.new(0, 8, 0, 0); AllEspLbl.BackgroundTransparency = 1
    AllEspLbl.TextColor3 = Color3.fromRGB(230, 230, 230); AllEspLbl.Font = Enum.Font.SourceSansBold; AllEspLbl.TextSize = 13; AllEspLbl.TextXAlignment = Enum.TextXAlignment.Left; AllEspLbl.ZIndex = 5

    local AllEspTFrame = Instance.new("TextButton", AllEspContainer)
    AllEspTFrame.Size = UDim2.new(0, 42, 0, 22); AllEspTFrame.Position = UDim2.new(1, -44, 0.5, -11); AllEspTFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); AllEspTFrame.Text = ""; AllEspTFrame.ZIndex = 5
    Instance.new("UICorner", AllEspTFrame).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", AllEspTFrame).Color = Color3.fromRGB(255,255,255)

    local AllEspTCircle = Instance.new("Frame", AllEspTFrame)
    AllEspTCircle.Size = UDim2.new(0, 16, 0, 16); AllEspTCircle.Position = UDim2.new(0, 3, 0.5, -8); AllEspTCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); AllEspTCircle.ZIndex = 6
    Instance.new("UICorner", AllEspTCircle).CornerRadius = UDim.new(1, 0)

    local function updateAllEsp()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if allEspEnabled then
                    local hl = p.Character:FindFirstChild("NexusAllESP") or Instance.new("Highlight")
                    hl.Name = "NexusAllESP"
                    hl.FillColor = Color3.fromRGB(255, 255, 0)
                    hl.Parent = p.Character
                else
                    if p.Character:FindFirstChild("NexusAllESP") then p.Character.NexusAllESP:Destroy() end
                end
            end
        end
    end

    AllEspTFrame.Activated:Connect(function()
        allEspEnabled = not allEspEnabled
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if allEspEnabled then
            TweenService:Create(AllEspTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(AllEspTCircle, tInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        else
            TweenService:Create(AllEspTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            TweenService:Create(AllEspTCircle, tInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        updateAllEsp()
    end)

    -- ЛИНИЯ ТЕПЕРЬ ОГРАНИЧЕНА В ОДИНОЧЕСТВЕ ПОСЛЕ "ПОДСВЕТИТЬ ВСЕХ"
    local PlrSeparatorLine2 = Instance.new("Frame", TargetPlayersFrame)
    PlrSeparatorLine2.Size = UDim2.new(1, -10, 0, 2)
    PlrSeparatorLine2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    PlrSeparatorLine2.ZIndex = 4

    -- Поле ввода таблички
    local SignTextBoxOval = Instance.new("TextBox", TargetPlayersFrame)
    SignTextBoxOval.Size = UDim2.new(0.85, 0, 0, 32)
    SignTextBoxOval.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    SignTextBoxOval.Font = Enum.Font.SourceSansBold
    SignTextBoxOval.TextColor3 = Color3.fromRGB(255, 255, 255)
    SignTextBoxOval.TextSize = 13
    SignTextBoxOval.ZIndex = 5
    Instance.new("UICorner", SignTextBoxOval).CornerRadius = UDim.new(0, 16)
    local SignStroke = Instance.new("UIStroke", SignTextBoxOval)
    SignStroke.Color = Color3.fromRGB(70, 70, 70)
    SignStroke.Thickness = 1

    -- Кнопка Написать (Сделана ТЕМНО-СЕРЫМ цветом)
    local WriteSignButton = Instance.new("TextButton", TargetPlayersFrame)
    WriteSignButton.Size = UDim2.new(0.6, 0, 0, 28)
    WriteSignButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Более глубокий темно-серый
    WriteSignButton.Font = Enum.Font.SourceSansBold
    WriteSignButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    WriteSignButton.TextSize = 13
    WriteSignButton.ZIndex = 5
    Instance.new("UICorner", WriteSignButton).CornerRadius = UDim.new(0, 14)

    WriteSignButton.Activated:Connect(function()
        if selectedTargetPlayer and selectedTargetPlayer.Character then
            local toolSign = selectedTargetPlayer.Character:FindFirstChild("Sign") or selectedTargetPlayer.Character:FindFirstChild("Subsign")
            if toolSign then
                for _, descendant in ipairs(toolSign:GetDescendants()) do
                    if descendant:IsA("TextBox") or descendant:IsA("TextLabel") then
                        descendant.Text = SignTextBoxOval.Text
                    end
                end
            end
        end
    end)

    TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 460)

    local function CheckGameTabs(gameName)
        local isBrookhaven = (gameName == "Brookhaven")
        PlayerButton.Visible = isBrookhaven
        TargetPlayersButton.Visible = isBrookhaven 
        for _, btn in pairs(bhButtons) do
            btn.Visible = isBrookhaven
        end
        if not isBrookhaven and currentTab ~= "Settings" then
            SettingsButton.Activated:Fire()
        end
    end

    -------------------------------------------------------
    -- АВТО-ОТСТУПЫ СЕКЦИИ НАСТРОЕК
    -------------------------------------------------------
    local DevsLabel = Instance.new("TextLabel", DevelopersBlock)
    local DevsOval = Instance.new("Frame", DevelopersBlock)
    local DevsText = Instance.new("TextLabel", DevsOval)

    local function LayoutUI(animate)
        local langOpen = DropdownContainer1.Visible
        local gamesOpen = GamesDropdownContainer.Visible
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
        
        local gamesY = interfaceY + 120
        TweenService:Create(SeparatorLine3Left, tInfo, {Position = UDim2.new(0, 0, 0, gamesY + 10)}):Play()
        TweenService:Create(SeparatorLine3Right, tInfo, {Position = UDim2.new(0.5, 45, 0, gamesY + 10)}):Play()
        TweenService:Create(GamesLabel, tInfo, {Position = UDim2.new(0.5, -45, 0, gamesY)}):Play()
        TweenService:Create(BigBottomOval, tInfo, {Position = UDim2.new(0, 6, 0, gamesY + 26)}):Play()
        
        TweenService:Create(GamesDropdownContainer, tInfo, {
            Size = UDim2.new(1, -16, 0, gamesOpen and 95 or 0),
            Position = UDim2.new(0, 6, 0, gamesY + 62)
        }):Play()
        
        local devsY = gamesOpen and (gamesY + 165) or (gamesY + 65)
        TweenService:Create(DevelopersBlock, tInfo, {Position = UDim2.new(0, 0, 0, devsY)}):Play()
        
        GreyFrame.CanvasSize = UDim2.new(0, 0, 0, devsY + 150)
    end

    local function UpdateLocalization()
        local data = Localization[currentLanguage]
        
        SettingsButton.Text = data.Settings
        PlayerButton.Text = data.PlayerTab
        TargetPlayersButton.Text = data.T_Players
        LanguageLabel.Text = data.LangLabel
        GeometryLabel.Text = data.Interface
        GamesLabel.Text = data.GamesTitle
        
        DevsLabel.Text = data.DevsTitle
        DevsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        DevsLabel.Font = Enum.Font.SourceSansBold
        DevsLabel.TextSize = 13
        DevsLabel.ZIndex = 3
        DevsText.Text = data.DevsText

        if playerUIElements["WalkSpeed"] then playerUIElements["WalkSpeed"].Label.Text = data.WalkSpeed playerUIElements["WalkSpeed"].Reset.Text = data.ResetBtn end
        if playerUIElements["JumpPower"] then playerUIElements["JumpPower"].Label.Text = data.JumpPower playerUIElements["JumpPower"].Reset.Text = data.ResetBtn end
        if playerUIElements["Gravity"] then playerUIElements["Gravity"].Label.Text = data.Gravity playerUIElements["Gravity"].Reset.Text = data.ResetBtn end
        if playerUIElements["FOV"] then playerUIElements["FOV"].Label.Text = data.FOVText playerUIElements["FOV"].Reset.Text = data.ResetBtn end
        
        if playerUIElements["AntiSit"] then playerUIElements["AntiSit"].Label.Text = "  " .. data.AntiSit playerUIElements["AntiSit"].UpdateVisuals() end
        if playerUIElements["InfJump"] then playerUIElements["InfJump"].Label.Text = "  " .. data.InfJump playerUIElements["InfJump"].UpdateVisuals() end
        if playerUIElements["SwimMode"] then playerUIElements["SwimMode"].Label.Text = "  " .. data.SwimMode playerUIElements["SwimMode"].UpdateVisuals() end
        if playerUIElements["Noclip"] then playerUIElements["Noclip"].Label.Text = "  " .. data.Noclip playerUIElements["Noclip"].UpdateVisuals() end
        if playerUIElements["ShiftLock"] then playerUIElements["ShiftLock"].Label.Text = "  " .. data.ShiftLock playerUIElements["ShiftLock"].UpdateVisuals() end
        if playerUIElements["AutoUnban"] then playerUIElements["AutoUnban"].Label.Text = "  " .. data.AutoUnban playerUIElements["AutoUnban"].UpdateVisuals() end
        
        GravZeroBtn.Text = data.GravZero
        InvisiblePlaceTitle.Text = data.InvisibleText
        LeftGreyOvalBtn.Text = data.InvisibleText
        RightGreyOvalBtn.Text = data.ToolBtn
        
        SitModalOpenBtn.Text = data.SitBtn
        FlyModalOpenBtn.Text = data.FlyBtn

        PlrSelectLeftTitle.Text = data.T_Players
        GetToolButton.Text = data.GetTool
        TeleportToPlayerBtn.Text = data.TeleportTo
        SpectateLbl.Text = "  " .. data.SpectatePlr
        FollowLbl.Text = "  " .. data.FollowPlr
        SingleEspLbl.Text = "  " .. data.EspPlr
        AllEspLbl.Text = "  " .. data.EspAll
        
        -- Фикс моментального плейсхолдера:
        SignTextBoxOval.PlaceholderText = data.SignPlaceholder
        if SignTextBoxOval.Text == "" or SignTextBoxOval.Text == "Текст таблички..." or SignTextBoxOval.Text == "Sign text..." then
            SignTextBoxOval.Text = ""
        end
        
        if not selectedTargetPlayer then
            PlrSelectNickText.Text = data.SelectPlrHolder
        end
        
        WriteSignButton.Text = data.WriteBtn

        for _, tKey in ipairs(bhTabsList) do
            if bhButtons[tKey] then
                bhButtons[tKey].Text = data["T_" .. tKey] or tKey
            end
        end

        for _, slider in ipairs(sliders) do slider.Refresh() end
        BigOvalText.Text = selectedGame or data.SelectGame
        CheckGameTabs(selectedGame)
    end

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

    for i, gameName in ipairs(GamesList) do
        local GameBtn = Instance.new("TextButton", GamesDropdownContainer)
        GameBtn.Size = UDim2.new(1, -10, 0, 26)
        GameBtn.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 30)
        GameBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        GameBtn.Text = "  " .. gameName
        GameBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        GameBtn.Font = Enum.Font.SourceSansBold
        GameBtn.TextSize = 13
        GameBtn.ZIndex = 17
        GameBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", GameBtn).CornerRadius = UDim.new(0, 6)

        GameBtn.Activated:Connect(function()
            selectedGame = gameName
            GamesDropdownContainer.Visible = false
            TweenService:Create(ArrowIcon2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
            UpdateLocalization()
            LayoutUI(true)
        end)
    end

    DevelopersBlock.Name = "DevelopersBlock"
    DevelopersBlock.Size = UDim2.new(1, 0, 0, 145) 
    DevelopersBlock.BackgroundTransparency = 1
    DevelopersBlock.Parent = GreyFrame
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
    DevsText.Font = Enum.Font.SourceSansBold
    DevsText.TextSize = 14
    DevsText.TextWrapped = true
    DevsText.TextXAlignment = Enum.TextXAlignment.Left
    DevsText.TextYAlignment = Enum.TextYAlignment.Top
    DevsText.ZIndex = 5

    local function DetectCurrentGame()
        local pId = game.PlaceId
        local gId = game.GameId
        if pId == 492414483 or pId == 212640215 or gId == 212640215 or gId == 492414483 then return "Brookhaven"
        elseif pId == 537413550 or gId == 537413550 then return "BABFT"
        elseif pId == 9872472334 or gId == 9872472334 then return "Evade"
        elseif pId == 142823291 or gId == 142823291 then return "Murder Mystery 2"
        elseif pId == 2753915549 or gId == 2753915549 then return "Blox Fruits"
        end
        return nil
    end
    selectedGame = DetectCurrentGame()

    local function ClearTabStyles()
        SettingsButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        SettingsButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        PlayerButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        PlayerButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TargetPlayersButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        TargetPlayersButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        
        for _, btn in pairs(bhButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        for _, frame in pairs(CentralFrames) do
            frame.Visible = false
        end
    end

    SettingsButton.Activated:Connect(function()
        ClearTabStyles()
        currentTab = "Settings"
        SettingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CentralFrames["Settings"].Visible = true
    end)

    PlayerButton.Activated:Connect(function()
        ClearTabStyles()
        currentTab = "Player"
        PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CentralFrames["Player"].Visible = true
    end)

    TargetPlayersButton.Activated:Connect(function()
        ClearTabStyles()
        currentTab = "Players"
        TargetPlayersButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TargetPlayersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CentralFrames["Players"].Visible = true
    end)

    for _, tKey in ipairs(bhTabsList) do
        if bhButtons[tKey] then
            bhButtons[tKey].Activated:Connect(function()
                ClearTabStyles()
                currentTab = tKey
                bhButtons[tKey].BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                bhButtons[tKey].TextColor3 = Color3.fromRGB(255, 255, 255)
                CentralFrames[tKey].Visible = true
            end)
        end
    end

    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    DropdownBtn1.Activated:Connect(function()
        local isOpening = not DropdownContainer1.Visible
        DropdownContainer1.Visible = isOpening
        if isOpening then
            GamesDropdownContainer.Visible = false 
            TweenService:Create(ArrowIcon2, tweenInfo, {Rotation = 0}):Play()
            TweenService:Create(ArrowIcon1, tweenInfo, {Rotation = 180}):Play()
        else
            TweenService:Create(ArrowIcon1, tweenInfo, {Rotation = 0}):Play()
        end
        LayoutUI(true)
    end)

    BigBottomOval.Activated:Connect(function()
        local isOpening = not GamesDropdownContainer.Visible
        GamesDropdownContainer.Visible = isOpening
        if isOpening then
            DropdownContainer1.Visible = false 
            TweenService:Create(ArrowIcon1, tweenInfo, {Rotation = 0}):Play()
            TweenService:Create(ArrowIcon2, tweenInfo, {Rotation = 180}):Play()
        else
            TweenService:Create(ArrowIcon2, tweenInfo, {Rotation = 0}):Play()
        end
        LayoutUI(true)
    end)

    CloseBtn.Activated:Connect(function() 
        ScreenGui:Destroy() 
        MobileShiftLockBtn:Destroy()
    end)

    MinimizeBtn.Activated:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            SideTab.Visible = false
            for _, frame in pairs(CentralFrames) do frame.Visible = false end
            DropdownContainer1.Visible = false
            GamesDropdownContainer.Visible = false
            TweenService:Create(ArrowIcon1, tweenInfo, {Rotation = 0}):Play()
            TweenService:Create(ArrowIcon2, tweenInfo, {Rotation = 0}):Play()
            MenuScale.Scale = 1 
            MainFrame.Size = UDim2.new(0, 420, 0, 44)
        else
            SideTab.Visible = true
            if CentralFrames[currentTab] then CentralFrames[currentTab].Visible = true end
            LayoutUI(false)
            UpdateGeometry()
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if isInvisible then
            task.wait(0.1)
            UpdateCharacterTransparency(newChar, 1)
        end
    end)

    UpdateLocalization()
    LayoutUI(false)
end)

if not success then
    warn("Ошибка GUI: " .. tostring(err))
end
