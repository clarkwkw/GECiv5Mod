--- Add additional resouces for fast testing
local testers = {}
for key, player in pairs(Players) do
	if player:IsHuman() then
		local name = string.lower(player:GetName())
		print("Found human player "..name)
		if string.match(name, "helper") or string.match(name, "clark") then
			table.insert(testers, player)
		end		
	end
end

if #testers > 0 then
	print("Adding tester bonus..")
	ListenerManager.AddGlobalTurnStartListener("TESTER_BONUS", ListenerManager.TestBonusListenerFactory(testers))
end