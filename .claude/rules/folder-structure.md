# Folder Structure

This is a monorepo of Godot 4.7 addons. The root project is a development
harness; each `addons/<name>/` folder is a separate deliverable. Within a
folder, organize by feature/context rather than by file type.

```
res://
├── addons/
│   ├── ui_kit/            # one folder per addon: plugin.cfg, plugin script,
│   └── <name>/            # classes, fonts, theme/component/template resources
├── demo/
│   ├── ui_kit/            # manual demo scenes, grouped per addon
│   └── <name>/
├── docs/
│   ├── ui_kit/            # roadmap, API sketch, design notes, per addon
│   └── <name>/
├── tests/
│   ├── ui_kit/            # automated tests, grouped per addon
│   └── <name>/
├── assets/                # raw media exclusive to demo scenes (non-script)
│   ├── audio/
│   └── sprites/
├── icon.svg
└── project.godot          # dev harness only, never distributed
```

Rules:

- An addon is self-contained: everything it needs at runtime lives inside its
  own `addons/<name>/` folder, including bundled fonts, theme resources, and
  component/template scenes. That folder is exactly what a consumer copies.
- Nothing outside `addons/<name>/` ships. `demo/`, `docs/`, `tests/`,
  `assets/`, and `project.godot` exist for development only.
- One addon never reads from another addon's folder unless that dependency is
  documented in its README and checked at runtime — a consumer who copies one
  folder must not break silently.
- Each scene (`.tscn`) lives in the same folder as its script (`.gd`) and any
  resources exclusive to it (e.g. `demo/ui_kit/theming/theming.tscn` +
  `theming.gd`). Avoid splitting everything into global `scenes/` and
  `scripts/` folders.
- Media shared across multiple demo scenes (sprites, audio) goes in `assets/`,
  never inside a specific feature's folder.
- Don't create empty folders "for the future". A folder only exists once it
  has content — this includes the per-addon subfolders above.
