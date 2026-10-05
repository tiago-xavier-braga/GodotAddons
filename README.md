# Godot Addons

Internal monorepo of reusable addons for the Godot Engine. One Godot project
holds every addon plus its demo and test scenes, so they get developed and
tested together instead of one project per addon.

The project at the root (`project.godot`, `demo/`, `tests/`) is a development
harness — it is never distributed. Each `addons/<name>/` folder is the
deliverable, self-contained and copyable on its own.

## Addons

| Addon | What it does | Status |
| ----- | ------------ | ------ |
| `ui_kit` | Themed UI components, ready-made menu templates, and automatic keyboard/gamepad/touch switching | Planning ([roadmap](docs/ui_kit/roadmap.md)) |

## Requirements

- Godot `4.7`

## Layout

```
addons/<name>/        # the addon itself — the only thing consumers copy
demo/<name>/          # manual demo scenes for that addon
docs/<name>/          # planning notes, API sketches, design decisions
tests/<name>/         # automated tests
project.godot         # dev harness, never distributed
```

## Working on an addon

Open the repo as a Godot project and enable the addons you need under
`Project Settings > Plugins`. Each addon has its own `plugin.cfg`, so you can
enable one at a time — useful to confirm an addon still works without the
others loaded.

### Two rules that matter across addons

**One name prefix per addon.** GDScript has no namespaces: `class_name` and
autoload names are global to the whole project, including the consumer's game.
Two addons declaring the same `class_name` will not compile together. `ui_kit`
owns the `UI` prefix (`UIPalette`, `UIInput`, ...); every new addon picks its
own and keeps to it.

**Keep addons self-contained.** Everything loads at once here, so it is easy
to reach across addons without noticing — and the consumer who copies only one
folder then breaks at runtime. If an addon genuinely needs another, say so in
its README and check for it in `_enter_tree()` instead of assuming.

## Using an addon in a project

**Copy the folder.** Copy `addons/<name>/` into the target project and enable
it under `Project Settings > Plugins`. The version ends up committed in the
game's repo, which is usually what you want. Re-copy to update.

**Submodule, if re-copying gets old.** A git submodule cannot check out a
subdirectory, so this needs a per-addon repo. Publish one as a read-only
mirror without splitting development:

```bash
git subtree split --prefix=addons/ui_kit -b dist/ui_kit
git push git@github.com:<user>/godot-ui-kit.git dist/ui_kit:main
```

The consuming project submodules the mirror. One command per release.

## License

[MIT](LICENSE) — applies to every addon in this repo.
