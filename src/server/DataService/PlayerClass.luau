local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = {}
Player.__index = Player

function Player.new(player:Player, profile:any)
     local self = setmetatable({}, Player)

     self.Player = player
     self.Profile = profile
     self.CharacterApplied = false

     return self
end

-- Character added event
local checkMorphOnAvailable = function(player: Player, morphName, availableMorphs)
     for _, availMorphInfo in availableMorphs do
          if availMorphInfo[3] == morphName and player:GetRankInGroup(availMorphInfo[1]) == availMorphInfo[2] then
               return true
          end
     end
end

function Player:ApplyCharacter(character)
     if self.CharacterApplied then return end

     local SecurityService = Knit.GetService("SecurityService")
     local MorphService = Knit.GetService("MorphService")

     local DefaultClothing = Instance.new("Folder", self.Player)
     DefaultClothing.Name = "DefaultClothing"

     for _, cloth in character:GetChildren() do
          if cloth:IsA("Pants") or cloth:IsA("Shirt") or cloth:IsA("Accessory") then
               cloth:Clone().Parent = DefaultClothing
          end
     end

     local AutoMorphs = SecurityService:CheckPermissionByTeam(self.Player, "AutoMorphs")
     local AvailableMorphs = SecurityService:CheckPermissionByTeam(self.Player, "AvailableMorphs")

     if AutoMorphs and AvailableMorphs then
          for _, autoMorphName in AutoMorphs do
               local available = checkMorphOnAvailable(self.Player, autoMorphName, AvailableMorphs)
               if available then
                    MorphService.ApplyMorph(self.Player, autoMorphName)

                    -- task.wait(10) -- Remove morph in 10 seconds
                    -- MorphService.RemoveMorph(self.Player)
               end
          end
     end

     self.CharacterApplied = true
end

-- Times Methods
local checkOnTimesDiv = function(div)
     if div == "Login" or div == "Logout" then
          return true
     end
end

function Player:SetTime(div, time) : boolean
     if checkOnTimesDiv(div) then
          self.Profile.Data.Times[div] = time
          return true
     end
end

-- Money Methods
local checkOnMoneyDiv = function(div)
     if div == "Cash" or div == "Bank" then
          return true
     end
end

function Player:GetMoney() : any
     local Money = self.Profile.Data.Money
     return Money.Cash, Money.Bank
end

function Player:AddMoney(div, amount) : boolean
     if checkOnMoneyDiv(div) then
          self.Profile.Data.Money[div] += amount
          return true
     end
end

function Player:RemoveMoney(div, amount) : boolean
     if checkOnMoneyDiv(div) then
          self.Profile.Data.Money[div] -= amount
          return true
     end
end

function Player:SetMoney(div, amount) : boolean
     if checkOnMoneyDiv(div) then
          self.Profile.Data.Money[div] = amount
          return true
     end
end

-- Leveling Methods
function Player:GetLevel() : number
     return self.Profile.Data.Leveling.Level
end

function Player:GetExp() : number
     return self.Profile.Data.Leveling.Exp
end

function Player:UpLevel() : boolean
     self.Profile.Data.Leveling.Exp = 0
     self.Profile.Data.Leveling.Level += 1

     return true
end

function Player:AddExp(amount) : boolean

     self.Profile.Data.Leveling.Exp += amount

     if self:GetLevel() < (#Knit.Shared.Leveling.ExpRequirements) then
          local nextLevelExp = Knit.Shared.Leveling.ExpRequirements[self:GetLevel() + 1]
          if self:GetExp() >= nextLevelExp then
               local ostatok = self:GetExp() - nextLevelExp
               if ostatok > 0 then
                    self:UpLevel()
                    self:AddExp(ostatok)
               end
          end
     end

     return true
end

-- Loops
function Player:StartExpLoop()
     while task.wait(Knit.Shared.Leveling.TimedExp.Cooldown) do
          self:AddExp(Knit.Shared.Leveling.TimedExp.Amount)
     end
end

return Player