extends UIKitTestCase

## Tests for the [code]UIInput[/code] autoload — mostly the cases that make the
## naive "is a pad connected" check wrong.

const KEYBOARD := UIInputDevice.Kind.KEYBOARD_MOUSE
const GAMEPAD := UIInputDevice.Kind.GAMEPAD
const TOUCH := UIInputDevice.Kind.TOUCH

var _seen: Array[int] = []


func run() -> void:
	UIInput.device_changed.connect(_record)

	_test_classification()
	_test_joypad_deadzone()
	_test_mouse_motion_threshold()
	_test_emulated_events_are_ignored()
	_test_device_names()
	await _test_signal_fires_only_on_change()
	await _test_two_gamepads_are_one_device()
	await _test_real_pipeline()
	await _test_gamepad_unplugged_mid_game()

	UIInput.device_changed.disconnect(_record)


func _test_classification() -> void:
	check_equal(UIInput.classify(_key()), KEYBOARD, "a key press is keyboard/mouse")
	check_equal(UIInput.classify(_mouse_button()), KEYBOARD, "a click is keyboard/mouse")
	check_equal(UIInput.classify(_joy_button()), GAMEPAD, "a pad button is gamepad")
	check_equal(UIInput.classify(_touch()), TOUCH, "a screen touch is touch")
	check_equal(UIInput.classify(_drag()), TOUCH, "a screen drag is touch")
	check_equal(UIInput.classify(InputEventMIDI.new()), UIInput.UNKNOWN, "MIDI is not a UI device")


## A stick resting off-center must not steal the active device from someone
## typing — this is the failure the deadzone exists for.
func _test_joypad_deadzone() -> void:
	var drift := _joy_motion(UIInput.JOY_DEADZONE - 0.01)
	check_equal(UIInput.classify(drift), UIInput.UNKNOWN, "stick drift below the deadzone is ignored")

	var deliberate := _joy_motion(UIInput.JOY_DEADZONE + 0.01)
	check_equal(UIInput.classify(deliberate), GAMEPAD, "a stick past the deadzone is gamepad")

	var negative := _joy_motion(-1.0)
	check_equal(UIInput.classify(negative), GAMEPAD, "the deadzone applies to both directions")


func _test_mouse_motion_threshold() -> void:
	var nudge := _mouse_motion(UIInput.MOUSE_MOTION_THRESHOLD - 0.1)
	check_equal(UIInput.classify(nudge), UIInput.UNKNOWN, "a sub-pixel mouse nudge is ignored")

	var move := _mouse_motion(UIInput.MOUSE_MOTION_THRESHOLD + 1.0)
	check_equal(UIInput.classify(move), KEYBOARD, "real mouse movement is keyboard/mouse")


## With input_devices/pointing/emulate_mouse_from_touch on — Godot's default —
## every tap on a phone also produces a mouse click. Believing it would report
## "keyboard/mouse" on a device that has neither.
func _test_emulated_events_are_ignored() -> void:
	var emulated := _mouse_button()
	emulated.device = InputEvent.DEVICE_ID_EMULATION
	check_equal(
		UIInput.classify(emulated),
		UIInput.UNKNOWN,
		"a mouse click Godot synthesised from a touch is ignored"
	)

	var emulated_touch := _touch()
	emulated_touch.device = InputEvent.DEVICE_ID_EMULATION
	check_equal(
		UIInput.classify(emulated_touch),
		UIInput.UNKNOWN,
		"a touch Godot synthesised from a mouse is ignored"
	)


func _test_device_names() -> void:
	check_equal(UIInputDevice.name_of(KEYBOARD), &"keyboard_mouse", "keyboard/mouse name")
	check_equal(UIInputDevice.name_of(GAMEPAD), &"gamepad", "gamepad name")
	check_equal(UIInputDevice.name_of(TOUCH), &"touch", "touch name")


func _test_signal_fires_only_on_change() -> void:
	await _become(GAMEPAD)
	_seen.clear()

	await _send(_joy_button())
	await _send(_joy_button())
	check_equal(_seen.size(), 0, "repeated events from the active device emit nothing")

	await _send(_key())
	check_equal(_seen, [KEYBOARD] as Array[int], "switching device emits once")


## Two pads are still "gamepad". Swapping between them must not churn the
## signal, or every listener rebuilds its prompts for nothing.
func _test_two_gamepads_are_one_device() -> void:
	await _become(KEYBOARD)
	_seen.clear()

	var first := _joy_button()
	first.device = 0
	var second := _joy_button()
	second.device = 1
	await _send(first)
	await _send(second)

	check_equal(_seen, [GAMEPAD] as Array[int], "a second pad does not re-emit device_changed")
	check_equal(UIInput.get_active_device(), GAMEPAD, "either pad leaves the device on gamepad")


## Everything above calls classify() directly; this one proves the autoload is
## actually wired into _input.
func _test_real_pipeline() -> void:
	await _become(KEYBOARD)
	Input.parse_input_event(_joy_button())
	await next_frame()
	check_equal(
		UIInput.get_active_device(), GAMEPAD, "an event through Input.parse_input_event is picked up"
	)


## No event arrives to say the pad is gone, so the fallback has to come from
## the connection signal. With no pads left, the device drops back.
func _test_gamepad_unplugged_mid_game() -> void:
	await _become(GAMEPAD)
	_seen.clear()

	Input.joy_connection_changed.emit(0, false)
	await next_frame()

	check(Input.get_connected_joypads().is_empty(), "no real pads attached, so the test is valid")
	check_equal(
		UIInput.get_active_device(), KEYBOARD, "unplugging the last pad falls back to keyboard/mouse"
	)
	check_equal(_seen, [KEYBOARD] as Array[int], "the fallback emits device_changed once")


# --- helpers ---


func _record(device: UIInputDevice.Kind) -> void:
	_seen.append(device)


## Puts the autoload into [param kind] without asserting anything about it.
func _become(kind: UIInputDevice.Kind) -> void:
	var event: InputEvent
	match kind:
		GAMEPAD:
			event = _joy_button()
		TOUCH:
			event = _touch()
		_:
			event = _key()
	await _send(event)


func _send(event: InputEvent) -> void:
	Input.parse_input_event(event)
	await next_frame()


func _key() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	return event


func _mouse_button() -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	return event


func _mouse_motion(distance: float) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.relative = Vector2(distance, 0.0)
	return event


func _joy_button() -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_A
	event.pressed = true
	return event


func _joy_motion(axis_value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_X
	event.axis_value = axis_value
	return event


func _touch() -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	return event


func _drag() -> InputEventScreenDrag:
	return InputEventScreenDrag.new()
