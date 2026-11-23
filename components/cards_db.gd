extends RefCounted
## Карточки-научпоп: таблица content/dialog/cards.csv (колонки id, title, where, when, image, text_ru, source, vo_line).
## Собранные карточки — в памяти на время сессии (сохранение на диск — фаза 8).

const PATH := "res://content/dialog/cards.csv"

static var _cards: Dictionary = {}
static var _loaded := false
static var collected: Dictionary = {}   ## id → true (за сессию)


static func reload() -> void:
	_cards.clear()
	_loaded = true
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return
	var head := f.get_csv_line()
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < 1 or row[0].strip_edges() == "":
			continue
		var d := {}
		for i in range(mini(head.size(), row.size())):
			d[head[i].strip_edges()] = row[i]
		_cards[d.get("id", row[0])] = d


static func all() -> Dictionary:
	if not _loaded:
		reload()
	return _cards


static func get_card(id: String) -> Dictionary:
	return all().get(id, {})


static func ids() -> PackedStringArray:
	var out := PackedStringArray(all().keys())
	out.sort()
	return out
