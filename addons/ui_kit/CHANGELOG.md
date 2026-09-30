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
