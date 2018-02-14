--- active_turn_start_listeners: 	{playerID:{listener_id: listener}}
--- default_turn_start_listeners: 	{listener_id: listener}

local active_turn_start_listeners = {}
local default_turn_start_listeners = {}

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

ListenerManager.AddTurnStartListeners = function (listener_id, listener)
	default_turn_start_listeners[listener_id] = listener
end

--[[
	This function should be registered to Events.ActivePlayerTurnStart.Add
--]]

ListenerManager.ExecuteTurnStartListeners = function()
	local iPlayerID = Game.GetActivePlayer()

	-- copy a set of listeners for the player on initialization
	if not active_turn_start_listeners[iPlayerID] then
		copy_table = {}
		for listener_id, listener in pairs(default_turn_start_listeners) do
			notified = Utils.GetPlayerProperty(iPlayerID, listener_id)
			if not notified then
				copy_table[listener_id] = listener
			end
		end

		active_turn_start_listeners[iPlayerID] = copy_table
	end

	-- trigger listeners
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