local firstTurnConfigLoaded = Utils.GetGlobalProperty("Part23FirstTurnConfigLoaded")
if not firstTurnConfigLoaded then
	include("ReligionSetup.lua")
	SetupReligion("Part23")
	local civToPlayer = CreateCivToPlayerLookupTable()
	local venice = civToPlayer[GameInfo.Civilizations["CIVILIZATION_VENICE"].ID]
	local veniceTeam = Teams[venice:GetTeam()]
	veniceTeam:SetHasTech(GameInfoTypes["TECH_OPTICS"], true)
	Utils.SetGlobalProperty("Part23FirstTurnConfigLoaded", true)
end

include("UGFNScenario.lua")

part23Scenario = UGFNScenario:New({
	building_class_id = GameInfo.BuildingClasses.BUILDINGCLASS_LABORATORY.ID, 
	building_type = "BUILDING_LABORATORY",  -- just for displaying the building icon
	n_building_required = 4,
	prerequiste_tech = "TECH_PENICILIN",
	require_victory = true
})
part23Scenario:configureRequirementPopup()
part23Scenario:configure_tech_researched_popup()
part23Scenario:configure_building_constructed_popup()
part23Scenario:configure_update_progress_item_hook()
part23Scenario:configure_victory_hook()