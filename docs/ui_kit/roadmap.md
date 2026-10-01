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
`EditorPlugin`: `ui_kit.gd` calls `add_autoload_singleton()` in
`_enable_plugin()` and `remove_autoload_singleton()` in `_disable_plugin()`
— the enable/disable hooks, which run once each. Not
`_enter_tree()`/`_exit_tree()`, which fire on every editor restart and would
strip the autoload back out of the consumer's `project.godot` every time the
editor closes. Installing is ticking a checkbox.

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
- [x] Write down the public API you want (`UIPalette`, `UIButton`,
      `UIInput.get_active_device()`, template names) before writing any
      internals.
- [x] `addons/ui_kit/plugin.cfg` + an empty `ui_kit.gd`.
- [x] **Done when:** the API notes exist (this file + `api_design.md`) and
      the addon shows up under `Project Settings > Plugins`.

### Phase 1 — Tokens & theme generation
- [x] `UIPalette`: colors with names by role (background, surface, text
      primary/secondary, accent, info/warning/error/critical).
- [x] `UITypography`: bundled fonts + sizes (heading, body, button label,
      caption).
- [x] A builder that writes a `UIPalette` + `UITypography` pair into a
      `Theme`'s Type Variations.
- [x] **Done when:** `demo/ui_kit/theming/` holds a plain `Button` and `Panel` with
      no scripts, and swapping the palette in the inspector re-skins both
      live.

### Phase 2 — Input-device switching
- [x] First do it the naive way by hand (guess from
      `Input.get_connected_joypads().size()`) so you see the problem
      yourself. It lives on in the demo as the top row, next to the real
      answer.
- [x] `UIInput` autoload: `get_active_device() -> UIInputDevice.Kind` and a
      `device_changed(device: UIInputDevice.Kind)` signal. The enum sits in
      its own `UIInputDevice` class, because GDScript will not let the
      autoload's script declare a `class_name` matching the autoload name.
- [x] Register it from `ui_kit.gd`.
- [x] **Done when:** `demo/ui_kit/input_switching/` shows a label that updates the
      moment you touch a key, the mouse, a gamepad, or the screen — with no
      setup beyond enabling the plugin.

### Phase 3 — Component kit
- [x] Type Variations for `Button` (primary/secondary/icon), `CheckBox`,
      `HSlider`/`VSlider`, `Panel`. Native nodes, no subclasses. Two
      surprises: `CheckBox` has `checkbox_checked_color`, so the tick glyphs
      take the palette with no textures of our own; a slider's grabber is an
      icon Godot does *not* modulate, so the builder draws that one circle
      from the palette instead.
- [x] `UIFocusPrompt`: one overlay that reads
      `UIInput.device_changed` + `gui_get_focus_owner()` and draws the
      right glyph. Covers every component in one place. Glyphs live in a
      swappable `UIPromptSet`; an empty slot means "no prompt on this
      device".
- [x] `UIButton`: the only real component script — a variation enum instead
      of a mistypeable string, and the minimum touch target a `Theme` cannot
      express.
- [x] **Done when:** `demo/ui_kit/components/` shows the whole kit and is fully
      navigable by keyboard, gamepad, and touch.

### Phase 4 — Responsive breakpoints
- [x] First break it by hand: a fixed layout that overflows in mobile
      portrait. It stays in the demo as row 1.
- [x] `UIBreakpoints` autoload: `get_active_breakpoint() -> StringName`
      and a `breakpoint_changed(size_class: StringName)` signal — the
      parameter cannot be called `breakpoint`, which is a GDScript keyword.
- [x] Register it from `ui_kit.gd` next to `UIInput`, along with a
      `ui_kit/breakpoints/desktop_min_short_side` project setting so the
      threshold is retunable without editing the addon.
- [x] Let scenes react with native containers only — `FlowContainer` to
      wrap, `BoxContainer.vertical` toggled. No custom `Container`.
- [x] **Done when:** `demo/ui_kit/responsive/` works in mobile portrait, mobile
      landscape, and a desktop window.

Two things the plan had wrong, both found by running it:

