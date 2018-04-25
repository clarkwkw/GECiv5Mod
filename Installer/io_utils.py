import os
import errno
import platform
import zipfile

POSSIBLE_INSTALLATION_PATHS = {
	"windows": [
		"C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V",
		"D:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V"
	],
	"darwin": [
		"~/Libraries/Application Support/Steam/SteamApps/common/Sid Meier's Civilization V"
	]
}

CIV5_LANDMARKS = {
	"windows": [
		"Launcher.exe"
	],
	"darwin": [
	]
}

def make_sure_path_exists(path):
	try:
		os.makedirs(path)
	except OSError as exception:
		if exception.errno != errno.EEXIST:
			raise

def suggest_civ5_installation_path():
	os_type = platform.system().lower()
	for path in POSSIBLE_INSTALLATION_PATHS[os_type]:
		if verify_civ5_installation_path(path):
			return path
	return None

def verify_civ5_installation_path(path):
	os_type = platform.system().lower()

	for filename in CIV5_LANDMARKS[os_type]:
		if not os.path.isfile(path.rstrip("/") + "/" + filename):
			return False
	return True

# adopted from https://stackoverflow.com/questions/1855095/how-to-create-a-zip-archive-of-a-directory
def zipdir(path, zipname):
	ziph = zipfile.ZipFile(zipname, 'w', zipfile.ZIP_DEFLATED)
	for root, dirs, files in os.walk(path):
		for file in files:
			file_path = os.path.join(root, file)
			ziph.write(file_path, file_path.lstrip(path))
	ziph.close()

if __name__ == "__main__":
	print(suggest_civ5_installation_path())
	print(verify_civ5_installation_path("./"))