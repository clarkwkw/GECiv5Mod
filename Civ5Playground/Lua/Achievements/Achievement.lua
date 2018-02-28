Achievement = {}

function Achievement:New(o)
	local required_fields = {"EventID", "EventName", "Leaders", "Quota", "Reward", "Condition", "ObsoleteCondition"}
	local optional_fields = {"AdvisorType", "AdvisorHeading", "AdvisorBody"}

	for i, key in ipairs(required_fields) do
		if not o[key] then
			error("Achievement missing attribute '"..key.."'")
		end
	end

	o.progress = Utils.GetGlobalProperty("Achievement"..o.EventID)
	if o.progress == nil then
		o.progress = {obsoleted = false, achieved = 0}
		Utils.SetGlobalProperty("Achievement"..o.EventID, Utils.ToLuaCode(o.progress))
	else
		o.progress = Utils.FromLuaCode(o.progress)
	end

	setmetatable(o, self)
    self.__index = self

    if not o.progress["obsoleted"] then
    	print("Registering achievement "..o.EventID)
    	HistoricalEventManager.AddToQueue(o)
    	o.subEvent = HistoricalEvent:New({
    		EventID = o.EventID,
    		EventName = o.EventName,
    		OccurYear = -100000,
    		Leaders = {},
    		Compensation = o.Reward,
    		AdvisorType = o.AdvisorType,
    		AdvisorHeading = o.AdvisorHeading,
    		AdvisorBody = o.AdvisorBody
    	})
    else
    	print("Skipping achievement "..o.EventID)
    end

    return o
end

function Achievement:CheckCondition()
	if self.progress["achieved"] >= self.Quota or self.ObsoleteCondition() then
		print("Achievement "..self.EventID.." obsoleted")
		self.progress["obsoleted"] = true
		Utils.SetGlobalProperty("Achievement"..self.EventID, Utils.ToLuaCode(self.progress))
		return -1
	end
	return 1
end

function Achievement:Trigger()
	skipSave = skipSave or false
	local isShowAdvisor = self.AdvisorType ~= nil and self.AdvisorHeading ~= nil and self.AdvisorBody ~= nil
	local eventPlayers = {}
	if self.Leaders == "all" then
		eventPlayers = Players
	elseif self.Leaders == "allhuman" then
		for key, player in pairs(Players) do
			if player:IsHuman() then
				table.insert(eventPlayers, player)
			end
		end
	else
		for key, leader in pairs(self.Leaders) do
			table.insert(eventPlayers, Utils.GetPlayerByLeaderType(leader))
		end
	end
	for key, player in pairs(eventPlayers) do
		if self.progress["achieved"] < self.Quota  and self.progress[player:GetID()] == nil then
			local isAchieved = self.Condition(player)
			if isAchieved then
				self.subEvent:Trigger(true, {player})
				self.progress[player:GetID()] = true
				self.progress["achieved"] = self.progress["achieved"] + 1
				Utils.SetGlobalProperty("Achievement"..self.EventID, Utils.ToLuaCode(self.progress))
			end
		end
	end
end

include("AchievementsList.lua")