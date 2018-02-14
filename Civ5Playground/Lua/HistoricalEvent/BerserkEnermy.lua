g_last_checked_year = -1/0
--- {year:{id: event}}
g_event_queue = {}

include("../Utils.lua")
include("BerserkBarbarian.lua")


function TriggerHistoricalEvents()
	local current_year = Game.GetGameTurnYear()
	if g_last_checked_year >= current_year then
		return 
	end

	if not g_event_queue[current_year + 1] then
		g_event_queue[current_year + 1] = {}
	end

	for year, events in pairs(g_event_queue) do
		if year <= current_year then
			for i, event in ipairs(events) do
				local completed_id = event()
				if not completed_id then
					table.insert(g_event_queue[current_year + 1], event)
				else
					SetGlobalProperty("HISTEVENT_"..completed_id, true)
				end
			end
			g_event_queue[year] = nil
		end
	end 
	g_last_checked_year = current_year
end

function InitBersekBarbarianEvents()
	for row in GameInfo.EventBerserkEnermy() do

	end

end

function BerserkBarbarianEventConstructor()
end