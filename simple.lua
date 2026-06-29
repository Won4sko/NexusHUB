print("✅ Простой скрипт работает!")

local g = Instance.new("ScreenGui", game:GetService("CoreGui"))
g.Name = "TestGUI"

local f = Instance.new("Frame", g)
f.Size = UDim2.new(0, 300, 0, 150)
f.Position = UDim2.new(0.5, -150, 0.5, -75)
f.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

local t = Instance.new("TextLabel", f)
t.Size = UDim2.new(1, 0, 1, 0)
t.BackgroundTransparency = 1
t.Text = "✅ GitHub работает!\nМеню открыто!"
t.TextColor3 = Color3.fromRGB(255, 255, 255)
t.Font = Enum.Font.SourceSansBold
t.TextSize = 20

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
