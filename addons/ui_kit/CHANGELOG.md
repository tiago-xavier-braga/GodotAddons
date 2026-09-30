# Changelog — UI Kit

All notable changes to the `ui_kit` addon are documented in this file. Each
addon in this repo versions independently, so this covers `addons/ui_kit/` only.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this addon uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Planning: roadmap, API sketch, and default token palette
  (see [`docs/ui_kit/`](../../docs/ui_kit/)).
- Empty `EditorPlugin` stub, so the addon can be enabled under
  `Project Settings > Plugins`.
- `UIPalette` and `UITypography`: the color, font and text-size tokens the
  whole kit reads from.
- `UIThemeBuilder.apply()`: derives every style box, color and font size in a
  `Theme` from a token pair, including the Theme Type Variations
  `UIPrimaryButton`, `UISecondaryButton`, `UIIconButton`, `UIPanel`,
  `UIHeading`, `UIBody` and `UICaption` (named in `UIVariants`).
- `UITheme`: a `Theme` that rebuilds itself whenever its palette or typography
  changes, so re-skinning is one inspector edit.
- `UIMetrics`: the geometry constants the builder and the templates share.
- Bundled Noto Sans (Apache-2.0), so a web export has a font of its own — see
  [`THIRDPARTY.md`](THIRDPARTY.md).
- `UIInput` autoload: `get_active_device()`, `get_active_device_name()`,
  `classify()` and the `device_changed` signal, plus the `UIInputDevice.Kind`
  enum. Ignores events Godot synthesised from another device, stick drift below
  the deadzone, and sub-pixel mouse nudges; falls back off `gamepad` when the
  last pad is unplugged.
- `ui_kit.gd` registers the `UIInput` autoload on enable and removes it on
  disable, leaving an autoload the project declared itself alone.
- `UIFocusPrompt`: a single `CanvasLayer` overlay that draws the active
  device's glyph beside the focused control, flipping to its left at the screen
  edge and borrowing the control's own text colour.
- `UIPromptSet`: the swappable glyph-per-device resource `UIFocusPrompt` reads,
  with a default set built from Kenney's CC0 input prompts.
- `UIButton`: a `Button` whose `variation` enum drives
  `theme_type_variation`, with a minimum touch target applied per node.
- `UIBreakpoints` autoload: `get_active_breakpoint()`, `classify()`,
  `get_screen_size()` and the `breakpoint_changed` signal, plus the
  `UIBreakpoint` size-class names and `UIBreakpoint.is_mobile()`. Measures the
  window in density-independent pixels, so a phone is not mistaken for a
  desktop.
- `ui_kit/breakpoints/desktop_min_short_side` project setting, registered on
  enable; a value the project changed is left alone on disable.
