extends Node2D

export var floating = false
export var float_amount_v = 0
export var speed = 1
onready var animation_player = $AnimationPlayer


func _ready():
	if floating == false or float_amount_v == 0:
		return
	var animation = animation_player.get_animation("Floating")
	animation.track_set_key_value(0, 1, Vector2(0, float_amount_v))

	animation_player.playback_speed = speed
	animation_player.play("Floating")
