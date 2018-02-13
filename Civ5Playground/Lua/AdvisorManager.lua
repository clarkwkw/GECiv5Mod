g_advisorPopupQueue = {}

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

function GenerateAdvisorPopUp(advisor_type, title, body)
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
	table.insert(g_advisorPopupQueue, advisorEventInfo)
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

function TriggerOnePopUp()
	if #g_advisorPopupQueue > 0 then
		print(g_advisorPopupQueue[#g_advisorPopupQueue].ActivateButtonText)
		Events.AdvisorDisplayShow(g_advisorPopupQueue[#g_advisorPopupQueue])
		table.remove(g_advisorPopupQueue)
	end
end