# Testing UI Kit

Two checks, both runnable from the repo root. Neither needs the editor open.

## The test suite

```sh
godot --headless res://tests/ui_kit/test_runner.tscn
```

Exits non-zero on the first failing check, so it drops straight into CI. The
suite runs as a *scene*, not a `--script` main loop, because the addon's
autoloads and the real input pipeline both have to be live — several tests push
synthetic events through `Input.parse_input_event()` and assert on what comes
out the other side.

| File                             | Covers                                                              |
| -------------------------------- | ------------------------------------------------------------------- |
| `test_ui_input.gd`               | device classification, the deadzone, emulated events, pad unplugged |
| `test_ui_theme.gd`               | tokens into a `Theme`, live re-skin, idempotent rebuilds            |
| `test_ui_components.gd`          | `UIButton` variations, the focus prompt's position and glyph         |
| `test_ui_breakpoints.gd`         | the size-class rule, the threshold, a real window resize            |
| `test_ui_templates.gd`           | template signals, pausing, focus order, touch targets               |
| `test_ui_safe_area.gd`           | inset arithmetic against invented screens                           |
| `test_addon_is_self_contained.gd`| nothing in `addons/ui_kit/` points outside it                       |

Two things the harness enforces beyond the checks themselves: a test file that
asserts nothing is a failure, not a pass, and `UIKitTestCase.check_approx()`
exists because values that pass through a `Vector2` come back as 32-bit floats.

## The clean install check

```sh
tests/ui_kit/clean_install_check.sh
```

Copies `addons/ui_kit/` into a throwaway project that contains nothing else,
ticks the plugin's checkbox, and asserts that both autoloads appear and that
the templates, theme and focus prompt all load and run. This is the README's
install claim, checked.

It has to be a shell script rather than another test file: enabling a plugin is
an editor action, and `ui_kit.gd`'s `_enable_plugin()` only runs when the
checkbox is ticked. The script scaffolds a second, throwaway plugin whose only
job is to tick it, then runs one headless editor session.

Set `GODOT=/path/to/godot` if the binary is not on `PATH`.

## What these cannot cover

Device and export behaviour. See the open items in
[`roadmap.md`](roadmap.md#phase-6--cross-platform-polish): the font fallbacks,
the safe-area margins and the input switching all need a real web, mobile and
Windows build to confirm, and export templates plus the devices to run them on.
