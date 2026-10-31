-- Safe Remote Scanner (No Hooks - Won't Crash)
print("--- [SafeScanner] Scanning for Remotes ---")

local function scanFolder(folder)
	for _, child in pairs(folder:GetDescendants()) do
		if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
			print("Found Remote:", child:GetFullName())
		end
	end
end

pcall(function()
	scanFolder(game:GetService("ReplicatedStorage"))
end)

pcall(function()
	if game:GetService("Workspace"):FindFirstChild("Remotes") then
		scanFolder(game:GetService("Workspace").Remotes)
	end
end)

print("--- [SafeScanner] Scan Complete! ---")
