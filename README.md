# GECiv5Mod
Creating a Mod for Civilization V for general education

## Usage
1. Clone the repository
2. Open `Civ5Playground.civ5sln` with ModBuddy
3. In Solution Explorer, right click on the solution, click `Build Solution` or just press `Ctrl + Shift + B`
4. In Steam, launch the game Sid Meier's Civilization V
5. Navigate to [Mods], enable the mod `Civ5 Playground`, click [Next], and launch a single player game
6. The mod should be activiated in the game

Note: If you want to check the debugging message / lua console log, launch FireTuner before launching the game in Steam.

## Known Issues
1. `Events.ActivePlayerTurnStart` does not trigger any listener in the first turn of every player.
