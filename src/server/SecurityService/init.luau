local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SecurityService = Knit.CreateService { Name = "SecurityService", Client = {} }

SecurityService.VerifiedTeams = {}

local PrepareTeams = function()
     for teamIndex, teamInfo in Knit.Shared.Teams do
          local team = Instance.new("Team", Teams)
          team.Name = teamIndex
          team.TeamColor = teamInfo.BrickColor
          team:SetAttribute("ShortName", teamInfo.ShortName)
          teamInfo.Team = team
          SecurityService.VerifiedTeams[teamIndex] = teamInfo
     end
end

local getTeam = function(teamId)
     if typeof(teamId) == "Instance" then
          if teamId:IsA("Team") then return teamId end
     elseif typeof(teamId) == "string" then
          local t = Teams:FindFirstChild(teamId)
          if t then return t end
     end
end

function SecurityService:CheckTeam(teamId)
     local team = getTeam(teamId)
     local teamInfo = SecurityService.VerifiedTeams[team.Name]
     if teamInfo ~= nil then
          return teamInfo
     end
end

function SecurityService:CheckTeamPermission(teamId, perm)
     local teamInfo = SecurityService:CheckTeam(teamId)
     if teamInfo.Permissions ~= nil then
          if teamInfo.Permissions[perm] ~= nil then
               return teamInfo.Permissions[perm]
          end
     end
end

function SecurityService:CheckPermissionByTeam(player, perm)
     if player.Team ~= nil then
          local teamId = player.Team.Name
          return SecurityService:CheckTeamPermission(teamId, perm)
     end
end

function SecurityService.KnitInit()
     PrepareTeams()
end

function SecurityService.KnitStart()

end

return SecurityService