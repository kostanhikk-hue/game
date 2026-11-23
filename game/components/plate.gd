extends "res://game/components/component_base.gd"
## Нажимная плита: активна, пока на ней стоит герой / враг / любое тело. События pressed / released.
## Положение объекта — середина плиты, плита лежит на полу (низ = положение + 6 px).

const H := 12.0
var _area: Area2D
var _shape := RectangleShape2D.new()
var _release_t := 0.0


func _setup(_ctx: Dictionary) -> void:
	active = false
	_area = Area2D.new()
	_area.monitorable = false
	var cs := CollisionShape2D.new()
	cs.shape = _shape
	cs.position = Vector2(0, -H * 0.5)
	_area.add_child(cs)
	add_child(_area)


func _apply() -> void:
	_shape.size = Vector2(maxf(props.width - 4.0, 4.0), H * 2.0)
	match int(props.pressed_by):
		0: _area.collision_mask = PLAYER_LAYER
		1: _area.collision_mask = ENEMY_LAYER
		_: _area.collision_mask = PLAYER_LAYER | ENEMY_LAYER | WORLD_LAYER


func _physics_process(delta: float) -> void:
	super(delta)
	var pressed := false
	for b in _area.get_overlapping_bodies():
		if b.is_in_group("level_geometry"):
			continue
		if b.get("dead") == true:
			continue
		pressed = true
		break
	if pressed:
		_release_t = props.release_delay
		if not active:
			set_active(true)
	elif active:
		_release_t -= delta
		if _release_t <= 0.0:
			set_active(false)


func _active_event(on: bool) -> void:
	emit_event("pressed" if on else "released")
	if on:
		links_pulse()
	links_state(on)


func _on_active(_on: bool) -> void:
	queue_redraw()


func _draw() -> void:
	var w: float = props.width
	var depth: float = Params.get_res("objects").plate_depth if active else 0.0
	draw_rect(Rect2(-w * 0.5 - 4, 0, w + 8, 6), Color(0.3, 0.3, 0.33))
	var top := Rect2(-w * 0.5, -6 + depth, w, 6 - depth * 0.5)
	draw_rect(top, Color(0.95, 0.75, 0.3) if active else Color(0.7, 0.6, 0.45))
	draw_rect(top, Color(0, 0, 0, 0.5), false, 1.5)
	_draw_debug()
