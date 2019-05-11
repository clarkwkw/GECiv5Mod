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

	for i, key in ipairs(required_fields) do
		if not o[key] then
			error("UGFNScenario missing attribute '"..key.."'")
		end
	end

	setmetatable(o, self)
    self.__index = self

    local prev_progress = Utils.GetGlobalProperty("scenario_progress")
    if prev_progress == nil then
		Utils.SetGlobalProperty("scenario_progress", "none")
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

function UGFNScenario:setProgress(progress)
	Utils.SetGlobalProperty("scenario_progress", progress)
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

	local function listener()
		local triggered = show_popup()
		if triggered then
			self.setProgress("tech_researched")
		end
		return triggered

	end

	ListenerManager.AddIndividualTurnStartListener(
		"NOTIFICATION_TECH_RESEARCHED",
		listener
	)
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
		local function listener()
			local triggered = show_popup()
			if triggered then
				self.setProgress(i)
			end
			return triggered
		end	 	
		ListenerManager.AddIndividualTurnStartListener(	
			string.format("NOTIFICATION_BUILDING_CONSTRUCTED_%d", i),	
			listener
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

	local function listener()
		local triggered = show_completed_popup()
		if triggered then
			self.setProgress(self.n_building_required)
		end
		return triggered
	end
	ListenerManager.AddIndividualTurnStartListener(	
		string.format("NOTIFICATION_BUILDING_CONSTRUCTED_%d", self.n_building_required),	
		listener
	)
end

function create_update_progress_item_hook(scenario)
	function OnUpdateProgressItems(localPlayer)
		local progress = Utils.GetGlobalProperty("scenario_progress")
		researched = 0
		if progress ~= "none" then
			researched = 1
		end

		LuaEvents.OnAddIntProgressItem(
			GameInfo.Technologies[scenario.prerequiste_tech], 
			Locale.Lookup(scenario.prerequiste_tech_txt_key), 
			researched,
			1
		)
		
		built = 0
		if progress ~= "none" and progress ~= "researched" then
			built = progress
		end
		LuaEvents.OnAddIntProgressItem(
			GameInfo.Buildings[scenario.building_type], 
			Locale.Lookup(scenario.building_txt_key),
			built,
			scenario.n_building_required
		)

		local myLeaderInfo = GameInfo.Leaders[localPlayer:GetLeaderType()];

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
	local listener = function()
		if Game.GetActivePlayer():GetTeam() == Game:GetWinner() then
			Utils.SetGlobalProperty("VICTORY", true)
			return true
		end
	end
	ListenerManager.AddIndividualTurnStartListener(	
		string.format("LISTENER_VICTORY"),	
		listener
	)
end