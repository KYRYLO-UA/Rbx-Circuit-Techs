local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerClass = require(script.PlayerClass)
local ProfileService = require(script.ProfileService)
local ProfileTemplate = require(script.ProfileTemplate)
local ProfileStore = ProfileService.GetProfileStore("PlayerData03", ProfileTemplate)

local SecurityService
local DataService = Knit.CreateService { Name = "DataService", Client = {} }

DataService.Players = {}

local PlayerAdded = function(player:Player)
     local Profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
     local Player = PlayerClass.new(player, Profile)
     if Profile ~= nil and Player ~= nil then
          Profile:AddUserId(player.UserId)
          Profile:Reconcile()
          Profile:ListenToRelease(function()
               DataService.Players[player] = nil
               player:Kick()
          end)
          if player:IsDescendantOf(Players) == true then
               DataService.Players[player] = Player

               player.CharacterAdded:Connect(function(character)
                    Player.CharacterApplied = false
                    Player:ApplyCharacter(character)
               end)

               Player:ApplyCharacter(player.Character)
               
               Player:SetTime("Login", tick())
               -- Player:AddMoney("Cash", 100)

               if Knit.Shared.Leveling.Enabled then
                    if Knit.Shared.Leveling.TimedExp.Enabled then
                         Player:StartExpLoop()
                    end
               end

               print(Player.Profile.Data.Times.Login, Player.Profile.Data.Times.Logout)
          else
               Profile:Release()
          end
     else
          player:Kick()
     end
end

local StartPaycheckLoop = function()
     while task.wait(Knit.Shared.Paycheck.Cooldown) do
          for _, player in Players:GetPlayers() do
               local paycheckAmount = SecurityService:CheckPermissionByTeam(player, "Paycheck")
               local Player = DataService.Players[player]

               if typeof(paycheckAmount) == "table" then
                    for _, info in paycheckAmount do
                         -- print(info, info[1], info[2], info[3])
                         if player:GetRankInGroup(info[1]) == info[2] and info[3] > 0 then
                              Player:AddMoney("Bank", info[3])
                         end
                    end
               elseif typeof(paycheckAmount) == "number" then
                    Player:AddMoney("Bank", paycheckAmount)
               end
          end
     end  
end

function DataService.KnitInit()
     Players.PlayerAdded:Connect(PlayerAdded)

     Players.PlayerRemoving:Connect(function(player)
          local Player = DataService.Players[player]
          Player:SetTime("Logout", tick())

          if Player.Profile ~= nil then
               Player.Profile:Release()
          end
     end)
end

function DataService.KnitStart()
     SecurityService = Knit.GetService("SecurityService")

     for _, player in Players:GetPlayers() do
          task.spawn(PlayerAdded, player)
     end

     if Knit.Shared.Paycheck.Enabled then
          task.spawn(StartPaycheckLoop)
     end
end

return DataService