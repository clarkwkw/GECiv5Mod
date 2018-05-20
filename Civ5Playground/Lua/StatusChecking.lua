local GetBonusDispensedStr = function()
	local debug_bonus_dispensed_str = ""
	if Utils.GetGlobalProperty("TesterBonusLastDispensed") then
		debug_bonus_dispensed_str = "[COLOR_FONT_RED]Yes (cheating?)[ENDCOLOR]"
	else
		debug_bonus_dispensed_str = "[COLOR_FONT_GREEN]No[ENDCOLOR]"
	end
	return debug_bonus_dispensed_str
end

local GetTechProgressStr = function(techType)
	local player = Utils.GetCurrentPlayer()
	local researched = Teams[player:GetTeam()]:IsHasTech(techType)
	if researched then
		return "[COLOR_FONT_GREEN]Yes[ENDCOLOR]"
	else
		return "[COLOR_FONT_RED]No[ENDCOLOR]"
	end

end

local GetBuildingProgressStr = function(buildingClassId)
	local player = Utils.GetCurrentPlayer()
	return "" .. player:GetBuildingClassCount(buildingClassId)
end

local GetProjectProgressStr = function(projectType)
	local player = Utils.GetCurrentPlayer()
	local count = Teams[player:GetTeam()]:GetProjectCount(projectType)
	if count > 0 then
		return "[COLOR_FONT_GREEN]Yes[ENDCOLOR]"
	else
		return "[COLOR_FONT_RED]No[ENDCOLOR]"
	end

end

PopCheckingMsg = function()
	local player = Utils.GetCurrentPlayer()
	print("DEBUG MODE: "..GameDefines.UGFN_DEBUG_MODE)
	
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		"Debug Messages",
		"[NEWLINE]"..
		"Start time: "..Utils.GetGlobalProperty("STARTTIME").."[NEWLINE]"..
		"Year: "..Game.GetGameTurnYear().."[NEWLINE]"..
		"Debug bonus dispensed: "..GetBonusDispensedStr().."[NEWLINE]"..
		"No. of cities holding: "..player:GetNumCities().."[NEWLINE][NEWLINE]"..

		"Part 1 Summary".."[NEWLINE]"..
		"Education researched: "..GetTechProgressStr(GameInfoTypes["TECH_EDUCATION"]).."[NEWLINE]"..
		"Universities built: "..GetBuildingProgressStr(GameInfo.BuildingClasses.BUILDINGCLASS_UNIVERSITY.ID).."[NEWLINE]"..
		"Oxford University built: "..GetBuildingProgressStr(GameInfo.BuildingClasses.BUILDINGCLASS_OXFORD_UNIVERSITY.ID).."[NEWLINE][NEWLINE]"..
		
		"Part 2/3 Summary".."[NEWLINE]"..
		"Atomic Theory researched: "..GetTechProgressStr(GameInfoTypes["TECH_ATOMIC_THEORY"]).."[NEWLINE]"..
		"Manhatton Project constructed: "..GetProjectProgressStr(GameInfo.Projects.PROJECT_MANHATTAN_PROJECT.ID)

	)
	return false
end