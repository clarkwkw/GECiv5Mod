-- Utils
-- Author: clark
-- DateCreated: 1/19/2018 7:00:40 PM
--------------------------------------------------------------
i_TurnPlayer = -1
g_SaveData = Modding.OpenSaveData("UGFN", 1)
g_Properties = {}

GameEvents.PlayerDoTurn.Add(
	function(iPlayer)
		i_TurnPlayer = iPlayer
	end
)

function GetPersistentProperty(name)
    if not g_Properties[name] then
        g_Properties[name] = g_SaveData.GetValue(name)
    end
    return g_Properties[name]
end

function SetPersistentProperty(name, value)
    if not(GetPersistentProperty(name) == value) then
		g_SaveData.SetValue(name, value)
		g_Properties[name] = value
	end
	return value
end

function GetPlayerProperty(player_id, identifier)
	return GetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier)
end

function SetPlayerProperty(player_id, identifier, value)
	SetPersistentProperty("PLAYER_DATA_".. player_id .. "_" .. identifier, value)
end