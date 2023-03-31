extends Node2D

export var t := 0.0
export var speed = 200.0

func _process(delta):
	t += delta
	$Path2D/PathFollow2D.offset = t * speed
