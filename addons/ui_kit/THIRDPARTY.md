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
