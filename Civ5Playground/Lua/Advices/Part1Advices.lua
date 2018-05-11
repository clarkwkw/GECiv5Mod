local TXT_EDUCATION = Locale.Lookup("TXT_KEY_TECH_EDUCATION")
local TXT_UNIVERSITY = Locale.Lookup("TXT_KEY_BUILDING_UNIVERSITY")

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
			TXT_UNIVERSITY
		),
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
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
				TXT_UNIVERSITY
			),
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_MSG"), 
				i, 
				TXT_UNIVERSITY,
				UNIVERSITIES_REQUIRED - i
			),
			true
		)
	)
end
ListenerManager.AddIndividualTurnStartListener(
	string.format("NOTIFICATION_UNIVERSITY_BUILT_%d", UNIVERSITIES_REQUIRED),
	BuildingCountListenerFactory(
		GameInfo.BuildingClasses.BUILDINGCLASS_UNIVERSITY.ID,
		UNIVERSITIES_REQUIRED, 
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
			TXT_UNIVERSITY
		)
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_FINISH_MSG"), 
			UNIVERSITIES_REQUIRED,
			TXT_UNIVERSITY
		),
		true
	)
)


