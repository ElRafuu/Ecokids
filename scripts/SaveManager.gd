# SaveManager.gd — Godot 4.4.1
# Gestor global de perfiles/partidas (3 slots) con guardado automático.

extends Node
class_name SaveManager

const SAVE_PATH := "user://ecokids_profiles.json"
const MAX_SLOTS := 3

signal profiles_changed
signal active_profile_changed(slot: int)

var profiles: Array[Variant] = [null, null, null]
var active_slot: int = -1

func _ready() -> void:
	load_profiles()

# ---------- Carga/Guardado ----------
func load_profiles() -> void:
	profiles = [null, null, null]
	active_slot = -1

	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			var data := JSON.parse_string(txt)
			if typeof(data) == TYPE_DICTIONARY:
				var arr: Array = data.get("profiles", [])
				for i in range(MAX_SLOTS):
					profiles[i] = i < arr.size() ? arr[i] : null
				active_slot = int(data.get("active_slot", -1))

	emit_signal("profiles_changed")

func save_profiles() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		var payload := {
			"profiles": profiles,
			"active_slot": active_slot
		}
		f.store_string(JSON.stringify(payload, "", false))
		f.flush() # fuerza escritura en disco

# ---------- API de perfiles ----------
func is_slot_empty(slot: int) -> bool:
	return slot < 0 or slot >= MAX_SLOTS or profiles[slot] == null

func get_profile(slot: int) -> Dictionary:
	return {} if is_slot_empty(slot) else profiles[slot]

func create_profile(slot: int, name: String) -> bool:
	if slot < 0 or slot >= MAX_SLOTS or name.strip_edges().is_empty():
		return false
	if profiles[slot] != null:
		return false

	profiles[slot] = {
		"name": name.strip_edges(),
		"created": Time.get_datetime_string_from_system(true),
		"last_played": Time.get_datetime_string_from_system(true),
		"progress": 0
	}
	active_slot = slot
	save_profiles()
	emit_signal("profiles_changed")
	emit_signal("active_profile_changed", active_slot)
	return true

func select_slot(slot: int) -> bool:
	if is_slot_empty(slot):
		return false
	active_slot = slot
	var p: Dictionary = profiles[slot]
	p["last_played"] = Time.get_datetime_string_from_system(true)
	profiles[slot] = p
	save_profiles()
	emit_signal("active_profile_changed", active_slot)
	return true

func delete_profile(slot: int) -> bool:
	if is_slot_empty(slot):
		return false
	profiles[slot] = null
	if active_slot == slot:
		active_slot = -1
	save_profiles()
	emit_signal("profiles_changed")
	return true
