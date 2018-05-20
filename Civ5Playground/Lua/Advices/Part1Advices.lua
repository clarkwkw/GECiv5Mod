local TXT_EDUCATION = Locale.Lookup("TXT_KEY_TECH_EDUCATION")
local TXT_UNIVERSITY = Locale.Lookup("TXT_KEY_BUILDING_OXFORD_UNIVERSITY")

WrongScenarioSettingsPopup = function()
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_TITLE"),
		string.format(Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_CHECK_SCENARIO_MSG"), "PART 1")
	)
	return false
end

CorrectSettingsPopup = function()
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		Locale.Lookup("TXT_KEY_UGFN_CORRECT_SETTINGS_TITLE"),
		string.format(Locale.Lookup("TXT_KEY_UGFN_CORRECT_SETTINGS_MSG"), "PART 1", Locale.Lookup("TXT_KEY_UGFN_PART1_REQUIREMENTS"))
	)
	return true
end

if not PreGame.GetLoadWBScenario() then
	print("Scenario not activated, going to prompt reminder..")
	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_WRONG_SCENARIO_MSG",
		WrongScenarioSettingsPopup
	)
else
	print("Correct settings for part 1, going to prompt a popup..")
	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_CORRECT_SETTINGS_MSG",
		CorrectSettingsPopup
	)
end

--- Shown on successfully researched education
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_EDUCATION_RESEARCHED",
	TechnologyResearchedListenerFactory(
		GameInfoTypes["TECH_EDUCATION"],
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_TITLE"), 
			TXT_EDUCATION
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_MSG"), 
			TXT_EDUCATION,
			Locale.Lookup("TXT_KEY_PART1_RESEARCHED_NEXT_STEP")
		),
		true
	)
)

--- Shown on successfully building oxford university
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_OXFORD_UNIVERSITY_BUILT",
	BuildingCountListenerFactory(
		GameInfo.BuildingClasses.BUILDINGCLASS_OXFORD_UNIVERSITY.ID,
		1, 
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
			TXT_UNIVERSITY
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_FINISH_MSG"), 
			TXT_UNIVERSITY
		),
		true
	)
)


