DisasterEvent = {}

function DisasterEvent:New(o)
	local required_fields = {"EventID", "EventName", "Leaders", "OccurProb", "ObsoleteCondition", "Loss"}
	local optional_fields = {"AdvisorType", "AdvisorHeading", "AdvisorBody"}

	for i, key in ipairs(required_fields) do
		if not o[key] then
			error("DisasterEvent missing attribute '"..key.."'")
		end
	end

	setmetatable(o, self)
    self.__index = self
    if Utils.GetGlobalProperty("DISASTER_"..o.EventID) == nil then
    	HistoricalEventManager.AddToQueue(o)
    	print("Registering disaster "..o.EventID)
    end

    return o
end

function DisasterEvent:CheckCondition()
	local isObsolete = self:ObsoleteCondition()

	if isObsolete then
		Utils.SetGlobalProperty("DISASTER_"..self.EventID, true)
		return -1
	end

	return 1
end

function DisasterEvent:Trigger()
	local isShowAdvisor = self.AdvisorType ~= nil and self.AdvisorHeading ~= nil and self.AdvisorBody ~= nil
	local eventPlayers = {}
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

	for key, player in pairs(eventPlayers) do
		local threshold = self.OccurProb(player)
		local randompt =  Game.rand(101, "random diaster")/100.0
		local unitKilled = false
		if player and player:IsAlive() and player:GetCapitalCity() ~= nil and randompt < threshold then
			if self.Loss["Gold"] ~= nil then
				local goldChange = math.min(player:GetGold(), self.Loss["Gold"])
				player:ChangeGold(-1*goldChange)
			end
			if self.Loss["Population"] ~= nil then
				for city in player:Cities() do 
					local population = city:GetPopulation()
					local populationChange = math.min(population - 1, math.ceil(population*self.Loss["Population"]))
					city:ChangePopulation(-1*populationChange)
				end
			end
			if self.Loss["UnitHP"] ~= nil then
				for unit in player:Units() do 
					local plot = unit:GetPlot()
					if plot:GetOwner() == player:GetID() and unit:GetUnitCombatType() > -1 then
						local currentHP = 100 - unit:GetDamage()
						if self.Loss["UnitHP"] >= currentHP then
							unit:Kill()
							unitKilled = true
						else
							unit:ChangeDamage(self.Loss["UnitHP"])
						end
					end
				end
			end
			if self.Loss["PillageTiles"] ~= nil then
				local range = self.Loss["PillageTiles"]["Range"]
				local prob = self.Loss["PillageTiles"]["Prob"]
				for city in player:Cities() do
					local cityX = city:Plot():GetX()
					local cityY = city:Plot():GetY()
					for x = cityX - range, cityY+range do 
						for y = cityY - range, cityY + range do
							local plot = Map.GetPlot(x, y)
							if plot:GetImprovementType() ~= -1 then
								randompt = math.random()
								if randompt < prob then
									plot:SetImprovementPillaged(true)
								end
							end
						end
					end
				end
			end
			if player:IsHuman() then
				if unitKilled then
					player:AddNotification(NotificationTypes.NOTIFICATION_UNIT_DIED,  Locale.Lookup("TXT_KEY_UGFN_DISASTER_UNIT_DIED"), Locale.Lookup(self.EventName))
				end
				if isShowAdvisor then
					AdvisorManager.GenerateAdvisorPopUp(player:GetID(), AdvisorTypes[self.AdvisorType], Locale.Lookup(self.AdvisorHeading),  Locale.Lookup(self.AdvisorBody))
				end
			end 
		end
	end
end

include("DisastersList.lua")