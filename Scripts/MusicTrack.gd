class_name MusicTrack extends AudioStreamPlayer
## Música de escena que sobrevive al cambio de escena (se cuelga de /root).
## Escena nueva con otro track en el mismo canal: fade out del viejo y fade in del nuevo.
## Mismo stream (p. ej. reiniciar tras morir): el que suena sigue sin cortarse.
## Canales independientes: "music" (track del nivel/menú) y "ambient" (fondo continuo).
## Uso: nodo MusicTrack en la escena con su `stream` (import en loop) y bus Music.

## Segundos del fade in/out.
@export var fade_time := 1.5
## Un track por canal; canales distintos suenan a la vez.
@export var channel := &"music"

static var _current := {}


func _ready() -> void:
	var old: MusicTrack = _current.get(channel)
	if old and old.stream == stream:
		queue_free()
		return
	_current[channel] = self
	process_mode = Node.PROCESS_MODE_ALWAYS # sigue sonando con el juego en pausa (GameOver)
	if old:
		var out := old.create_tween()
		out.tween_property(old, "volume_linear", 0.0, fade_time)
		out.tween_callback(old.queue_free)
	_start.call_deferred()


func _start() -> void:
	reparent(get_tree().root) # sale de la escena: no muere al cambiarla
	var target := volume_linear
	volume_linear = 0.0
	play()
	create_tween().tween_property(self, "volume_linear", target, fade_time)
