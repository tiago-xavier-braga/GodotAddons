# Roadmap

Plan for building UI Kit: a UI kit for Godot you can drop into any new
project. It gives you themed components, ready-made menu screens, and
automatic keyboard/gamepad switching, so you don't rebuild your UI
from zero every time.

## How It Works

> UI Kit leans on what Godot already does and only fills the gaps.

The first goal is to reuse the same UIs across N projects, taking advantage of the main menu,
settings menu, level select screen, and automatic keyboard/gamepad visual indicator switching.
I will create the prototype frames in Penpot, and through the MCP connection you will replicate
them in the project.

### Acceptance Criteria
- [ ] Does it switch automatically from keyboard to gamepad?
- [ ] Does it recognize PlayStation and Xbox controllers?
- [ ] Does the screen flow work?
- [ ] Can I click a button and open another screen?
- [ ] Can I move the plugin to another project and keep working?

## Phase 1 — Asset Collection & Prototyping
- [x] Collect input prompt icons
 
- [ ] Prototype the screens in Penpot
  - Boot & front-end
    - [ ] Splash / logos
    - [ ] Title screen ("Press any button")
    - [ ] Main menu
    - [ ] Save slots (new game / load game)
    - [ ] Difficulty select
    - [ ] Level select

    - [ ] Loading screen
  - Settings
    - [ ] Video / display
    - [ ] Audio
    - [ ] Controls & remapping
    - [ ] Gameplay
    - [ ] Accessibility
    - [ ] Language
  - In-game
    - [ ] HUD
    - [ ] Pause menu

    - [ ] Quest / objectives log
    - [ ] Dialogue box
    - [ ] Shop
    - [ ] Tutorial / hint overlay
    
  - End of run
    - [ ] Game over
    - [ ] Victory / results
    - [ ] Credits
  - Online & meta

    - [ ] Leaderboards
    - [ ] Achievements

  - System overlays
    - [ ] Confirmation dialog (quit, overwrite save)
    - [ ] Controller disconnected
    - [ ] Toast / notification

## Phase 2 — Coding & Rule Definitions

A rough direction, not a final design. Each script still needs its own design note before
it is written.

### Without a script (native Godot)
- [ ] Theme (`.tres`) built from the Penpot colors and fonts — styles every screen.
- [ ] Focus navigation between buttons through `Control` focus neighbors.
- [ ] Confirm/back/navigate through the built-in `ui_*` actions in the `InputMap`.

### Scripts
- [ ] `UIInput` (autoload) — detects the last device used (keyboard/mouse, gamepad,
  touch), identifies the gamepad brand (Xbox, PlayStation, Switch, Steam Deck...), and
  signals when it changes.
- [ ] `UIPromptSet` (resource) — maps each action to its icon for one device; one `.tres`
  per folder in `icons/`.
- [ ] `UIPromptIcon` (`TextureRect`) — shows the icon of one action for the current device
  and swaps it when `UIInput` signals a change.
- [ ] `UIScreenStack` (autoload) — opens a screen on top of the current one and closes it on
  back, so a button can open another screen and `ui_cancel` returns.
- [ ] `UIScreen` (`Control`) — base for every screen; declares which control gets focus when
  it opens.
- [ ] `UISettings` (autoload) — saves/loads the settings menu values (video, audio, language)
  to a `ConfigFile` and applies them.
- [ ] `ui_kit.gd` (`EditorPlugin`) — registers the autoloads when the plugin is enabled, so
  copying the folder into another project is enough.

### Rules
- [ ] Every public `class_name` and autoload uses the `UI` prefix.
- [ ] The addon only reads from `addons/ui_kit/`; nothing points to `demo/` or `assets/`.
- [ ] Icon folders and action names follow one fixed naming scheme that `UIPromptSet` relies on.

## Phase 3 — Building the Screens into the Plugin
- [ ] Build the Boot & front-end screens
- [ ] Build the Settings screens
- [ ] Build the In-game screens
- [ ] Build the End of run screens
- [ ] Build the Online & meta screens
- [ ] Build the System overlays

## Phase 4 — External Testing & Deploy
- [ ] Create a showcase scene with every screen
- [ ] Playtest with friends
- [ ] Test with different controllers
- [ ] Write the changelog for version 1.0.0
