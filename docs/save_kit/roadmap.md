# Roadmap

Plan for building Save Kit: one save system for every Godot game. Each game declares what it
saves in its own JSON file, and Save Kit keeps it in the browser's localStorage on the web and in
a `user://` file everywhere else, so the same game code saves on itch.io, CrazyGames, desktop and
Steam.

It was built inside He Who Loses Wins, its first game, and then moved here. GodotAddons holds the
source of truth: fix it here and re-copy it into the games.

## How It Works

> Save Kit turns the game's data into JSON and hands the text to a storage. The game never knows
> which storage it is.

```
SaveKit (autoload)   the game's data <-> JSON text
   └─ SaveStorage    keeps the text under the game's save key
        ├─ SaveWebStorage   localStorage          (web, picked automatically)
        ├─ SaveFileStorage  user://<key>.json     (desktop, mobile, Steam)
        └─ a project's own  CrazyGames SDK, Steam Remote Storage...
```

### Acceptance Criteria
- [ ] Web build: solve something, reload the tab, and it's still saved.
- [ ] Desktop: the same after closing and reopening the game.
- [ ] Private window or blocked storage: the game runs, a warning shows, progress lasts the
  session.
- [ ] A broken or hand-edited save doesn't crash: the game starts from the defaults and logs an
  error.
- [ ] A key added to the defaults file keeps the old progress and returns its default.
- [ ] A script set in `save_kit/custom_storage` is used instead of the automatic storage.
- [ ] Can I copy `addons/save_kit/` into another project and keep working?


## Using It in a Project

1. Copy `addons/save_kit/` and enable it under `Project Settings > Plugins`. It adds the
   `SaveKit` autoload and three settings:

   | Setting | Default | Purpose |
   | ------- | ------- | ------- |
   | `save_kit/save_key` | project name in snake_case | File name on desktop, localStorage key on the web |
   | `save_kit/defaults_file` | empty (required) | The game's JSON with every key and its default value |
   | `save_kit/custom_storage` | empty | A script that extends `SaveStorage`; empty picks one automatically |

   Never change `save_key` after release: every player's save is kept under it.

2. Write the defaults file. A number with a decimal point (`0.8`, `1.0`) is a float, one without
   (`1`) is an int:

   ```json
   { "current_level": 1, "unlocked_skins": [], "music_volume": 0.8 }
   ```

3. Use it:

   ```gdscript
   SaveKit.get_value("current_level")     # typed like its default: 1, not 1.0
   SaveKit.set_value("current_level", 2)  # memory only
   SaveKit.save()                         # writes now
   ```

   Save when something changes, not at quit: the web has no reliable quit event.

The saved text looks like `{ "data": { "current_level": 2, ... }, "version": 1 }`.

## Phase 1 — Core (inside He Who Loses Wins)

### Without a script (native Godot)
- [x] Configuration in Project Settings, registered by the plugin.
- [ ] Steam Cloud: Auto-Cloud on the `user://` file, set up in Steamworks. Steam games also turn
  on `application/config/use_custom_user_dir`.

### Scripts
- [x] `plugin.gd` (`EditorPlugin`) — adds the `SaveKit` autoload and registers the three
  settings.
- [x] `save_kit.gd` (autoload `SaveKit`) — picks the storage, reads the save, lays it over the
  game's defaults, and writes it back on `save()`.
- [x] `save_storage.gd` (`SaveStorage`, abstract) — what every storage does: `read(key)` and
  `write(key, text)`.
- [x] `save_file_storage.gd` (`SaveFileStorage`) — keeps the save in `user://<key>.json`.
- [x] `save_web_storage.gd` (`SaveWebStorage`) — keeps the save in localStorage, through a small
  JavaScript helper that turns browser errors into `""` or `false`.

### Rules
- Every public `class_name` and autoload uses the `Save` prefix.
- The addon only reads from `addons/save_kit/` and the game's defaults file.
- No SDK code in `save_kit`: a script that uses `Steam` doesn't compile in a project without
  GodotSteam.

## Phase 2 — First Game: He Who Loses Wins

Out of scope: settings (volume, difficulty), Steam Cloud, a reset-progress button.
Done when: in the web build, a solved puzzle is still solved after reloading the tab.

- [x] `resources/save_defaults.json` with `solved_puzzles`, added to the web export's include
  filter because Godot only exports resources by default.
- [x] Enable the plugin and set `save_kit/defaults_file`.
- [x] `GameSettings.is_solved(level)` and `mark_solved(level)` replace the session-only
  `solved_puzzles` array, storing ids from the file names (`puzzle_07`).
- [x] `PuzzleMenu` and `PuzzleController` use them.
- [x] Test the web build: the save shows under the `he_who_loses_wins` key in the browser's
  Local Storage.
- [x] Update `gdd.md` ("decided later") and `README.md` ("kept only until you close").

## Phase 3 — Move to GodotAddons
- [x] Copy `addons/save_kit/` and this file (to `docs/save_kit/roadmap.md`).
- [x] Add Save Kit to the addons table in the GodotAddons README.
- [x] He Who Loses Wins keeps its copy and re-copies to update.

## Known Risks
- **itch.io shares one domain across games.** The save key keeps their saves apart, but they
  share the browser's ~5 MB localStorage limit; when it's full, the write fails and progress
  lasts the session.
- **Browsers can block or wipe storage**: private windows, iframes with blocked storage, Safari
  after ~7 days without a visit, a player clearing site data.
- **Puzzle ids come from file names** (He Who Loses Wins): renaming a puzzle file loses its
  progress.
- **The defaults file must be in the export.** Check it's in the web build.
- **Only top-level values are typed.** Numbers inside arrays and dictionaries still come back as
  float.
- **Arrays and dictionaries come back by reference.** Changing one changes the save in memory even
  without `set_value`.
- **A broken save is overwritten** by the next `save()`, so its data is lost.

## Backlog
- SDK storages as their own addons that depend on Save Kit: `save_kit_crazy_games`,
  `save_kit_steam` (Remote Storage). The CrazyGames SDK must finish starting before it can read,
  so the first one will probably need `SaveKit` to load when the storage is ready instead of in
  `_init`.
- Check whether CrazyGames requires its SDK's data module for saving progress.
- Save slots, encryption, a reset-progress helper, Godot types in the JSON (`JSON.from_native`),
  typed values inside arrays, a temp file and rename for desktop writes, migration code that
  reads `version`.
