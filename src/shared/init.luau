local Shared = {}

Shared.Paycheck = {
     Enabled = true,
     Cooldown = 4
}

Shared.Leveling = {
     Enabled = true,
     TimedExp = {
          Enabled = true,
          Cooldown = 1,
          Amount = 10
     },
     ExpRequirements = {
          [1] = 100, [2] = 250, [3] = 500, [4] = 1000, [5] = 2000
     }
}

Shared.Teams = require(script.Teams)

for funcName, func in require(script.Functions) do
     Shared[funcName] = func
end

return Shared