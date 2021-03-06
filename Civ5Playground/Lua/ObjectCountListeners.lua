-- ObjectCountListeners
-- Author: clark
-- DateCreated: 1/20/2018 9:12:22 AM
--------------------------------------------------------------


--- Creates a listener function to the no. of building of a player
--- buildingClass: an integer indicating the building class type
---		see http://modiki.civfanatics.com/index.php?title=BuildingClassType_(Civ5_Type) for details
--- count: an integer for the number of buildings required
--- msg: a string of message for the notification to be shown upon completion

function BuildingCountListenerFactory(buildingClass, count, heading, msg, onAdvisor)
	listener = 
		function()
			local player = Utils.GetCurrentPlayer()
			if player == nil then
				return
			end
			local built = player:GetBuildingClassCount(buildingClass)
			if built >= count then
				if not onAdvisor then
					player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, msg, heading)
				else
					AdvisorManager.GenerateAdvisorPopUp(Game.GetActivePlayer(), AdvisorTypes.ADVISOR_ECONOMIC, heading, msg)
				end
				return true
			end
			return false
		end
	return listener
end


--- Creates a listener function to the no. of units of a player
--- unitClass: an integer indicating the unit class
---		see http://modiki.civfanatics.com/index.php?title=UnitClassType_(Civ5_Type) for details

function UnitCountListenerFactory(unitClass, count, heading, msg, onAdvisor)
	listener = 
		function()
			local player = Utils.GetCurrentPlayer()
			if player == nil then
				return
			end
			local built = player:GetUnitClassCount(unitClass)
			if built >= count then
				if not onAdvisor then
					player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, msg, heading)
				else
					AdvisorManager.GenerateAdvisorPopUp(Game.GetActivePlayer(), AdvisorTypes.ADVISOR_ECONOMIC, heading, msg)
				end
				return true
			end
			return false
		end
	return listener
end

function TechnologyResearchedListenerFactory(techType, heading, msg, onAdvisor)
	listener = function()
		local player = Utils.GetCurrentPlayer()
		if player == nil then
			return
		end
		local researched = Teams[player:GetTeam()]:IsHasTech(techType)
		if researched then
			if not onAdvisor then
				player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, msg, heading)
			else
				AdvisorManager.GenerateAdvisorPopUp(Game.GetActivePlayer(), AdvisorTypes.ADVISOR_ECONOMIC, heading, msg)
			end
			return true
		end
		return false
	end
	return listener
end

function ProjectCompletedListenerFactory(projectType, heading, msg, onAdvisor)
	listener = function()
		local player = Utils.GetCurrentPlayer()
		if player == nil then
			return
		end
		local count = Teams[player:GetTeam()]:GetProjectCount(projectType)
		if count > 0 then
			if not onAdvisor then
				player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, msg, heading)
			else
				AdvisorManager.GenerateAdvisorPopUp(Game.GetActivePlayer(), AdvisorTypes.ADVISOR_ECONOMIC, heading, msg)
			end
			return true
		end
		return false
	end
	return listener
end