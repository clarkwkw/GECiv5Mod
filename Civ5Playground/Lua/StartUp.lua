-- StartUp
-- Author: clark
-- DateCreated: 1/20/2018 9:52:09 AM
--------------------------------------------------------------

print("Hello world from Civ5Playground!!!!!!!!!!!!!!!!!!!!!")

include("Utils.lua")
include("ObjectCountListeners.lua")

print("Adding listeners..")

--- Monitoring no. of Palace Built
Events.ActivePlayerTurnStart.Add(
	BuildingCountListenerFactory(
		GameInfo.BuildingClasses.BUILDINGCLASS_PALACE.ID, --- Palace
		"NOTIFICATION_PALACE_BUILT", 
		1, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_PALACE_TITLE"),
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_PALACE_MSG")
	)
)

--- Monitoring no. of Settler Built
Events.ActivePlayerTurnStart.Add(
	UnitCountListenerFactory(
		GameInfo.UnitClasses.UNITCLASS_SETTLER.ID, --- SETTLER
		"NOTIFICATION_SETTLER_BUILT", 
		1, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_SETTLER_TITLE"),
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_SETTLER_MSG")
	)
)