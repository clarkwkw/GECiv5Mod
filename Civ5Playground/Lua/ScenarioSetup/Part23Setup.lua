local KEY_PREREQUISITE_TECH = "TECH_INDUSTRIALIZATION"
local TXT_PREREQUISITE_TECH = Locale.Lookup("TXT_KEY_TECH_INDUSTRIALIZATION")
local BUILDING_CLASS_ID = GameInfo.BuildingClasses.BUILDINGCLASS_FACTORY.ID
local KEY_BUILDING_TYPE = "BUILDING_FACTORY"
local TXT_BUILDING = Locale.Lookup("TXT_KEY_BUILDING_FACTORY")
local NUM_BUILDING_REQUIRED = 4
local TXT_RESEARCHED_NEXT_STEP = string.format(Locale.Lookup("TXT_KEY_RESEARCHED_NEXT_STEP"), TXT_BUILDING, TXT_BUILDING)

local religionConfigured = Utils.GetGlobalProperty("Part23ReligionConfigured")
if not religionConfigured then
	include("ReligionSetup.lua")
	SetupReligion("Part23")
	Utils.SetGlobalProperty("Part23ReligionConfigured", true)
end

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
		"NOTIFICATION_PART23_STARTED",
		RequirementPopup
)

--- Shown on successfully researched
ListenerManager.AddIndividualTurnStartListener(
	"NOTIFICATION_PART23_TECH_RESEARCHED",
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
		string.format("NOTIFICATION_PART23_BUILDING_CONSTRUCTED_%d", i),	
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
	"NOTIFICATION_PART23_COMPLETED",
	BuildingCountListenerFactory(
		BUILDING_CLASS_ID,
		NUM_BUILDING_REQUIRED, 
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
	if Teams[localPlayer:GetTeam()]:IsHasTech(GameInfoTypes[KEY_PREREQUISITE_TECH]) then
		researched = 1
	end

	LuaEvents.OnAddIntProgressItem(
		GameInfo.Technologies[KEY_PREREQUISITE_TECH], 
		TXT_PREREQUISITE_TECH, 
		researched,
		1
	)
	
	LuaEvents.OnAddIntProgressItem(
		GameInfo.Buildings[KEY_BUILDING_TYPE], 
		TXT_BUILDING, 
		localPlayer:GetBuildingClassCount(BUILDING_CLASS_ID), 
		NUM_BUILDING_REQUIRED
	)

	local myLeaderInfo = GameInfo.Leaders[localPlayer:GetLeaderType()];

	LuaEvents.OnAddTextProgressItem(
		myLeaderInfo, 
		Locale.Lookup("TXT_KEY_GEF_PROGRESS_STARTTIME"), 
		Utils.GetGlobalProperty("STARTTIME")
	)
end
LuaEvents.OnUpdateProgressItems.Add(OnUpdateProgressItems)