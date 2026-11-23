extends Node
## Главное меню игры: «Играть уровень» (список уровней из content/levels/, временно — до кампании),
## «Разработка» (только в dev-сборке), «Выход».

const LevelFiles := preload("res://game/level/level_files.gd")
const LevelRuntime := preload("res://game/level/level_runtime.gd")
const Dev := preload("res://core/dev.gd")
const DEV_MENU := "res://editor/launcher.tscn"

var _box: VBoxContainer


func _ready() -> void:
	Fx.set_base_scale(1.0)
	var layer := CanvasLayer.new()
	add_child(layer)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	_box = VBoxContainer.new()
	_box.custom_minimum_size = Vector2(420, 0)
	_box.add_theme_constant_override("separation", 10)
	center.add_child(_box)
	_show_main()


func _clear() -> void:
	for c in _box.get_children():
		c.queue_free()


func _title(text: String) -> void:
	var t := Label.new()
	t.text = text
	t.add_theme_font_size_override("font_size", 32)
	t.add_theme_color_override("font_color", Color(1, 0.8, 0.35))
	_box.add_child(t)


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 44)
	b.pressed.connect(cb)
	_box.add_child(b)
	return b


func _show_main() -> void:
	_clear()
	_title("ИГРА")
	_button("Играть уровень", _show_levels).grab_focus.call_deferred()
	if Dev.enabled():
		_button("Разработка", func() -> void: get_tree().change_scene_to_file(DEV_MENU))
	_button("Выход", func() -> void: get_tree().quit())


func _show_levels() -> void:
	_clear()
	_title("УРОВНИ")
	var levels := LevelFiles.all_levels()
	if levels.is_empty():
		var l := Label.new()
		l.text = "Уровней пока нет (content/levels/<эпоха>/<id>.tres)."
		_box.add_child(l)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, mini(levels.size(), 8) * 48)
	_box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for lv in levels:
		var b := Button.new()
		var ep_i := LevelData.EPOCHS.find(lv["epoch"])
		b.text = "%s  ·  %s" % [lv["id"], LevelData.EPOCH_TITLES[ep_i] if ep_i >= 0 else lv["epoch"]]
		b.custom_minimum_size = Vector2(0, 40)
		b.pressed.connect(_play.bind(lv["path"]))
		list.add_child(b)
	_button("← Назад", _show_main)


func _play(path: String) -> void:
	LevelRuntime.requested_path = path
	get_tree().change_scene_to_file(LevelRuntime.SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		_show_main()
