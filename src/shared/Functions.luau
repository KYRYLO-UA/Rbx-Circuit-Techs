local F = {}

function F.Weld(part, toPart, unachor, uncancollide)
     local Weld = Instance.new("WeldConstraint")
     Weld.Part0 = toPart
     Weld.Part1 = part
     Weld.Parent = toPart
     if unachor then
          part.Anchored = false
     end
     if uncancollide then
          part.CanCollide = false
     end
     return Weld
end

function F.TransformConfig(config:Configuration)
     local newConfig = {}

     for _, elem in config:GetChildren() do
          if string.find(string.lower(elem.ClassName), "value") then
               newConfig[elem.Name] = elem.Value
          end
     end

     return newConfig
end

return F