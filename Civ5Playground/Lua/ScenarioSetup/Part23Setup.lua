local TXT_ATOMIC_THEORY = Locale.Lookup("TXT_KEY_TECH_ATOMIC_THEORY_TITLE")
local TXT_MANHATTAN_PROJ = Locale.Lookup("TXT_KEY_PROJECT_MANHATTAN_PROJECT")

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

local religionConfigured = Utils.GetGlobalProperty("Part23ReligionConfigured")
if not religionConfigured then
	include("ReligionSetup.lua")
	SetupReligion("Part23")
	Utils.SetGlobalProperty("Part23ReligionConfigured", true)
end

--- Shown on successfully researched atomic theory
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_ATOMIC_THEORY_RESEARCHED",
	TechnologyResearchedListenerFactory(
		GameInfoTypes["TECH_ATOMIC_THEORY"],
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_TITLE"), 
			TXT_ATOMIC_THEORY
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_MSG"), 
			TXT_ATOMIC_THEORY,
			Locale.Lookup("TXT_KEY_PART23_RESEARCHED_NEXT_STEP")
		),
		true
	)
)

--- Shown on completing Manhattan Project
ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_MANHATTAN_PROJ_BUILT",
		ProjectCompletedListenerFactory(
			GameInfo.Projects.PROJECT_MANHATTAN_PROJECT.ID,
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
				TXT_MANHATTAN_PROJ
			),
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_FINISH_MSG"),
				TXT_MANHATTAN_PROJ
			),
			true
		)
	)