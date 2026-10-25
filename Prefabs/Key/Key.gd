class_name Key
extends Area2D
## Llave recogible. Colocar la instancia donde se quiera en el nivel.
## Al tocarla el jugador (grupo "player") emite collected, suena y desaparece.
## El nivel la encuentra por el grupo "keys".

signal collected

## Sonido al recogerla (bus Effects).
@export var pickup_sound: AudioStream = preload("res://MusicSfx/key-adquired.mp3")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	collected.emit()
	hide()
	set_deferred("monitoring", false)
	var sfx := AudioStreamPlayer.new()
	sfx.stream = pickup_sound
	sfx.bus = &"Effects"
	add_child(sfx)
	sfx.play()
	await sfx.finished # se borra cuando termina de sonar
	queue_free()
