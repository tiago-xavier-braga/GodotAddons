extends Node

## Tracks which device the player is actually using right now.
##
## Registered as the [code]UIInput[/code] autoload when the plugin is enabled,
## so it is available as [code]UIInput.get_active_device()[/code] from
## anywhere.
##
## The usual shortcut, [code]Input.get_connected_joypads().size() > 0[/code],
## answers a different question — "is a pad plugged in" — and gets it wrong for
## the most common setup there is: a controller sitting connected while the
## player types. This listens to real events instead and remembers the last
## device that produced one, which is the only thing that can be known for
## certain.
##
## See [UIInputDevice] for the device kinds.

## Emitted when the active device changes — never on every event, so a
## listener can rebuild prompts here without rate-limiting.
signal device_changed(device: UIInputDevice.Kind)

## Returned by [method classify] for an event that carries no usable signal.
const UNKNOWN := -1

## How far a stick must leave center before it counts as deliberate input.
## Matches Godot's own default action deadzone, so a pad that does not fight
## [InputMap] does not fight this either.
const JOY_DEADZONE := 0.5

## How far the mouse must travel in one event before it counts. Without this,
## desk vibration steals the active device from a gamepad player.
const MOUSE_MOTION_THRESHOLD := 2.0

var _active_device: UIInputDevice.Kind = UIInputDevice.Kind.KEYBOARD_MOUSE


func _ready() -> void:
	# Device detection has to keep working while the tree is paused, because a
	# paused tree is exactly when the pause menu needs the right glyphs.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_active_device = _default_device()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _input(event: InputEvent) -> void:
	# _input, not _unhandled_input: a button press consumed by a Control is
	# still the player telling us which device they are on.
	var kind := classify(event)
	if kind != UNKNOWN:
		_set_active_device(kind as UIInputDevice.Kind)


## The device that produced the most recent real input event.
func get_active_device() -> UIInputDevice.Kind:
	return _active_device


## [method get_active_device] as a stable lower-case name.
func get_active_device_name() -> StringName:
	return UIInputDevice.name_of(_active_device)


## Which device [param event] came from, or [constant UNKNOWN] when the event
## proves nothing: idle stick drift, a mouse nudge, or an event Godot
## synthesised from another device.
func classify(event: InputEvent) -> int:
	# Godot stamps events it invents — a mouse click built from a touch when
	# input_devices/pointing/emulate_mouse_from_touch is on, which it is by
	# default — with this device id. Trusting them would flip a phone to
	# "keyboard and mouse" on every tap.
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return UNKNOWN

	if event is InputEventKey or event is InputEventMouseButton:
		return UIInputDevice.Kind.KEYBOARD_MOUSE

	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if motion.relative.length() < MOUSE_MOTION_THRESHOLD:
			return UNKNOWN
		return UIInputDevice.Kind.KEYBOARD_MOUSE

	if event is InputEventPanGesture or event is InputEventMagnifyGesture:
		return UIInputDevice.Kind.KEYBOARD_MOUSE

	if event is InputEventJoypadButton:
		return UIInputDevice.Kind.GAMEPAD

	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if absf(motion.axis_value) < JOY_DEADZONE:
			return UNKNOWN
		return UIInputDevice.Kind.GAMEPAD

	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return UIInputDevice.Kind.TOUCH

	return UNKNOWN


func _set_active_device(kind: UIInputDevice.Kind) -> void:
	if _active_device == kind:
		return
	_active_device = kind
	device_changed.emit(_active_device)


## Unplugging the pad you were just using has to fall back to something, and
## no event will arrive to say so.
func _on_joy_connection_changed(_pad: int, connected: bool) -> void:
	if connected:
		return
	if _active_device != UIInputDevice.Kind.GAMEPAD:
		return
	if not Input.get_connected_joypads().is_empty():
		return
	_set_active_device(_default_device())


## The best guess before any event has arrived. A guess is all it can be — the
## first real event replaces it.
func _default_device() -> UIInputDevice.Kind:
	if OS.has_feature("mobile"):
		return UIInputDevice.Kind.TOUCH
	return UIInputDevice.Kind.KEYBOARD_MOUSE
