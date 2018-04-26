import sys
from cx_Freeze import setup, Executable
import os

# Dependencies are automatically detected, but it might need fine tuning.
build_exe_options = {
	"include_files": [
	]	
}

# GUI applications require a different base on Windows (the default is for a
# console application).
base = None
if sys.platform == "win32":
	base = "Win32GUI"
	PYTHON_INSTALL_DIR = os.path.dirname(os.path.dirname(os.__file__))
	os.environ['TCL_LIBRARY'] = os.path.join(PYTHON_INSTALL_DIR, 'tcl', 'tcl8.6')
	os.environ['TK_LIBRARY'] = os.path.join(PYTHON_INSTALL_DIR, 'tcl', 'tk8.6')
	build_exe_options["include_files"].extend([
		os.path.join(PYTHON_INSTALL_DIR, 'DLLs', 'tk86t.dll'),
		os.path.join(PYTHON_INSTALL_DIR, 'DLLs', 'tcl86t.dll'),
	])

setup(  name = "Civ5 Mod Installer",
		version = "1.0",
		description = "A helper tool to install the Civ5 Mod.",
		options = {"build_exe": build_exe_options},
		executables = [Executable("installer.py", base = base)])