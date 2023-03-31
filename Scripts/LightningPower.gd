extends Node2D

func _ready():
	$AnimationPlayer.get_animation("Bird").loop = true
	$Sprite.visible = true
	$AnimationPlayer.play("Bird")

func death():
	if $AnimationPlayer.current_animation != "Bird":
		return false
	kill_bird(".")
	return true

func kill_bird(name: String):
	print("Killing bird")
	$AnimationPlayer.play("Death")
	yield(get_tree().create_timer(0.92), "timeout")
	$Sprite.visible = false
	$AnimationPlayer.play("Rebirth")
	yield(get_tree().create_timer(4), "timeout")
	rebirth()

func rebirth():
	print("Rebirth!")
	$AnimationPlayer.get_animation("Bird").loop = true
	$AnimationPlayer.play("Bird")
