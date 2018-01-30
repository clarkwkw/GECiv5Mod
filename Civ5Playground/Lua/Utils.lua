-- Utils
-- Author: clark
-- DateCreated: 1/19/2018 7:00:40 PM
--------------------------------------------------------------
i_TurnPlayer = -1
g_SaveData = Modding.OpenSaveData("UGFN", 1)
g_Properties = {}

GameEvents.PlayerDoTurn.Add(
	function(iPlayer)
		i_TurnPlayer = iPlayer
	end
)


--- Helper functions to help cache save data
--- such that unncessary save/load can be avoided
--- Example usage: check GetPlayerProperty and SetPlayerProperty
function GetPersistentProperty(name)
    if not g_Properties[name] then
        g_Properties[name] = g_SaveData.GetValue(name)
    end
    return g_Properties[name]
end

function SetPersistentProperty(name, value)
    if not(GetPersistentProperty(name) == value) then
		g_SaveData.SetValue(name, value)
		g_Properties[name] = value
	end
	return value
end



--- Retrieve and save customized attributes to the save data (exclusive to this mod)
function GetPlayerProperty(player_id, identifier)
	return GetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier)
end

function SetPlayerProperty(player_id, identifier, value)
	SetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier, value)
end



--- Retrieve the current active human player
--- Return nil if the current player is not a human
function GetCurrentPlayer()
	local iPlayerID = Game.GetActivePlayer();
	if (iPlayerID < 0) then
		dprint("Error - player index not correct");
		return nil;
	end

	if (not Players[iPlayerID]:IsHuman()) then
		return nil;
	end

	return Players[iPlayerID];
end

--[[
	advisor_type: int, which of the 4 types of advisors should be shown
 				e.g. AdvisorTypes.NO_ADVISOR_TYPE
 				AdvisorTypes.ADVISOR_MILITARY, 
 				AdvisorTypes.ADVISOR_ECONOMIC, 
 				AdvisorTypes.ADVISOR_FOREIGN, 
 				AdvisorTypes.ADVISOR_SCIENCE
--]]
function GenerateAdvisorPopUp(advisor_type, title, body)
	local advisorEventInfo =
	{
		Advisor = advisor_type,
		TitleText = title,
		BodyText = body,
		---ActivateButtonText = buttonText,
		
		---Concept1 = "CONCEPT_UNITS",
		---Concept2 = tutorial.Concept2,
		---Concept3 = tutorial.Concept3,
		Modal = false;
	};
	Events.AdvisorDisplayShow(advisorEventInfo)
end