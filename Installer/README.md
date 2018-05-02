## Dependencies
- Python 3
- cxFreeze (for compiling executable for MacOS)
- pyinstaller (for compiling executable for Windows)

## Installer Compilation
1. Clone the repository on the target platform, and install the required dependencies.
2. Change to this directory and issue the command `make {OS}`, where `OS` must be `windows` or `mac`.

## Packing the Mod into a Zip
1. Build the solution in ModBuddy Solution Explorer.
2. In Steam, switch the language of Civilization V to Chinese (Traditional).
3. Launch FireTuner and Civilization V.
4. Make sure you have installed the mod `Multiplayer Mods Workaround` by subscribing it in [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=361391109).
5. Start a modded single player game, with only our mod and `Multiplayer Mods Workaround` activated.
6. Switch to FireTuner, navigate to the `Lua Console` tab.
7. Below the tab name, there is a dropdown menu. Select the one starts with `\Users\[yourName]\Documents`.
8. Make sure your antivirus software is off or else you need to wait for hours.
9. Type `CreateMP()` (case sensitive) into the command line at the bottom and press enter.
(It packs our mod into a DLC which is placed under `Steam\steamapps\common\sid meier's civilization v\Assets\DLC\MP_MODSPACK`.)
10. Once civ 5 begins working again, and if there are no errors noted in firetuner, exit out of civ 5 entirely. Remember to turn your antivirus back on!
11. Modify `build_zip.py` to configure the paths to Civilization V base game, directories that contains files to copy/replace, etc.
12. Issue the command `python3 build_zip.py` and enter the version number.
13. A zip file named `{VERSION_NUMBER}.zip` should be generated.

## Making a New Version Available to the Installer
1. Upload the zip file to anywhere stable and accessible on the Internet. (e.g. the release page).
2. Contact Clark.
