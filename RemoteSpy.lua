-- RemoteEvent Logger: Spy on damage/combat events
local replicatedStorage = game:GetService("ReplicatedStorage")

local function scanForRemotes(parent)
	for _, child in pairs(parent:GetDescendants()) do
		if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
			print("[Found Remote]: " .. child:GetFullName())
			
			-- Hook onto fired events to see what arguments/data are sent
			if child:IsA("RemoteEvent") then
				child.OnClientEvent:Connect(function(...)
					-- print("Received from server:", child.Name, ...)
				end)
			end
		end
	end
end

print("--- Scanning ReplicatedStorage for Remotes ---")
scanForRemotes(replicatedStorage)
print("--- Scan Complete. Check your executor console when attacking the boss! ---")
