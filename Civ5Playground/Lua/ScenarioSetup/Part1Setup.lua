local KEY_PREREQUISITE_TECH = "TECH_EDUCATION"
local TXT_PREREQUISITE_TECH = Locale.Lookup("TXT_KEY_TECH_EDUCATION")
local KEY_BUILDING_TYPE = "BUILDING_UNIVERSITY"
local BUILDING_CLASS_ID = GameInfo.BuildingClasses.BUILDINGCLASS_UNIVERSITY.ID
local TXT_BUILDING = Locale.Lookup("TXT_KEY_BUILDING_UNIVERSITY")
local NUM_BUILDING_REQUIRED = 4
local TXT_RESEARCHED_NEXT_STEP = string.format(Locale.Lookup("TXT_KEY_RESEARCHED_NEXT_STEP"), TXT_BUILDING, TXT_BUILDING)

function RequirementPopup()
	AdvisorManager.GenerateAdvisorPopUp(
		Game.GetActivePlayer(),
		AdvisorTypes.ADVISOR_MILITARY, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_JUST_STARTED_TITLE"),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_REQUIREMENTS"),
			NUM_BUILDING_REQUIRED,
			NUM_BUILDING_REQUIRED,
			TXT_BUILDING,
			TXT_PREREQUISITE_TECH
		)
	)
	return true
end

ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_PART1_STARTED",
		RequirementPopup
)

--- Shown on successfully researched
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_PART1_TECH_RESEARCHED",
	TechnologyResearchedListenerFactory(
		GameInfoTypes[KEY_PREREQUISITE_TECH],
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_TITLE"), 
			TXT_PREREQUISITE_TECH
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_MSG"),
			TXT_PREREQUISITE_TECH,
			TXT_RESEARCHED_NEXT_STEP
		),
		true
	)
)

--- Shown on successfully building universities
for i = 1, NUM_BUILDING_REQUIRED - 1 do 	
	ListenerManager.AddIndividualTurnStartListener(	
		string.format("NOTIFICATION_PART1_BUILDING_CONSTRUCTED_%d", i),	
		BuildingCountListenerFactory(	
			BUILDING_CLASS_ID,
			i, 	
			string.format(	
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),	
				TXT_BUILDING	
			),	
			string.format(	
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_MSG"), 	
				i, 	
				TXT_BUILDING,	
				NUM_BUILDING_REQUIRED - i	
			),	
			true	
		)	
	)	
end

ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_PART1_COMPLETED",
	BuildingCountListenerFactory(
		BUILDING_CLASS_ID,
		1, 
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
			TXT_BUILDING
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_FINISH_MSG"), 
			TXT_BUILDING
		),
		true
	)
)

function OnUpdateProgressItems(localPlayer)
	local researched = 0
	if Teams[localPlayer:GetTeam()]:IsHasTech(KEY_PREREQUISITE_TECH) then
		researched = 1
	end

	LuaEvents.OnAddProgressItem(
		GameInfo.Technologies[KEY_PREREQUISITE_TECH], 
		TXT_PREREQUISITE_TECH, 
		string.format("%d/%d", researched, 1)
	)

	LuaEvents.OnAddProgressItem(
		GameInfo.Buildings[KEY_BUILDING_TYPE], 
		TXT_BUILDING, 
		string.format("%d/%d", localPlayer:GetBuildingClassCount(BUILDING_CLASS_ID), NUM_BUILDING_REQUIRED)
	)

	local myLeaderInfo = GameInfo.Leaders[localPlayer:GetLeaderType()];

	LuaEvents.OnAddProgressItem(
		myLeaderInfo, 
		Locale.Lookup("TXT_KEY_GEF_PROGRESS_STARTTIME"), 
		Utils.GetGlobalProperty("STARTTIME")
	)
end
LuaEvents.OnUpdateProgressItems.Add(OnUpdateProgressItems)