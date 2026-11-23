extends "res://game/components/component_base.gd"
## Движущаяся платформа: AnimatableBody2D (sync_to_physics) едет по пути — герой стоит на ней без проскальзывания.
## Зажатого героя выталкивает или убивает (вкладка «Объекты», группа "crusher"). Активна = едет.
## События reached_point {index}, reached_end.

const GeometryBuilder := preload("res://game/level/geometry_builder.gd")
const PathFollow := preload("res://game/components/path_follow.gd")
const ArtLoader := preload("res://game/level/art_loader.gd")

var body: AnimatableBody2D
var follow := PathFollow.new()
var _form := PackedVector2Array()
var _closed := false
var _origin := Vector2.ZERO     ## первая точка пути (мир)
var _waiting := false
var _img: Node2D
var _img_path := ""
var _paths: Dictionary = {}


func _setup(ctx: Dictionary) -> void:
	_paths = ctx.get("paths", {})
	var list: Array = shapes.get("form", [])
	if not list.is_empty():
		_form = list[0]["points"]
		_closed = list[0]["closed"]
	else:
		_form = PackedVector2Array([Vector2(-64, 0), Vector2(64, 0)])
	body = AnimatableBody2D.new()
	body.sync_to_physics = true
	body.collision_layer = WORLD_LAYER
	body.collision_mask = 0
	body.add_to_group("crusher")
	add_child(body)


func _apply() -> void:
	for c in body.get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			c.queue_free()
	if not (_closed and GeometryBuilder.fill_polygon(body, _form)):
		GeometryBuilder.fill_chain(body, _form, props.thickness, props.one_way, 60.0)
	var path: Dictionary = _paths.get(props.path_uid, {})
	var keep := [follow.i, follow.dirn, follow.u, follow.finished]
	var had := follow.pts.size() >= 2
	if path.is_empty():
		follow.setup(PackedVector2Array(), false, props.mode)
	else:
		follow.setup(path["points"], path["closed"], props.mode)
		_origin = (path["points"] as PackedVector2Array)[0]
		if had and follow.pts.size() >= 2:
			follow.i = clampi(keep[0], 0, follow.pts.size() - 1)
			follow.dirn = keep[1]
			follow.u = keep[2]
	_waiting = props.wait_for_player and follow.i == 0 and follow.u == 0.0
	if props.image != _img_path:
		if _img != null:
			_img.queue_free()
		_img = null
		_img_path = props.image
		if _img_path != "" and ArtLoader.exists(_img_path):
			_img = ArtLoader.make_node(_img_path, Rect2(), true)
			body.add_child(_img)
	if _img != null:
		_img.scale = Vector2.ONE * props.image_scale
	_place()


func _place() -> void:
	if follow.pts.size() >= 2:
		body.position = follow.pos(props.ease) - _origin


func _physics_process(delta: float) -> void:
	super(delta)
	if not active or follow.finished:
		return
	if _waiting:
		var pl = runtime.player if runtime != null else null
		if pl != null and is_instance_valid(pl) and pl.standing_on(body):
			_waiting = false
		else:
			return
	for e in follow.step(delta, props.speed, props.pause, props.ease):
		if e[0] == "point":
			emit_event("reached_point", {"index": e[1]})
		else:
			emit_event("reached_end")
			if props.wait_for_player:
				_waiting = true
	_place()
	queue_redraw()


func _snap() -> Dictionary:
	return {"i": follow.i, "dirn": follow.dirn, "u": follow.u, "wait": follow.wait, "fin": follow.finished, "waiting": _waiting}


func _restore(d: Dictionary) -> void:
	follow.i = d.get("i", 0)
	follow.dirn = d.get("dirn", 1)
	follow.u = d.get("u", 0.0)
	follow.wait = d.get("wait", 0.0)
	follow.finished = d.get("fin", false)
	_waiting = d.get("waiting", false)
	_place()
	body.reset_physics_interpolation()


func _draw() -> void:
	draw_set_transform(body.position)
	var col: Color = props.color
	if _closed and _form.size() >= 3:
		draw_colored_polygon(_form, col)
		var o := _form.duplicate()
		o.append(_form[0])
		draw_polyline(o, Color(0, 0, 0, 0.5), 2.0)
	elif _img == null:
		var th: float = props.thickness
		for i in range(_form.size() - 1):
			var a := _form[i]
			var b := _form[i + 1]
			var dn := (b - a).orthogonal().normalized()
			if dn.y < 0.0:
				dn = -dn
			draw_colored_polygon(PackedVector2Array([a, b, b + dn * th, a + dn * th]), col)
			draw_line(a, b, col.lightened(0.35), 3.0)
	draw_set_transform(Vector2.ZERO)
	_draw_debug()


func _debug() -> String:
	return ("ждёт героя" if _waiting else ("стоит" if not active or follow.finished else "едет")) + " · точка %d" % follow.i
