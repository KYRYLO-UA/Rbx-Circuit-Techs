local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MorphsStorage = ServerStorage.MorphsStorage

local MorphService = Knit.CreateService { Name = "MorphService", Client = {} }


-- -- Morph
-- local Morphee = Morphe:FindFirstChild("Morph")
-- if Morphee then
--      for _, PartModel in Morphee:GetChildren() do
--           local CharPart = Character:FindFirstChild(PartModel.Name)
--           if CharPart then
--                local Clone = PartModel:Clone()
--                Clone.Parent = game.ReplicatedStorage
--                local Middle = Clone.PrimaryPart or Clone.Middle
--                for _, p in Clone:GetChildren() do
--                     if p:IsA("BasePart") and p.Name ~= "Middle" then
--                          Morph.Weld(p, Middle, true, true)
--                     end
--                end
--                Middle.Anchored = false
--                Clone.Parent = CharPart
--                Middle.CFrame = CharPart.CFrame
--                Morph.Weld(Middle, CharPart, false, true)
--           else
--                print(CharPart.." is not found in "..Character.Name.." character.")
--           end
--      end
-- end

local getDefaultPlayerClothing = function(player)
     return player:FindFirstChild("DefaultClothing")
end

local checkOnWearedMorph = function(player)
     local humanoid = player.Character.Humanoid
     local wearedMorph = humanoid:GetAttribute("WearedMorph")
     return wearedMorph or false
end

function MorphService.ApplyMorph(player, morphName)
     if checkOnWearedMorph(player) then return end

     local character = player.Character
     local humanoid = character.Humanoid

     local morphModel = MorphsStorage:FindFirstChild(morphName)
     
     if morphModel then
          humanoid:SetAttribute("WearedMorph", morphName)

          local config = Knit.Shared.TransformConfig(morphModel.Config)
          local clothingModel = morphModel:FindFirstChild("Clothing")
          local morphPartsModel = morphModel:FindFirstChild("MorphParts")

          if config.RemoveAccessories == true then
               for _, acc in character:GetChildren() do
                    if acc:IsA("Accessory") then
                         acc:Destroy()
                    end
               end
          end

          if config.ExtraHealth ~= nil then
               local savedHealth, savedMaxHealth = humanoid.Health, humanoid.MaxHealth
               humanoid.MaxHealth += config.ExtraHealth
               if savedHealth >= (savedMaxHealth - 1) then
                    humanoid.Health = humanoid.MaxHealth
               end
          end

          if clothingModel then
               for _, cloth in character:GetChildren() do
                    if cloth:IsA("Pants") or cloth:IsA("Shirt") then
                         cloth:Destroy()
                    end
               end
               for _, cloth in clothingModel:GetChildren() do
                    if cloth:IsA("Pants") or cloth:IsA("Shirt") then
                         cloth:Clone().Parent = character
                    end
               end
          end

          if morphPartsModel then
               for _, partModel in morphPartsModel:GetChildren() do
                    local charPart = character:FindFirstChild(partModel.Name)
                    if charPart then
                         local clone = partModel:Clone()
                         clone.Name = charPart.Name.."Morph"
                         clone.Parent = game.ReplicatedStorage

                         local middle = clone.PrimaryPart or clone.Middle

                         for _, p in clone:GetChildren() do
                              if p:IsA("BasePart") and p.Name ~= "Middle" then
                                   Knit.Shared.Weld(p, middle, true, true)
                              end
                         end

                         middle.Anchored = false
                         clone.Parent = charPart
                         middle.CFrame = charPart.CFrame

                         Knit.Shared.Weld(middle, charPart, false, true).Name = charPart.Name.."Weld"
                    else
                         print(charPart.." is not found in "..character.Name.." character.")
                    end
               end
          end

          warn('apply', morphName, morphModel)
     end
end

function MorphService.RemoveMorph(player)
     local character = player.Character
     local humanoid = character.Humanoid

     local wearedMorph = checkOnWearedMorph(player)
     local defaultClothing = getDefaultPlayerClothing(player)

     if wearedMorph then
          for _, part in character:GetChildren() do
               if part:IsA("BasePart") then
                    local morphPartModel = part:FindFirstChild(part.Name.."Morph")
                    local morphPartWeld = part:FindFirstChild(part.Name.."Weld")
                    if morphPartModel then
                         morphPartModel:Destroy()
                    end
                    if morphPartWeld then
                         morphPartWeld:Destroy()
                    end
               end
          end
          for _, cloth in character:GetChildren() do
               if cloth:IsA("Pants") or cloth:IsA("Shirt") then
                    cloth:Destroy()
               end
          end
          for _, cloth in defaultClothing:GetChildren() do
               if not character:FindFirstChild(defaultClothing) then
                    cloth:Clone().Parent = character
               end
          end
          humanoid:SetAttribute("WearedMorph", nil)
     end
end

function MorphService.KnitInit()

end

function MorphService.KnitStart()

end

return MorphService