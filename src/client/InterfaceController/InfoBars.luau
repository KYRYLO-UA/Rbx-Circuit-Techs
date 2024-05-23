local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local InfoBars = {}

InfoBars.InfoBarsUI = nil

InfoBars.HideTrigger = false
InfoBars.Hidden = false


function InfoBars:AnimateText(TextLabel: TextLabel, Speed, Async, Reverse, Text)
     if TextLabel.Text == Text and Reverse == false then
          return
     end

     local f = function()
          if Reverse then
               for index = string.len(TextLabel.Text), 0, -1 do
                    TextLabel.MaxVisibleGraphemes = index
                    task.wait(Speed)
               end
          else
               TextLabel.MaxVisibleGraphemes = 0
               TextLabel.Text = Text or ""

               for index = 0, string.len(Text), 1 do
                    TextLabel.MaxVisibleGraphemes = index
                    task.wait(Speed)
               end
          end
     end

     if Async then task.spawn(f) else f() end
end

local Bar = {}
Bar.__index = Bar

function Bar.new(Template)
     local Content = InfoBars.InfoBarsUI.Main.Content
     local BarsFrame = Content.BarsFrame

     local self = setmetatable({}, Bar)
     self.Name = "Frame"

     local BarFrame = Template:Clone()
     BarFrame.Parent = BarsFrame

     self.BarFrame = BarFrame

     self.Callback = function()
          print("hello")
     end
     self.Events = {}

     self.ColorElements = {}
     self.Color = Color3.fromRGB(255, 255, 255)

     InfoBars:UpdateMainFrame()

     local TextLabel = BarFrame:FindFirstChildOfClass("TextLabel")
     BarFrame.BackgroundTransparency = .4
     BarFrame.MouseEnter:Connect(function()
          if TextLabel then TextLabel.TextSize = 22 end
          TweenService:Create(BarFrame, TweenInfo.new(.3, Enum.EasingStyle.Cubic), {BackgroundTransparency = .2}):Play()
     end)
     BarFrame.MouseLeave:Connect(function()
          if TextLabel then TextLabel.TextSize = 20 end
          TweenService:Create(BarFrame, TweenInfo.new(.3, Enum.EasingStyle.Cubic), {BackgroundTransparency = .4}):Play()
     end)

     return self
end

function Bar:UpdateColor()
     for _, el in self.ColorElements do
          el[1][el[2]] = self.Color
     end
end

function Bar:ApplyColor(...)
     self.ColorElements = {...}
end

function Bar:SetColor(Color: Color3)
     self.Color = Color
end

function Bar:SetName(Name: string)
     local BarFrame:Frame = self.BarFrame
     BarFrame.Name = Name
     self.Name = Name
end

function Bar:SetPriority(Num: number)
     local BarFrame:Frame = self.BarFrame
     BarFrame.LayoutOrder = Num
end

function Bar:SetCallback(Func)
     self.Callback = Func
     task.spawn(self.Callback)
end

function Bar:SetEvents(Table: any)
     for _, event in self.Events do
          event:Disconnect()
     end

     self.Events = Table

     for _, event in self.Events do
          if event ~= nil then
               event:Connect(self.Callback)
          end
     end
end

function Bar:AddEvent(Event)
     table.insert(self.Events, Event)
     Event:Connect(self.Callback)
end

InfoBars.Bar = Bar

function InfoBars:UpdateMainFrame()
     local Main:Frame = InfoBars.InfoBarsUI.Main
     local Content = Main.Content
     local BarsFrame = Content.BarsFrame
     
     local BarsAmount, MainSize = 0, 0

     for _, Frame:Frame in BarsFrame:GetChildren() do
          if Frame:IsA("Frame") then
               if Frame.Visible == true then
                    BarsAmount += 1
                    MainSize += Frame.Size.Y.Offset
               end
          end
     end

     MainSize += (BarsAmount - 1) * 4
     
     TweenService:Create(Main, TweenInfo.new(.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, MainSize) }):Play()
end

function InfoBars:TurnHidden(Auto: boolean, State: boolean)
     local Main = InfoBars.InfoBarsUI.Main
     local Content = Main.Content
     local HideButton = Content.HideTrigger.HideButton

     if Auto then
          InfoBars.Hidden = not InfoBars.Hidden
     else
          InfoBars.Hidden = State
     end

     Main.ClipsDescendants = InfoBars.Hidden
     if InfoBars.Hidden then
          TweenService:Create(Content, TweenInfo.new(.65, Enum.EasingStyle.Cubic), { Position = UDim2.new(1, 0, .5, 0) }):Play()
          TweenService:Create(HideButton, TweenInfo.new(.4, Enum.EasingStyle.Linear), { Rotation = 180 }):Play()
          TweenService:Create(HideButton, TweenInfo.new(.3, Enum.EasingStyle.Sine), { TextTransparency = 0 }):Play()
     else
          TweenService:Create(Content, TweenInfo.new(.65, Enum.EasingStyle.Cubic), { Position = UDim2.new(0, 0, .5, 0) }):Play()
          TweenService:Create(HideButton, TweenInfo.new(.4, Enum.EasingStyle.Linear), { Rotation = 0 }):Play()
          if not InfoBars.HideTrigger then
               TweenService:Create(HideButton, TweenInfo.new(.3, Enum.EasingStyle.Sine), { TextTransparency = 1 }):Play()
          end
     end
