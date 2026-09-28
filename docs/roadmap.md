# Roadmap

Plan for building UI Kit: a UI kit for Godot you can drop into any new
project. It gives you themed components, ready-made menu screens, and
automatic keyboard/gamepad/touch switching, so you don't rebuild your UI
from zero every time.

## How It Works

UI Kit leans on what Godot already does and only fills the gaps.

**Theming from tokens.** Godot has Theme Type Variations (named styles like
`PrimaryButton` on top of `Button`), but they can't share a color. To change
your accent color you edit the same hex in every `StyleBoxFlat`, one by one.
So: `UIPalette` + `UITypography` hold the colors and fonts once, and a
builder writes them into the Type Variations. Re-skinning the game becomes a
few field edits in one resource.

**Input-device detection.** Godot has no idea which device the player is
using right now. The common trick, `Input.get_connected_joypads().size() > 0`,
is wrong as soon as a gamepad is plugged in but not used. So: the `UIInput`
autoload watches real `_input(event)` events, remembers the *last* device
used, and emits `device_changed(device)` only when it actually changes.

**Components with no scripts.** A native `Button`/`CheckBox`/`Slider`/`Panel`
with a Type Variation already handles hover, pressed, disabled, and focus by
itself. So most of the kit is just styles. Only two things need code:
`UIFocusPrompt`, one overlay that draws the right button glyph over
whatever has focus, and `UIButton`, for the little that styling can't do.

**Named breakpoints.** Godot's stretch modes scale a layout but never
rearrange it — a row of buttons that fits a Steam window overflows on a
phone in portrait. Godot *does* have containers that rearrange
(`FlowContainer` wraps, `BoxContainer.vertical` toggles at runtime), it just
has no idea what size class the screen is. So: `UIBreakpoints` reports
`mobile_portrait` / `mobile_landscape` / `desktop` and nothing more. The
native containers do the rearranging.

**Menu templates.** Godot auto-computes `focus_neighbor_*` from node
positions, so navigation usually works just by using a `Container`. The real
work is fixing the cases it gets wrong, keeping touch targets big enough,
and shipping the three screens already built. Templates are plain scenes
made from the kit, so they get theming, input switching, and responsive
layout for free.

**One-click install.** Normally a consumer has to open
`Project Settings > Autoload` and type each singleton path by hand — get it
wrong and the autoload silently doesn't exist. So UI Kit ships as a real
`EditorPlugin`: `plugin.gd` calls `add_autoload_singleton()` in
`_enter_tree()` and `remove_autoload_singleton()` in `_exit_tree()`.
Installing is ticking a checkbox.

## What To Learn First

- [ ] `Control` nodes: anchors, containers, `focus_mode` and
      `focus_neighbor_*` (when the automatic navigation is enough, and when
      you must override it)
- [ ] Containers that rearrange on their own: `HFlowContainer`/
      `VFlowContainer` and `BoxContainer.vertical`
- [ ] Theme Type Variations and `StyleBoxFlat` per state (normal, hover,
      pressed, disabled, focus); how theme lookup walks up the tree
- [ ] `Resource` + `class_name` for custom data, instead of editing `.tres`
      by hand
- [ ] Input events: `InputEventKey`, `InputEventMouseButton`,
      `InputEventJoypadButton`/`Motion`, `InputEventScreenTouch`/`Drag`, and
      `Input.joy_connection_changed`
- [ ] `PROCESS_MODE_ALWAYS` + `get_tree().paused` — Godot's own pause system
- [ ] Viewport sizing and stretch modes
- [ ] Signals and `Callable` for reacting to theme and device changes
- [ ] `EditorPlugin` lifecycle and `add_autoload_singleton()` /
      `remove_autoload_singleton()`
- [ ] `FontVariation.fallbacks` and `DisplayServer.get_display_safe_area()`

## Phases

### Phase 0 — Baseline
- [ ] Write down the public API you want (`UIPalette`, `UIButton`,
      `UIInput.get_active_device()`, template names) before writing any
      internals.
- [ ] `addons/ui_kit/plugin.cfg` + an empty `plugin.gd`.
- [ ] **Done when:** the API notes exist (this file + `api_design.md`) and
      the addon shows up under `Project Settings > Plugins`.

### Phase 1 — Tokens & theme generation
- [ ] `UIPalette`: colors with names by role (background, surface, text
      primary/secondary, accent, info/warning/error/critical).
- [ ] `UITypography`: bundled fonts + sizes (heading, body, button label,
      caption).
- [ ] A builder that writes a `UIPalette` + `UITypography` pair into a
      `Theme`'s Type Variations.
- [ ] **Done when:** `demo/theming/` holds a plain `Button` and `Panel` with
      no scripts, and swapping the palette in the inspector re-skins both
      live.

### Phase 2 — Input-device switching
- [ ] First do it the naive way by hand (guess from
      `Input.get_connected_joypads().size()`) so you see the problem
      yourself.
