local BlackDeathOccurProb = function(player)
	return 1 - 0.1*player:CountNumBuildings(GameInfo.Buildings["BUILDING_HOSPITAL"])
end

local BlackDeathObsoleteCondition = function()
	return HistoricalEventManager.GetCurrentYear() >= 1900
end

DisasterEvent:New({
	EventID = "BLACKDEATH",
	EventName = "TXT_KEY_UGFN_DISASTER_BLACKDEATH_NAME",
	AdvisorType = "ADVISOR_ECONOMIC",
	AdvisorHeading = "TXT_KEY_UGFN_DISASTER_BLACKDEATH_ADVHEAD",
	AdvisorBody = "TXT_KEY_UGFN_DISASTER_BLACKDEATH_BODY",
	Leaders = "all",
	OccurProb = BlackDeathOccurProb,
	ObsoleteCondition = BlackDeathObsoleteCondition,
	Loss = {
		Population = 0.1,
		UnitHP = 50,
		PillageTiles = {
			Range = 2,
			Prob = 1.0
		}
	}
})