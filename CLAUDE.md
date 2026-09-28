# Godot Addons

Internal monorepo of reusable Godot Engine addons. The root Godot project is a
development harness for building and testing them — it is never distributed.
Each `addons/<name>/` folder is a self-contained deliverable that a consumer
project copies in on its own.

Current addons:

- `ui_kit` — themed UI components, ready-made menu templates, and automatic
  keyboard/gamepad/touch input switching. Planning notes in `docs/ui_kit/`.

Because GDScript has no namespaces, `class_name` and autoload names are global
to the whole project — including the consumer's game. Each addon owns one name
prefix and keeps to it (`ui_kit` owns `UI`), and no addon reaches into another
without declaring the dependency.

@.claude/local.md
@.claude/rules/folder-structure.md
@.claude/rules/file-naming.md
@.claude/rules/code-style.md
@.claude/rules/task-tracking.md
