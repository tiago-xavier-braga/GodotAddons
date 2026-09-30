# Third-party assets bundled in UI Kit

Everything listed here ships inside `addons/ui_kit/`, so a consumer project
inherits it by copying the folder. Licenses are reproduced next to the files
they cover.

## Noto Sans — `fonts/noto_sans_regular.ttf`, `fonts/noto_sans_bold.ttf`

- Source: the [Noto](https://fonts.google.com/noto) project (Google).
- License: Apache License 2.0 — full text in
  [`fonts/noto_sans_license.txt`](fonts/noto_sans_license.txt).
- Why bundled: a web export cannot fall back on a font installed on the
  player's machine, so the kit has to carry its own. See
  [`UITypography`](theme/ui_typography.gd).

## Input prompt glyphs — `components/focus_prompt/glyphs/`

- Source: Kenney's [Input Prompts](https://kenney.nl/assets/input-prompts)
  pack, version 1.5 — three files from it (`keyboard_enter.svg`,
  `xbox_button_a.svg`, `touch_tap.svg`), not the whole set.
- License: CC0 1.0 (public domain) — full notice in
  [`components/focus_prompt/glyphs/kenney_license.txt`](components/focus_prompt/glyphs/kenney_license.txt).
- Why bundled: [`UIFocusPrompt`](components/focus_prompt/ui_focus_prompt.gd)
  has to draw *something* out of the box. They are plain white, so the palette
  tints them. To use PlayStation or Switch artwork instead, point a
  [`UIPromptSet`](components/focus_prompt/ui_prompt_set.gd) at your own files —
  the addon does not need to change.
