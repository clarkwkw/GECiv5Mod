SetupReligion = function(scenarioId)

	local civToPlayer = CreateCivToPlayerLookupTable()
	local minorCivToPlayer = CreateMinorCivToPlayerLookupTable()
	print("Setting Pantheons..")
	for row in GameInfo.ScenarioPantheon{ScenarioId = scenarioId} do
		print("\t", row.CivId, "->", row.PantheonBelief)
		local player = GetPlayerById(row.CivId, civToPlayer, minorCivToPlayer)
		local beliefType = GameInfo.Beliefs[row.PantheonBelief]

		if player ~= nil and beliefType ~= nil then
			Game.FoundPantheon(player:GetID(), beliefType.ID)
		end
	end


	print("Setting holy cities..")
	-- Set holy cities
	for row in GameInfo.ScenarioReligion{ScenarioId = scenarioId} do
		print("\t", row.FounderCivId, "->", row.ReligionId)
		local player =  GetPlayerById(row.FounderCivId, civToPlayer, minorCivToPlayer)

		if player ~= nil then
			local city = GetCityByPlayerAndCityName(player, row.HolyCityName)
			if city ~= nil then
				Game.FoundReligion(
					player:GetID(),
					GameInfo.Religions[row.ReligionId].ID,
					nil,
					GetBeliefIdByKey(row.FounderBelief1),
					GetBeliefIdByKey(row.FounderBelief2),
					GetBeliefIdByKey(row.FounderBelief3),
					GetBeliefIdByKey(row.FounderBelief4),
					city)
			end
		end
	end

	print("Setting follower cities..")
	--- Change belief
	for row in GameInfo.ScenarioCityReligion{ScenarioId = scenarioId} do
		print("\t", row.CityCivId, row.CityName, "->", row.ReligionId)
		local player = GetPlayerById(row.CityCivId, civToPlayer, minorCivToPlayer)

		if player ~= nil then
			local city = GetCityByPlayerAndCityName(player, row.CityName)
			if city ~= nil then
				city:AdoptReligionFully(GameInfo.Religions[row.ReligionId].ID)
			end
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

GetPlayerById = function(id, civToPlayer, minorCivToPlayer)
	local player = nil
	if GameInfo.Civilizations[id] ~= nil then
		player = civToPlayer[GameInfo.Civilizations[id].ID]
	elseif GameInfo["MinorCivilizations"][id] ~= nil then
		player = minorCivToPlayer[GameInfo["MinorCivilizations"][id].ID]
	end
	return player
end

GetBeliefIdByKey = function(key)
	local belief = GameInfo.Beliefs[key]
	if belief then
		return belief.ID
	else
		return -1
	end
end