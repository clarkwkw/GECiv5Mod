local FREE_POLICY_SAVE_NAME = "FREE_POLICY_BANK";
local FREE_TENET_SAVE_NAME = "FREE_TENET_BANK";

function getNumSavedFreePolicy(player)
	return Utils.GetPlayerProperty(player:GetID(), FREE_POLICY_SAVE_NAME) or 0
end

function onRequestNumSavedFreePolicy()
	local player = Utils.GetCurrentPlayer()
	LuaEvents.OnRequestNumSavedFreePolicyCallback(getNumSavedFreePolicy(player))
end
LuaEvents.OnRequestNumSavedFreePolicy.Add(onRequestNumSavedFreePolicy)

function saveCurrentFreePolicy()
	local player = Utils.GetCurrentPlayer()
	local savedFreePolicy = getNumSavedFreePolicy(player)
	Utils.SetPlayerProperty(player:GetID(), FREE_POLICY_SAVE_NAME, savedFreePolicy + player:GetNumFreePolicies())
	player:SetNumFreePolicies(0)
end
LuaEvents.OnSaveCurrentFreePolicy.Add(saveCurrentFreePolicy)

function grantSavedFreePolicy()
	local player = Utils.GetCurrentPlayer()
	local savedFreePolicy = getNumSavedFreePolicy(player)
	player:ChangeNumFreePolicies(savedFreePolicy)
	Utils.SetPlayerProperty(player:GetID(), FREE_POLICY_SAVE_NAME, 0)
end
LuaEvents.OnGrantSavedFreePolicy.Add(grantSavedFreePolicy)

function getNumSavedFreeTenet(player)
	return Utils.GetPlayerProperty(player:GetID(), FREE_TENET_SAVE_NAME) or 0
end

function onRequestNumSavedFreeTenet()
	local player = Utils.GetCurrentPlayer()
	LuaEvents.OnRequestNumSavedFreeTenetCallback(getNumSavedFreeTenet(player))
end
LuaEvents.OnRequestNumSavedFreeTenet.Add(onRequestNumSavedFreeTenet)

function saveCurrentFreeTenet()
	local player = Utils.GetCurrentPlayer()
	local savedFreeTenet = getNumSavedFreeTenet(player)
	Utils.SetPlayerProperty(player:GetID(), FREE_TENET_SAVE_NAME, savedFreeTenet + player:GetNumFreeTenets())
	player:SetNumFreeTenets(0)
end
LuaEvents.OnSaveCurrentFreeTenet.Add(saveCurrentFreeTenet)

function grantSavedFreeTenet()
	local player = Utils.GetCurrentPlayer()
	local savedFreeTenet = getNumSavedFreeTenet(player)
	player:ChangeNumFreeTenets(savedFreeTenet)
	Utils.SetPlayerProperty(player:GetID(), FREE_TENET_SAVE_NAME, 0)
end
LuaEvents.OnGrantSavedFreeTenet.Add(grantSavedFreeTenet)