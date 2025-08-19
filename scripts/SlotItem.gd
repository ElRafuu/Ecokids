extends Button
class_name SlotItem

signal create_requested(slot_idx: int)
signal continue_requested(slot_idx: int)

@export var slot_index: int = 0
@onready var title_lbl: Label = %TitleLabel
@onready var name_lbl: Label  = %NameLabel
@onready var meta_lbl: Label  = %MetaLabel

func _ready() -> void:
	title_lbl.text = "Partida %d" % (slot_index + 1)
	update_from_data()
	pressed.connect(_on_pressed)

func update_from_data() -> void:
	if PerfilManager.has_profile(slot_index):
		var d := PerfilManager.slots[slot_index]
		name_lbl.text = d.get("name", "Jugador")
		var p := d.get("progress", {"level":1, "stars":0})
		meta_lbl.text = "Nivel %d • %d★" % [p.get("level",1), p.get("stars",0)]
	else:
		name_lbl.text = "Crear partida nueva"
		meta_lbl.text = ""

func _on_pressed() -> void:
	if PerfilManager.has_profile(slot_index):
		continue_requested.emit(slot_index)
	else:
		create_requested.emit(slot_index)
