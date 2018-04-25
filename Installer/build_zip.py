'''
Prerequisite:
1. Run the Multiplayer Mod DLC-hack, you can find the details at 
   https://forums.civfanatics.com/threads/mpmpm-multiplayer-mod-dlc-hack-updated.533238/
2. Configure the civ5 installation path and other settings in below
'''

# ------------------ Settings ------------------ #

# Installation Path of Civ5
CIV5_ROOT_DIR = "C:/Program Files (x86)/Steam/steamapps/common/Sid Meier's Civilization V"

# Directories that need to be copied under the Civ5 installation path
FROM_CIV5_DIR = [
	"Assets/DLC/MP_MODSPACK"
]

# Directories that need to be copied, indicated by relative path to current working directory
FROM_LOCAL_DIR = [
	"../Builtin"
]

TMP_DIR = "./tmp"

MODINFO_PATH = "Assets/DLC/MP_MODSPACK/modinfo.json"

# ---------- End of Settings Section ---------- #

VERSION_NUMBER = input("Version number [e.g. v0.3]: ")

ZIP_NAME = str(VERSION_NUMBER) + ".zip"

import zipfile
import io_utils
from distutils.dir_util import copy_tree
import shutil
import os
from os.path import dirname
import json

if __name__ == "__main__":

	CIV5_ROOT_DIR = CIV5_ROOT_DIR.rstrip("/")
	if not io_utils.verify_civ5_installation_path(CIV5_ROOT_DIR):
		print("Cannot detect civ5 installation in the specified path, abort")
		exit(-1)

	if os.path.exists(TMP_DIR):
		shutil.rmtree(TMP_DIR)

	io_utils.make_sure_path_exists(TMP_DIR)
	for dir_path in FROM_CIV5_DIR:
		src_dir = CIV5_ROOT_DIR + "/" + dir_path
		target_dir = TMP_DIR + "/" + dir_path
		copy_tree(src_dir, target_dir)

	for dir_path in FROM_LOCAL_DIR:
		io_utils.merge_dir(dir_path, TMP_DIR)

	with open(TMP_DIR + "/" + MODINFO_PATH, "w") as f:
		modinfo = {
			"version": VERSION_NUMBER
		}
		json.dump(modinfo, f)

	io_utils.zipdir(TMP_DIR, ZIP_NAME)
	shutil.rmtree(TMP_DIR)
	print("Done")