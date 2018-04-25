'''
Prerequisite:
1. Run the Multiplayer Mod DLC-hack, you can find the details at 
   https://forums.civfanatics.com/threads/mpmpm-multiplayer-mod-dlc-hack-updated.533238/
2. Configure the civ5 installation path and other settings in below
'''

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

ZIP_NAME = "GECiv5Mod.zip"

TMP_DIR = "./tmp"

import zipfile
import io_utils
from distutils.dir_util import copy_tree
import shutil
import os
from os.path import dirname

if __name__ == "__main__":

	CIV5_ROOT_DIR = CIV5_ROOT_DIR.rstrip("/")
	if not io_utils.verify_civ5_installation_path(CIV5_ROOT_DIR):
		print("Cannot detect civ5 installation in the specified path, abort")
		exit(-1)

	io_utils.make_sure_path_exists(TMP_DIR)
	for dir_path in FROM_CIV5_DIR:
		src_dir = CIV5_ROOT_DIR + "/" + dir_path
		target_dir = TMP_DIR + "/" + dir_path
		copy_tree(src_dir, target_dir)

	for dir_path in FROM_LOCAL_DIR:
		for item in os.listdir(dir_path):
			src = os.path.join(dir_path, item)
			target = os.path.join(TMP_DIR, item)
			if os.path.isdir(src):
				copy_tree(src, target)
			else:
				shutil.copy2(src, target)

	io_utils.zipdir(TMP_DIR, ZIP_NAME)