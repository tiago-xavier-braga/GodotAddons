extends Control

## Phase 2 demo: the naive device guess next to what [code]UIInput[/code] reports.
##
## The top row is the shortcut everyone writes first —
## [code]Input.get_connected_joypads().size() > 0[/code]. Leave a controller
## plugged in and type: it claims "gamepad" and never changes its mind. It also
## has no signal to connect to, so the demo has to poll it every frame.
##
## The row below it is [code]UIInput[/code], driven by real events and updated
## through [signal device_changed].

const HISTORY_LIMIT := 8

@onready var _naive_answer: Label = %NaiveAnswer
@onready var _kit_answer: Label = %KitAnswer
@onready var _history: Label = %History

var _switches: Array[String] = []


func _ready() -> void:
	UIInput.device_changed.connect(_on_device_changed)
	%SimulateKeyboard.pressed.connect(_simulate.bind(_key_event()))
	%SimulateGamepad.pressed.connect(_simulate.bind(_joypad_event()))
	%SimulateTouch.pressed.connect(_simulate.bind(_touch_event()))
	_show_active_device()
	_show_history()


func _process(_delta: float) -> void:
	# The naive check is a poll by necessity: nothing tells you when the answer
	# would have changed, because the answer never changes.
	var pads := Input.get_connected_joypads()
	var guess := "gamepad" if pads.size() > 0 else "keyboard_mouse"
	_naive_answer.text = "%s   (pads connected: %d)" % [guess, pads.size()]


func _on_device_changed(device: UIInputDevice.Kind) -> void:
	_switches.push_front(UIInputDevice.name_of(device))
	if _switches.size() > HISTORY_LIMIT:
		_switches.resize(HISTORY_LIMIT)
	_show_active_device()
	_show_history()


func _show_active_device() -> void:
	_kit_answer.text = str(UIInput.get_active_device_name())


func _show_history() -> void:
	if _switches.is_empty():
		_history.text = "no switches yet — press a key, move the mouse, or use a pad"
		return
	_history.text = " ← ".join(_switches)


## Feeds a synthetic event through the real input pipeline, so the demo is
## usable on a desk with no controller and no touchscreen. Deferred because
## this runs inside the handling of the mouse click that triggered it.
func _simulate(event: InputEvent) -> void:
	Input.parse_input_event.call_deferred(event)


func _key_event() -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	return event


func _joypad_event() -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_A
	event.pressed = true
	return event


func _touch_event() -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.pressed = true
	return event
