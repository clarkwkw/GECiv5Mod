local bIsModding = true;
local ModID = "17c0bfe1-11af-4921-9198-5db1ea0e4b10"
local ModVersion = Modding.GetLatestInstalledModVersion(ModID)
modUserData = Modding.OpenUserData(ModID, ModVersion)

function IsUGFNMap(filename)
	return string.match(string.lower(filename), "ugfn") or string.match(string.lower(filename), "ugfh")
end