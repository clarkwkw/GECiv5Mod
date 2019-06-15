include("UGFNScenario.lua")

part23Scenario = UGFNScenario:New({
	building_class_id = GameInfo.BuildingClasses.BUILDINGCLASS_UNIVERSITY.ID, 
	building_type = "BUILDING_UNIVERSITY", -- just for displaying the building icon
	n_building_required = 4,
	prerequiste_tech = "TECH_UNIVERSITY_EDUCATION",
	require_victory = false
})
part23Scenario:configureRequirementPopup()
part23Scenario:configure_tech_researched_popup()
part23Scenario:configure_building_constructed_popup()
part23Scenario:configure_update_progress_item_hook()
part23Scenario:configure_victory_hook()