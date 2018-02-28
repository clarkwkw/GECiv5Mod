--- active_turn_start_listeners: 	{playerID:{listener_id: listener}}
--- default_turn_start_listeners: 	{listener_id: listener}

local active_turn_start_listeners = {}
local individual_turn_start_listeners = {}
local global_turn_start_listeners = {}
local last_executed = Utils.GetGlobalProperty("ListenerManagerLastExecuted") or -1000000

ListenerManager = {}
--[[
	The listener manager maintains the state of each listener for each player,
	and triggers each listener at the start of a turn.
	If a listener returns a logical true, the manager deregisters the listener,
	and will ensure the listener would not be registered again.
--]]

--[[
	Adds the listener to the listener manager
	listener_id: a unique identifier for the listener
	listener: a function to be executed in the beginning of each turn, 
			should return true if the listener function no longer needs to be triggered for the player
--]]

ListenerManager.AddIndividualTurnStartListener = function (listener_id, listener)
	individual_turn_start_listeners[listener_id] = listener
end

ListenerManager.AddGlobalTurnStartListener = function (listener_id, listener)
	if not Utils.GetGlobalProperty("ListenerGlobal_"..listener_id) then
		global_turn_start_listeners[listener_id] = listener
	end
end

--[[
	This function should be registered to Events.ActivePlayerTurnStart.Add
--]]

ListenerManager.ExecuteTurnStartListeners = function()
	local iPlayerID = Game.GetActivePlayer()
	local curYear = Game.GetGameTurnYear()

	-- copy a set of listeners for the player on initialization
	if not active_turn_start_listeners[iPlayerID] then
		copy_table = {}
		for listener_id, listener in pairs(individual_turn_start_listeners) do
			notified = Utils.GetPlayerProperty(iPlayerID, listener_id)
			if not notified then
				copy_table[listener_id] = listener
			end
		end

		active_turn_start_listeners[iPlayerID] = copy_table
	end

	if curYear > last_executed then
		last_executed = curYear
		Utils.SetGlobalProperty("ListenerManagerLastExecuted", curYear)
		for listener_id, listener in pairs(global_turn_start_listeners) do
			print("Triggering global listener "..listener_id)
			result = listener()
			if result then
				print("Deregistering "..listener_id.." global listener"..iPlayerID)
				global_turn_start_listeners[listener_id] = nil
				Utils.SetGlobalProperty("ListenerGlobal_"..listener_id, true)
			end
		end
	end

	-- trigger indiviudal listeners
	for listener_id, listener in pairs(active_turn_start_listeners[iPlayerID]) do
		print("Triggering listener for player " ..iPlayerID .. " on " ..listener_id)
		result = listener()
		if result then
			print("Deregistering "..listener_id.." listener for player "..iPlayerID)
			active_turn_start_listeners[iPlayerID][listener_id] = nil
			Utils.SetPlayerProperty(iPlayerID, listener_id, true)
		end
	end

end