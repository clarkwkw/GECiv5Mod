include( "FLuaVector" );

--[[
Tutorial Structure
All tutorials are simple tables with pre-defined fields.
The fields are described as follows.

*Required Fields*
ID					-- A Unique string identifier for the tutorial

*UI Fields -- Controls how the advisor will look*
ActivateButtonText	-- Whether or not the activate button has custom text.
Advisor				-- The advisor to use.
Concept1			-- An additional concept entry, displayed under advisor text.
Concept2			-- An additional concept entry, displayed under advisor text. (Concept1 must already be defined.)
Concept3			-- An additional concept entry, displayed under advisor text. (Cocnept2 must already be defined.)
UnitIndexFunction	-- A function which returns a unit ID.  When this function is active a new button is shown allowing the user to navigate to the unit.
PlotFunction		-- A function which returns a plot ID.  When this function is active a new button is shown allowing the user to navigate to the plot.

*Test Fields -- Fields that control how the tutorial is activated
CheckFunction		-- A function which returns the status of the tutorial (primarilly used in periodic checks)
ButtonPopupType		-- Activates the tutorial if the following popup is displayed.
NotificationType	-- Activates the tutorial if the following notification is displayed.

*Pre check Fields - Controls when to test tutorial*
These fields determine when and how a check function is called.
MinTurnTime		-- The min elapsed time (in seconds a tutorial is allowed to trigger.
MaxTurnTime		-- The max elapsed time (in seconds) a tutorial is allowed trigger.
MinTurn			-- The min turn a tutorial is allowed to trigger.
MaxTurn			-- The max turn a tutorial is allowed to trigger.
PesterAgainTurn	-- A duration a turns that must pass before the tutorial may trigger again.
PesterAgainTime -- A duration of time (in seconds) that must pass before the tutorial may trigger again.
TurnsCheck		-- A duration of turns to test if a tutorial is active.
TurnTimeCheck	-- The interval (in seconds) during a turn to test if a tutorial is active.
TutorialLevel   -- The level of the tutorial (0 == Noobie, 1 = New To Civ5, 2 = New To Civ5GK, 3 = Experienced User)

*Post check Fields*
These fields are only used AFTER a check function has been successful.
MaxInQueue		-- If There are "MaxInQueue" tutorials already queued up, fail the conditional check and test later.
MinInQueue		-- There must be "MinInQueue" tutorials already queued up for the condition to pass.
--]]


-- Global Constants
local COMPLETE  = 0; -- Successfully completed this task
local DISMISSED = 1; -- Tutorial display was seen and dismissed by player
local INVALID   = 2; -- Missed the boat on this task
local ACTIVE    = 3; -- This task can be evaluated
local INACTIVE  = 4; -- This task cannot currently be evaluated

-- notification message types
local ACTIVATE_ACTION_DO_NOTHING	 = -1;
local ACTIVATE_ACTION_SELECT_UNIT    =  0;
local ACTIVATE_ACTION_SCROLL_TO_PLOT =  1;
local ACTIVATE_ACTION_OPEN_POPUP	 =  2;

-- Global Variables 
g_PeriodicTutorials = {};		-- Tutorials that rely on periodic checks. (array)
g_PopupTutorials = {};			-- Tutorials that rely on popup events.	(indexed by PopupType)
g_NotificationTutorials = {};	-- Tutorials that rely on notification events. (indexed by notification Type)
g_TutorialStatus = {};			-- Status of tutorials (indexed by tutorial).
g_ActiveTutorialQueue = {};		-- Queue of active tutorials.

g_ActiveTutorialsByNotificationId = {};	-- List of active notification-based tutorials.

g_LastTurnChecked = {};			-- Last turn a tutorial was checked. (Indexed by tutorial)
g_LastTurnTimeChecked = {};		-- Last turn time a tutorial was checked. (Indexed by tutorial) (Empties on new turn)	

g_LastQueueTurn = {}			-- Last turn a tutorial was queued. (Indexed by tutorial)
g_LastQueueTime = {}			-- Last time a tutorial was queued. (Indexed by tutorial)

g_TutorialsPerTick = 5;
g_CurrentGameTurn = -1;
g_TotalTime = 0;
g_TurnTime = 0;

function FilterInPlace(t, predicate) 
	local j = 1;

	for i, v in ipairs(t) do 
		if (predicate(v)) then 
			t[j] = v; 
			j = j + 1; 
		end 
	end 

	while t[j] ~= nil do 
		t[j] = nil 
		j = j + 1 
	end 
end 

--Check whether the tutorial is queable (due to time/turn constraints);
function CanQueueTutorial(tutorial)

	local gameTutorialLevel = Game.GetTutorialLevel();
	
	-- If the static tutorial is running, set tutorial level to lowest possible value.
	if(Game.IsStaticTutorialActive()) then
		gameTutorialLevel = 0;
	end
	
	local minTurnTime = tutorial.MinTurnTime or -1;
	local maxTurnTime = tutorial.MaxTurnTime or math.huge;
	
	local minTotalTime = tutorial.MinTotalTime or -1;
	local maxTotalTime = tutorial.MaxTotalTime or math.huge;
	
	local minTurn = tutorial.MinTurn or -1;
	local maxTurn = tutorial.MaxTurn or math.huge;

	local pesterAgainTurn = tutorial.PesterAgainTurn;
	local pesterAgainTime = tutorial.PesterAgainTime;
	
	if(pesterAgainTurn ~= nil and pesterAgainTurn < 0) then
		pesterAgainTurn = nil;
	end
		
	if(pesterAgainTime ~= nil and pesterAgainTime < 0) then
		pesterAgainTime = nil;	
	end	
	
	local lastPesterTurn = g_LastQueueTurn[tutorial];
	local lastPesterTime = g_LastQueueTime[tutorial];
	
	local nextTurnCheck = g_CurrentGameTurn;
	local turnsCheck = tutorial.TurnsCheck;
	if(turnsCheck ~= nil and turnsCheck >= 0) then
		local lastTurnChecked = g_LastTurnChecked[tutorial];
		if(lastTurnChecked ~= nil) then
			nextTurnCheck = lastTurnChecked + turnsCheck;
		end
	end
	
	local nextTurnTimeCheck = g_TurnTime;
	local turnTimeCheck = tutorial.TurnTimeCheck;
	if(turnTimeCheck ~= nil and turnTimeCheck >= 0) then
		local lastTurnTimeChecked = g_LastTurnTimeChecked[tutorial];
		if(lastTurnTimeChecked ~= nil) then
			nextTurnTimeCheck = lastTurnTimeChecked + turnTimeCheck;
		end
	end
	
	-- Determine next turn and time this tutorial will be valid.
	if(pesterAgainTurn ~= nil and lastPesterTurn ~= nil) then
		minTurn = math.max(minTurn, lastPesterTurn + pesterAgainTurn);
	end
	
	if(pesterAgainTime ~= nil and lastPesterTime ~= nil) then
		minTime = math.max(minTime, lastPesterTime + pesterAgainTime);
	end
	
	local tutorialLevel = tutorial.TutorialLevel or math.huge;
	
	if(	tutorialLevel >= gameTutorialLevel and
		g_CurrentGameTurn >= nextTurnCheck and
		g_TurnTime >= nextTurnTimeCheck and
		g_CurrentGameTurn >= minTurn and
		g_CurrentGameTurn <= maxTurn and
		g_TurnTime >= minTurnTime and
		g_TurnTime <= maxTurnTime and
		g_TotalTime >= minTotalTime and
		g_TotalTime <= maxTotalTime) then 
	   
		--Fail if tutorial is already queued
		for i,v in ipairs(g_ActiveTutorialQueue) do
			if(v.Tutorial == tutorial) then
				return false;
			end
		end
		
		return true;
	end
	
	return false;
end

function QueueTutorial(tutorial, highPriority)

	if (Game.GetTutorialLevel() < 0 and not Game.IsStaticTutorialActive()) then
		return;
	end

	if (Game.IsPaused()) then
		return;
	end

	local player = GetPlayer();
	if (player == nil) then
		return;
	end
	
	local status = g_TutorialStatus[tutorial];
	if(status ~= INACTIVE) then
		return;
	end
	
	--print("Queue Tutorial - " .. tutorial.ID);

	-- This will affect queue processing but not tutorial triggering.
	--if (UI.IsPopupUp()) then
		--return;
	--end

	-- This will affect queue processing but not tutorial triggering.
	--if (not player:IsTurnActive() or player:HasBusyUnit() or player:HasBusyMovingUnit()) then
		--return;
	--end

	-- Checks to see if we're out of tutorial nodes 
	--if (IsTutorialOver()) then
		--return;
	--end
	
	if(tutorial.CanActivate == nil or tutorial.CanActivate()) then
		local activateButtonAction = ACTIVATE_ACTION_DO_NOTHING;
		local data1 = -1;
		local data2 = -1;

		if (tutorial.UnitIndexFunction) then
			local playerID = Game.GetActivePlayer();
			local unitID   = tutorial.UnitIndexFunction();

			activateButtonAction = ACTIVATE_ACTION_SELECT_UNIT;
			data1 = playerID;
			data2 = unitID;
		elseif (tutorial.PlotFunction) then				
			local plot = tutorial.PlotFunction();
			if (plot) then
				activateButtonAction = ACTIVATE_ACTION_SCROLL_TO_PLOT;
				data1 = plot:GetX();
				data2 = plot:GetY();					
			end
		elseif(tutorial.ActivateButtonPopupType) then
			activateButtonAction = ACTIVATE_ACTION_OPEN_POPUP;
			data1 = tutorial.ActivateButtonPopupType;
		end
		
		g_LastQueueTurn[tutorial] = g_CurrentGameTurn;
		g_LastQueueTime[tutorial] = g_TotalTime;
		
		if(highPriority == true) then
			table.insert(g_ActiveTutorialQueue, 1, {
				Tutorial = tutorial,
				ActivateButtonAction = activateButtonAction,
				ActivateButtonData1 = data1,
				ActivateButtonData2 = data2,
			});		
		else
			table.insert(g_ActiveTutorialQueue, {
				Tutorial = tutorial,
				ActivateButtonAction = activateButtonAction,
				ActivateButtonData1 = data1,
				ActivateButtonData2 = data2,
			});		
		end
		
	end
end

function DismissActiveTutorial(tutorial)
	local currentActiveTutorial = g_ActiveTutorialQueue[1];
	if(currentActiveTutorial ~= nil and currentActiveTutorial.Tutorial == tutorial) then
		-- Tell Advisor system to dismiss!
		Events.AdvisorDisplayHide();
	end
	
	-- Remove the tutorial from the queue if it exists.
	FilterInPlace(g_ActiveTutorialQueue, function(v) return v.Tutorial ~= tutorial; end);	
end

---------------------------------------------------------------------------------
-- Event Handling
---------------------------------------------------------------------------------
function HandleAppUpdate(tickCount, timeIncrement)

	-- If game is paused, don't check for tutorials or even update the timers.
	if (Game.IsPaused() or IsGameCoreBusy()) then
		return;
	end
	
	if (IsScenarioComplete and DoScenarioComplete and IsScenarioComplete()) then
		DoScenarioComplete();
		return;
	end
		
	g_TotalTime = g_TotalTime + timeIncrement;
	g_TurnTime = g_TurnTime + timeIncrement;
	
	local TurnPassed = false;
	
	local gameTurn = Game.GetGameTurn();
	if (g_CurrentGameTurn ~= gameTurn) then
		g_CurrentGameTurn = gameTurn;
		TurnPassed = true;
		g_TurnTime = 0;
		g_LastTurnTimeChecked = {};
		
	end
			
	-- Build batch of available tutorials.
	local tutorialsToCheck = {};
	for i,v in ipairs(g_PeriodicTutorials) do
		if(CanQueueTutorial(v)) then
			table.insert(tutorialsToCheck, v);
		end
	end
	
	local bQueueWasEmpty = #g_ActiveTutorialQueue == 0;
	
	local bNeedsRefresh = false;
	local bProcessQueue = false;
	
	--print("Checking " .. tostring(#tutorialsToCheck) .. " tutorials.");
	for i,v in ipairs(tutorialsToCheck) do
		
		local tutorial = v;
		local oldStatus = g_TutorialStatus[tutorial];
		
		--local timer = Profiler.BeginTiming("Check Tutorial - " .. tutorial.ID);
		local checkFunction = tutorial.CheckFunction;
		local status = checkFunction and checkFunction() or INACTIVE;
		--timer.Stop();
		
		g_LastTurnChecked[tutorial] = g_CurrentGameTurn;
		g_LastTurnTimeChecked[tutorial] = g_TurnTime;
		
		if(status ~= oldStatus) then
		
			local queueCount = #g_ActiveTutorialQueue;
			local maxInQueue = tutorial.MaxInQueue or math.huge;
			local minInQueue = tutorial.MinInQueue or 0;
	
			--Only process if the post check conditions are satisfied.
			if(maxInQueue >= queueCount  and minInQueue <= queueCount ) then
				if(status == ACTIVE) then			
					QueueTutorial(tutorial);
					bProcessQueue = true;
				end
				
				g_TutorialStatus[tutorial] = status;
				bNeedsRefresh = true;
			end
		end
	end
		
	if(bNeedsRefresh) then 
		-- Refresh the list since completed, invalid, or dismissed tutorials could be filtered.
		-- print("Refreshing and Reindexing");
		RefreshStatusAndReIndexTutorials(TutorialInfo);
	end
	
	if(bProcessQueue and bQueueWasEmpty) then
		-- print("ProcessQ");
		ProcessActiveTutorialQueue();
	end	
	
	--loopTimer.Stop();
end
--------------------------------------------------------------------
function HandlePopupShown(popupInfo)
	--print("POPUP SHOWN");
	--print(popupInfo.Type);
	
	if(g_PopupTutorials ~= nil) then
		local popupTutorials = g_PopupTutorials[popupInfo.Type];
		if(popupTutorials ~= nil) then
			for i,v in ipairs(popupTutorials) do
				if(CanQueueTutorial(v)) then
					local checkFunction = v.CheckFunction;
					local status = checkFunction and checkFunction() or ACTIVE;
					if(status == ACTIVE) then
						QueueTutorial(v, true);
						ProcessActiveTutorialQueue();
					end
				end				
			end	
		end
	end
end
--------------------------------------------------------------------
function HandlePopupProcessed(popupInfoType)
	--print("POPUP PROCESSED");
	--print(popupInfoType);
	if(g_PopupTutorials ~= nil) then
		local popupTutorials = g_PopupTutorials[popupInfoType];
		if(popupTutorials ~= nil) then
			for i,v in ipairs(popupTutorials) do
				DismissActiveTutorial(v);
			end	
		end
	end
end
--------------------------------------------------------------------
function HandleNotificationAdded(notificationId, notificationType, toolTip, summary, gameValue, extraGameData)
	--print("NOTIFICATION ADDED");
	--print(notificationId);
	--print(notificationType);
	
	if(g_NotificationTutorials ~= nil) then
		local notificationTutorials = g_NotificationTutorials[notificationType];
		if(notificationTutorials ~= nil) then
			for i,v in ipairs(notificationTutorials) do
				if(CanQueueTutorial(v)) then
					
					-- Added to indexed list
					if(g_ActiveTutorialsByNotificationId[notificationId] == nil) then
						g_ActiveTutorialsByNotificationId[notificationId] = {};
					end
					table.insert(g_ActiveTutorialsByNotificationId[notificationId], v);
					
					QueueTutorial(v, true);
					ProcessActiveTutorialQueue();
				end
			end	
		end
	end
end
--------------------------------------------------------------------
function HandleNotificationRemoved(notificationId)
	--print("NOTIFICATION REMOVED");
	--print(notificationId);
	local tutorials = g_ActiveTutorialsByNotificationId[notificationId];
	if(tutorials ~= nil) then
		for i,tutorial in ipairs(tutorials) do
			DismissActiveTutorial(tutorial);
		end
	end
	
	g_ActiveTutorialsByNotificationId[notificationId] = nil;
end
--------------------------------------------------------------------
function HandleAdvisorUIHide()
	if MapModData.UGFNAdvisorWorking then
		return;
	end
	
	-- Pop an item from the active tutorial Q
	local tutorial = g_ActiveTutorialQueue[1];
	if(tutorial ~= nil) then
		g_TutorialStatus[tutorial.Tutorial] = INACTIVE; 
	end
	
	table.remove(g_ActiveTutorialQueue, 1);
	
	-- The advisor window has been hidden, update the status of advisor messages!
	RefreshStatusAndReIndexTutorials(TutorialInfo);
	
	ProcessActiveTutorialQueue();
end

------------------------------------------------------------
function ActivatedPopup(popupInfo)
	if (popupInfo.Type ~= 99997) then
		return;
	end
		
	local e = g_ActiveTutorialQueue[1];
	if(e == nil or e.ActivateButtonAction == ACTIVATE_ACTION_DO_NOTHING) then
		return;
	end
	
	if (e.ActivateButtonAction == ACTIVATE_ACTION_SELECT_UNIT) then
		local iPlayer = e.ActivateButtonData1;
		local iUnit   = e.ActivateButtonData2;
		
		local player = Players[iPlayer];	
		local unit = nil;
		if (player ~= nil) then
			if (iUnit >= 0) then
				unit = player:GetUnitByID(iUnit);
			end		
		end

		if (unit ~= nil) then
			UI.SelectUnit(unit);
			UI.LookAt(unit:GetPlot(), 0);
			local plot = unit:GetPlot();
			if (plot) then
				local hex = ToHexFromGrid( Vector2(plot:GetX(), plot:GetY() ) );
				Events.GameplayFX(hex.x, hex.y, -1);			
			end
		end
		
	elseif (e.ActivateButtonAction == ACTIVATE_ACTION_SCROLL_TO_PLOT) then
		local iX = e.ActivateButtonData1;
		local iY = e.ActivateButtonData2;
		
		local pPlot = Map.GetPlot(iX, iY);
		if (pPlot) then
			UI.LookAt(pPlot, 0);
			
			local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()));
			Events.GameplayFX(hex.x, hex.y, -1);		
		end

	elseif(e.ActivateButtonAction == ACTIVATE_ACTION_OPEN_POPUP) then
			local popupInfo = {
				Type = e.ActivateButtonData1,
				Data1 = -1,
				Data2 = -1,
				Data3 = -1,
				Option1 = false,
				Option2 = false;
			}
		Events.SerialEventGameMessagePopup(popupInfo);
	end
end

function ProcessActiveTutorialQueue()
	if MapModData.UGFNAdvisorWorking then
		return;
	end

	local v = g_ActiveTutorialQueue[1];
	if(v == nil) then
		return;
	end
	
	local tutorial = v.Tutorial;
	
	local strPrefix = "TXT_KEY_ADVISOR_" .. tutorial.ID;
	local strActivateButtonText = "";
	if (tutorial.ActivateButtonText) then
		strActivateButtonText = Locale.Lookup(strPrefix .. "_ACTIVATE_BUTTON");				
	end
	
	local AdvisorDisplayShowData =
	{
		IDName = tutorial.ID,
		Advisor = tutorial.Advisor,
		TitleText = tutorial.TitleText and tutorial.TitleText or (strPrefix .. "_DISPLAY"),
		BodyText = tutorial.BodyText and tutorial.BodyText or (strPrefix .. "_BODY"),
		ActivateButtonText = strActivateButtonText,
		
		Concept1 = tutorial.Concept1,
		Concept2 = tutorial.Concept2,
		Concept3 = tutorial.Concept3,
		Modal = tutorial.Modal or false;
	};
	
	--print("Showing Tutorial - " .. tutorial.ID);
	Events.AdvisorDisplayShow(AdvisorDisplayShowData);

end
---------------------------------------------------------------------------------
-- Initialization Routines
---------------------------------------------------------------------------------
-- Should the tutorial system be enabled?
function TutorialSystemEverEnabled()
	if (Game.GetTutorialLevel() < 0 and not Game.IsStaticTutorialActive()) then
		return false;
	end

	if (Game.IsGameMultiPlayer() or Game.IsHotSeat()) then
		return false;
	end
	
	if (Game.IsOption("GAMEOPTION_NO_TUTORIAL")) then
		return false;
	end
	
	return true;
end
--------------------------------------------------------------------
-- Given a set of tutorials, returns separate sets of tutorials
-- Indexed by Turn-based, Periodic, Popup, and Notification based tutorials.
-- NOTE: Turn-based and Periodic may include the same tutorials.
function IndexTutorials(tutorials)
	
	local popupTutorials = {};
	local notificationTutorials = {};
	local periodicTutorials = {};
	
	for i,v in ipairs(tutorials) do
	
		local status = g_TutorialStatus[v];
		if(status == INACTIVE) then
		
			if(v.ButtonPopupType ~= nil) then
			
				local popupType = v.ButtonPopupType;
				if(popupTutorials[popupType] == nil) then
					popupTutorials[popupType] = {};
				end
				
				table.insert(popupTutorials[popupType], v);
			end
			
			if(v.NotificationType ~= nil) then
				local notificationType = v.NotificationType;
				if(notificationTutorials[notificationType] == nil) then
					notificationTutorials[notificationType] = {};
				end
				
				table.insert(notificationTutorials[notificationType], v);
			end
			
			if(v.ButtonPopupType == nil and v.NotificationType == nil) then
				table.insert(periodicTutorials, v);
			end
			
			end
		end
	
	return periodicTutorials, popupTutorials, notificationTutorials;
end

--------------------------------------------------------------------
function RefreshStatusAndReIndexTutorials(tutorials)

	-- Initialize the status of tutorials.
	local gameHasAdvisorMessageBeenSeen = Game.HasAdvisorMessageBeenSeen;
	local uiHasAdvisorMessageBeenSeen = UI.HasAdvisorMessageBeenSeen;
	
	for i,v in ipairs(tutorials) do
		
		local tutorialID = v.ID;
		
		local isPester = (v.PesterAgainTurn ~= nil and v.PesterAgainTurn >= 0) or (v.PesterAgainTime ~= nil and v.PesterAgainTime >= 0);
		
		if ( (gameHasAdvisorMessageBeenSeen(tutorialID) and not isPester) or uiHasAdvisorMessageBeenSeen(tutorialID)) then
			g_TutorialStatus[v] = COMPLETE;
		end
	
		if(g_TutorialStatus[v] == nil) then
			g_TutorialStatus[v] = INACTIVE;
		end
	end
	
	-- Remove completed tutorials from the queue.
	local statusesToFilter = {
		[COMPLETE] = true,
		[INVALID] = true,
		[DISMISSED] = true
	};
	
	FilterInPlace(g_ActiveTutorialQueue, function(v) 
		local status = g_TutorialStatus[v.Tutorial];
		return statusesToFilter[status] ~= true;
	end);

	-- Split up tutorials by their type (this will also filter out INVALID and COMPLETE tutorials).
	g_PeriodicTutorials, g_PopupTutorials, g_NotificationTutorials = IndexTutorials(TutorialInfo);

end
--------------------------------------------------------------------
function InitializeTutorialSystem()
    -- This is a hack until we can place units with the world builder
	if(TutorialSetup ~= nil) then
		TutorialSetup();
	end

	RefreshStatusAndReIndexTutorials(TutorialInfo);
		
	-- Update Events.
	Events.SequenceGameInitComplete.Remove(InitializeTutorialSystem); -- only call this once
	
	Events.LocalMachineAppUpdate.Add(HandleAppUpdate);
	
	Events.SerialEventGameMessagePopupShown.Add(HandlePopupShown);
	Events.SerialEventGameMessagePopupProcessed.Add(HandlePopupProcessed);
	
	Events.NotificationAdded.Add(HandleNotificationAdded);
	Events.NotificationRemoved.Add(HandleNotificationRemoved);
	
	Events.AdvisorDisplayHide.Add(HandleAdvisorUIHide);
	
	Events.SerialEventGameMessagePopup.Add(ActivatedPopup);
end
--------------------------------------------------------------------
-- Initialization
if(TutorialSystemEverEnabled()) then
	Events.SequenceGameInitComplete.Add(InitializeTutorialSystem)

	LuaEvents.TryQueueTutorial.Add(function(tutorialID, highPriority) 
		--print("Trying to queue a tutorial");
		for i,v in ipairs(TutorialInfo) do
			if(v.ID == tutorialID) then
				if(CanQueueTutorial(v)) then
					if(highPriority ~= nil) then
						QueueTutorial(v);
						ProcessActiveTutorialQueue();
					else
						local bWasEmpty = #g_ActiveTutorialQueue == 0;
						
						QueueTutorial(v);
						if(bWasEmpty) then
							ProcessActiveTutorialQueue();
						end
					end				
				end
				break;
			end
		end
	end);
	
	LuaEvents.TryDismissTutorial.Add(function(tutorialID)
		--print("Trying to dismiss a tutorial");
		for i,v in ipairs(TutorialInfo) do
			if(v.ID == tutorialID) then
				DismissActiveTutorial(tutorial);
				break;
			end
		end
	end);
end


