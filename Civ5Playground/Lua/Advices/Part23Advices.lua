local TXT_INDUSTRIALIZATION = Locale.Lookup("TXT_KEY_TECH_INDUSTRIALIZATION")
local TXT_FACTORY = Locale.Lookup("TXT_KEY_BUILDING_FACTORY")

WrongScenarioSettingsPopup = function()
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_TITLE"),
		string.format(Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_CHECK_SCENARIO_MSG"), "PART 2/3")
	)
	return false
end

CorrectSettingsPopup = function()
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		Locale.Lookup("TXT_KEY_UGFN_CORRECT_SETTINGS_TITLE"),
		string.format(Locale.Lookup("TXT_KEY_UGFN_CORRECT_SETTINGS_MSG"), "PART 2/3", Locale.Lookup("TXT_KEY_UGFN_PART23_REQUIREMENTS"))
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
	print("Correct settings for part 2/3, going to prompt a popup..")
	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_CORRECT_SETTINGS_MSG",
		CorrectSettingsPopup
	)
end

--- Shown on successfully researched industrialization
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_INDUSTRIALIZATION_RESEARCHED",
	TechnologyResearchedListenerFactory(
		GameInfoTypes["TECH_INDUSTRIALIZATION"],
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_TITLE"), 
			TXT_INDUSTRIALIZATION
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_MSG"), 
			TXT_INDUSTRIALIZATION,
			TXT_FACTORY
		),
		true
	)
)

--- Shown on successfully building factories
local FACTORIES_REQUIRED = 3
for i = 1,FACTORIES_REQUIRED - 1 do 
	ListenerManager.AddIndividualTurnStartListener(
		string.format("NOTIFICATION_FACTORY_BUILT_%d", i),
		BuildingCountListenerFactory(
			GameInfo.BuildingClasses.BUILDINGCLASS_FACTORY.ID,
			i, 
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
				TXT_FACTORY
			),
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_MSG"), 
				i, 
				TXT_FACTORY,
				FACTORIES_REQUIRED - i
			),
			true
		)
	)
end
ListenerManager.AddIndividualTurnStartListener(
	string.format("NOTIFICATION_FACTORY_BUILT_%d", FACTORIES_REQUIRED),
	BuildingCountListenerFactory(
		GameInfo.BuildingClasses.BUILDINGCLASS_FACTORY.ID,
		FACTORIES_REQUIRED, 
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
			TXT_FACTORY
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_FINISH_MSG"), 
			FACTORIES_REQUIRED,
			TXT_FACTORY
		),
		true
	)
)