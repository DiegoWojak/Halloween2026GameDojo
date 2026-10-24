class_name GameOver extends CanvasLayer
## Pantalla de muerte: pausa el juego, muestra qué enemigo te mató (una copia quieta
## de él) y los botones Reiniciar / Volver al menú. El jugador la busca por el grupo "game_over".

@export_file("*.tscn") var menu_scene := "res://Scenes/MainMenu.tscn"
## Escala de la copia del enemigo en la vista previa.
@export var preview_scale := 4.0

@onready var _killer_name: Label = %KillerName
@onready var _preview: Control = %Preview


func _ready() -> void:
	hide()
	%Restart.pressed.connect(_on_restart)
	%Menu.pressed.connect(_on_menu)


func show_killer(killer: Node2D) -> void:
	if is_instance_valid(killer):
		var script := killer.get_script() as Script
		_killer_name.text = String(script.get_global_name() if script else killer.name)
		_preview.add_child(_still_copy(killer))
	show()
	get_tree().paused = true


## Copia del enemigo sin lógica, centrada en la vista previa.
func _still_copy(killer: Node2D) -> Node2D:
	var copy := killer.duplicate() as Node2D
	copy.process_mode = Node.PROCESS_MODE_DISABLED
	for group in copy.get_groups():
		copy.remove_from_group(group) # que el nivel y la linterna no la cuenten
	if "lifetime" in copy:
		copy.lifetime = 0 # Seeker: si no, se borra solo
	# El Orbiter usa LIGHT_ONLY (solo se ve con luz): aquí va con material normal
	for item in [copy] + copy.get_children():
		if item is CanvasItem and item.material is CanvasItemMaterial:
			item.material = null
	copy.position = _preview.custom_minimum_size / 2
	copy.rotation = 0
	copy.scale = Vector2.ONE * preview_scale
	return copy


func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(menu_scene)
