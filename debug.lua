print("🚀 Запуск отладочной версии NexusHUB")

local success, err = pcall(function()
    local script = game:HttpGet('https://raw.githubusercontent.com/Won4sko/NexusHUB/main/NexusHUB.lua')
    print("✅ Скрипт загружен, длина: " .. #script .. " символов")
    loadstring(script)()
end)

if not success then
    warn("❌ Ошибка выполнения: " .. tostring(err))
    print("📌 Создаю тестовое окно...")
    
    local g = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local f = Instance.new("Frame", g)
    f.Size = UDim2.new(0, 300, 0, 150)
    f.Position = UDim2.new(0.5, -150, 0.5, -75)
    f.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = "⚠️ Ошибка в скрипте\nПроверь консоль Delta"
    t.TextColor3 = Color3.fromRGB(255, 200, 100)
    t.Font = Enum.Font.SourceSansBold
    t.TextSize = 16
    t.TextWrapped = true
    
    local c = Instance.new("TextButton", f)
    c.Size = UDim2.new(0, 30, 0, 30)
    c.Position = UDim2.new(1, -35, 0, 5)
    c.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    c.Text = "X"
    c.TextColor3 = Color3.fromRGB(255, 255, 255)
    c.Font = Enum.Font.SourceSansBold
    c.TextSize = 16
    Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
    c.Activated:Connect(function() g:Destroy() end)
end
