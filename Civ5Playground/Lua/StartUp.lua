-- StartUp
-- Author: clark
-- DateCreated: 1/20/2018 9:52:09 AM
--------------------------------------------------------------

print("Hello world from Civ5Playground!!!!!!!!!!!!!!!!!!!!!")

include("Utils.lua")
include("ObjectCountListeners.lua")
include("ListenerManager.lua")

GenerateCheckString()
print("Adding listeners..")

AddTurnStartListeners(
	"NOTIFICATION_DEBUG_MSG",
	PopDebugMsg
)

--- Monitoring no. of Palace Built
AddTurnStartListeners(
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
AddTurnStartListeners(
	"NOTIFICATION_SETTLER_BUILT",
	BuildingCountListenerFactory(
		GameInfo.UnitClasses.UNITCLASS_SETTLER.ID, --- SETTLER
		1, 
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_SETTLER_TITLE"),
		Locale.Lookup("TXT_KEY_UGFN_PROGRESS_SETTLER_MSG"),
		true
	)

)

Events.ActivePlayerTurnStart.Add(ExecuteTurnStartListeners)
Events.ActivePlayerTurnStart.Add(TriggerOnePopUp)
Events.AdvisorDisplayHide.Add(TriggerOnePopUp)

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
