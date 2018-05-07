import zipfile
import io_utils
from distutils.dir_util import copy_tree
import shutil
import os
from os.path import dirname
import json
import platform 

'''
Prerequisite:
1. Run the Multiplayer Mod DLC-hack, you can find the details at 
   https://forums.civfanatics.com/threads/mpmpm-multiplayer-mod-dlc-hack-updated.533238/
2. Configure the civ5 installation path and other settings in below
'''

# ------------------ Settings ------------------ #

# Installation Path of Civ5
CIV5_ROOT_DIR = "C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V"
#CIV5_ROOT_DIR = os.path.expanduser("~/Library/Application Support/Steam/steamapps/common/Sid Meier's Civilization V")

# Directories that need to be copied under the Civ5 installation path
DIR_COPY = [
]

# Directories containing files that need to be replaced, indicated by relative path to current working directory
DIR_REPLACE = [
	"../Builtin"
]

# Directories containing the mod to be copied
DIR_MOD = os.path.expanduser("~/Documents/My Games/Sid Meier's Civilization 5/MODS/")

MOD_NAME = "CUHKGEFWorldHistory (v 1)"

TMP_DIR = "./tmp"

# ---------- End of Settings Section ---------- #

VERSION_NUMBER = input("Version number [e.g. v0.3]: ")

ZIP_NAME = str(VERSION_NUMBER) + ".zip"

os_version = platform.system().lower()

if __name__ == "__main__":
	files_copied = []
	files_replaced = []

	if not io_utils.verify_civ5_installation_path(CIV5_ROOT_DIR):
		print("Cannot detect civ5 installation in the specified path, abort")
		exit(-1)

	if os.path.exists(TMP_DIR):
		shutil.rmtree(TMP_DIR)

	io_utils.make_sure_path_exists(os.path.join(TMP_DIR, "basegame"))
	for dir_path in DIR_COPY:
		src_dir = os.path.join(CIV5_ROOT_DIR, io_utils.CIV5_ROOT_OFFSET[os_version], dir_path)
		target_dir = os.path.join(TMP_DIR, "basegame", dir_path)
		copy_tree(src_dir, target_dir)
		files_copied.append(dir_path.replace("\\", "/"))

	for dir_path in DIR_REPLACE:
		io_utils.merge_dir(dir_path, os.path.join(TMP_DIR, "basegame"))
		
		for root, subdirs, files in os.walk(dir_path):
			for file in files:
				files_replaced.append(os.path.relpath(os.path.join(root, file), dir_path).replace("\\", "/"))

	src_moddir = os.path.join(DIR_MOD, MOD_NAME)
	target_moddir = os.path.join(TMP_DIR, MOD_NAME)
	try:
		copy_tree(src_moddir, target_moddir)
	except:
		print("Cannot detect built mod files under 'MyGames', build the solution using ModBuddy first")
		exit(-1)

	with open(os.path.join(TMP_DIR, "modinfo.json"), "w") as f:
		modinfo = {
			"version": VERSION_NUMBER,
			"files_copied": files_copied,
			"files_replaced": files_replaced,
			"modname": MOD_NAME
		}
		json.dump(modinfo, f, indent = 4)

	io_utils.zipdir(TMP_DIR, ZIP_NAME)
	shutil.rmtree(TMP_DIR)
	print("Done")