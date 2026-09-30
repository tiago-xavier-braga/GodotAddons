class_name UIKitTestCase
extends Node

## Base class for the addon's tests. Development only — nothing under
## [code]tests/[/code] ships inside [code]addons/ui_kit/[/code].
##
## Tests are [Node]s rather than plain scripts so they run inside a real
## [SceneTree], with the autoloads registered and the input pipeline live.
## Override [method run] and use the [code]check*[/code] helpers; it may
## [code]await[/code] freely.

var failures: PackedStringArray = []
var checks: int = 0


## Override with the test body. May be a coroutine.
func run() -> void:
	pass


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)


func check_equal(actual: Variant, expected: Variant, description: String) -> void:
	checks += 1
	if actual != expected:
		failures.append("%s — expected %s, got %s" % [description, expected, actual])


## Waits one full frame, so an event pushed through [method Input.parse_input_event]
## has been dispatched before the next assertion.
func next_frame() -> void:
	await get_tree().process_frame
