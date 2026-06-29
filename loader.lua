-- Загрузчик NexusHUB с защитой от ошибок
print("🚀 Загрузка NexusHUB...")

local function LoadScript()
    local success, result = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/Won4sko/NexusHUB/main/NexusHUB.lua')
    end)
    
    if success then
        print("✅ Скрипт загружен!")
        loadstring(result)()
    else
        warn("❌ Ошибка загрузки: " .. tostring(result))
        print("🔄 Повтор через 3 секунды...")
        task.wait(3)
        LoadScript()
    end
end

LoadScript()
