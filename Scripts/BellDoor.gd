extends Node

export var lock_id = ""
export var time_open: float = 3.0
var active = false


func open_door():
	if active:
		$Timer.start()
		return
	get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", true)
	$Sprite.frame = 1
	active = true
	$Timer.wait_time = time_open
	$Timer.start()

func close_door():
	active = false
	get_node("StaticBody2D/CollisionShape2D").disabled = false
	$Sprite.frame = 0
