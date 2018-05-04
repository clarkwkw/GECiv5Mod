import os
import errno
import platform
import zipfile
import shutil
from distutils.dir_util import copy_tree
import json

POSSIBLE_INSTALLATION_PATHS = {
	"windows": [
		"C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V",
		"D:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V"
	],
	"darwin": [
		os.path.expanduser("~/Library/Application Support/Steam/steamapps/common/Sid Meier's Civilization V")
	]
}

MOD_PATHS = {
	"windows": os.path.expanduser("~/Documents/My Games/Sid Meier's Civilization 5/MODS"),
	"darwin": ""
}

# On some system, e.g. MacOS, the game content is placed in a subdirectory under civ5 installation path
CIV5_ROOT_OFFSET = {
	"windows": "",
	"darwin": "Civilization V.app/Contents/Home"
}

CIV5_LANDMARKS = {
	"windows": [
		"Launcher.exe"
	],
	"darwin": [
		"Civilization V.app"
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

	if len(CIV5_LANDMARKS[os_type]) == 0:
		return False

	for filename in CIV5_LANDMARKS[os_type]:
		if not os.path.exists(os.path.join(path, filename)):
			return False
	return True

def check_civ5_activated():
	os_type = platform.system().lower()
	return os.path.exists(MOD_PATHS[os_type])

def check_mod_version(civ5_path):
	os_type = platform.system().lower()
	MODINFO_PATH = os.path.join(CIV5_ROOT_OFFSET[os_type], "modinfo.json")
	if not verify_civ5_installation_path(civ5_path):
		return None

	modinfo_full_path = os.path.join(civ5_path, MODINFO_PATH)
	if not os.path.isfile(modinfo_full_path):
		return None

	with open(modinfo_full_path, "r") as f:
		modinfo = json.load(f)
		version = modinfo["version"]

	return version

# adopted from https://stackoverflow.com/questions/1855095/how-to-create-a-zip-archive-of-a-directory
def zipdir(path, zipname):
	ziph = zipfile.ZipFile(zipname, 'w', zipfile.ZIP_DEFLATED)
	for root, dirs, files in os.walk(path):
		for file in files:
			file_path = os.path.join(root, file)
			ziph.write(file_path, file_path.lstrip(path))
	ziph.close()

def merge_dir(src_dir, target_dir):
	for item in os.listdir(src_dir):
		item_src_path = os.path.join(src_dir, item)
		item_target_path = os.path.join(target_dir, item)
		if os.path.isdir(item_src_path):
			copy_tree(item_src_path, item_target_path)
		else:
			shutil.copy2(item_src_path, item_target_path)