-- Advanced Real-Time Remote Spy
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("--- [RemoteSpy] Started Listening to Game Traffic ---")

-- Hook into all RemoteEvents in the game
for _, obj in pairs(game:GetDescendants()) do
	if obj:IsA("RemoteEvent") then
		pcall(function()
			obj.OnClientEvent:Connect(function(...)
				print("[ClientEvent Received]:", obj:GetFullName(), ...)
			end)
		end)
	end
end

-- Intercept when anything tries to fire a remote to the server
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
		print("[Remote Fired] ->", self:GetFullName(), "Arguments:", ...)
	end
	return oldNamecall(self, ...)
end)

print("--- [RemoteSpy] Ready! Attack the boss now and check logs. ---")