end

function InfoBars:InitHideButton()
     local HideTrigger = InfoBars.InfoBarsUI.Main.Content.HideTrigger
     local HideButton = HideTrigger.HideButton

     HideButton.TextTransparency = 1

     HideButton.MouseButton1Click:Connect(function()
          InfoBars:TurnHidden(true)
     end)

     HideTrigger.MouseEnter:Connect(function()
          InfoBars.HideTrigger = true
          TweenService:Create(HideButton, TweenInfo.new(.3, Enum.EasingStyle.Sine), { TextTransparency = 0 }):Play()
     end)

     HideTrigger.MouseLeave:Connect(function()
          InfoBars.HideTrigger = false
          if not InfoBars.Hidden then
               TweenService:Create(HideButton, TweenInfo.new(.3, Enum.EasingStyle.Sine), { TextTransparency = 1 }):Play()
          end
     end)
end

local Init = function()
     local DataService = Knit.GetService("DataService")
     warn("DATA", DataService)
     -- warn("DATA")

     local Humanoid = Players.LocalPlayer.Character.Humanoid

     InfoBars.InfoBarsUI = ReplicatedStorage.Resources.InfoBarsUI:Clone()
     InfoBars.InfoBarsUI.Parent = Players.LocalPlayer.PlayerGui

     StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

     InfoBars:InitHideButton()
     InfoBars:UpdateMainFrame()

     local HeaderBar = Bar.new(ReplicatedStorage.Resources.InfoBarHeaderTemplate)
     HeaderBar:SetName("Header")
     HeaderBar:SetPriority(0)
     InfoBars:AnimateText(HeaderBar.BarFrame.Username.TextLabel, .05, false, false, "Ім'я: " .. Players.LocalPlayer.Name)
     HeaderBar:SetCallback(function()
          local BarFrame:Frame = HeaderBar.BarFrame

          InfoBars:AnimateText(BarFrame.Role.TextLabel, .05, false, true)
          InfoBars:AnimateText(BarFrame.Role.TextLabel, .05, true, false, Players.LocalPlayer.Team.Name)

          BarFrame.Role.TextLabel.TextColor3 = Players.LocalPlayer.Team.TeamColor.Color
     end)
     HeaderBar:AddEvent(Players.LocalPlayer:GetPropertyChangedSignal("Team"))

     -- task.wait(1)

     local LevelBar = Bar.new(ReplicatedStorage.Resources.InfoBarDefaultTemplate)
     LevelBar:SetName("Level")
     LevelBar:SetPriority(1)

     local UpdateLevelBar = function()
          local BarFrame:Frame = LevelBar.BarFrame
          BarFrame.Bar.Visible = true

          local CurrentExp, NextLevelExp, CurrentLevel = 50, 100, 1

          BarFrame.TextLabel.Text = 'Рівень: <font size="22">'..tostring(CurrentLevel)..'</font>'
          TweenService:Create(BarFrame.Bar, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Size = UDim2.new(CurrentExp / NextLevelExp, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(134, 157, 158)}):Play()
     end

     LevelBar:SetCallback(UpdateLevelBar)

     LevelBar:SetColor(Color3.fromRGB(40, 40, 40))
     LevelBar:ApplyColor({LevelBar.BarFrame, "BackgroundColor3"})
     LevelBar:UpdateColor()

     -- task.wait(.5)

     local MoneyBar = Bar.new(ReplicatedStorage.Resources.InfoBarDefaultTemplate)
     MoneyBar:SetName("Money")
     MoneyBar:SetPriority(2)

     local UpdateMoneyBar = function()
          local Bank, Cash = 100, 100
          MoneyBar.BarFrame.TextLabel.Text = 'Гроші: '..tostring(Cash)..'₴'
     end

     MoneyBar:SetColor(Color3.fromRGB(121, 181, 128))
     MoneyBar:ApplyColor({MoneyBar.BarFrame, "BackgroundColor3"})
     MoneyBar:UpdateColor()

     MoneyBar:SetCallback(UpdateMoneyBar)

     -- task.wait(.5)

     local HealthBar = Bar.new(ReplicatedStorage.Resources.InfoBarDefaultTemplate)
     HealthBar:SetName("Health")
     HealthBar:SetPriority(3)

     local UpdateHealthBar = function()
          local BarFrame:Frame = HealthBar.BarFrame
          local Health, MaxHealth = Humanoid.Health, 100

          if MaxHealth > 100 then
               Health = Health - (MaxHealth - 100)
          end

          BarFrame.Bar.Visible = true

          TweenService:Create(BarFrame.Bar, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Size = UDim2.new(Health / MaxHealth, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 132, 130)}):Play()

          HealthBar.BarFrame.TextLabel.Text = "Здоров'я"
     end

     HealthBar:SetColor(Color3.fromRGB(40, 40, 40))
     HealthBar:ApplyColor({HealthBar.BarFrame, "BackgroundColor3"})
     HealthBar:UpdateColor()

     HealthBar:SetCallback(UpdateHealthBar)

     HealthBar:SetEvents({Humanoid:GetPropertyChangedSignal("Health"), Humanoid:GetPropertyChangedSignal("MaxHealth")})

     -- task.wait(.5)

     local ArmourBar = Bar.new(ReplicatedStorage.Resources.InfoBarDefaultTemplate)
     ArmourBar:SetName("Armour")
     ArmourBar:SetPriority(4)

     local UpdateArmourBar = function()
          local BarFrame:Frame = ArmourBar.BarFrame

          BarFrame.TextLabel.Text = "Броня"
          
          local Health, MaxHealth = Humanoid.Health, Humanoid.MaxHealth

          BarFrame.Visible = (Health > 100)

          Health, MaxHealth = Humanoid.Health - 100, Humanoid.MaxHealth - 100

          if Health <= 0 then Health = 1 end
          if MaxHealth <= 0 then MaxHealth = 1 end

          BarFrame.Bar.Visible = true
          
          TweenService:Create(BarFrame.Bar, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Size = UDim2.new(Health / MaxHealth, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(137, 166, 255)}):Play()

          InfoBars:UpdateMainFrame()
     end

     ArmourBar:SetColor(Color3.fromRGB(40, 40, 40))
     ArmourBar:ApplyColor({ArmourBar.BarFrame, "BackgroundColor3"})
     ArmourBar:UpdateColor()

     ArmourBar:SetCallback(UpdateArmourBar)

     ArmourBar:SetEvents({Humanoid:GetPropertyChangedSignal("Health"), Humanoid:GetPropertyChangedSignal("MaxHealth")})

     -- task.wait(.5)

     local Hunger = Humanoid.Parent:WaitForChild("Stances", math.huge):WaitForChild("Hunger", math.huge)

     local HungerBar = Bar.new(ReplicatedStorage.Resources.InfoBarDefaultTemplate)
     HungerBar:SetName("Hunger")
     HungerBar:SetPriority(5)

     local UpdateHungerBar = function()
          local BarFrame = HungerBar.BarFrame

          BarFrame.TextLabel.Text = "Голод"

          BarFrame.Bar.Visible = true
          
          TweenService:Create(BarFrame.Bar, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Size = UDim2.new(Hunger.Value / 100, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 181, 132)}):Play()
     end

     HungerBar:SetColor(Color3.fromRGB(40, 40, 40))
     HungerBar:ApplyColor({HungerBar.BarFrame, "BackgroundColor3"})
     HungerBar:UpdateColor()

     HungerBar:SetCallback(UpdateHungerBar)

     HungerBar:AddEvent(Hunger.Changed)

     -- task.wait(.5)
     local Stamina = script.Parent.Parent:WaitForChild("StaminaController"):WaitForChild("Stamina")

     local StaminaBar = Bar.new(ReplicatedStorage.Resources.InfoBarDefaultTemplate)
     StaminaBar:SetName("Stamina")
     StaminaBar:SetPriority(6)

     local UpdateStaminaBar = function()
          local BarFrame = StaminaBar.BarFrame

          BarFrame.TextLabel.Text = "Витривалість"

          BarFrame.Bar.Visible = true
          
          TweenService:Create(BarFrame.Bar, TweenInfo.new(.4, Enum.EasingStyle.Cubic), {Size = UDim2.new(Stamina.Value / 100, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(161, 204, 255)}):Play()
     end

     StaminaBar:SetColor(Color3.fromRGB(40, 40, 40))
     StaminaBar:ApplyColor({StaminaBar.BarFrame, "BackgroundColor3"})
     StaminaBar:UpdateColor()

     StaminaBar:SetCallback(UpdateStaminaBar)

     StaminaBar:AddEvent(Stamina.Changed)
end

function InfoBars.Init()
     task.delay(3, Init)
     return true
end

return InfoBars