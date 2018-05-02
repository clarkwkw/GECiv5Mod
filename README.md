# GECiv5Mod
Creating a Mod for Civilization V for general education.

## Development
1. Clone the repository.
2. Open `Civ5Playground.civ5sln` with ModBuddy.
3. In Solution Explorer, right click on the solution, click `Build Solution` or just press `Ctrl + Shift + B`.
4. Copy everything under `Builtin` to the Civilization V installation path.
5. In Steam, launch the game Sid Meier's Civilization V.
6. Navigate to [Mods], enable the mod `Civ5 Playground`, click [Next], and launch a single player game
7. The mod should be activiated in the game.

**Note**: 
1. If you want to check the debugging message / lua console log, launch FireTuner before launching the game in Steam.
2. If you want to update the maps, place the map files under `Buildin/Assets/Maps` and update the default map name in `Builtin/Assets/UI/FrontEnd/SinglePlayer.lua`.

## Installation
Please follow the instructions at https://github.com/clarkwkw/GECiv5Mod/releases/tag/v0.0.

## Known Issues
1. `Events.ActivePlayerTurnStart` does not trigger any listener in the first turn of every player.
