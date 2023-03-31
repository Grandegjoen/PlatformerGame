extends Node

var enabled = true

func _ready():
	pass # Replace with function body.
	
func picked_up():
	if enabled == false:
		return
	$AnimationPlayer.play("PickedUp")
	enabled = false
	yield(get_tree().create_timer(5), "timeout")
	enabled = true
	$AnimationPlayer.play("Default")
