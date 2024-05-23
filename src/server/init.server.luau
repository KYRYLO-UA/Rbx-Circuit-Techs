local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.Shared = require(ReplicatedStorage.Shared)

local Services = script --:GetChildren()

Knit.AddServices(Services)
Knit.Start():catch(warn)

Knit.Loaded = true