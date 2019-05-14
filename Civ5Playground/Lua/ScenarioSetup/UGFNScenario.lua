UGFNScenario = {}
function UGFNScenario:New(o)
	local required_fields = {
		"building_class_id", 
		"building_type",
		"building_txt_key",
		"n_building_required",
		"prerequiste_tech",
		"prerequiste_tech_txt_key"
	}

	local boolean_or_optional_fields = {
		"require_victory"
	}

	for i, key in ipairs(required_fields) do
		if not o[key] then
			error("UGFNScenario missing attribute '"..key.."'")
		end
	end

	setmetatable(o, self)
    self.__index = self

    local building_constrcuted = Utils.GetPlayerProperty(Game.GetActivePlayer(), "scenario_building_constructed")
    if building_constrcuted == nil then
		Utils.SetPlayerProperty(Game.GetActivePlayer(), "scenario_building_constructed", 0)
	end

	local tech_researched = Utils.GetPlayerProperty(Game.GetActivePlayer(), "scenario_tech_researched")

    if tech_researched == nil then
		Utils.SetPlayerProperty(Game.GetActivePlayer(), "scenario_tech_researched", 0)
	end

	local victory_achieved = Utils.GetPlayerProperty(Game.GetActivePlayer(), "victory")
	if victory_achieved == nil then
		Utils.SetPlayerProperty(Game.GetActivePlayer(), "victory", 0)
	end

    return o
end

function UGFNScenario:configureRequirementPopup()
	local function RequirementPopup()
		AdvisorManager.GenerateAdvisorPopUp(
			Game.GetActivePlayer(),
			AdvisorTypes.ADVISOR_MILITARY, 
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_JUST_STARTED_TITLE"),
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_REQUIREMENTS"),
				self.n_building_required,
				self.n_building_required,
				Locale.Lookup(self.building_txt_key),
				Locale.Lookup(self.prerequiste_tech_txt_key)
			)
		)
		return true
	end

	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_SCENARIO_STARTED",
		RequirementPopup
	)

end

function UGFNScenario:setTechResearched()
	Utils.SetPlayerProperty(Game.GetActivePlayer(), "scenario_tech_researched", 1)
end

function UGFNScenario:setBuildingConstructed(count)
	Utils.SetPlayerProperty(Game.GetActivePlayer(), "scenario_building_constructed", count)
end

function UGFNScenario:setVictoryAttained()
	Utils.SetPlayerProperty(Game.GetActivePlayer(), "victory", 1)
end

function UGFNScenario:isTechResearched()
	return Utils.GetPlayerProperty(Game.GetActivePlayer(), "scenario_tech_researched") == 1
end

function UGFNScenario:getBuildingConstructedCount()
	return Utils.GetPlayerProperty(Game.GetActivePlayer(), "scenario_building_constructed")
end

function UGFNScenario:isVictoryAttained()
	return Utils.GetPlayerProperty(Game.GetActivePlayer(), "victory") == 1
end

function UGFNScenario:configure_tech_researched_popup()
	local txt_tech = Locale.Lookup(self.prerequiste_tech_txt_key)
	local txt_building = Locale.Lookup(self.building_txt_key)
	local txt_researched_next_step = string.format(Locale.Lookup("TXT_KEY_RESEARCHED_NEXT_STEP"), txt_building, txt_building)
	
	local show_popup = TechnologyResearchedListenerFactory(
			GameInfoTypes[self.prerequiste_tech],
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_TITLE"), 
				txt_tech
			),
			string.format(
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_TECH_MSG"), 
				txt_tech,
				txt_researched_next_step
			),
			true
	)


	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_TECH_RESEARCHED",
		show_popup
	)

	local update_progress = function(teamId, techType, adopted)
		local team = Teams[teamId]
		local player = Players[team:GetLeaderID()]
		if (techType == GameInfoTypes[self.prerequiste_tech] and player:IsHuman()) then
			self:setTechResearched(1)
			GameEvents.TeamTechResearched.Remove(update_progress)
		end
	end

	GameEvents.TeamTechResearched.Add(update_progress)

