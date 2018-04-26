import sys
from cx_Freeze import setup, Executable

# Dependencies are automatically detected, but it might need fine tuning.
build_exe_options = {
}

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None
if sys.platform == "win32":
	base = "Win32GUI"

setup(  name = "Civ5 Mod Installer",
		version = "1.0",
		description = "A helper tool to install the Civ5 Mod.",
		options = {"build_exe": build_exe_options},
		executables = [Executable("installer.py", base = base)])