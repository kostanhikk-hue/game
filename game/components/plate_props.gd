extends Resource
## Свойства нажимной плиты.

const LABELS := {"pressed_by": "Что нажимает", "width": "Ширина", "release_delay": "Задержка отпускания",
	"targets": "Цели связей", "link_mode": "Что делать с целями", "reset_on_death": "Откат при смерти героя"}
const UNITS := {"width": "px", "release_delay": "с"}
const HINTS := {
	"pressed_by": "Любое тело — герой, враги, штрихи кисти, ящики…",
	"release_delay": "Плита остаётся нажатой столько секунд после того, как с неё сошли.",
	"link_mode": "Обычно «Следовать»: стоишь — дверь открыта, сошёл — закрыта.",
}

@export_enum("Герой", "Враг", "Любое тело") var pressed_by: int = 0
@export_range(16.0, 256.0, 4.0, "or_greater") var width: float = 48.0
@export_range(0.0, 5.0, 0.05) var release_delay: float = 0.0
@export var targets: PackedStringArray = PackedStringArray()
@export_enum("Включить", "Выключить", "Переключить", "Следовать") var link_mode: int = 3
@export var reset_on_death: bool = true
