# Folder Structure

Directory layout for the project (Godot 4.7), organized by feature/context
rather than by file type:

```
res://
├── addons/
│   └── ui_kit/           # addon source code (plugin.cfg, plugin.gd, internal classes,
│                          # bundled fonts, theme/component/template resources)
├── demo/                  # example/manual test scenes for the addon
├── tests/                 # automated tests
├── assets/                # raw media exclusive to demo scenes (non-script)
│   ├── audio/
│   └── sprites/
├── icon.svg
└── project.godot
```

Rules:

- Each scene (`.tscn`) lives in the same folder as its script (`.gd`) and any
  resources exclusive to it (e.g. `demo/theming/theming.tscn` + `theming.gd`).
  Avoid splitting everything into global `scenes/` and `scripts/` folders.
- Resources shared across multiple demo scenes (sprites, audio) go in
  `assets/`, never inside a specific feature's folder.
- Addon code — including bundled fonts, theme resources, and component/
  template scenes — lives exclusively in `addons/ui_kit/` — no addon logic
  or assets outside that folder. This is what a consumer project copies in
  to install UI Kit.
- Don't create empty folders "for the future". A folder only exists once it
  has content.
