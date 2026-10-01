#!/usr/bin/env bash
# Installs addons/ui_kit/ into a throwaway project the way a consumer would,
# and checks the claim the README makes: copy the folder, tick the checkbox,
# and both autoloads are there with nothing added by hand.
#
#   tests/ui_kit/clean_install_check.sh
#
# This cannot be a GDScript test, because enabling a plugin is an editor
# action: ui_kit.gd's _enable_plugin() only runs when the checkbox is ticked.
# So the script scaffolds a second, throwaway plugin whose only job is to tick
# it, and runs a headless editor once.

set -euo pipefail

GODOT="${GODOT:-godot}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

fail() { printf '  \xe2\x9c\x97 %s\n' "$1" >&2; FAILURES=$((FAILURES + 1)); }
pass() { printf '  ok %s\n' "$1"; }
FAILURES=0

echo "clean install into $WORK_DIR"

# 1. A bare project: no autoloads, no plugins, nothing but the copied folder.
mkdir -p "$WORK_DIR/addons"
cp -r "$REPO_ROOT/addons/ui_kit" "$WORK_DIR/addons/ui_kit"
cat > "$WORK_DIR/project.godot" <<'EOF'
config_version=5

[application]

config/name="Clean Install Check"
config/features=PackedStringArray("4.7", "GL Compatibility")

[editor_plugins]

enabled=PackedStringArray("res://addons/install_probe/plugin.cfg")

[rendering]

renderer/rendering_method="gl_compatibility"
EOF

# 2. The throwaway plugin that ticks UI Kit's checkbox for us.
mkdir -p "$WORK_DIR/addons/install_probe"
cat > "$WORK_DIR/addons/install_probe/plugin.cfg" <<'EOF'
[plugin]

name="Install Probe"
description="Test scaffolding. Ticks UI Kit's checkbox so _enable_plugin() runs."
author="UI Kit tests"
version="1.0.0"
script="install_probe.gd"
EOF
cat > "$WORK_DIR/addons/install_probe/install_probe.gd" <<'EOF'
@tool
extends EditorPlugin


func _enter_tree() -> void:
	_tick.call_deferred()


func _tick() -> void:
	# Enabling a plugin makes the editor reload them all, so this probe is
	# constructed again and ticks again. Asking the editor beats any flag of
	# our own, which the new instance would not have.
	if EditorInterface.is_plugin_enabled("ui_kit"):
		return
	EditorInterface.set_plugin_enabled("ui_kit", true)
	ProjectSettings.save()
EOF

# 3. Import, then run the editor once so the probe can tick the checkbox.
"$GODOT" --headless --path "$WORK_DIR" --import >/dev/null 2>&1 || true
"$GODOT" --headless --path "$WORK_DIR" --editor --quit-after 120 >"$WORK_DIR/editor.log" 2>&1 || true

echo
echo "after enabling the plugin:"

PROJECT_FILE="$WORK_DIR/project.godot"
for singleton in UIInput UIBreakpoints; do
	# Godot 4.7 writes autoloads as uid:// references rather than res:// paths,
	# so only the entry's presence can be checked here; that it points into the
	# addon is checked by standalone.gd, which can resolve a uid.
	if grep -qE "^${singleton}=\"\\*(res|uid)://" "$PROJECT_FILE"; then
		pass "$singleton was registered automatically"
	else
		fail "$singleton is missing from project.godot"
		sed -n '/^\[autoload\]/,/^\[/p' "$PROJECT_FILE" >&2
	fi
done

if grep -q "addons/ui_kit/plugin.cfg" "$PROJECT_FILE"; then
	pass "UI Kit shows as enabled"
else
	fail "UI Kit is not listed as enabled"
fi

if grep -qiE "^(ERROR|SCRIPT ERROR)" "$WORK_DIR/editor.log"; then
	fail "the editor reported errors while loading the addon:"
	grep -iE "^(ERROR|SCRIPT ERROR)" "$WORK_DIR/editor.log" | head -5 >&2
else
	pass "the addon loaded with no errors in a project that has nothing else"
fi

# 4. Prove it runs, not just that it loads: a scene using the templates, in a
#    project where the only thing installed is the copied folder.
cat > "$WORK_DIR/standalone.gd" <<'EOF'
extends Node


func _ready() -> void:
	var problems: PackedStringArray = []

	for singleton_name: String in ["UIInput", "UIBreakpoints"]:
		var singleton := get_node_or_null("/root/" + singleton_name)
		if singleton == null:
			problems.append("%s autoload is not in the tree" % singleton_name)
			continue
		# The autoload is stored as a uid:// reference, so this is where it can
		# be confirmed to resolve to a script inside the copied folder.
		var script: Script = singleton.get_script()
		if script == null or not script.resource_path.begins_with("res://addons/ui_kit/"):
			problems.append(
				"%s resolves to %s, outside the addon"
				% [singleton_name, "nothing" if script == null else script.resource_path]
			)

	var theme := load("res://addons/ui_kit/theme/default_theme.tres") as UITheme
	if theme == null or theme.palette == null:
		problems.append("the default theme did not load")
	elif (theme.get_stylebox(&"normal", UIVariants.PRIMARY_BUTTON) as StyleBoxFlat) == null:
		problems.append("the default theme generated no style boxes")

	var screen := Control.new()
	screen.theme = theme
	add_child(screen)
	for scene_path: String in [
		"res://addons/ui_kit/templates/main_menu/main_menu.tscn",
		"res://addons/ui_kit/templates/pause_menu/pause_menu.tscn",
		"res://addons/ui_kit/templates/settings_menu/settings_menu.tscn",
		"res://addons/ui_kit/components/focus_prompt/ui_focus_prompt.tscn",
	]:
		var packed := load(scene_path) as PackedScene
		if packed == null:
			problems.append("%s did not load" % scene_path)
			continue
		screen.add_child(packed.instantiate())

	await get_tree().process_frame
	await get_tree().process_frame

	if problems.is_empty():
		print("STANDALONE_OK")
	else:
		for problem: String in problems:
			printerr("STANDALONE_FAIL ", problem)
	get_tree().quit()
EOF
cat > "$WORK_DIR/standalone.tscn" <<'EOF'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://standalone.gd" id="1_standalone"]

[node name="Standalone" type="Node"]
script = ExtResource("1_standalone")
EOF

"$GODOT" --headless --path "$WORK_DIR" --import >/dev/null 2>&1 || true
"$GODOT" --headless --path "$WORK_DIR" res://standalone.tscn >"$WORK_DIR/run.log" 2>&1 || true

if grep -q "STANDALONE_OK" "$WORK_DIR/run.log"; then
	pass "the templates, theme and autoloads all work with only the folder copied"
else
	fail "running the addon standalone failed:"
	grep -E "STANDALONE_FAIL|^(ERROR|SCRIPT ERROR)" "$WORK_DIR/run.log" | head -10 >&2
fi

echo
if [ "$FAILURES" -eq 0 ]; then
	echo "clean install check passed"
else
	echo "clean install check: $FAILURES problem(s)" >&2
fi
exit "$FAILURES"
