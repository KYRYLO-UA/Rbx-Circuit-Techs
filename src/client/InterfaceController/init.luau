local Players = game:GetService("Players")
local InterfaceController = {}

function InterfaceController.Init()
     
end

function InterfaceController.Start()
     task.wait(1)
     local PlayeGui = Players.LocalPlayer.PlayerGui
     for _, cModule in script:GetChildren() do
          local c = require(cModule)
          c.Init()
     end
end

return InterfaceController