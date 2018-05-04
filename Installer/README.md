## Dependencies
- Python 3
- cxFreeze (for compiling executable for MacOS)
- pyinstaller (for compiling executable for Windows)

## Installer Compilation
1. Clone the repository on the target platform, and install the required dependencies.
2. Change to this directory and issue the command `make {OS}`, where `OS` must be `windows` or `mac`.

## Packing the Mod into a Zip
1. Build the solution in ModBuddy Solution Explorer.
2. Modify `build_zip.py` to configure 

   a. the path to the Civilization V base game, 
   
   b. directories that contains files to copy/replace, 
   
   c. the directory containing the mod built by ModBuddy,
   
   d. name of the mod.
   
3. Issue the command `python build_zip.py` and enter the version number.
4. A zip file named `{VERSION_NUMBER}.zip` should be generated.

## Making a New Version Available to the Installer
1. Upload the zip file to anywhere stable and accessible on the Internet. (e.g. the Github release page).
2. Contact Clark to update the Json file [civ5-versions.html](https://clarkwkw.github.io/civ5-versions.html).
