# UI Kit

A portable UI kit for the Godot Engine: themed components, ready-made menu
templates (main menu, pause, settings), and automatic keyboard/gamepad/touch
input switching — built to drop into new projects (web, mobile, Steam) without
rebuilding UI from scratch every time.

> **Status:** feature-complete and covered by 158 headless checks. What is
> left is device verification: the web, mobile and Windows exports in Phase 6
> of the
> [roadmap](https://github.com/tiago-xavier-braga/GodotAddons/blob/main/docs/ui_kit/roadmap.md) for the phased plan
> and the [API sketch](https://github.com/tiago-xavier-braga/GodotAddons/blob/main/docs/ui_kit/api_design.md) for the
> intended public surface.

## Why

Godot's `Control`/`Theme` system covers the primitives well, but every new
project rebuilds the same four things:

- **Design-token theming** — a `UIPalette`/`UITypography` resource pair feeds
  the whole `Theme`, instead of editing the same hex in dozens of overrides.
- **Automatic input-device switching** — `UIInput` tracks whether the player is
  on keyboard/mouse, gamepad, or touch from real input events, and the kit
  reacts to it.
- **Menu templates** — main menu, pause, and settings, already navigable by
  keyboard, gamepad, and touch.
- **Responsive layout** — `UIBreakpoints` reports the active screen class so
  native containers can restructure the UI, not just scale it.

## Requirements

- Godot `4.7`

## Safe areas

Each template's outer container is a `UISafeArea`, so content stays clear of
camera cut-outs, rounded corners and gesture bars without you thinking about
it. On a screen with nothing in the way it is an ordinary `MarginContainer`
using its `minimum_margin`. Use it in your own screens the same way.

## Fonts and missing glyphs

The kit bundles Noto Sans, because a web export has no system font to fall
back on — a character the font lacks is a visible box, not a substitution. For
scripts Noto Sans does not cover, add a font to `font_fallbacks` on your
`UITypography`: it applies to every text item in the theme at once, including
fonts of your own that replace the bundled ones.

Noto Sans CJK is tens of megabytes, which is why it is not bundled for
everyone.

## Install

Copy this folder into `addons/ui_kit/` in the target project and enable
**UI Kit** under `Project Settings > Plugins`. Enabling it registers the
`UIInput` and `UIBreakpoints` autoloads — there is nothing to add by hand.

## Theming

Point a scene root's `theme` at `theme/default_theme.tres` and every stock
`Button`, `CheckBox`, `HSlider`, `Panel` and `Label` under it is styled, with
no scripts involved. The variations are named in
[`theme/ui_variants.gd`](theme/ui_variants.gd):

| Variation            | Base type | Use                              |
| -------------------- | --------- | -------------------------------- |
| `UIPrimaryButton`    | `Button`  | the one action a screen wants    |
| `UISecondaryButton`  | `Button`  | outlined, quieter alternative    |
| `UIIconButton`       | `Button`  | square, icon only                |
| `UIPanel`            | `Panel`   | a raised card on the background  |
| `UIHeading`          | `Label`   | screen titles                    |
| `UIBody`             | `Label`   | ordinary text                    |
| `UICaption`          | `Label`   | secondary, smaller text          |

To re-skin, duplicate `theme/default_palette.tres`, edit the colors, and drop
it into the theme's `palette` field. `UITheme` regenerates every style box from
it — there is no "rebuild" step, and no hex to find twice.

`theme/default_theme.tres` stores only the two token references; the style
boxes are generated on load, which is why the file is a dozen lines.

## Input-device switching

`UIInput` reports which device the player is using *right now*, from real input
events rather than from what is plugged in:

```gdscript
if UIInput.get_active_device() == UIInputDevice.Kind.GAMEPAD:
    show_pad_hint()

UIInput.device_changed.connect(_on_device_changed)
```

It only emits `device_changed` when the answer actually changes, and it
deliberately ignores three things that would otherwise make it lie: events
Godot synthesised from another device (a tap becomes a mouse click whenever
`emulate_mouse_from_touch` is on, which is the default), analog stick drift
below the deadzone, and mouse movement of a pixel or two.

## Components

Most of the kit is styling, so a stock `Button`, `CheckBox`, `HSlider`, `Panel`
or `Label` with a variation set is a first-class component — there is no
subclass to remember. Two pieces do carry a script:

**`UIFocusPrompt`** — instance
`components/focus_prompt/ui_focus_prompt.tscn` once per screen. It draws the
active device's glyph beside whatever has focus, and that is the whole setup;
it needs no help from the controls it points at. Swap the artwork by pointing
its `prompts` field at your own `UIPromptSet`, and clear a slot in that
resource to show no prompt for that device.

**`UIButton`** — a `Button` that picks its variation from an enum
(`PRIMARY`/`SECONDARY`/`ICON`) instead of a free-text string, and holds itself
to `UIMetrics.MIN_TOUCH_TARGET`. Use it where a typo would be expensive; a
plain `Button` with `theme_type_variation` set is equally supported.

## Responsive layout

`UIBreakpoints` reports one of three size classes and rearranges nothing
itself:

```gdscript
UIBreakpoints.breakpoint_changed.connect(_on_breakpoint_changed)

func _on_breakpoint_changed(size_class: StringName) -> void:
    # A plain BoxContainer, not an HBoxContainer — the H/V subclasses exist to
    # lock the orientation and refuse to be flipped.
    row.vertical = size_class == UIBreakpoint.MOBILE_PORTRAIT
```

Reach for `HFlowContainer` before reaching for a breakpoint at all: it wraps
on its own and needs no signal. The breakpoint is for the case no container
covers, like a row that has to become a column.

The threshold lives in `Project Settings > ui_kit > breakpoints >
desktop_min_short_side` (600 by default): below that many
density-independent pixels on the *shorter* side, the screen is mobile, and
its orientation picks which of the two mobile classes applies. Sizes are
divided by `DisplayServer.screen_get_scale()`, which reports the real factor
on Android, iOS, macOS, Wayland and the web. X11 and Windows report `1.0` —
right at 100% desktop scaling, wrong above it, and
`UIBreakpoints.set_screen_scale_override()` is there for that case.

## Menu templates

Three full-screen scenes under `templates/`. Instance one, connect its
signals, and that is the integration:

```gdscript
main_menu.play_pressed.connect(_start_game)
main_menu.settings_pressed.connect(_open_settings)

pause_menu.resume_pressed.connect(_on_resumed)
settings_menu.palette_changed.connect(_save_palette)
```

| Template           | Signals                                                                                      |
| ------------------ | -------------------------------------------------------------------------------------------- |
| `UIMainMenu`       | `play_pressed`, `settings_pressed`, `quit_pressed`                                            |
| `UIPauseMenu`      | `resume_pressed`, `settings_pressed`, `quit_pressed` — plus `open()`/`close()`/`resume()`      |
| `UISettingsMenu`   | `back_pressed`, `palette_changed`, `music_volume_changed`, `effects_volume_changed`, `fullscreen_toggled` |

Two things to know:

- **They set no `theme`.** Theme lookup walks up the tree, so a template picks
  up whatever `UITheme` your root sets. That is what keeps them templates
  instead of a second skin to maintain — but it also means opening one on its
  own in the editor shows it unstyled, which is expected.
- **They report; they do not act.** The settings screen does not touch your
  audio buses or your window mode, because it cannot know how many buses you
  have or whether you want exclusive or borderless fullscreen. The one
  exception is the palette, since re-skinning is this kit's own job.

`UIPauseMenu` pauses with `get_tree().paused` and stays responsive through
`PROCESS_MODE_ALWAYS` — there is no pause system in the addon. Pressing
Settings from it hides the menu but leaves the tree paused, so whatever you
show next is paused too.

`demo/ui_kit/showcase/` chains all three and is the dev harness's main scene.

## Name prefix

Every public name in this addon uses the `UI` prefix. GDScript has no
namespaces, so `class_name` and autoload names are global to the whole project:
if your game already has a `UIPalette`, rename one of the two before enabling
this addon.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE)