end

function UGFNScenario:configure_building_constructed_popup()
	local building_txt = Locale.Lookup(self.building_txt_key)

	for i = 1, self.n_building_required - 1 do
		local show_popup = BuildingCountListenerFactory(	
			self.building_class_id,
			i, 	
			string.format(	
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),	
				building_txt	
			),	
			string.format(	
				Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_MSG"), 	
				i, 	
				building_txt,	
				self.n_building_required - i	
			),	
			true	
		)
		ListenerManager.AddIndividualTurnStartListener(	
			string.format("NOTIFICATION_BUILDING_CONSTRUCTED_%d", i),	
			show_popup
		)
	end

	local show_completed_popup = BuildingCountListenerFactory(
		self.building_class_id,
		self.n_building_required, 
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_TITLE"),
			building_txt
		),
		string.format(
			Locale.Lookup("TXT_KEY_UGFN_PROGRESS_BUILD_FINISH_MSG"), 
			building_txt
		),
			true
	)
	ListenerManager.AddIndividualTurnStartListener(	
		string.format("NOTIFICATION_BUILDING_CONSTRUCTED_%d", self.n_building_required),	
		show_completed_popup
	)
	
	local update_progress = function(ownerId, cityId, buildingType, bGold, bFaithOrCulture)
		local player = Players[ownerId]
		if (buildingType == GameInfoTypes[self.building_type] and player:IsHuman()) then
			self:setBuildingConstructed(self:getBuildingConstructedCount() + 1)
		end
	end
	GameEvents.CityConstructed.Add(update_progress)	
end

function create_update_progress_item_hook(scenario)
	function OnUpdateProgressItems()
		local buildingCount = scenario:getBuildingConstructedCount()

		local researched_int = 0
		if scenario:isTechResearched() == true then
			researched_int = 1
		end
		LuaEvents.OnAddIntProgressItem(
			GameInfo.Technologies[scenario.prerequiste_tech], 
			Locale.Lookup(scenario.prerequiste_tech_txt_key), 
			researched_int,
			1
		)

		LuaEvents.OnAddIntProgressItem(
			GameInfo.Buildings[scenario.building_type], 
			Locale.Lookup(scenario.building_txt_key),
			buildingCount,
			scenario.n_building_required
		)
		local object = GameInfo.Buildings[scenario.building_type]

		if scenario.require_victory then
			LuaEvents.OnAddIntProgressItem(
				{
					["IconAtlas"] = "UGFN_TROPHY_ATLAS_64",
					["PortraitIndex"] = 0
				},
				Locale.Lookup("TXT_KEY_GEF_PROGRESS_Victory"),
				scenario:isVictoryAttained() and 1 or 0,
				1
			)
		end
		local myLeaderInfo = GameInfo.Leaders[Utils.GetCurrentPlayer():GetLeaderType()];

		LuaEvents.OnAddTextProgressItem(
			myLeaderInfo, 
			Locale.Lookup("TXT_KEY_GEF_PROGRESS_STARTTIME"), 
			Utils.GetGlobalProperty("STARTTIME")
		)
	end
	return OnUpdateProgressItems
end

function UGFNScenario:configure_update_progress_item_hook()
	LuaEvents.OnUpdateProgressItems.Add(create_update_progress_item_hook(self))
end

function UGFNScenario:configure_victory_hook()
	local listener = function(endGameType, teamId)
		if Utils.GetCurrentPlayer():GetTeam() == teamId then
			self:setVictoryAttained()
			Events.EndGameShow.Remove(listener)
			return true
		end
	end
	Events.EndGameShow.Add(listener)
	ListenerManager.AddIndividualTurnStartListener(	
		string.format("LISTENER_VICTORY"),	
		listener
	)
end