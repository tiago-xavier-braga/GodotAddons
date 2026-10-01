# API Design — Phase 0 Baseline

Sketch of UI Kit's public API surface, written before any addon internals
(see [`roadmap.md`](roadmap.md), Phase 0). Names follow GDScript conventions
(`snake_case` for members, `PascalCase` for classes) and the architecture
decisions the roadmap has already made (token-driven `Theme` generation, an
`UIInput` autoload, breakpoint-based responsive layout).

This is notes, not code — nothing here needs to compile yet.

## 1. Design tokens & Theme generation (Phase 1)

```gdscript
class_name UIPalette
extends Resource

@export var background: Color
@export var surface: Color
@export var text_primary: Color
@export var text_secondary: Color
@export var accent: Color
@export var info: Color
@export var warning: Color
@export var error: Color
@export var critical: Color
```

```gdscript
class_name UITypography
extends Resource

@export var font_default: Font
@export var font_heading: Font
@export var size_body: int = 16
@export var size_heading: int = 24
@export var size_caption: int = 12
```

```gdscript
UIThemeBuilder.apply(theme: Theme, palette: UIPalette, typography: UITypography) -> void
```

- `apply()` writes into the `Theme`'s existing Theme Type Variations
  (`PrimaryButton`, `SecondaryButton`, `UIPanel`, ...) instead of
  generating a new `Theme` from scratch — the variations themselves are
  still defined in the editor (the native Theme editor), only the values
  come from the token.
- Semantic roles (`background`, `accent`, `error`, ...) rather than raw
  color slots, so a component only ever asks for "the accent color", never
  a hardcoded hex.
- Default values ship as a `UIPalette`/`UITypography` pair matching
  [`design.md`](design.md), usable as-is or replaced wholesale per
  project.

## 2. Input-device detection (Phase 2)

```gdscript
enum InputDevice { KEYBOARD_MOUSE, GAMEPAD, TOUCH }

UIInput.get_active_device() -> InputDevice
signal UIInput.device_changed(device: InputDevice)
```

- Autoload singleton; listens in `_input(event)` and classifies `event` by
  type (`InputEventKey`/`InputEventMouseButton` → `KEYBOARD_MOUSE`,
  `InputEventJoypadButton`/`InputEventJoypadMotion` → `GAMEPAD`,
  `InputEventScreenTouch`/`InputEventScreenDrag` → `TOUCH`), updating the
  active device and emitting the signal only on an actual change.
- `InputEventJoypadMotion` needs a deadzone threshold so idle stick drift
  doesn't fight a keyboard/mouse player — open question below.

## 3. Themed components (Phase 3)

```gdscript
class_name UIFocusPrompt
extends CanvasLayer

func _ready() -> void:
	UIInput.device_changed.connect(_on_device_changed)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
```

- Checkbox/slider/panel: no script at all, just the matching Theme Type
  Variation applied to the native node (`CheckBox`, `HSlider`/`VSlider`,
  `Panel`) — per-state `StyleBox` already covers
  hover/pressed/disabled/focus.
- `UIFocusPrompt` is the one place that reacts to
  `UIInput.device_changed`, using `Viewport.gui_focus_changed` (native)
  to know who currently has focus and draw the right glyph over it — not
  a script per component.

```gdscript
class_name UIButton
extends Button

@export var variant: Variant  # PRIMARY / SECONDARY / ICON — enum TBD
```

- The one real component script, only where there's logic beyond styling
  (e.g. a dynamic icon per variant). `extends Button` instead of
  reimplementing input/focus, and reads the Type Variation applied by
  Phase 1 instead of hardcoding a `StyleBox`.

## 4. Responsive breakpoints (Phase 4)

```gdscript
enum Breakpoint { MOBILE_PORTRAIT, MOBILE_LANDSCAPE, DESKTOP }

UIBreakpoints.get_active_breakpoint() -> StringName
signal UIBreakpoints.breakpoint_changed(breakpoint: StringName)
```

- Autoload singleton, same shape as `UIInput`: reads the viewport size
  on `_notification(NOTIFICATION_RESIZED)`, picks the matching named
  breakpoint, and emits the signal only on an actual change.
- Doesn't restructure anything itself — each scene decides what to do
  with the active breakpoint using Godot's native containers
  (`FlowContainer` for wrapping, `BoxContainer.vertical` toggled at
  runtime), instead of a custom `Container` reimplementing what they
  already do.

## 5. Full-screen templates (Phase 5)

```gdscript
addons/ui_kit/templates/main_menu/main_menu.tscn
addons/ui_kit/templates/pause_menu/pause_menu.tscn
addons/ui_kit/templates/settings_menu/settings_menu.tscn
```

- Plain scenes, not scripts with a public API — "usage" is instancing
  them and connecting their signals (`UIPauseMenu.resume_pressed`,
  `UISettingsMenu.palette_changed(palette: UIPalette)`, ...).
- Built entirely from Phase 3 components + Phase 4 layout, so they
  inherit theming and input switching for free instead of reimplementing
  either.
- Focus navigation comes from Godot's native `focus_neighbor_*`
  auto-computation just by sitting inside a `Container` — explicit
  `focus_neighbor_*` only where the auto-computation gets it wrong.
  `pause_menu.tscn` uses `process_mode = PROCESS_MODE_ALWAYS` +
  `get_tree().paused = true` (native), with no pause system of its own.

## Open questions to settle before Phase 1

- Exact thresholds (in px) for each `Breakpoint` — probably `@export` on
  the `UIBreakpoints` autoload, not hardcoded, so a project can adjust
  without editing the addon.
- Deadzone threshold for `InputEventJoypadMotion` before it counts as
  "gamepad input" for device-switching purposes.
- Whether `UIButton` variants (`PRIMARY`/`SECONDARY`/`ICON`) are one
  script with an `@export` enum, or one base class with a subclass per
  variant — the same choice applies to every other themed component.
- How a component decides which prompt glyph set to show per gamepad
  brand (Xbox/PlayStation/Switch) — out of scope for Phase 2, but the
  `InputDevice` enum shape should leave room for it later.

## What shipped differently

This file is the Phase 0 sketch and is left as written, so the guesses stay
visible. Four of them did not survive contact with the engine — the code is
the reference now, and `roadmap.md` records why each changed.

- **`UIInput` is the autoload; `UIInputDevice` is the type.** GDScript refuses
  a `class_name` that matches an autoload name, and a script without a
  `class_name` cannot be used as a static type. So the enum lives in its own
  class: `UIInputDevice.Kind`, not `UIInput.InputDevice`.
- **`breakpoint_changed(size_class:)`, not `(breakpoint:)`.** `breakpoint` is a
  GDScript keyword. The names themselves are constants on `UIBreakpoint`, and
  the threshold is measured against the *window* in density-independent pixels
  rather than the viewport — which cannot work, for the reason the roadmap
  gives.
- **`UIButton.variation`, not `variant`.** `Variant` is a built-in type name.
  The enum is `UIButton.Variation`, and the script's remaining job turned out
  to be the minimum touch target, which a `Theme` cannot express.
- **Variation names all carry the `UI` prefix** — `UIPrimaryButton`,
  `UISecondaryButton`, `UIIconButton`, `UIPanel`, `UIHeading`, `UIBody`,
  `UICaption`, collected in `UIVariants`. A `Theme` merged into a project's own
  shares that namespace, so they are public names like any other.

Two things the sketch got right and are worth noting as settled: most
components need no script at all, and `UIFocusPrompt` as one overlay rather
than per-component logic is what makes that possible — including for a
project's own controls, which the kit has never seen.
