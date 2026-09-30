# UI Kit

A portable UI kit for the Godot Engine: themed components, ready-made menu
templates (main menu, pause, settings), and automatic keyboard/gamepad/touch
input switching — built to drop into new projects (web, mobile, Steam) without
rebuilding UI from scratch every time.

> **Status:** in progress (Phase 1 of 6 done — token-driven theming). See the
> [roadmap](../../docs/ui_kit/roadmap.md) for the phased plan and the
> [API sketch](../../docs/ui_kit/api_design.md) for the intended public
> surface.

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

## Name prefix

Every public name in this addon uses the `UI` prefix. GDScript has no
namespaces, so `class_name` and autoload names are global to the whole project:
if your game already has a `UIPalette`, rename one of the two before enabling
this addon.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](../../LICENSE)