- [ ] `UIInput` autoload: `get_active_device() -> InputDevice` and a
      `device_changed(device: InputDevice)` signal.
- [ ] Register it from `plugin.gd`.
- [ ] **Done when:** `demo/input_switching/` shows a label that updates the
      moment you touch a key, the mouse, a gamepad, or the screen — with no
      setup beyond enabling the plugin.

### Phase 3 — Component kit
- [ ] Type Variations for `Button` (primary/secondary/icon), `CheckBox`,
      `HSlider`/`VSlider`, `Panel`. Native nodes, no subclasses.
- [ ] `UIFocusPrompt`: one overlay that reads
      `UIInput.device_changed` + `gui_get_focus_owner()` and draws the
      right glyph. Covers every component in one place.
- [ ] `UIButton`: the only real component script, for what styling can't
      do (like a per-variant icon).
- [ ] **Done when:** `demo/components/` shows the whole kit and is fully
      navigable by keyboard, gamepad, and touch.

### Phase 4 — Responsive breakpoints
- [ ] First break it by hand: a fixed layout that overflows in mobile
      portrait.
- [ ] `UIBreakpoints` autoload: `get_active_breakpoint() -> StringName`
      and a `breakpoint_changed(breakpoint: StringName)` signal.
- [ ] Register it from `plugin.gd` next to `UIInput`.
- [ ] Let scenes react with native containers only — `FlowContainer` to
      wrap, `BoxContainer.vertical` toggled. No custom `Container`.
- [ ] **Done when:** `demo/responsive/` works in mobile portrait, mobile
      landscape, and a desktop window.

### Phase 5 — Menu templates
- [ ] `templates/main_menu/`, `templates/pause_menu/`,
      `templates/settings_menu/`, built from the Phase 3 kit inside
      `Container`s. Override `focus_neighbor_*` only where the automatic
      order is wrong.
- [ ] Touch-friendly hit areas via `custom_minimum_size`.
- [ ] `pause_menu`: `PROCESS_MODE_ALWAYS` + `get_tree().paused = true`.
      Nothing custom.
- [ ] Put a palette picker in the settings menu, as a live demo of Phase 1.
- [ ] **Done when:** `demo/showcase/` chains all three screens, navigable by
      keyboard, gamepad, and touch, with the active-device indicator
      visible.

### Phase 6 — Cross-platform polish
- [ ] Set `FontVariation.fallbacks` on the bundled fonts and check it on a
      web export.
- [ ] Apply `DisplayServer.get_display_safe_area()` as margin on the
      templates.
- [ ] Export and check by hand on web, one mobile target, and
      Windows/Steam. Input switching and breakpoints must work on all
      three.
- [ ] A few tests in `tests/` for `UIInput` edge cases (gamepad unplugged
      mid-game, two gamepads).
- [ ] Install on a clean project: copy `addons/ui_kit/`, enable the plugin,
      confirm both autoloads appear with no manual setup.
- [ ] **Done when:** the addon works standalone on all three targets above.

## Questions To Check Yourself

1. Why build the `Theme` from a token resource instead of editing theme
   overrides in the inspector? What breaks when you re-skin a whole game?
2. What's wrong with `Input.get_connected_joypads().size() > 0`, and what
   does `UIInput` track instead?
3. If a gamepad is plugged in but the player is typing, what should
   `get_active_device()` return, and why?
4. Why do most components need no script? What does a Type Variation
   already handle, and what's left for `UIFocusPrompt`/`UIButton`?
5. Why one shared focus prompt instead of `device_changed` logic in every
   component?
6. Why does `UIBreakpoints` only report the active breakpoint and never
   rearrange anything?
7. Why ship the menu templates in the addon instead of letting each project
   wire its own navigation?
8. Why bundle fonts inside `addons/ui_kit/`, and why does that matter most
   for the web export?
9. Why register the autoloads from `plugin.gd` instead of documenting
   "add these by hand"? What fails silently if the path is mistyped?

## Done Criteria

- You can explain the token → `Theme` pipeline and the device-detection
  approach from memory.
- Component kit, responsive layout, input switching, and all three
  templates are finished.
- A brand-new project can copy `addons/ui_kit/`, enable the plugin, drop in
  the templates, and ship a themed menu flow that works with keyboard,
  gamepad, and touch — no new UI code, no manual autoloads.
- Verified on web, one mobile export, and Windows/Steam.

## References

- [Control node UI tutorials](https://docs.godotengine.org/en/stable/tutorials/ui/index.html)
- [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html)
- [GUI skinning (Theme)](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html)
- [Theme Type Variations](https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html)
- [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html)
- [InputEvent class reference](https://docs.godotengine.org/en/stable/classes/class_inputevent.html)
- [Multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Making plugins (EditorPlugin)](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html)
