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

Utils.GetCurrentTime = function()
	local date_table = os.date("*t")
	local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
	local hour, minute, second = date_table.hour, date_table.min, date_table.sec
	local year, month, day = date_table.year, date_table.month, date_table.day
	local result = string.format("%d-%d-%d %d:%d:%d", year, month, day, hour, minute, second)
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
	local totalDist = Game.rand(maxdist - mindist + 1, "Generate position offset (totalDist)") + mindist
	local dx = Game.rand(totalDist, "Generate position offset (dx)") + 1
	local dy = totalDist - dx

	if Game.rand(10, "Generate position offset (x direction)") < 5 then
		dx = -1*dx
	end
	if Game.rand(10, "Generate position offset (y direction)") < 5 then
		dy = -1*dy
	end

	return dx, dy
end

Utils.ToLuaCode = function (item, left)
	if type(item) == "nil" then return "nil" end
	if type(item) == "boolean" then return tostring(item) end
	if type(item) == "number" then return tostring(item) end
	if type(item) == "string" then return "'"..item.."'" end
	if type(item) ~= "table" then error("could not serialize an element of type "..type(item)) end
	
	local str = "{"
	for k, v in pairs(item) do
		 str = str  .."[".. Utils.ToLuaCode(k, true) .. "] = " .. Utils.ToLuaCode(v) .. ", "
	end
	return str.."}"
end

Utils.FromLuaCode = function (code)
	local func =  loadstring("return "..code)
	return func()
end

-- Given a full path, returns the Path, Filename, and Extension as 3 values
Utils.SplitPath = function(path)
	return path:match("(.-)([^\\/]-)%.([^\\/%.]+)$")
end

Utils.StrStartsWith = function(String, Start)
   return string.sub(String, 1, string.len(Start)) == Start
end

Utils.SetFirstTurnFinished = function()
	Utils.SetGlobalProperty("FIRST_TURN_OVER", true)
	return true
end

Utils.HandleFirstTurnNotificationAdded = function(notificationId, notificationType, toolTip, summary, gameValue, extraGameData)
	if Utils.GetGlobalProperty("FIRST_TURN_OVER") == nil then
		UI.RemoveNotification(notificationId)
	end
end


timeSpentLastUpdated = os.time()
if Utils.GetGlobalProperty("TOTAL_TIME_SPENT") == nil then
	Utils.SetGlobalProperty("TOTAL_TIME_SPENT", 0)
end

Utils.UpdateTotalTimeSpent = function()
	local curTime = os.time()
	local totalTime = Utils.GetGlobalProperty("TOTAL_TIME_SPENT") + os.difftime(curTime, timeSpentLastUpdated)
	Utils.SetGlobalProperty("TOTAL_TIME_SPENT", totalTime)
	timeSpentLastUpdated = curTime
	LuaEvents.OnUpdateTimeSpentItem()
end

Utils.GetTotalTimeSpent = function(table)
	table["value"] = Utils.GetGlobalProperty("TOTAL_TIME_SPENT")
end
LuaEvents.OnGetTotalTimeSpent.Add(Utils.GetTotalTimeSpent)
