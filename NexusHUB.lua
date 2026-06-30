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
    local antiAfkEnabled = false
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

    -- Состояния вкладки Килл
    local selectedKillPlayer = nil
    local selectedTpPlayer = nil
    local selectedKillMethod = "Sofa (Диван)"
    local killLoopActive = true
    local flingLoopActive = true

    local Camera = Workspace.CurrentCamera
    local startPosition = nil -- Для захвата диваном

    -------------------------------------------------------
    -- ТАБЛИЦА ЛОКАЛИЗАЦИИ (РАСШИРЕННАЯ)
    -------------------------------------------------------
    local Localization = {
        ["English"] = {
            LangLabel = "Language", SelectGame = "Select a game...", 
            Interface = "Interface", Size = "Size", Length = "Length", Width = "Width",
            GamesTitle = "Games", DevsTitle = "Developers", Settings = "Settings",
            WalkSpeed = "WalkSpeed", JumpPower = "JumpPower", Gravity = "Gravity", ResetBtn = "Reset",
            InvisibleText = "Invisible", ToolBtn = "Menu UI", AntiSit = "Anti-Sit", AntiAFK = "Anti-AFK",
            PlayerTab = "Player", InfJump = "Infinite Jump", SwimMode = "Swim Mode",
            Noclip = "Noclip", GravZero = "Space Gravity", ShiftLock = "Shift Lock",
            AutoUnban = "Auto Unban", SitBtn = "Sit Menu", FlyBtn = "Fly Menu", SitAction = "Sit Now",
            DevsText = "Design: Won4sko\n\nCoding: Won4sko\n\nFeatures: Won4sko, Gemini, DeepSeek.",
            T_Players = "Players", T_Kill = "Kill", T_Teleport = "Teleport", T_Items = "Items",
            T_Skin = "Skin", T_Car = "Car", T_House = "House", T_Music = "Music",
            T_Emotes = "Emotes", T_Troll = "Troll", T_Defense = "Defense", T_Server = "Server",
            FOVText = "Field of View", SelectPlrTitle = "Select Player", TeleportTo = "Teleport to Player",
            SpectatePlr = "Spectate Player", FollowPlr = "Follow Player: OFF", FollowPlrOn = "Follow Player: ON", 
            EspPlr = "ESP Player", EspAll = "ESP All Players",
            SignPlaceholder = "Sign text...", WriteBtn = "Write", GetTool = "Select (Tool)", 
            SelectPlrHolder = "Select player...", SelectMethod = "Select kill method...",
            FastKill = "Fast Kill (Tool)", AutoKillPlr = "Auto-Kill Target", AutoKillAll = "Auto-Kill All",
            AutoManualKill = "Auto-Manual Kill", StopKills = "Stop Kills", FlingPlr = "Fling Target",
            FlingAll = "Fling All Players", FlingDoors = "Fling Doors", StopFling = "Stop Fling",
            AutoGetSofa = "Auto Get Sofa", GetRemoveSofa = "Get/Remove Sofa", SofaKidnap = "Sofa Kidnap To Start",
            SelectLocHolder = "Select Brookhaven Location...", TeleportTitle = "Teleport",
            TeleportToLoc = "Teleport to Location", TeleportToPlr = "Teleport to Player"
        },
        ["Русский"] = {
            LangLabel = "Язык", SelectGame = "Выбрать игру...", 
            Interface = "Интерфейс", Size = "Размер", Length = "Длина", Width = "Ширина",
            GamesTitle = "Игры", DevsTitle = "Разработчики", Settings = "Настройки",
            WalkSpeed = "Скорость бега", JumpPower = "Сила прыжка", Gravity = "Гравитация", ResetBtn = "Сброс",
            InvisibleText = "Невидимость", ToolBtn = "Менюшка", AntiSit = "Анти-сидеть", AntiAFK = "Анти-АФК",
            PlayerTab = "Игрок", InfJump = "Бесконечный прыжок", SwimMode = "Плавать",
            Noclip = "Ноклип", GravZero = "Космическая Гравитация", ShiftLock = "Блокировка Шифт",
            AutoUnban = "Авто Разбан (Дома)", SitBtn = "Сидеть", FlyBtn = "Летать", SitAction = "Нажмите, чтобы сесть",
            DevsText = "Дизайн: Won4sko\n\nКодинг: Won4sko\n\nФункции: Won4sko, Gemini, DeepSeek.",
            T_Players = "Игроки", T_Kill = "Килл", T_Teleport = "Телепорт", T_Items = "Предметы",
            T_Skin = "Скин", T_Car = "Машина", T_House = "Дом", T_Music = "Музыка",
            T_Emotes = "Эмоции", T_Troll = "Тролль", T_Defense = "Защита", T_Server = "Сервер",
            FOVText = "Поле зрения (FOV)", SelectPlrTitle = "Выбор игрока", TeleportTo = "Телепорт к игроку",
            SpectatePlr = "Наблюдать за игроком", FollowPlr = "Следовать за игроком: ВЫКЛ", FollowPlrOn = "Следовать за игроком: ВКЛ",
            EspPlr = "Подсветить игрока", EspAll = "Подсветить всех",
            SignPlaceholder = "Текст таблички...", WriteBtn = "Написать", GetTool = "Выбрать (Tool)", 
            SelectPlrHolder = "Выберите игрока...", SelectMethod = "Выберите способ килла...",
            FastKill = "Быстрый килл (Tool)", AutoKillPlr = "АвтоКилл выбранного игрока", AutoKillAll = "АвтоКилл всех игроков",
            AutoManualKill = "Авто ручной килл", StopKills = "Остановить киллы", FlingPlr = "Флинг выбранного игрока",
            FlingAll = "Флинг всех игроков", FlingDoors = "Флинг дверей", StopFling = "Остановить флинг",
            AutoGetSofa = "Авто получение дивана", GetRemoveSofa = "Получить/Удалить Диван", SofaKidnap = "Захват диваном на старт",
            SelectLocHolder = "Выберите локацию Брукхейвена...", TeleportTitle = "Телепорт",
            TeleportToLoc = "Телепорт к Локации", TeleportToPlr = "Телепорт к игроку"
        },
        ["العربية"] = {
            LangLabel = "اللغة", SelectGame = "اختر لعبة...", 
            Interface = "الواجهة", Size = "الحجم", Length = "الطول", Width = "العرض",
            GamesTitle = "الألعاب", DevsTitle = "المطورين", Settings = "الإعدادات",
            WalkSpeed = "سرعة المشي", JumpPower = "قوة القفز", Gravity = "الجاذبية", ResetBtn = "إعادة",
            InvisibleText = "اختفاء", ToolBtn = "قائمة", AntiSit = "منع الجلوس", AntiAFK = "ضد الأفلاق",
            PlayerTab = "لاعب", InfJump = "قفز لا نهائي", SwimMode = "وضع السباحة",
            Noclip = "اختراق الجدران", GravZero = "جاذبية الفضاء", ShiftLock = "قفل التحويل",
            AutoUnban = "إلغاء الحظر التلقائي", SitBtn = "جلوس", FlyBtn = "طيران", SitAction = "اضغط للجلوس",
            DevsText = "Won4sko :التصميم\n\nWon4sko :البرمجة\n\nWon4sko, Gemini, DeepSeek. :الميزات",
            T_Players = "اللاعبين", T_Kill = "قتل", T_Teleport = "انتقال", T_Items = "العناصر",
            T_Skin = "المظهر", T_Car = "سيارة", T_House = "منزل", T_Music = "موسيقى",
            T_Emotes = "تعبيرات", T_Troll = "مقلب", T_Defense = "حماية", T_Server = "خادم",
            FOVText = "مجال الرؤية", SelectPlrTitle = "اختر لاعب", TeleportTo = "انتقال للاعب",
            SpectatePlr = "مراقبة اللاعب", FollowPlr = "اتبع اللاعب", EspPlr = "تحديد اللاعب", EspAll = "تحديد الكل",
            SignPlaceholder = "نص اللوحة...", WriteBtn = "كتابة", GetTool = "اختر أداة", 
            SelectPlrHolder = "اختر لاعب...", SelectMethod = "اختر طريقة القتل...",
            FastKill = "قتل سريع (أداة)", AutoKillPlr = "قتل تلقائي للهدف", AutoKillAll = "قتل تلقائي للجميع",
            AutoManualKill = "قتل يدوي تلقائي", StopKills = "إيقاف القتل", FlingPlr = "قذف الهدف",
            FlingAll = "قذف جميع اللاعبين", FlingDoors = "قذف الأبواب", StopFling = "إيقاف القذف",
            AutoGetSofa = "الحصول على أريكة تلقائي", GetRemoveSofa = "الحصول/إزالة الأريكة", SofaKidnap = "اختطاف بالأريكة",
            SelectLocHolder = "اختر موقع بروكهافن...", TeleportTitle = "انتقال",
            TeleportToLoc = "انتقال إلى الموقع", TeleportToPlr = "انتقال إلى اللاعب"
        },
        ["Español"] = {
            LangLabel = "Idioma", SelectGame = "Seleccionar juego...", 
            Interface = "Interfaz", Size = "Tamaño", Length = "Longitud", Width = "Ancho",
            GamesTitle = "Juegos", DevsTitle = "Devs", Settings = "Ajustes",
            WalkSpeed = "Velocidad", JumpPower = "Fuerza de Salto", Gravity = "Gravedad", ResetBtn = "Reiniciar",
            InvisibleText = "Invisibilidad", ToolBtn = "Menú UI", AntiSit = "Anti-Asiento", AntiAFK = "Anti-AFK",
            PlayerTab = "Jugador", InfJump = "Salto Infinito", SwimMode = "Modo Nadar",
            Noclip = "Noclip", GravZero = "Gravedad Espacial", ShiftLock = "Shift Lock",
            AutoUnban = "Auto Desbanear", SitBtn = "Sentarse", FlyBtn = "Volar", SitAction = "Haz clic para sentarte",
            DevsText = "Diseño: Won4sko\n\nCódigo: Won4sko\n\nFunciones: Won4sko, Gemini, DeepSeek.",
            T_Players = "Jugadores", T_Kill = "Kill", T_Teleport = "Teleport", T_Items = "Objetos",
            T_Skin = "Skin", T_Car = "Coche", T_House = "Casa", T_Music = "Música",
            T_Emotes = "Emociones", T_Troll = "Troll", T_Defense = "Defensa", T_Server = "Servidor",
            FOVText = "Campo de Visión", SelectPlrTitle = "Seleccionar Jugador", TeleportTo = "Teletransportarse al jugador",
            SpectatePlr = "Espectar jugador", FollowPlr = "Seguir jugador: OFF", FollowPlrOn = "Seguir jugador: ON",
            EspPlr = "Resaltar jugador", EspAll = "Resaltar a todos",
            SignPlaceholder = "Texto del cartel...", WriteBtn = "Escribir", GetTool = "Obtener herramienta",
            SelectPlrHolder = "Seleccionar jugador...", SelectMethod = "Seleccionar método de kill...",
            FastKill = "Kill rápido (Herramienta)", AutoKillPlr = "Auto-Kill objetivo", AutoKillAll = "Auto-Kill todos",
            AutoManualKill = "Auto-Kill manual", StopKills = "Detener kills", FlingPlr = "Fling objetivo",
            FlingAll = "Fling todos los jugadores", FlingDoors = "Fling puertas", StopFling = "Detener Fling",
            AutoGetSofa = "Obtener sofá automático", GetRemoveSofa = "Obtener/Eliminar Sofá", SofaKidnap = "Secuestro con sofá",
            SelectLocHolder = "Seleccionar ubicación de Brookhaven...", TeleportTitle = "Teletransporte",
            TeleportToLoc = "Teletransportarse a Ubicación", TeleportToPlr = "Teletransportarse a Jugador"
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

    -- Логика Анти-АФК
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if antiAfkEnabled then
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end
        end)
    end)

    -- Наземный кастомный СТИЛЬНЫЙ КРУГЛЫЙ Shift-Lock с линиями по бокам
    local MobileShiftLockBtn = Instance.new("TextButton", ScreenGui)
    MobileShiftLockBtn.Name = "MobileShiftLockBtn"
    MobileShiftLockBtn.Size = UDim2.new(0, 65, 0, 65)
    MobileShiftLockBtn.Position = UDim2.new(0.82, 0, 0.65, 0)
    MobileShiftLockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MobileShiftLockBtn.BackgroundTransparency = 0.2
    MobileShiftLockBtn.Text = ""
    MobileShiftLockBtn.Visible = true
    Instance.new("UICorner", MobileShiftLockBtn).CornerRadius = UDim.new(1, 0)
    local SLStroke = Instance.new("UIStroke", MobileShiftLockBtn)
    SLStroke.Color = Color3.fromRGB(255, 255, 255)
    SLStroke.Thickness = 2.5

    local LeftLine = Instance.new("Frame", MobileShiftLockBtn)
    LeftLine.Size = UDim2.new(0, 3, 0, 25)
    LeftLine.Position = UDim2.new(0, -10, 0.5, 0)
    LeftLine.AnchorPoint = Vector2.new(0, 0.5)
    LeftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", LeftLine).CornerRadius = UDim.new(0, 2)

    local RightLine = Instance.new("Frame", MobileShiftLockBtn)
    RightLine.Size = UDim2.new(0, 3, 0, 25)
    RightLine.Position = UDim2.new(1, 7, 0.5, 0)
    RightLine.AnchorPoint = Vector2.new(0, 0.5)
    RightLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", RightLine).CornerRadius = UDim.new(0, 2)

    local InnerCircle = Instance.new("Frame", MobileShiftLockBtn)
    InnerCircle.Size = UDim2.new(0, 16, 0, 16)
    InnerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", InnerCircle).CornerRadius = UDim.new(1, 0)

    MobileShiftLockBtn.Activated:Connect(function()
        shiftLockEnabled = not shiftLockEnabled
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if shiftLockEnabled then
            TweenService:Create(MobileShiftLockBtn, tInfo, {BackgroundColor3 = Color3.fromRGB(0, 200, 200), BackgroundTransparency = 0.1}):Play()
            TweenService:Create(SLStroke, tInfo, {Color = Color3.fromRGB(0, 255, 255)}):Play()
            TweenService:Create(LeftLine, tInfo, {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
            TweenService:Create(RightLine, tInfo, {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
        else
            TweenService:Create(MobileShiftLockBtn, tInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), BackgroundTransparency = 0.2}):Play()
            TweenService:Create(SLStroke, tInfo, {Color = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(LeftLine, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(RightLine, tInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
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
        if shiftLockEnabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                local lookVector = Camera.CFrame.LookVector
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            end
        end
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
    local KillFrame = CreateCentralScroll("Kill")
    local TeleportFrame = CreateCentralScroll("Teleport")
    
    local pListLayout = Instance.new("UIListLayout", PlayerFrame)
    pListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pListLayout.Padding = UDim.new(0, 0) 

    local tpListLayout = Instance.new("UIListLayout", TargetPlayersFrame)
    tpListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tpListLayout.Padding = UDim.new(0, 10)
    tpListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local kListLayout = Instance.new("UIListLayout", KillFrame)
    kListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    kListLayout.Padding = UDim.new(0, 10)
    kListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    for _, tKey in ipairs(bhTabsList) do
        if tKey ~= "Kill" and tKey ~= "Teleport" then 
            CreateCentralScroll(tKey) 
        end
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
    CreateToggleSwitch(PlayerFrame, "AntiAFK", 45, function() return antiAfkEnabled end, function() antiAfkEnabled = not antiAfkEnabled end)
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

    LeftGreyOvalBtn.Activated:Connect(ToggleInvisible)

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

    local FinalSpacerPlayer = Instance.new("Frame", PlayerFrame)
    FinalSpacerPlayer.Size = UDim2.new(1, 0, 0, 15)
    FinalSpacerPlayer.BackgroundTransparency = 1
    FinalSpacerPlayer.LayoutOrder = 120

    PlayerFrame.CanvasSize = UDim2.new(0, 0, 0, 600)

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

    -------------------------------------------------------
    -- ВЫДЕЛЕННАЯ КОМПЛЕКСНАЯ ВКЛАДКА "PLAYERS" (ИГРОКИ)
    -------------------------------------------------------
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
    PlrSelectNickText.TextColor3 = Color3.fromRGB(170, 170, 170)
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
                pBtn.Text = "  " .. player.Name .. " (" .. player.DisplayName .. ")"
                pBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                pBtn.Font = Enum.Font.SourceSansBold
                pBtn.TextSize = 12
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.ZIndex = 11
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)

                pBtn.Activated:Connect(function()
                    selectedTargetPlayer = player
                    PlrSelectNickText.Text = player.Name
                    PlrSelectNickText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    PlrDropdownListFrame.Visible = false
                    TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
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
            TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 540)
        else
            PlrDropdownListFrame.Size = UDim2.new(1, -12, 0, 0)
            TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
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

    local function SetupToolSelection(callback)
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
                            callback(clickedPlr)
                        end
                    end
                else
                    connection:Disconnect()
                end
            end)
        end)
        targetTool.Parent = backpack
    end

    GetToolButton.Activated:Connect(function()
        SetupToolSelection(function(clickedPlr)
            selectedTargetPlayer = clickedPlr
            PlrSelectNickText.Text = clickedPlr.Name
            PlrSelectNickText.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
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
            FollowLbl.Text = "  " .. Localization[currentLanguage].FollowPlrOn
        else
            TweenService:Create(FollowTFrame, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            TweenService:Create(FollowTCircle, tInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            FollowLbl.Text = "  " .. Localization[currentLanguage].FollowPlr
        end
    end)

    -- КНОПКА ЗАХВАТ ДИВАНОМ НА СТАРТ
    local KidnapBtn = Instance.new("TextButton", TargetPlayersFrame)
    KidnapBtn.Size = UDim2.new(1, -16, 0, 35)
    KidnapBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 150)
    KidnapBtn.Text = Localization[currentLanguage].SofaKidnap
    KidnapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    KidnapBtn.Font = Enum.Font.SourceSansBold
    KidnapBtn.ZIndex = 5
    Instance.new("UICorner", KidnapBtn).CornerRadius = UDim.new(0, 8)

    KidnapBtn.Activated:Connect(function()
        if selectedTargetPlayer and selectedTargetPlayer.Character then
            local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tRoot = selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if pRoot and tRoot then
                -- Сохраняем начальную позицию
                startPosition = pRoot.CFrame
                
                -- Берем диван
                local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                local sofaTool = nil
                if bp then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                            sofaTool = tool
                            break
                        end
                    end
                end
                if not sofaTool then
                    -- Поиск в Character
                    local char = LocalPlayer.Character
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                                sofaTool = tool
                                break
                            end
                        end
                    end
                end
                
                if sofaTool then
                    sofaTool.Parent = LocalPlayer.Character
                    task.wait(0.2)
                    
                    -- Телепортируем к игроку
                    pRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -2)
                    task.wait(1)
                    
                    -- Захватываем и телепортируем на старт
                    pRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                    task.wait(0.3)
                    pRoot.CFrame = startPosition
                    tRoot.CFrame = startPosition * CFrame.new(0, 0, 2)
                end
            end
        end
    end)

    -- Остальные элементы Players (ESP, Sign и т.д.)
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
                local hl = selectedTargetPlayer.Character:FindFirstChild("NexusPlrESP") or Instance.new("Highlight")
                hl.Name = "NexusPlrESP"
                hl.FillColor = Color3.fromRGB(0, 120, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = selectedTargetPlayer.Character

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
                if selectedTargetPlayer.Character:FindFirstChild("NexusPlrESP") then selectedTargetPlayer.Character.NexusPlrESP:Destroy() end
                if selectedTargetPlayer.Character:FindFirstChild("NexusEspBillboard") then selectedTargetPlayer.Character.NexusEspBillboard:Destroy() end
            end
        end
    end)

    local PlrSeparatorLineBeforeAll = Instance.new("Frame", TargetPlayersFrame)
    PlrSeparatorLineBeforeAll.Size = UDim2.new(1, -10, 0, 2)
    PlrSeparatorLineBeforeAll.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    PlrSeparatorLineBeforeAll.ZIndex = 4

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

    local PlrSeparatorLine2 = Instance.new("Frame", TargetPlayersFrame)
    PlrSeparatorLine2.Size = UDim2.new(1, -10, 0, 2)
    PlrSeparatorLine2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    PlrSeparatorLine2.ZIndex = 4

    local SignTextBoxOval = Instance.new("TextBox", TargetPlayersFrame)
    SignTextBoxOval.Size = UDim2.new(0.85, 0, 0, 32)
    SignTextBoxOval.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    SignTextBoxOval.Font = Enum.Font.SourceSansBold
    SignTextBoxOval.TextColor3 = Color3.fromRGB(255, 255, 255)
    SignTextBoxOval.TextSize = 13
    SignTextBoxOval.Text = "" 
    SignTextBoxOval.ZIndex = 5
    Instance.new("UICorner", SignTextBoxOval).CornerRadius = UDim.new(0, 16)
    local SignStroke = Instance.new("UIStroke", SignTextBoxOval)
    SignStroke.Color = Color3.fromRGB(70, 70, 70)
    SignStroke.Thickness = 1

    local WriteSignButton = Instance.new("TextButton", TargetPlayersFrame)
    WriteSignButton.Size = UDim2.new(0.6, 0, 0, 28)
    WriteSignButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35) 
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

    local FinalSpacerPlayersTab = Instance.new("Frame", TargetPlayersFrame)
    FinalSpacerPlayersTab.Size = UDim2.new(1, 0, 0, 45)
    FinalSpacerPlayersTab.BackgroundTransparency = 1
    FinalSpacerPlayersTab.ZIndex = 3

    TargetPlayersFrame.CanvasSize = UDim2.new(0, 0, 0, 520)

    -------------------------------------------------------
    -- ВЫДЕЛЕННАЯ ВКЛАДКА "KILL" (КИЛЛ) - РАСШИРЕННАЯ
    -------------------------------------------------------
    local TopSpacerKill = Instance.new("Frame", KillFrame)
    TopSpacerKill.Size = UDim2.new(1, 0, 0, 10)
    TopSpacerKill.BackgroundTransparency = 1
    TopSpacerKill.ZIndex = 3

    -- Выбор метода Килла (ОВАЛ С ВЫПАДАЮЩИМ СПИСКОМ)
    local KillMethodBtn = Instance.new("TextButton", KillFrame)
    KillMethodBtn.Size = UDim2.new(1, -16, 0, 32)
    KillMethodBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    KillMethodBtn.Text = Localization[currentLanguage].SelectMethod
    KillMethodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillMethodBtn.ZIndex = 5
    Instance.new("UICorner", KillMethodBtn).CornerRadius = UDim.new(0, 8)

    local KillMethodArrow = Instance.new("TextLabel", KillMethodBtn)
    KillMethodArrow.Size = UDim2.new(0, 12, 0, 12)
    KillMethodArrow.BackgroundTransparency = 1
    KillMethodArrow.Text = "▼"
    KillMethodArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    KillMethodArrow.Font = Enum.Font.SourceSansBold
    KillMethodArrow.TextSize = 10
    KillMethodArrow.Position = UDim2.new(1, -16, 0.5, -6)
    KillMethodArrow.ZIndex = 6

    local KillMethodDropdown = Instance.new("Frame", KillFrame)
    KillMethodDropdown.Size = UDim2.new(1, -16, 0, 0)
    KillMethodDropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    KillMethodDropdown.Visible = false
    KillMethodDropdown.ZIndex = 6
    KillMethodDropdown.ClipsDescendants = true
    Instance.new("UICorner", KillMethodDropdown).CornerRadius = UDim.new(0, 8)

    local killMethods = {"Sofa (Диван)", "Fling (Выталкивание)", "Tools (Инструменты)"}
    selectedKillMethod = killMethods[1]
    for i, m in ipairs(killMethods) do
        local b = Instance.new("TextButton", KillMethodDropdown)
        b.Size = UDim2.new(1, 0, 0, 24)
        b.BackgroundTransparency = 1
        b.Text = m
        b.TextColor3 = Color3.fromRGB(200, 200, 200)
        b.Font = Enum.Font.SourceSans
        b.TextSize = 13
        b.Activated:Connect(function()
            selectedKillMethod = m
            KillMethodBtn.Text = "Метод: " .. m
            KillMethodDropdown.Visible = false
            KillMethodDropdown.Size = UDim2.new(1, -16, 0, 0)
        end)
    end

    KillMethodBtn.Activated:Connect(function()
        KillMethodDropdown.Visible = not KillMethodDropdown.Visible
        KillMethodDropdown.Size = KillMethodDropdown.Visible and UDim2.new(1, -16, 0, #killMethods * 24 + 8) or UDim2.new(1, -16, 0, 0)
    end)

    -- Выбор игрока для килла
    local KillSelectMainFrame = Instance.new("Frame", KillFrame)
    KillSelectMainFrame.Size = UDim2.new(1, -12, 0, 36)
    KillSelectMainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KillSelectMainFrame.ZIndex = 4
    Instance.new("UICorner", KillSelectMainFrame).CornerRadius = UDim.new(0, 18)

    local KillSelectLeftTitle = Instance.new("TextLabel", KillSelectMainFrame)
    KillSelectLeftTitle.Size = UDim2.new(0.35, 0, 1, 0)
    KillSelectLeftTitle.Position = UDim2.new(0, 14, 0, 0)
    KillSelectLeftTitle.BackgroundTransparency = 1
    KillSelectLeftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillSelectLeftTitle.Font = Enum.Font.SourceSansBold
    KillSelectLeftTitle.TextSize = 13
    KillSelectLeftTitle.TextXAlignment = Enum.TextXAlignment.Left
    KillSelectLeftTitle.ZIndex = 5

    local KillSelectRightOval = Instance.new("TextButton", KillSelectMainFrame)
    KillSelectRightOval.Size = UDim2.new(0.6, 0, 0, 26)
    KillSelectRightOval.Position = UDim2.new(1, -6, 0.5, -13)
    KillSelectRightOval.AnchorPoint = Vector2.new(1, 0)
    KillSelectRightOval.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    KillSelectRightOval.Text = ""
    KillSelectRightOval.ZIndex = 5
    Instance.new("UICorner", KillSelectRightOval).CornerRadius = UDim.new(0, 13)

    local KillSelectNickText = Instance.new("TextLabel", KillSelectRightOval)
    KillSelectNickText.Size = UDim2.new(1, -22, 1, 0)
    KillSelectNickText.Position = UDim2.new(0, 10, 0, 0)
    KillSelectNickText.BackgroundTransparency = 1
    KillSelectNickText.Text = ""
    KillSelectNickText.TextColor3 = Color3.fromRGB(170, 170, 170)
    KillSelectNickText.Font = Enum.Font.SourceSansBold
    KillSelectNickText.TextSize = 11
    KillSelectNickText.TextXAlignment = Enum.TextXAlignment.Left
    KillSelectNickText.ZIndex = 6

    local KillSelectArrow = Instance.new("TextLabel", KillSelectRightOval)
    KillSelectArrow.Size = UDim2.new(0, 12, 0, 12)
    KillSelectArrow.Position = UDim2.new(1, -16, 0.5, -6)
    KillSelectArrow.BackgroundTransparency = 1
    KillSelectArrow.Text = "▼"
    KillSelectArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillSelectArrow.Font = Enum.Font.SourceSansBold
    KillSelectArrow.TextSize = 9
    KillSelectArrow.ZIndex = 6

    local KillDropdownListFrame = Instance.new("ScrollingFrame", KillFrame)
    KillDropdownListFrame.Size = UDim2.new(1, -12, 0, 0)
    KillDropdownListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    KillDropdownListFrame.Visible = false
    KillDropdownListFrame.ZIndex = 10
    KillDropdownListFrame.ScrollBarThickness = 3
    Instance.new("UICorner", KillDropdownListFrame).CornerRadius = UDim.new(0, 10)
    local kdlLayout = Instance.new("UIListLayout", KillDropdownListFrame)
    kdlLayout.Padding = UDim.new(0, 4)

    local function RefreshKillDropdown()
        for _, c in ipairs(KillDropdownListFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local index = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                index = index + 1
                local pBtn = Instance.new("TextButton", KillDropdownListFrame)
                pBtn.Size = UDim2.new(1, -8, 0, 24)
                pBtn.Position = UDim2.new(0, 4, 0, 0)
                pBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
                pBtn.Text = "  " .. player.Name
                pBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                pBtn.Font = Enum.Font.SourceSansBold
                pBtn.TextSize = 12
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.ZIndex = 11
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)

                pBtn.Activated:Connect(function()
                    selectedKillPlayer = player
                    KillSelectNickText.Text = player.Name
                    KillSelectNickText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    KillDropdownListFrame.Visible = false
                end)
            end
        end
        KillDropdownListFrame.CanvasSize = UDim2.new(0, 0, 0, index * 28 + 10)
    end

    KillSelectRightOval.Activated:Connect(function()
        KillDropdownListFrame.Visible = not KillDropdownListFrame.Visible
        if KillDropdownListFrame.Visible then
            RefreshKillDropdown()
            KillDropdownListFrame.Size = UDim2.new(1, -12, 0, 90)
        else
            KillDropdownListFrame.Size = UDim2.new(1, -12, 0, 0)
        end
    end)

    local GetKillToolButton = Instance.new("TextButton", KillFrame)
    GetKillToolButton.Size = UDim2.new(1, -16, 0, 30)
    GetKillToolButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    GetKillToolButton.Font = Enum.Font.SourceSansBold
    GetKillToolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKillToolButton.TextSize = 13
    GetKillToolButton.ZIndex = 5
    Instance.new("UICorner", GetKillToolButton).CornerRadius = UDim.new(0, 8)

    GetKillToolButton.Activated:Connect(function()
        SetupToolSelection(function(clickedPlr)
            selectedKillPlayer = clickedPlr
            KillSelectNickText.Text = clickedPlr.Name
            KillSelectNickText.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local KillSeparatorLine1 = Instance.new("Frame", KillFrame)
    KillSeparatorLine1.Size = UDim2.new(1, -10, 0, 2)
    KillSeparatorLine1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    KillSeparatorLine1.ZIndex = 4

    -- БЫСТРЫЙ КИЛЛ (Tool) - убивает сразу выбранным методом
    local FastKillBtn = Instance.new("TextButton", KillFrame)
    FastKillBtn.Size = UDim2.new(1, -16, 0, 35)
    FastKillBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    FastKillBtn.Text = Localization[currentLanguage].FastKill
    FastKillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FastKillBtn.Font = Enum.Font.SourceSansBold
    FastKillBtn.ZIndex = 5
    Instance.new("UICorner", FastKillBtn).CornerRadius = UDim.new(0, 8)

    FastKillBtn.Activated:Connect(function()
        if selectedKillPlayer and selectedKillPlayer.Character then
            local hum = selectedKillPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if selectedKillMethod == "Sofa (Диван)" then
                    -- Ищем диван
                    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                    local sofaTool = nil
                    if bp then
                        for _, tool in ipairs(bp:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                                sofaTool = tool
                                break
                            end
                        end
                    end
                    if sofaTool then
                        sofaTool.Parent = LocalPlayer.Character
                        task.wait(0.1)
                        local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot and tRoot then
                            pRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                            task.wait(0.3)
                            hum.Health = 0
                        end
                    else
                        hum.Health = 0 -- если нет дивана, просто убиваем
                    end
                elseif selectedKillMethod == "Fling (Выталкивание)" then
                    local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot and tRoot then
                        tRoot.Velocity = Vector3.new(0, 1000, 0)
                        task.wait(0.1)
                        hum.Health = 0
                    end
                else -- Tools (Инструменты)
                    hum.Health = 0
                end
            end
        end
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local KillSeparatorLine2 = Instance.new("Frame", KillFrame)
    KillSeparatorLine2.Size = UDim2.new(1, -10, 0, 2)
    KillSeparatorLine2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    KillSeparatorLine2.ZIndex = 4

    -- ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ СОЗДАНИЯ ПЕРЕТЯГОВ
    local function CreateKillToggle(parent, textKey, layoutOrder, stateRef, onToggle)
        local TContainer = Instance.new("Frame", parent)
        TContainer.Size = UDim2.new(1, -16, 0, 35)
        TContainer.BackgroundTransparency = 1
        TContainer.LayoutOrder = layoutOrder or 10
        TContainer.ZIndex = 4

        local TLbl = Instance.new("TextLabel", TContainer)
        TLbl.Size = UDim2.new(0.65, 0, 1, 0)
        TLbl.Position = UDim2.new(0, 10, 0, 0)
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

        return TContainer, TFrame, function() updateVisuals(stateRef()) end
    end

    -- АВТОКИЛЛЫ
    local autoKillPlrEnabled = false
    local autoKillAllEnabled = false
    local autoManualEnabled = false
    local killLoopActive = true

    local killContainer1, _, updateKillPlr = CreateKillToggle(KillFrame, Localization[currentLanguage].AutoKillPlr, 15, function() return autoKillPlrEnabled end, function() 
        autoKillPlrEnabled = not autoKillPlrEnabled
        killLoopActive = true
        if autoKillPlrEnabled or autoKillAllEnabled or autoManualEnabled then
            task.spawn(function()
                while killLoopActive and (autoKillPlrEnabled or autoKillAllEnabled or autoManualEnabled) do
                    if autoKillPlrEnabled and selectedKillPlayer and selectedKillPlayer.Character then
                        local hum = selectedKillPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if selectedKillMethod == "Sofa (Диван)" then
                                -- Поиск дивана
                                local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                                local sofaTool = nil
                                if bp then
                                    for _, tool in ipairs(bp:GetChildren()) do
                                        if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                                            sofaTool = tool
                                            break
                                        end
                                    end
                                end
                                if sofaTool then
                                    sofaTool.Parent = LocalPlayer.Character
                                    task.wait(0.1)
                                    local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if pRoot and tRoot then
                                        pRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                                        task.wait(0.3)
                                        hum.Health = 0
                                    end
                                else
                                    hum.Health = 0
                                end
                            elseif selectedKillMethod == "Fling (Выталкивание)" then
                                local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if pRoot and tRoot then
                                    tRoot.Velocity = Vector3.new(0, 1000, 0)
                                    task.wait(0.1)
                                    hum.Health = 0
                                end
                            else
                                hum.Health = 0
                            end
                        end
                    end

                    if autoKillAllEnabled then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                end
                            end
                        end
                    end

                    if autoManualEnabled then
                        -- Авто ручной килл - нужно просто убивать ближайшего игрока
                        local nearestDist = math.huge
                        local nearestPlayer = nil
                        local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            for _, player in ipairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                    if tRoot then
                                        local dist = (tRoot.Position - pRoot.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearestPlayer = player
                                        end
                                    end
                                end
                            end
                            if nearestPlayer and nearestPlayer.Character then
                                local hum = nearestPlayer.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end)

    local killContainer2, _, updateKillAll = CreateKillToggle(KillFrame, Localization[currentLanguage].AutoKillAll, 20, function() return autoKillAllEnabled end, function() 
        autoKillAllEnabled = not autoKillAllEnabled
        killLoopActive = true
        if autoKillPlrEnabled or autoKillAllEnabled or autoManualEnabled then
            task.spawn(function()
                while killLoopActive and (autoKillPlrEnabled or autoKillAllEnabled or autoManualEnabled) do
                    -- Логика та же, что и выше
                    if autoKillPlrEnabled and selectedKillPlayer and selectedKillPlayer.Character then
                        local hum = selectedKillPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if selectedKillMethod == "Sofa (Диван)" then
                                local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                                local sofaTool = nil
                                if bp then
                                    for _, tool in ipairs(bp:GetChildren()) do
                                        if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                                            sofaTool = tool
                                            break
                                        end
                                    end
                                end
                                if sofaTool then
                                    sofaTool.Parent = LocalPlayer.Character
                                    task.wait(0.1)
                                    local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if pRoot and tRoot then
                                        pRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                                        task.wait(0.3)
                                        hum.Health = 0
                                    end
                                else
                                    hum.Health = 0
                                end
                            elseif selectedKillMethod == "Fling (Выталкивание)" then
                                local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if pRoot and tRoot then
                                    tRoot.Velocity = Vector3.new(0, 1000, 0)
                                    task.wait(0.1)
                                    hum.Health = 0
                                end
                            else
                                hum.Health = 0
                            end
                        end
                    end

                    if autoKillAllEnabled then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                end
                            end
                        end
                    end

                    if autoManualEnabled then
                        local nearestDist = math.huge
                        local nearestPlayer = nil
                        local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            for _, player in ipairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                    if tRoot then
                                        local dist = (tRoot.Position - pRoot.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearestPlayer = player
                                        end
                                    end
                                end
                            end
                            if nearestPlayer and nearestPlayer.Character then
                                local hum = nearestPlayer.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end)

    local killContainer3, _, updateManual = CreateKillToggle(KillFrame, Localization[currentLanguage].AutoManualKill, 25, function() return autoManualEnabled end, function() 
        autoManualEnabled = not autoManualEnabled
        killLoopActive = true
        if autoKillPlrEnabled or autoKillAllEnabled or autoManualEnabled then
            task.spawn(function()
                while killLoopActive and (autoKillPlrEnabled or autoKillAllEnabled or autoManualEnabled) do
                    -- Та же логика
                    if autoKillPlrEnabled and selectedKillPlayer and selectedKillPlayer.Character then
                        local hum = selectedKillPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if selectedKillMethod == "Sofa (Диван)" then
                                local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                                local sofaTool = nil
                                if bp then
                                    for _, tool in ipairs(bp:GetChildren()) do
                                        if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                                            sofaTool = tool
                                            break
                                        end
                                    end
                                end
                                if sofaTool then
                                    sofaTool.Parent = LocalPlayer.Character
                                    task.wait(0.1)
                                    local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if pRoot and tRoot then
                                        pRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                                        task.wait(0.3)
                                        hum.Health = 0
                                    end
                                else
                                    hum.Health = 0
                                end
                            elseif selectedKillMethod == "Fling (Выталкивание)" then
                                local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if pRoot and tRoot then
                                    tRoot.Velocity = Vector3.new(0, 1000, 0)
                                    task.wait(0.1)
                                    hum.Health = 0
                                end
                            else
                                hum.Health = 0
                            end
                        end
                    end

                    if autoKillAllEnabled then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                end
                            end
                        end
                    end

                    if autoManualEnabled then
                        local nearestDist = math.huge
                        local nearestPlayer = nil
                        local pRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if pRoot then
                            for _, player in ipairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                    if tRoot then
                                        local dist = (tRoot.Position - pRoot.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearestPlayer = player
                                        end
                                    end
                                end
                            end
                            if nearestPlayer and nearestPlayer.Character then
                                local hum = nearestPlayer.Character:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    hum.Health = 0
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local KillSeparatorLine3 = Instance.new("Frame", KillFrame)
    KillSeparatorLine3.Size = UDim2.new(1, -10, 0, 2)
    KillSeparatorLine3.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    KillSeparatorLine3.ZIndex = 4

    -- ОСТАНОВИТЬ КИЛЛЫ (ОВАЛ)
    local StopKillsBtn = Instance.new("TextButton", KillFrame)
    StopKillsBtn.Size = UDim2.new(1, -16, 0, 32)
    StopKillsBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    StopKillsBtn.Text = Localization[currentLanguage].StopKills
    StopKillsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopKillsBtn.Font = Enum.Font.SourceSansBold
    StopKillsBtn.ZIndex = 5
    Instance.new("UICorner", StopKillsBtn).CornerRadius = UDim.new(0, 8)

    StopKillsBtn.Activated:Connect(function() 
        killLoopActive = false
        autoKillPlrEnabled = false
        autoKillAllEnabled = false
        autoManualEnabled = false
        if updateKillPlr then updateKillPlr() end
        if updateKillAll then updateKillAll() end
        if updateManual then updateManual() end
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local KillSeparatorLine4 = Instance.new("Frame", KillFrame)
    KillSeparatorLine4.Size = UDim2.new(1, -10, 0, 2)
    KillSeparatorLine4.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    KillSeparatorLine4.ZIndex = 4

    -- ФЛИНГИ
    local flingPlrEnabled = false
    local flingAllEnabled = false
    local flingDoorsEnabled = false
    local flingLoopActive = true

    local flingContainer1, _, updateFlingPlr = CreateKillToggle(KillFrame, Localization[currentLanguage].FlingPlr, 30, function() return flingPlrEnabled end, function() 
        flingPlrEnabled = not flingPlrEnabled
        flingLoopActive = true
        if flingPlrEnabled or flingAllEnabled or flingDoorsEnabled then
            task.spawn(function()
                while flingLoopActive and (flingPlrEnabled or flingAllEnabled or flingDoorsEnabled) do
                    if flingPlrEnabled and selectedKillPlayer and selectedKillPlayer.Character then
                        local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            tRoot.Velocity = Vector3.new(0, 500, 0)
                            tRoot.CFrame = tRoot.CFrame * CFrame.new(0, 10, 0)
                        end
                    end

                    if flingAllEnabled then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                if tRoot then
                                    tRoot.Velocity = Vector3.new(0, 500, 0)
                                    tRoot.CFrame = tRoot.CFrame * CFrame.new(0, 10, 0)
                                end
                            end
                        end
                    end

                    if flingDoorsEnabled then
                        for _, door in ipairs(Workspace:GetDescendants()) do
                            if door:IsA("BasePart") and (door.Name:lower():find("door") or door.Name:lower():find("дверь")) then
                                door.Velocity = Vector3.new(0, 200, 0)
                                door.CFrame = door.CFrame * CFrame.new(0, 5, 0)
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end)

    local flingContainer2, _, updateFlingAll = CreateKillToggle(KillFrame, Localization[currentLanguage].FlingAll, 35, function() return flingAllEnabled end, function() 
        flingAllEnabled = not flingAllEnabled
        flingLoopActive = true
        if flingPlrEnabled or flingAllEnabled or flingDoorsEnabled then
            task.spawn(function()
                while flingLoopActive and (flingPlrEnabled or flingAllEnabled or flingDoorsEnabled) do
                    if flingPlrEnabled and selectedKillPlayer and selectedKillPlayer.Character then
                        local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            tRoot.Velocity = Vector3.new(0, 500, 0)
                            tRoot.CFrame = tRoot.CFrame * CFrame.new(0, 10, 0)
                        end
                    end

                    if flingAllEnabled then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                if tRoot then
                                    tRoot.Velocity = Vector3.new(0, 500, 0)
                                    tRoot.CFrame = tRoot.CFrame * CFrame.new(0, 10, 0)
                                end
                            end
                        end
                    end

                    if flingDoorsEnabled then
                        for _, door in ipairs(Workspace:GetDescendants()) do
                            if door:IsA("BasePart") and (door.Name:lower():find("door") or door.Name:lower():find("дверь")) then
                                door.Velocity = Vector3.new(0, 200, 0)
                                door.CFrame = door.CFrame * CFrame.new(0, 5, 0)
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end)

    local flingContainer3, _, updateFlingDoors = CreateKillToggle(KillFrame, Localization[currentLanguage].FlingDoors, 40, function() return flingDoorsEnabled end, function() 
        flingDoorsEnabled = not flingDoorsEnabled
        flingLoopActive = true
        if flingPlrEnabled or flingAllEnabled or flingDoorsEnabled then
            task.spawn(function()
                while flingLoopActive and (flingPlrEnabled or flingAllEnabled or flingDoorsEnabled) do
                    if flingPlrEnabled and selectedKillPlayer and selectedKillPlayer.Character then
                        local tRoot = selectedKillPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            tRoot.Velocity = Vector3.new(0, 500, 0)
                            tRoot.CFrame = tRoot.CFrame * CFrame.new(0, 10, 0)
                        end
                    end

                    if flingAllEnabled then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                if tRoot then
                                    tRoot.Velocity = Vector3.new(0, 500, 0)
                                    tRoot.CFrame = tRoot.CFrame * CFrame.new(0, 10, 0)
                                end
                            end
                        end
                    end

                    if flingDoorsEnabled then
                        for _, door in ipairs(Workspace:GetDescendants()) do
                            if door:IsA("BasePart") and (door.Name:lower():find("door") or door.Name:lower():find("дверь")) then
                                door.Velocity = Vector3.new(0, 200, 0)
                                door.CFrame = door.CFrame * CFrame.new(0, 5, 0)
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local KillSeparatorLine5 = Instance.new("Frame", KillFrame)
    KillSeparatorLine5.Size = UDim2.new(1, -10, 0, 2)
    KillSeparatorLine5.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    KillSeparatorLine5.ZIndex = 4

    -- ОСТАНОВИТЬ ФЛИНГ (ОВАЛ)
    local StopFlingBtn = Instance.new("TextButton", KillFrame)
    StopFlingBtn.Size = UDim2.new(1, -16, 0, 32)
    StopFlingBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    StopFlingBtn.Text = Localization[currentLanguage].StopFling
    StopFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopFlingBtn.Font = Enum.Font.SourceSansBold
    StopFlingBtn.ZIndex = 5
    Instance.new("UICorner", StopFlingBtn).CornerRadius = UDim.new(0, 8)

    StopFlingBtn.Activated:Connect(function() 
        flingLoopActive = false
        flingPlrEnabled = false
        flingAllEnabled = false
        flingDoorsEnabled = false
        if updateFlingPlr then updateFlingPlr() end
        if updateFlingAll then updateFlingAll() end
        if updateFlingDoors then updateFlingDoors() end
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local KillSeparatorLine6 = Instance.new("Frame", KillFrame)
    KillSeparatorLine6.Size = UDim2.new(1, -10, 0, 2)
    KillSeparatorLine6.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    KillSeparatorLine6.ZIndex = 4

    -- АВТО ПОЛУЧЕНИЕ ДИВАНА
    local autoSofaEnabled = false
    local autoSofaContainer, _, updateAutoSofa = CreateKillToggle(KillFrame, Localization[currentLanguage].AutoGetSofa, 45, function() return autoSofaEnabled end, function() 
        autoSofaEnabled = not autoSofaEnabled
        if autoSofaEnabled then
            task.spawn(function()
                while autoSofaEnabled do
                    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if bp then
                        local found = false
                        for _, tool in ipairs(bp:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                                found = true
                                break
                            end
                        end
                        if not found then
                            -- Ищем диван на карте
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("Tool") and (obj.Name:lower():find("sofa") or obj.Name:lower():find("диван")) then
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp then
                                        hrp.CFrame = obj:GetPivot()
                                        task.wait(0.1)
                                        obj.Parent = LocalPlayer.Character
                                        task.wait(0.1)
                                        obj.Parent = bp
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait(3)
                end
            end)
        end
    end)

    -- ПОЛУЧИТЬ/УДАЛИТЬ ДИВАН (ОВАЛ)
    local GetSofaBtn = Instance.new("TextButton", KillFrame)
    GetSofaBtn.Size = UDim2.new(1, -16, 0, 32)
    GetSofaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    GetSofaBtn.Text = Localization[currentLanguage].GetRemoveSofa
    GetSofaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetSofaBtn.Font = Enum.Font.SourceSansBold
    GetSofaBtn.ZIndex = 5
    Instance.new("UICorner", GetSofaBtn).CornerRadius = UDim.new(0, 8)

    GetSofaBtn.Activated:Connect(function()
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local found = false
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                    tool.Parent = LocalPlayer.Character
                    found = true
                    break
                end
            end
        end
        if not found then
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("sofa") or tool.Name:lower():find("диван")) then
                        tool.Parent = bp or game:GetService("ReplicatedStorage")
                        found = true
                        break
                    end
                end
            end
        end
        if not found then
            print("Диван не найден!")
        end
    end)

    -- ОТСТУП ВНИЗУ
    local KillFinalSpacer = Instance.new("Frame", KillFrame)
    KillFinalSpacer.Size = UDim2.new(1, 0, 0, 20)
    KillFinalSpacer.BackgroundTransparency = 1
    KillFinalSpacer.ZIndex = 3

    KillFrame.CanvasSize = UDim2.new(0, 0, 0, 700)

    -------------------------------------------------------
    -- ВКЛАДКА "TELEPORT" (РАСШИРЕННАЯ)
    -------------------------------------------------------
    -- ВЫБОР ЛОКАЦИЙ (ОВАЛ СО СТРЕЛКОЙ)
    local LocBtn = Instance.new("TextButton", TeleportFrame)
    LocBtn.Size = UDim2.new(1, -16, 0, 32)
    LocBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LocBtn.Text = Localization[currentLanguage].SelectLocHolder
    LocBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    LocBtn.ZIndex = 5
    Instance.new("UICorner", LocBtn).CornerRadius = UDim.new(0, 8)

    local LocArrow = Instance.new("TextLabel", LocBtn)
    LocArrow.Size = UDim2.new(0, 12, 0, 12)
    LocArrow.BackgroundTransparency = 1
    LocArrow.Text = "▼"
    LocArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    LocArrow.Font = Enum.Font.SourceSansBold
    LocArrow.TextSize = 10
    LocArrow.Position = UDim2.new(1, -16, 0.5, -6)
    LocArrow.ZIndex = 6

    local LocDropdown = Instance.new("ScrollingFrame", TeleportFrame)
    LocDropdown.Size = UDim2.new(1, -16, 0, 0)
    LocDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LocDropdown.Visible = false
    LocDropdown.ZIndex = 6
    LocDropdown.ScrollBarThickness = 3
    LocDropdown.ClipsDescendants = true
    Instance.new("UICorner", LocDropdown).CornerRadius = UDim.new(0, 8)

    local selectedLocationCFrame = nil
    local brookhavenLocations = {
        {"Spawn", CFrame.new(-13, 17, 15)}, {"Bank", CFrame.new(-34, 16, -91)}, 
        {"Arcade", CFrame.new(77, 16, -114)}, {"School", CFrame.new(-220, 16, -80)},
        {"Hospital", CFrame.new(-180, 16, -260)}, {"Police Station", CFrame.new(-40, 16, -40)},
        {"Grocery Store", CFrame.new(90, 16, -40)}, {"Daycare", CFrame.new(150, 16, -30)},
        {"Hair Salon", CFrame.new(50, 16, -90)}, {"Fire Station", CFrame.new(-90, 16, -20)},
        {"Church / Cemetery", CFrame.new(-300, 18, 50)}, {"Auto Shop", CFrame.new(120, 16, -120)},
        {"Starbrooks Coffee", CFrame.new(20, 16, -80)}, {"Candy Shop", CFrame.new(35, 16, -40)},
        {"Ice Cream Parlor", CFrame.new(60, 16, -40)}, {"Burger Shop", CFrame.new(105, 16, -80)},
        {"Library", CFrame.new(-150, 25, -70)}, {"Cinema", CFrame.new(5, 16, -120)},
        {"Gym", CFrame.new(130, 16, 10)}, {"Post Office", CFrame.new(-10, 16, -160)},
        {"Apparel / Clothing", CFrame.new(-70, 16, -90)}, {"Hotel", CFrame.new(0, 16, -60)},
        {"Airport", CFrame.new(-500, 30, -300)}, {"Lake Brookhaven", CFrame.new(400, 12, 300)},
        {"Farm", CFrame.new(-600, 16, 200)}, {"Park", CFrame.new(0, 15, 100)},
        {"Pool", CFrame.new(150, 15, 80)}, {"Gas Station", CFrame.new(200, 16, -50)},
        {"Golf Course", CFrame.new(-400, 15, 500)}, {"Secret Agency", CFrame.new(-75, -15, -60)}
    }

    for _, loc in ipairs(brookhavenLocations) do
        local b = Instance.new("TextButton", LocDropdown)
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundTransparency = 1
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = "📍 " .. loc[1]
        b.Font = Enum.Font.SourceSans
        b.TextSize = 13
        b.Activated:Connect(function()
            selectedLocationCFrame = loc[2]
            LocBtn.Text = "📍 " .. loc[1]
            LocDropdown.Visible = false
            LocDropdown.Size = UDim2.new(1, -16, 0, 0)
        end)
    end

    LocBtn.Activated:Connect(function()
        LocDropdown.Visible = not LocDropdown.Visible
        LocDropdown.Size = LocDropdown.Visible and UDim2.new(1, -16, 0, 120) or UDim2.new(1, -16, 0, 0)
    end)

    -- ТЕЛЕПОРТ К ЛОКАЦИИ (ОВАЛ НА ВСЮ ШИРИНУ)
    local MainTpLocBtn = Instance.new("TextButton", TeleportFrame)
    MainTpLocBtn.Size = UDim2.new(1, -16, 0, 40)
    MainTpLocBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 120)
    MainTpLocBtn.Text = Localization[currentLanguage].TeleportToLoc
    MainTpLocBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTpLocBtn.Font = Enum.Font.SourceSansBold
    MainTpLocBtn.ZIndex = 5
    Instance.new("UICorner", MainTpLocBtn).CornerRadius = UDim.new(0, 10)
    MainTpLocBtn.Activated:Connect(function()
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r and selectedLocationCFrame then 
            r.CFrame = selectedLocationCFrame
        end
    end)

    -- ПОЛОСКА РАЗДЕЛЯЮЩАЯ
    local TpSeparatorLine = Instance.new("Frame", TeleportFrame)
    TpSeparatorLine.Size = UDim2.new(1, -10, 0, 2)
    TpSeparatorLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TpSeparatorLine.ZIndex = 4

    -- ВЫБОР ИГРОКА ДЛЯ ТЕЛЕПОРТА (ОВАЛ СО СТРЕЛКОЙ)
    local SelectTpPlrBtn = Instance.new("TextButton", TeleportFrame)
    SelectTpPlrBtn.Size = UDim2.new(1, -16, 0, 32)
    SelectTpPlrBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SelectTpPlrBtn.Text = Localization[currentLanguage].SelectPlrHolder
    SelectTpPlrBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    SelectTpPlrBtn.ZIndex = 5
    Instance.new("UICorner", SelectTpPlrBtn).CornerRadius = UDim.new(0, 8)

    local TpPlrArrow = Instance.new("TextLabel", SelectTpPlrBtn)
    TpPlrArrow.Size = UDim2.new(0, 12, 0, 12)
    TpPlrArrow.BackgroundTransparency = 1
    TpPlrArrow.Text = "▼"
    TpPlrArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    TpPlrArrow.Font = Enum.Font.SourceSansBold
    TpPlrArrow.TextSize = 10
    TpPlrArrow.Position = UDim2.new(1, -16, 0.5, -6)
    TpPlrArrow.ZIndex = 6

    local TpPlrDropdown = Instance.new("ScrollingFrame", TeleportFrame)
    TpPlrDropdown.Size = UDim2.new(1, -16, 0, 0)
    TpPlrDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TpPlrDropdown.Visible = false
    TpPlrDropdown.ZIndex = 6
    TpPlrDropdown.ScrollBarThickness = 2
    TpPlrDropdown.ClipsDescendants = true
    Instance.new("UICorner", TpPlrDropdown).CornerRadius = UDim.new(0, 8)

    local function updateTpPlrDropdown()
        for _, c in ipairs(TpPlrDropdown:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local b = Instance.new("TextButton", TpPlrDropdown)
                b.Size = UDim2.new(1, 0, 0, 28)
                b.BackgroundTransparency = 1
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
                b.Text = player.Name .. " (" .. player.DisplayName .. ")"
                b.Font = Enum.Font.SourceSans
                b.TextSize = 13
                b.Activated:Connect(function()
                    selectedTpPlayer = player
                    SelectTpPlrBtn.Text = "🎯 " .. player.Name
                    TpPlrDropdown.Visible = false
                    TpPlrDropdown.Size = UDim2.new(1, -16, 0, 0)
                end)
            end
        end
        TpPlrDropdown.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 28 + 10)
    end

    SelectTpPlrBtn.Activated:Connect(function()
        TpPlrDropdown.Visible = not TpPlrDropdown.Visible
        if TpPlrDropdown.Visible then
            updateTpPlrDropdown()
            TpPlrDropdown.Size = UDim2.new(1, -16, 0, 100)
        else
            TpPlrDropdown.Size = UDim2.new(1, -16, 0, 0)
        end
    end)

    -- ТЕЛЕПОРТ К ИГРОКУ (ОВАЛ НА ВСЮ ШИРИНУ)
    local MainTpPlayerBtn = Instance.new("TextButton", TeleportFrame)
    MainTpPlayerBtn.Size = UDim2.new(1, -16, 0, 40)
    MainTpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    MainTpPlayerBtn.Text = Localization[currentLanguage].TeleportToPlr
    MainTpPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTpPlayerBtn.Font = Enum.Font.SourceSansBold
    MainTpPlayerBtn.ZIndex = 5
    Instance.new("UICorner", MainTpPlayerBtn).CornerRadius = UDim.new(0, 10)
    MainTpPlayerBtn.Activated:Connect(function()
        if selectedTpPlayer and selectedTpPlayer.Character and selectedTpPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then
                r.CFrame = selectedTpPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            end
        end
    end)

    local TpFinalSpacer = Instance.new("Frame", TeleportFrame)
    TpFinalSpacer.Size = UDim2.new(1, 0, 0, 30)
    TpFinalSpacer.BackgroundTransparency = 1
    TpFinalSpacer.ZIndex = 3

    TeleportFrame.CanvasSize = UDim2.new(0, 0, 0, 350)

    -------------------------------------------------------
    -- УПРАВЛЕНИЕ ВКЛАДКАМИ
    -------------------------------------------------------
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
        if playerUIElements["AntiAFK"] then playerUIElements["AntiAFK"].Label.Text = "  " .. data.AntiAFK playerUIElements["AntiAFK"].UpdateVisuals() end
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
        if followEnabled then
            FollowLbl.Text = "  " .. data.FollowPlrOn
        else
            FollowLbl.Text = "  " .. data.FollowPlr
        end
        SingleEspLbl.Text = "  " .. data.EspPlr
        AllEspLbl.Text = "  " .. data.EspAll

        KillSelectLeftTitle.Text = data.T_Kill or "Kill"
        GetKillToolButton.Text = data.GetTool
        KillMethodBtn.Text = "Метод: " .. selectedKillMethod
        
        if not selectedKillPlayer then 
            KillSelectNickText.Text = data.SelectPlrHolder 
        end
        
        SignTextBoxOval.PlaceholderText = data.SignPlaceholder
        
        if not selectedTargetPlayer then
            PlrSelectNickText.Text = data.SelectPlrHolder
        end
        
        WriteSignButton.Text = data.WriteBtn
        KidnapBtn.Text = data.SofaKidnap
        FastKillBtn.Text = data.FastKill
        StopKillsBtn.Text = data.StopKills
        StopFlingBtn.Text = data.StopFling
        GetSofaBtn.Text = data.GetRemoveSofa
        LocBtn.Text = data.SelectLocHolder
        MainTpLocBtn.Text = data.TeleportToLoc
        MainTpPlayerBtn.Text = data.TeleportToPlr
        
        if not selectedTpPlayer then
            SelectTpPlrBtn.Text = data.SelectPlrHolder
        end

        for _, tKey in ipairs(bhTabsList) do
            if bhButtons[tKey] then
                bhButtons[tKey].Text = data["T_" .. tKey] or tKey
            end
        end

        -- Обновляем переключатели в Kill
        local killToggleMap = {
            ["Auto-Kill Target"] = "AutoKillPlr",
            ["Auto-Kill All"] = "AutoKillAll",
            ["Auto-Manual Kill"] = "AutoManualKill",
            ["Fling Target"] = "FlingPlr",
            ["Fling All Players"] = "FlingAll",
            ["Fling Doors"] = "FlingDoors",
            ["Auto Get Sofa"] = "AutoGetSofa"
        }
        for _, child in ipairs(KillFrame:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
                local label = child:FindFirstChildOfClass("TextLabel")
                if label then
                    local labelText = label.Text:gsub("^  ", "")
                    local key = killToggleMap[labelText]
                    if key and data[key] then
                        label.Text = "  " .. data[key]
                    end
                end
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
