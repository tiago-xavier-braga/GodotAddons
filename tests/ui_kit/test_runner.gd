extends Node

## Runs every UI Kit test and exits non-zero if any check failed.
##
##     godot --headless res://tests/ui_kit/test_runner.tscn
##
## A scene, not a [code]--script[/code] main loop, because the tests need the
## autoloads registered and the input pipeline running — the same conditions
## the addon sees in a real game.

const TESTS: PackedStringArray = [
	"res://tests/ui_kit/test_ui_input.gd",
	"res://tests/ui_kit/test_ui_theme.gd",
	"res://tests/ui_kit/test_ui_components.gd",
]


func _ready() -> void:
	await _run_all()


func _run_all() -> void:
	var total_checks := 0
	var all_failures: PackedStringArray = []

	for path: String in TESTS:
		var script: GDScript = load(path)
		if script == null:
			all_failures.append("%s — could not be loaded" % path)
			continue

		var test: UIKitTestCase = script.new()
		test.name = path.get_file().get_basename()
		add_child(test)
		await test.run()

		total_checks += test.checks
		for failure: String in test.failures:
			all_failures.append("%s: %s" % [test.name, failure])
		print("%s  %s (%d checks)" % [
			"FAIL" if not test.failures.is_empty() else "ok  ", test.name, test.checks
		])
		test.queue_free()

	print("")
	if all_failures.is_empty():
		print("%d checks passed" % total_checks)
		get_tree().quit(0)
		return

	for failure: String in all_failures:
		printerr("  ✗ ", failure)
	printerr("%d of %d checks failed" % [all_failures.size(), total_checks])
	get_tree().quit(1)
