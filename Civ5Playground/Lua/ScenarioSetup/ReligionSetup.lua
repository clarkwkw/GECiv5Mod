SetupReligion = function(scenarioId)
	local civToPlayer = CreateCivToPlayerLookupTable()
	print("Setting holy cities..")
	-- Set holy cities
	for row in GameInfo.ScenarioReligion{ScenarioId = scenarioId} do
		local player = civToPlayer[GameInfo.Civilizations[row.FounderCivId].ID]
		local city = GetCityByPlayerAndCityName(player, row.HolyCityName)
		if city ~= nil then
			Game.FoundReligion(
				player:GetID(),
				GameInfo.Religions[row.ReligionId].ID,
				GameInfo.Beliefs[row.PantheonBelief].ID,
				GameInfo.Beliefs[row.FounderBelief1].ID,
				GameInfo.Beliefs[row.FounderBelief2].ID,
				GameInfo.Beliefs[row.FounderBelief3].ID,
				GameInfo.Beliefs[row.FounderBelief4].ID,
				city
			)
		end
	end
	print("Setting follower cities..")
	--- Change belief
	for row in GameInfo.ScenarioCityReligion{ScenarioId = scenarioId} do
		local player = civToPlayer[GameInfo.Civilizations[row.CityCivId].ID]
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

GetCityByPlayerAndCityName = function(player, cityName)
	for city in player:Cities() do
		local isMatched = city:GetNameKey():lower() == cityName:lower()
		isMatched = isMatched or Locale.LookupLanguage("en_US", city:GetNameKey()):lower() == cityName:lower()

		if isMatched then
			return city
		end
	end
end