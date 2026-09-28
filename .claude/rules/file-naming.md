# File and Folder Naming

Follows the official Godot style guide.

- **Folders**: `snake_case`, lowercase. E.g. `leaf_tween/`, `basic_demo/`.
- **Scenes (`.tscn`)**: `snake_case`, matching the script/root node name.
  E.g. `player.tscn`, `main_menu.tscn`.
- **Scripts (`.gd`)**: `snake_case`, matching the scene name when attached to
  it. E.g. `player.gd` for `player.tscn`.
- **Resources (`.tres`, `.res`)**: `snake_case`, describing the content. E.g.
  `ease_out_cubic.tres`.
- **Classes (`class_name`)**: `PascalCase`, to stay consistent with the
  engine's native classes. E.g. `class_name LeafTween`.
- **Autoloads/Singletons**: file name in `snake_case`, but the name
  registered in the project (used as the global identifier) in `PascalCase`.
- Avoid spaces, accents, and uppercase letters in file/folder names — only
  `a-z`, `0-9`, and `_`.

## Name prefix per addon

GDScript has no namespaces: `class_name` and autoload names are global to the
entire project, including the consumer's game. Two addons declaring the same
`class_name` will not compile together.

- Every public `class_name` and autoload in an addon carries that addon's
  prefix. `ui_kit` owns `UI` (`UIPalette`, `UITypography`, `UIInput`,
  `UIBreakpoints`, ...).
- A new addon picks its own prefix and never shares one with another addon.
  Pick something unlikely to collide with a game's own classes too.
- The prefix applies to public names only. Private members keep the `_` prefix
  convention from `code-style.md` and need no addon prefix.
- The addon's folder name stays `snake_case` and unprefixed (`ui_kit/`, not
  `ui_ui_kit/`).
