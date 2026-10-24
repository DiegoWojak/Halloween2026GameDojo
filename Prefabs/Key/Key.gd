class_name Key
extends Area2D
## Llave recogible. Colocar la instancia donde se quiera en el nivel.
## Al tocarla el jugador (grupo "player") emite collected y desaparece.
## El nivel la encuentra por el grupo "keys".

signal collected


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collected.emit()
		queue_free()
