-- StartUp
-- Author: clark
-- DateCreated: 1/20/2018 9:52:09 AM
--------------------------------------------------------------

print("Hello world from Civ5Playground!!!!!!!!!!!!!!!!!!!!!")

include("Utils.lua")
include("ObjectCountListeners.lua")
include("ListenerManager.lua")
include("AdvisorManager.lua")
include("HistoricalEvent.lua")
include("BerserkEnermy.lua")

Utils.GenerateCheckString()
HistoricalEventManager.InitEvents()
BerserkEnermyEventManager.InitEvents()
print("Adding listeners..")

ListenerManager.AddTurnStartListeners(
	"NOTIFICATION_DEBUG_MSG",
	Utils.PopDebugMsg
)

--- Monitoring no. of Palace Built
ListenerManager.AddTurnStartListeners(
	"NOTIFICATION_PALACE_BUILT",
	BuildingCountListenerFactory(
		GameInfo.BuildingClasses.BUILDINGCLASS_PALACE.ID, --- Palace 
		1, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_PALACE_TITLE"),
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_PALACE_MSG"),
		true
	)

)

--- Monitoring no. of Settler Built
ListenerManager.AddTurnStartListeners(
	"NOTIFICATION_SETTLER_BUILT",
	BuildingCountListenerFactory(
		GameInfo.UnitClasses.UNITCLASS_SETTLER.ID, --- SETTLER
		1, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_SETTLER_TITLE"),
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_SETTLER_MSG"),
		true
	)

)

ListenerManager.AddTurnStartListeners(
	"HISTORICAL_EVENTS",
	HistoricalEventManager.TriggerEvents
)

ListenerManager.AddTurnStartListeners(
	"BERSERK_ENERMY",
	BerserkEnermyEventManager.TriggerEvents
)

Events.ActivePlayerTurnStart.Add(ListenerManager.ExecuteTurnStartListeners)
Events.ActivePlayerTurnStart.Add(AdvisorManager.TriggerOnePopUp)
Events.AdvisorDisplayHide.Add(AdvisorManager.TriggerOnePopUp)

--[[
Events.ActivePlayerTurnStart.Add(
	function()
		for j = 1, 5 do
			local st = os.clock()
			local n = 1000000*j
			for i = 1, n do
				player = GetCurrentPlayer()
				player:GetBuildingClassCount(GameInfo.BuildingClasses.BUILDINGCLASS_PALACE.ID)
			end
			print(string.format("elapsed time [%d]: %.2f", n, os.clock() - st))
		end
	end
)
--]]
