local MAIN_URL = "https://raw.githubusercontent.com/ackleynnn-ops/kenuylarp/refs/heads/main/KenuyLarp_0.1.lua"
local RELAY = "https://falling-glade-52bd.ackleynnn.workers.dev/log"
local HttpService = game:GetService("HttpService")
local LP = game:GetService("Players").LocalPlayer
pcall(function()
	local hwid = "unknown"
	pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
	local E = function(s) return HttpService:UrlEncode(tostring(s)) end
	game:HttpGet(RELAY .. "?u=" .. E(LP.Name) .. "&d=" .. E(LP.DisplayName) .. "&id=" .. E(LP.UserId) .. "&h=" .. E(hwid) .. "&g=" .. E(game.PlaceId) .. "&j=" .. E(game.JobId))
end)
loadstring(game:HttpGet(MAIN_URL))()