- **Measure the window, not the viewport.** The obvious source is
  `get_visible_rect()`, and it cannot work: under a `canvas_items` stretch
  mode with an `expand` aspect, the canvas keeps the project's base width
  and grows only in the other direction, so its shorter side barely moves
  however the screen is resized. `UIBreakpoints` reads the window instead,
  divided by `DisplayServer.screen_get_scale()` — without that divisor every
  modern phone reports 1080-plus pixels on its short side and classifies as
  a desktop.
- **`HBoxContainer` refuses to be flipped.** `BoxContainer.vertical` is
  settable, but `HBoxContainer` and `VBoxContainer` exist precisely to lock
  the orientation and push an error when you assign it. A row that has to
  become a column must be a plain `BoxContainer`.

### Phase 5 — Menu templates
- [x] `main_menu/`, `pause_menu/`, and `settings_menu/` under
      `addons/ui_kit/templates/`, built from the Phase 3 kit inside
      `Container`s. Override `focus_neighbor_*` only where the automatic
      order is wrong — which turned out to be nowhere. `tests/ui_kit/`
      asserts the computed order instead of trusting it.
- [x] Touch-friendly hit areas via `custom_minimum_size`, with a test that
      walks all three templates and fails on any focusable control shorter
      than `UIMetrics.MIN_TOUCH_TARGET`.
- [x] `pause_menu`: `PROCESS_MODE_ALWAYS` + `get_tree().paused = true`.
      Nothing custom.
- [x] Put a palette picker in the settings menu, as a live demo of Phase 1.
      A row of buttons rather than an `OptionButton`: a popup is a second
      surface to theme, costs an extra press on a pad, and hides the choices
      until opened.
- [x] **Done when:** `demo/ui_kit/showcase/` chains all three screens, navigable by
      keyboard, gamepad, and touch, with the active-device indicator
      visible.

One decision worth writing down: the templates set no `theme` on their own
roots. Theme lookup walks up the tree, so they inherit the game's — which is
what makes them templates rather than a second skin to keep in sync. The
cost is that opening one on its own in the editor shows it unstyled.

### Phase 6 — Cross-platform polish
- [x] Set `FontVariation.fallbacks` on the bundled fonts. `fonts/ui_sans.tres`
      and `fonts/ui_sans_bold.tres` wrap the two faces, with the bold one
      falling through to the regular — a replacement display font missing
      digits or punctuation still renders. Coverage the kit cannot ship
      (Noto Sans CJK is tens of megabytes) goes in
      `UITypography.font_fallbacks`, so it is configured in the consumer's
      own resource and applies to their fonts as well as the bundled ones.
      *Still to check on a web export.*
- [x] Apply `DisplayServer.get_display_safe_area()` as margin on the
      templates, through `UISafeArea`. Two details the plan did not have:
      the safe area is a *rect* and margins are *insets*, so it has to be
      inverted against the screen size; and it is measured in screen pixels
      while a margin constant is in canvas units, which a `canvas_items`
      stretch mode makes different sizes.
- [ ] Export and check by hand on web, one mobile target, and
      Windows/Steam. Input switching and breakpoints must work on all
      three. **Not done — needs export templates and real devices.** The
      three things that can only be confirmed there: the bundled font
      actually reaching a web build, `screen_get_scale()` reporting a real
      factor on Android or iOS (without it a phone classifies as a desktop),
      and the safe-area margins against a real notch.
- [x] A few tests in `tests/ui_kit/` for `UIInput` edge cases (gamepad unplugged
      mid-game, two gamepads). Both are in `test_ui_input.gd`; see
      [`testing.md`](testing.md) for the whole suite.
- [x] Install on a clean project: copy `addons/ui_kit/`, enable the plugin,
      confirm both autoloads appear with no manual setup. Automated as
      `tests/ui_kit/clean_install_check.sh`, which scaffolds a throwaway
      project and ticks the checkbox for real. Worth knowing:
      `add_autoload_singleton()` persists a `uid://` reference in Godot 4.7,
      not a path — so grepping `project.godot` for the script path finds
      nothing, and moving the addon folder does not break the autoload.
- [ ] **Done when:** the addon works standalone on all three targets above.
      Everything that can be checked on a desktop is checked, by 161 headless
      assertions plus the clean-install script; the three exports are what
      remains.

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
9. Why register the autoloads from `ui_kit.gd` instead of documenting
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
