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
Events.ActivePlayerTurnStart.Add(AdvisorManager.TriggerOnePopUp)
Events.ActivePlayerTurnEnd.Add(AdvisorManager.Dominate)
Events.AdvisorDisplayHide.Add(AdvisorManager.TriggerOnePopUp)

print("Adding listeners..")

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
print("map: " .. mapname)

include("CommonAdvices.lua")
if mapname == "UGFN Part 1" then
	include("Part23Advices.lua")
	---include("Part1Advices.lua")

elseif "UGFN Part 23" then
	include("Part23Advices.lua")

else
	print("Map not selected, going to prompt reminder..")
	WrongMapSettingsPopup = function()
		AdvisorManager.GenerateAdvisorPopUp(
			Game.GetActivePlayer(),
			AdvisorTypes.ADVISOR_MILITARY, 
			Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_TITLE"),
			Locale.Lookup("TXT_KEY_UGFN_WRONG_SETTINGS_MAP_MSG")
		)
		return false
	end
	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_WRONG_MAP_MSG",
		WrongMapSettingsPopup
	)
end