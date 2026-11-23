extends RefCounted
## Реплики: таблица content/dialog/lines.csv (колонки id, speaker, text, set, note; text_ru тоже понимается)
## и голос: content/vo/<speaker>/<id>.ogg (или .wav). Таблица перечитывается при каждом запуске уровня
## (reload) — агент поправил реплики, F5 — новые.

const PATH := "res://content/dialog/lines.csv"
const VO_DIR := "res://content/vo"
## Имена говорящих в титрах. Неизвестный говорящий показывается своим id.
const SPEAKER_TITLES := {"goddess": "Богиня", "hero": "Герой"}

static var _lines: Dictionary = {}
static var _sets: Dictionary = {}    ## имя набора → [id по порядку таблицы]
static var _loaded := false


static func reload() -> void:
	_lines.clear()
	_sets.clear()
	_loaded = true
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var head := f.get_csv_line()
	for i in range(head.size()):
		head[i] = head[i].strip_edges()
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.is_empty() or row[0].strip_edges() == "" or row[0].begins_with("#"):
			continue
		var d := {}
		for i in range(mini(head.size(), row.size())):
			d[head[i]] = row[i].strip_edges()
		if not d.has("text") and d.has("text_ru"):
			d["text"] = d["text_ru"]
		var id: String = d.get("id", "")
		_lines[id] = d
		var s: String = d.get("set", "")
		if s != "":
			if not _sets.has(s):
				_sets[s] = []
			_sets[s].append(id)


static func _ensure() -> void:
	if not _loaded:
		reload()


static func get_line(id: String) -> Dictionary:
	_ensure()
	return _lines.get(id, {})


static func has_line(id: String) -> bool:
	_ensure()
	return _lines.has(id)


static func set_lines(set_name: String) -> Array:
	_ensure()
	return _sets.get(set_name, [])


static func has_set(set_name: String) -> bool:
	_ensure()
	return _sets.has(set_name)


static func all_ids() -> Array:
	_ensure()
	return _lines.keys()


static func speaker_title(speaker: String) -> String:
	return SPEAKER_TITLES.get(speaker, speaker)


## Путь к файлу голоса (или ""): content/vo/<speaker>/<id>.ogg / .wav.
static func voice_path(id: String) -> String:
	var l := get_line(id)
	var sp: String = l.get("speaker", "")
	for ext in ["ogg", "wav"]:
		var p := "%s/%s/%s.%s" % [VO_DIR, sp, id, ext]
		if ResourceLoader.exists(p) or FileAccess.file_exists(p):
			return p
	return ""


## Звук голоса: импортированный — load(), свежий (ещё не открыт в Godot) — прямо из файла.
static func load_voice(path: String) -> AudioStream:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		var s = load(path)
		if s is AudioStream:
			return s
	if path.ends_with(".ogg"):
		return AudioStreamOggVorbis.load_from_file(path)
	if path.ends_with(".wav"):
		return AudioStreamWAV.load_from_file(path)
	return null
