FirstInWaterCondition = function (player)
	return Teams[player:GetTeam()]:IsHasTech(GameInfoTypes["TECH_SAILING"])
end

FirstInWaterObsoleteCondition = function ()
	return HistoricalEventManager.GetCurrentYear() >= 0
end

--[[
Achievement:New({
	EventID = "FIRSTINWATER",
	EventName = "TXT_KEY_UGFN_FIRSTINWATER_NAME",
	Leaders = "allhuman",
	Quota = 1,
	Reward = {
		UNIT_GREAT_ADMIRAL = 1,
		UNIT_PROPHET = 1
	},
	Condition = FirstInWaterCondition,
	ObsoleteCondition = FirstInWaterObsoleteCondition,
	AdvisorType = "ADVISOR_MILITARY",
	AdvisorHeading = "TXT_KEY_UGFN_FIRSTINWATER_ADVHEAD",
	AdvisorBody = "TXT_KEY_UGFN_FIRSTINWATER_BODY"
})
--]]