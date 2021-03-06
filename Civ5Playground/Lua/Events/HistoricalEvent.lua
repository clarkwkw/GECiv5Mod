---include("BerserkEnermy.lua")

HistoricalEventManager  = {}
HistoricalEvent = {}
local lastInvoked = Utils.GetGlobalProperty("HistoricalEventManagerLastInvoked") or -999999
local currentYear = -999999
local eventQueue = {}

HistoricalEventManager.InitEvents = function()
	local eventInfo = {}
	local eventAllLeaders = {}

	for row in GameInfo.EventHistorical() do
		print("Adding event "..row.EventID)
		if not Utils.GetGlobalProperty("HISTEVENT_"..row.EventID) then
			eventInfo[row.EventID] = {}
			for key, value in pairs(row) do
				eventInfo[row.EventID][key] = value
			end
			eventInfo[row.EventID]["Leaders"] = {}
			eventInfo[row.EventID]["Compensation"] = {}
		end
	end

	for row in GameInfo.EventHistoricalLeaders() do
		print("Adding leader "..row.LeaderType.." to "..row.EventID)
		if eventInfo[row.EventID] ~= nil and eventAllLeaders[row.EventID] == nil then
			if row.LeaderType:lower() ~= "all" and row.LeaderType:lower() ~= "allhuman" then
				table.insert(eventInfo[row.EventID]["Leaders"], row.LeaderType)
			else
				eventInfo[row.EventID]["Leaders"] =  row.LeaderType:lower()
				eventAllLeaders[row.EventID] = true
			end
		end
	end

	for row in GameInfo.EventHistoricalCompensation() do
		if eventInfo[row.EventID] ~= nil then
			print("Adding compensation "..row.UnitTypeID.."("..row.Count..") to event "..row.EventID)
			eventInfo[row.EventID]["Compensation"][row.UnitTypeID] = row.Count
		end
	end

	for key, event in pairs(eventInfo) do
		table.insert(eventQueue, HistoricalEvent:New(event))
	end
end

HistoricalEventManager.AddToQueue = function(event)
	table.insert(eventQueue, event)
end

HistoricalEventManager.GetCurrentYear = function()
	return currentYear
end


HistoricalEventManager.TriggerEvents = function()
	local newQueue = {}
	currentYear = Game.GetGameTurnYear()
	if lastInvoked < currentYear then
		currentYear = Game.GetGameTurnYear()
		Utils.SetGlobalProperty("HistoricalEventManagerLastInvoked", currentYear)
		for i, event in ipairs(eventQueue) do
			print("Checking event "..event.EventID)
			local status = event:CheckCondition()
			if status == 1 then
				event:Trigger()
			end

			if status ~= -1 then
				table.insert(newQueue, event)
			end

		end
		eventQueue = newQueue
		lastInvoked = currentYear
	end
end

function HistoricalEvent:New(o)
	local required_fields = {"EventID", "EventName", "Leaders", "OccurYear", "Compensation"}
	local optional_fields = {"AdvisorType", "AdvisorHeading", "AdvisorBody"}

	for i, key in ipairs(required_fields) do
		if not o[key] then
			error("HistoricalEvent missing attribute '"..key.."'")
		end
	end

	o.isDispose = false
	setmetatable(o, self)
    self.__index = self
    return o
end

--- return 1 if it should be triggered now
--- return 0 if it cannot be triggered now but it may be triggered in future
--- return -1 if it will never be triggered
function HistoricalEvent:CheckCondition()
	if self.isDispose then
		return -1
	end

	if currentYear > self.OccurYear then
		return 1
	end

	return 0
end

function HistoricalEvent:Trigger(skipSave, playersOverride)
	skipSave = skipSave or false
	local isShowAdvisor = self.AdvisorType ~= nil and self.AdvisorHeading ~= nil and self.AdvisorBody ~= nil
	local eventPlayers = playersOverride or {}
	if playersOverride  == nil then
		if self.Leaders == "all" then
			eventPlayers = Players
		elseif self.Leaders == "allhuman" then
			for key, player in pairs(Players) do
				if player:IsHuman() then
					table.insert(eventPlayers, player)
				end
			end
		else
			for key, leader in pairs(self.Leaders) do
				table.insert(eventPlayers, Utils.GetPlayerByLeaderType(leader))
			end
		end
	end
	for key, player in pairs(eventPlayers) do
		if player and player:IsAlive() and player:GetCapitalCity() ~= nil then
			local capitalCity = player:GetCapitalCity()
			local capitalPlot = capitalCity:Plot()

			for unitTypeID, count in pairs(self.Compensation) do
				if count ~= 0 then
					if GameInfo.Units[unitTypeID] ~= nil then
						print(self.EventID..": Granting "..count.." "..unitTypeID.." to player "..player:GetID())
						Utils.AddFreeUnits(
							player,
							GameInfo.Units[unitTypeID].ID,
							capitalPlot:GetX(),
							capitalPlot:GetY(), 
							count
						)
					elseif unitTypeID:lower() == "gold" then
						player:ChangeGold(count)
					elseif unitTypeID:lower() == "tech" then
						if player:IsHuman() then
							player:SetNumFreeTechs(player:GetNumFreeTechs() + count)
							player:AddNotification(NotificationTypes.NOTIFICATION_FREE_TECH,  Locale.Lookup("TXT_KEY_UGFN_FREETECH"), Locale.Lookup(self.EventName))
						else
							local freeTechGranted = capitalCity:GetNumRealBuilding(GameInfoTypes["BUILDING_DUMFREETECH"])
							capitalCity:SetNumRealBuilding(GameInfoTypes["BUILDING_DUMFREETECH"], freeTechGranted + count)
						end
					elseif unitTypeID:lower() == "policy" then
						player:ChangeNumFreePolicies(count)
					elseif unitTypeID:lower() == "culture" then
						player:ChangeJONSCulture(count)
					elseif unitTypeID:lower() == "faith" then
						player:ChangeFaith(count)
					end
				end
			end
			if player:IsHuman() and isShowAdvisor then
				AdvisorManager.GenerateAdvisorPopUp(player:GetID(), AdvisorTypes[self.AdvisorType], Locale.Lookup(self.AdvisorHeading),  Locale.Lookup(self.AdvisorBody))
			end 			
		end
	end
	if not skipSave then
		print("Removing event "..self.EventID)
		Utils.SetGlobalProperty("HISTEVENT_"..self.EventID, true)
	end
	self.isDispose = true
end
