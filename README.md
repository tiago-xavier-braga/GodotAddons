# UI Kit

A portable UI kit for the Godot Engine: themed components, ready-made menu
templates (main menu, pause, settings), and automatic keyboard/gamepad/touch
input switching — built to drop into new projects (web, mobile, Steam)
without rebuilding UI from scratch every time.

> **Status:** planning (Phase 0) — see [roadmap.md](docs/roadmap.md) for the
> full phased plan and [api_design.md](docs/api_design.md) for the sketched
> public API. Nothing is implemented yet.

## Why UI Kit

Godot's built-in `Control`/`Theme` system covers the primitives well, but
every new project ends up rebuilding the same things from scratch:

- **Design-token theming** — a `UIPalette`/`UITypography` resource pair
  generates a full `Theme`, instead of editing dozens of overrides by hand
  per project.
- **Automatic input-device switching** — `UIInput` tracks whether the
  player is currently on keyboard/mouse, gamepad, or touch from real input
  events, and the component kit reacts to it automatically.
- **Ready-made, fully-navigable menu templates** — main menu, pause menu,
  and settings menu, pre-wired for keyboard, gamepad, and touch navigation
  at once.
- **Responsive layout** — a breakpoint container restructures UI (not just
  scales it) across mobile, desktop, and Steam window sizes.

See [roadmap.md](docs/roadmap.md) for the full plan and the architecture
decisions behind it, and [design.md](docs/design.md) for the default token
palette.

## Requirements

- Godot `4.7`

## Installation

Not available yet — the addon has no code until Phase 1 of the
[roadmap](docs/roadmap.md) lands.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

[MIT](LICENSE)
