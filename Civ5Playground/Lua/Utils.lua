-- Utils
-- Author: clark
-- DateCreated: 1/19/2018 7:00:40 PM
--------------------------------------------------------------
include("AdvisorManager.lua")

local i_TurnPlayer = -1
local g_SaveData = Modding.OpenSaveData("UGFN", 1)
local g_Properties = {}
local g_leader_player = {}

GameEvents.PlayerDoTurn.Add(
	function(iPlayer)
		i_TurnPlayer = iPlayer
	end
)

Utils = {}

--- Helper functions to help cache save data
--- such that unncessary save/load can be avoided
--- Example usage: check GetPlayerProperty and SetPlayerProperty
Utils.GetPersistentProperty = function(name)
    if not g_Properties[name] then
        g_Properties[name] = g_SaveData.GetValue(name)
    end
    return g_Properties[name]
end

Utils.SetPersistentProperty = function(name, value)
    if not(Utils.GetPersistentProperty(name) == value) then
		g_SaveData.SetValue(name, value)
		g_Properties[name] = value
	end
	return value
end

--- Retrieve and save customized attributes of a player to the save data (exclusive to this mod)
Utils.GetPlayerProperty = function(player_id, identifier)
	return Utils.GetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier)
end

Utils.SetPlayerProperty = function(player_id, identifier, value)
	Utils.SetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier, value)
end

--- Retrieve and save customized attributes of the game to the save data (exclusive to this mod)
Utils.GetGlobalProperty = function(identifier)
	return Utils.GetPersistentProperty("GLOBAL_" .. identifier)
end

Utils.SetGlobalProperty = function(identifier, value)
	Utils.SetPersistentProperty("GLOBAL_" .. identifier, value)
end


--- Retrieve the current active human player
--- Return nil if the current player is not a human
Utils.GetCurrentPlayer = function()
	local iPlayerID = Game.GetActivePlayer()
	if (iPlayerID < 0) then
		dprint("Error - player index not correct");
		return nil;
	end

	if (not Players[iPlayerID]:IsHuman()) then
		return nil;
	end

	return Players[iPlayerID]
end

Utils.GenerateCheckString = function()
	if not Utils.GetGlobalProperty("STARTTIME")  then
		Utils.SetGlobalProperty("STARTTIME", Utils.GetCurrentTime())
	end
end

Utils.PopDebugMsg = function()
	print("DEBUG MODE: "..GameDefines.UGFN_DEBUG_MODE)
	if GameDefines.UGFN_DEBUG_MODE == 1 then
		AdvisorManager.GenerateAdvisorPopUp(
			Game.GetActivePlayer(),
			AdvisorTypes.ADVISOR_MILITARY, 
			"Debug Messages",
			"Start time: "..Utils.GetGlobalProperty("STARTTIME").."[NEWLINE]"..
			"Year: "..Game.GetGameTurnYear()
		)
	end
	return false
end

Utils.GetCurrentTime = function()
	local date_table = os.date("*t")
	local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
	local hour, minute, second = date_table.hour, date_table.min, date_table.sec
	local year, month, day = date_table.year, date_table.month, date_table.day
	local result = string.format("%d-%d-%d %d:%d:%d:%s", year, month, day, hour, minute, second, ms)
	return result
end

Utils.GetPlayerByLeaderType = function(leaderTypeTxt)
	if #g_leader_player == 0 then
		for key, player in pairs(Players) do
			g_leader_player[player:GetLeaderType()] = player
		end
	end
	return g_leader_player[GameInfoTypes[leaderTypeTxt]]
end

Utils.AddFreeUnits = function(player, unitTypeID, locationX, locationY, nunit)
	local units = {}
	for i = 1, nunit do
		local unit = player:InitUnit(unitTypeID, locationX, locationY, UNITAI_DEFENSE,  DirectionTypes.DIRECTION_WEST)
		unit:JumpToNearestValidPlot()
		table.insert(units, unit)
	end
	return units
end

Utils.GeneratePositionOffset = function(mindist, maxdist)
	local totalDist = math.random(mindist, maxdist)
	local dx = math.random(mindist, totalDist)
	local dy = totalDist - dx

	if math.random() < 0.5 then
		dx = -1*dx
	end
	if math.random() < 0.5 then
		dy = -1*dy
	end

	return dx, dy
end