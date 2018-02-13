-- Utils
-- Author: clark
-- DateCreated: 1/19/2018 7:00:40 PM
--------------------------------------------------------------
include("AdvisorManager.lua")

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

--- Retrieve and save customized attributes of a player to the save data (exclusive to this mod)
function GetPlayerProperty(player_id, identifier)
	return GetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier)
end

function SetPlayerProperty(player_id, identifier, value)
	SetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier, value)
end

--- Retrieve and save customized attributes of the game to the save data (exclusive to this mod)
function GetGlobalProperty(identifier)
	return GetPersistentProperty("GLOBAL_" .. identifier)
end

function SetGlobalProperty(identifier, value)
	SetPersistentProperty("GLOBAL_" .. identifier, value)
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

function GenerateCheckString()
	if not GetGlobalProperty("STARTTIME")  then
		SetGlobalProperty("STARTTIME", GetCurrentTime())
	end
end

function PopDebugMsg()
	print("DEBUG MODE: "..GameDefines.UGFN_DEBUG_MODE)
	if GameDefines.UGFN_DEBUG_MODE == 1 then
		GenerateAdvisorPopUp(
			AdvisorTypes.ADVISOR_MILITARY, 
			"Debug Messages",
			"Start time: "..GetGlobalProperty("STARTTIME")
		)
	end
	return false
end

function GetCurrentTime()
	local date_table = os.date("*t")
	local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
	local hour, minute, second = date_table.hour, date_table.min, date_table.sec
	local year, month, day = date_table.year, date_table.month, date_table.wday
	local result = string.format("%d-%d-%d %d:%d:%d:%s", year, month, day, hour, minute, second, ms)
	return result
end