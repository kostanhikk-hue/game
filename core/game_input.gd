extends Node
## Регистрирует действия ввода (автозагрузка). Все скрипты используют только имена действий.

func _ready() -> void:
	_key("left", [KEY_A, KEY_LEFT])
	_key("right", [KEY_D, KEY_RIGHT])
	_key("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_key("attack", [KEY_J, KEY_X])
	_key("ink", [KEY_K, KEY_C])
	_key("wave", [KEY_L, KEY_V])
	_key("reset", [KEY_R])
	_key("toggle_ui", [KEY_TAB])
	_key("back", [KEY_ESCAPE])
	_key("interact", [KEY_E])

	_add("left", _joy_axis(-1.0))
	_add("right", _joy_axis(1.0))
	_add("jump", _joy_btn(JOY_BUTTON_A))
	_add("attack", _joy_btn(JOY_BUTTON_X))
	_add("ink", _joy_btn(JOY_BUTTON_Y))
	_add("wave", _joy_btn(JOY_BUTTON_B))
	_add("interact", _joy_btn(JOY_BUTTON_RIGHT_SHOULDER))
	var mb := InputEventMouseButton.new()
	mb.button_index = MOUSE_BUTTON_RIGHT
	_add("ink", mb)
	var ml := InputEventMouseButton.new()
	ml.button_index = MOUSE_BUTTON_LEFT
	_add("wave", ml)


func _key(action: String, keys: Array) -> void:
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		_add(action, e)


func _add(action: String, ev: InputEvent) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_add_event(action, ev)


func _joy_axis(value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = JOY_AXIS_LEFT_X
	e.axis_value = value
	return e


func _joy_btn(button: JoyButton) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	return e
