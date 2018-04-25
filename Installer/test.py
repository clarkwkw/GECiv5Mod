import io_utils, network_utils, shutil

version_json = network_utils.get_versions()
latest_version = version_json["current_version"]
mod_url = version_json["versions"][latest_version]["url"]
civ5_path = io_utils.suggest_civ5_installation_path()

if civ5_path is None:
	print("Cannot detect civ5 installation")
	exit()

print("Civ 5 Installation:", civ5_path)
local_version = io_utils.check_mod_version(civ5_path)

print("Installed mod version:", local_version if local_version is not None else "Not installed")
print("Latest version:", latest_version)

decision = None
while decision is None:
	res = input("Do you want to [re-]install the mod? [y/n] ")
	res = res.lower()
	if res == "y":
		decision = True
	elif res == "n":
		decision = False

if decision:
	print("Downloading...")
	downloaded_dir = network_utils.download_mod(mod_url, "./tmp")
	print("Patching...")
	io_utils.merge_dir(downloaded_dir, civ5_path)
	shutil.rmtree("./tmp")
	print("Done")