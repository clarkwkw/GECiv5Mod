WrongScenarioSettingsPopup = function()
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_TITLE"),
		string.format(Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_CHECK_SCENARIO_MSG"), "PART 1")
	)
	return false
end

if not PreGame.GetLoadWBScenario() then
	print("Scenario not activated, going to prompt reminder..")
	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_WRONG_SCENARIO_MSG",
		WrongScenarioSettingsPopup
	)
end

--- Shown on successfully researched education
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_EDUCATION_RESEARCHED",
	TechnologyResearchedListenerFactory(
		GameInfoTypes["TECH_EDUCATION"],
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_EDUCATION_TITLE"),
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_EDUCATION_MSG"),
		true
	)
)

--- Shown on successfully building universities
local UNIVERSITIES_REQUIRED = 3
for i = 1,UNIVERSITIES_REQUIRED - 1 do 
	ListenerManager.AddIndividualTurnStartListener(
		string.format("NOTIFICATION_UNIVERSITY_BUILT_%d", i),
		BuildingCountListenerFactory(
			GameInfo.BuildingClasses.BUILDINGCLASS_UNIVERSITY.ID,
			i, 
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_UNIVERSITY_TITLE"),
			string.format(Locale.Lookup("TXT_KEY_UGFN_PROGRESS_UNIVERSITY_MSG"), i, UNIVERSITIES_REQUIRED - i),
			true
		)
	)
end
ListenerManager.AddIndividualTurnStartListener(
	string.format("NOTIFICATION_UNIVERSITY_BUILT_%d", UNIVERSITIES_REQUIRED),
	BuildingCountListenerFactory(
		GameInfo.BuildingClasses.BUILDINGCLASS_UNIVERSITY.ID,
		UNIVERSITIES_REQUIRED, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_UNIVERSITY_TITLE"),
		string.format(Locale.Lookup("TXT_KEY_UGFN_PROGRESS_UNIVERSITY_FINISH_MSG"), UNIVERSITIES_REQUIRED),
		true
	)
)


