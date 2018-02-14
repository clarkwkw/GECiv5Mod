local g_advisorPopupQueue = {}

AdvisorManager = {}
--[[
	Generates an advisor popup and insert into the popup queue, the popups in the queue will be triggered sequentially
	You should NOT use Events.AdvisorDisplayShow directly, 
	because it is possible that 2 popups being triggered at the same time and only 1 will be shown
	
	advisor_type: int, which of the 4 types of advisors should be shown
 				e.g. 
 				AdvisorTypes.ADVISOR_MILITARY, 
 				AdvisorTypes.ADVISOR_ECONOMIC, 
 				AdvisorTypes.ADVISOR_FOREIGN, 
 				AdvisorTypes.ADVISOR_SCIENCE
--]]

AdvisorManager.GenerateAdvisorPopUp = function(player_id, advisor_type, title, body)
	local advisorEventInfo =
	{
		Advisor = advisor_type,
		TitleText = title,
		BodyText = body,
		ActivateButtonText = "",
		Concept1 = "",
		Concept2 = "",
		Concept3 = "",
		Modal = false;
	};
	if not g_advisorPopupQueue[player_id] then
		g_advisorPopupQueue[player_id] = {}
	end
	table.insert(g_advisorPopupQueue[player_id], advisorEventInfo)
end


--[[
	This function should be registered to Events.ActivePlayerTurnStart.Add and Events.AdvisorDisplayHide.Add
	When called, triggers the last popup in the queue and remove it from the queue
	
	Execution example:
	Assume there are 3 popups in the queue, namely A, B, C
	TriggerOnePopUp() (from Events.ActivePlayerTurnStart)
	-> Triggers and removes C from queue
	-> TriggerOnePopUp() (from Events.AdvisorDisplayHide)
	-> Triggers and removes B from queue
	-> TriggerOnePopUp() (from Events.AdvisorDisplayHide)
	-> Triggers and removes A from queue
	-> TriggerOnePopUp() (from Events.AdvisorDisplayHide)
	-> There is no more popup in the queue
--]]

AdvisorManager.TriggerOnePopUp = function()
	local player_id = Game.GetActivePlayer()
	if not g_advisorPopupQueue[player_id] then
		g_advisorPopupQueue[player_id] = {}
	end

	local queue = g_advisorPopupQueue[player_id]
	if #queue > 0 then
		Events.AdvisorDisplayShow(queue[#queue])
		table.remove(queue)
	end
	
end