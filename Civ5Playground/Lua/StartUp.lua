include("UGFNUtils.lua")
include("ObjectCountListeners.lua")
include("ListenerManager.lua")
include("AdvisorManager.lua")
include("HistoricalEvent.lua")
include("BerserkEnermy.lua")
include("Disaster.lua")
include("Achievement.lua")

Utils.GenerateCheckString()
HistoricalEventManager.InitEvents()
BerserkEnermyEventManager.InitEvents()
Events.ActivePlayerTurnStart.Add(ListenerManager.ExecuteTurnStartListeners)
Events.ActivePlayerTurnStart.Add(Utils.UpdateTotalTimeSpent)
Events.ActivePlayerTurnStart.Add(AdvisorManager.TriggerOnePopUp)
Events.ActivePlayerTurnEnd.Add(AdvisorManager.Dominate)
Events.AdvisorDisplayHide.Add(AdvisorManager.TriggerOnePopUp)

print("Adding listeners..")

ListenerManager.AddGlobalTurnStartListener(
	"FIRST_TURN_FINISHED",
	Utils.SetFirstTurnFinished
)

ListenerManager.AddGlobalTurnStartListener(
	"HISTORICAL_EVENTS",
	HistoricalEventManager.TriggerEvents
)

ListenerManager.AddGlobalTurnStartListener(
	"BERSERK_ENERMY",
	BerserkEnermyEventManager.TriggerEvents
)

if GameDefines.UGFN_DEBUG_MODE == 1 then
	include("StatusChecking.lua")
	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_DEBUG_MSG",
		PopCheckingMsg
	)
end

_, mapname, _ = Utils.SplitPath(PreGame.GetMapScript())
print("Selected Map: " .. mapname)

include("CommonSetup.lua")
if mapname == "UGFN Part 1" then
	include("Part1Setup.lua")

elseif "UGFN Part 23" then
	Events.NotificationAdded.Add(Utils.HandleFirstTurnNotificationAdded)
	include("Part23Setup.lua")

end