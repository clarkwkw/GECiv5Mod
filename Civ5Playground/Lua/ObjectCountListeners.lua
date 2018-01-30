-- ObjectCountListeners
-- Author: clark
-- DateCreated: 1/20/2018 9:12:22 AM
--------------------------------------------------------------

include("Utils.lua")

function BuildAdvisorInfo(heading, msg, advistorType)
	info = AdvisorInfo.new()
end

--- Creates a listener function to the no. of building of a player
--- buildingClass: an integer indicating the building class type
---		see http://modiki.civfanatics.com/index.php?title=BuildingClassType_(Civ5_Type) for details
--- identifier: an unique string identifier for saving the status in database
--- count: an integer for the number of buildings required
--- msg: a string of message for the notification to be shown upon completion

function BuildingCountListenerFactory(buildingClass, identifier, count, heading, msg, onAdvisor)
	listener = 
		function()
			---local player = Players[i_TurnPlayer]
			local player = GetCurrentPlayer()
			if player == nil then
				return
			end
			local isNotified = GetPlayerProperty(i_TurnPlayer, identifier)
			local built = player:GetBuildingClassCount(buildingClass)
			print("Checking status for player " ..i_TurnPlayer .. " on " ..identifier)
			print("Built ".. built)
			if not isNotified and built >= count then
				print("Firing msg for "..identifier)
				if not onAdvisor then
					player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, msg, heading)
				else
					GenerateAdvisorPopUp(AdvisorTypes.ADVISOR_ECONOMIC, heading, msg, "OK")
				end
				SetPlayerProperty(i_TurnPlayer, identifier, true)
			end
		end
	return listener
end


--- Creates a listener function to the no. of units of a player
--- unitClass: an integer indicating the unit class
---		see http://modiki.civfanatics.com/index.php?title=UnitClassType_(Civ5_Type) for details

function UnitCountListenerFactory(untiClass, identifier, count, heading, msg, onAdvisor)
	listener = 
		function()
			---local player = Players[i_TurnPlayer]
			local player = GetCurrentPlayer()
			if player == nil then
				return
			end

			local isNotified = GetPlayerProperty(i_TurnPlayer, identifier)
			local built = player:GetUnitClassCount(untiClass)
			print("Checking status for player " ..i_TurnPlayer .. " on " ..identifier)
			print("Built ".. built)
			if not isNotified and built >= count then
				print("Firing msg for "..identifier)
				if not onAdvisor then
					player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, msg, heading)
				else
					GenerateAdvisorPopUp(AdvisorTypes.ADVISOR_ECONOMIC, heading, msg, "OK")
				end
				SetPlayerProperty(i_TurnPlayer, identifier, true)
			end
		end
	return listener
end