SetupReligion = function(scenarioId)
	local civToPlayer = CreateCivToPlayerLookupTable()
	local minorCivToPlayer = CreateMinorCivToPlayerLookupTable()
	print("Setting holy cities..")
	-- Set holy cities
	for row in GameInfo.ScenarioReligion{ScenarioId = scenarioId} do
		local player = nil

		if GameInfo.Civilizations[row.FounderCivId] ~= nil then
			player = civToPlayer[GameInfo.Civilizations[row.FounderCivId].ID]
		elseif GameInfo["MinorCivilizations"][row.FounderCivId] ~= nil then
			player = minorCivToPlayer[GameInfo["MinorCivilizations"][row.FounderCivId].ID]
		end
		if player ~= nil then
			local city = GetCityByPlayerAndCityName(player, row.HolyCityName)
			if city ~= nil then
				Game.FoundReligion(
					player:GetID(),
					GameInfo.Religions[row.ReligionId].ID,
					nil,
					BeliefTypes[row.FounderBelief1] or -1,
					BeliefTypes[row.FounderBelief2] or -1,
					BeliefTypes[row.FounderBelief3] or -1,
					BeliefTypes[row.FounderBelief4] or -1,
					city
				)
			end
		end
	end
	print("Setting follower cities..")
	--- Change belief
	for row in GameInfo.ScenarioCityReligion{ScenarioId = scenarioId} do
		local player = civToPlayer[GameInfo.Civilizations[row.CityCivId].ID] or minorCivToPlayer[GameInfo["MinorCivilizations"][row.FounderCivId].ID]
		local city = GetCityByPlayerAndCityName(player, row.CityName)
		if city ~= nil then
			city:AdoptReligionFully(GameInfo.Religions[row.ReligionId].ID)
		end
	end
end

CreateCivToPlayerLookupTable = function()
	local table = {}
	for key, player in pairs(Players) do
		table[player:GetCivilizationType()] = player
	end
	return table
end

CreateMinorCivToPlayerLookupTable = function()
	local table = {}
	for key, player in pairs(Players) do
		table[player:GetMinorCivType()] = player
	end
	return table
end

GetCityByPlayerAndCityName = function(player, cityName)
	for city in player:Cities() do
		local isMatched = city:GetNameKey():lower() == cityName:lower()
		isMatched = isMatched or Locale.LookupLanguage("en_US", city:GetNameKey()):lower() == cityName:lower()

		if isMatched then
			return city
		end
	end
end