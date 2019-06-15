local FREE_POLICY_SAVE_NAME = "FREE_POLICY_BANK";

function getNumSavedFreePolicy(player)
	return Utils.GetPlayerProperty(player:GetID(), FREE_POLICY_SAVE_NAME) or 0
end

function onRequestNumSavedFreePolicy()
	local player = Utils.GetCurrentPlayer()
	LuaEvents.OnRequestNumSavedFreePolicyCallback(getNumSavedFreePolicy(player))
end
LuaEvents.OnRequestNumSavedFreePolicy.Add(onRequestNumSavedFreePolicy)

function saveCurrentFreePolicy()
	print("Saving policy")
	local player = Utils.GetCurrentPlayer()
	local savedFreePolicy = getNumSavedFreePolicy(player)
	Utils.SetPlayerProperty(player:GetID(), FREE_POLICY_SAVE_NAME, savedFreePolicy + player:GetNumFreePolicies())
	player:SetNumFreePolicies(0)
end
LuaEvents.OnSaveCurrentFreePolicy.Add(saveCurrentFreePolicy)

function grantSavedFreePolicy()
	local player = Utils.GetCurrentPlayer()
	local savedFreePolicy = getNumSavedFreePolicy(player)
	player:SetNumFreePolicies(savedFreePolicy)
	Utils.SetPlayerProperty(player:GetID(), FREE_POLICY_SAVE_NAME, 0)
end
LuaEvents.OnGrantSavedFreePolicy.Add(grantSavedFreePolicy)