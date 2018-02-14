BerserkEnermyEventManager  = {}
BerserkEnermyEvent = {}

BerserkEnermyEventManager.InitEvents = function()
	local eventInfo = {}
	local eventAllLeadersDefense = {}

	for row in GameInfo.EventBerserkEnermy() do
		print("Adding event "..row.EventID)
		if not Utils.GetGlobalProperty("HISTEVENT_"..row.EventID) then
			eventInfo[row.EventID] = {}
			for key, value in pairs(row) do
				eventInfo[row.EventID][key] = value
				print("Getting "..key)
			end
			eventInfo[row.EventID]["OffenseLeaders"] = {}
			eventInfo[row.EventID]["DefenseLeaders"] = {}
			eventInfo[row.EventID]["OffenseCompensation"] = {}
			eventInfo[row.EventID]["DefenseCompensation"] = {}
			eventInfo[row.EventID]["OffenseTroops"] = {}
		end
	end

	for row in GameInfo.EventBerserkEnermyOffense() do
		print("Adding offensing leader "..row.LeaderType.." to "..row.EventID)
		if eventInfo[row.EventID] ~= nil then
			table.insert(eventInfo[row.EventID]["OffenseLeaders"], row.LeaderType)
		end
	end

	for row in GameInfo.EventBerserkEnermyDefense() do
		print("Adding defending leader "..row.LeaderType.." to "..row.EventID)
		if eventInfo[row.EventID] ~= nil and eventAllLeadersDefense[row.EventID] == nil then
			if row.LeaderType:lower() ~= "all" and row.LeaderType:lower() ~= "allhuman" then
				table.insert(eventInfo[row.EventID]["DefenseLeaders"], row.LeaderType)
			else
				eventInfo[row.EventID]["DefenseLeaders"] =  row.LeaderType:lower()
				eventAllLeadersDefense[row.EventID] = true
			end
		end
	end

	for row in GameInfo.EventBerserkEnermyOffenseCompensation() do
		if eventInfo[row.EventID] ~= nil then
			print("Adding offensing compensation "..row.UnitTypeID.."("..row.Count..") to event "..row.EventID)
			eventInfo[row.EventID]["OffenseCompensation"][row.UnitTypeID] = row.Count
		end
	end

	for row in GameInfo.EventBerserkEnermyOffenseTroops() do
		if eventInfo[row.EventID] ~= nil then
			print("Adding offensing troops "..row.UnitTypeID.."("..row.Count..") to event "..row.EventID)
			eventInfo[row.EventID]["OffenseTroops"][row.UnitTypeID] = row.Count
		end
	end

	for row in GameInfo.EventBerserkEnermyDefenseCompensation() do
		if eventInfo[row.EventID] ~= nil then
			print("Adding defending compensation "..row.UnitTypeID.."("..row.Count..") to event "..row.EventID)
			eventInfo[row.EventID]["DefenseCompensation"][row.UnitTypeID] = row.Count
		end
	end

	for key, event in pairs(eventInfo) do
		HistoricalEventManager.AddToQueue(BerserkEnermyEvent:New(event))
	end
end

function BerserkEnermyEvent:New(o)
	local required_fields = {"EventID", "OffenseLeaders", "DefenseLeaders", "OccurYear", "OffenseCompensation", "DefenseCompensation", "OffenseTroops"}
	local optional_fields = {"OffenseAdvisorType", "DefenseAdvisorType", "OffenseAdvisorHeading", "OffenseAdvisorBody", "DefenseAdvisorHeading", "DefenseAdvisorBody"}

	for i, key in ipairs(required_fields) do
		if not o[key] then
			error("BerserkEnermyEvent missing attribute '"..key.."'")
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
function BerserkEnermyEvent:CheckCondition()
	if self.isDispose then
		return -1
	end

	if HistoricalEventManager.GetCurrentYear() > self.OccurYear then
		return 1
	end

	return 0
end

function BerserkEnermyEvent:Trigger()
	local defenseEvent = HistoricalEvent:New({
		EventID = self.EventID,
		Leaders = self.DefenseLeaders,
		OccurYear = self.OccurYear,
		Compensation = self.DefenseCompensation,
		AdvisorType = self.DefenseAdvisorType,
		AdvisorHeading = self.DefenseAdvisorHeading,
		AdvisorBody = self.DefenseAdvisorBody
	})

	local offenseEvent = HistoricalEvent:New({
		EventID = self.EventID,
		Leaders = self.OffenseLeaders,
		OccurYear = self.OccurYear,
		Compensation = self.OffenseCompensation,
		AdvisorType = self.OffenseAdvisorType,
		AdvisorHeading = self.OffenseAdvisorHeading,
		AdvisorBody = self.OffenseAdvisorBody
	})

	local eventOffensePlayers = {}	
	local eventDefensePlayers = {}

	--- Retrieve offensing and defending players
	for key, leader in pairs(self.OffenseLeaders) do
		table.insert(eventOffensePlayers, Utils.GetPlayerByLeaderType(leader))
	end

	if self.DefenseLeaders == "all" then
		eventDefensePlayers = Players
	elseif self.DefenseLeaders == "allhuman" then
		for key, player in pairs(Players) do
			if player:IsHuman() then
				table.insert(eventDefensePlayers, player)
			end
		end
	else
		for key, leader in pairs(self.DefenseLeaders) do
			table.insert(eventDefensePlayers, Utils.GetPlayerByLeaderType(leader))
		end
	end

	print("Offense: "..#eventOffensePlayers)
	print("Defense: "..#eventDefensePlayers)

	for key, player in pairs(eventOffensePlayers) do
		if not player:IsAlive() then
			eventOffensePlayers[key] = nil
		end
	end
	for key, player in pairs(eventDefensePlayers) do
		if not player:IsAlive() then
			eventDefensePlayers[key] = nil
		end
	end

	--- For every offense player, spawn troops around every defense player's capital city
	--- Declare war for every pair of offense and defense player

	if #eventOffensePlayers > 0 and #eventDefensePlayers > 0 then
		for _, offensePlayer in pairs(eventOffensePlayers) do
			for _, defensePlayer in pairs(eventDefensePlayers) do
				if defensePlayer:GetCapitalCity() ~= nil then
					local capitalPlot = defensePlayer:GetCapitalCity():Plot()
					for unitTypeID, count in pairs(self.OffenseTroops) do
						local locationX = capitalPlot:GetX() + math.random(1, 3)
						local locationY = capitalPlot:GetY() + math.random(1, 3)
						print(self.EventID..": Spawning "..count.." "..unitTypeID.." for player "..offensePlayer:GetID().." at the capital of player "..defensePlayer:GetID())
						Utils.AddFreeUnits(
							offensePlayer,
							GameInfo.Units[unitTypeID].ID,
							locationX,
							locationY, 
							count
						)
					end
				end
				local teamOffense = Teams[offensePlayer:GetTeam()]
				local teamDefense = Teams[defensePlayer:GetTeam()]
				teamOffense:DeclareWar(teamDefense, true)
			end
		end
		defenseEvent:Trigger(true)
		offenseEvent:Trigger(true)
	end

	print("Removing event "..self.EventID)
	Utils.SetGlobalProperty("HISTEVENT_"..self.EventID, true)
	self.isDispose = true
end
