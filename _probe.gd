extends SceneTree

func _initialize() -> void:
	print("DEVICE_ID_EMULATION exposed: ", InputEvent.DEVICE_ID_EMULATION)
	var ev := InputEventMouseButton.new()
	print("default device on a fresh event: ", ev.device)
	print("joy deadzone default: ", InputMap.action_get_deadzone("ui_accept") if InputMap.has_action("ui_accept") else "n/a")
	print("emulate_mouse_from_touch setting: ", ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch", "unset"))
	print("emulate_touch_from_mouse setting: ", ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", "unset"))
	quit()
